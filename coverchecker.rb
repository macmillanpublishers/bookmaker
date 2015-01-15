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
pisbn = File.read("#{html_file}").scan(/ISBN\s*.+\s*\(hardcover\)\s*<\/p>/).to_s.gsub(/-/,"").gsub(/ISBN\s*/,"").gsub(/\s*\(hardcover\)\s*/,"").gsub(/<\/p>/,"").gsub(/\["/,"").gsub(/"\]/,"")

# The location where the cover is dropped by the user
coverdir = "#{tmp_dir}\\#{filename}\\"

# the revised cover filename
cover = "cover.jpg"

# An array listing all files in the submission dir
files = Dir.entries("#{coverdir}")

# checks to see if cover is in the submission dir
# if yes, copies cover to archival location and deletes from submission dir
# if no, prints an error to the archival directory 
if files.include?("#{cover}")
	`copy #{tmp_dir}\\#{filename}\\#{cover} #{working_dir}\\done\\#{pisbn}\\cover\\cover.jpg`
else
	File.open("#{working_dir}\\done\\#{pisbn}\\COVER_ERROR.txt", 'w') do |output|
		output.write "There is no cover image for this title. Covers must be dropped in the submitted_images folder, and must be named cover.jpg."
	end
end
