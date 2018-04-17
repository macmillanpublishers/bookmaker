require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

filetype = Bkmkr::Project.filename_split.split(".").pop

saxonpath = File.join(Bkmkr::Paths.resource_dir, "saxon", "#{Bkmkr::Tools.xslprocessor}.jar")

docxtoxml_py = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "docxtoxml.py")

source_xml = File.join(Bkmkr::Paths.project_tmp_dir, "#{Bkmkr::Project.filename}.xml")

word_to_html_xsl = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "wordtohtml.xsl")

footnotes_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "footnotes.js")

strip_toc_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "strip-toc.js")

parts_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "parts.js")

headings_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "headings.js")

inlines_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "inlines.js")

lists_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "lists.js")

evaluate_pis = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "evaluate_pis.js")

title_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "title.js")

preformatted_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "preformatted.js")

bandaid_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "bandaid.js")

# ---------------------- METHODS

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

## wrapping Bkmkr::Tools.runnode in a new method for this script; to return a result for json_logfile
def htmlmakerRunNode(jsfile, args, logkey='')
	Bkmkr::Tools.runnode(jsfile, args)
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

# convert docx to xml
convertdocxtoxml(filetype, docxtoxml_py, 'convert_docx_to_xml')

# convert xml to html
convertxmltohtml(filetype, saxonpath, source_xml, word_to_html_xsl, 'convert_xml_to_html')

#read in html
filecontents = readOutputHtml('read_output_html_a')

# run method: fixFootnotes
filecontents = fixFootnotes(filecontents, 'fix_footnotes')

# run method: fixEndnotes
filecontents = fixEndnotes(filecontents, 'fix_endnotes')

# run method: fixEntities
filecontents = fixEntities(filecontents, 'fix_entities')

#write out edited html
overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents, 'overwrite_output_html_a')

# # strip extraneous footnote section from html
htmlmakerRunNode(footnotes_js, Bkmkr::Paths.outputtmp_html, 'footnotes_js')

# # strip static toc from html
htmlmakerRunNode(strip_toc_js, Bkmkr::Paths.outputtmp_html, 'strip_toc_js')

# # convert parts to divs
htmlmakerRunNode(parts_js, Bkmkr::Paths.outputtmp_html, 'parts_js')

# # add headings to all sections
htmlmakerRunNode(headings_js, Bkmkr::Paths.outputtmp_html, 'headings_js')

# # add correct markup for inlines (em, strong, sup, sub)
htmlmakerRunNode(inlines_js, Bkmkr::Paths.outputtmp_html, 'inlines_js')

# # add correct markup for lists
htmlmakerRunNode(lists_js, Bkmkr::Paths.outputtmp_html, 'lists_js')

# # change p children of pre tags to spans
htmlmakerRunNode(preformatted_js, Bkmkr::Paths.outputtmp_html, 'preformatted_js')

# temporary fixes to potentially be discarded once we switch to javascript conversion
htmlmakerRunNode(bandaid_js, Bkmkr::Paths.outputtmp_html, 'bandaid_js')

filecontents = readOutputHtml('read_output_html_b')

# run method: stripEndnotes
filecontents = stripEndnotes(filecontents, 'strip_endnotes')

overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents, 'overwrite_output_html_b')

# set html title to match JSON
htmlmakerRunNode(title_js, "#{Bkmkr::Paths.outputtmp_html} \"#{Metadata.booktitle}\"", 'title_js')

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
