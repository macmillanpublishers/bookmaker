require 'fileutils'

require_relative '../header.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

input_config = File.join(Bkmkr::Paths.submitted_images, "config.json")

tmp_config = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")

filecontents = "The conversion processor is currently running. Please do not submit any new files or images until the process completes."

# ---------------------- METHODS
## all methods for this script are Mcmlln::Tools methods wrapped in new methods,
## in order to return results for json_logfile
def getFilesinSubmittedImages(logkey='')
	files = Mcmlln::Tools.dirList(Bkmkr::Paths.submitted_images)
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

def deleteOldProjectTmpFolder(logkey='')
	if Dir.exist?(Bkmkr::Paths.project_tmp_dir)
		Mcmlln::Tools.deleteDir(Bkmkr::Paths.project_tmp_dir)
	else
		logstring = 'n-a'
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def copyInputFile(logkey='')
	Mcmlln::Tools.copyFile("#{Bkmkr::Project.input_file}", Bkmkr::Paths.project_tmp_file)
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def mvInputConfigFile(input_config, logkey='')
	if File.file?(input_config)
		Mcmlln::Tools.moveFile(input_config, tmp_config)
	else
		logstring = 'n-a'
	end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def writeAlertFile(filecontents, logkey='')
	Mcmlln::Tools.overwriteFile(Bkmkr::Paths.alert, filecontents)
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# ---------------------- PROCESSES
# Local path variables
all_submitted_images = getFilesinSubmittedImages('check_submitted_images')
@log_hash['submitted_images'] = all_submitted_images

# Rename and move input files to tmp folder to eliminate possibility of overwriting
makeFolder(Bkmkr::Paths.tmp_dir, 'tmp_folder_created')

deleteOldProjectTmpFolder('old_project_tmp_folder_deleted')

makeFolder(Bkmkr::Paths.project_tmp_dir, 'project_tmp_folder_created')

makeFolder(Bkmkr::Paths.project_tmp_dir_img, 'project_tmp_img_folder_created')

copyInputFile('copy_input_file')

mvInputConfigFile(input_config, 'moved_input_config_file')

writeAlertFile(filecontents, 'write_alert_file')

# ---------------------- LOGGING

# Write test results
File.open("#{Bkmkr::Paths.log_file}", 'w+') do |f|
	f.puts "-----"
	f.puts Time.now
	f.puts "----- TMPARCHIVE PROCESSES"
	f.puts "finished tmparchive"
end

# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
