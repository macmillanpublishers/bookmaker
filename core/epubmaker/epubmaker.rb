require 'FileUtils'

require_relative '../header.rb'
require_relative '../metadata.rb'

configfile = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")
file = File.read(configfile)
data_hash = JSON.parse(file)

cover = data_hash['frontcover']

# Local path var(s)
epub_dir = Bkmkr::Paths.project_tmp_dir
saxonpath = File.join(Bkmkr::Paths.resource_dir, "saxon", "#{Bkmkr::Tools.xslprocessor}.jar")
epub_tmp_html = File.join(Bkmkr::Paths.project_tmp_dir, "epub_tmp.html")
strip_halftitle_xsl = File.join(Bkmkr::Paths.core_dir, "epubmaker", "strip-halftitle.xsl")
epub_xsl = File.join(Bkmkr::Paths.scripts_dir, "HTMLBook", "htmlbook-xsl", "epub.xsl")
tmp_epub = File.join(Bkmkr::Paths.project_tmp_dir, "tmp.epub")
convert_log_txt = File.join(Bkmkr::Paths.log_dir, "#{Bkmkr::Project.filename}.txt")
OEBPS_dir = File.join(Bkmkr::Paths.project_tmp_dir, "OEBPS")
final_cover = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "cover", cover)
cover_jpg = File.join(OEBPS_dir, "cover.jpg")
epub_img_dir = File.join(Bkmkr::Paths.project_tmp_dir, "epubimg")

# Adding author meta element to head
# Replacing toc with empty nav, as required by htmlbook xsl
# Allowing for users to preprocess epub html if desired
if File.file?(epub_tmp_html)
	filecontents = File.read(epub_tmp_html).gsub(/<\?xml version="1.0" encoding="UTF-8"\?>/,"<?xml version=\"1.0\" encoding=\"UTF-8\" lang=\"en\"?>").gsub(/<\/head>/,"<meta name='author' content='#{Metadata.bookauthor}' /><meta name='publisher' content='#{Metadata.imprint}' /><meta name='isbn-13' content='#{Metadata.eisbn}' /></head>").gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\"><img src=\"cover.jpg\"/></figure>").gsub(/<nav.*<\/nav>/,"<nav data-type='toc' />").gsub(/&nbsp;/,"&#160;").gsub(/src="images\//,"src=\"")
else
	filecontents = File.read(Bkmkr::Paths.outputtmp_html).gsub(/<\?xml version="1.0" encoding="UTF-8"\?>/,"<?xml version=\"1.0\" encoding=\"UTF-8\" lang=\"en\"?>").gsub(/<\/head>/,"<meta name='author' content='#{Metadata.bookauthor}' /><meta name='publisher' content='#{Metadata.imprint}' /><meta name='isbn-13' content='#{Metadata.eisbn}' /></head>").gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\"><img src=\"cover.jpg\"/></figure>").gsub(/<nav.*<\/nav>/,"<nav data-type='toc' />").gsub(/&nbsp;/,"&#160;").gsub(/src="images\//,"src=\"")
end

# Saving revised HTML into tmp file
File.open(epub_tmp_html, 'w') do |output| 
	output.write filecontents
end

# Add new section to log file
File.open(convert_log_txt, 'a+') do |f|
	f.puts "----- EPUBMAKER PROCESSES"
end

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
replace = opfcontents.gsub(/<dc:creator/,"<dc:identifier id='isbn'>#{Metadata.eisbn}</dc:identifier><dc:creator id='creator'").gsub(/#{copyright_tag}/,"").gsub(/<\/spine>/,"#{copyright_tag}<\/spine>")
File.open("#{OEBPS_dir}/content.opf", "w") {|file| file.puts replace}

# add epub css to epub folder
FileUtils.cp("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/layout/epub.css", OEBPS_dir)

# add cover image file to epub folder
FileUtils.cp(final_cover, cover_jpg)
`convert "#{cover_jpg}" -resize "600x800>" "#{cover_jpg}"`

# add image files to epub folder
sourceimages = Dir.entries("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/images")

# using imgmagick to optimize image sizes for epub
if sourceimages.any?
	unless File.exist?(epub_img_dir)
		Dir.mkdir(epub_img_dir)
	end
	FileUtils.cp Dir["#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/images/*"].select {|f| test ?f, f}, epub_img_dir
	images = Dir.entries("#{Bkmkr::Paths.project_tmp_dir}/epubimg").select { |f| File.file?(f) }
	images.each do |i|
		path_to_i = File.join(Bkmkr::Paths.project_tmp_dir, "epubimg", "#{i}")
		`convert "#{path_to_i}" -resize "600x800>" "#{path_to_i}"`
	end
	FileUtils.cp Dir["#{epub_img_dir}/*"].select {|f| test ?f, f}, OEBPS_dir
end

csfilename = "#{Metadata.eisbn}_EPUB"

# zip epub
# do these commands need to stack, or can I do this FileUtils prior instead of the cd's??
FileUtils.cd(Bkmkr::Paths.project_tmp_dir)
`cd "#{Bkmkr::Paths.project_tmp_dir}" & #{Bkmkr::Paths.resource_dir}\\zip\\zip.exe #{csfilename}.epub -DX0 mimetype`
`cd "#{Bkmkr::Paths.project_tmp_dir}" & #{Bkmkr::Paths.resource_dir}\\zip\\zip.exe #{csfilename}.epub -rDX9 META-INF OEBPS`

# move epub into archive folder
FileUtils.cp("#{Bkmkr::Paths.project_tmp_dir}/#{csfilename}.epub", "#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}")
FileUtils.rm("#{Bkmkr::Paths.project_tmp_dir}/#{csfilename}.epub")

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