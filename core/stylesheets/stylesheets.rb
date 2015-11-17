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

oneoffcss_p_new = File.join(Bkmkr::Paths.submitted_images, "oneoff_pdf.css")
oneoffcss_p_pickup = File.join(tmp_layout_dir, "oneoff_pdf.css")

if File.file?(oneoffcss_p_new)
	FileUtils.mv(oneoffcss_p_new, oneoffcss_p_pickup)
	oneoffcss = File.read(oneoffcss_p_pickup)
	File.open("#{tmp_layout_dir}/pdf.css", 'a+') do |o|
		o.write oneoffcss
	end
elsif File.file?(oneoffcss_p_pickup)
	oneoffcss = File.read(oneoffcss_p_pickup)
	File.open("#{tmp_layout_dir}/pdf.css", 'a+') do |o|
		o.write oneoffcss
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

oneoffcss_e_new = File.join(Bkmkr::Paths.submitted_images, "oneoff_epub.css")
oneoffcss_e_pickup = File.join(tmp_layout_dir, "oneoff_epub.css")

if File.file?(oneoffcss_e_new)
	FileUtils.mv(oneoffcss_e_new, oneoffcss_e_pickup)
	oneoffcss = File.read(oneoffcss_e_pickup)
	File.open("#{tmp_layout_dir}/epub.css", 'a+') do |o|
		o.write oneoffcss
	end
elsif File.file?(oneoffcss_e_pickup)
	oneoffcss = File.read(oneoffcss_e_pickup)
	File.open("#{tmp_layout_dir}/epub.css", 'a+') do |o|
		o.write oneoffcss
	end
end

# LOGGING

chapterheadsnum = chapterheads.count

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- STYLESHEETS PROCESSES"
	f.puts "----- I found #{chapterheadsnum} chapters in this book."
	f.puts "finished stylesheets"
end
