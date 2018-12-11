require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

filetype = Bkmkr::Project.filename_split.split(".").pop

project_html_file = File.join(Bkmkr::Paths.project_tmp_dir, "#{Bkmkr::Project.filename}.html")

htmlmakerjs_path = File.join(Bkmkr::Paths.scripts_dir, "htmlmaker_js")

htmlmaker_bin = File.join(htmlmakerjs_path, 'bin', 'htmlmaker')

styles_json = File.join(htmlmakerjs_path, 'styles.json')

stylefunctions_js = File.join(htmlmakerjs_path, 'style-functions.js')

htmltohtmlbook_js = File.join(htmlmakerjs_path, 'lib', 'htmltohtmlbook.js')

generateTOC_js = File.join(htmlmakerjs_path, 'lib', 'generateTOC.js')

docxtoxml_py = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "docxtoxml.py")

saxonpath = File.join(Bkmkr::Paths.resource_dir, "saxon", "#{Bkmkr::Tools.xslprocessor}.jar")

source_xml = File.join(Bkmkr::Paths.project_tmp_dir, "#{Bkmkr::Project.filename}.xml")

word_to_html_xsl = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "wordtohtml.xsl")

headings_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "headings.js")

inlines_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "inlines.js")

evaluate_pis = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "evaluate_pis.js")

title_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "title.js")

xslonly_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "xsl_only.js")

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

# for xsl conversion
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

# for xsl conversion
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

def fixFootnotes(content, logkey='')
	# place footnote text inline per htmlbook
	filecontents = content.gsub(/(<span class=")(spansuperscriptcharacterssup)(" id="\d+")/,"\\1FootnoteReference\\3")
												.gsub(/(<span class="spansuperscriptcharacterssup">)(<span class="FootnoteReference" id="\d+"><\/span>)(<\/span>)/,"\\2")
	footnotes = content.scan(/(<div class="footnotetext" id=")(\d+)(">)(\s?)(.*?)(<\/div>)/)

	footnotes.each do |f|
		noteref = f[1]
		notetext = f[4].gsub(/<p/,"<span").gsub(/<\/p/,"</span")
		filecontents = filecontents.gsub(/<span class="FootnoteReference" id="#{noteref}"><\/span>/,"<span data-type=\"footnote\" id=\"footnote_#{noteref}\">#{notetext}</span>")
														   .gsub(/<span class="FootnoteReference" id="#{noteref}"\/>/,"<span data-type=\"footnote\" id=\"footnote_#{noteref}\">#{notetext}</span>")
	end
	return filecontents
rescue => logstring
	return content
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def fixEndnotes(content, logkey='')
	# add endnote ref id as static content
	filecontents = content.gsub(/(<span class=")(.ndnote.eference)(" id=")(\d+)(">)(<\/span>)/,"\\1endnotereference\\3endnoteref_\\4\\5\\4\\6")
												.gsub(/(div class="endnotetext" id=")/,"\\1endnotetext_")
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

data_hash = readConfigJson('read_config_json')
#local definition(s) based on config.json
doctemplate_version = data_hash['doctemplate_version']
doctemplatetype = data_hash['doctemplatetype']

#### replacing \/ with /\
# # get template_version value from json logfile (local_log_hash is a hash of the json logfile, read in at the beginning of each script)
# if local_log_hash.key?('htmlmaker_preprocessing.rb')
#   template_version = local_log_hash['htmlmaker_preprocessing.rb']['template_version']
# else
#   # if htmlmaker_preprocessing.rb was not run, set this value to an empty string
#   template_version = ''
# end

# if the docx file exists, convert to html
#   use doctemplatetype to determine which conversion method
#   later, when we want to discontinue a method, just skip the conversion, and create errfile in filearchive_postprocessing?
#   if we want to make sure no wrongly constructed files are picked up, we can rm then in cleanup/cleanup_preprocessing too.
if File.file?(Bkmkr::Paths.project_docx_file)
  case doctemplatetype
  when 'rsuite'
  # if doctemplate_version == 'rsuite'
    # convert to html via htmlmaker_js
    htmlmakerRunNode(htmlmaker_bin, "#{Bkmkr::Paths.project_docx_file} #{Bkmkr::Paths.project_tmp_dir} #{styles_json} #{stylefunctions_js}", 'convertdocx_to_html')

    # make copy of output html to match name 'outputtmp_html'
    copyFile(project_html_file, Bkmkr::Paths.outputtmp_html, 'copy_and_rename_html_to_outputtmphtml')

    # convert html to htmlbook
    htmlmakerRunNode(htmltohtmlbook_js, Bkmkr::Paths.outputtmp_html, 'convert_to_htmlbook')

    # generateTOC
    htmlmakerRunNode(generateTOC_js, Bkmkr::Paths.outputtmp_html, 'generateTOC_js')
  when 'sectionstart'
    # convert to html via htmlmaker_js
    htmlmakerRunNode(htmlmaker_bin, "#{Bkmkr::Paths.project_docx_file} #{Bkmkr::Paths.project_tmp_dir} #{styles_json} #{stylefunctions_js}", 'convertdocx_to_html')

    # make copy of output html to match name 'outputtmp_html'
    copyFile(project_html_file, Bkmkr::Paths.outputtmp_html, 'copy_and_rename_html_to_outputtmphtml')

    # convert html to htmlbook
    htmlmakerRunNode(htmltohtmlbook_js, Bkmkr::Paths.outputtmp_html, 'convert_to_htmlbook')

    # generateTOC
    htmlmakerRunNode(generateTOC_js, Bkmkr::Paths.outputtmp_html, 'generateTOC_js')
  when 'pre-sectionstart'
    # convert docx to xml
    convertdocxtoxml(filetype, docxtoxml_py, 'convert_docx_to_xml')

    # convert xml to html
    convertxmltohtml(filetype, saxonpath, source_xml, word_to_html_xsl, 'convert_xml_to_html')
  end
# if infile was already html, rename a copy of file to 'outputtmp.html'
elsif File.file?(project_html_file)
  copyFile(project_html_file, Bkmkr::Paths.outputtmp_html, 'copy_and_rename_html_to_outputtmphtml')
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

# # add correct markup for inlines (em, strong, sup, sub)
htmlmakerRunNode(inlines_js, Bkmkr::Paths.outputtmp_html, 'inlines_js')

# # change p children of pre tags to spans
htmlmakerRunNode(preformatted_js, Bkmkr::Paths.outputtmp_html, 'preformatted_js')

# for xsl-only: I think this includes stuff from formerly included:
  # footnotes.js, lists.js, parts.js, strip-toc.js, headings.js(for xsl) and some from band-aid.js
  # more items from bandaid were moved to htmlpostprocessing
if doctemplate_version == 'pre-sectionstart'
  htmlmakerRunNode(xslonly_js, Bkmkr::Paths.outputtmp_html, 'xslonly_js')
else
  # # add headings to all sections for sectionstart
  htmlmakerRunNode(headings_js, Bkmkr::Paths.outputtmp_html, 'headings_js')
end

filecontents = readOutputHtml('read_output_html_b')

# run method: stripEndnotes
filecontents = stripEndnotes(filecontents, 'strip_endnotes')

overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents, 'overwrite_output_html_b')

# set html title to match JSON
htmlmakerRunNode(title_js, "#{Bkmkr::Paths.outputtmp_html} \"#{Metadata.booktitle}\"", 'title_js')

# add meta tag to html with template_version
unless doctemplate_version.nil? || doctemplate_version.empty?
  htmlmakerRunNode(version_metatag_js, "#{Bkmkr::Paths.outputtmp_html} \"#{doctemplate_version}\"", 'add_doctemplate-version_meta_tag')
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
