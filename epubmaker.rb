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

epub_dir = "#{tmp_dir}\\#{filename}"

html_file = "#{tmp_dir}\\#{filename}\\outputtmp.html"

# Finding author name(s)
authorname1 = File.read("#{html_file}").scan(/<p class="TitlepageAuthorNameau">.*?<\/p>/).join(",")
authorname2 = authorname1.gsub(/<p class="TitlepageAuthorNameau">/,"").gsub(/<\/p>/,"")

# finding both print and ebook isbns
eisbn_basestring = File.read("#{html_file}").scan(/ISBN\s*.+\s*\(e-book\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
eisbn = eisbn_basestring.scan(/\d+\(ebook\)/).to_s.gsub(/\(ebook\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
pisbn_basestring = File.read("#{html_file}").scan(/ISBN\s*.+\s*\(hardcover\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
pisbn = pisbn_basestring.scan(/\d+\(hardcover\)/).to_s.gsub(/\(hardcover\)/,"").gsub(/\["/,"").gsub(/"\]/,"")

# finding imprint name
imprint = File.read("#{html_file}").scan(/<p class="TitlepageImprintLineimp">.*?<\/p>/).to_s.gsub(/\["<p class=\\"TitlepageImprintLineimp\\">/,"").gsub(/"\]/,"").gsub(/<\/p>/,"")

# Adding author meta element to head
# Replacing toc with empty nav, as required by htmlbook xsl
filecontents = File.read("#{html_file}").gsub(/<\/head>/,"<meta name='author' content='#{authorname2}' /><meta name='publisher' content='#{imprint}' /><meta name='isbn-13' content='#{eisbn}' /></head>").gsub(/(<img.*?)(>)/,"\\1/\\2").gsub(/<body data-type="book">/,"<body data-type=\"book\"><figure data-type=\"cover\"><img src=\"cover.jpg\"/></figure>").gsub(/<nav.*<\/nav>/,"<nav data-type='toc' />").gsub(/&nbsp;/,"&#160;")

# Saving revised HTML into tmp file
File.open("#{tmp_dir}\\#{filename}\\epub_tmp.html", 'w') do |output| 
	output.write filecontents
end

# convert to epub
`chdir #{tmp_dir}\\#{filename} & java -jar C:\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{filename}\\epub_tmp.html -xsl:S:\\resources\\HTMLBook\\htmlbook-xsl\\epub.xsl -o:#{epub_dir}\\tmp.epub`

# fix cover.html doctype
covercontents = File.read("#{tmp_dir}\\#{filename}\\OEBPS\\cover.html")
replace = covercontents.gsub(/&lt;!DOCTYPE html&gt;/,"<!DOCTYPE html>")
File.open("#{tmp_dir}\\#{filename}\\OEBPS\\cover.html", "w") {|file| file.puts replace}

# fix author info in opf
opfcontents = File.read("#{tmp_dir}\\#{filename}\\OEBPS\\content.opf")
replace = opfcontents.gsub(/<dc:creator/,"<dc:identifier id='isbn'>#{eisbn}</dc:identifier><dc:creator id='creator'")
File.open("#{tmp_dir}\\#{filename}\\OEBPS\\content.opf", "w") {|file| file.puts replace}

# add epub css to epub folder
`copy #{working_dir}\\done\\#{pisbn}\\layout\\epub.css #{tmp_dir}\\#{filename}\\OEBPS\\`

# add cover image file to epub folder
`copy #{working_dir}\\done\\#{pisbn}\\cover\\cover.jpg #{tmp_dir}\\#{filename}\\OEBPS\\`
`convert #{tmp_dir}\\#{filename}\\OEBPS\\cover.jpg -resize "600x800>" #{tmp_dir}\\#{filename}\\OEBPS\\cover.jpg`

# add image files to epub folder
sourceimages = Dir["#{working_dir}\\done\\#{pisbn}\\images\\"]

if sourceimages.any?
	`md #{tmp_dir}\\#{filename}\\OEBPS\\images\\`
	`copy #{working_dir}\\done\\#{pisbn}\\images\\* #{tmp_dir}\\#{filename}\\OEBPS\\images\\`
	images = Dir.entries("#{tmp_dir}\\#{filename}\\OEBPS\\images\\").select { |f| File.file?(f) }
	images.each do |i|
		`convert #{tmp_dir}\\#{filename}\\OEBPS\\images\\#{i} -resize "800x1200>" #{tmp_dir}\\#{filename}\\OEBPS\\images\\#{i}`
	end
end

#copy tor logo image file to epub folder
`copy S:\\resources\\torDOTcom\\img\\torlogo.jpg #{tmp_dir}\\#{filename}\\OEBPS\\torlogo.jpg`

# zip epub
`chdir #{tmp_dir}\\#{filename} & C:\\zip\\zip.exe #{eisbn}_EPUB.epub -DX0 mimetype`
`chdir #{tmp_dir}\\#{filename} & C:\\zip\\zip.exe #{eisbn}_EPUB.epub -rDX9 META-INF OEBPS`

# move epub into archive folder
`copy #{tmp_dir}\\#{filename}\\#{eisbn}_EPUB.epub #{working_dir}\\done\\#{pisbn}\\`
`del #{tmp_dir}\\#{filename}\\#{eisbn}_EPUB.epub`

# delete temp epub html file
`del #{tmp_dir}\\#{filename}\\epub_tmp.html`