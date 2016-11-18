require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
json_log_hash = Bkmkr::Paths.jsonlog_hash
json_log_hash[Bkmkr::Paths.thisscript] = {}
log_hash = json_log_hash[Bkmkr::Paths.thisscript]

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

# ---------------------- METHODS

def convertdocxtoxml(filetype,docxtoxml_py)
	unless filetype == "html"
		Bkmkr::Tools.runpython(docxtoxml_py, Bkmkr::Paths.project_docx_file)
	else
		'input file is html, skipping'
	end
	true
rescue => e
	e
end

def convertxmltohtml(filetype,saxonpath,source_xml,word_to_html_xsl)
	unless filetype == "html"
		`java -jar "#{saxonpath}" -s:"#{source_xml}" -xsl:"#{word_to_html_xsl}" -o:"#{Bkmkr::Paths.outputtmp_html}"`
		true
	else
		Mcmlln::Tools.copyFile(Bkmkr::Paths.project_tmp_file, Bkmkr::Paths.outputtmp_html)
		'input file is html, skipping (copied input file to project_tmp)'
	end
rescue => e
	e
end

def readOutputHtml
	filecontents = File.read(Bkmkr::Paths.outputtmp_html)
	return true, filecontents
rescue => e
	return e, ''
end

def fixFootnotes(content)
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
	return true, filecontents
rescue => e
	return e, content
end

def fixEndnotes(content)
	# add endnote ref id as static content
	filecontents = content.gsub(/(<span class=")(.ndnote.eference)(" id=")(\d+)(">)(<\/span>)/,"\\1endnotereference\\3endnoteref-\\4\\5\\4\\6")
												.gsub(/(div class="endnotetext" id=")/,"\\1endnotetext-")
	return true, filecontents
rescue => e
	return e, content
end

def fixEntities(content)
	filecontents = content.gsub(/&nbsp/,"&#160")
												.gsub(/(<img.*?)(>)/,"\\1/\\2")
												.gsub(/(<br)(>)/,"\\1/\\2")
	return true, filecontents
rescue => e
	return e, content
end

def overwriteFile(path,filecontents)
	Mcmlln::Tools.overwriteFile(path, filecontents)
	true
rescue => e
	e
end

def htmlmakerRunNode(jsfile, extra_arg=nil)
	if extra_arg.nil?
		Bkmkr::Tools.runnode(jsfile, Bkmkr::Paths.outputtmp_html)
	else
		Bkmkr::Tools.runnode(jsfile, extra_arg)
	end
	true
rescue => e
	e
end

def stripEndnotes(content)
	# removes endnotes section if no content
	filecontents = content
	endnote_txt = content.match(/(<section data-type=\"appendix\" class=\"endnotes\".*?\">)((.|\n)*?)(<\/section>)/).to_s
	unless endnote_txt.include?("<p ")
		filecontents = content.gsub(/(<section data-type=\"appendix\" class=\"endnotes\".*?\">)((.|\n)*?)(<\/section>)/,"")
	end
	return true, filecontents
rescue => e
	return e, content
end

# ---------------------- PROCESSES

# convert docx to xml
log_hash['convert_docx_to_xml'] = convertdocxtoxml(filetype, docxtoxml_py)

# convert xml to html
log_hash['convert_xml_to_html'] = convertxmltohtml(filetype, saxonpath, source_xml, word_to_html_xsl)

#read in html
log_hash['read_output_html_a'], filecontents = readOutputHtml

# run method: fixFootnotes
log_hash['fix_footnotes'], filecontents = fixFootnotes(filecontents)

# run method: fixEndnotes
log_hash['fix_endnotes'], filecontents = fixEndnotes(filecontents)

# run method: fixEntities
log_hash['fix_entities'], filecontents = fixEntities(filecontents)

#write out edited html
log_hash['overwrite_output_html_a'] = overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents)

# # strip extraneous footnote section from html
log_hash['footnotes_js'] = htmlmakerRunNode(footnotes_js)

# # strip static toc from html
log_hash['strip_toc_js'] = htmlmakerRunNode(strip_toc_js)

# # convert parts to divs
log_hash['parts_js'] = htmlmakerRunNode(parts_js)

# # add headings to all sections
log_hash['headings_js'] = htmlmakerRunNode(headings_js)

# # add correct markup for inlines (em, strong, sup, sub)
log_hash['inlines_js'] = htmlmakerRunNode(inlines_js)

# # add correct markup for lists
log_hash['lists_js'] = htmlmakerRunNode(lists_js)

# # change p children of pre tags to spans
log_hash['preformatted_js'] = htmlmakerRunNode(preformatted_js)

log_hash['read_output_html_b'], filecontents = readOutputHtml

# run method: stripEndnotes
log_hash['strip_endnotes'], filecontents = stripEndnotes(filecontents)

log_hash['overwrite_output_html_b'] = overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents)

# set html title to match JSON
log_hash['title_js'] = htmlmakerRunNode(title_js, "#{Bkmkr::Paths.outputtmp_html} \"#{Metadata.booktitle}\"")

# evaluate processing instructions
log_hash['evaluate_pis'] = htmlmakerRunNode(evaluate_pis)

# ---------------------- LOGGING

# html file should exist
if File.file?("#{Bkmkr::Paths.outputtmp_html}")
	test_html_status = "pass: html file was created successfully"
else
	test_html_status = "FAIL: html file was created successfully"
end

# Printing the test results to the log file
File.open("#{Bkmkr::Paths.log_file}", 'a+') do |f|
	f.puts "----- HTMLMAKER PROCESSES"
	f.puts test_html_status
	f.puts "finished htmlmaker"
end

# Write json log:
log_hash['completed'] = Time.now
Mcmlln::Tools.write_json(json_log_hash, Bkmkr::Paths.json_log)
