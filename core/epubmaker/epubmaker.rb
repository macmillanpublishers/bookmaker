require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

configfile = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")
file = File.read(configfile)
data_hash = JSON.parse(file)

cover = data_hash['frontcover']

# Local path var(s)
epub_dir = Bkmkr::Paths.project_tmp_dir
saxonpath = File.join(Bkmkr::Paths.resource_dir, "saxon", "#{Bkmkr::Tools.xslprocessor}.jar")
zipepub_py = File.join(Bkmkr::Paths.core_dir, "epubmaker", "zipepub.py")
epub_tmp_html = File.join(Bkmkr::Paths.project_tmp_dir, "epub_tmp.html")
strip_tocnodes_js = File.join(Bkmkr::Paths.core_dir, "epubmaker", "strip-tocnodes.js")
strip_halftitle_xsl = File.join(Bkmkr::Paths.core_dir, "epubmaker", "strip-halftitle.xsl")
epub_xsl = File.join(Bkmkr::Paths.scripts_dir, "HTMLBook", "htmlbook-xsl", "epub.xsl")
tmp_epub = File.join(Bkmkr::Paths.project_tmp_dir, "tmp.epub")
convert_log_txt = File.join(Bkmkr::Paths.log_dir, "#{Bkmkr::Project.filename}.txt")
OEBPS_dir = File.join(Bkmkr::Paths.project_tmp_dir, "OEBPS")
METAINF_dir = File.join(Bkmkr::Paths.project_tmp_dir, "META-INF")
final_cover = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "cover", cover)
cover_jpg = File.join(OEBPS_dir, "cover.jpg")
epub_img_dir = File.join(Bkmkr::Paths.project_tmp_dir, "epubimg")

# Delete any old conversion stuff
if File.exists?(OEBPS_dir)
	FileUtils.rm_r(OEBPS_dir)
end

if File.exists?(METAINF_dir)
	FileUtils.rm_r(METAINF_dir)
end

# Adding author meta element to head
# Replacing toc with empty nav, as required by htmlbook xsl
# Allowing for users to preprocess epub html if desired
if File.file?(epub_tmp_html)
	filecontents = File.read(epub_tmp_html).gsub(/<\/head>/,"<meta name='author' content=\"#{Metadata.bookauthor}\" /><meta name='publisher' content=\"#{Metadata.imprint}\" /><meta name='isbn-13' content='#{Metadata.eisbn}' /></head>").gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\" id=\"bookcover01\"><img src=\"cover.jpg\"/></figure>").gsub(/&nbsp;/,"&#160;").gsub(/src="images\//,"src=\"")
else
	filecontents = File.read(Bkmkr::Paths.outputtmp_html).gsub(/<\/head>/,"<meta name='author' content=\"#{Metadata.bookauthor}\" /><meta name='publisher' content=\"#{Metadata.imprint}\" /><meta name='isbn-13' content='#{Metadata.eisbn}' /></head>").gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\" id=\"bookcover01\"><img src=\"cover.jpg\"/></figure>").gsub(/&nbsp;/,"&#160;").gsub(/src="images\//,"src=\"")
end

# Saving revised HTML into tmp file
File.open(epub_tmp_html, 'w') do |output| 
	output.write filecontents
end

if File.file?(final_cover)
	filecontents = File.read(epub_tmp_html).gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\" id=\"bookcover01\"><img src=\"cover.jpg\"/></figure>")
	# Saving revised HTML into tmp file
	File.open(epub_tmp_html, 'w') do |output| 
		output.write filecontents
	end
end

Bkmkr::Tools.runnode(strip_tocnodes_js, epub_tmp_html)

# Add new section to log file
File.open(convert_log_txt, 'a+') do |f|
	f.puts "----- EPUBMAKER PROCESSES"
end

# convert to epub and send stderr to log file
# do these commands need to stack, or can I do this prior? (there was a cd and saxon invoke on top of each other)
FileUtils.cd(Bkmkr::Paths.project_tmp_dir)
Bkmkr::Tools.processxsl(epub_tmp_html, epub_xsl, tmp_epub, convert_log_txt)

# fix cover.html doctype and ncx entry
# at some point I should move this to addons
covercontents = File.read("#{OEBPS_dir}/cover.html")
if File.file?(final_cover)
	replace = covercontents.gsub(/&lt;!DOCTYPE html&gt;/,"<!DOCTYPE html>")
	File.open("#{OEBPS_dir}/cover.html", "w") {|file| file.puts replace}
	ncx = File.read("#{OEBPS_dir}/toc.ncx")
	ncxreplace = ncx.gsub(/(<text\/>)(<\/navLabel><content src=")(#bookcover01)("\/>)/,"<text>Cover</text>\\2cover.html\\4")
end

# fix author info in opf, add toc to text flow
opfcontents = File.read("#{OEBPS_dir}/content.opf")
replace = opfcontents.gsub(/<dc:creator/,"<dc:identifier id='isbn'>#{Metadata.eisbn}</dc:identifier><dc:creator id='creator'")
File.open("#{OEBPS_dir}/content.opf", "w") {|file| file.puts replace}

# add epub css to epub folder
FileUtils.cp("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/layout/epub.css", OEBPS_dir)

# add cover image file to epub folder
if File.file?(final_cover)
	FileUtils.cp(final_cover, cover_jpg)
	unless Bkmkr::Tools.processimages == "false"
		`convert "#{cover_jpg}" -resize "600x800>" "#{cover_jpg}"`
	end
end

# add image files to epub folder
sourceimages = Dir.entries("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/images")

# using imgmagick to optimize image sizes for epub
if sourceimages.any?
	unless File.exist?(epub_img_dir)
		Dir.mkdir(epub_img_dir)
	end
	FileUtils.cp Dir["#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/images/*"].select {|f| test ?f, f}, epub_img_dir
	unless Bkmkr::Tools.processimages == "false"
		images = Dir.entries(epub_img_dir).select {|f| !File.directory? f}
		images.each do |i|
			path_to_i = File.join(epub_img_dir, i)
			`convert "#{path_to_i}" -bordercolor white -border 1x1  -trim -resize "600x800>" "#{path_to_i}"`
		end
	end
	FileUtils.cp Dir["#{epub_img_dir}/*"].select {|f| test ?f, f}, OEBPS_dir
end

csfilename = "#{Metadata.eisbn}_EPUB"

# zip epub
Bkmkr::Tools.runpython(zipepub_py, "#{csfilename}.epub #{Bkmkr::Paths.project_tmp_dir}")

# move epub into archive folder
FileUtils.cp("#{Bkmkr::Paths.project_tmp_dir}/#{csfilename}.epub", "#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}")
FileUtils.rm("#{Bkmkr::Paths.project_tmp_dir}/#{csfilename}.epub")

# LOGGING

# epub file should exist in done dir 
if File.file?("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/#{csfilename}.epub")
	test_epub_status = "pass: the EPUB was created successfully"
else
	test_epub_status = "FAIL: the EPUB was created successfully"
end

# Add new section to log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts " "
	f.puts "-----"
	f.puts test_epub_status
	f.puts "----- ebook ISBN: #{Metadata.eisbn}"
	f.puts "finished epubmaker"
end