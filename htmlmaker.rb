# --------------------STANDARD HEADER START--------------------
# The bookmkaer scripts require a certain folder structure 
# in order to source in the correct CSS files, logos, 
# and other imprint-specific items. You can read about the 
# required folder structure here:
input_file = ARGV[0]
filename_split = input_file.split("\\").pop
filename = filename_split.split(".").shift.gsub(/ /, "")
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
project_dir = working_dir_split[0...-2].pop.split("_").shift
stage_dir = working_dir_split[0...-2].pop.split("_").pop
# In Macmillan's environment, these scripts could be 
# running either on the C: volume or on the S: volume 
# of the configured server. This block determines which 
# of those is the current working volume.
`cd > currvol.txt`
currpath = File.read("currvol.txt")
currvol = currpath.split("\\").shift

# --------------------USER CONFIGURED PATHS START--------------------
# These are static paths to folders on your system.
# These paths will need to be updated to reflect your current 
# directory structure.

# set temp working dir based on current volume
tmp_dir = "#{currvol}\\bookmaker_tmp"
# set directory for logging output
log_dir = "S:\\resources\\logs"
# set directory where bookmkaer scripts live
bookmaker_dir = "S:\\resources\\bookmaker_scripts"
# set directory where other resources are installed
# (for example, saxon, zip)
resource_dir = "C:"
# --------------------USER CONFIGURED PATHS END--------------------
# --------------------STANDARD HEADER END--------------------

# convert xml to html
`java -jar #{resource_dir}\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{filename}\\#{filename}.xml -xsl:#{bookmaker_dir}\\WordXML-to-HTML\\wordtohtml.xsl -o:#{tmp_dir}\\#{filename}\\outputtmp.html`

# place footnote text inline per htmlbook
filecontents = File.read("#{tmp_dir}\\#{filename}\\outputtmp.html")
replace = filecontents.gsub(/(<span class=")(spansuperscriptcharacterssup)(" id="\d+")/,"\\1FootnoteReference\\3")
File.open("#{tmp_dir}\\#{filename}\\outputtmp.html", "w") {|file| file.puts replace}

footnotes = File.read("#{tmp_dir}\\#{filename}\\outputtmp.html").scan(/(<p class="footnotetext" id=")(\d+)(">)(\s)(.*?)(<\/p>)/)

footnotes.each do |f|
	noteref = f[1]
	notetext = f[4]
	filecontents = File.read("#{tmp_dir}\\#{filename}\\outputtmp.html")
	replace = filecontents.gsub(/<span class="FootnoteReference" id="#{noteref}"><\/span>/,"<span data-type=\"footnote\" id=\"footnote-#{noteref}\">#{notetext}</span>")
	File.open("#{tmp_dir}\\#{filename}\\outputtmp.html", "w") {|file| file.puts replace}
end

# add endnote ref id as static content
filecontents = File.read("#{tmp_dir}\\#{filename}\\outputtmp.html")
replace = filecontents.gsub(/(<span class="EndnoteReference" id=")(\d+)(">)(<\/span>)/,"\\1endnoteref-\\2\\3\\2\\4").gsub(/(p class="endnotetext" id=")/,"\\1endnotetext-")
File.open("#{tmp_dir}\\#{filename}\\outputtmp.html", "w") {|file| file.puts replace}

# replace nbsp entities with 160 and fix img closing tags
nbspcontents = File.read("#{tmp_dir}\\#{filename}\\outputtmp.html")
replace = nbspcontents.gsub(/&nbsp/,"&#160").gsub(/(<img.*?)(>)/,"\\1/\\2")
File.open("#{tmp_dir}\\#{filename}\\outputtmp.html", "w") {|file| file.puts replace}

# strip extraneous footnote section from html
`java -jar #{resource_dir}\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{filename}\\outputtmp.html -xsl:#{bookmaker_dir}\\bookmaker_htmlmaker\\footnotes.xsl -o:#{tmp_dir}\\#{filename}\\outputtmp.html`

# strip static toc from html
`java -jar #{resource_dir}\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{filename}\\outputtmp.html -xsl:#{bookmaker_dir}\\bookmaker_htmlmaker\\strip-toc.xsl -o:#{tmp_dir}\\#{filename}\\outputtmp.html`

# convert parts to divs
`java -jar #{resource_dir}\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{filename}\\outputtmp.html -xsl:#{bookmaker_dir}\\bookmaker_htmlmaker\\parts.xsl -o:#{tmp_dir}\\#{filename}\\outputtmp.html`

# add headings to all sections
`java -jar #{resource_dir}\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{filename}\\outputtmp.html -xsl:#{bookmaker_dir}\\bookmaker_htmlmaker\\headings.xsl -o:#{tmp_dir}\\#{filename}\\outputtmp.html`

# add correct markup for inlines (em, strong, sup, sub)
`java -jar #{resource_dir}\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{filename}\\outputtmp.html -xsl:#{bookmaker_dir}\\bookmaker_htmlmaker\\inlines.xsl -o:#{tmp_dir}\\#{filename}\\outputtmp.html`

# TESTING

# html file should exist
if File.file?("#{tmp_dir}\\#{filename}\\outputtmp.html")
	test_html_status = "pass: html file was created successfully"
else
	test_html_status = "FAIL: html file was created successfully"
end

# html file should contain html tag, body tag, and title should be non-empty
test_html_html = File.read("#{tmp_dir}\\#{filename}\\outputtmp.html").scan(/<html/)
test_html_body = File.read("#{tmp_dir}\\#{filename}\\outputtmp.html").scan(/<body/)
test_html_content = File.read("#{tmp_dir}\\#{filename}\\outputtmp.html").scan(/<title>.+<\/title>/)

if test_html_html.length != 0 and test_html_body.length!= 0 and test_html_content != 0
	test_content_status = "pass: html file has content and a title"
else 
	test_content_status = "FAIL: html file has content and a title"
end

# Printing the test results to the log file
File.open("#{log_dir}\\#{filename}.txt", 'a+') do |f|
	f.puts "----- HTMLMAKER PROCESSES"
	f.puts test_html_status
	f.puts test_content_status
end