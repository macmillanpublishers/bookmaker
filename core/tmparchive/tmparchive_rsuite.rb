require 'fileutils'

require_relative '../header.rb'


# ---------------------- VARIABLES

local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash(true)

tmpdir_from_rsuite = ARGV[1].chomp('"').reverse.chomp('"').reverse.gsub('\\', '/')

rs_server = ARGV[2].chomp('"').reverse.chomp('"').reverse

input_config = File.join(Bkmkr::Paths.project_tmp_dir_submitted, "config.json")

tmp_config = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")


# ---------------------- METHODS
## most methods for this script are Mcmlln::Tools methods wrapped in new methods,
##  in order to return results for json_logfile

def readJson(jsonfile, logkey='')
  data_hash = Mcmlln::Tools.readjson(jsonfile)
  return data_hash
rescue => logstring
  return {}
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def getSubmittedFilesList(dirname, logkey='')
	files = Mcmlln::Tools.dirList(dirname)
	files
rescue => logstring
	return []
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def makeFolder(path, logkey='')
	unless Dir.exist?(path)
		Mcmlln::Tools.makeDir(path)
	else
	 logstring = 'n-a'
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def deleteOldProjectTmpFolders(project_tmp_dir, logkey='')
  pathroot, u, count = project_tmp_dir.rpartition('_')
  dircount = 0
  Dir.glob("#{pathroot}*") do |p_tmpdir|
      if p_tmpdir.rpartition('_')[2].to_i > count.to_i
        dircount += 1
        Mcmlln::Tools.deleteDir(p_tmpdir)
      end
  end
  if dircount > 0
    logstring = "deleted #{dircount} tmpdir(s) with higher increment than new one"
  end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def mvInputConfigFile(input_config, tmp_config, logkey='')
	if File.file?(input_config)
		Mcmlln::Tools.moveFile(input_config, tmp_config)
	else
		logstring = 'n-a'
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# def writeAlertFile(filecontents, logkey='')
# 	Mcmlln::Tools.overwriteFile(Bkmkr::Paths.alert, filecontents)
# rescue => logstring
# ensure
# 	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
# end

def writeHashToJSON(hash, jsonfile, logkey='')
  if not hash.empty?
    Mcmlln::Tools.write_json(hash, jsonfile)
  else
    logstring = 'no data to write to json (empty hash)'
  end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# # ---------------------- PROCESSES
# local definitions from json files
rsuite_metadata_hash = readJson(Bkmkr::Paths.fromrsuite_Metadata_json, 'read_rsuite_metadata_json')

# log some basic info to json:
@log_hash['infile'] = Bkmkr::Project.input_file_normalized
@log_hash['tmpdir_from_rsuite'] = tmpdir_from_rsuite

# verify that python & bookmaker's calculated tmpdirs match
if tmpdir_from_rsuite != Bkmkr::Paths.project_tmp_dir
  @log_hash['tmpdirs_dont_match'] = "tmpdir_from_rsuite does not match bkmkr tmp_dir: #{Bkmkr::Paths.project_tmp_dir}"
else
  all_submitted_files = getSubmittedFilesList(Bkmkr::Paths.project_tmp_dir_submitted, 'check_submitted_files_besides_docx')
  # log submitted files list
  @log_hash['submitted_files'] = all_submitted_files

  # rm any old unique tmp folders for this project with higher increments
  deleteOldProjectTmpFolders(Bkmkr::Paths.project_tmp_dir, 'old_project_tmp_folders_delete')

  # create necessary subdir
  makeFolder(Bkmkr::Paths.project_tmp_dir_img, 'project_tmp_img_folder_created')

  # move input config file to root of tmpdir (if present)
  mvInputConfigFile(input_config, tmp_config, 'moved_input_config_file')

  # # write bookmaker 'busy' file to project dir <-- not really supported for simultaneous runs, but leaving, commented, in case we want to rework
  # filecontents = "The conversion processor is currently running. Please do not submit any new files or images until the process completes."
  # writeAlertFile(filecontents, 'write_alert_file')

  # write rs_servername value to metadata_json
  @log_hash['rsuite_server'] = rs_server
  rsuite_metadata_hash['rsuite_server'] = rs_server
  writeHashToJSON(rsuite_metadata_hash, Bkmkr::Paths.fromrsuite_Metadata_json, 'write_RSserver_info_to_json')
end

# ---------------------- LOGGING
# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
