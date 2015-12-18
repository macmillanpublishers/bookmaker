require 'fileutils'

require_relative '../header.rb'

# ---------------------- VARIABLES
input_config = File.join(Bkmkr::Paths.submitted_images, "config.json")

tmp_config = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")

# ---------------------- METHODS

# ---------------------- PROCESSES

# For TEST purposes
test_images_before = Mcmlln::Tools.dirList(Bkmkr::Paths.submitted_images)

# Local path variables
all_submitted_images = Mcmlln::Tools.dirList(Bkmkr::Paths.submitted_images)

# Rename and move input files to tmp folder to eliminate possibility of overwriting
unless Dir.exist?(Bkmkr::Paths.tmp_dir)
	Mcmlln::Tools.makeDir(Bkmkr::Paths.tmp_dir)
end

if Dir.exist?(Bkmkr::Paths.project_tmp_dir)
	Mcmlln::Tools.deleteDir(Bkmkr::Paths.project_tmp_dir)
end

Mcmlln::Tools.makeDir(Bkmkr::Paths.project_tmp_dir)

Mcmlln::Tools.makeDir(Bkmkr::Paths.project_tmp_dir_img)

Mcmlln::Tools.copyFile("#{Bkmkr::Project.input_file}", Bkmkr::Paths.project_tmp_file)

if File.file?(input_config)
	Mcmlln::Tools.moveFile(input_config, tmp_config)
end

filecontents = "The conversion processor is currently running. Please do not submit any new files or images until the process completes."

Mcmlln::Tools.overwriteFile(Bkmkr::Paths.alert, filecontents)

# ---------------------- LOGGING

# Write test results
File.open("#{Bkmkr::Paths.log_file}", 'a+') do |f|
	f.puts "-----"
	f.puts Time.now
	f.puts "----- TMPARCHIVE PROCESSES"
	f.puts "finished tmparchive"
end