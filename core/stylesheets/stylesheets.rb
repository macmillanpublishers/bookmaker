require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

tmp_layout_dir = File.join(Metadata.final_dir, "layout")

tmp_pdf_scss = File.join(tmp_layout_dir, "pdf.scss")

pdf_css = File.join(tmp_layout_dir, "pdf.css")

tmp_epub_css = File.join(tmp_layout_dir, "epub.css")

print_scss = Metadata.printcss

global_templates_dir = File.join(Bkmkr::Paths.scripts_dir, "bookmaker_assets", "rsuite_assets", "pdfmaker", "css", "global_templates")

override_js_file = File.join(Bkmkr::Paths.project_tmp_dir, "override_pdf.js")


# ---------------------- METHODS

def readConfigJson(logkey='')
  data_hash = Mcmlln::Tools.readjson(Metadata.configfile)
  return data_hash
rescue => logstring
  return {}
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

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
		importpaths = []
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
			importpaths << importpath
			puts "CSS import file: #{importpath}"
			if File.file?(importpath)
				thisimport = File.read(importpath)
				File.open(path, 'a+') do |p|
					p.write thisimport
				end
			end
		end
		@log_hash['css_import_paths'] = importpaths
	else
		logstring = 'no CSS import files found'
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

def makeNoPdfCssNotice(logkey='')
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

def applyGlobalTemplate(html, print_scss, tmp_pdf_scss, global_templates_dir, logkey='')
	scss_load_path = ""
	orig_template_name = File.basename(print_scss, ".*")
	filecontents = File.read(html)
	ms_template_name = filecontents.scan(/<meta name="template"/)
	unless ms_template_name.nil? or ms_template_name.empty? or !ms_template_name
		ms_template_name = filecontents.match(/(<meta name="template" content=")(\S*)(")/)[2]
	else
		logstring = "no template applied in this ms"
	end
	unless ms_template_name.nil? or ms_template_name.empty? or !ms_template_name
		# check if template name matches (if it does we are already set to use imprint template), if not check if it exists in global_templates
		if orig_template_name != ms_template_name
			global_template_scss_file = File.join(global_templates_dir, "#{ms_template_name}.scss")
			# if global template scss exists, pick it up!
			if File.exist?(global_template_scss_file)
				logstring = "Found css for requested global template: #{ms_template_name}.scss, moving to layout dir with gsub."
				# read in scss, replace IMPRINT val, write to layout dir
				orig_template_dirname = File.basename(File.dirname(print_scss))
				gt_scss = File.read(global_template_scss_file).gsub(/IMPRINT/, orig_template_dirname)
				File.open(tmp_pdf_scss, 'a+') do |p|
					p.write gt_scss
				end
				scss_load_path = File.dirname(global_template_scss_file)
			else
				logstring = "no global template found for #{ms_template_name}.css"
			end
		else
			logstring = "imprint specific template used"
		end
		puts logstring
	end
	return scss_load_path
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def moveSCSStoLayoutDir(tmp_pdf_scss, scss_load_path, print_scss, logkey='')
	if scss_load_path.empty?
			Mcmlln::Tools.copyFile(print_scss, tmp_pdf_scss)
			scss_load_path = File.dirname(print_scss)
	end
	return scss_load_path
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def localCompileSCSS(tmp_pdf_scss, pdf_css, scss_load_path, logkey='')
	Bkmkr::Tools.compilescss(tmp_pdf_scss, pdf_css, scss_load_path,)
rescue => logstring
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def evalOneoffs(file, path, logkey='')
	tmp_layout_dir = File.join(Metadata.final_dir, "layout")
	oneoffcss_new = File.join(Bkmkr::Paths.project_tmp_dir_submitted, file)
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

def convertInchesToPts(inches)
  inchnum = inches.gsub("in","")
  puts inchnum
  ptnum = inchnum.to_f * 72
  puts ptnum
  pts = "#{ptnum}pt"
  puts pts
  return pts
end

def applyTrimSCSS(html, tmp_pdf_scss, logkey='')
  filecontents = File.read(html)
	csscontents = File.read(tmp_pdf_scss)
	size = filecontents.scan(/<meta name="size"/)
	unless size.nil? or size.empty? or !size
		size = filecontents.match(/(<meta name="size" content=")(\d*\.*\d*in \d*\.*\d*in)("\s?\/>)/)[2]
    pagewidthinches = size.split[0]
    pageheightinches = size.split[1]
    pagewidthpts = convertInchesToPts(size.split[0])
    pageheightpts = convertInchesToPts(size.split[1])
	end
  logstring = "----- No trim size customizations found."
  # puts "size: #{size} pagewidthinches: #{pagewidthinches}, pageheightinches: #{pageheightinches}"
  unless pageheightpts.nil? or pageheightpts.empty? or !pageheightpts or pagewidthpts.nil? or pagewidthpts.empty? or !pagewidthpts
    tmp_scss = File.read(tmp_pdf_scss).gsub(/TRIM VARS Placeholder/, "Trim vars in use */")
            .gsub(/PAGEWIDTHINCHES/, pagewidthinches)
            .gsub(/PAGEHEIGHTINCHES/, pageheightinches)
            .gsub(/PAGEWIDTHPTS/, pagewidthpts)
            .gsub(/PAGEHEIGHTPTS/, pageheightpts)
            .gsub(/TRIM VARS \*\//, "")
    File.open(tmp_pdf_scss, 'w') do |p|
      p.write tmp_scss
    end
    # logstring = "----- A custom trim size of #{size} has been implemented, per a processing instruction."
  end
rescue => logstring
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def evalTocPI(html, css, pod_toc, logkey='')
	# check for TOC PI
	filecontents = File.read(html)
	tocstring = "TOC present, no TOC PI"
	override = ""
	toctype = filecontents.scan(/<meta name="toc"/)
	unless toctype.nil? or toctype.empty? or !toctype
		toctype = filecontents.match(/(<meta name="toc" content=")(auto|manual|none)("\/>)/)[2]
		tocstring = "Adjusting TOC display per processing instruction (#{toctype})"
	end
	if toctype.include?("auto")
		override = "nav[data-type=\"toc\"] { display: block; } .texttoc { display: none; }"
	elsif toctype.include?("manual")
		override = "nav[data-type=\"toc\"] { display: none; } .texttoc { display: block; }"
	elsif toctype.include?("none")
		override = "nav[data-type=\"toc\"] { display: none; } .texttoc { display: none; }"
	elsif pod_toc != "true"
		tocstring = "no TOC, no toc-PI, hiding TOC element."
		override = 'nav[data-type="toc"]{display:none;}'
	end
	# if we have an override let's write to CSS!
	unless override.empty?
		File.open(css, 'a+') do |o|
			o.puts " "
			o.puts "/* #{tocstring} */"
			o.puts override
		end
	end
	logstring = "----- #{tocstring}"
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# hide chaptertitle for books with only 1 chapter
def appendSoloChapterPdfCss(pdf_css_file, chapterheads, logkey='')#, pod_toc, toc_override, logkey='')
	if File.file?(pdf_css_file)
		suppress_titles = "section[data-type='chapter']>h1{display:none;}"
		unless chapterheads.count > 1
			# append chaptertitle change to pdf css
			File.open(pdf_css_file, 'a+') do |p|
				p.puts " "
				p.puts "/* Suppressing Chapter h1 for novella */"
				p.puts suppress_titles
			end
		end
	else
		logstring = 'no pdf_css_file'
	end
rescue => logstring
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def appendSoloChapterEpubCss(epub_css_file, chapterheads, logkey='')
	if File.file?(epub_css_file)
		unless chapterheads.count > 1
			File.open(epub_css_file, 'a+') do |e|
				e.puts "h1.ChapTitlect{display:none;}"
			end
		end
	else
		logstring = 'no epub_css_file'
	end
rescue => logstring
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def copyOverrideJStoDone(override_js_file, tmp_layout_dir, logkey='')
  if File.file?(override_js_file)
    dest_path = File.join(tmp_layout_dir, "override_pdf.js")
    FileUtils.cp(override_js_file, dest_path)
  else
    logstring = "n-a"
  end
rescue => logstring
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# ---------------------- PROCESSES

# get pod_toc data from config
data_hash = readConfigJson('read_config_json')
pod_toc = data_hash['pod_toc']

# an array of all occurances of chapters in the manuscript
chapterheads = get_chapterheads('get_chapterheads')
@log_hash['chapterhead_count'] = chapterheads.count

# delete pdf & epub css from previous runs
deleteLastRunCss(tmp_pdf_scss, 'delete_existing_tmp_pdf_scss')
deleteLastRunCss(pdf_css, 'delete_existing_pdf_css')
deleteLastRunCss(tmp_epub_css, 'delete_existing_tmp_epub_css')

# apply global templates - these are currently based on sizing/hitting signatures
scss_load_path = applyGlobalTemplate(Bkmkr::Paths.outputtmp_html, print_scss, tmp_pdf_scss, global_templates_dir, "apply_global_templates")

# set scss file, get load path for imports, compile css from scss
scss_load_path = moveSCSStoLayoutDir(tmp_pdf_scss, scss_load_path, print_scss, "move_scss_to_layout_dir")
@log_hash['scss_load_path'] = scss_load_path

# set trim with appended scss vars, also imports specified trim_vars to recalculate trim dependent measurements
applyTrimSCSS(Bkmkr::Paths.outputtmp_html, tmp_pdf_scss, 'apply_trim_scss')

localCompileSCSS(tmp_pdf_scss, pdf_css, scss_load_path, "compile_css_from_scss")

# apply bookmaker processing instructions for TOC to tmp pdf css
evalTocPI(Bkmkr::Paths.outputtmp_html, pdf_css, pod_toc, 'evaluate_Toc_PIs')

# apply css for solo chapter title to tmp pdf css
appendSoloChapterPdfCss(pdf_css, chapterheads, 'append_solo_chapter_css')

# append one-off css (from submitted_images or archival dirs) to tmp css
evalOneoffs("oneoff_pdf.css", pdf_css, 'one_off_css_for_pdf')

# so we get logging re: evalImports even if it's not run
@log_hash['evalImports_epub_css-metadata'] = 'n-a'

# read css and append contents of any referenced imports directly into tmp css
if File.file?(Metadata.epubcss)
	evalImports(Metadata.epubcss, tmp_epub_css, 'evalImports_epub_css-metadata')
	copyCSS(Metadata.epubcss, tmp_epub_css, 'copy_epub_css-metadata')
else
	makeNoEpubCssNotice('no_epubcss-notice')
end

# hide chaptertitle for epubs with only 1 chapter
appendSoloChapterEpubCss(tmp_epub_css, chapterheads, 'append_pdf_css')

# append one-off css (from submitted_images or archival dirs) to tmp css
evalOneoffs("oneoff_epub.css", tmp_epub_css, 'one_off_css_for_epub')

# copy override_pdf_js file to done/layout for re-use/pickup
copyOverrideJStoDone(override_js_file, tmp_layout_dir, 'copy_override_js_file_to_Done')

# ---------------------- LOGGING

# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
