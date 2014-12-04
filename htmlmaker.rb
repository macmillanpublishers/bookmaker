input_file = ARGV[0]
filename_split = input_file.split("\\").pop
filename = filename_split.split(".").shift.gsub(/ /, "")
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
tmp_dir = "C:\\bookmaker_tmp"

# convert xml to html
`java -jar C:\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{filename}\\#{filename}.xml -xsl:S:\\resources\\bookmaker_scripts\\WordXML-to-HTML\\wordtohtml.xsl -o:#{tmp_dir}\\#{filename}\\outputtmp.html`