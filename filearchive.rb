input_file = ARGV[0]
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
tmp_id = File.read("#{input_file}").match(/978-?(\d{1}-?){10}/i)
tmp_dir = "S:\\resources\\bookmaker_tmp"

html_file = "#{tmp_dir}\\#{tmp_id}\\outputtmp.html"
pisbn = File.read("#{html_file}").scan(/Print ISBN:.*?<\/p>/).to_s.gsub(/-/,"").gsub(/Print ISBN: /,"").gsub(/<\/p>/,"").gsub(/\["/,"").gsub(/"\]/,"")

# create the archival directory structure and copy xml and html there
`md #{working_dir}\\done\\#{pisbn}`
`md #{working_dir}\\done\\#{pisbn}\\images`
`md #{working_dir}\\done\\#{pisbn}\\cover`
`md #{working_dir}\\done\\#{pisbn}\\layout`
`copy #{input_file} #{working_dir}\\done\\#{pisbn}\\`
`copy #{html_file} #{working_dir}\\done\\#{pisbn}\\layout\\#{pisbn}.html`