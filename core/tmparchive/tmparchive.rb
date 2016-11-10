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

# ---------------------- PROCESSES

# For TEST purposes
test_images_before = Mcmlln::Tools.dirList(Bkmkr::Paths.submitted_images)

# Local path variables
all_submitted_images = Mcmlln::Tools.dirList(Bkmkr::Paths.submitted_images)

# Rename and move input files to tmp folder to eliminate possibility of overwriting
def createTmpDir()
	unless Dir.exist?(Bkmkr::Paths.tmp_dir)
		Mcmlln::Tools.makeDir(Bkmkr::Paths.tmp_dir)
		return true
	else
		return 'n-a'
	end
rescue => e
	return e
end
log_hash['tmp_folder_created'] = createTmpDir

def deleteProjectTmpDir()
	if Dir.exist?(Bkmkr::Paths.project_tmp_dir)
		Mcmlln::Tools.deleteDir(Bkmkr::Paths.project_tmp_dir)
		return true
	else
		return 'n-a'
	end
rescue => e
	return e
end
log_hash['old_project_tmp_folder_deleted'] = deleteProjectTmpDir

def createProjectTmpDir()
	Mcmlln::Tools.makeDir(Bkmkr::Paths.project_tmp_dir)
	return true
rescue => e
	return e
end
log_hash['project_tmp_folder_created'] = createProjectTmpDir

def createProjectTmpImgDir()
	Mcmlln::Tools.makeDir(Bkmkr::Paths.project_tmp_dir_img)
	return true
rescue => e
	return e
end
log_hash['project_tmp_img_folder_created'] = createProjectTmpImgDir

def copyInputFile()
	Mcmlln::Tools.copyFile("#{Bkmkr::Project.input_file}", Bkmkr::Paths.project_tmp_file)
	return true
rescue => e
	return e
end
log_hash['copy_input_file'] = copyInputFile

def mvInputConfigFile(input_config, tmp_config)
	if File.file?(input_config)
		Mcmlln::Tools.moveFile(input_config, tmp_config)
		return true
	else
		return 'n-a'
	end
rescue => e
	return e
end
log_hash['moved_input_config_file'] = mvInputConfigFile(input_config, tmp_config)

def writeAlertFile(filecontents)
	Mcmlln::Tools.overwriteFile(Bkmkr::Paths.alert, filecontents)
	return true
rescue => e
	return e
end
log_hash['copy_input_file'] = writeAlertFile(filecontents)


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
