input_file = ARGV[0]
filename_split = input_file.split("\\").pop
filename = filename_split.split(".").shift.gsub(/ /, "")
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
# determine current working volume
`cd > currvol.txt`
currpath = File.read("currvol.txt")
currvol = currpath.split("\\").shift

# set working dir based on current volume
tmp_dir = "#{currvol}\\bookmaker_tmp"

# convert xml to html
`java -jar C:\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{filename}\\#{filename}.xml -xsl:S:\\resources\\bookmaker_scripts\\WordXML-to-HTML\\wordtohtml.xsl -o:#{tmp_dir}\\#{filename}\\outputtmp.html`

# replace nbsp entities with 160
nbspcontents = File.read("#{tmp_dir}\\#{filename}\\outputtmp.html")
replace = nbspcontents.gsub(/&nbsp/,"&#160")
File.open("#{tmp_dir}\\#{filename}\\outputtmp.html", "w") {|file| file.puts replace}

# strip static toc from html
`java -jar C:\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{filename}\\outputtmp.html -xsl:S:\\resources\\bookmaker_scripts\\bookmaker_htmlmaker\\strip-toc.xsl -o:#{tmp_dir}\\#{filename}\\outputtmp.html`

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
File.open("S:\\resources\\logs\\#{filename}.txt", 'a+') do |f|
	f.puts "----- HTMLMAKER PROCESSES"
	f.puts test_html_status
	f.puts test_content_status
end