require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# create the archival directory structure and copy xml and html there
filetype = Bkmkr::Project.filename_split.split(".").pop

final_dir = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn)
final_dir_images = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "images")
final_dir_cover = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "cover")
final_dir_layout = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "layout")
final_manuscript = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "#{Metadata.pisbn}_MNU.#{filetype}")
final_html = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "layout", "#{Metadata.pisbn}.html")
tmp_config = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")
final_config = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "layout", "config.json")

unless Dir.exist?(final_dir)
	Dir.mkdir(final_dir)
	Dir.mkdir(final_dir_images)
	Dir.mkdir(final_dir_cover)
	Dir.mkdir(final_dir_layout)
end

FileUtils.cp(Bkmkr::Project.input_file, final_manuscript)
FileUtils.cp(Bkmkr::Paths.outputtmp_html, final_html)
FileUtils.cp(tmp_config, final_config)

# LOGGING

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- FILEARCHIVE PROCESSES"
	f.puts "----- Print ISBN: #{Metadata.pisbn}"
	f.puts "finished filearchive"
end