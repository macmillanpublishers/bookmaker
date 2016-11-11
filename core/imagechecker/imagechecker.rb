require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
json_log_hash = Bkmkr::Paths.jsonlog_hash
json_log_hash[Bkmkr::Paths.thisscript] = {}
log_hash = json_log_hash[Bkmkr::Paths.thisscript]

# The locations to check for images
imagedir = Bkmkr::Paths.submitted_images

final_dir_images = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "images")

final_cover = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "cover", Metadata.frontcover)

# full path to the image error file
image_error = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "IMAGE_ERROR.txt")

readHtml = lambda {
	filecontents = File.read(Bkmkr::Paths.outputtmp_html)
	return true, filecontents
}

writeHtml = lambda { |filecontents|
	Mcmlln::Tools.overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents)
	true
}

getFilesinDir = lambda { |path|
	files = Mcmlln::Tools.dirList(path)
	return true, files
}

# ---------------------- METHODS
# If an image_error file exists, delete it
def checkErrorFile(file)
	if File.file?(file)
		Mcmlln::Tools.deleteFile(file)
	true
	else
		'n-a'
	end
rescue => e
	e
end

#strips spaces from img names in html
def stripSpaces(content)
	filecontents = content.gsub(/img src=".*?"/) {|i| i.gsub(/ /, "").sub(/imgsrc/, "img src")}
	return filecontents, true
rescue => e
	return content, e
end

def listImages(file)
	# An array of all the image files referenced in the source html file
	imgarr = File.read(file).scan(/img src=".*?"/)
	# remove duplicate image names from source array
	imgarr = imgarr.uniq
	return imgarr, true
rescue => e
	return [], e
end

def checkImages(imglist, inputdirlist, finaldirlist, inputdir, finaldir)
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
		elsif !inputdirlist.include?("#{match}") and match != Metadata.frontcover and finaldirlist.include?("#{match}")
			matched << match
			Mcmlln::Tools.copyFile(matched_file_pickup, Bkmkr::Paths.project_tmp_dir_img)
		else
			missing << match
		end
	end
	return resolution, missing, true
rescue => e
	return [],[],e
end

def writeMissingErrors(arr, file)
	# Writes an error text file in the done\pisbn\ folder that lists all missing image files as stored in the missing array
	if arr.any?
		File.open(file, 'a+') do |output|
			output.puts "MISSING IMAGES:"
			output.puts "The following images are missing from the submitted_images folder:"
			arr.each do |m|
				output.puts m
			end
		end
		true
	else
		'n-a'
	end
rescue => e
	e
end

def writeResErrors(arr, file)
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
		true
	else
		'n-a'
	end
rescue => e
	e
end

# ---------------------- PROCESSES

log_hash['get_imagedir_images'], images = Mcmlln::Tools.methodize(imagedir, &getFilesinDir)

log_hash['get_finaldir_images'], finalimages = Mcmlln::Tools.methodize(final_dir_images, &getFilesinDir)

log_hash['delete_image_errfile'] = checkErrorFile(image_error)

filecontents = File.read(Bkmkr::Paths.outputtmp_html)
log_hash['read_output_html_c'], filecontents = Mcmlln::Tools.methodize(&readHtml)

# run method: stripSpaces
filecontents, log_hash['strip_spaces'] = stripSpaces(filecontents)

#write out edited html
log_hash['overwrite_output_html_c'] = Mcmlln::Tools.methodize(filecontents, &writeHtml)

# run method: listImages
imgarr, log_hash['list_images'] = listImages(Bkmkr::Paths.outputtmp_html)

# run method: checkImages
resolution, missing, log_hash['check_images'] = checkImages(imgarr, images, finalimages, imagedir, final_dir_images)

# run method: writeMissingErrors
log_hash['write_missing_errors'] = writeMissingErrors(missing, image_error)

# run method: writeResErrors
log_hash['write_resolution_errors'] = writeResErrors(missing, image_error)

log_hash['imagedir_images'] = images
log_hash['finaldir_images'] = finalimages
log_hash['unique_image_array'] = imgarr
log_hash['lowres_images'] = resolution
log_hash['missing_images'] = missing

# ---------------------- LOGGING

# Count how many images are referenced in the book
test_img_src = imgarr.count

if missing.any?
	test_missing_img = "FAIL: These image files seem to be missing: #{missing}"
else
	test_missing_img = "pass: There are no missing image files!"
end

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- IMAGECHECKER PROCESSES"
	f.puts "I found #{test_img_src} image references in this book"
	f.puts "#{test_missing_img}"
	f.puts "finished imagechecker"
end

# Write json log:
log_hash['completed'] = Time.now
Mcmlln::Tools.write_json(json_log_hash, Bkmkr::Paths.json_log)
