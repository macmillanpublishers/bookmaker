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

# The location where the images are dropped by the user
imagedir = "#{tmp_dir}\\#{filename}\\images\\"

# An array listing all the submitted images
images = Dir.entries("#{imagedir}")

# An array of all the image files referenced in the source html file
source = File.read("#{html_file}").scan(/img src=".*?"/)

# An empty array to store the list of any missing images
missing = []

# Checks to see if each image referenced in the html exists in the submission folder
# If no, saves the image file name in the missing array
# If yes, copies the image file to the done/pisbn/images folder, and deletes original
source.each do |m|
	match = m.split("/").pop.gsub(/"/,'')
	if images.include?("#{match}")
		`copy #{image_dir}\\#{match} #{working_dir}\\done\\#{pisbn}\\images\\`
		`S:\\resources\\bookmaker_scripts\\imageupload.bat #{match}`
	else
		missing << match
	end
end

# Writes an error text file in the done\pisbn\ folder that lists all missing image files as stored in the missing array
if missing.any?
	File.open("#{working_dir}\\done\\#{pisbn}\\IMAGE_ERROR.txt", 'w') do |output|
		output.write "The following images are missing from the images folder: #{missing}"
	end
end

# TESTING

# Count how many images are referenced in the book
test_img_src = source.count

if missing.any?
	test_missing_img = "These image files seem to be missing: #{missing}"
else
	test_missing_img = "There are no missing image files!"
end

# Printing the test results to the log file
File.open("S:\\resources\\logs\\#{filename}.txt", 'a+') do |f|
	f.puts "----- IMAGECHECKER PROCESSES"
	f.puts "----- I found #{test_img_src} image references in this book"
	f.puts "----- #{test_missing_img}"
end