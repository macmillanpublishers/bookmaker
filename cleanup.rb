# --------------------STANDARD HEADER START--------------------
# The bookmkaer scripts require a certain folder structure 
# in order to source in the correct CSS files, logos, 
# and other imprint-specific items. You can read about the 
# required folder structure here:
input_file = ARGV[0]
filename_split = input_file.split("\\").pop
filename = filename_split.split(".").shift.gsub(/ /, "")
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
project_dir = working_dir_split[0...-3].pop
stage_dir = working_dir_split[0...-2].pop
# In Macmillan's environment, these scripts could be 
# running either on the C: volume or on the S: volume 
# of the configured server. This block determines which 
# of those is the current working volume.
`cd > currvol.txt`
currpath = File.read("currvol.txt")
currvol = currpath.split("\\").shift

# --------------------USER CONFIGURED PATHS START--------------------
# These are static paths to folders on your system.
# These paths will need to be updated to reflect your current 
# directory structure.

# set temp working dir based on current volume
tmp_dir = "#{currvol}\\bookmaker_tmp"
# set directory for logging output
log_dir = "S:\\resources\\logs"
# set directory where bookmkaer scripts live
bookmaker_dir = "S:\\resources\\bookmaker_scripts"
# set directory where other resources are installed
# (for example, saxon, zip)
resource_dir = "C:"
# --------------------USER CONFIGURED PATHS END--------------------
# --------------------STANDARD HEADER END--------------------

# --------------------HTML FILE DATA START--------------------
# This block creates a variable to point to the 
# converted HTML file, and pulls the isbn data
# out of the HTML file.

# the working html file
html_file = "#{tmp_dir}\\#{filename}\\outputtmp.html"

# testing to see if ISBN style exists
spanisbn = File.read("#{html_file}").scan(/spanISBNisbn/)
multiple_isbns = File.read("#{html_file}").scan(/spanISBNisbn">\s*.+<\/span>\s*\(((hardcover)|(trade\s*paperback)|(e-*book))\)/)

# determining print isbn
if spanisbn.length != 0 && multiple_isbns.length != 0
	pisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+<\/span>\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
elsif spanisbn.length != 0 && multiple_isbns.length == 0
	pisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+<\/span>/).to_s.gsub(/<\/span>/,"").gsub(/\["/,"").gsub(/"\]/,"")
else
	pisbn_basestring = File.read("#{html_file}").match(/ISBN\s*.+\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+\(.*\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
end

# determining ebook isbn
if spanisbn.length != 0 && multiple_isbns.length != 0
	eisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>\s*\(e-*book\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	eisbn = eisbn_basestring.match(/\d+<\/span>\(ebook\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
elsif spanisbn.length != 0 && multiple_isbns.length == 0
	eisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	eisbn = pisbn_basestring.match(/\d+<\/span>/).to_s.gsub(/<\/span>/,"").gsub(/\["/,"").gsub(/"\]/,"")
else
	eisbn_basestring = File.read("#{html_file}").match(/ISBN\s*.+\s*\(e-*book\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	eisbn = eisbn_basestring.match(/\d+\(ebook\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
end

# just in case no isbn is found
if pisbn.length == 0
	pisbn = "#{filename}"
end

if eisbn.length == 0
	eisbn = "#{filename}"
end
# --------------------HTML FILE DATA END--------------------

# clean up the ftp site if files were uploaded
if File.exists?("#{tmp_dir}\\#{filename}\\images\\uploaded_image_log.txt") && !File.zero?("#{tmp_dir}\\#{filename}\\images\\uploaded_image_log.txt")
	`#{bookmaker_dir}\\bookmaker_ftpupload\\imagedelete.bat #{working_dir}\\done\\#{pisbn}\\images`
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
`del /f /s /q /a #{tmp_dir}\\#{filename}\\images\\pdftmp\\*`
`del /f /s /q /a #{tmp_dir}\\#{filename}\\epubimg\\*`
`rd #{tmp_dir}\\#{filename}\\images\\pdftmp`
`rd #{tmp_dir}\\#{filename}\\images\\`
`rd #{tmp_dir}\\#{filename}\\epubimg\\`
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
	test_inputfile_removed = "pass: Input file has been deleted from Convert directory"
end

# verify ftp site is clean
if File.exists?("#{working_dir}\\done\\#{pisbn}\\images\\clear_ftp_log.txt")
	if File.zero?("#{working_dir}\\done\\#{pisbn}\\images\\clear_ftp_log.txt")
		test_ftp_files_removed = "pass: The ftp server directory (bookmakerimg) is clean"
	else
		test_ftp_files_removed = "FAIL: The ftp server directory (bookmakerimg) is clean"
	end
elsif File.exists?("#{tmp_dir}\\#{filename}\\images\\uploaded_image_log.txt") && !File.zero?("#{tmp_dir}\\#{filename}\\images\\uploaded_image_log.txt")
	test_ftp_files_removed = "FAIL: The ftp server directory (bookmakerimg) is clean (files were uploaded but not deleted)"
else
	test_ftp_files_removed = "pass: The ftp server directory (bookmakerimg) presumed clean (no images uploaded))"
end

# verify tmp folder for pisbn is gone
if File.exists?("#{tmp_dir}\\#{filename}")
	test_tmpdir_removed = "FAIL: Tmp directory has been removed"
else
	test_tmpdir_removed = "pass: Tmp directory has been removed"
end

# Printing the test results to the log file
File.open("#{log_dir}\\#{filename}.txt", 'a+') do |f|
	f.puts "----- CLEANUP PROCESSES"
	f.puts "#{test_inputfile_removed}"
	f.puts "#{test_ftp_files_removed}"	
	f.puts "#{test_tmpdir_removed}"	
end