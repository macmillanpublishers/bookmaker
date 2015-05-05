require 'fileutils'

require_relative '../bookmaker/header.rb'

# p = Bkmkr::Project.new(ARGV[0])

# puts p.working_dir

puts Bkmkr::Project.input_file
puts Bkmkr::Project.filename
puts Bkmkr::Project.filename_split
puts Bkmkr::Project.filename_normalized
puts Bkmkr::Project.working_dir
puts Bkmkr::Project.working_dir_split
puts Bkmkr::Project.project_dir
puts Bkmkr::Project.stage_dir
puts Bkmkr::Paths.currpath
puts Bkmkr::Paths.currvol
puts Bkmkr::Paths.tmp_dir
puts Bkmkr::Paths.log_dir
puts Bkmkr::Paths.bookmaker_dir
puts Bkmkr::Paths.resource_dir
puts Bkmkr::Paths.submitted_images
puts Bkmkr::Paths.project_tmp_dir
puts Bkmkr::Paths.project_tmp_dir_img
puts Bkmkr::Paths.project_tmp_file
puts Bkmkr::Paths.alert
puts Bkmkr::Paths.log_file

# For TEST purposes
test_images_before = Dir.entries("#{Bkmkr::Paths.submitted_images}")

# Local path variables
all_submitted_images = File.join(Bkmkr::Paths.submitted_images, "*")

# Rename and move input files to tmp folder to eliminate possibility of overwriting
Dir.mkdir(Bkmkr::Paths.project_tmp_dir)
Dir.mkdir(Bkmkr::Paths.project_tmp_dir_img)
FileUtils.mv(Dir.glob('#{all_submitted_images}'), '#{Bkmkr::Paths.project_tmp_dir_img}')
FileUtils.cp('#{Bkmkr::Project.input_file}','#{Bkmkr::Paths.project_tmp_file}')

# Add a notice to the conversion dir warning that the process is in use
File.open("#{Bkmkr::Paths.alert}", 'w') do |output|
	output.write "The conversion processor is currently running. Please do not submit any new files or images until the process completes."
end

# TESTING

# Filename should not be null
test_fname = Bkmkr::Project.filename.split(%r{\s*})

if test_fname.length != 0
	test_fname_status = "pass: original filename is not null"
else
	test_fname_status = "FAIL: original filename is not null"
end

# tmpdir should exist
if File.exist?("#{Bkmkr::Paths.project_tmp_dir}") and File.exist?("#{Bkmkr::Paths.project_tmp_dir_img}")
	test_dir_status = "pass: temp directory and all sub-directories were successfully created"
else
	test_dir_status = "FAIL: temp directory and all sub-directories were successfully created"
end

# submitted images dir should be clean
test_images_after = Dir.entries("#{Bkmkr::Paths.submitted_images}")

if test_images_after.length == 2
	test_imagedir_status = "pass: submitted images directory has been emptied"
else
	test_imagedir_status = "FAIL: submitted images directory has been emptied"
end

# IF submitted images dir was not clean at beginning, tmpdir images dir should also not be clean at end
test_tmp_images = Dir.entries("#{Bkmkr::Paths.project_tmp_dir_img}")

if test_images_before.length == test_tmp_images.length
	test_tmpimgdir_status = "pass: all submitted images have been copied to temp directory"
else
	test_tmpimgdir_status = "FAIL: all submitted images have been copied to temp directory"
end

# input file should exist in tmp dir
if File.file?("#{Bkmkr::Paths.project_tmp_file}")
	test_input_status = "pass: original file preserved in project directory"
else
	test_input_status = "FAIL: original file preserved in project directory"
end

# Write test results
File.open("#{Bkmkr::Paths.log_file}", 'a+') do |f|
	f.puts "-----"
	f.puts Time.now
	f.puts "----- TMPARCHIVE PROCESSES"
	f.puts test_fname_status
	f.puts test_dir_status
	f.puts test_imagedir_status
	f.puts test_tmpimgdir_status
	f.puts test_input_status
end