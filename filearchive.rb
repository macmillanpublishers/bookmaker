require 'fileutils'

require_relative '../bookmaker/header.rb'

# create the archival directory structure and copy xml and html there
filetype = Bkmkr::Project.filename_split.split(".").pop

final_dir = File.join(Bkmkr::Paths.done_dir, Bkmkr::Metadata.pisbn)
final_dir_images = File.join(Bkmkr::Paths.done_dir, Bkmkr::Metadata.pisbn, "images")
final_dir_cover = File.join(Bkmkr::Paths.done_dir, Bkmkr::Metadata.pisbn, "cover")
final_dir_layout = File.join(Bkmkr::Paths.done_dir, Bkmkr::Metadata.pisbn, "layout")
final_manuscript = File.join(Bkmkr::Paths.done_dir, Bkmkr::Metadata.pisbn, "#{Bkmkr::Metadata.pisbn}_MNU.#{filetype}")
final_html = File.join(Bkmkr::Paths.done_dir, Bkmkr::Metadata.pisbn, "layout", "#{Bkmkr::Metadata.pisbn}.html")

unless Dir.exist?(final_dir)
	Dir.mkdir(final_dir)
	Dir.mkdir(final_dir_images)
	Dir.mkdir(final_dir_cover)
	Dir.mkdir(final_dir_layout)
end

FileUtils.cp(Bkmkr::Project.input_file, final_manuscript)
FileUtils.cp(html_file, final_html)

# TESTING

# print isbn should exist AND be 13-digit string of digits
test_pisbn_chars = Bkmkr::Metadata.pisbn.scan(/\d\d\d\d\d\d\d\d\d\d\d\d\d/)
test_pisbn_length = Bkmkr::Metadata.pisbn.split(%r{\s*})

if test_pisbn_length.length == 13 and test_pisbn_chars.length != 0
	test_isbn_status = "pass: print isbn is composed of 13 consecutive digits"
else
	test_isbn_status = "FAIL: print isbn is composed of 13 consecutive digits"
end

# done dir and all subdirs should exist
if File.exist?(final_dir) and File.exist?(final_dir_images) and File.exist?(final_dir_cover) and File.exist?(final_dir_layout)
	test_dir_status = "pass: project directory and all sub-directories were successfully created"
else
	test_dir_status = "FAIL: project directory and all sub-directories were successfully created"
end

# input file should exist in done dir 
if File.file?(final_manuscript)
	test_input_status = "pass: original file preserved in project directory"
else
	test_input_status = "FAIL: original file preserved in project directory"
end

# html file should exist in done dir 
if File.file?(final_html)
	test_html_status = "pass: converted html file preserved in project directory"
else
	test_html_status = "FAIL: converted html file preserved in project directory"
end

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- FILEARCHIVE PROCESSES"
	f.puts "----- Print ISBN: #{Bkmkr::Metadata.pisbn}"
	f.puts test_isbn_status
	f.puts test_dir_status
	f.puts test_input_status
	f.puts test_html_status
end