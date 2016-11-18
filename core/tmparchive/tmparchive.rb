require 'fileutils'

require_relative '../header.rb'

# ---------------------- VARIABLES
json_log_hash = Bkmkr::Paths.jsonlog_hash
json_log_hash[Bkmkr::Paths.thisscript] = {}
log_hash = json_log_hash[Bkmkr::Paths.thisscript]

input_config = File.join(Bkmkr::Paths.submitted_images, "config.json")

tmp_config = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")

filecontents = "The conversion processor is currently running. Please do not submit any new files or images until the process completes."

# ---------------------- METHODS

def getFilesinSubmittedImages
	files = Mcmlln::Tools.dirList(Bkmkr::Paths.submitted_images)
	return true, files
rescue => e
	e
end

def makeTmpFolder
	unless Dir.exist?(Bkmkr::Paths.tmp_dir)
		Mcmlln::Tools.makeDir(Bkmkr::Paths.tmp_dir)
		true
	else
	 'n-a'
	end
rescue => e
	e
end

def deleteOldProjectTmpFolder
	if Dir.exist?(Bkmkr::Paths.project_tmp_dir)
		Mcmlln::Tools.deleteDir(Bkmkr::Paths.project_tmp_dir)
		true
	else
		'n-a'
	end
rescue => e
	e
end

def createProjectTmpFolder
	Mcmlln::Tools.makeDir(Bkmkr::Paths.project_tmp_dir)
	true
rescue => e
	e
end

def createProjectTmpImgFolder
	Mcmlln::Tools.makeDir(Bkmkr::Paths.project_tmp_dir_img)
	true
rescue => e
	e
end

def copyInputFile
	Mcmlln::Tools.copyFile("#{Bkmkr::Project.input_file}", Bkmkr::Paths.project_tmp_file)
	true
rescue => e
	e
end

def mvInputConfigFile(input_config)
	if File.file?(input_config)
		Mcmlln::Tools.moveFile(input_config, tmp_config)
		true
	else
		'n-a'
	end
rescue => e
	e
end

def writeAlertFile(filecontents)
	Mcmlln::Tools.overwriteFile(Bkmkr::Paths.alert, filecontents)
	true
rescue => e
	e
end

# ---------------------- PROCESSES

# For TEST purposes
# test_images_before = Mcmlln::Tools.dirList(Bkmkr::Paths.submitted_images)  <--can I get rid of this?

# Local path variables
log_hash['check_submitted_images'], all_submitted_images = getFilesinSubmittedImages	#is this needed in tmparchive? is also in imgchecker (imagedir_images)
log_hash['submitted_images'] = all_submitted_images

# Rename and move input files to tmp folder to eliminate possibility of overwriting
log_hash['tmp_folder_created'] = makeTmpFolder

log_hash['old_project_tmp_folder_deleted'] = deleteOldProjectTmpFolder

log_hash['project_tmp_folder_created'] = createProjectTmpFolder

log_hash['project_tmp_img_folder_created'] = createProjectTmpImgFolder

log_hash['copy_input_file'] = copyInputFile

log_hash['moved_input_config_file'] = mvInputConfigFile(input_config)

log_hash['write_alert_file'] = writeAlertFile(filecontents)

# ---------------------- LOGGING

# Write test results
File.open("#{Bkmkr::Paths.log_file}", 'w+') do |f|
	f.puts "-----"
	f.puts Time.now
	f.puts "----- TMPARCHIVE PROCESSES"
	f.puts "finished tmparchive"
end

# Write json log:
log_hash['completed'] = Time.now
Mcmlln::Tools.write_json(json_log_hash, Bkmkr::Paths.json_log)
