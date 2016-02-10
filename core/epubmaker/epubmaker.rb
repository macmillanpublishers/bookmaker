require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
data_hash = Mcmlln::Tools.readjson(Metadata.configfile)

cover = data_hash['frontcover']

# the directory where the epub will be created initially
epub_dir = Bkmkr::Paths.project_tmp_dir

# the path for the epub zip tool
zipepub_py = File.join(Bkmkr::Paths.core_dir, "epubmaker", "zipepub.py")

# the path for the adjusted epub html file
epub_tmp_html = File.join(Bkmkr::Paths.project_tmp_dir, "epub_tmp.html")

# the path for strip-tocnodes.js
strip_tocnodes_js = File.join(Bkmkr::Paths.core_dir, "epubmaker", "strip-tocnodes.js")

# the path for strip-halftitle.js
strip_halftitle_xsl = File.join(Bkmkr::Paths.core_dir, "epubmaker", "strip-halftitle.xsl")

# the path for the primary epub conversion xsl from HTMLBook
epub_xsl = File.join(Bkmkr::Paths.scripts_dir, "HTMLBook", "htmlbook-xsl", "epub.xsl")

# the path for the temporary epub file
tmp_epub = File.join(Bkmkr::Paths.project_tmp_dir, "tmp.epub")

# the path for the conversion log file
convert_log_txt = File.join(Bkmkr::Paths.log_dir, "#{Bkmkr::Project.filename}.txt")

# the path for the temp OEBPS dir
OEBPS_dir = File.join(Bkmkr::Paths.project_tmp_dir, "OEBPS")

# the path for the temp META-INF dir
METAINF_dir = File.join(Bkmkr::Paths.project_tmp_dir, "META-INF")

# cover html file within the epub
cover_html = File.join(OEBPS_dir, "cover.html")

# ncx file within the epub
toc_ncx = File.join(OEBPS_dir, "toc.ncx")

# opf file within the epub
content_opf = File.join(OEBPS_dir, "content.opf")

# the path to the cover file
unless data_hash['frontcover'].nil? or data_hash['frontcover'].empty? or !data_hash['frontcover']
	final_cover = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "cover", cover)
else
	final_cover = ""
end

# the path for the converted epub cover file
cover_jpg = File.join(OEBPS_dir, "cover.jpg")

# the path to the holding dir for epub image conversion
epub_img_dir = File.join(Bkmkr::Paths.project_tmp_dir, "epubimg")

# final epub filename
csfilename = "#{Metadata.eisbn}_EPUB"

# epub css file
epub_css = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "layout", "epub.css")

# final image directory
img_dir = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "images")

# final converted epub
final_epub = File.join(Bkmkr::Paths.project_tmp_dir, "#{csfilename}.epub") 

# final archive dir
final_dir = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn)

# second epub conversion
tmp_epub2 = File.join(Bkmkr::Paths.project_tmp_dir, "#{csfilename}.epub")

# ---------------------- METHODS
# Delete any old conversion stuff
def deleteOld(dir)
	if File.exists?(dir)
		Mcmlln::Tools.deleteDir(dir)
	end
end

# Adding author meta element to head
# Replacing toc with empty nav, as required by htmlbook xsl
def firstHTMLEdit(file)
	filecontents = File.read(file)

	hascreator = filecontents.match(/meta name="author"/)
	haspublisher = filecontents.match(/meta name="publisher"/)

	if hascreator.nil?
		filecontents = filecontents.gsub(/<\/head>/,"<meta name='author' content=\"#{Metadata.bookauthor}\" /></head>")
	end

	if haspublisher.nil?
		filecontents = filecontents.gsub(/<\/head>/,"<meta name='publisher' content=\"#{Metadata.imprint}\" /></head>")
	end

	filecontents = filecontents.gsub(/<\/head>/,"<meta name='isbn-13' content='#{Metadata.eisbn}' /></head>")
								 							.gsub(/&nbsp;/,"&#160;")
								 							.gsub(/src="images\//,"src=\"")
	filecontents
end

# Adding the cover holder to the html file
def secondHTMLEdit(var)
	filecontents = var.gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\" id=\"bookcover01\"><img src=\"cover.jpg\"/></figure>")
	filecontents
end

# fix cover.html doctype
def firstCoverEdit(file)
	covercontents = File.read(file).gsub(/&lt;!DOCTYPE html&gt;/,"<!DOCTYPE html>")
	covercontents
end

# fix cover ncx entry
def firstNCXEdit(file)
	ncxcontents = File.read(file).gsub(/<text\/><\/navLabel><content src="\#bookcover01"\/>/,"<text>Cover</text></navLabel><content src=\"cover.html\"/>")
	ncxcontents
end

# fix author info in opf
def firstOPFEdit(file)
	opfcontents = File.read(file).gsub(/<dc:creator/,"<dc:identifier id='isbn'>#{Metadata.eisbn}</dc:identifier><dc:creator id='creator'")
	opfcontents
end

def convertCoverImg(file)
	`convert "#{file}" -colorspace RGB -resize "600x800>" "#{file}"`
end

def convertInteriorImg(file, dir)
	path_to_i = File.join(dir, file)
	myres = `identify -format "%y" "#{path_to_i}"`
	myres = myres.to_f
	if file.include?("_crop")
		`convert "#{path_to_i}" -colorspace RGB -density #{myres} -bordercolor white -border 1x1  -trim -resize "600x800>" -quality 100 "#{path_to_i}"`
	else
		`convert "#{path_to_i}" -colorspace RGB -density #{myres} -resize "600x800>" -quality 100 "#{path_to_i}"`
	end
end

def copyInteriorImg(dir, opf, dest)
	images = Mcmlln::Tools.dirListFiles(dir)
	opfcontents = File.read(opf)
	copied = []
	images.each do |i|
		path_to_i = File.join(dir, i)
		if opfcontents.include? i
			Mcmlln::Tools.copyFile(path_to_i, dest)
			copied << i
		end
	end
	copied
end

# ---------------------- PROCESSES
deleteOld(OEBPS_dir)
deleteOld(METAINF_dir)

# run method: firstHTMLEdit
if File.file?(epub_tmp_html)
	filecontents = firstHTMLEdit(epub_tmp_html)
else
	filecontents = firstHTMLEdit(Bkmkr::Paths.outputtmp_html)
end

# run method: secondHTMLEdit
if !final_cover.nil? and File.file?(final_cover)
	filecontents = secondHTMLEdit(filecontents)
end

Mcmlln::Tools.overwriteFile(epub_tmp_html, filecontents)

Bkmkr::Tools.runnode(strip_tocnodes_js, epub_tmp_html)

# Add new section to log file
File.open(convert_log_txt, 'a+') do |f|
	f.puts "----- EPUBMAKER PROCESSES"
end

# convert to epub and send stderr to log file
FileUtils.cd(Bkmkr::Paths.project_tmp_dir)
Bkmkr::Tools.processxsl(epub_tmp_html, epub_xsl, tmp_epub, convert_log_txt)

# run method: firstCoverEdit
# run method: firstNCXEdit
# add cover image file to epub folder
# run method: convertCoverImg
if !final_cover.nil? and File.file?(final_cover)
	covercontents = firstCoverEdit(cover_html)
	Mcmlln::Tools.overwriteFile(cover_html, covercontents)
	ncxcontents = firstNCXEdit(toc_ncx)
	Mcmlln::Tools.overwriteFile(toc_ncx, ncxcontents)
	Mcmlln::Tools.copyFile(final_cover, cover_jpg)
	unless Bkmkr::Tools.processimages == "false"
		convertCoverImg(cover_jpg)
	end
end

# run method: firstOPFEdit
opfcontents = firstOPFEdit(content_opf)
Mcmlln::Tools.overwriteFile(content_opf, opfcontents)

# add epub css to epub folder
Mcmlln::Tools.copyFile(epub_css, OEBPS_dir)

# add image files to epub folder
sourceimages = Mcmlln::Tools.dirList(img_dir)

# using imgmagick to optimize image sizes for epub
# run method: convertInteriorImg
if sourceimages.any?
	unless File.exist?(epub_img_dir)
		Dir.mkdir(epub_img_dir)
	end
	Mcmlln::Tools.copyAllFiles(img_dir, epub_img_dir)
	unless Bkmkr::Tools.processimages == "false"
		images = Mcmlln::Tools.dirListFiles(epub_img_dir)
		images.each do |i|
			convertInteriorImg(i, epub_img_dir)
		end
	end
	epubimages = copyInteriorImg(epub_img_dir, content_opf, OEBPS_dir)
	puts epubimages
end

# zip epub
Bkmkr::Tools.runpython(zipepub_py, "#{csfilename}.epub #{Bkmkr::Paths.project_tmp_dir}")

# move epub into archive folder
Mcmlln::Tools.copyFile(final_epub, final_dir)

# remove temp epub file
Mcmlln::Tools.deleteFile(tmp_epub2)

# ---------------------- LOGGING
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