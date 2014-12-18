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
pisbn = File.read("#{html_file}").scan(/Print ISBN:.*?<\/p>/).to_s.gsub(/-/,"").gsub(/Print ISBN: /,"").gsub(/<\/p>/,"").gsub(/\["/,"").gsub(/"\]/,"")

# create the archival directory structure and copy xml and html there
`md #{working_dir}\\done\\#{pisbn}`
`md #{working_dir}\\done\\#{pisbn}\\images`
`md #{working_dir}\\done\\#{pisbn}\\cover`
`md #{working_dir}\\done\\#{pisbn}\\layout`
`copy #{input_file} #{working_dir}\\done\\#{pisbn}\\`
`copy #{html_file} #{working_dir}\\done\\#{pisbn}\\layout\\#{pisbn}.html`
