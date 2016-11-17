require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
# The locations to check for images
imagedir = Bkmkr::Paths.submitted_images

final_dir_images = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "images")

final_cover = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "cover", Metadata.frontcover)

# full path to the image error file
image_error = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "IMAGE_ERROR.txt")

# ---------------------- METHODS
# If an image_error file exists, delete it
def checkErrorFile(file)
	if File.file?(file)
		Mcmlln::Tools.deleteFile(file)
	end
end

#strips spaces from img names in html
def stripSpaces(content)
	filecontents = content.gsub(/img src=".*?"/) {|i| i.gsub(/ /, "").sub(/imgsrc/, "img src")}
	filecontents
end

def listImages(file)
	# An array of all the image files referenced in the source html file
	imgarr = File.read(file).scan(/img src=".*?"/)
	# remove duplicate image names from source array
	imgarr = imgarr.uniq
	imgarr
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
			puts match
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
	return resolution, missing
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
	end
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
	end
end

# ---------------------- PROCESSES

images = Mcmlln::Tools.dirList(imagedir)

finalimages = Mcmlln::Tools.dirList(final_dir_images)

checkErrorFile(image_error)

filecontents = File.read(Bkmkr::Paths.outputtmp_html)

# run method: stripSpaces
filecontents = stripSpaces(filecontents)

Mcmlln::Tools.overwriteFile(Bkmkr::Paths.outputtmp_html, filecontents)

# run method: listImages
imgarr = listImages(Bkmkr::Paths.outputtmp_html)

# run method: checkImages
resolution, missing = checkImages(imgarr, images, finalimages, imagedir, final_dir_images)

# run method: writeMissingErrors
writeMissingErrors(missing, image_error)

# run method: writeResErrors
writeResErrors(resolution, image_error)

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