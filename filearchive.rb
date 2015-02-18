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
	pisbn_basestring = File.read("#{html_file}").scan(/spanISBNisbn">\s*.+<\/span>\s*\((hardcover|trade paperback)\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	puts pisbn_basestring
	pisbn = pisbn_basestring.scan(/\d+<\/span>\((hardcover|trade paperback)\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
else
	pisbn_basestring = File.read("#{html_file}").scan(/ISBN\s*.+\s*\((hardcover|trade paperback)\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	puts pisbn_basestring
	pisbn = pisbn_basestring.scan(/\d+\((hardcover|trade paperback)\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
end

puts pisbn

# create the archival directory structure and copy xml and html there
`md #{working_dir}\\done\\#{pisbn}`
`md #{working_dir}\\done\\#{pisbn}\\images`
`md #{working_dir}\\done\\#{pisbn}\\cover`
`md #{working_dir}\\done\\#{pisbn}\\layout`
`copy #{input_file} #{working_dir}\\done\\#{pisbn}\\`
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
if File.file?("#{working_dir}\\done\\#{pisbn}\\#{filename}.xml")
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
File.open("S:\\resources\\logs\\#{filename}.txt", 'a+') do |f|
	f.puts "----- FILEARCHIVE PROCESSES"
	f.puts "----- Print ISBN: #{pisbn}"
	f.puts test_isbn_status
	f.puts test_dir_status
	f.puts test_input_status
	f.puts test_html_status
end