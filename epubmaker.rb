input_file = ARGV[0]
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
tmp_id = File.read("#{input_file}").match(/978-?(\d{1}-?){10}/i)
tmp_dir = "S:\\resources\\bookmaker_tmp"
html_file = "#{tmp_dir}\\outputtmp.html"

# Finding author name(s)
authorname1 = File.read("#{html_file}").scan(/<p class="TitlepageAuthorNameau">.*?<\/p>/).join(",")
authorname2 = authorname1.gsub(/<p class="TitlepageAuthorNameau">/,"").gsub(/<\/p>/,"")

# finding both print and ebook isbns
eisbn = File.read("#{html_file}").scan(/Ebook ISBN:.*?<\/p>/).to_s.gsub(/-/,"").gsub(/Ebook ISBN: /,"").gsub(/<\/p>/,"").gsub(/\["/,"").gsub(/"\]/,"")
pisbn = File.read("#{html_file}").scan(/Print ISBN:.*?<\/p>/).to_s.gsub(/-/,"").gsub(/Print ISBN: /,"").gsub(/<\/p>/,"").gsub(/\["/,"").gsub(/"\]/,"")

# finding imprint name
imprint = File.read("#{html_file}").scan(/<p class="TitlepageImprintLineimp">.*?<\/p>/).to_s.gsub(/\["<p class=\\"TitlepageImprintLineimp\\">/,"").gsub(/"\]/,"").gsub(/<\/p>/,"")

# Adding author meta element to head
# Replacing toc with empty nav, as required by htmlbook xsl
filecontents = File.read("#{html_file}").gsub(/<\/head>/,"<meta name='author' content='#{authorname2}' /><meta name='publisher' content='#{imprint}' /><meta name='isbn-13' content='#{eisbn}' /></head>").gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\"><img src=\"cover.jpg\"/></figure>").gsub(/<nav.*<\/nav>/,"<nav data-type='toc' />").gsub(/&nbsp;/,"&#160;")

# Saving revised HTML into tmp file
File.open("#{tmp_dir}\\#{pisbn}\\epub_tmp.html", 'w') do |output| 
	output.write filecontents
end

# convert to epub
`java -jar C:\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{pisbn}\\epub_tmp.html -xsl:S:\\resources\\HTMLBook\\HTMLBook-master\\htmlbook-xsl\\epub.xsl -o:#{tmp_dir}\\#{pisbn}\\tmp.epub`

# fix cover.html doctype
covercontents = File.read("#{tmp_dir}\\#{pisbn}\\OEBPS\\cover.html")
replace = covercontents.gsub(/&lt;!DOCTYPE html&gt;/,"<!DOCTYPE html>")
File.open("#{tmp_dir}\\#{pisbn}\\OEBPS\\cover.html", "w") {|file| file.puts replace}

# fix author info in opf
covercontents = File.read("#{tmp_dir}\\#{pisbn}\\OEBPS\\content.opf")
replace = covercontents.gsub(/<dc:creator/,"<dc:identifier id='isbn'>#{eisbn}</dc:identifier><dc:creator role='aut'")
File.open("#{tmp_dir}\\#{pisbn}\\OEBPS\\content.opf", "w") {|file| file.puts replace}

# add epub css to epub folder
`copy #{working_dir}\\done\\#{pisbn}\\layout\\epub.css #{tmp_dir}\\#{pisbn}\\OEBPS\\`

# add cover image file to epub folder
`copy #{working_dir}\\done\\#{pisbn}\\cover\\cover.jpg #{tmp_dir}\\#{pisbn}\\OEBPS\\`

#copy tor logo image file to epub folder
`copy #{working_dir}\\resources\\torDOTcom\\img\\torlogo.jpg #{tmp_dir}\\#{pisbn}\\OEBPS\\`

# zip epub
`C:\\zip\\zip.exe #{eisbn}_EPUB.epub -DX0 #{tmp_dir}\\#{pisbn}\\mimetype`
`C:\\zip\\zip.exe #{eisbn}_EPUB.epub -rDX9 #{tmp_dir}\\#{pisbn}\\META-INF #{tmp_dir}\\#{pisbn}\\OEBPS`

# move epub into archive folder
`copy #{eisbn}_EPUB.epub #{working_dir}\\done\\#{pisbn}\\`
`del #{eisbn}_EPUB.epub`

# delete temp epub html file
`del #{tmp_dir}\\#{pisbn}\\epub_tmp.html`