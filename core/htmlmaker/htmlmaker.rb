require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

required_version_for_jsconvert = '4.1.0'

filetype = Bkmkr::Project.filename_split.split(".").pop

saxonpath = File.join(Bkmkr::Paths.resource_dir, "saxon", "#{Bkmkr::Tools.xslprocessor}.jar")

docxtoxml_py = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "docxtoxml.py")

source_xml = File.join(Bkmkr::Paths.project_tmp_dir, "#{Bkmkr::Project.filename}.xml")

word_to_html_xsl = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "wordtohtml.xsl")

project_html_file = File.join(Bkmkr::Paths.project_tmp_dir, "#{Bkmkr::Project.filename}.html")

htmlmakerjs_path = File.join(Bkmkr::Paths.scripts_dir, "htmlmaker_js")

htmlmaker = File.join(htmlmakerjs_path, 'bin', 'htmlmaker')

styles_json = File.join(htmlmakerjs_path, 'styles.json')

stylefunctions_js = File.join(htmlmakerjs_path, 'style-functions.js')

htmltohtmlbook_js = File.join(htmlmakerjs_path, 'lib', 'htmltohtmlbook.js')

generateTOC_js = File.join(htmlmakerjs_path, 'lib', 'generateTOC.js')

headings_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "headings.js")

xsl_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "xsl_only.js")

inlines_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "inlines.js")

evaluate_pis = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "evaluate_pis.js")

title_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "title.js")

version_metatag_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "version_metatag.js")

preformatted_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "preformatted.js")

# ---------------------- METHODS

def readConfigJson(logkey='')
  data_hash = Mcmlln::Tools.readjson(Metadata.configfile)
  return data_hash
rescue => logstring
  return {}
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# returns true if v1 is nil, empty, or >= v2. Otherwise returns false
def versionCompare(v1, v2, logkey='')
  if v1.nil?
    logstring = "template_version is nil, indicating a non-Macmillan bookmaker instance; returning 'true' for js conversion"
    return true
  elsif v1.empty?
    logstring = "template_version is empty, indicating an html file, no conversion necessary"
    return true
  elsif v1.match(/[^\d.]/) || v2.match(/[^\d.]/)
    logstring = "template_version string includes nondigit chars: returning false for xsl conversion"
    return false
  elsif v1 == v2
    logstring = "template_version meets requirements for jsconvert"
    return true
  else
    v1long = v1.split('.').length
    v2long = v2.split('.').length
    maxlength = v1long > v2long ? v1long : v2long
    0.upto(maxlength-1) { |n|
      puts "n is #{n}"
      v1split = v1.split('.')[n].to_i
      v2split = v2.split('.')[n].to_i
      if v1split > v2split
        logstring = "template_version meets requirements for jsconvert"
        return true
      elsif v1split < v2split
        logstring = "template_version is older than required version for jsconvert: returning false for xsl conversion"
        return false
      elsif n == maxlength-1 && v1split == v2split
        logstring = "template_version meets requirements for jsconvert"
        return true
      end
    }
  end
rescue => logstring
  return true
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping Bkmkr::Tools.runpython in a new method for this script; to return a result for json_logfile
def convertdocxtoxml(filetype, docxtoxml_py, logkey='')
	unless filetype == "html"
		Bkmkr::Tools.runpython(docxtoxml_py, Bkmkr::Paths.project_docx_file)
	else
		logstring = 'input file is html, skipping'
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def convertxmltohtml(filetype, saxonpath, source_xml, word_to_html_xsl, logkey='')
	unless filetype == "html"
		`java -jar "#{saxonpath}" -s:"#{source_xml}" -xsl:"#{word_to_html_xsl}" -o:"#{Bkmkr::Paths.outputtmp_html}"`
	else
		Mcmlln::Tools.copyFile(Bkmkr::Paths.project_tmp_file, Bkmkr::Paths.outputtmp_html)
		logstring = 'input file is html, skipping (copied input file to project_tmp)'
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping Bkmkr::Tools.runnode in a new method for this script; to return a result for json_logfile
def htmlmakerRunNode(jsfile, args, logkey='')
	Bkmkr::Tools.runnode(jsfile, args)
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def copyFile(srcFile, destFile, logkey='')
	Mcmlln::Tools.copyFile(srcFile, destFile)
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def readOutputHtml(logkey='')
	filecontents = File.read(Bkmkr::Paths.outputtmp_html)
	return filecontents
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def fixFootnotes(content, logkey='')
	# place footnote text inline per htmlbook
	filecontents = content.gsub(/(<span class=")(spansuperscriptcharacterssup)(" id="\d+")/,"\\1FootnoteReference\\3")
												.gsub(/(<span class="spansuperscriptcharacterssup">)(<span class="FootnoteReference" id="\d+"><\/span>)(<\/span>)/,"\\2")
	footnotes = content.scan(/(<div class="footnotetext" id=")(\d+)(">)(\s?)(.*?)(<\/div>)/)

	footnotes.each do |f|
		noteref = f[1]
		notetext = f[4].gsub(/<p/,"<span").gsub(/<\/p/,"</span")
		filecontents = filecontents.gsub(/<span class="FootnoteReference" id="#{noteref}"><\/span>/,"<span data-type=\"footnote\" id=\"footnote-#{noteref}\">#{notetext}</span>")
														   .gsub(/<span class="FootnoteReference" id="#{noteref}"\/>/,"<span data-type=\"footnote\" id=\"footnote-#{noteref}\">#{notetext}</span>")
	end
	return filecontents
rescue => logstring
	return content
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def fixEndnotes(content, logkey='')
	# add endnote ref id as static content
	filecontents = content.gsub(/(<span class=")(.ndnote.eference)(" id=")(\d+)(">)(<\/span>)/,"\\1endnotereference\\3endnoteref-\\4\\5\\4\\6")
												.gsub(/(div class="endnotetext" id=")/,"\\1endnotetext-")
	return filecontents
rescue => logstring
	return content
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def fixEntities(content, logkey='')
	filecontents = content.gsub(/&nbsp/,"&#160")
												.gsub(/(<img.*?)(>)/,"\\1/\\2")
												.gsub(/(<br)(>)/,"\\1/\\2")
	return filecontents
rescue => logstring
	return content
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def overwriteFile(path,filecontents, logkey='')
	Mcmlln::Tools.overwriteFile(path, filecontents)
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def stripEndnotes(content, logkey='')
	# removes endnotes section if no content
	filecontents = content
	endnote_txt = content.match(/(<section data-type=\"appendix\" class=\"endnotes\".*?\">)((.|\n)*?)(<\/section>)/).to_s
	unless endnote_txt.include?("<p ")
		filecontents = content.gsub(/(<section data-type=\"appendix\" class=\"endnotes\".*?\">)((.|\n)*?)(<\/section>)/,"")
	end
	return filecontents
rescue => logstring
	return content
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# ---------------------- PROCESSES

# get template_version value from config.json.
data_hash = readConfigJson('read_config_json')
# If no config.json file is present or it does not have a 'template_version' key, this value will be nil:
template_version = data_hash['template_version']

# this method will return true if:
#   template_version is nil (this would be the case if htmlpreprocessing.rb was not run, as in the case of a non-Macmillan bookmaker-instance),
#   template_version is empty (this would be the case when the input file is an html file)
#   template_version >= required_version_for_jsconvert
# it will return false if
#   template_version < required_version_for_jsconvert
#   template_version is 'not-found' or has any other non-digit or characters (besides '.')
htmlmaker_js_version_test = versionCompare(template_version, required_version_for_jsconvert, 'version_compare')
@log_hash['htmlmaker_js_version_test'] = htmlmaker_js_version_test

# convert a .docx tp HTML, via js or xsl: depending on value of htmlmaker_js_version_test from above
if htmlmaker_js_version_test == true
  # if infile is docx, convert to htmlbook html & generate TOC; otherwise bypass
  # else, if infile is already html, rename a copy of file to 'outputtmp.html'
  if File.file?(Bkmkr::Paths.project_docx_file)
    htmlmakerRunNode(htmlmaker, "#{Bkmkr::Paths.project_docx_file} #{Bkmkr::Paths.project_tmp_dir} #{styles_json} #{stylefunctions_js}", 'convertdocx_to_html')

    # make copy of output html to match name 'outputtmp_html'
    # <<this is a quick workaround, since htmlmaker_js outputs an html file with basename matching in-file..
    # .. and subsequent items in the toolchain expect outputtmp.html
    # Another alternative would be set outputtmp_html in header.rb to match project_html_file below: >>
    copyFile(project_html_file, Bkmkr::Paths.outputtmp_html, 'copy_and_rename_html_to_outputtmphtml')

    # convert html to htmlbook
    htmlmakerRunNode(htmltohtmlbook_js, Bkmkr::Paths.outputtmp_html, 'convert_to_htmlbook')

    # generateTOC
    htmlmakerRunNode(generateTOC_js, Bkmkr::Paths.outputtmp_html, 'generateTOC_js')

  elsif File.file?(project_html_file)
    copyFile(project_html_file, Bkmkr::Paths.outputtmp_html, 'copy_and_rename_html_to_outputtmphtml')
  end

elsif htmlmaker_js_version_test == false

  # convert docx to xml
  convertdocxtoxml(filetype, docxtoxml_py, 'convert_docx_to_xml')

  # convert xml to html
  convertxmltohtml(filetype, saxonpath, source_xml, word_to_html_xsl, 'convert_xml_to_html')
end

# read in html
filecontents = readOutputHtml('read_output_html_a')

# run method: fixFootnotes
filecontents = fixFootnotes(filecontents, 'fix_footnotes')

# run method: fixEndnotes
filecontents = fixEndnotes(filecontents, 'fix_endnotes')

# run method: fixEntities
filecontents = fixEntities(filecontents, 'fix_entities')

#write out edited html
overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents, 'overwrite_output_html_a')

if htmlmaker_js_version_test == true

  # # add headings to all sections
  htmlmakerRunNode(headings_js, Bkmkr::Paths.outputtmp_html, 'headings_js')

elsif htmlmaker_js_version_test == false

  # # run supplemental js transformations for the xsl-conversion, consolidating legacy files:
  # #   footnotes.js, strip-toc.js, parts.js, headings.js, lists.js, + 1 item from bandaid.js
  htmlmakerRunNode(xsl_js, Bkmkr::Paths.outputtmp_html, 'xsl_only_js')

end

# # add correct markup for inlines (em, strong, sup, sub)
htmlmakerRunNode(inlines_js, Bkmkr::Paths.outputtmp_html, 'inlines_js')

# # change p children of pre tags to spans
htmlmakerRunNode(preformatted_js, Bkmkr::Paths.outputtmp_html, 'preformatted_js')

filecontents = readOutputHtml('read_output_html_b')

# run method: stripEndnotes
filecontents = stripEndnotes(filecontents, 'strip_endnotes')

overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents, 'overwrite_output_html_b')

# set html title to match JSON
htmlmakerRunNode(title_js, "#{Bkmkr::Paths.outputtmp_html} \"#{Metadata.booktitle}\"", 'title_js')

# add meta tag to html with template_version
unless template_version.nil? || template_version.empty?
  htmlmakerRunNode(version_metatag_js, "#{Bkmkr::Paths.outputtmp_html} \"#{template_version}\"", 'add_template-version_meta_tag')
end

# evaluate processing instructions
htmlmakerRunNode(evaluate_pis, Bkmkr::Paths.outputtmp_html, 'evaluate_pis')

# html file should exist
if File.file?("#{Bkmkr::Paths.outputtmp_html}")
	test_html_status = "pass: html file was created successfully"
else
	test_html_status = "FAIL: html file was created successfully"
end
@log_hash['html_status']=test_html_status


# ---------------------- LOGGING
# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
