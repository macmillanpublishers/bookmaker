input_file = ARGV[0]
filename_split = input_file.split("\\").pop
filename = filename_split.split(".").shift.gsub(/ /, "")
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
project_dir = working_dir_split[0...-3].pop
# determine current working volume
`cd > currvol.txt`
currpath = File.read("currvol.txt")
currvol = currpath.split("\\").shift

# set working dir based on current volume
tmp_dir = "#{currvol}\\bookmaker_tmp"

html_file = "#{tmp_dir}\\#{filename}\\outputtmp.html"
pisbn_basestring = File.read("#{html_file}").scan(/ISBN\s*.+\s*\(hardcover\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
pisbn = pisbn_basestring.scan(/\d+\(hardcover\)/).to_s.gsub(/\(hardcover\)/,"").gsub(/\["/,"").gsub(/"\]/,"")

# an array of all occurances of chapters in the manuscript
chapterheads = File.read("#{html_file}").scan(/section data-type="chapter"/)

# css files
pdf_css_file = "S:\\resources\\bookmaker_scripts\\bookmaker_pdfmaker\\css\\#{project_dir}\\pdf.css"
epub_css_file = "S:\\resources\\bookmaker_scripts\\bookmaker_epubmaker\\css\\#{project_dir}\\epub.css"

if File.file?("#{pdf_css_file}")
	pdf_css = File.read("#{pdf_css_file}")
	if chapterheads.count > 1
		`copy #{pdf_css_file} #{working_dir}\\done\\#{pisbn}\\layout\\pdf.css`
	else
		File.open("#{working_dir}\\done\\#{pisbn}\\layout\\pdf.css", 'w') do |p|
			p.write "#{pdf_css}section[data-type='chapter']>h1{display:none;}"
		end
	end
end

if File.file?("#{epub_css_file}")
	epub_css = File.read("#{epub_css_file}")
	if chapterheads.count > 1
		`copy #{epub_css_file} #{working_dir}\\done\\#{pisbn}\\layout\\epub.css`
	else
		File.open("#{working_dir}\\done\\#{pisbn}\\layout\\epub.css", 'w') do |e|
			e.write "#{epub_css}h1.ChapTitlect{display:none;}"
		end
	end
end

# TESTING

# css files should exist in project directory
if File.file?("#{working_dir}\\done\\#{pisbn}\\layout\\pdf.css")
	test_pcss_status = "pass: PDF CSS file was added to the project directory"
else
	test_pcss_status = "FAIL: PDF CSS file was added to the project directory"
end

if File.file?("#{working_dir}\\done\\#{pisbn}\\layout\\epub.css")
	test_ecss_status = "pass: EPUB CSS file was added to the project directory"
else
	test_ecss_status = "FAIL: EPUB CSS file was added to the project directory"
end

chapterheadsnum = chapterheads.count

# Printing the test results to the log file
File.open("S:\\resources\\logs\\#{filename}.txt", 'a+') do |f|
	f.puts "----- CHAPTERHEADS PROCESSES"
	f.puts "----- I found #{chapterheadsnum} chapters in this book."
	f.puts test_pcss_status
	f.puts test_ecss_status
end
