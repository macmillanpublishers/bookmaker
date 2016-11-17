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

# ---------------------- PROCESSES
# Delete all the working files and dirs
log_hash['delete_project_tmp_folder'] = Mcmlln::Tools.methodize do
		Mcmlln::Tools.deleteDir(Bkmkr::Paths.project_tmp_dir)
		true
end

log_hash['delete_input_file'] = Mcmlln::Tools.methodize do
  if File.file?(Bkmkr::Project.input_file)
    Mcmlln::Tools.deleteFile(Bkmkr::Project.input_file)
    true
  else
    'n-a'
  end
end

log_hash['delete_alert_file'] = Mcmlln::Tools.methodize do
  if File.file?(Bkmkr::Paths.alert)
    Mcmlln::Tools.deleteFile(Bkmkr::Paths.alert)
    true
  else
    'n-a'
  end
end

# ---------------------- LOGGING
# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
  f.puts "----- CLEANUP PROCESSES"
  f.puts "finished cleanup"
end

# Write json log:
log_hash['completed'] = Time.now
Mcmlln::Tools.write_json(json_log_hash, Bkmkr::Paths.json_log)
