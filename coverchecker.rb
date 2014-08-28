input_file = ARGV[0]
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
tmp_id = File.read("#{input_file}").match(/978-?(\d{1}-?){10}/i)
tmp_dir = "S:\\resources\\bookmaker_tmp"

html_file = "#{tmp_dir}\\#{tmp_id}\\outputtmp.html"
pisbn = File.read("#{html_file}").scan(/Print ISBN:.*?<\/p>/).to_s.gsub(/-/,"").gsub(/Print ISBN: /,"").gsub(/<\/p>/,"").gsub(/\["/,"").gsub(/"\]/,"")

# The location where the cover is dropped by the user
coverdir = "#{working_dir}\\submitted_images"

# the revised cover filename
cover = "#{tmp_id}_cover.jpg"

# An array listing all files in the submission dir
files = Dir["#{coverdir}*"]

# Removes the full path from each file in the array of submitted files, to make matching more precise
files.each do |s|
    s.gsub!(/#{coverdir}/,"")
end

# checks to see if cover is in the submission dir
# if yes, copies cover to archival location and deletes from submission dir
# if no, prints an error to the archival directory 
if files.include?("#{cover}")
	`copy #{cover} #{working_dir}\\done\\#{pisbn}\\cover\\cover.jpg`
	`del #{working_dir}\\submitted_images\\#{cover}`
else
	File.open("#{working_dir}\\done\\#{pisbn}\\COVER_ERROR.txt", 'w') do |output|
		output.write "There is no cover image for this title. Covers must be dropped in the book_images folder, and must be named cover.jpg."
	end
end
