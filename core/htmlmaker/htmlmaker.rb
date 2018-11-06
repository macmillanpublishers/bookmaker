require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

filetype = Bkmkr::Project.filename_split.split(".").pop

project_html_file = File.join(Bkmkr::Paths.project_tmp_dir, "#{Bkmkr::Project.filename}.html")

htmlmakerjs_path = File.join(Bkmkr::Paths.scripts_dir, "htmlmaker_js")

htmlmaker = File.join(htmlmakerjs_path, 'bin', 'htmlmaker')

styles_json = File.join(htmlmakerjs_path, 'styles.json')

stylefunctions_js = File.join(htmlmakerjs_path, 'style-functions.js')

htmltohtmlbook_js = File.join(htmlmakerjs_path, 'lib', 'htmltohtmlbook.js')

generateTOC_js = File.join(htmlmakerjs_path, 'lib', 'generateTOC.js')

headings_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "headings.js")

inlines_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "inlines.js")

evaluate_pis = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "evaluate_pis.js")

title_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "title.js")

version_metatag_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "version_metatag.js")

preformatted_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "preformatted.js")

# ---------------------- METHODS

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

# get template_version value from json logfile (local_log_hash is a hash of the json logfile, read in at the beginning of each script)
if local_log_hash.key?('htmlmaker_preprocessing.rb')
  template_version = local_log_hash['htmlmaker_preprocessing.rb']['template_version']
else
  # if htmlmaker_preprocessing.rb was not run, set this value to an empty string
  template_version = ''
end

# if the docx file exists, convert to html via js
if File.file?(Bkmkr::Paths.project_docx_file)
  # convert to html via htmlmaker_js
  htmlmakerRunNode(htmlmaker, "#{Bkmkr::Paths.project_docx_file} #{Bkmkr::Paths.project_tmp_dir} #{styles_json} #{stylefunctions_js}", 'convertdocx_to_html')

  # make copy of output html to match name 'outputtmp_html'
  copyFile(project_html_file, Bkmkr::Paths.outputtmp_html, 'copy_and_rename_html_to_outputtmphtml')

  # convert html to htmlbook
  htmlmakerRunNode(htmltohtmlbook_js, Bkmkr::Paths.outputtmp_html, 'convert_to_htmlbook')

  # generateTOC
  htmlmakerRunNode(generateTOC_js, Bkmkr::Paths.outputtmp_html, 'generateTOC_js')

elsif File.file?(project_html_file)
  # if infile was already html, rename a copy of file to 'outputtmp.html'
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

# # add headings to all sections
htmlmakerRunNode(headings_js, Bkmkr::Paths.outputtmp_html, 'headings_js')

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
