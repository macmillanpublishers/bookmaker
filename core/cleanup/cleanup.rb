require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

final_dir = Metadata.final_dir

unused_submitted_dir = File.join(final_dir, "unused_submitted_files")

# ---------------------- METHODS
## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def readJson(jsonfile, logkey='')
  data_hash = Mcmlln::Tools.readjson(jsonfile)
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

## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def deleteLockfileifExists(final_dir, logkey='')
  donedir_lockfile_pathroot = File.join(final_dir, "layout", "lockfile_*.txt")
  if !Dir.glob(donedir_lockfile_pathroot).empty?
		Mcmlln::Tools.deleteFile(Dir.glob(donedir_lockfile_pathroot)[0])
	else
		logstring = 'n-a'
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# ---------------------- PROCESSES
# write jsonfile data to jsonlog for troubleshooting
config_hash = readJson(Metadata.configfile, 'read_config_json')
@log_hash['config_json_data'] = config_hash

api_md_hash = readJson(Bkmkr::Paths.api_Metadata_json, 'read_api_Metadata_json')
@log_hash['api_Metadata_json_data'] = api_md_hash

# move any remaining files from submitted-tmpdir to done dir
cpUnusedSubmitted(Bkmkr::Paths.project_tmp_dir_submitted, unused_submitted_dir, 'cp_unused_submitted_items_to_donedir')

# Delete all the working files and dirs
deleteProjectTmpDir('delete_project_tmp_folder')

deleteFileifExists(Bkmkr::Project.input_file, 'delete_input_file')

deleteFileifExists(Bkmkr::Paths.alert, 'delete_alert_file')

deleteLockfileifExists(final_dir, 'delete_final_dir_lockfile')

# ---------------------- LOGGING
# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
