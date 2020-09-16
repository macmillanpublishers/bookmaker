require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

# the directory where the epub will be created initially
epub_dir = Bkmkr::Paths.project_tmp_dir

# the path for the epub zip tool
zipepub_py = File.join(Bkmkr::Paths.core_dir, "epubmaker", "zipepub.py")

# the path for the adjusted epub html file
epub_tmp_html = File.join(Bkmkr::Paths.project_tmp_dir, "epub_tmp.xhtml")

# the path for strip-tocnodes.js
strip_tocnodes_js = File.join(Bkmkr::Paths.core_dir, "epubmaker", "strip-tocnodes.js")

# the path for strip-tocnodes.js
cover_placeholder_js = File.join(Bkmkr::Paths.core_dir, "epubmaker", "cover_placeholder.js")

# the path for strip-halftitle.js
strip_halftitle_xsl = File.join(Bkmkr::Paths.core_dir, "epubmaker", "strip-halftitle.xsl")

# the path for the primary epub conversion xsl from HTMLBook
epub_xsl = File.join(Bkmkr::Paths.scripts_dir, "HTMLBook", "htmlbook-xsl", "epub.xsl")

# the path for the temporary epub file
tmp_epub = File.join(Bkmkr::Paths.project_tmp_dir, "tmp.epub")

# the path for the temp OEBPS dir
oebps_dir = File.join(Bkmkr::Paths.project_tmp_dir, "OEBPS")

# the path for the temp META-INF dir
metainf_dir = File.join(Bkmkr::Paths.project_tmp_dir, "META-INF")

# cover html file within the epub
cover_html = File.join(oebps_dir, "cover.xhtml")

# ncx file within the epub
toc_ncx = File.join(oebps_dir, "toc.ncx")

# opf file within the epub
content_opf = File.join(oebps_dir, "content.opf")

# the path for the converted epub cover file
cover_jpg = File.join(oebps_dir, "cover.jpg")

# the path to the holding dir for epub image conversion
epub_img_dir = File.join(Bkmkr::Paths.project_tmp_dir, "epubimg")

# final epub filename
csfilename = "#{Metadata.eisbn}_EPUB"

# epub css file
epub_css = File.join(Metadata.final_dir, "layout", "epub.css")

# final image directory
img_dir = File.join(Metadata.final_dir, "images")

# final converted epub
final_epub = File.join(Bkmkr::Paths.project_tmp_dir, "#{csfilename}.epub")

# final archive dir
final_dir = Metadata.final_dir

# second epub conversion
tmp_epub2 = File.join(Bkmkr::Paths.project_tmp_dir, "#{csfilename}.epub")

# ---------------------- METHODS
def readConfigJson(logkey='')
  data_hash = Mcmlln::Tools.readjson(Metadata.configfile)
  return data_hash
rescue => logstring
  return {}
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# Delete any old conversion stuff
## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def deleteOld(dir, logkey='')
	if File.exists?(dir)
		Mcmlln::Tools.deleteDir(dir)
	else
		logstring = 'n-a'
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# Adding author meta element to head
# Replacing toc with empty nav, as required by htmlbook xsl
def firstHTMLEdit(file, logkey='')
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
	return filecontents
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def overwriteFile(path, filecontents, logkey='')
	Mcmlln::Tools.overwriteFile(path, filecontents)
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping Bkmkr::Tools.runnode in a new method for this script; to return a result for json_logfile
def localRunNode(jsfile, htmlfile, logkey='')
	Bkmkr::Tools.runnode(jsfile, htmlfile)
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def cdToProjectTmp(logkey='')
	FileUtils.cd(Bkmkr::Paths.project_tmp_dir)
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping Bkmkr::Tools.processxsl in a new method for this script; to return a result for json_logfile
def processxsl_epubmaker(epub_tmp_html, epub_xsl, tmp_epub, logkey='')
	Bkmkr::Tools.processxsl(epub_tmp_html, epub_xsl, tmp_epub, '')
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# fix cover.html doctype
def firstCoverEdit(file, logkey='')
	covercontents = File.read(file).gsub(/&lt;!DOCTYPE html&gt;/,"<!DOCTYPE html>").gsub(/<body>/,"<body><h1 class=\"Nonprinting\">Cover</h1>")
	return covercontents
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# fix cover ncx entry
def firstNCXEdit(file, logkey='')
	ncxcontents = File.read(file).gsub(/<text\/><\/navLabel><content src="\#bookcover01"\/>/,"<text>Cover</text></navLabel><content src=\"cover.xhtml\"/>")
	return ncxcontents
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# fix author info in opf
def firstOPFEdit(file, logkey='')
	opfcontents = File.read(file).gsub(/<dc:creator/,"<dc:identifier id='isbn'>#{Metadata.eisbn}</dc:identifier><dc:creator id='creator'")
	return opfcontents
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def convertCoverImg(file, logkey='')
	unless Bkmkr::Tools.processimages == "false"
		`convert "#{file}" -colorspace RGB -resize "600x800>" "#{file}"`
	else
		logstring = 'processimages is set to false in bookmaker config.rb, skipping'
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def copyFile_epubmaker(source, dest, logkey='')
	Mcmlln::Tools.copyFile(source, dest)
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def getFilesinDir(path, logkey='')
	files = Mcmlln::Tools.dirList(path)
	return files
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def makeEpubImgsDir(path, logkey='')
	unless Dir.exist?(path)
		Mcmlln::Tools.makeDir(path)
	else
	 logstring = 'n-a'
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def copyImgFiles(source, dest, logkey='')
	Mcmlln::Tools.copyAllFiles(source,dest)
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def convertInteriorImg(file, dir, logkey='')
	path_to_i = File.join(dir, file)
	myres = `identify -format "%y" "#{path_to_i}"`
	myres = myres.to_f
	if file.include?("_crop")
		`convert "#{path_to_i}" -colorspace RGB -density #{myres} -bordercolor white -border 1x1  -trim -resize "600x800>" -quality 100 "#{path_to_i}"`
	else
		`convert "#{path_to_i}" -colorspace RGB -density #{myres} -resize "600x800>" -quality 100 "#{path_to_i}"`
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def convertInteriorImgs(epub_img_dir, logkey='')
	unless Bkmkr::Tools.processimages == "false"
		images = getFilesinDir(epub_img_dir, 'get_epub_img_list')
		images.each do |i|
			convertInteriorImg(i, epub_img_dir)
		end
	else
		logstring = 'processimages is set to false in bookmaker config.rb, skipping'
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def copyInteriorImg(dir, opf, dest, logkey='')
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
	return copied
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def moveFileToDoneFolder(file, dest, logkey='')
	Mcmlln::Tools.moveFile(file, dest)
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping Bkmkr::Tools.runpython in a new method for this script; to return a result for json_logfile
def zipEpub(script, args, logkey='')
	Bkmkr::Tools.runpython(script, args)
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def deleteTmpEpub(file, logkey='')
	Mcmlln::Tools.deleteFile(file)
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# ---------------------- PROCESSES

data_hash = readConfigJson('read_config_json')

##### local definition(s) based on data from config.json
cover = data_hash['frontcover']

# the path to the cover file
unless data_hash['frontcover'].nil? or data_hash['frontcover'].empty? or !data_hash['frontcover']
	final_cover = File.join(Metadata.final_dir, "cover", cover)
else
	final_cover = ""
end

# delete existing epub dirs
deleteOld(oebps_dir, 'delete_old_OEBPS')
deleteOld(metainf_dir, 'delete_old_METAINF')

# run method: firstHTMLEdit
if File.file?(epub_tmp_html)
	filecontents = firstHTMLEdit(epub_tmp_html, 'first_html_edit--epub_tmp_html')
else
	filecontents = firstHTMLEdit(Bkmkr::Paths.outputtmp_html, 'first_html_edit--outputtmp_html')
end

overwriteFile(epub_tmp_html, filecontents, 'overwrite_epubtmp_html')

# run node method: add cover placeholder to html file
if !final_cover.nil? and File.file?(final_cover)
  localRunNode(cover_placeholder_js, epub_tmp_html, 'cover_placeholder_js')
end

localRunNode(strip_tocnodes_js, epub_tmp_html, 'strip_tocnodes_js')

# convert to epub!
processxsl_epubmaker(epub_tmp_html, epub_xsl, tmp_epub, 'process_xsl')

# run method: firstCoverEdit
# run method: firstNCXEdit
# add cover image file to epub folder
# run method: convertCoverImg
if !final_cover.nil? and File.file?(final_cover)
	@log_hash['final_cover_present'] = true
	covercontents = firstCoverEdit(cover_html, 'first_cover_edit')
	overwriteFile(cover_html, covercontents, 'overwrite_cover_html')
	ncxcontents = firstNCXEdit(toc_ncx, 'first_ncx_edit')
	overwriteFile(toc_ncx, ncxcontents, 'overwrite_toc_ncx')
	copyFile_epubmaker(final_cover, cover_jpg, 'copy_final_cover_file')
	convertCoverImg(cover_jpg, 'process_cover_file')
else
	@log_hash['final_cover_present'] = false
end

# run method: firstOPFEdit
opfcontents = firstOPFEdit(content_opf, 'first_OPF_Edit')
overwriteFile(content_opf, opfcontents, 'overwrite_content_opf')

# add epub css to epub folder
copyFile_epubmaker(epub_css, oebps_dir, 'copy_epub_css_to_OEBPSdir')

# add image files to epub folder
sourceimages = getFilesinDir(img_dir, 'get_image_list')

# using imgmagick to optimize image sizes for epub
# run method: convertInteriorImg
if sourceimages.any?
	makeEpubImgsDir(epub_img_dir, 'mkdir-epub_images')

	copyImgFiles(Bkmkr::Paths.project_tmp_dir_img, epub_img_dir, 'copy_img_files')

	#this method checks for pis and loops through relevant imgs for method convertInteriorImg
	convertInteriorImgs(epub_img_dir, 'convert_interior_imgs')

	epubimages = copyInteriorImg(epub_img_dir, content_opf, oebps_dir, 'copy_interior_imgs')
	puts epubimages
	@log_hash['interior_img_list'] = epubimages
end

# zip epub
zipEpub(zipepub_py, "#{csfilename}.epub #{Bkmkr::Paths.project_tmp_dir}", 'zip_epub')

# move epub into archive folder
moveFileToDoneFolder(final_epub, final_dir, 'mv_epub_to_done_folder')

# remove temp epub file
deleteTmpEpub(tmp_epub2, 'rm_tmp_epub_file')


# ---------------------- LOGGING
# epub file should exist in done dir
if File.file?("#{Metadata.final_dir}/#{csfilename}.epub")
	test_epub_status = "pass: the EPUB was created successfully"
else
	test_epub_status = "FAIL: the EPUB was created successfully"
end

@log_hash['ebook_ISBN']=Metadata.eisbn
@log_hash['test_epub_status'] = test_epub_status

# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
