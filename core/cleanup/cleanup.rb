require_relative '../header.rb'
require_relative '../metadata.rb'

data_hash = Bkmkr::Tools.readjson(Metadata.configfile)
project_dir = data_hash['project']
stage_dir = data_hash['stage']

# Delete all the working files and dirs
Bkmkr::Tools.deleteDir(Bkmkr::Paths.project_tmp_dir)
Bkmkr::Tools.deleteFile(Bkmkr::Project.input_file)
Bkmkr::Tools.deleteFile(Bkmkr::Paths.alert)

# LOGGING

# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
  f.puts "----- CLEANUP PROCESSES"
  f.puts "finished cleanup"	
end