require 'rubygems'
require 'doc_raptor'
require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# Local path var(s)
pdftmp_dir = File.join(Bkmkr::Paths.project_tmp_dir_img, "pdftmp")
pdfmaker_dir = File.join(Bkmkr::Paths.core_dir, "pdfmaker")
pdf_tmp_html = File.join(Bkmkr::Paths.project_tmp_dir, "pdf_tmp.html")

# Authentication data is required to use docraptor and 
# to post images and other assets to an ftp for inclusion 
# via docraptor.
DocRaptor.api_key "#{Bkmkr::Keys.docraptor_key}"

# change to DocRaptor 'test' mode when running from staging server
testing_value = "false"
if File.file?("#{Bkmkr::Paths.resource_dir}/staging.txt") then testing_value = "true" end

# create pdf tmp directory
Dir.mkdir(pdftmp_dir)

# Link to print css in the html head
cssfile = File.join(Bkmkr::Project.working_dir, "done", Metadata.pisbn, "layout", "pdf.css")
if File.file?(cssfile)
	embedcss = File.read(cssfile)
else
	embedcss = " "
end

# Link to custom javascript in the html head
if File.file?(Metadata.printjs)
	embedjs = File.read(Metadata.printjs)
else
	embedjs = " "
end

# inserts links to the css and js into the head of the html, fixes images
# Allowing for users to preprocess pdf html if desired
if File.file?(pdf_tmp_html)
	pdf_html = File.read(pdf_tmp_html).gsub(/<\/head>/,"<script>#{embedjs}</script><style>#{embedcss}</style></head>").to_s
else
	pdf_html = File.read(Bkmkr::Paths.outputtmp_html).gsub(/<\/head>/,"<script>#{embedjs}</script><style>#{embedcss}</style></head>").to_s
end

# sends file to docraptor for conversion
FileUtils.cd(Bkmkr::Paths.project_tmp_dir)
File.open("#{Metadata.pisbn}.pdf", "w+b") do |f|
  f.write DocRaptor.create(:document_content => pdf_html,
                           :name             => "#{Metadata.pisbn}.pdf",
                           :document_type    => "pdf",
                           :strict			     => "none",
                           :test             => "#{testing_value}",
	                         :prince_options	 => {
	                           :http_user		 => "#{Bkmkr::Keys.http_username}",
	                           :http_password	 => "#{Bkmkr::Keys.http_password}",
	                           :javascript 		 => "true"
							             }
                       		)
                           
end

# moves rendered pdf to archival dir
FileUtils.mv("#{Metadata.pisbn}.pdf","#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/#{Metadata.pisbn}_POD.pdf")


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

if File.file?("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/#{Metadata.pisbn}_POD.pdf")
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
