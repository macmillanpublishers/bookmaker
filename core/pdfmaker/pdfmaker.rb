require 'rubygems'
require 'doc_raptor'
require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
json_log_hash = Bkmkr::Paths.jsonlog_hash
json_log_hash[Bkmkr::Paths.thisscript] = {}
log_hash = json_log_hash[Bkmkr::Paths.thisscript]

# Local path var(s)
pdftmp_dir = File.join(Bkmkr::Paths.project_tmp_dir_img, "pdftmp")

pdfmaker_dir = File.join(Bkmkr::Paths.core_dir, "pdfmaker")

pdf_tmp_html = File.join(Bkmkr::Paths.project_tmp_dir, "pdf_tmp.html")

testing_value_file = File.join(Bkmkr::Paths.resource_dir, "staging.txt")

cssfile = File.join(Bkmkr::Project.working_dir, "done", Metadata.pisbn, "layout", "pdf.css")

tmppdf = File.join(Bkmkr::Paths.project_tmp_dir, "#{Metadata.pisbn}.pdf")

finalpdf = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "#{Metadata.pisbn}_POD.pdf")

# ---------------------- METHODS

def testingValue(file)
	# change to DocRaptor 'test' mode when running from staging server
	testing_value = "false"
	if File.file?(file) then testing_value = "true" end
	return true, testing_value
rescue => e
	return e,''
end

def makePdfTmpFolder(path)
	unless File.exist?(path)
		Mcmlln::Tools.makeDir(path)
		true
	else
	 'n-a'
	end
rescue => e
	e
end

def readCSS(file)
	# CSS to be added to the html head, escaping special chars for ruby
	if File.file?(file)
		embedcss = File.read(file).gsub(/(\\)/,"\\0\\0")
		return true,embedcss
	else
		embedcss = " "
		return 'no css file to embed',embedcss
	end
rescue => e
	return e,''
end

def overwriteFile(path,filecontents)
	Mcmlln::Tools.overwriteFile(path, filecontents)
	true
rescue => e
	e
end

def readJS(file)
	# Custom javascript to be added to the html head
	if File.file?(file)
		embedjs = File.read(file).to_s
		return true, embedjs
	else
		embedjs = " "
		return 'no custom js file to embed', embedjs
	end
rescue => e
	return e,''
end

def readHtmlContents(file)
	filecontents = File.read(file)
	return true, filecontents
rescue => e
	return e, ''
end

def insertAssets(content, js, css)
	# add css and js to html head
	filecontents = content.gsub(/<\/head>/,"<script>#{js}</script><style>#{css}</style></head>").to_s
	return true, filecontents
rescue => e
	return e, content
end

def pdfmaker_makePdf(pdf_tmp_html, filecontents, cssfile, testing_value)
	Bkmkr::Tools.makepdf(Bkmkr::Tools.pdfprocessor, Metadata.pisbn, pdf_tmp_html, filecontents, cssfile, testing_value, Bkmkr::Keys.http_username, Bkmkr::Keys.http_password)
	true
rescue => e
	e
end

def moveFileToDoneFolder(file, dest)
	Mcmlln::Tools.moveFile(file, dest)
	true
rescue => e
	e
end

def revertCSS(file)
	if File.file?(file)
		# remove escape chars
		revertcss = File.read(file).gsub(/(\\)(\\)/,"\\1")
		return true, revertcss
	else
		revertcss = " "
		return 'no cssfile to revert to', revertcss
	end
rescue => e
	return e,''
end

# ---------------------- PROCESSES

# Authentication data is required to use docraptor and
# to post images and other assets to an ftp for inclusion
# via docraptor.
DocRaptor.api_key "#{Bkmkr::Keys.docraptor_key}"

# run method: testingValue
log_hash['testing_value_test'], testing_value = testingValue(testing_value_file)
log_hash['running_on_testing_server'] = testing_value

# create pdf tmp directory
log_hash['pdf_tmp_folder_created'] = makePdfTmpFolder(pdftmp_dir)

# run method: readCSS
log_hash['read_pdfcss_file'], embedcss = readCSS(cssfile)

log_hash['overwrite_pdfcss_escaping_specialchars'] = overwriteFile(cssfile,embedcss)

# run method: readJS
log_hash['read_pdf_js_file'], embedjs = readJS(Metadata.printjs)

if File.file?(pdf_tmp_html)
	log_hash['read_in_html'], filecontents = readHtmlContents(pdf_tmp_html)
else
	log_hash['read_in_html'], filecontents = readHtmlContents(Bkmkr::Paths.outputtmp_html)
end

# run method: insertAssets
log_hash['insertAssets'], filecontents = insertAssets(filecontents, embedjs, embedcss)

log_hash['overwrite_pdf_html'] = overwriteFile(pdf_tmp_html,filecontents)

# create PDF
log_hash['make_pdf'] = pdfmaker_makePdf(pdf_tmp_html, filecontents, cssfile, testing_value)

# moves rendered pdf to archival dir
log_hash['move_pdf_to_done_dir'] = moveFileToDoneFolder(tmppdf, finalpdf)

# run method: revertCSS
log_hash['read_css_file_sans_specialchar_escapes'], revertcss = revertCSS(cssfile)

log_hash['overwrite_css_rm-ing_escapechars'] = overwriteFile(cssfile,revertcss)

# ---------------------- LOGGING

# is there custom javascript?

if File.file?(Metadata.printjs)
	test_custom_js = Metadata.printjs
else
	test_custom_js = "none"
end

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- PDFMAKER PROCESSES"
	f.puts "----- I found the following custom javascript: #{test_custom_js}"
	f.puts "finished pdfmaker"
end

# Write json log:
log_hash['completed'] = Time.now
Mcmlln::Tools.write_json(json_log_hash, Bkmkr::Paths.json_log)
