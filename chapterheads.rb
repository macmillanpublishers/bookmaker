require 'fileutils'

require_relative '../bookmaker/header.rb'
require_relative '../bookmaker/metadata.rb'

# an array of all occurances of chapters in the manuscript
chapterheads = File.read(Bkmkr::Paths.outputtmp_html).scan(/section data-type="chapter"/)

# Local path vars, css files 
tmp_layout_dir = File.join(Bkmkr::Project.working_dir, "done", Metadata.pisbn, "layout")
epub_css_dir = File.join(Bkmkr::Paths.bookmaker_dir, "bookmaker_epubmaker", "css")
pdf_css_file = "#{Bkmkr::Paths.bookmaker_dir}/bookmaker_pdfmaker/css/#{Bkmkr::Project.project_dir}/pdf.css"

if File.file?("#{epub_css_dir}/#{Bkmkr::Project.project_dir}/epub.css")
	epub_css_file = "#{epub_css_dir}/#{Bkmkr::Project.project_dir}/epub.css"
# elsif Bkmkr::Project.project_dir.include? "egalley" or Bkmkr::Project.project_dir.include? "first_pass"
# 	epub_css_file = "S:\\resources\\bookmaker_scripts\\bookmaker_epubmaker\\css\\egalley_SMP\\epub.css"
else
 	epub_css_file = "#{epub_css_dir}/generic/epub.css"
end

if File.file?(pdf_css_file)
	pdf_css = File.read(pdf_css_file)
	if chapterheads.count > 1
		FileUtils.cp(pdf_css_file, "#{tmp_layout_dir}/pdf.css")
	else
		File.open("#{tmp_layout_dir}/pdf.css", 'w') do |p|
			p.write "#{pdf_css}section[data-type='chapter']>h1{display:none;}"
		end
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
