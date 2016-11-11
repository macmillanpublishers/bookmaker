require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
json_log_hash = Bkmkr::Paths.jsonlog_hash
json_log_hash[Bkmkr::Paths.thisscript] = {}
log_hash = json_log_hash[Bkmkr::Paths.thisscript]

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

log_hash['make_final_dir'] = Mcmlln::Tools.methodize do
  unless Dir.exist?(final_dir)
    Mcmlln::Tools.makeDir(final_dir)
		true
	else
		'n-a'
	end
end

log_hash['make_final_images_dir'] = Mcmlln::Tools.methodize do
  unless Dir.exist?(final_dir_images)
    Mcmlln::Tools.makeDir(final_dir_images)
		true
	else
		'n-a'
	end
end

log_hash['make_final_cover_dir'] = Mcmlln::Tools.methodize do
  unless Dir.exist?(final_dir_cover)
    Mcmlln::Tools.makeDir(final_dir_cover)
		true
	else
		'n-a'
	end
end

log_hash['make_final_layout_dir'] = Mcmlln::Tools.methodize do
  unless Dir.exist?(final_dir_layout)
    Mcmlln::Tools.makeDir(final_dir_layout)
		true
	else
		'n-a'
	end
end

log_hash['copy_input_file_to_final_dir'] = Mcmlln::Tools.methodize do
	Mcmlln::Tools.copyFile(Bkmkr::Project.input_file, final_manuscript)
	true
end
log_hash['copy_html_to_final_layout_dir'] = Mcmlln::Tools.methodize do
	Mcmlln::Tools.copyFile(Bkmkr::Paths.outputtmp_html, final_html)
	true
end
log_hash['copy_tmp_config_final_layout_dir'] = Mcmlln::Tools.methodize do
	Mcmlln::Tools.copyFile(tmp_config, final_config)
	true
end

# ---------------------- LOGGING

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
	f.puts "----- FILEARCHIVE PROCESSES"
	f.puts "----- Print ISBN: #{Metadata.pisbn}"
	f.puts "finished filearchive"
end

# Write json log:
log_hash['completed'] = Time.now
Mcmlln::Tools.write_json(json_log_hash, Bkmkr::Paths.json_log)
