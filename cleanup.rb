require 'fileutils'

require_relative '../bookmaker/header.rb'


# --------------------HTML FILE DATA START--------------------
# This block creates a variable to point to the 
# converted HTML file, and pulls the isbn data
# out of the HTML file.

# the working html file
html_file = "#{Bkmkr::Paths.outputtmp_html}"

# testing to see if ISBN style exists
spanisbn = File.read("#{html_file}").scan(/spanISBNisbn/)

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
	pisbn = "#{Bkmkr::Project.filename}"
end

if eisbn.length == 0
	eisbn = "#{Bkmkr::Project.filename}"
end
# --------------------HTML FILE DATA END--------------------

# clean up the ftp site if files were uploaded
if File.exists?("#{Bkmkr::Paths.project_tmp_dir_img}/uploaded_image_log.txt") && !File.zero?("#{Bkmkr::Paths.project_tmp_dir_img}/uploaded_image_log.txt")
	`#{Bkmkr::Paths.bookmaker_dir}/bookmaker_ftpupload/imagedelete.bat #{Bkmkr::Paths.done_dir}/#{pisbn}/images`
end

# Delete all the working files and dirs
FileUtils.rm_r(Bkmkr::Paths.project_tmp_dir)
FileUtils.rm(Bkmkr::Project.input_file)
FileUtils.rm(Bkmkr::Paths.alert)

# TESTING

# verify input file is gone
if File.exists?("#{Bkmkr::Project.input_file}")
	test_inputfile_removed = "FAIL: Input file has been deleted from Convert directory"
else
	test_inputfile_removed = "pass: Input file has been deleted from Convert directory"
end

# verify ftp site is clean
if File.exists?("#{Bkmkr::Paths.done_dir}/#{pisbn}/images/clear_ftp_log.txt")
	if File.zero?("#{Bkmkr::Paths.done_dir}/#{pisbn}/images/clear_ftp_log.txt")
		test_ftp_files_removed = "pass: The ftp server directory (bookmakerimg) is clean"
	else
		test_ftp_files_removed = "FAIL: The ftp server directory (bookmakerimg) is clean"
	end
elsif File.exists?("#{Bkmkr::Paths.project_tmp_dir_img}/uploaded_image_log.txt") && !File.zero?("#{Bkmkr::Paths.project_tmp_dir_img}/uploaded_image_log.txt")
	test_ftp_files_removed = "FAIL: The ftp server directory (bookmakerimg) is clean (files were uploaded but not deleted)"
else
	test_ftp_files_removed = "pass: The ftp server directory (bookmakerimg) presumed clean (no images uploaded))"
end

# verify tmp folder for pisbn is gone
if File.exists?("#{Bkmkr::Paths.tmp_dir}/#{filename}")
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