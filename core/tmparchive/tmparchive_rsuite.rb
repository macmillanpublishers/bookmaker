require 'fileutils'

require_relative '../header.rb'

puts "inputfile: ", "#{Bkmkr::Project.input_file_normalized}"
puts "project tmpdir:", ARGV[1].chomp('"').reverse.chomp('"').reverse
sleep(20)
puts "I'm Done!"
# ---------------------- VARIABLES
# local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash(true)
#
# input_config = File.join(Bkmkr::Paths.submitted_images, "config.json")
#
# tmp_config = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")
#
# # ---------------------- METHODS
# ## all methods for this script are Mcmlln::Tools methods wrapped in new methods,
# ## in order to return results for json_logfile
# def getFilesinSubmittedImages(logkey='')
# 	files = Mcmlln::Tools.dirList(Bkmkr::Paths.submitted_images)
# 	files
# rescue => logstring
# 	return []
# ensure
# 	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
# end
#
# def makeFolder(path, logkey='')
# 	unless Dir.exist?(path)
# 		Mcmlln::Tools.makeDir(path)
# 	else
# 	 logstring = 'n-a'
# 	end
# rescue => logstring
# ensure
# 	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
# end
#
# def deleteOldProjectTmpFolders(project_tmp_dir, logkey='')
#   pathroot, u, count = project_tmp_dir.rpartition('_')
#   dircount = 0
#   Dir.glob("#{pathroot}*") do |p_tmpdir|
#       if p_tmpdir.rpartition('_')[2].to_i > count.to_i
#         dircount += 1
#         Mcmlln::Tools.deleteDir(p_tmpdir)
#       end
#   end
#   if dircount > 0
#     logstring = "deleted #{dircount} tmpdir(s) with higher increment than new one"
#   end
# rescue => logstring
# ensure
# 	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
# end
#
# def copyInputFile(logkey='')
# 	Mcmlln::Tools.copyFile("#{Bkmkr::Project.input_file}", Bkmkr::Paths.project_tmp_file)
# rescue => logstring
# ensure
# 	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
# end
#
# def mvInputConfigFile(input_config, tmp_config, logkey='')
# 	if File.file?(input_config)
# 		Mcmlln::Tools.moveFile(input_config, tmp_config)
# 	else
# 		logstring = 'n-a'
# 	end
# rescue => logstring
# ensure
# 	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
# end
#
# def mvSubmittedFiles(dir, dest, logkey='')
#   Mcmlln::Tools.copyAllFiles(dir, dest)
#   Dir.foreach(dir) {|f|
#     fn = File.join(dir, f)
#     File.delete(fn) if !File.directory?(fn)
#   }
# rescue => logstring
# ensure
# 	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
# end
#
# def writeAlertFile(filecontents, logkey='')
# 	Mcmlln::Tools.overwriteFile(Bkmkr::Paths.alert, filecontents)
# rescue => logstring
# ensure
# 	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
# end
#
# # ---------------------- PROCESSES
# # Local path variables
# all_submitted_images = getFilesinSubmittedImages('check_submitted_images')
# # log submitted image list
# @log_hash['submitted_images'] = all_submitted_images
#
# makeFolder(Bkmkr::Paths.tmp_dir, 'tmp_folder_created')
#
# # make project tmp folder: create new if current exists.
# makeFolder(Bkmkr::Paths.project_tmp_dir, 'project_tmp_folder_created')
#
# # rm any old unique tmp folders for this project with higher increments
# deleteOldProjectTmpFolders(Bkmkr::Paths.project_tmp_dir, 'old_project_tmp_folders_delete')
#
# makeFolder(Bkmkr::Paths.project_tmp_dir_img, 'project_tmp_img_folder_created')
#
# makeFolder(Bkmkr::Paths.project_tmp_dir_submitted, 'project_tmp_submitted_folder created')
#
# mvInputConfigFile(input_config, tmp_config, 'moved_input_config_file')
#
# # Rename and move input files to tmp folder to eliminate possibility of overwriting
# copyInputFile('copy_input_file')
#
# # move all submitted files to project_tmp_dir_submitted
# # => except input file and config.json (already moved above)
# mvSubmittedFiles(Bkmkr::Paths.submitted_images, Bkmkr::Paths.project_tmp_dir_submitted, 'moving_submitted_items_to_tmp')
#
# filecontents = "The conversion processor is currently running. Please do not submit any new files or images until the process completes."
#
# writeAlertFile(filecontents, 'write_alert_file')
#
# # ---------------------- LOGGING
# # Write json log:
# Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
# Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
