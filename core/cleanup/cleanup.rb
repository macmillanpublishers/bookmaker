require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
data_hash = Mcmlln::Tools.readjson(Metadata.configfile)
project_dir = data_hash['project']
stage_dir = data_hash['stage']

# ---------------------- METHODS

# ---------------------- PROCESSES
# Delete all the working files and dirs
Mcmlln::Tools.deleteDir(Bkmkr::Paths.project_tmp_dir)

if File.file?(Bkmkr::Project.input_file)
  Mcmlln::Tools.deleteFile(Bkmkr::Project.input_file)
end

if File.file?(Bkmkr::Paths.alert)
  Mcmlln::Tools.deleteFile(Bkmkr::Paths.alert)
end

# ---------------------- LOGGING
# Printing the test results to the log file
File.open(Bkmkr::Paths.log_file, 'a+') do |f|
  f.puts "----- CLEANUP PROCESSES"
  f.puts "finished cleanup"	
end