require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# an array of all occurances of chapters in the manuscript
chapterheads = File.read(Bkmkr::Paths.outputtmp_html).scan(/section data-type="chapter"/)

# Local path vars, css files 
tmp_layout_dir = File.join(Bkmkr::Project.working_dir, "done", Metadata.pisbn, "layout")

pdf_css_file = Metadata.printcss
epub_css_file = Metadata.epubcss

find_pdf_css_file = File.join(Bkmkr::Paths.submitted_images, Metadata.printcss)
find_epub_css_file = File.join(Bkmkr::Paths.submitted_images, Metadata.epubcss)

if File.file?(pdf_css_file)
	FileUtils.cp(pdf_css_file, "#{tmp_layout_dir}/pdf.css")
elsif File.file?(find_pdf_css_file)
	FileUtils.cp(find_pdf_css_file, "#{tmp_layout_dir}/pdf.css")
	FileUtils.rm(find_pdf_css_file)
else
	File.open("#{tmp_layout_dir}/pdf.css", 'w') do |p|
		p.write "/* no print css supplied */"
	end
end

if File.file?(epub_css_file)
	FileUtils.cp(epub_css_file, "#{tmp_layout_dir}/epub.css")
elsif File.file?(find_epub_css_file)
	FileUtils.cp(find_epub_css_file, "#{tmp_layout_dir}/epub.css")
	FileUtils.rm(find_epub_css_file)
else
	File.open("#{tmp_layout_dir}/epub.css", 'w') do |e|
		e.write "/* no epub css supplied */"
	end
end

# TESTING

# css files should exist in project directory
if File.file?("#{tmp_layout_dir}/pdf.css")
	test_pcss_status = "pass: PDF CSS file was added to the project directory"
else
	test_pcss_status = "FAIL: PDF CSS file was added to the project directory"
end

if File.file?("#{tmp_layout_dir}/epub.css")
	test_ecss_status = "pass: EPUB CSS file was added to the project directory"
else
	test_ecss_status = "FAIL: EPUB CSS file was added to the project directory"
end

chapterheadsnum = chapterheads.count

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- CHAPTERHEADS PROCESSES"
	f.puts "----- I found #{chapterheadsnum} chapters in this book."
	f.puts test_pcss_status
	f.puts test_ecss_status
end
