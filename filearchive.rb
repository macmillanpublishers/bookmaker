require '../bookmaker/header.rb'

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

# create the archival directory structure and copy xml and html there
filetype = filename_split.split(".").pop

`md #{working_dir}\\done\\#{pisbn}`
`md #{working_dir}\\done\\#{pisbn}\\images`
`md #{working_dir}\\done\\#{pisbn}\\cover`
`md #{working_dir}\\done\\#{pisbn}\\layout`
`copy "#{input_file}" #{working_dir}\\done\\#{pisbn}\\#{pisbn}_MNU.#{filetype}`
`copy #{html_file} #{working_dir}\\done\\#{pisbn}\\layout\\#{pisbn}.html`

# TESTING

# print isbn should exist AND be 13-digit string of digits
test_pisbn_chars = pisbn.scan(/\d\d\d\d\d\d\d\d\d\d\d\d\d/)
test_pisbn_length = pisbn.split(%r{\s*})

if test_pisbn_length.length == 13 and test_pisbn_chars.length != 0
	test_isbn_status = "pass: print isbn is composed of 13 consecutive digits"
else
	test_isbn_status = "FAIL: print isbn is composed of 13 consecutive digits"
end

# done dir and all subdirs should exist
if File.exist?("#{working_dir}\\done\\#{pisbn}") and File.exist?("#{working_dir}\\done\\#{pisbn}\\images") and File.exist?("#{working_dir}\\done\\#{pisbn}\\cover") and File.exist?("#{working_dir}\\done\\#{pisbn}\\layout")
	test_dir_status = "pass: project directory and all sub-directories were successfully created"
else
	test_dir_status = "FAIL: project directory and all sub-directories were successfully created"
end

# input file should exist in done dir 
if File.file?("#{working_dir}\\done\\#{pisbn}\\#{pisbn}_MNU.#{filetype}")
	test_input_status = "pass: original file preserved in project directory"
else
	test_input_status = "FAIL: original file preserved in project directory"
end

# html file should exist in done dir 
if File.file?("#{working_dir}\\done\\#{pisbn}\\layout\\#{pisbn}.html")
	test_html_status = "pass: converted html file preserved in project directory"
else
	test_html_status = "FAIL: converted html file preserved in project directory"
end

# Printing the test results to the log file
File.open("#{log_dir}\\#{filename}.txt", 'a+') do |f|
	f.puts "----- FILEARCHIVE PROCESSES"
	f.puts "----- Print ISBN: #{pisbn}"
	f.puts test_isbn_status
	f.puts test_dir_status
	f.puts test_input_status
	f.puts test_html_status
end