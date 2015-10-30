require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# The locations to check for images
imagedir = Bkmkr::Paths.submitted_images
final_dir_images = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "images")
final_cover = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "cover", Metadata.frontcover)

# The working dir location that images will be moved to (for test 3)
image_dest = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "images")

# full path to the image error file
image_error = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "IMAGE_ERROR.txt")

# An array listing all the submitted images
images = Dir.entries("#{imagedir}")

# An array listing all images in the archive dir
finalimages = Dir.entries("#{final_dir_images}")

# If a cover_error file exists, delete it
if File.file?(image_error)
	FileUtils.rm(image_error)
end

#strips spaces from img names in html
text = File.read(Bkmkr::Paths.outputtmp_html)
new_contents = text.gsub(/img src=".*?"/) {|i| i.gsub(/ /, "").sub(/imgsrc/, "img src")}
File.open(Bkmkr::Paths.outputtmp_html, "w") {|file| file.puts new_contents }

# An array of all the image files referenced in the source html file
source = File.read(Bkmkr::Paths.outputtmp_html).scan(/img src=".*?"/)

# remove duplicate image names from source array
source = source.uniq

# An empty array to store the list of any missing images
missing = []
# An empty array to store nospace names of html images existing in submission folder (for test 3)
matched = []
# An empty array to store filenames with resolution less than 300
resolution = []

# Checks to see if each image referenced in the html exists in the tmp images folder
# If no, saves the image file name in the missing array
# If yes, copies the image file to the done/pisbn/images folder, and deletes original
source.each do |m|
	match = m.split("/").pop.gsub(/"/,'')
	matched_file = File.join(imagedir, match)
	matched_file_pickup = File.join(final_dir_images, match)
	if images.include?("#{match}") and match == Metadata.frontcover
		matched << match
		myres = `identify -format "%y" "#{matched_file}"`
		myres = myres.to_f
		if myres < 300
			resolution << match
		end
		FileUtils.cp(matched_file, Bkmkr::Paths.project_tmp_dir_img)
	elsif images.include?("#{match}") and match != Metadata.frontcover
		FileUtils.cp(matched_file, image_dest)
		matched << match
		myres = `identify -format "%y" "#{matched_file}"`
		myres = myres.to_f
		if myres < 300
			resolution << match
		end
		FileUtils.mv(matched_file, Bkmkr::Paths.project_tmp_dir_img)
	elsif !images.include?("#{match}") and match != Metadata.frontcover and finalimages.include?("#{match}")
		matched << match
		FileUtils.cp(matched_file_pickup, Bkmkr::Paths.project_tmp_dir_img)
	else
		missing << match
	end
end

# Writes an error text file in the done\pisbn\ folder that lists all missing image files as stored in the missing array
if missing.any?
	File.open(image_error, 'w') do |output|
		output.puts "MISSING IMAGES:"
		output.puts "The following images are missing from the submitted_images folder:"
		missing.each do |m|
			output.puts m
		end
	end
end

# Check image resolution
if resolution.any?
	File.open(image_error, 'a') do |output|
		output.puts "RESOLUTION ERRORS:"
		output.puts "Your images will look best in both print and ebook formats at 300dpi or higher."
		output.puts "The following images have a resolution less than 300dpi:"
		resolution.each do |r|
			output.puts r
		end
	end
end

# LOGGING

# Count how many images are referenced in the book
test_img_src = source.count

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