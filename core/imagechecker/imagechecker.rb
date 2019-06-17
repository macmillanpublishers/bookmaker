require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

# The locations to check for images
imagedir = Bkmkr::Paths.project_tmp_dir_submitted

final_dir_images = File.join(Metadata.final_dir, "images")

final_cover = File.join(Metadata.final_dir, "cover", Metadata.frontcover)

# full path to the image error file
image_error = File.join(Metadata.final_dir, "IMAGE_ERROR.txt")

# ---------------------- METHODS
## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def getFilesinDir(path, logkey='')
	files = Mcmlln::Tools.dirList(path)
	return files
rescue => logstring
	return []
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# If an image_error file exists, delete it
## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def checkErrorFile(file, logkey='')
	if File.file?(file)
		Mcmlln::Tools.deleteFile(file)
	else
		logstring = 'n-a'
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def readOutputHtml(logkey='')
	filecontents = File.read(Bkmkr::Paths.outputtmp_html)
	return filecontents
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

#strips spaces from img names in html
def stripSpaces(content, logkey='')
	filecontents = content.gsub(/img src=".*?"/) {|i| i.gsub(/ /, "").sub(/imgsrc/, "img src")}
	return filecontents
rescue => logstring
	return content
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def overwriteFile(path,filecontents, logkey='')
	Mcmlln::Tools.overwriteFile(path, filecontents)
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def listImages(file, logkey='')
	# An array of all the image files referenced in the source html file
	imgarr = File.read(file).scan(/img src=".*?"/)
	# remove duplicate image names from source array
	imgarr = imgarr.uniq
	return imgarr
rescue => logstring
	return []
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def checkImages(imglist, inputdirlist, finaldirlist, inputdir, finaldir, logkey='')
	# An empty array to store the list of any missing images
	missing = []
	# An empty array to store nospace names of html images existing in submission folder (for test 3)
	matched = []
	# An empty array to store filenames with resolution less than 300
	resolution = []

	# Checks to see if each image referenced in the html exists in the tmp images folder
	# If no, saves the image file name in the missing array
	# If yes, copies the image file to the done/pisbn/images folder, and deletes original
	imglist.each do |m|
		puts "CHECKING IMAGE #{m}"
		match = m.split("/").pop.gsub(/"/,'')
		matched_file = File.join(inputdir, match)
		matched_file_pickup = File.join(finaldir, match)
		if inputdirlist.include?("#{match}") and match == Metadata.frontcover
			matched << match
			myres = `identify -format "%y" "#{matched_file}"`
			myres = myres.to_f
			if myres < 300
				resolution << match
			end
			Mcmlln::Tools.copyFile(matched_file, Bkmkr::Paths.project_tmp_dir_img)
		elsif inputdirlist.include?("#{match}") and match != Metadata.frontcover
			Mcmlln::Tools.copyFile(matched_file, finaldir)
			matched << match
			myres = `identify -format "%y" "#{matched_file}"`
			myres = myres.to_f
			if myres < 300
				resolution << match
			end
			Mcmlln::Tools.moveFile(matched_file, Bkmkr::Paths.project_tmp_dir_img)
			puts "MOVING #{match} to archive dir"
		elsif !inputdirlist.include?("#{match}") and match != Metadata.frontcover and finaldirlist.include?("#{match}")
			matched << match
			Mcmlln::Tools.copyFile(matched_file_pickup, Bkmkr::Paths.project_tmp_dir_img)
		else
			missing << match
		end
	end
	return resolution, missing
rescue => logstring
	return [],[]
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def writeMissingErrors(arr, file, logkey='')
	# Writes an error text file in the done\pisbn\ folder that lists all missing image files as stored in the missing array
	if arr.any?
		File.open(file, 'a+') do |output|
			output.puts "MISSING IMAGES:"
			output.puts "The following images are missing from the submitted_images folder:"
			arr.each do |m|
				output.puts m
			end
		end
	else
		logstring = 'n-a'
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def writeResErrors(arr, file, logkey='')
	# Writes an error text file in the done\pisbn\ folder that lists all low res image files as stored in the resolution array
	if arr.any?
		File.open(file, 'a+') do |output|
			output.puts "RESOLUTION ERRORS:"
			output.puts "Your images will look best in both print and ebook formats at 300dpi or higher."
			output.puts "The following images have a resolution less than 300dpi:"
			arr.each do |r|
				output.puts r
			end
		end
	else
		logstring = 'n-a'
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# ---------------------- PROCESSES

#get arrays of submitted images & images in archival folders
images = getFilesinDir(imagedir, 'check_submitted_images')

finalimages = getFilesinDir(final_dir_images, 'check_final_images')

#delete image error file if it exists
checkErrorFile(image_error, 'delete_image_errfile')

#read in html for manipulations
filecontents = readOutputHtml('read_output_html')

# run method: stripSpaces
filecontents = stripSpaces(filecontents, 'strip_spaces')

#write out edited html
overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents, 'overwrite_output_html_c')

# run method: listImages
imgarr = listImages(Bkmkr::Paths.outputtmp_html, 'list_images')

# run method: checkImages
resolution, missing = checkImages(imgarr, images, finalimages, imagedir, final_dir_images, 'check_images')

# run method: writeMissingErrors
writeMissingErrors(missing, image_error, 'write_missing_errors')

# run method: writeResErrors
writeResErrors(resolution, image_error, 'write_resolution_errors')


# ---------------------- LOGGING

# write items of interest to json log
@log_hash['image_references_in_ms']=imgarr.count
@log_hash['imagedir_images'] = images
@log_hash['finaldir_images'] = finalimages
@log_hash['unique_image_array'] = imgarr
@log_hash['lowres_images'] = resolution
@log_hash['missing_images'] = missing

# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
