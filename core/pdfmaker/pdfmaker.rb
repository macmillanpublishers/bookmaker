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

readHtml = lambda { |path|
	filecontents = File.read(path)
	return true, filecontents
}

overwriteFile = lambda { |path, filecontents|
	Mcmlln::Tools.overwriteFile(path, filecontents)
	true
}

# ---------------------- METHODS

def testingValue(file)
	# change to DocRaptor 'test' mode when running from staging server
	testing_value = "false"
	if File.file?(file) then testing_value = "true" end
	return testing_value, true
rescue => e
	return '',e
end

def readCSS(file)
	# CSS to be added to the html head, escaping special chars for ruby
	if File.file?(file)
		embedcss = File.read(file).gsub(/(\\)/,"\\0\\0")
		return embedcss,true
	else
		embedcss = " "
		return embedcss,'no css file to embed'
	end
rescue => e
	return '',e
end

def readJS(file)
	# Custom javascript to be added to the html head
	if File.file?(file)
		embedjs = File.read(file).to_s
		return embedjs,true
	else
		embedjs = " "
		return embedjs,'no custom js file to embed'
	end
rescue => e
	return '',e
end

def insertAssets(content, js, css)
	# add css and js to html head
	filecontents = content.gsub(/<\/head>/,"<script>#{js}</script><style>#{css}</style></head>").to_s
	return filecontents, true
rescue => e
	return content, e
end

def revertCSS(file)
	if File.file?(file)
		# remove escape chars
		revertcss = File.read(file).gsub(/(\\)(\\)/,"\\1")
		return revertcss, true
	else
		revertcss = " "
		return revertcss, 'no cssfile to revert to'
	end
rescue => e
	return '', e
end

# ---------------------- PROCESSES

# Authentication data is required to use docraptor and
# to post images and other assets to an ftp for inclusion
# via docraptor.
DocRaptor.api_key "#{Bkmkr::Keys.docraptor_key}"

# run method: testingValue
testing_value, log_hash['testing_value_test'] = testingValue(testing_value_file)
log_hash['running_on_testing_server'] = testing_value

# create pdf tmp directory
log_hash['pdf_tmp_folder_created'] = Mcmlln::Tools.methodize do
	unless File.exist?(pdftmp_dir)
		Mcmlln::Tools.makeDir(pdftmp_dir)
		true
	else
	 'n-a'
	end
end

# run method: readCSS
embedcss, log_hash['read_pdfcss_file'] = readCSS(cssfile)

log_hash['overwrite_pdfcss_escaping_specialchars'] = Mcmlln::Tools.methodize do
	Mcmlln::Tools.overwriteFile(cssfile, embedcss)
	true
end

# run method: readJS
embedjs, log_hash['read_pdf_js_file'] = readJS(Metadata.printjs)

if File.file?(pdf_tmp_html)
	log_hash['read_in_html'], filecontents = Mcmlln::Tools.methodize(pdf_tmp_html, &readHtml)
else
	log_hash['read_in_html'], filecontents = Mcmlln::Tools.methodize(Bkmkr::Paths.outputtmp_html, &readHtml)
end

# run method: insertAssets
filecontents, log_hash['insertAssets'] = insertAssets(filecontents, embedjs, embedcss)

log_hash['overwrite_pdf_html'] = Mcmlln::Tools.methodize(pdf_tmp_html, filecontents, &overwriteFile)

# create PDF
log_hash['make_pdf'] = Bkmkr::Tools.makepdf(Bkmkr::Tools.pdfprocessor, Metadata.pisbn, pdf_tmp_html, filecontents, cssfile, testing_value, Bkmkr::Keys.http_username, Bkmkr::Keys.http_password)

# moves rendered pdf to archival dir
log_hash['move_pdf_to_done_dir'] = Mcmlln::Tools.methodize do
	Mcmlln::Tools.moveFile(tmppdf, finalpdf)
	true
end

# run method: revertCSS
revertcss, log_hash['read_css_file_sans_specialchar_escapes'] = revertCSS(cssfile)

log_hash['overwrite_css_rm-ing_escapechars'] = Mcmlln::Tools.methodize(cssfile, revertcss, &overwriteFile)

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
