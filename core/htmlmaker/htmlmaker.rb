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

readHtml = lambda { |path|
	filecontents = File.read(path)
	return true, filecontents
}

writeHtml = lambda { |path, filecontents|
	Mcmlln::Tools.overwriteFile(path, filecontents)
	true
}

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
	return filecontents, true
rescue => e
	return content, e
end

def fixEndnotes(content)
	# add endnote ref id as static content
	filecontents = content.gsub(/(<span class=")(.ndnote.eference)(" id=")(\d+)(">)(<\/span>)/,"\\1endnotereference\\3endnoteref-\\4\\5\\4\\6")
												.gsub(/(div class="endnotetext" id=")/,"\\1endnotetext-")
	return filecontents, true
rescue => e
	return content, e
end

def fixEntities(content)
	filecontents = content.gsub(/&nbsp/,"&#160")
												.gsub(/(<img.*?)(>)/,"\\1/\\2")
												.gsub(/(<br)(>)/,"\\1/\\2")
	return filecontents, true
rescue => e
	return content, e
end

def stripEndnotes(content)
	# removes endnotes section if no content
	filecontents = content
	endnote_txt = content.match(/(<section data-type=\"appendix\" class=\"endnotes\".*?\">)((.|\n)*?)(<\/section>)/).to_s
	unless endnote_txt.include?("<p ")
		filecontents = content.gsub(/(<section data-type=\"appendix\" class=\"endnotes\".*?\">)((.|\n)*?)(<\/section>)/,"")
	end
	return filecontents, true
rescue => e
	return content, e
end

# ---------------------- PROCESSES

# convert docx to xml
unless filetype == "html"
	Bkmkr::Tools.runpython(docxtoxml_py, Bkmkr::Paths.project_docx_file)
end

# convert xml to html
unless filetype == "html"
	`java -jar "#{saxonpath}" -s:"#{source_xml}" -xsl:"#{word_to_html_xsl}" -o:"#{Bkmkr::Paths.outputtmp_html}"`
else
	Mcmlln::Tools.copyFile(Bkmkr::Paths.project_tmp_file, Bkmkr::Paths.outputtmp_html)
end

#read in html
log_hash['read_output_html_a'], filecontents = Mcmlln::Tools.methodize(Bkmkr::Paths.outputtmp_html,&readHtml)

# run method: fixFootnotes
filecontents, log_hash['fix_footnotes'] = fixFootnotes(filecontents)

# run method: fixEndnotes
filecontents, log_hash['fix_endnotes'] = fixEndnotes(filecontents)

# run method: fixEntities
filecontents, log_hash['fix_entities'] = fixEntities(filecontents)

#write out edited html
log_hash['overwrite_output_html_a'] = Mcmlln::Tools.methodize(Bkmkr::Paths.outputtmp_html, filecontents, &writeHtml)

# # strip extraneous footnote section from html
Bkmkr::Tools.runnode(footnotes_js, Bkmkr::Paths.outputtmp_html)

# # strip static toc from html
Bkmkr::Tools.runnode(strip_toc_js, Bkmkr::Paths.outputtmp_html)

# # convert parts to divs
Bkmkr::Tools.runnode(parts_js, Bkmkr::Paths.outputtmp_html)

# # add headings to all sections
Bkmkr::Tools.runnode(headings_js, Bkmkr::Paths.outputtmp_html)

# # add correct markup for inlines (em, strong, sup, sub)
Bkmkr::Tools.runnode(inlines_js, Bkmkr::Paths.outputtmp_html)

# # add correct markup for lists
Bkmkr::Tools.runnode(lists_js, Bkmkr::Paths.outputtmp_html)

# # change p children of pre tags to spans
Bkmkr::Tools.runnode(preformatted_js, Bkmkr::Paths.outputtmp_html)

log_hash['read_output_html_b'], filecontents = Mcmlln::Tools.methodize(Bkmkr::Paths.outputtmp_html,&readHtml)

# run method: stripEndnotes
filecontents, log_hash['strip_endnotes'] = stripEndnotes(filecontents)

log_hash['overwrite_output_html_b'] = Mcmlln::Tools.methodize(Bkmkr::Paths.outputtmp_html, filecontents, &writeHtml)

# set html title to match JSON
Bkmkr::Tools.runnode(title_js, "#{Bkmkr::Paths.outputtmp_html} \"#{Metadata.booktitle}\"")

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

# Write json log:
log_hash['completed'] = Time.now
Mcmlln::Tools.write_json(json_log_hash, Bkmkr::Paths.json_log)
