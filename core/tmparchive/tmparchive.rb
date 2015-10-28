require 'fileutils'

require_relative '../header.rb'

# For TEST purposes
test_images_before = Dir.entries(Bkmkr::Paths.submitted_images)

# Local path variables
all_submitted_images = Dir.entries(Bkmkr::Paths.submitted_images)
input_config = File.join(Bkmkr::Paths.submitted_images, "config.json")
tmp_config = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")

# Rename and move input files to tmp folder to eliminate possibility of overwriting
if Dir.exist?(Bkmkr::Paths.project_tmp_dir)
	FileUtils.rm_r(Bkmkr::Paths.project_tmp_dir)
end
Dir.mkdir(Bkmkr::Paths.project_tmp_dir)
Dir.mkdir(Bkmkr::Paths.project_tmp_dir_img)
FileUtils.cp("#{Bkmkr::Project.input_file}", Bkmkr::Paths.project_tmp_file)
if File.file?(input_config)
	FileUtils.mv(input_config, tmp_config)
end

# Add a notice to the conversion dir warning that the process is in use
File.open("#{Bkmkr::Paths.alert}", 'w') do |output|
	output.write "The conversion processor is currently running. Please do not submit any new files or images until the process completes."
end

# LOGGING

# Write test results
File.open("#{Bkmkr::Paths.log_file}", 'a+') do |f|
	f.puts "-----"
	f.puts Time.now
	f.puts "----- TMPARCHIVE PROCESSES"
	f.puts "finished tmparchive"
end