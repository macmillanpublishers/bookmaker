input_file = ARGV[0]
filename_split = input_file.split("\\").pop
filename = filename_split.split(".").shift.gsub(/ /, "")
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
# determine current working volume
`cd > currvol.txt`
currpath = File.read("currvol.txt")
currvol = currpath.split("\\").shift

# set working dir based on current volume
tmp_dir = "#{currvol}\\bookmaker_tmp"

html_file = "#{tmp_dir}\\#{filename}\\outputtmp.html"

# testing to see if ISBN style exists
spanisbn = File.read("#{html_file}").scan(/spanISBNisbn/)

# determining print isbn
if spanisbn.length != 0
	pisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+<\/span>\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
else
	pisbn_basestring = File.read("#{html_file}").match(/ISBN\s*.+\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+\(.*\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
end

# just in case no isbn is found
if pisbn.length == 0
	pisbn = "#{filename}"
end

# clean up the ftp site if files were uploaded
if File.exists?("#{tmp_dir}\\#{filename}\\images\\uploaded_image_log.txt") && !File.zero?("#{tmp_dir}\\#{filename}\\images\\uploaded_image_log.txt")
	`S:\\resources\\bookmaker_scripts\\bookmaker_ftpupload\\imagedelete.bat #{working_dir}\\done\\#{pisbn}\\images`
end

# Delete all the working files and dirs
`del /f /s /q /a #{tmp_dir}\\#{filename}\\OEBPS\\*`
`del /f /s /q /a #{tmp_dir}\\#{filename}\\OEBPS\\images\\*`
`rd #{tmp_dir}\\#{filename}\\OEBPS\\images\\`
`rd #{tmp_dir}\\#{filename}\\OEBPS\\`
`del /f /s /q /a #{tmp_dir}\\#{filename}\\META-INF\\*`
`rd #{tmp_dir}\\#{filename}\\META-INF\\`
`del /f /s /q /a #{tmp_dir}\\#{filename}\\mimetype`
`del /f /s /q /a #{tmp_dir}\\#{filename}\\images\\*`
`rd #{tmp_dir}\\#{filename}\\images\\`
`del /f /s /q /a #{tmp_dir}\\#{filename}\\*`
`rd #{tmp_dir}\\#{filename}\\`
`del /f /s /q /a "#{input_file}"`
`del /f /s /q /a #{working_dir}\\IN_USE_PLEASE_WAIT.txt`
`cd #{currvol}`
`del currvol.txt`


# TESTING

# verify input file is gone
if File.exists?("#{input_file}")
	test_inputfile_removed = "FAIL: Input file has been deleted from Convert directory"
else
	test_inputfile_removed = "PASS: Input file has been deleted from Convert directory"
end

# verify ftp site is clean
if File.exists?("#{working_dir}\\done\\#{pisbn}\\images\\clear_ftp_log.txt")
	if File.zero?("#{working_dir}\\done\\#{pisbn}\\images\\clear_ftp_log.txt")
		test_ftp_files_removed = "PASS: The ftp server directory (bookmakerimg) is clean"
	else
		test_ftp_files_removed = "FAIL: The ftp server directory (bookmakerimg) is clean"
	end
else File.exists?("#{tmp_dir}\\#{filename}\\images\\uploaded_image_log.txt") && !File.zero?("#{tmp_dir}\\#{filename}\\images\\uploaded_image_log.txt")
	if 
		test_ftp_files_removed = "FAIL: The ftp server directory (bookmakerimg) is clean (files were uploaded but not deleted)"
	else
		test_ftp_files_removed = "PASS: The ftp server directory (bookmakerimg) presumed clean (no images uploaded))"
	end
end

# verify tmp folder for pisbn is gone
if File.exists?("#{tmp_dir}\\#{filename}")
	test_tmpdir_removed = "FAIL: Tmp directory has been removed"
else
	test_tmpdir_removed = "PASS: Tmp directory has been removed"
end

# Printing the test results to the log file
File.open("S:\\resources\\logs\\#{filename}.txt", 'a+') do |f|
	f.puts "----- CLEANUP PROCESSES"
	f.puts "#{test_inputfile_removed}"
	f.puts "#{test_ftp_files_removed}"	
	f.puts "#{test_tmpdir_removed}"	
end