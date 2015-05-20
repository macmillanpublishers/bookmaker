require 'fileutils'

require_relative '../bookmaker/header.rb'
require_relative '../bookmaker/metadata.rb'

# The directory where the cover was moved in tmparchive
coverdir = Bkmkr::Paths.project_tmp_dir_img

# the revised cover filename
cover = "#{Metadata.pisbn}_FC.jpg"

# the full path to the cover in tmp, including file name
tmp_cover = File.join(Bkmkr::Paths.project_tmp_dir_img, cover)

# the full path to the cover in the archival location, including file name
final_cover = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "cover", "cover.jpg")

# full path of cover error file
cover_error = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "COVER_ERROR.txt")

# An array listing all files in the submission dir
files = Dir.entries("#{coverdir}")

# If a cover_error file exists, delete it
if File.file?(cover_error)
	FileUtils.rm(cover_error)
end

# checks to see if cover is in the submission dir
# if yes, copies cover to archival location and deletes from submission dir
# if no, prints an error to the archival directory 
if files.include?("#{cover}")
	FileUtils.cp(tmp_cover, final_cover)
else
	File.open(cover_error, 'w') do |output|
		output.write "There is no cover image for this title. Download the cover image from Biblio and place it in the submitted_images folder, then re-submit the manuscript for conversion; cover images must be named ISBN_FC.jpg."
	end
end

# TESTING

# Count how many images are referenced in the book
if files.include?("#{cover}")
	test_missing_cover = "pass: I found a cover for this book."
else
	test_missing_cover = "FAIL: The cover file is missing."
end

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- COVERCHECKER PROCESSES"
	f.puts "#{test_missing_cover}"
end
