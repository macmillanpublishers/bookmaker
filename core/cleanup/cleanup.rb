require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# clean up the ftp site if files were uploaded
if File.exists?("#{Bkmkr::Paths.project_tmp_dir_img}/uploaded_image_log.txt") && !File.zero?("#{Bkmkr::Paths.project_tmp_dir_img}/uploaded_image_log.txt")
	`#{Bkmkr::Paths.scripts_dir}/bookmaker_ftpupload/imagedelete.bat #{Bkmkr::Paths.project_tmp_dir}`
end

# verify ftp site is clean
if File.exists?("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/images/clear_ftp_log.txt")
	if File.zero?("#{Bkmkr::Paths.project_tmp_dir}/clear_ftp_log.txt")
		test_ftp_files_removed = "pass: The ftp server directory (bookmakerimg) is clean"
	else
		test_ftp_files_removed = "FAIL: The ftp server directory (bookmakerimg) is clean"
	end
elsif File.exists?("#{Bkmkr::Paths.project_tmp_dir_img}/uploaded_image_log.txt") && !File.zero?("#{Bkmkr::Paths.project_tmp_dir_img}/uploaded_image_log.txt")
	test_ftp_files_removed = "FAIL: The ftp server directory (bookmakerimg) is clean (files were uploaded but not deleted)"
else
	test_ftp_files_removed = "pass: The ftp server directory (bookmakerimg) presumed clean (no images uploaded))"
end

# Delete all the working files and dirs
FileUtils.rm_r(Bkmkr::Paths.project_tmp_dir)
FileUtils.rm(Bkmkr::Project.input_file)
FileUtils.rm(Bkmkr::Paths.alert)

# LOGGING

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- CLEANUP PROCESSES"
	f.puts "finished cleanup"	
end