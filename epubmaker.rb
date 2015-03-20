input_file = ARGV[0]
filename_split = input_file.split("\\").pop
filename = filename_split.split(".").shift.gsub(/ /, "")
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
project_dir = working_dir_split[0...-3].pop
# determine current working volume
`cd > currvol.txt`
currpath = File.read("currvol.txt")
currvol = currpath.split("\\").shift

# set working dir based on current volume
tmp_dir = "#{currvol}\\bookmaker_tmp"

epub_dir = "#{tmp_dir}\\#{filename}"

html_file = "#{tmp_dir}\\#{filename}\\outputtmp.html"

# Finding author name(s)
authorname1 = File.read("#{html_file}").scan(/<p class="TitlepageAuthorNameau">.*?</).join(",")
authorname2 = authorname1.gsub(/<p class="TitlepageAuthorNameau">/,"").gsub(/</,"")

#set logo image based on project directory
logo_img = "S:\\resources\\bookmaker_scripts\\bookmaker_epubmaker\\images\\#{project_dir}\\logo.jpg"

# testing to see if ISBN style exists
spanisbn = File.read("#{html_file}").scan(/spanISBNisbn/)

# determining print isbn
if spanisbn.length != 0
	pisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+<\/span>\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
else
	pisbn_basestring = File.read("#{html_file}").match(/ISBN\s*.+\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+\(.*\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
end

# determining ebook isbn
if spanisbn.length != 0
	eisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>\s*\(e-*book\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	eisbn = eisbn_basestring.match(/\d+<\/span>\(ebook\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
else
	eisbn_basestring = File.read("#{html_file}").match(/ISBN\s*.+\s*\(e-*book\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	eisbn = eisbn_basestring.match(/\d+\(ebook\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
end

# just in case no isbn is found
if pisbn.length == 0
	pisbn = "#{filename}"
end

if eisbn.length == 0
	eisbn = "#{filename}"
end

# finding imprint name
imprint = File.read("#{html_file}").scan(/<p class="TitlepageImprintLineimp">.*?</).to_s.gsub(/\["<p class=\\"TitlepageImprintLineimp\\">/,"").gsub(/"\]/,"").gsub(/</,"")

# Adding author meta element to head
# Replacing toc with empty nav, as required by htmlbook xsl
#Adding imprint logo to title page
filecontents = File.read("#{html_file}").gsub(/<\/head>/,"<meta name='author' content='#{authorname2}' /><meta name='publisher' content='#{imprint}' /><meta name='isbn-13' content='#{eisbn}' /></head>").gsub(/(<img.*?)(>)/,"\\1/\\2").gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\"><img src=\"cover.jpg\"/></figure>").gsub(/<nav.*<\/nav>/,"<nav data-type='toc' />").gsub(/&nbsp;/,"&#160;").gsub(/<p class="TitlepageImprintLineimp">/,"<img src=\"logo.jpg\"/><p class=\"TitlepageImprintLineimp\">")

# Saving revised HTML into tmp file
File.open("#{tmp_dir}\\#{filename}\\epub_tmp.html", 'w') do |output| 
	output.write filecontents
end

# Add new section to log file
File.open("S:\\resources\\logs\\#{filename}.txt", 'a+') do |f|
	f.puts "----- EPUBMAKER PROCESSES"
end

# convert to epub and send stderr to log file
`chdir #{tmp_dir}\\#{filename} & java -jar C:\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{filename}\\epub_tmp.html -xsl:S:\\resources\\HTMLBook\\htmlbook-xsl\\epub.xsl -o:#{epub_dir}\\tmp.epub 2>>S:\\resources\\logs\\#{filename}.txt`

# fix cover.html doctype
covercontents = File.read("#{tmp_dir}\\#{filename}\\OEBPS\\cover.html")
replace = covercontents.gsub(/&lt;!DOCTYPE html&gt;/,"<!DOCTYPE html>")
File.open("#{tmp_dir}\\#{filename}\\OEBPS\\cover.html", "w") {|file| file.puts replace}

# fix author info in opf
opfcontents = File.read("#{tmp_dir}\\#{filename}\\OEBPS\\content.opf")
replace = opfcontents.gsub(/<dc:creator/,"<dc:identifier id='isbn'>#{eisbn}</dc:identifier><dc:creator id='creator'")
File.open("#{tmp_dir}\\#{filename}\\OEBPS\\content.opf", "w") {|file| file.puts replace}

# add epub css to epub folder
`copy #{working_dir}\\done\\#{pisbn}\\layout\\epub.css #{tmp_dir}\\#{filename}\\OEBPS\\`

# add cover image file to epub folder
`copy #{working_dir}\\done\\#{pisbn}\\cover\\cover.jpg #{tmp_dir}\\#{filename}\\OEBPS\\`
`convert #{tmp_dir}\\#{filename}\\OEBPS\\cover.jpg -resize "600x800>" #{tmp_dir}\\#{filename}\\OEBPS\\cover.jpg`

# add image files to epub folder
sourceimages = Dir["#{working_dir}\\done\\#{pisbn}\\images\\"]

if sourceimages.any?
	`md #{tmp_dir}\\#{filename}\\OEBPS\\images\\`
	`copy #{working_dir}\\done\\#{pisbn}\\images\\* #{tmp_dir}\\#{filename}\\OEBPS\\images\\`
	images = Dir.entries("#{tmp_dir}\\#{filename}\\OEBPS\\images\\").select { |f| File.file?(f) }
	images.each do |i|
		`convert #{tmp_dir}\\#{filename}\\OEBPS\\images\\#{i} -resize "800x1200>" #{tmp_dir}\\#{filename}\\OEBPS\\images\\#{i}`
	end
end

#copy logo image file to epub folder
`copy #{logo_img} #{tmp_dir}\\#{filename}\\OEBPS\\logo.jpg`

# zip epub
`chdir #{tmp_dir}\\#{filename} & C:\\zip\\zip.exe #{eisbn}_EPUB.epub -DX0 mimetype`
`chdir #{tmp_dir}\\#{filename} & C:\\zip\\zip.exe #{eisbn}_EPUB.epub -rDX9 META-INF OEBPS`

# move epub into archive folder
`copy #{tmp_dir}\\#{filename}\\#{eisbn}_EPUB.epub #{working_dir}\\done\\#{pisbn}\\`
`del #{tmp_dir}\\#{filename}\\#{eisbn}_EPUB.epub`

# delete temp epub html file
`del #{tmp_dir}\\#{filename}\\epub_tmp.html`

# TESTING

# epub file should exist in done dir 
if File.file?("#{working_dir}\\done\\#{pisbn}\\#{eisbn}_EPUB.epub")
	test_epub_status = "pass: the EPUB was created successfully"
else
	test_epub_status = "FAIL: the EPUB was created successfully"
end

# ebook isbn should exist AND be 13-digit string of digits
test_eisbn_chars = eisbn.scan(/\d\d\d\d\d\d\d\d\d\d\d\d\d/)
test_eisbn_length = eisbn.split(%r{\s*})

if test_eisbn_length.length == 13 and test_eisbn_chars.length != 0
	test_eisbn_status = "pass: ebook isbn is composed of 13 consecutive digits"
else
	test_eisbn_status = "FAIL: ebook isbn is composed of 13 consecutive digits"
end

# Add new section to log file
File.open("S:\\resources\\logs\\#{filename}.txt", 'a+') do |f|
	f.puts " "
	f.puts "-----"
	f.puts test_epub_status
	f.puts "----- ebook ISBN: #{eisbn}"
	f.puts test_eisbn_status
end