require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
tmp_layout_dir = File.join(Bkmkr::Project.working_dir, "done", Metadata.pisbn, "layout")

tmp_pdf_css = File.join(tmp_layout_dir, "pdf.css")

tmp_epub_css = File.join(tmp_layout_dir, "epub.css")

# ---------------------- METHODS
def evalImports(file, path)
	filecontents = File.read(file)
	thispath = file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-1].join(File::SEPARATOR)
	if filecontents.include? "@import"
		puts "found a CSS import file"
		imports = filecontents.scan(/@import.*?;{1}/)
		imports.each do |i|
			myimport = i.gsub(/@import/,"").gsub(/\"/,"").gsub(/\'/,"").gsub(/;/,"")
			myimport = myimport.gsub(/^\s*/,"")
			importarr = myimport.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))
			importfile = myimport.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).pop
			if importarr.length >= 2 and importarr.include? ".."
				searchdir = thispath.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].join(File::SEPARATOR)
				importpath = File.join(searchdir, importfile)
			elsif importarr.length >= 2 and importarr.include? "."
				importpath = File.join(thispath, importfile)
			elsif importarr.length >= 2
				searchdir = myimport.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).join(File::SEPARATOR)
				importpath = File.join(searchdir, importfile)
			else
				importpath = File.join(thispath, importfile)
			end
			puts "CSS import file: #{importpath}"
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

def evalTrimPI(html, css)
	filecontents = File.read(html)
	csscontents = File.read(css)
	size = filecontents.scan(/<meta name="size"/)
	unless size.nil? or size.empty? or !size
		size = filecontents.match(/(<meta name="size" content=")(\d*\.*\d*in \d*\.*\d*in)("\/>)/)[2]
	end
	log = "----- No trim size customizations found."
	unless size.nil? or size.empty? or !size
		trim = "@page { size: #{size}; }"
		File.open(css, 'a+') do |o|
			o.puts " "
			o.puts "/* Adjusting trim per processing instruction */"
			o.puts trim
		end
		log = "----- A custom trim size of #{size} has been added, per a processing instruction."
	end
	log
end

def evalTocPI(html, css)
	filecontents = File.read(html)
	csscontents = File.read(css)
	toctype = filecontents.scan(/<meta name="toc"/)
	unless toctype.nil? or toctype.empty? or !toctype
		toctype = filecontents.match(/(<meta name="toc" content=")(auto|manual|none)("\/>)/)[2]
	end
	log = "----- TOC will be hidden in PDF."
	if toctype.include?("auto")
		override = "nav[data-type=\"toc\"] { display: block; } .texttoc { display: none; }"
		File.open(css, 'a+') do |o|
			o.puts " "
			o.puts "/* Adjusting TOC display per processing instruction */"
			o.puts override
		end
		log = "----- The TOC is set to #{toctype}, per a processing instruction."
	elsif toctype.include?("manual")
		override = "nav[data-type=\"toc\"] { display: none; } .texttoc { display: block; }"
		File.open(css, 'a+') do |o|
			o.puts " "
			o.puts "/* Adjusting TOC display per processing instruction */"
			o.puts override
		end
		log = "----- The TOC is set to #{toctype}, per a processing instruction."
	elsif toctype.include?("none")
		override = "nav[data-type=\"toc\"] { display: none; } .texttoc { display: none; }"
		File.open(css, 'a+') do |o|
			o.puts " "
			o.puts "/* Adjusting TOC display per processing instruction */"
			o.puts override
		end
		log = "----- The TOC is set to #{toctype}, per a processing instruction."
	end
	log
end

# ---------------------- PROCESSES

# an array of all occurances of chapters in the manuscript
chapterheads = File.read(Bkmkr::Paths.outputtmp_html).scan(/section data-type="chapter"/)

if File.file?(tmp_pdf_css)
	Mcmlln::Tools.deleteFile(tmp_pdf_css)
end

if File.file?(tmp_epub_css)
	Mcmlln::Tools.deleteFile(tmp_epub_css)
end

find_pdf_css_file = File.join(Bkmkr::Paths.submitted_images, Metadata.printcss)
find_epub_css_file = File.join(Bkmkr::Paths.submitted_images, Metadata.epubcss)

if File.file?(Metadata.printcss)
	evalImports(Metadata.printcss, tmp_pdf_css)
	copyCSS(Metadata.printcss, tmp_pdf_css)
elsif File.file?(find_pdf_css_file)
	evalImports(find_pdf_css_file, tmp_pdf_css)
	copyCSS(find_pdf_css_file, tmp_pdf_css)
	Mcmlln::Tools.deleteFile(find_pdf_css_file)
else
	File.open("#{tmp_layout_dir}/pdf.css", 'a+') do |p|
		p.write "/* no print css supplied */"
	end
end

evalOneoffs("oneoff_pdf.css", tmp_pdf_css)

trimmessage = evalTrimPI(Bkmkr::Paths.outputtmp_html, tmp_pdf_css)

tocmessage = evalTocPI(Bkmkr::Paths.outputtmp_html, tmp_pdf_css)

if File.file?(Metadata.epubcss)
	evalImports(Metadata.epubcss, tmp_epub_css)
	copyCSS(Metadata.epubcss, tmp_epub_css)
elsif File.file?(find_epub_css_file)
	evalImports(find_epub_css_file, tmp_epub_css)
	copyCSS(find_epub_css_file, tmp_epub_css)
	Mcmlln::Tools.deleteFile(find_epub_css_file)
else
	File.open("#{tmp_layout_dir}/epub.css", 'a+') do |e|
		e.write "/* no epub css supplied */"
	end
end

evalOneoffs("oneoff_epub.css", tmp_epub_css)

# ---------------------- LOGGING

chapterheadsnum = chapterheads.count

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- STYLESHEETS PROCESSES"
	f.puts "----- I found #{chapterheadsnum} chapters in this book."
	f.puts trimmessage
	f.puts tocmessage
	f.puts "finished stylesheets"
end
