require_relative '..\\bookmaker\\header.rb'

# --------------------HTML FILE DATA START--------------------
# This block creates a variable to point to the 
# converted HTML file, and pulls the isbn data
# out of the HTML file.

# the working html file
html_file = "#{Bkmkr::Dir.tmp_dir}\\#{Bkmkr::Project.filename}\\outputtmp.html"

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

# an array of all occurances of chapters in the manuscript
chapterheads = File.read("#{html_file}").scan(/section data-type="chapter"/)

# css files
pdf_css_file = "#{Bkmkr::Dir.bookmaker_dir}\\bookmaker_pdfmaker\\css\\#{Bkmkr::Project.project_dir}\\pdf.css"

if File.file?("#{Bkmkr::Dir.bookmaker_dir}\\bookmaker_epubmaker\\css\\#{Bkmkr::Project.project_dir}\\epub.css")
	epub_css_file = "#{Bkmkr::Dir.bookmaker_dir}\\bookmaker_epubmaker\\css\\#{Bkmkr::Project.project_dir}\\epub.css"
# elsif Bkmkr::Project.project_dir.include? "egalley" or Bkmkr::Project.project_dir.include? "first_pass"
# 	epub_css_file = "S:\\resources\\bookmaker_scripts\\bookmaker_epubmaker\\css\\egalley_SMP\\epub.css"
else
 	epub_css_file = "#{Bkmkr::Dir.bookmaker_dir}\\bookmaker_epubmaker\\css\\generic\\epub.css"
end

if File.file?("#{pdf_css_file}")
	pdf_css = File.read("#{pdf_css_file}")
	if chapterheads.count > 1
		`copy #{pdf_css_file} #{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\layout\\pdf.css`
	else
		File.open("#{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\layout\\pdf.css", 'w') do |p|
			p.write "#{pdf_css}section[data-type='chapter']>h1{display:none;}"
		end
	end
end

if File.file?("#{epub_css_file}")
	epub_css = File.read("#{epub_css_file}")
	if chapterheads.count > 1
		`copy #{epub_css_file} #{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\layout\\epub.css`
	else
		File.open("#{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\layout\\epub.css", 'w') do |e|
			e.write "#{epub_css}h1.ChapTitlect{display:none;}"
		end
	end
end

# TESTING

# css files should exist in project directory
if File.file?("#{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\layout\\pdf.css")
	test_pcss_status = "pass: PDF CSS file was added to the project directory"
else
	test_pcss_status = "FAIL: PDF CSS file was added to the project directory"
end

if File.file?("#{Bkmkr::Project.working_dir}\\done\\#{pisbn}\\layout\\epub.css")
	test_ecss_status = "pass: EPUB CSS file was added to the project directory"
else
	test_ecss_status = "FAIL: EPUB CSS file was added to the project directory"
end

chapterheadsnum = chapterheads.count

# Printing the test results to the log file
File.open("#{Bkmkr::Dir.log_dir}\\#{Bkmkr::Project.filename}.txt", 'a+') do |f|
	f.puts "----- CHAPTERHEADS PROCESSES"
	f.puts "----- I found #{chapterheadsnum} chapters in this book."
	f.puts test_pcss_status
	f.puts test_ecss_status
end
