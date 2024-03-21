require 'rubygems'
require 'doc_raptor'
require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

# Local path var(s)
# pdftmp_dir = File.join(Bkmkr::Paths.project_tmp_dir_img, "pdftmp")

pdfmaker_dir = File.join(Bkmkr::Paths.core_dir, "pdfmaker")

pdf_tmp_html = File.join(Bkmkr::Paths.project_tmp_dir, "pdf_tmp.html")

testing_value_file = File.join(Bkmkr::Paths.resource_dir, "staging.txt")

cssfile = File.join(Metadata.final_dir, "layout", "pdf.css")

tmppdf = File.join(Bkmkr::Paths.project_tmp_dir, "#{Metadata.pisbn}.pdf")

finalpdf = File.join(Metadata.final_dir, "#{Metadata.pisbn}_POD.pdf")

watermark_css = File.join(Bkmkr::Paths.scripts_dir, "bookmaker_assets", "pdfmaker", "css", "generic", "watermark.css")


# ---------------------- METHODS

def testingValue(file, logkey='')
	# change to DocRaptor 'test' mode when running from staging server
	testing_value = "false"
	if File.file?(file) then testing_value = "true" end
	return testing_value
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def makePdfTmpFolder(path, logkey='')
	unless File.exist?(path)
		Mcmlln::Tools.makeDir(path)
	else
	 logstring = 'n-a'
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def readCSS(file, logkey='')
	# CSS to be added to the html head, escaping special chars for ruby
	if File.file?(file)
		embedcss = File.read(file).gsub(/(\\)/,"\\0\\0")
	else
		embedcss = " "
		logstring = 'no css file to embed'
	end
	return embedcss
rescue => logstring
	return ''
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def overwriteFile(path,filecontents, logkey='')
	Mcmlln::Tools.overwriteFile(path, filecontents)
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# def readJS(file, logkey='')
# 	# Custom javascript to be added to the html head
# 	if File.file?(file)
# 		embedjs = File.read(file).to_s
# 	else
# 		embedjs = " "
# 		logstring = 'no custom js file to embed'
# 	end
# 	return embedjs
# rescue => logstring
# 	return ''
# ensure
# 	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
# end

def readHtmlContents(file, logkey='')
	filecontents = File.read(file)
	return filecontents
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def insertAssets(content, js, css, logkey='')
	# add css and js to html head
	filecontents = content.gsub(/<\/head>/,"<script>#{js}</script><style>#{css}</style></head>").to_s
	return filecontents
rescue => logstring
	return content
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping Bkmkr::Tools.makepdf in a new method for this script; to return a result for json_logfile
def pdfmaker_makePdf(pdf_tmp_html, cssfile, jsfile, testing_value, watermark_css, logkey='')
	output = Bkmkr::Tools.makepdf("prince", Metadata.pisbn, pdf_tmp_html, cssfile, jsfile, testing_value, watermark_css, Bkmkr::Keys.http_username, Bkmkr::Keys.http_password)
  logstring = output
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def moveFileToDoneFolder(file, dest, logkey='')
	Mcmlln::Tools.moveFile(file, dest)
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def revertCSS(file, logkey='')
	if File.file?(file)
		# remove escape chars
		revertcss = File.read(file).gsub(/(\\)(\\)/,"\\1")
	else
		revertcss = " "
		logstring = 'no cssfile to revert to'
	end
	return revertcss
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# ---------------------- PROCESSES

# # Authentication data is required to use docraptor and
# # to post images and other assets to an ftp for inclusion
# # via docraptor.
# DocRaptor.api_key "#{Bkmkr::Keys.docraptor_key}"

# run method: testingValue
testing_value = testingValue(testing_value_file, 'testing_value_test')
@log_hash['running_on_testing_server'] = testing_value

# # create pdf tmp directory
# makePdfTmpFolder(pdftmp_dir, 'pdf_tmp_folder_created')

# # run method: readCSS
# embedcss = readCSS(cssfile, 'read_pdfcss_file')
#
# overwriteFile(cssfile,embedcss, 'overwrite_pdfcss_escaping_specialchars')

# # run method: readJS
# embedjs = readJS(Metadata.printjs, 'read_pdf_js_file')

# # prepare html as raw filecontents for doc_raptor
# if File.file?(pdf_tmp_html)
# 	filecontents = readHtmlContents(pdf_tmp_html, 'read_in_html')
# else
# 	filecontents = readHtmlContents(Bkmkr::Paths.outputtmp_html, 'read_in_html')
# end
# # run method: insertAssets
# filecontents = insertAssets(filecontents, embedjs, embedcss, 'insertAssets')


# create PDF
pdfmaker_makePdf(pdf_tmp_html, cssfile, Metadata.printjs, testing_value, watermark_css, 'make_pdf')

# moves rendered pdf to archival dir
moveFileToDoneFolder(tmppdf, finalpdf, 'move_pdf_to_done_dir')

# # run method: revertCSS
# revertcss = revertCSS(cssfile, 'read_css_file_sans_specialchar_escapes')
#
# overwriteFile(cssfile, revertcss, 'overwrite_css_rm-ing_escapechars')

# ---------------------- LOGGING

# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
