require 'rubygems'
require 'doc_raptor'
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

# Local path var(s)
pdftmp_dir = File.join(Bkmkr::Paths.project_tmp_dir_img, "pdftmp")
pdfmaker_dir = File.join(Bkmkr::Paths.bookmaker_dir, "bookmaker_pdfmaker")

# Authentication data is required to use docraptor and 
# to post images and other assets to the ftp for inclusion 
# via docraptor. This auth data should be housed in 
# separate files, as laid out in the following block.
docraptor_key = File.read("#{Bkmkr::Paths.bookmaker_dir}/bookmaker_authkeys/api_key.txt")
ftp_uname = File.read("#{Bkmkr::Paths.bookmaker_dir}/bookmaker_authkeys/ftp_username.txt")
ftp_pass = File.read("#{Bkmkr::Paths.bookmaker_dir}/bookmaker_authkeys/ftp_pass.txt")
ftp_dir = "http://www.macmillan.tools.vhost.zerolag.com/bookmaker/bookmakerimg"

DocRaptor.api_key "#{docraptor_key}"

# change to DocRaptor 'test' mode when running from staging server
testing_value = "false"
if File.file?("#{Bkmkr::Paths.resource_dir}/staging.txt") then testing_value = "true" end

# create pdf tmp directory
Dir.mkdir(pdftmp_dir)

#if any images are in 'done' dir, grayscale and upload them to macmillan.tools site
images = Dir.entries("#{Bkmkr::Paths.project_tmp_dir_img}").select {|f| !File.directory? f}
image_count = images.count
if image_count > 0
	#using this model for Fileutils.cp to select all files in a dir (* won't work):  FileUtils.cp Dir["#{dir1}/*"].select {|f| test ?f, f}, "#{dir2}"
	FileUtils.cp Dir["#{Bkmkr::Paths.project_tmp_dir_img}/*"].select {|f| test ?f, f}, pdftmp_dir
	pdfimages = Dir.entries("#{Bkmkr::Paths.project_tmp_dir_img}/pdftmp").select { |f| !File.directory? f }
	pdfimages.each do |i|
		if i.include?("fullpage")
			#convert command for ImageMagick should work the same on any platform
			pdfimage = File.join(pdftmp_dir, "#{i}")
			`convert "#{pdfimage}" -colorspace gray "#{pdfimage}"`
		elsif i.include?("_FC") or i.include?(".txt") or i.include?(".css") or i.include?(".js")
			FileUtils.rm("#{pdfimage}")
		else
			myres = `identify -format "%y" "#{pdfimage}"`
			myres = myres.to_f
			myheight = `identify -format "%h" "#{pdfimage}"`
			myheight = myheight.to_f
			myheightininches = ((myheight / myres) * 72.0)
			mywidth = `identify -format "%h" "#{pdfimage}"`
			mywidth = mywidth.to_f
			mywidthininches = ((mywidth / myres) * 72.0)
			if mywidthininches > 3.5 or myheightininches > 5.5 then
				targetheight = 5.5 * myres
				targetwidth = 3.5 * myres
				`convert "#{pdfimage}" -resize "#{targetwidth}x#{targetheight}>" "#{pdfimage}"`
			end
			myheight = `identify -format "%h" "#{pdfimage}"`
			myheight = myheight.to_f
			myheightininches = ((myheight / myres) * 72.0)
			mymultiple = ((myheight / myres) * 72.0) / 16.0
			if mymultiple <= 1
				`convert "#{pdfimage}" -colorspace gray "#{pdfimage}"`
			else 
				newheight = ((mymultiple.floor * 16.0) / 72.0) * myres
				`convert "#{pdfimage}" -resize "x#{newheight}" -colorspace gray "#{pdfimage}"`
			end
		end
	end

end

# copy assets to tmp upload dir and upload to ftp
FileUtils.cp Dir["#{pdfmaker_dir}/css/#{Bkmkr::Project.project_dir}/*"].select {|f| test ?f, f}, pdftmp_dir
FileUtils.cp Dir["#{pdfmaker_dir}/images/#{Bkmkr::Project.project_dir}/*"].select {|f| test ?f, f}, pdftmp_dir
FileUtils.cp Dir["#{pdfmaker_dir}/scripts/#{Bkmkr::Project.project_dir}/*"].select {|f| test ?f, f}, pdftmp_dir		
`#{Bkmkr::Paths.bookmaker_dir}\\bookmaker_ftpupload\\imageupload.bat #{Bkmkr::Paths.tmp_dir}\\#{Bkmkr::Project.filename}\\images\\pdftmp #{Bkmkr::Paths.tmp_dir}\\#{Bkmkr::Project.filename}\\images`

# Link to custom javascript in the html head
if File.file?("#{pdfmaker_dir}/scripts/#{Bkmkr::Project.project_dir}/pdf.js")
	pdfjs = File.read("#{pdfmaker_dir}/scripts/#{Bkmkr::Project.project_dir}/pdf.js")
	jsfile = "<script src='#{ftp_dir}/pdf.js'></script>"
else
	jsfile = ""
end

# inserts links to the css and js into the head of the html, fixes images
pdf_html = File.read("#{html_file}").gsub(/<\/head>/,"#{jsfile}<link rel=\"stylesheet\" type=\"text/css\" href=\"#{ftp_dir}/pdf.css\" /></head>").gsub(/src="images\//,"src=\"#{ftp_dir}/").gsub(/\. \. \./,"<span class=\"bookmakerkeeptogetherkt\">\. \. \.</span>").to_s

# sends file to docraptor for conversion
FileUtils.cd(Bkmkr::Paths.project_tmp_dir)
File.open("#{pisbn}.pdf", "w+b") do |f|
  f.write DocRaptor.create(:document_content => pdf_html,
                           :name             => "#{pisbn}.pdf",
                           :document_type    => "pdf",
                           :strict			     => "none",
                           :test             => "#{testing_value}",
	                         :prince_options	 => {
	                           :http_user		 => "#{ftp_uname}",
	                           :http_password	 => "#{ftp_pass}",
	                           :javascript 		 => "true"
							             }
                       		)
                           
end

# moves rendered pdf to archival dir
FileUtils.mv("#{pisbn}.pdf","#{Bkmkr::Paths.done_dir}/#{pisbn}/#{pisbn}_POD.pdf")


# TESTING

# count, report images in file
if image_count > 0

	# test if sites are up/logins work?

	# verify files were uploaded, and match image array
    upload_report = []
    File.read("#{Bkmkr::Paths.project_tmp_dir_img}/uploaded_image_log.txt").each_line {|line|
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

if File.file?("#{Bkmkr::Paths.done_dir}/#{pisbn}/#{pisbn}_POD.pdf")
	test_pdf_created = "pass: PDF file exists in DONE directory"
else
	test_pdf_created = "FAIL: PDF file exists in DONE directory"
end

# is there custom javascript?

if File.file?("#{pdfmaker_dir}/scripts/#{Bkmkr::Project.project_dir}/pdf.js")
	test_custom_js = "#{pdfmaker_dir}/scripts/#{Bkmkr::Project.project_dir}/pdf.js"
else
	test_custom_js = "none"
end

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- PDFMAKER PROCESSES"
	f.puts "----- I found #{image_count} images to be uploaded"
	f.puts "----- I found #{upload_count} files uploaded"
	f.puts "----- I found the following custom javascript: #{test_custom_js}"
	f.puts "#{test_image_array_compare}"
	f.puts "#{test_pdf_created}"	
end
