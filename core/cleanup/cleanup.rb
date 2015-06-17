require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# clean up the ftp site if files were uploaded
if File.exists?("#{Bkmkr::Paths.project_tmp_dir_img}/uploaded_image_log.txt") && !File.zero?("#{Bkmkr::Paths.project_tmp_dir_img}/uploaded_image_log.txt")
	`#{Bkmkr::Paths.scripts_dir}/bookmaker_ftpupload/imagedelete.bat #{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/images`
end

# verify ftp site is clean
if File.exists?("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/images/clear_ftp_log.txt")
	if File.zero?("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/images/clear_ftp_log.txt")
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
FileUtils.rm_r("#{Bkmkr::Paths.submitted_images}/*")
FileUtils.rm(Bkmkr::Project.input_file)
FileUtils.rm(Bkmkr::Paths.alert)

# TESTING

# verify input file is gone
if File.exists?("#{Bkmkr::Project.input_file}")
	test_inputfile_removed = "FAIL: Input file has been deleted from Convert directory"
else
	test_inputfile_removed = "pass: Input file has been deleted from Convert directory"
end

# verify tmp folder for pisbn is gone
if File.exists?("#{Bkmkr::Paths.tmp_dir}/#{Bkmkr::Project.filename}")
	test_tmpdir_removed = "FAIL: Tmp directory has been removed"
else
	test_tmpdir_removed = "pass: Tmp directory has been removed"
end

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- CLEANUP PROCESSES"
	f.puts "#{test_inputfile_removed}"
	f.puts "#{test_ftp_files_removed}"	
	f.puts "#{test_tmpdir_removed}"	
end