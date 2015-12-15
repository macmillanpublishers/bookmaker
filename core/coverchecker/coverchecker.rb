require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
# the cover filename
cover = Metadata.frontcover

# The directory where the cover was submitted
coverdir = Bkmkr::Paths.submitted_images

# the full path to the cover in tmp, including file name
tmp_cover = File.join(Bkmkr::Paths.submitted_images, cover)

# the full path to the cover in the archival location, including file name
final_cover = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "cover", cover)

# full path of cover error file
cover_error = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "COVER_ERROR.txt")

# An array listing all files in the submission dir
files = Mcmlln::Tools.dirList(coverdir)

# ---------------------- METHODS
# If a cover_error file exists, delete it
def checkErrorFile(file)
	if File.file?(file)
		Mcmlln::Tools.deleteFile(file)
	end
end

# checks to see if cover is in the submission dir
# if yes, copies cover to archival location and deletes from submission dir
# if no, prints an error to the archival directory 
def checkCoverFile(file, tmpcover, finalcover, errorfile)
	if files.include?("#{file}")
		FileUtils.mv(tmpcover, finalcover)
		covercheck = "Found a new cover submitted"
	elsif !files.include?("#{file}") and File.file?(finalcover)
		covercheck = "Picking up existing cover"
	else
		File.open(errorfile, 'w') do |output|
			output.puts "There is no cover image for this title."
			output.puts "Place the cover image file in the submitted_images folder, then re-submit the manuscript for conversion."
			output.puts "Cover image must be named #{Metadata.frontcover}."
		end
		covercheck = "No cover found"
	end
	covercheck
end

# ---------------------- PROCESSES
checkErrorFile(cover_error)
checkCoverFile(cover, tmp_cover, final_cover, cover_error)

# ---------------------- LOGGING
# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- COVERCHECKER PROCESSES"
	f.puts covercheck
	f.puts "finished coverchecker"
end
