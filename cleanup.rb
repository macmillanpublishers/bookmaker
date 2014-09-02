input_file = ARGV[0]
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
tmp_id = File.read("#{input_file}").match(/978-?(\d{1}-?){10}/i)
tmp_dir = "S:\\resources\\bookmaker_tmp"

html_file = "#{tmp_dir}\\outputtmp.html"
pisbn = File.read("#{html_file}").scan(/Print ISBN:.*?<\/p>/).to_s.gsub(/-/,"").gsub(/Print ISBN: /,"").gsub(/<\/p>/,"").gsub(/\["/,"").gsub(/"\]/,"")

# Delete all the working files and dirs
`del /f /s /q /a #{tmp_dir}\\#{pisbn}\\OEBPS\\*`
`rd #{tmp_dir}\\#{pisbn}\\OEBPS\\`
`del /f /s /q /a #{tmp_dir}\\#{pisbn}\\META-INF\\*`
`rd #{tmp_dir}\\#{pisbn}\\META-INF\\`
`del /f /s /q /a #{tmp_dir}\\#{pisbn}\\mimetype`
`del /f /s /q /a #{tmp_dir}\\#{pisbn}\\*`
`rd #{tmp_dir}\\#{pisbn}\\`
`del /f /s /q /a #{html_file}`
`del /f /s /q /a #{input_file}`
`del /f /s /q /a #{working_dir}\\IN_USE_PLEASE_WAIT.txt`