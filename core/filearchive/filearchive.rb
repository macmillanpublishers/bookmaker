require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
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

# ---------------------- METHODS

# ---------------------- PROCESSES

unless Dir.exist?(final_dir)
  Mcmlln::Tools.makeDir(final_dir)
end

unless Dir.exist?(final_dir_images)
  Mcmlln::Tools.makeDir(final_dir_images)
end

unless Dir.exist?(final_dir_cover)
  Mcmlln::Tools.makeDir(final_dir_cover)
end

unless Dir.exist?(final_dir_layout)
  Mcmlln::Tools.makeDir(final_dir_layout)
end

Mcmlln::Tools.copyFile(Bkmkr::Project.input_file, final_manuscript)
Mcmlln::Tools.copyFile(Bkmkr::Paths.outputtmp_html, final_html)
Mcmlln::Tools.copyFile(tmp_config, final_config)

# ---------------------- LOGGING

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- FILEARCHIVE PROCESSES"
	f.puts "----- Print ISBN: #{Metadata.pisbn}"
	f.puts "finished filearchive"
end