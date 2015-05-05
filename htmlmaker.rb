require_relative '..\\bookmaker\\header.rb'

# convert xml to html
`java -jar #{Bkmkr::Dir.resource_dir}\\saxon\\saxon9pe.jar -s:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\#{Bkmkr::Project.filename}.xml -xsl:#{Bkmkr::Dir.bookmaker_dir}\\WordXML-to-HTML\\wordtohtml.xsl -o:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html`

# place footnote text inline per htmlbook
filecontents = File.read("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html")
replace = filecontents.gsub(/(<span class=")(spansuperscriptcharacterssup)(" id="\d+")/,"\\1FootnoteReference\\3")
File.open("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html", "w") {|file| file.puts replace}

footnotes = File.read("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html").scan(/(<p class="footnotetext" id=")(\d+)(">)(\s)(.*?)(<\/p>)/)

footnotes.each do |f|
	noteref = f[1]
	notetext = f[4]
	filecontents = File.read("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html")
	replace = filecontents.gsub(/<span class="FootnoteReference" id="#{noteref}"><\/span>/,"<span data-type=\"footnote\" id=\"footnote-#{noteref}\">#{notetext}</span>")
	File.open("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html", "w") {|file| file.puts replace}
end

# add endnote ref id as static content
filecontents = File.read("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html")
replace = filecontents.gsub(/(<span class="EndnoteReference" id=")(\d+)(">)(<\/span>)/,"\\1endnoteref-\\2\\3\\2\\4").gsub(/(p class="endnotetext" id=")/,"\\1endnotetext-")
File.open("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html", "w") {|file| file.puts replace}

# replace nbsp entities with 160 and fix img closing tags
nbspcontents = File.read("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html")
replace = nbspcontents.gsub(/&nbsp/,"&#160").gsub(/(<img.*?)(>)/,"\\1/\\2")
File.open("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html", "w") {|file| file.puts replace}

# strip extraneous footnote section from html
`java -jar #{Bkmkr::Dir.resource_dir}\\saxon\\saxon9pe.jar -s:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html -xsl:#{Bkmkr::Dir.bookmaker_dir}\\bookmaker_htmlmaker\\footnotes.xsl -o:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html`

# strip static toc from html
`java -jar #{Bkmkr::Dir.resource_dir}\\saxon\\saxon9pe.jar -s:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html -xsl:#{Bkmkr::Dir.bookmaker_dir}\\bookmaker_htmlmaker\\strip-toc.xsl -o:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html`

# convert parts to divs
`java -jar #{Bkmkr::Dir.resource_dir}\\saxon\\saxon9pe.jar -s:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html -xsl:#{Bkmkr::Dir.bookmaker_dir}\\bookmaker_htmlmaker\\parts.xsl -o:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html`

# add headings to all sections
`java -jar #{Bkmkr::Dir.resource_dir}\\saxon\\saxon9pe.jar -s:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html -xsl:#{Bkmkr::Dir.bookmaker_dir}\\bookmaker_htmlmaker\\headings.xsl -o:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html`

# add correct markup for inlines (em, strong, sup, sub)
`java -jar #{Bkmkr::Dir.resource_dir}\\saxon\\saxon9pe.jar -s:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html -xsl:#{Bkmkr::Dir.bookmaker_dir}\\bookmaker_htmlmaker\\inlines.xsl -o:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html`

# removes endnotes section if no content
filecontents = File.read("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html")
endnote_txt = filecontents.match(/(<section data-type=\"appendix\" class=\"endnotes\".*?\">)((.|\n)*?)(<\/section>)/)
unless endnote_txt.include?("<p")
	replace = filecontents.gsub(/(<section data-type=\"appendix\" class=\"endnotes\".*?\">)((.|\n)*?)(<\/section>)/,"")
	File.open("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html", "w") {|file| file.puts replace}
end

# TESTING

# html file should exist
if File.file?("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html")
	test_html_status = "pass: html file was created successfully"
else
	test_html_status = "FAIL: html file was created successfully"
end

# html file should contain html tag, body tag, and title should be non-empty
test_html_html = File.read("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html").scan(/<html/)
test_html_body = File.read("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html").scan(/<body/)
test_html_content = File.read("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html").scan(/<title>.+<\/title>/)

if test_html_html.length != 0 and test_html_body.length!= 0 and test_html_content != 0
	test_content_status = "pass: html file has content and a title"
else 
	test_content_status = "FAIL: html file has content and a title"
end

# Printing the test results to the log file
File.open("#{Bkmkr::Dir.log_dir}\\#{Bkmkr::Project.filename}.txt", 'a+') do |f|
	f.puts "----- HTMLMAKER PROCESSES"
	f.puts test_html_status
	f.puts test_content_status
end