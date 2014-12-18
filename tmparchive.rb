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

# Rename and move input files to tmp folder to eliminate possibility of overwriting
`md #{tmp_dir}\\#{filename}`
`move #{working_dir}\\submitted_images\\cover.jpg #{tmp_dir}\\#{filename}\\cover.jpg`
`copy #{input_file} #{tmp_dir}\\#{filename}\\#{filename}.xml`

# Add a notice to the conversion dir warning that the process is in use
File.open("#{working_dir}\\IN_USE_PLEASE_WAIT.txt", 'w') do |output|
	output.write "The conversion processor is currently running. Please do not submit any new files or images until the process completes."
end