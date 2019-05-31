require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

unused_submitted_dir = File.join(Bkmkr::Paths.done_dir, Metadata.pisbn, "unused_submitted_files")

# ---------------------- METHODS
def readConfigJson(logkey='')
  data_hash = Mcmlln::Tools.readjson(Metadata.configfile)
  return data_hash
rescue => logstring
  return {}
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def cpUnusedSubmitted(src, dest, logkey='')
  files = Dir.entries(src) - ['..', '.', '.DS_Store']
  unless files.empty?
    unless Dir.exist?(dest)
      Mcmlln::Tools.makeDir(dest)
    end
    Mcmlln::Tools.copyAllFiles(src, dest)
    logstring = "moved #{files.length} files to done/unused_submitted_dir"
  else
    logstring = 'n-a'
  end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def deleteProjectTmpDir(logkey='')
	Mcmlln::Tools.deleteDir(Bkmkr::Paths.project_tmp_dir)
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def deleteFileifExists(file, logkey='')
	if File.file?(file)
		Mcmlln::Tools.deleteFile(file)
	else
		logstring = 'n-a'
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# ---------------------- PROCESSES
data_hash = readConfigJson('read_config_json')
#local definition(s) based on config.json
project_dir = data_hash['project']
stage_dir = data_hash['stage']

# move any remaining files from submitted-tmpdir to done dir
cpUnusedSubmitted(Bkmkr::Paths.project_tmp_dir_submitted, unused_submitted_dir, 'cp_unused_submitted_items_to_donedir')

# Delete all the working files and dirs
deleteProjectTmpDir('delete_project_tmp_folder')

deleteFileifExists(Bkmkr::Project.input_file, 'delete_input_file')

deleteFileifExists(Bkmkr::Paths.alert, 'delete_alert_file')

# ---------------------- LOGGING
# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
