require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

tmp_layout_dir = File.join(Bkmkr::Project.working_dir, "done", Metadata.pisbn, "layout")

tmp_pdf_css = File.join(tmp_layout_dir, "pdf.css")

tmp_epub_css = File.join(tmp_layout_dir, "epub.css")

# ---------------------- METHODS
def get_chapterheads(logkey='')
	chapterheads = File.read(Bkmkr::Paths.outputtmp_html).scan(/section data-type="chapter"/)
	return chapterheads
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def deleteLastRunCss(file, logkey='')
	if Dir.exist?(Bkmkr::Paths.project_tmp_dir)
		Mcmlln::Tools.deleteFile(file)
	else
		logstring = 'n-a'
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def evalImports(file, path, logkey='')
	filecontents = File.read(file)
	thispath = file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-1].join(File::SEPARATOR)
	if filecontents.include? "@import"
		puts "found a CSS import file"
		logstring = 'found a CSS import file'
		imports = filecontents.scan(/@import.*?;{1}/)
		imports.each do |i|
			myimport = i.gsub(/@import/,"").gsub(/url/,"").gsub(/ /,"").gsub(/\(/,"").gsub(/\"/,"").gsub(/\'/,"").gsub(/\)/,"").gsub(/;/,"")
			myimport = myimport.gsub(/^\s*/,"")
			importarr = myimport.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))
			importfile = myimport.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).pop
			if importarr.length >= 2 and importarr.include? ".."
				searchdir = thispath.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-1].join(File::SEPARATOR)
				importpath = File.join(searchdir, importfile)
			elsif importarr.length >= 2 and importarr.include? "."
				importpath = File.join(thispath, importfile)
			elsif importarr.length >= 2
				searchdir = myimport.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).join(File::SEPARATOR)
				importpath = File.join(searchdir, importfile)
			else
				importpath = File.join(thispath, importfile)
			end
			@log_hash['css_import_path'] = importpath
			puts "CSS import file: #{importpath}"
			if File.file?(importpath)
				thisimport = File.read(importpath)
				File.open(path, 'a+') do |p|
					p.write thisimport
				end
			end
		else
			logstring = 'no CSS import file found'
		end
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def copyCSS(file, path, logkey='')
	filecontents = File.read(file)
	filecontents = filecontents.gsub(/@import.*?;{1}/, "")
	File.open(path, 'a+') do |p|
		p.write filecontents
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def deleteSubmittedCss(file, logkey='')
	Mcmlln::Tools.deleteFile(file)
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def makeNoPdfNotice(logkey='')
	File.open("#{tmp_layout_dir}/pdf.css", 'a+') do |p|
		p.write "/* no print css supplied */"
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def makeNoEpubCssNotice(logkey='')
	File.open("#{tmp_layout_dir}/epub.css", 'a+') do |e|
		e.write "/* no epub css supplied */"
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def evalOneoffs(file, path, logkey='')
	tmp_layout_dir = File.join(Bkmkr::Project.working_dir, "done", Metadata.pisbn, "layout")
	oneoffcss_new = File.join(Bkmkr::Paths.submitted_images, file)
	oneoffcss_pickup = File.join(tmp_layout_dir, file)

	if File.file?(oneoffcss_new)
		FileUtils.mv(oneoffcss_new, oneoffcss_pickup)
		oneoffcss = File.read(oneoffcss_pickup)
		File.open(path, 'a+') do |o|
			o.write oneoffcss
		end
		logstring = "----- Found new one-off #{file} in submitted images dir, appending to css."
	elsif File.file?(oneoffcss_pickup)
		oneoffcss = File.read(oneoffcss_pickup)
		File.open(path, 'a+') do |o|
			o.write oneoffcss
		end
		logstring = "----- Found one-off css in tmp_layout_dir from a previous run, appending to css."
	else
		logstring = "----- No one off css found."
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def evalTrimPI(html, css, logkey='')
	filecontents = File.read(html)
	csscontents = File.read(css)
	size = filecontents.scan(/<meta name="size"/)
	unless size.nil? or size.empty? or !size
		size = filecontents.match(/(<meta name="size" content=")(\d*\.*\d*in \d*\.*\d*in)("\/>)/)[2]
	end
	logstring = "----- No trim size customizations found."
	unless size.nil? or size.empty? or !size
		trim = "@page { size: #{size}; }"
		File.open(css, 'a+') do |o|
			o.puts " "
			o.puts "/* Adjusting trim per processing instruction */"
			o.puts trim
		end
		logstring = "----- A custom trim size of #{size} has been added, per a processing instruction."
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def evalTocPI(html, css, logkey='')
	filecontents = File.read(html)
	csscontents = File.read(css)
	toctype = filecontents.scan(/<meta name="toc"/)
	unless toctype.nil? or toctype.empty? or !toctype
		toctype = filecontents.match(/(<meta name="toc" content=")(auto|manual|none)("\/>)/)[2]
	end
	logstring = "----- TOC will be hidden in PDF."
	if toctype.include?("auto")
		override = "nav[data-type=\"toc\"] { display: block; } .texttoc { display: none; }"
		File.open(css, 'a+') do |o|
			o.puts " "
			o.puts "/* Adjusting TOC display per processing instruction */"
			o.puts override
		end
		logstring = "----- The TOC is set to #{toctype}, per a processing instruction."
	elsif toctype.include?("manual")
		override = "nav[data-type=\"toc\"] { display: none; } .texttoc { display: block; }"
		File.open(css, 'a+') do |o|
			o.puts " "
			o.puts "/* Adjusting TOC display per processing instruction */"
			o.puts override
		end
		logstring = "----- The TOC is set to #{toctype}, per a processing instruction."
	elsif toctype.include?("none")
		override = "nav[data-type=\"toc\"] { display: none; } .texttoc { display: none; }"
		File.open(css, 'a+') do |o|
			o.puts " "
			o.puts "/* Adjusting TOC display per processing instruction */"
			o.puts override
		end
		logstring = "----- The TOC is set to #{toctype}, per a processing instruction."
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# ---------------------- PROCESSES

# an array of all occurances of chapters in the manuscript
chapterheads = get_chapterheads('get_chapterheads')
@log_hash['chapterhead_count'] = chapterheads.count

deleteLastRunCss(tmp_pdf_css, 'delete_existing_tmp_pdf_css')

deleteLastRunCss(tmp_epub_css, 'delete_existing_tmp_epub_css')

find_pdf_css_file = File.join(Bkmkr::Paths.submitted_images, Metadata.printcss)
find_epub_css_file = File.join(Bkmkr::Paths.submitted_images, Metadata.epubcss)

#so we get SOME log output either way
@log_hash['evalImports_pdf_css-metadata'] = 'n-a'
@log_hash['evalImports_pdf_css-submitted'] = 'n-a'

if File.file?(Metadata.printcss)
	evalImports(Metadata.printcss, tmp_pdf_css, 'evalImports_pdf_css-metadata')
	copyCSS(Metadata.printcss, tmp_pdf_css, 'copy_pdf_css-metadata')
elsif File.file?(find_pdf_css_file)
	evalImports(find_pdf_css_file, tmp_pdf_css, 'evalImports_pdf_css-submitted')
	copyCSS(find_pdf_css_file, tmp_pdf_css, 'copy_pdf_css-submitted')
	deleteSubmittedCss(find_pdf_css_file, 'rm_pdf_css-submitted')
else
	makeNoPdfCssNotice('no_pdfcss-notice')
end

evalOneoffs("oneoff_pdf.css", tmp_pdf_css, 'one_off_css_for_pdf')

evalTrimPI(Bkmkr::Paths.outputtmp_html, tmp_pdf_css, 'evaluate_Trim_PIs')

evalTocPI(Bkmkr::Paths.outputtmp_html, tmp_pdf_css, 'evaluate_Toc_PIs')

#so we get SOME log output either way
@log_hash['evalImports_epub_css-metadata'] = 'n-a'
@log_hash['evalImports_epub_css-submitted'] = 'n-a'

if File.file?(Metadata.epubcss)
	evalImports(Metadata.epubcss, tmp_epub_css, 'evalImports_epub_css-metadata')
	copyCSS(Metadata.epubcss, tmp_epub_css, 'copy_epub_css-metadata')
elsif File.file?(find_epub_css_file)
	evalImports(find_epub_css_file, tmp_epub_css, 'evalImports_epub_css-submitted')
	copyCSS(find_epub_css_file, tmp_epub_css, 'copy_epub_css-submitted')
	deleteSubmittedCss(find_epub_css_file, 'rm_epub_css-submitted')
else
	makeNoEpubCssNotice('no_epubcss-notice')
end

evalOneoffs("oneoff_epub.css", tmp_epub_css, 'one_off_css_for_epub')

# ---------------------- LOGGING

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- STYLESHEETS PROCESSES"
	f.puts "----- I found #{@log_hash['chapter_head_count']} chapters in this book."
	f.puts @log_hash['evaluate_Trim_PIs']
	f.puts @log_hash['evaluate_Toc_PIs']
	f.puts "finished stylesheets"
end

# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
