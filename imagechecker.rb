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

# determining print isbn
if spanisbn.length != 0
	pisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+<\/span>\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
else
	pisbn_basestring = File.read("#{html_file}").match(/ISBN\s*.+\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	pisbn = pisbn_basestring.match(/\d+\(.*\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
end

# determining ebook isbn
if spanisbn.length != 0
	eisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>\s*\(e-*book\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
	eisbn = eisbn_basestring.match(/\d+<\/span>\(ebook\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
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

# The location where the images are dropped by the user
imagedir = "#{tmp_dir}\\#{filename}\\images\\"
# The working dir location that images will be moved to (for test 3)
image_dest = "#{working_dir}\\done\\#{pisbn}\\images\\"

# An array listing all the submitted images
images = Dir.entries("#{imagedir}")

#strips spaces from img names in html
text = File.read("#{html_file}")
new_contents = text.gsub(/img src=".*?"/) {|i| i.gsub(/ /, "").sub(/imgsrc/, "img src")}
File.open("#{html_file}", "w") {|file| file.puts new_contents }

# An array of all the image files referenced in the source html file
source = File.read("#{html_file}").scan(/img src=".*?"/)

# An empty array to store the list of any missing images
missing = []
# An empty array to store nospace names of html images existing in submission folder (for test 3)
matched = []

# Checks to see if each image referenced in the html exists in the submission folder
# If no, saves the image file name in the missing array
# If yes, copies the image file to the done/pisbn/images folder, and deletes original
source.each do |m|
	match = m.split("/").pop.gsub(/"/,'')
	if images.include?("#{match}")
		`copy #{imagedir}\\#{match} #{working_dir}\\done\\#{pisbn}\\images\\`
		matched << match
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
	test_missing_img = "FAIL: These image files seem to be missing: #{missing}"
else
	test_missing_img = "pass: There are no missing image files!"
end

images_moved = Dir.entries("#{image_dest}") 
if images_moved.sort == matched.sort
	test_imgs_match_refs = "pass: Images' names in Done folder match references in html"
else
	test_imgs_match_refs = "FAIL: Images' names in Done folder match references in html"
end

# Printing the test results to the log file
File.open("#{log_dir}\\#{filename}.txt", 'a+') do |f|
	f.puts "----- IMAGECHECKER PROCESSES"
	f.puts "I found #{test_img_src} image references in this book"
	f.puts "#{test_missing_img}"
	f.puts "#{test_imgs_match_refs}"
end