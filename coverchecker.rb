input_file = ARGV[0]
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
tmp_id = File.read("#{input_file}").match(/978-?(\d{1}-?){10}/i)
tmp_dir = "S:\\resources\\bookmaker_tmp"

html_file = "#{tmp_dir}\\outputtmp.html"
pisbn = File.read("#{html_file}").scan(/Print ISBN:.*?<\/p>/).to_s.gsub(/-/,"").gsub(/Print ISBN: /,"").gsub(/<\/p>/,"").gsub(/\["/,"").gsub(/"\]/,"")

# The location where the cover is dropped by the user
coverdir = "#{tmp_dir}\\#{pisbn}\\"

# the revised cover filename
cover = "#{pisbn}_cover.jpg"

# An array listing all files in the submission dir
files = Dir.entries("#{coverdir}")

# checks to see if cover is in the submission dir
# if yes, copies cover to archival location and deletes from submission dir
# if no, prints an error to the archival directory 
if files.include?("#{cover}")
	`copy #{tmp_dir}\\#{pisbn}\\#{cover} #{working_dir}\\done\\#{pisbn}\\cover\\cover.jpg`
else
	File.open("#{working_dir}\\done\\#{pisbn}\\COVER_ERROR.txt", 'w') do |output|
		output.write "There is no cover image for this title. Covers must be dropped in the submitted_images folder, and must be named cover.jpg."
	end
end
