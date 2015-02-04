require 'rubygems'
require 'doc_raptor'

DocRaptor.api_key "***REMOVED***"

input_file = ARGV[0]
filename_split = input_file.split("\\").pop
filename = filename_split.split(".").shift.gsub(/ /, "")
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
# determine current working volume
`cd > currvol.txt`
currpath = File.read("currvol.txt")
currvol = currpath.split("\\").shift

# set working dir based on current volume
tmp_dir = "#{currvol}\\bookmaker_tmp"

html_file = "#{tmp_dir}\\#{filename}\\outputtmp.html"

# determing print isbn
tpbisbn = File.read("#{html_file}").scan(/ISBN\s*.+\s*\(trade paperback\)/)
hcvisbn = File.read("#{html_file}").scan(/ISBN\s*.+\s*\(hardcover\)/)

if hcvisbn.length != 0
  pisbn_basestring = File.read("#{html_file}").scan(/ISBN\s*.+\s*\(hardcover\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
  pisbn = pisbn_basestring.scan(/\d+\(hardcover\)/).to_s.gsub(/\(hardcover\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
else
  pisbn_basestring = File.read("#{html_file}").scan(/ISBN\s*.+\s*\(trade paperback\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
  pisbn = pisbn_basestring.scan(/\d+\(trade paperback\)/).to_s.gsub(/\(trade paperback\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
end

# pdf css to be added to the file that will be sent to docraptor
css_file = File.read("#{working_dir}\\done\\#{pisbn}\\layout\\pdf.css").to_s

# inserts the css into the head of the html, fixes images
# pdf_html = File.read("#{html_file}").gsub(/<\/head>/,"<style>#{css_file}</style></head>").gsub(/(<img.*?)(>)/,"\\1/\\2").gsub(/src="images\//,"src=\"http://art.macmillanusa.com/Content%20Workflows/NYAutomation/").to_s
pdf_html = File.read("#{html_file}").gsub(/<\/head>/,"<style>#{css_file}</style></head>").gsub(/(<img.*?)(>)/,"\\1/\\2").gsub(/src="images\//,"src=\"http://nelliemckesson.com/test/").to_s

# sends file to docraptor for conversion
# currently running in test mode; remove test when css is finalized
`chdir #{tmp_dir}\\#{filename}`
File.open("#{pisbn}.pdf", "w+b") do |f|
  f.write DocRaptor.create(:document_content => pdf_html,
                           :name             => "#{pisbn}.pdf",
                           :document_type    => "pdf",
                           :strict			     => "none",
                           :test             => true,
	                         :prince_options	 => {
	                           :http_user		   => "bookmaker",
	                           :http_password	 => "***REMOVED***"
							             }
                       		)
                           
end

# moves rendered pdf to archival dir
`move #{pisbn}.pdf #{working_dir}\\done\\#{pisbn}\\#{pisbn}_POD.pdf`