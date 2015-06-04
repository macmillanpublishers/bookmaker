require 'fileutils'

require_relative '../bookmaker/header.rb'
require_relative '../bookmaker/metadata.rb'

# an array of all occurances of chapters in the manuscript
chapterheads = File.read(Bkmkr::Paths.outputtmp_html).scan(/section data-type="chapter"/)

# Local path vars, css files 
tmp_layout_dir = File.join(Bkmkr::Project.working_dir, "done", Metadata.pisbn, "layout")

pdf_css_file = Metadata.printcss
epub_css_file = Metadata.epubcss

if File.file?(pdf_css_file)
	pdf_css = File.read(pdf_css_file)
	if chapterheads.count > 1
		FileUtils.cp(pdf_css_file, "#{tmp_layout_dir}/pdf.css")
	else
		File.open("#{tmp_layout_dir}/pdf.css", 'w') do |p|
			p.write "#{pdf_css}section[data-type='chapter']>h1{display:none;}"
		end
	end
else
	File.open("#{tmp_layout_dir}/pdf.css", 'w') do |p|
		p.write "/* no print css supplied */"
	end
end

if File.file?(epub_css_file)
	epub_css = File.read(epub_css_file)
	if chapterheads.count > 1
		FileUtils.cp(epub_css_file, "#{tmp_layout_dir}/epub.css")
	else
		File.open("#{tmp_layout_dir}/epub.css", 'w') do |e|
			e.write "#{epub_css}h1.ChapTitlect{display:none;}"
		end
	end
else
	File.open("#{tmp_layout_dir}/epub.css", 'w') do |p|
		p.write "/* no epub css supplied */"
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
