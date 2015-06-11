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
unless File.exist?(pdftmp_dir)
	Dir.mkdir(pdftmp_dir)
end

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

#temporary, for testing
docpdf = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "layout", "docraptor.html")
File.open(docpdf, "w") {|file| file.puts pdf_html}


# TESTING

# verify pdf was produced

if File.file?("#{Bkmkr::Paths.done_dir}/#{Metadata.pisbn}/#{Metadata.pisbn}_POD.pdf")
	test_pdf_created = "pass: PDF file exists in DONE directory"
else
	test_pdf_created = "FAIL: PDF file exists in DONE directory"
end

# is there custom javascript?

if File.file?(Metadata.printjs)
	test_custom_js = Metadata.printjs
else
	test_custom_js = "none"
end

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- PDFMAKER PROCESSES"
	f.puts "----- I found the following custom javascript: #{test_custom_js}"
	f.puts "#{test_pdf_created}"	
end
