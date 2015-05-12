require 'fileutils'

require_relative '../bookmaker/header.rb'

# --------------------HTML FILE DATA START--------------------
# This block creates a variable to point to the 
# converted HTML file, and pulls the isbn data
# out of the HTML file.

# the working html file
html_file = Bkmkr::Paths.outputtmp_html

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

# The location where the images are moved to by tmparchive
imagedir = Bkmkr::Paths.project_tmp_dir_img

# The working dir location that images will be moved to (for test 3)
image_dest = File.join(Bkmkr::Project.working_dir, "done", pisbn, "images")

# full path to the image error file
image_error = File.Join(Bkmkr::Project.working_dir, "done", pisbn, "IMAGE_ERROR.txt")

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

# Checks to see if each image referenced in the html exists in the tmp images folder
# If no, saves the image file name in the missing array
# If yes, copies the image file to the done/pisbn/images folder, and deletes original
source.each do |m|
	match = m.split("/").pop.gsub(/"/,'')
	matched_file = File.join(imagedir, match)
	if images.include?("#{match}")
		FileUtils.mv(matched_file, image_dest)
		matched << match
	else
		missing << match
	end
end

# Writes an error text file in the done\pisbn\ folder that lists all missing image files as stored in the missing array
if missing.any?
	File.open(image_error, 'w') do |output|
		output.write "The following images are missing from the submitted_images folder: #{missing}"
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

images_moved = Dir.entries("#{image_dest}").select {|f| !File.directory? f}
images_moved -= %w{clear_ftp_log.txt}
match_check = matched.uniq.sort
if images_moved.sort == match_check
	test_imgs_match_refs = "pass: Images' names in Done folder match references in html"
else
	test_imgs_match_refs = "FAIL: Images' names in Done folder match references in html"
end

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- IMAGECHECKER PROCESSES"
	f.puts "I found #{test_img_src} image references in this book"
	f.puts "#{test_missing_img}"
	f.puts "#{test_imgs_match_refs}"
end