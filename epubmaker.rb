require_relative '..\\bookmaker\\header.rb'

# --------------------HTML FILE DATA START--------------------
# This block creates a variable to point to the 
# converted HTML file, and pulls the isbn data
# out of the HTML file.

# the working html file
html_file = "#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html"

# testing to see if ISBN style exists
spanisbn = File.read("#{html_file}").scan(/spanISBNisbn/)
multiple_isbns = File.read("#{html_file}").scan(/spanISBNisbn">\s*.+<\/span>\s*\(((hardcover)|(trade\s*paperback)|(e-*book))\)/)

# determining print isbn
if spanisbn.length != 0 && multiple_isbns.length != 0
	pisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+<\/span>\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
elsif spanisbn.length != 0 && multiple_isbns.length == 0
	pisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+<\/span>/).to_s.gsub(/<\/span>/,"").gsub(/\["/,"").gsub(/"\]/,"")
else
	pisbn_basestring = File.read("#{html_file}").match(/ISBN\s*.+\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+\(.*\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
end

# determining ebook isbn
if spanisbn.length != 0 && multiple_isbns.length != 0
	eisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>\s*\(e-*book\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	eisbn = eisbn_basestring.match(/\d+<\/span>\(ebook\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
elsif spanisbn.length != 0 && multiple_isbns.length == 0
	eisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	eisbn = pisbn_basestring.match(/\d+<\/span>/).to_s.gsub(/<\/span>/,"").gsub(/\["/,"").gsub(/"\]/,"")
else
	eisbn_basestring = File.read("#{html_file}").match(/ISBN\s*.+\s*\(e-*book\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	eisbn = eisbn_basestring.match(/\d+\(ebook\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
end

# just in case no isbn is found
if pisbn.length == 0
	pisbn = "#{Bkmkr::Project.filename}"
end

if eisbn.length == 0
	eisbn = "#{Bkmkr::Project.filename}"
end
# --------------------HTML FILE DATA END--------------------

epub_dir = "#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}"

# Finding author name(s)
authorname1 = File.read("#{html_file}").scan(/<p class="TitlepageAuthorNameau">.*?</).join(",")
authorname2 = authorname1.gsub(/<p class="TitlepageAuthorNameau">/,"").gsub(/</,"")

#set logo image based on project directory
logo_img = "#{Bkmkr::Dir.bookmaker_dir}\\bookmaker_epubmaker\\images\\#{Bkmkr::Project.project_dir}\\logo.jpg"

# finding imprint name
imprint = File.read("#{html_file}").scan(/<p class="TitlepageImprintLineimp">.*?</).to_s.gsub(/\["<p class=\\"TitlepageImprintLineimp\\">/,"").gsub(/"\]/,"").gsub(/</,"")

# Adding author meta element to head
# Replacing toc with empty nav, as required by htmlbook xsl
# Adding imprint logo to title page
filecontents = File.read("#{html_file}").gsub(/<\/head>/,"<meta name='author' content='#{authorname2}' /><meta name='publisher' content='#{imprint}' /><meta name='isbn-13' content='#{eisbn}' /></head>").gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\"><img src=\"cover.jpg\"/></figure>").gsub(/<nav.*<\/nav>/,"<nav data-type='toc' />").gsub(/&nbsp;/,"&#160;").gsub(/<p class="TitlepageImprintLineimp">/,"<img src=\"logo.jpg\"/><p class=\"TitlepageImprintLineimp\">").gsub(/src="images\//,"src=\"")
# Update several copyright elements for epub
if filecontents.include?('data-type="copyright-page"')
	copyright_txt = filecontents.match(/(<section data-type=\"copyright-page\" .*?\">)((.|\n)*?)(<\/section>)/)[2]
	# Note: last gsub here presumes Printer's key is the only copyright item that might be a <p>with just a number, eg <p class="xxx">13</p>
	new_copyright = copyright_txt.to_s.gsub(/(ISBN )([0-9\-]{13,20})( \(e-book\))/, "e\\1\\2").gsub(/ Printed in the United States of America./, "").gsub(/ Copyright( |\D|&.*?;)+/, " Copyright &#169; ").gsub(/<p class="\w*?">(\d+|(\d+\s){1,9}\d)<\/p>/, "")
	# Note: this gsub block presumes that these urls do not already have <a href> tags.
	new_copyright = new_copyright.gsub(/([^\s>]+.(com|org|net)[^\s<]*)/) do |m|
		url_prefix = "http:\/\/"
		if m.match(/@/)
			url_prefix = "mailto:"
		elsif m.match(/http/)
			url_prefix = ""
		end
		"<a href=\"#{url_prefix}#{m}\">#{m}<\/a>"
	end
	filecontents = filecontents.gsub(/(^(.|\n)*?<section data-type="copyright-page" id=".*?">)((.|\n)*?)(<\/section>(.|\n)*$)/, "\\1#{new_copyright}\\5")
end

# Saving revised HTML into tmp file
File.open("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epub_tmp.html", 'w') do |output| 
	output.write filecontents
end

# Add new section to log file
File.open("#{Bkmkr::Dir.log_dir}\\#{Bkmkr::Project.filename}.txt", 'a+') do |f|
	f.puts "----- EPUBMAKER PROCESSES"
end

# strip halftitlepage from html
`java -jar #{Bkmkr::Dir.resource_dir}\\saxon\\saxon9pe.jar -s:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epub_tmp.html -xsl:#{Bkmkr::Dir.bookmaker_dir}\\bookmaker_epubmaker\\strip-halftitle.xsl -o:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epub_tmp.html`

# convert to epub and send stderr to log file
`chdir #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename} & java -jar #{Bkmkr::Dir.resource_dir}\\saxon\\saxon9pe.jar -s:#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epub_tmp.html -xsl:#{Bkmkr::Dir.bookmaker_dir}\\HTMLBook\\htmlbook-xsl\\epub.xsl -o:#{epub_dir}\\tmp.epub 2>>#{Bkmkr::Dir.log_dir}\\#{Bkmkr::Project.filename}.txt`

# fix cover.html doctype
covercontents = File.read("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\OEBPS\\cover.html")
replace = covercontents.gsub(/&lt;!DOCTYPE html&gt;/,"<!DOCTYPE html>")
File.open("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\OEBPS\\cover.html", "w") {|file| file.puts replace}

# fix author info in opf, add toc to text flow
opfcontents = File.read("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\OEBPS\\content.opf")
tocid = opfcontents.match(/(id=")(toc-.*?)(")/)[2]
copyright_tag = opfcontents.match(/<itemref idref="copyright-page-.*?"\/>/)
replace = opfcontents.gsub(/<dc:creator/,"<dc:identifier id='isbn'>#{eisbn}</dc:identifier><dc:creator id='creator'").gsub(/(<itemref idref="titlepage-.*?"\/>)/,"\\1<itemref idref=\"#{tocid}\"\/>").gsub(/#{copyright_tag}/,"").gsub(/<\/spine>/,"#{copyright_tag}<\/spine>")
File.open("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\OEBPS\\content.opf", "w") {|file| file.puts replace}

# add epub css to epub folder
`copy #{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\layout\\epub.css #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\OEBPS\\`

# add cover image file to epub folder
`copy #{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\cover\\cover.jpg #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\OEBPS\\`
`convert #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\OEBPS\\cover.jpg -resize "600x800>" #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\OEBPS\\cover.jpg`

# add image files to epub folder
sourceimages = Dir.entries("#{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\images\\")

if sourceimages.any?
	`mkdir #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epubimg\\`
	`copy #{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\images\\* #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epubimg\\`
	`del #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epubimg\\clear_ftp_log.txt`
	images = Dir.entries("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epubimg\\").select { |f| File.file?(f) }
	images.each do |i|
		`convert #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epubimg\\#{i} -resize "600x800>" #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epubimg\\#{i}`
	end
	`copy #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epubimg\\* #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\OEBPS\\`
end

#copy logo image file to epub folder
`copy #{logo_img} #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\OEBPS\\logo.jpg`

if Bkmkr::Project.stage_dir.include? "egalley" or Bkmkr::Project.stage_dir.include? "firstpass"
	csfilename = "#{eisbn}_EPUBfirstpass"
else
	csfilename = "#{eisbn}_EPUB"
end

# zip epub
`chdir #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename} & #{Bkmkr::Dir.resource_dir}\\zip\\zip.exe #{csfilename}.epub -DX0 mimetype`
`chdir #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename} & #{Bkmkr::Dir.resource_dir}\\zip\\zip.exe #{csfilename}.epub -rDX9 META-INF OEBPS`

# move epub into archive folder
`copy #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\#{csfilename}.epub #{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\`
`del #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\#{csfilename}.epub`

# delete temp epub html file
#`del #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\epub_tmp.html`

# TESTING

# epub file should exist in done dir 
if File.file?("#{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\#{csfilename}.epub")
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
File.open("#{Bkmkr::Dir.log_dir}\\#{Bkmkr::Project.filename}.txt", 'a+') do |f|
	f.puts " "
	f.puts "-----"
	f.puts test_epub_status
	f.puts "----- ebook ISBN: #{eisbn}"
	f.puts test_eisbn_status
end