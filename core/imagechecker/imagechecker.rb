require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# The location where the images are moved to by tmparchive
imagedir = Bkmkr::Paths.submitted_images

# The working dir location that images will be moved to (for test 3)
image_dest = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "images")

# full path to the image error file
image_error = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "IMAGE_ERROR.txt")

# An array listing all the submitted images
images = Dir.entries("#{imagedir}")

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

# Checks to see if each image referenced in the html exists in the tmp images folder
# If no, saves the image file name in the missing array
# If yes, copies the image file to the done/pisbn/images folder, and deletes original
source.each do |m|
	match = m.split("/").pop.gsub(/"/,'')
	matched_file = File.join(imagedir, match)
	if images.include?("#{match}") and match == Metadata.frontcover
		FileUtils.cp(matched_file, image_dest)
		matched << match
		FileUtils.cp(matched_file, Bkmkr::Paths.project_tmp_dir_img)
	elsif images.include?("#{match}") and match != Metadata.frontcover
		FileUtils.cp(matched_file, image_dest)
		matched << match
		FileUtils.mv(matched_file, Bkmkr::Paths.project_tmp_dir_img)
	else
		missing << match
	end
end

# Writes an error text file in the done\pisbn\ folder that lists all missing image files as stored in the missing array
if missing.any?
	File.open(image_error, 'w') do |output|
		output.write "The following images are missing from the submitted_images folder: #{missing}"
	end
end

# TESTING

# Count how many images are referenced in the book
test_img_src = source.count

if missing.any?
	test_missing_img = "FAIL: These image files seem to be missing: #{missing}"
else
	test_missing_img = "pass: There are no missing image files!"
end

images_moved = Dir.entries("#{image_dest}").select {|f| !File.directory? f}
images_moved -= %w{clear_ftp_log.txt}
match_check = matched.uniq.sort
if images_moved.sort == match_check
	test_imgs_match_refs = "pass: Images' names in Done folder match references in html"
else
	test_imgs_match_refs = "FAIL: Images' names in Done folder match references in html"
end

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- IMAGECHECKER PROCESSES"
	f.puts "I found #{test_img_src} image references in this book"
	f.puts "#{test_missing_img}"
	f.puts "#{test_imgs_match_refs}"
end