require 'rubygems'
require 'doc_raptor'
require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
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
	testing_value
end

def readCSS(file)
	# CSS to be added to the html head, escaping special chars for ruby
	if File.file?(file)
		embedcss = File.read(file).gsub(/(\\)/,"\\0\\0")
	else
		embedcss = " "
	end
	embedcss
end

def readJS(file)
	# Custom javascript to be added to the html head
	if File.file?(file)
		embedjs = File.read(file).to_s
	else
		embedjs = " "
	end
	embedjs
end

def insertAssets(content)
	# add css and js to html head
	filecontents = content.gsub(/<\/head>/,"<script>#{embedjs}</script><style>#{embedcss}</style></head>").to_s
end

def revertCSS(file)
	if File.file?(file)
		# remove escape chars
		revertcss = File.read(file).gsub(/(\\)(\\)/,"\\1")
	else
		revertcss = " "
	end
	revertcss
end

# ---------------------- PROCESSES

# Authentication data is required to use docraptor and 
# to post images and other assets to an ftp for inclusion 
# via docraptor.
DocRaptor.api_key "#{Bkmkr::Keys.docraptor_key}"

# run method: testingValue
testing_value = testingValue(testing_value_file)

# create pdf tmp directory
unless File.exist?(pdftmp_dir)
	Mcmlln::Tools.makeDir(pdftmp_dir)
end

# run method: readCSS
embedcss = readCSS(cssfile)

Mcmlln::Tools.overwriteFile(cssfile, embedcss)

# run method: readJS
embedcss = readJS(Metadata.printjs)

if File.file?(pdf_tmp_html)
	filecontents = File.read(pdf_tmp_html)
else
	filecontents = File.read(Bkmkr::Paths.outputtmp_html)
end

# run method: insertAssets
filecontents = insertAssets(filecontents)

Mcmlln::Tools.overwriteFile(pdf_tmp_html, filecontents)

# create PDF
Bkmkr::Tools.makepdf(Bkmkr::Tools.pdfprocessor, Metadata.pisbn, pdf_tmp_html, pdf_html, cssfile, testing_value, Bkmkr::Keys.http_username, Bkmkr::Keys.http_password)

# moves rendered pdf to archival dir
Mcmlln::Tools.moveFile(tmppdf, finalpdf)

# run method: revertCSS
revertcss = revertCSS(cssfile)

Mcmlln::Tools.overwriteFile(cssfile, revertcss)

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
