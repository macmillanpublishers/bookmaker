require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
json_log_hash = Bkmkr::Paths.jsonlog_hash
json_log_hash[Bkmkr::Paths.thisscript] = {}
log_hash = json_log_hash[Bkmkr::Paths.thisscript]

tmp_layout_dir = File.join(Bkmkr::Project.working_dir, "done", Metadata.pisbn, "layout")

tmp_pdf_css = File.join(tmp_layout_dir, "pdf.css")

tmp_epub_css = File.join(tmp_layout_dir, "epub.css")

# ---------------------- METHODS
def get_chapterheads
	chapterheads = File.read(Bkmkr::Paths.outputtmp_html).scan(/section data-type="chapter"/)
	return true, chapterheads
rescue =>e
	return e,''
end

def deleteLastRunCss(file)
	if Dir.exist?(Bkmkr::Paths.project_tmp_dir)
		Mcmlln::Tools.deleteFile(file)
		true
	else
		'n-a'
	end
rescue => e
	e
end







def evalImports(file, path)
	filecontents = File.read(file)
	thispath = file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-1].join(File::SEPARATOR)
	if filecontents.include? "@import"
		puts "found a CSS import file"
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
			puts "CSS import file: #{importpath}"
			if File.file?(importpath)
				thisimport = File.read(importpath)
				File.open(path, 'a+') do |p|
					p.write thisimport
				end
			end
		end
	end
	true
rescue => e
	e
end

def copyCSS(file, path)
	filecontents = File.read(file)
	filecontents = filecontents.gsub(/@import.*?;{1}/, "")
	File.open(path, 'a+') do |p|
		p.write filecontents
	end
	true
rescue => e
	e
end

def deleteSubmittedCss(file)
	Mcmlln::Tools.deleteFile(file)
	true
rescue => e
	e
end

def makeNoPdfNotice
	File.open("#{tmp_layout_dir}/pdf.css", 'a+') do |p|
		p.write "/* no print css supplied */"
	end
	true
rescue => e
	e
end

def makeNoEpubCssNotice
	File.open("#{tmp_layout_dir}/epub.css", 'a+') do |e|
		e.write "/* no epub css supplied */"
	end
	true
rescue => e
	e
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
		log = "----- Found new one-off #{file} in submitted images dir, appending to css."
	elsif File.file?(oneoffcss_pickup)
		oneoffcss = File.read(oneoffcss_pickup)
		File.open(path, 'a+') do |o|
			o.write oneoffcss
		end
		log = "----- Found one-off css in tmp_layout_dir from a previous run, appending to css."
	else
		log = "----- No one off css found."
	end
	log
rescue => e
	return e
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
rescue => e
	e
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
	true
rescue => e
	e
end

# ---------------------- PROCESSES

# an array of all occurances of chapters in the manuscript
log_hash['get_chapterheads'], chapterheads = get_chapterheads
log_hash['chapterhead_count'] = chapterheads.count

log_hash['delete_existing_tmp_pdf_css'] = deleteLastRunCss(tmp_pdf_css)

log_hash['delete_existing_tmp_epub_css'] = deleteLastRunCss(tmp_epub_css)

find_pdf_css_file = File.join(Bkmkr::Paths.submitted_images, Metadata.printcss)
find_epub_css_file = File.join(Bkmkr::Paths.submitted_images, Metadata.epubcss)

log_hash['evalImports_pdf_css-metadata'],log_hash['evalImports_pdf_css-submitted'] = 'n-a','n-a' #so we get SOME output either way

if File.file?(Metadata.printcss)
	log_hash['evalImports_pdf_css-metadata'] = evalImports(Metadata.printcss, tmp_pdf_css)
	log_hash['copy_pdf_css-metadata'] = copyCSS(Metadata.printcss, tmp_pdf_css)
elsif File.file?(find_pdf_css_file)
	log_hash['evalImports_pdf_css-submitted'] = evalImports(find_pdf_css_file, tmp_pdf_css)
	log_hash['copy_pdf_css-submitted'] = copyCSS(find_pdf_css_file, tmp_pdf_css)
	log_hash['rm_pdf_css-submitted'] = deleteSubmittedCss(find_pdf_css_file)
else
	log_hash['no_pdfcss-notice'] = makeNoPdfCssNotice
end

log_hash['one_off_css_for_pdf'] = evalOneoffs("oneoff_pdf.css", tmp_pdf_css)

log_hash['evaluate_Trim_PIs'] = evalTrimPI(Bkmkr::Paths.outputtmp_html, tmp_pdf_css)

log_hash['evaluate_Toc_PIs'] = evalTocPI(Bkmkr::Paths.outputtmp_html, tmp_pdf_css)

log_hash['evalImports_epub_css-metadata'],log_hash['evalImports_epub_css-submitted'] = 'n-a','n-a'

if File.file?(Metadata.epubcss)
	log_hash['evalImports_epub_css-metadata'] = evalImports(Metadata.epubcss, tmp_epub_css)
	log_hash['copy_epub_css-metadata'] = copyCSS(Metadata.epubcss, tmp_epub_css)
elsif File.file?(find_epub_css_file)
	log_hash['evalImports_epub_css-submitted'] = evalImports(find_epub_css_file, tmp_epub_css)
	log_hash['copy_epub_css-submitted'] = copyCSS(find_epub_css_file, tmp_epub_css)
	log_hash['rm_epub_css-submitted'] = deleteSubmittedCss(find_epub_css_file)
else
	log_hash['no_epubcss-notice'] = makeNoEpubCssNotice
end

log_hash['one_off_css_for_epub'] = evalOneoffs("oneoff_epub.css", tmp_epub_css)

# ---------------------- LOGGING

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- STYLESHEETS PROCESSES"
	f.puts "----- I found #{log_hash['chapter_head_count']} chapters in this book."
	f.puts log_hash['evaluate_Trim_PIs']
	f.puts log_hash['evaluate_Toc_PIs']
	f.puts "finished stylesheets"
end

# Write json log:
log_hash['completed'] = Time.now
Mcmlln::Tools.write_json(json_log_hash, Bkmkr::Paths.json_log)
