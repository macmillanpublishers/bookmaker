require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
json_log_hash = Bkmkr::Paths.jsonlog_hash
json_log_hash[Bkmkr::Paths.thisscript] = {}
log_hash = json_log_hash[Bkmkr::Paths.thisscript]

data_hash = Mcmlln::Tools.readjson(Metadata.configfile)
project_dir = data_hash['project']
stage_dir = data_hash['stage']

# ---------------------- METHODS
def deleteProjectTmpDir
	Mcmlln::Tools.deleteDir(Bkmkr::Paths.project_tmp_dir)
	true
rescue => e
	e
end

def deleteFileifExists(file)
	if File.file?(file)
		Mcmlln::Tools.deleteFile(file)
		true
	else
		'n-a'
	end
rescue => e
	e
end

# ---------------------- PROCESSES
# Delete all the working files and dirs
log_hash['delete_project_tmp_folder'] = deleteProjectTmpDir

log_hash['delete_input_file'] = deleteFileifExists(Bkmkr::Project.input_file)

log_hash['delete_alert_file'] = deleteFileifExists(Bkmkr::Paths.alert)

# ---------------------- LOGGING
# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
  f.puts "----- CLEANUP PROCESSES"
  f.puts "finished cleanup"
end

# Write json log:
log_hash['completed'] = Time.now
Mcmlln::Tools.write_json(json_log_hash, Bkmkr::Paths.json_log)
