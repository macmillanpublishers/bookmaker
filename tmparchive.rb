require_relative '..\\bookmaker\\header.rb'

filename_split_nospaces = Bkmkr::Project.filename_split.gsub(/ /, "")

# For TEST purposes
test_images_before = Dir.entries("#{Bkmkr::Project.working_dir}\\submitted_images\\")

# Rename and move input files to tmp folder to eliminate possibility of overwriting
`md #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}`
`md #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\images`
`move #{Bkmkr::Project.working_dir}\\submitted_images\\* #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\images\\`
`copy "#{Bkmkr::Project.input_file}" #{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\#{filename_split_nospaces}`

# Add a notice to the conversion dir warning that the process is in use
File.open("#{Bkmkr::Project.working_dir}\\IN_USE_PLEASE_WAIT.txt", 'w') do |output|
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
if File.exist?("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}") and File.exist?("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\images")
	test_dir_status = "pass: temp directory and all sub-directories were successfully created"
else
	test_dir_status = "FAIL: temp directory and all sub-directories were successfully created"
end

# submitted images dir should be clean
test_images_after = Dir.entries("#{Bkmkr::Project.working_dir}\\submitted_images\\")

if test_images_after.length == 2
	test_imagedir_status = "pass: submitted images directory has been emptied"
else
	test_imagedir_status = "FAIL: submitted images directory has been emptied"
end

# IF submitted images dir was not clean at beginning, tmpdir images dir should also not be clean at end
test_tmp_images = Dir.entries("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\images\\")

if test_images_before.length == test_tmp_images.length
	test_tmpimgdir_status = "pass: all submitted images have been copied to temp directory"
else
	test_tmpimgdir_status = "FAIL: all submitted images have been copied to temp directory"
end

# input file should exist in tmp dir
if File.file?("#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\#{filename_split_nospaces}")
	test_input_status = "pass: original file preserved in project directory"
else
	test_input_status = "FAIL: original file preserved in project directory"
end

# Write test results
File.open("#{Bkmkr::Dir.log_dir}\\#{Bkmkr::Project.filename}.txt", 'a+') do |f|
	f.puts "-----"
	f.puts Time.now
	f.puts "----- TMPARCHIVE PROCESSES"
	f.puts test_fname_status
	f.puts test_dir_status
	f.puts test_imagedir_status
	f.puts test_tmpimgdir_status
	f.puts test_input_status
end