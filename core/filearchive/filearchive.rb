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
## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def makeDir(path)
  unless Dir.exist?(path)
    Mcmlln::Tools.makeDir(path)
    true
  else
    'n-a'
  end
rescue => e
  e
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def copyFile(source,dest)
  Mcmlln::Tools.copyFile(source, dest)
  true
rescue => e
  e
end

# ---------------------- PROCESSES

log_hash['make_final_dir'] = makeDir(final_dir)

log_hash['make_final_images_dir'] = makeDir(final_dir_images)

log_hash['make_final_cover_dir'] = makeDir(final_dir_cover)

log_hash['make_final_layout_dir'] = makeDir(final_dir_cover)

log_hash['make_final_layout_dir'] = makeDir(final_dir_layout)

log_hash['copy_input_file_to_final_dir'] = copyFile(Bkmkr::Project.input_file, final_manuscript)

log_hash['copy_html_to_final_layout_dir'] = copyFile(Bkmkr::Paths.outputtmp_html, final_html)

log_hash['copy_tmp_config_final_layout_dir'] = copyFile(tmp_config, final_config)


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
