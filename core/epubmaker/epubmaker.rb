require 'FileUtils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# Local path var(s)
epub_dir = Bkmkr::Paths.project_tmp_dir
saxonpath = File.join(Bkmkr::Paths.resource_dir, "saxon", "saxon9pe.jar")
epub_tmp_html = File.join(Bkmkr::Paths.project_tmp_dir, "epub_tmp.html")
strip_halftitle_xsl = File.join(Bkmkr::Paths.core_dir, "epubmaker", "strip-halftitle.xsl")
epub_xsl = File.join(Bkmkr::Paths.scripts_dir, "HTMLBook", "htmlbook-xsl", "epub.xsl")
tmp_epub = File.join(Bkmkr::Paths.project_tmp_dir, "tmp.epub")
convert_log_txt = File.join(Bkmkr::Paths.log_dir, "#{Bkmkr::Project.filename}.txt")
OEBPS_dir = File.join(Bkmkr::Paths.project_tmp_dir, "OEBPS")
cover_jpg = File.join(OEBPS_dir, "cover.jpg")

# Finding author name(s)
authorname1 = File.read(Bkmkr::Paths.outputtmp_html).scan(/<p class="TitlepageAuthorNameau">.*?</).join(",")
authorname2 = authorname1.gsub(/<p class="TitlepageAuthorNameau">/,"").gsub(/</,"")

#set logo image based on project directory
logo_img = "#{Bkmkr::Paths.core_dir}/epubmaker/images/#{Bkmkr::Project.project_dir}/logo.jpg"

# finding imprint name
imprint = File.read(Bkmkr::Paths.outputtmp_html).scan(/<p class="TitlepageImprintLineimp">.*?</).to_s.gsub(/\["<p class=\\"TitlepageImprintLineimp\\">/,"").gsub(/"\]/,"").gsub(/</,"")

# Adding author meta element to head
# Replacing toc with empty nav, as required by htmlbook xsl
# Adding imprint logo to title page
filecontents = File.read(Bkmkr::Paths.outputtmp_html).gsub(/<\/head>/,"<meta name='author' content='#{authorname2}' /><meta name='publisher' content='#{imprint}' /><meta name='isbn-13' content='#{Metadata.eisbn}' /></head>").gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\"><img src=\"cover.jpg\"/></figure>").gsub(/<nav.*<\/nav>/,"<nav data-type='toc' />").gsub(/&nbsp;/,"&#160;").gsub(/<p class="TitlepageImprintLineimp">/,"<img src=\"logo.jpg\"/><p class=\"TitlepageImprintLineimp\">").gsub(/src="images\//,"src=\"")
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
File.open(epub_tmp_html, 'w') do |output| 
	output.write filecontents
end

# Add new section to log file
File.open(convert_log_txt, 'a+') do |f|
	f.puts "----- EPUBMAKER PROCESSES"
end

# strip halftitlepage from html
`java -jar "#{saxonpath}" -s:"#{epub_tmp_html}" -xsl:"#{strip_halftitle_xsl}" -o:"#{epub_tmp_html}"`

# convert to epub and send stderr to log file
# do these commands need to stack, or can I do this prior? (there was a cd and saxon invoke on top of each other)
FileUtils.cd(Bkmkr::Paths.project_tmp_dir)
`java -jar "#{saxonpath}" -s:"#{epub_tmp_html}" -xsl:"#{epub_xsl}" -o:"#{tmp_epub}" 2>>"#{convert_log_txt}"`

# fix cover.html doctype
covercontents = File.read("#{OEBPS_dir}/cover.html")
replace = covercontents.gsub(/&lt;!DOCTYPE html&gt;/,"<!DOCTYPE html>")
File.open("#{OEBPS_dir}/cover.html", "w") {|file| file.puts replace}

# fix author info in opf, add toc to text flow
opfcontents = File.read("#{OEBPS_dir}/content.opf")
tocid = opfcontents.match(/(id=")(toc-.*?)(")/)[2]
copyright_tag = opfcontents.match(/<itemref idref="copyright-page-.*?"\/>/)
replace = opfcontents.gsub(/<dc:creator/,"<dc:identifier id='isbn'>#{Metadata.eisbn}</dc:identifier><dc:creator id='creator'").gsub(/(<itemref idref="titlepage-.*?"\/>)/,"\\1<itemref idref=\"#{tocid}\"\/>").gsub(/#{copyright_tag}/,"").gsub(/<\/spine>/,"#{copyright_tag}<\/spine>")
File.open("#{OEBPS_dir}/content.opf", "w") {|file| file.puts replace}

# add epub css to epub folder
FileUtils.cp("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/layout/epub.css", OEBPS_dir)

# add cover image file to epub folder
FileUtils.cp("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/cover/cover.jpg", OEBPS_dir)
`convert "#{cover_jpg}" -resize "600x800>" "#{cover_jpg}"`

# add image files to epub folder
sourceimages = Dir.entries("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/images")

if sourceimages.any?
	unless File.exist?("#{Bkmkr::Paths.project_tmp_dir}/epubimg")
		Dir.mkdir("#{Bkmkr::Paths.project_tmp_dir}/epubimg")
	end
	#using this model for Fileutils.cp to select all files in a dir (* won't work directly):  FileUtils.cp Dir["#{dir1}/*"].select {|f| test ?f, f}, "#{dir2}"
	FileUtils.cp Dir["#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/images/*"].select {|f| test ?f, f}, "#{Bkmkr::Paths.project_tmp_dir}/epubimg"
	#not sure why below line was here, this file shouldn't exist in this dir anyways? commenting
	#FileUtils.rm("#{Bkmkr::Paths.project_tmp_dir}/epubimg/clear_ftp_log.txt")
	images = Dir.entries("#{Bkmkr::Paths.project_tmp_dir}/epubimg").select { |f| File.file?(f) }
	images.each do |i|
		path_to_i = File.join(Bkmkr::Paths.project_tmp_dir, "epubimg", "#{i}")
		`convert "#{path_to_i}" -resize "600x800>" "#{path_to_i}"`
	end
	FileUtils.cp Dir["#{Bkmkr::Paths.project_tmp_dir}/epubimg/*"].select {|f| test ?f, f}, OEBPS_dir
end

#copy logo image file to epub folder
FileUtils.cp(logo_img, "#{OEBPS_dir}/logo.jpg")

csfilename = "#{Metadata.eisbn}_EPUB"


# zip epub
# do these commands need to stack, or can I do this FileUtils prior instead of the cd's??
FileUtils.cd(Bkmkr::Paths.project_tmp_dir)
`cd "#{Bkmkr::Paths.project_tmp_dir}" & #{Bkmkr::Paths.resource_dir}\\zip\\zip.exe #{csfilename}.epub -DX0 mimetype`
`cd "#{Bkmkr::Paths.project_tmp_dir}" & #{Bkmkr::Paths.resource_dir}\\zip\\zip.exe #{csfilename}.epub -rDX9 META-INF OEBPS`

# move epub into archive folder
FileUtils.cp("#{Bkmkr::Paths.project_tmp_dir}/#{csfilename}.epub", "#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}")
FileUtils.rm("#{Bkmkr::Paths.project_tmp_dir}/#{csfilename}.epub")

# delete temp epub html file
#`del #{Bkmkr::Paths.tmp_dir}\\#{Bkmkr::Project.filename}\\epub_tmp.html`

# TESTING

# epub file should exist in done dir 
if File.file?("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/#{csfilename}.epub")
	test_epub_status = "pass: the EPUB was created successfully"
else
	test_epub_status = "FAIL: the EPUB was created successfully"
end

# ebook isbn should exist AND be 13-digit string of digits
test_eisbn_chars = Metadata.eisbn.scan(/\d\d\d\d\d\d\d\d\d\d\d\d\d/)
test_eisbn_length = Metadata.eisbn.split(%r{\s*})

if test_eisbn_length.length == 13 and test_eisbn_chars.length != 0
	test_eisbn_status = "pass: ebook isbn is composed of 13 consecutive digits"
else
	test_eisbn_status = "FAIL: ebook isbn is composed of 13 consecutive digits"
end

# Add new section to log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts " "
	f.puts "-----"
	f.puts test_epub_status
	f.puts "----- ebook ISBN: #{Metadata.eisbn}"
	f.puts test_eisbn_status
end