input_file = ARGV[0]
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
tmp_id = File.read("#{input_file}").match(/978-?(\d{1}-?){10}/i)
tmp_dir = "S:\\resources\\bookmaker_tmp"

# Delete all the working files and dirs
`del /f /s /q /a #{tmp_dir}\\#{tmp_id}\\OEBPS\\*`
`rd #{tmp_dir}\\#{tmp_id}\\OEBPS\\`
`del /f /s /q /a #{tmp_dir}\\#{tmp_id}\\META-INF\\*`
`rd #{tmp_dir}\\#{tmp_id}\\META-INF\\`
`del /f /s /q /a #{tmp_dir}\\#{tmp_id}\\mimetype`
`del /f /s /q /a #{tmp_dir}\\#{tmp_id}\\*`
`rd #{tmp_dir}\\#{tmp_id}\\`
`del /f /s /q /a #{input_file}`
`del /f /s /q /a #{working_dir}\\IN_USE_PLEASE_WAIT.txt`