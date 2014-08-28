input_file = ARGV[0]
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
tmp_id = File.read("#{input_file}").match(/978-?(\d{1}-?){10}/i)
tmp_dir = "S:\\resources\\bookmaker_tmp"

# Add a notice to the conversion dir warning that the process is in use
File.open("#{working_dir}\\IN_USE_PLEASE_WAIT.txt", 'w') do |output|
	output.write "The conversion processor is currently running. Please do not submit any new files or images until the process completes."
end

# Rename and move files to tmp folder to eliminate possibility of overwriting
`move #{working_dir}\\submitted_images\\cover.jpg #{working_dir}\\submitted_images\\#{tmp_id}_cover.jpg`
`md #{tmp_dir}\\#{tmp_id}`
`copy #{input_file} #{tmp_dir}\\#{tmp_id}\\#{tmp_id}.xml`
`chdir #{tmp_dir}\\#{tmp_id}\\`

# convert xml to html
`java -jar C:\\saxon\\saxon9pe.jar -s:#{tmp_dir}\\#{tmp_id}\\#{tmp_id}.xml -xsl:S:\\resources\\bookmaker_scripts\\wordtohtml.xsl -o:#{tmp_dir}\\#{tmp_id}\\outputtmp.html`

