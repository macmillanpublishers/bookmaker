require 'rubygems'
require 'doc_raptor'

#get secure keys & credentials
docraptor_key = File.read("S:/resources/bookmaker_scripts/bookmaker_authkeys/api_key.txt")
ftp_uname = File.read("S:/resources/bookmaker_scripts/bookmaker_authkeys/ftp_username.txt")
ftp_pass = File.read("S:/resources/bookmaker_scripts/bookmaker_authkeys/ftp_pass.txt")

DocRaptor.api_key "#{docraptor_key}"

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

# testing to see if ISBN style exists
spanisbn = File.read("#{html_file}").scan(/spanISBNisbn/)

# determining print isbn
if spanisbn.length != 0
  pisbn_basestring = File.read("#{html_file}").match(/spanISBNisbn">\s*.+<\/span>\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
  pisbn = pisbn_basestring.match(/\d+<\/span>\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
else
  pisbn_basestring = File.read("#{html_file}").match(/ISBN\s*.+\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
  pisbn = pisbn_basestring.match(/\d+\(.*\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
end

# just in case no isbn is found
if pisbn.length == 0
  pisbn = "#{filename}"
end

#upload images to macmillan.tools site
`S:\\resources\\bookmaker_scripts\\bookmaker_ftpupload\\imageupload.bat #{working_dir}\\done\\#{pisbn}\\images\\`

# pdf css to be added to the file that will be sent to docraptor
css_file = File.read("#{working_dir}\\done\\#{pisbn}\\layout\\pdf.css").to_s

# inserts the css into the head of the html, fixes images
pdf_html = File.read("#{html_file}").gsub(/<\/head>/,"<style>#{css_file}</style></head>").gsub(/(<img.*?)(>)/,"\\1/\\2").gsub(/src="images\//,"src=\"http://www.macmillan.tools.vhost.zerolag.com/bookmaker/bookmakerimg/").to_s

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
	                           :http_user		   => "#{ftp_uname}",
	                           :http_password	 => "#{ftp_pass}"
							             }
                       		)
                           
end

# moves rendered pdf to archival dir
`move #{pisbn}.pdf #{working_dir}\\done\\#{pisbn}\\#{pisbn}_POD.pdf`