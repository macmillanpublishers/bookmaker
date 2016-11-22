require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
json_log_hash = Bkmkr::Paths.jsonlog_hash
json_log_hash[Bkmkr::Paths.thisscript] = {}
log_hash = json_log_hash[Bkmkr::Paths.thisscript]

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
		true
	else
		'n-a'
	end
rescue => e
	e
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
	return true, filecontents
rescue => e
	return e,''
end

# Adding the cover holder to the html file
def secondHTMLEdit(var)
	filecontents = var.gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\" id=\"bookcover01\"><img src=\"cover.jpg\"/></figure>")
	return true, filecontents
rescue => e
	return e,''
end

def overwriteFile(path,filecontents)
	Mcmlln::Tools.overwriteFile(path, filecontents)
	true
rescue => e
	e
end

def runNode_epubmaker(jsfile, extra_arg=nil)
	if extra_arg.nil?
		Bkmkr::Tools.runnode(jsfile, Bkmkr::Paths.outputtmp_html)
	else
		Bkmkr::Tools.runnode(jsfile, extra_arg)
	end
	true
rescue => e
	e
end

def cdToProjectTmp
	FileUtils.cd(Bkmkr::Paths.project_tmp_dir)
	true
rescue => e
	e
end

def processxsl_epubmaker(epub_tmp_html, epub_xsl, tmp_epub, convert_log_txt)
	Bkmkr::Tools.processxsl(epub_tmp_html, epub_xsl, tmp_epub, convert_log_txt)
	true
rescue => e
	e
end

# fix cover.html doctype
def firstCoverEdit(file)
	covercontents = File.read(file).gsub(/&lt;!DOCTYPE html&gt;/,"<!DOCTYPE html>").gsub(/<body>/,"<body><h1 class=\"Nonprinting\">Cover</h1>")
	return true, covercontents
rescue => e
	return e,''
end

# fix cover ncx entry
def firstNCXEdit(file)
	ncxcontents = File.read(file).gsub(/<text\/><\/navLabel><content src="\#bookcover01"\/>/,"<text>Cover</text></navLabel><content src=\"cover.html\"/>")
	return true, ncxcontents
rescue => e
	return e,''
end

# fix author info in opf
def firstOPFEdit(file)
	opfcontents = File.read(file).gsub(/<dc:creator/,"<dc:identifier id='isbn'>#{Metadata.eisbn}</dc:identifier><dc:creator id='creator'")
	return true, opfcontents
rescue => e
	return e,''
end

def convertCoverImg(file)
	unless Bkmkr::Tools.processimages == "false"
		`convert "#{file}" -colorspace RGB -resize "600x800>" "#{file}"`
		true
	else
		'processimages is set to false in bookmaker config.rb, skipping'
	end
rescue => e
	e
end

def copyFile_epubmaker(source, dest)
	Mcmlln::Tools.copyFile(source, dest)
	true
rescue => e
	e
end

def getFilesinDir(path)
	files = Mcmlln::Tools.dirList(path)
	return true, files
rescue => e
	e
end

def makeEpubImgsDir(path)
	unless Dir.exist?(Bkmkr::path.tmp_dir)
		Mcmlln::Tools.makeDir(path)
		true
	else
	 'n-a'
	end
rescue => e
	e
end

def copyImgFiles(source,dest)
	Mcmlln::Tools.copyAllFiles(source,dest)
	true
rescue => e
	e
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
rescue => e
	e
end

def convertInteriorImgs(dir)
	unless Bkmkr::Tools.processimages == "false"
		log_hash['get_epub_img_list'], images = getFilesinDir(epub_img_dir)
		images.each do |i|
			convertInteriorImg(i, epub_img_dir)
		end
		true
	else
		'processimages is set to false in bookmaker config.rb, skipping'
	end
rescue => e
	e
end

def copyInteriorImg(dir, opf, dest)
	images = Mcmlln::Tools.dirListFiles(dir)
	opfcontents = File.read(opf)
	copied = []
	images.each do |i|
		path_to_i = File.join(dir, i)
		if opfcontents.include? "\"#{i}"
			Mcmlln::Tools.copyFile(path_to_i, dest)
			copied << i
		end
	end
	return true, copied
rescue => e
	return e,''
end

def moveFileToDoneFolder(file, dest)
	Mcmlln::Tools.moveFile(file, dest)
	true
rescue => e
	e
end

def zipEpub(script, args)
	Bkmkr::Tools.runpython(script, args)
	true
rescue => e
	e
end

def deleteTmpEpub(file)
	Mcmlln::Tools.deleteFile(file)
	true
rescue => e
	e
end

# ---------------------- PROCESSES
log_hash['delete_old_OEBPS'] = deleteOld(OEBPS_dir)
log_hash['delete_old_METAINF'] = deleteOld(METAINF_dir)

# run method: firstHTMLEdit
if File.file?(epub_tmp_html)
	log_hash['first_html_edit--epub_tmp_html'], filecontents = firstHTMLEdit(epub_tmp_html)
else
	log_hash['first_html_edit--outputtmp_html'], filecontents = firstHTMLEdit(Bkmkr::Paths.outputtmp_html)
end

# run method: secondHTMLEdit
if !final_cover.nil? and File.file?(final_cover)
	log_hash['second_html_edit'], filecontents = secondHTMLEdit(filecontents)
end

log_hash['overwrite_epubtmp_html'] = overwriteFile(epub_tmp_html, filecontents)

log_hash['strip_tocnodes_js'] = runNode_epubmaker(strip_tocnodes_js, epub_tmp_html)

# Add new section to log file
File.open(convert_log_txt, 'a+') do |f|
	f.puts "----- EPUBMAKER PROCESSES"
end

# convert to epub and send stderr to log file
log_hash['cd_to_project_tmpdir'] = cdToProjectTmp

log_hash['process_xsl'] = processxsl_epubmaker(epub_tmp_html, epub_xsl, tmp_epub, convert_log_txt)

# run method: firstCoverEdit
# run method: firstNCXEdit
# add cover image file to epub folder
# run method: convertCoverImg
if !final_cover.nil? and File.file?(final_cover)
	log_hash['final_cover_present'] = true
	log_hash['first_cover_edit'], covercontents = firstCoverEdit(cover_html)
	log_hash['overwrite_cover_html'] = overwriteFile(cover_html, covercontents)
	log_hash['first_ncx_edit'], ncxcontents = firstNCXEdit(toc_ncx)
	log_hash['overwrite_toc_ncx'] = overwriteFile(toc_ncx, ncxcontents)
	log_hash['copy_final_cover_file'] = copyFile_epubmaker(final_cover, cover_jpg)
	log_hash['process_cover_file'] = convertCoverImg(cover_jpg)
else
	log_hash['final_cover_present'] = false
end

# run method: firstOPFEdit
log_hash['first_OPF_Edit'], opfcontents = firstOPFEdit(content_opf)
log_hash['overwrite_content_opf'] = overwriteFile(content_opf, opfcontents)

# add epub css to epub folder
log_hash['copy_epub_css_to_OEBPSdir'] = copyFile_epubmaker(epub_css, OEBPS_dir)

# add image files to epub folder
log_hash['get_image_list'], sourceimages = getFilesinDir(img_dir)

# using imgmagick to optimize image sizes for epub
# run method: convertInteriorImg
if sourceimages.any?
	log_hash['mkdir-epub_images'] = makeEpubImgsDir(epub_img_dir)

	log_hash['copy_img_files'] = copyImgFiles(Bkmkr::Paths.project_tmp_dir_img, epub_img_dir)

	log_hash['convert_interior_imgs'] = convertInteriorImgs(epub_img_dir)

	log_hash['copy_interior_imgs'], epubimages = copyInteriorImg(epub_img_dir, content_opf, OEBPS_dir)
	puts epubimages

	log_hash['interior_img_list'] = epubimages
end

# zip epub
log_hash['zip_epub'] = zipEpub(zipepub_py, "#{csfilename}.epub #{Bkmkr::Paths.project_tmp_dir}")

# move epub into archive folder
log_hash['mv_epub_to_done_folder'] = moveFileToDoneFolder(final_epub, final_dir)

# remove temp epub file
log_hash['rm_tmp_epub_file'] = deleteTmpEpub(tmp_epub2)


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

log_hash['test_epub_status'] = test_epub_status

# Write json log:
log_hash['completed'] = Time.now
Mcmlln::Tools.write_json(json_log_hash, Bkmkr::Paths.json_log)
