require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES

saxonpath = File.join(Bkmkr::Paths.resource_dir, "saxon", "#{Bkmkr::Tools.xslprocessor}.jar")

docxtoxml_py = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "docxtoxml.py")

source_xml = File.join(Bkmkr::Paths.project_tmp_dir, "#{Bkmkr::Project.filename}.xml")

word_to_html_xsl = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "wordtohtml.xsl")

footnotes_xsl = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "footnotes.xsl")

strip_toc_xsl = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "strip-toc.xsl")

parts_xsl = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "parts.xsl")

headings_xsl = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "headings.xsl")

inlines_xsl = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "inlines.xsl")

evaluate_pis = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "evaluate_pis.js")

title_js = File.join(Bkmkr::Paths.core_dir, "htmlmaker", "title.js")

# ---------------------- METHODS

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
	filecontents
end

def fixEndnotes(content)
	# add endnote ref id as static content
	filecontents = content.gsub(/(<span class=")(.ndnote.eference)(" id=")(\d+)(">)(<\/span>)/,"\\1endnotereference\\3endnoteref-\\4\\5\\4\\6")
												.gsub(/(div class="endnotetext" id=")/,"\\1endnotetext-")
	filecontents
end

def fixEntities(content)
	filecontents = content.gsub(/&nbsp/,"&#160")
												.gsub(/(<img.*?)(>)/,"\\1/\\2")
												.gsub(/(<br)(>)/,"\\1/\\2")
	filecontents
end

def stripEndnotes(content)
	# removes endnotes section if no content
	filecontents = content
	endnote_txt = content.match(/(<section data-type=\"appendix\" class=\"endnotes\".*?\">)((.|\n)*?)(<\/section>)/).to_s
	unless endnote_txt.include?("<p ")
		filecontents = content.gsub(/(<section data-type=\"appendix\" class=\"endnotes\".*?\">)((.|\n)*?)(<\/section>)/,"")
	end
	filecontents
end

# ---------------------- PROCESSES

# convert docx to xml
Bkmkr::Tools.runpython(docxtoxml_py, Bkmkr::Paths.project_docx_file)

# convert xml to html
`java -jar "#{saxonpath}" -s:"#{source_xml}" -xsl:"#{word_to_html_xsl}" -o:"#{Bkmkr::Paths.outputtmp_html}"`

filecontents = File.read(Bkmkr::Paths.outputtmp_html)

# run method: fixFootnotes
filecontents = fixFootnotes(filecontents)

# run method: fixEndnotes
filecontents = fixEndnotes(filecontents)

# run method: fixEntities
filecontents = fixEntities(filecontents)

Mcmlln::Tools.overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents)

# strip extraneous footnote section from html
`java -jar "#{saxonpath}" -s:"#{Bkmkr::Paths.outputtmp_html}" -xsl:"#{footnotes_xsl}" -o:"#{Bkmkr::Paths.outputtmp_html}"`

# strip static toc from html
`java -jar "#{saxonpath}" -s:"#{Bkmkr::Paths.outputtmp_html}" -xsl:"#{strip_toc_xsl}" -o:"#{Bkmkr::Paths.outputtmp_html}"`

# convert parts to divs
`java -jar "#{saxonpath}" -s:"#{Bkmkr::Paths.outputtmp_html}" -xsl:"#{parts_xsl}" -o:"#{Bkmkr::Paths.outputtmp_html}"`

# add headings to all sections
`java -jar "#{saxonpath}" -s:"#{Bkmkr::Paths.outputtmp_html}" -xsl:"#{headings_xsl}" -o:"#{Bkmkr::Paths.outputtmp_html}"`

# add correct markup for inlines (em, strong, sup, sub)
`java -jar "#{saxonpath}" -s:"#{Bkmkr::Paths.outputtmp_html}" -xsl:"#{inlines_xsl}" -o:"#{Bkmkr::Paths.outputtmp_html}"`

filecontents = File.read(Bkmkr::Paths.outputtmp_html)

# run method: stripEndnotes
filecontents = stripEndnotes(filecontents)

Mcmlln::Tools.overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents)

# set html title to match JSON
Bkmkr::Tools.runnode(title_js, "#{Bkmkr::Paths.outputtmp_html} #{Metadata.booktitle}")

# evaluate processing instructions
Bkmkr::Tools.runnode(evaluate_pis, Bkmkr::Paths.outputtmp_html)

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