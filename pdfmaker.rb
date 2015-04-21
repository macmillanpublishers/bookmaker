require 'rubygems'
require 'doc_raptor'

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

# Authentication data is required to use docraptor and 
# to post images and other assets to the ftp for inclusion 
# via docraptor. This auth data should be housed in 
# separate files, as laid out in the following block.
docraptor_key = File.read("#{bookmaker_dir}\\bookmaker_authkeys\\api_key.txt")
ftp_uname = File.read("#{bookmaker_dir}\\bookmaker_authkeys\\ftp_username.txt")
ftp_pass = File.read("#{bookmaker_dir}\\bookmaker_authkeys\\ftp_pass.txt")

DocRaptor.api_key "#{docraptor_key}"

#if any images are in 'done' dir, grayscale and upload them to macmillan.tools site
images = Dir.entries("#{working_dir}\\done\\#{pisbn}\\images\\").select {|f| !File.directory? f}
image_count = images.count
if image_count > 0
	`mkdir #{tmp_dir}\\#{filename}\\images\\pdftmp\\`
	`copy #{tmp_dir}\\#{filename}\\images\\* #{tmp_dir}\\#{filename}\\images\\pdftmp\\`
	pdfimages = Dir.entries("#{tmp_dir}\\#{filename}\\images\\pdftmp\\").select { |f| !File.directory? f }
	pdfimages.each do |i|
		if i.include?("fullpage")
			`convert #{tmp_dir}\\#{filename}\\images\\pdftmp\\#{i} -colorspace gray #{tmp_dir}\\#{filename}\\images\\pdftmp\\#{i}`
		elsif i.include?("_FC") or i.include?(".txt")
			`del #{tmp_dir}\\#{filename}\\images\\pdftmp\\#{i}`
		else
			puts i
			`convert #{tmp_dir}\\#{filename}\\images\\pdftmp\\#{i} -resize "360x576>" #{tmp_dir}\\#{filename}\\images\\pdftmp\\#{i}`
			myheight = `identify -format "%h" #{tmp_dir}\\#{filename}\\images\\pdftmp\\#{i}`
			myres = `identify -format "%y" #{tmp_dir}\\#{filename}\\images\\pdftmp\\#{i}`
			myheight = myheight.to_f
			puts myheight
			myres = myres.to_f
			puts myres
			mymultiple = ((myheight / myres) * 72.0) / 16.0
			puts mymultiple
			newheight = ((mymultiple.floor * 16.0) / 72.0) * myres
			puts newheight
			`convert #{tmp_dir}\\#{filename}\\images\\pdftmp\\#{i} -resize "x#{newheight}" -colorspace gray #{tmp_dir}\\#{filename}\\images\\pdftmp\\#{i}`
		end
	end
	`copy #{bookmaker_dir}\\bookmaker_pdfmaker\\css\\torDOTcom\\orn.jpg #{tmp_dir}\\#{filename}\\images\\pdftmp\\orn.jpg`
	`copy #{bookmaker_dir}\\bookmaker_pdfmaker\\css\\torDOTcom\\titlepage-rule.jpg #{tmp_dir}\\#{filename}\\images\\pdftmp\\titlepage-rule.jpg`
	`copy #{bookmaker_dir}\\bookmaker_pdfmaker\\images\\torDOTcom\\logo.jpg #{tmp_dir}\\#{filename}\\images\\pdftmp\\logo.jpg`
	`#{bookmaker_dir}\\bookmaker_ftpupload\\imageupload.bat #{tmp_dir}\\#{filename}\\images\\pdftmp #{tmp_dir}\\#{filename}\\images`
end

# pdf css to be added to the file that will be sent to docraptor
css_file = File.read("#{working_dir}\\done\\#{pisbn}\\layout\\pdf.css").to_s

# inserts the css into the head of the html, fixes images
pdf_html = File.read("#{html_file}").gsub(/<\/head>/,"<style>#{css_file}</style></head>").gsub(/src="images\//,"src=\"http://www.macmillan.tools.vhost.zerolag.com/bookmaker/bookmakerimg/").gsub(/\. \. \./,"<span class=\"bookmakerkeeptogetherkt\">\. \. \.</span>").to_s

# sends file to docraptor for conversion
# currently running in test mode; remove test when css is finalized
`chdir #{tmp_dir}\\#{filename}`
File.open("#{pisbn}.pdf", "w+b") do |f|
  f.write DocRaptor.create(:document_content => pdf_html,
                           :name             => "#{pisbn}.pdf",
                           :document_type    => "pdf",
                           :strict			     => "none",
                           :test             => true,
	                         :prince_options	 => {
	                           :http_user		   => "#{ftp_uname}",
	                           :http_password	 => "#{ftp_pass}"
							             }
                       		)
                           
end

# moves rendered pdf to archival dir
`move #{pisbn}.pdf #{working_dir}\\done\\#{pisbn}\\#{pisbn}_POD.pdf`


# TESTING

# count, report images in file
if image_count > 0

	# test if sites are up/logins work?

	# verify files were uploaded, and match image array
    upload_report = []
    File.read("#{tmp_dir}\\#{filename}\\images\\uploaded_image_log.txt").each_line {|line|
          line_b = line.gsub(/\n$/, "")
          upload_report.push line_b}
 	upload_count = upload_report.count
	
	if upload_report.sort == images.sort
		test_image_array_compare = "pass: Images in Done dir match images uploaded to ftp"
	else
		test_image_array_compare = "FAIL: Images in Done dir match images uploaded to ftp"
	end
	
else
	upload_count = 0
	test_image_array_compare = "pass: There are no missing image files"
end

# verify pdf was produced

if File.file?("#{working_dir}\\done\\#{pisbn}\\#{pisbn}_POD.pdf")
	test_pdf_created = "pass: PDF file exists in DONE directory"
else
	test_pdf_created = "FAIL: PDF file exists in DONE directory"
end

# Printing the test results to the log file
File.open("#{log_dir}\\#{filename}.txt", 'a+') do |f|
	f.puts "----- PDFMAKER PROCESSES"
	f.puts "----- I found #{image_count} images to be uploaded"
	f.puts "----- I found #{upload_count} files uploaded"
	f.puts "#{test_image_array_compare}"
	f.puts "#{test_pdf_created}"	
end
