require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

# create the archival directory structure and copy xml and html there
filetype = Bkmkr::Project.filename_split.split(".").pop

final_dir = File.join(Metadata.final_dir)

final_dir_images = File.join(Metadata.final_dir, "images")

final_dir_cover = File.join(Metadata.final_dir, "cover")

final_dir_layout = File.join(Metadata.final_dir, "layout")

final_manuscript = File.join(Metadata.final_dir, "#{Metadata.pisbn}_MNU.#{filetype}")

final_html = File.join(Metadata.final_dir, "layout", "#{Metadata.pisbn}.html")

tmp_config = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")

final_config = File.join(Metadata.final_dir, "layout", "config.json")

# ---------------------- METHODS
## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def makeDir(path, logkey='')
  unless Dir.exist?(path)
    Mcmlln::Tools.makeDir(path)
  else
    logstring = 'n-a'
  end
rescue => logstring
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def copyFile(source, dest, logkey='')
  Mcmlln::Tools.copyFile(source, dest)
rescue => logstring
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# ---------------------- PROCESSES

#make archival dirs
makeDir(final_dir, 'make_final_dir')

makeDir(final_dir_images, 'make_final_images_dir')

makeDir(final_dir_cover, 'make_final_cover_dir')

makeDir(final_dir_layout, 'make_final_layout_dir')

#move input file, outputtmp_html, config.json to archival dirs
copyFile(Bkmkr::Project.input_file, final_manuscript, 'copy_input_file_to_final_dir')

copyFile(Bkmkr::Paths.outputtmp_html, final_html, 'copy_html_to_final_layout_dir')

copyFile(tmp_config, final_config, 'copy_tmp_config_final_layout_dir')

@log_hash['print_ISBN']=Metadata.pisbn

# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
