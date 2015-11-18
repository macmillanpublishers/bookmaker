require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

def evalImports(file, path)
	filecontents = File.read(file)
	thispath = file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-1].join(File::SEPARATOR)
	if filecontents.include? "@import"
		imports = filecontents.scan(/@import.*?;{1}/)
		imports.each do |i|
			importarr = i.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))
			importfile = i.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).pop
			if importarr.length >= 2 and importarr.include? ".."
				searchdir = thispath.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].join(File::SEPARATOR)
				importpath = File.join(searchdir, importfile)
			elsif importarr.length >= 2 and importarr.include? "."
				importpath = File.join(thispath, importfile)
			elsif importarr.length >= 2
				searchdir = i.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).join(File::SEPARATOR)
				importpath = File.join(searchdir, importfile)
			else
				importpath = File.join(thispath, importfile)
			end
			if File.file?(importpath)
				thisimport = File.read(importpath)
				File.open(path, 'a+') do |p|
					p.write thisimport
				end
			end
		end
	end
end

def copyCSS(file, path)
	filecontents = File.read(file)
	filecontents = filecontents.gsub(/@import.*?;{1}/, "")
	File.open(path, 'a+') do |p|
		p.write filecontents
	end
end

def evalOneoffs(file, path)
	tmp_layout_dir = File.join(Bkmkr::Project.working_dir, "done", Metadata.pisbn, "layout")
	oneoffcss_new = File.join(Bkmkr::Paths.submitted_images, file)
	oneoffcss_pickup = File.join(tmp_layout_dir, file)

	if File.file?(oneoffcss_new)
		FileUtils.mv(oneoffcss_new, oneoffcss_pickup)
		oneoffcss = File.read(oneoffcss_pickup)
		File.open(path, 'a+') do |o|
			o.write oneoffcss
		end
	elsif File.file?(oneoffcss_pickup)
		oneoffcss = File.read(oneoffcss_pickup)
		File.open(path, 'a+') do |o|
			o.write oneoffcss
		end
	end
end

# an array of all occurances of chapters in the manuscript
chapterheads = File.read(Bkmkr::Paths.outputtmp_html).scan(/section data-type="chapter"/)

# Local path vars, css files 
tmp_layout_dir = File.join(Bkmkr::Project.working_dir, "done", Metadata.pisbn, "layout")
tmp_pdf_css = File.join(tmp_layout_dir, "pdf.css")
tmp_epub_css = File.join(tmp_layout_dir, "epub.css")

pdf_css_file = Metadata.printcss
epub_css_file = Metadata.epubcss

find_pdf_css_file = File.join(Bkmkr::Paths.submitted_images, Metadata.printcss)
find_epub_css_file = File.join(Bkmkr::Paths.submitted_images, Metadata.epubcss)

if File.file?(pdf_css_file)
	evalImports(pdf_css_file, tmp_pdf_css)
	copyCSS(pdf_css_file, tmp_pdf_css)
elsif File.file?(find_pdf_css_file)
	evalImports(find_pdf_css_file, tmp_pdf_css)
	copyCSS(find_pdf_css_file, tmp_pdf_css)
	FileUtils.rm(find_pdf_css_file)
else
	File.open("#{tmp_layout_dir}/pdf.css", 'a+') do |p|
		p.write "/* no print css supplied */"
	end
end

evalOneoffs("oneoff_pdf.css", tmp_pdf_css)

if File.file?(epub_css_file)
	evalImports(epub_css_file, tmp_epub_css)
	copyCSS(epub_css_file, tmp_epub_css)
elsif File.file?(find_epub_css_file)
	evalImports(find_epub_css_file, tmp_epub_css)
	copyCSS(find_epub_css_file, tmp_epub_css)
	FileUtils.rm(find_epub_css_file)
else
	File.open("#{tmp_layout_dir}/epub.css", 'a+') do |e|
		e.write "/* no epub css supplied */"
	end
end

evalOneoffs("oneoff_epub.css", tmp_epub_css)

# LOGGING

chapterheadsnum = chapterheads.count

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- STYLESHEETS PROCESSES"
	f.puts "----- I found #{chapterheadsnum} chapters in this book."
	f.puts "finished stylesheets"
end
