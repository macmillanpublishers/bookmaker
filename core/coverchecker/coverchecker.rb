require 'fileutils'

require_relative '../header.rb'
require_relative '../metadata.rb'

# ---------------------- VARIABLES
local_log_hash, @log_hash = Bkmkr::Paths.setLocalLoghash

# the cover filename
cover = Metadata.frontcover

# The directory where the cover was submitted
coverdir = Bkmkr::Paths.project_tmp_dir_submitted

# the full path to the cover in tmp, including file name
tmp_cover = File.join(Bkmkr::Paths.project_tmp_dir_submitted, cover)

# the full path to the cover in the archival location, including file name
final_cover = File.join(Metadata.final_dir, "cover", cover)

# full path of cover error file
cover_error = File.join(Metadata.final_dir, "COVER_ERROR.txt")

# An array listing all files in the submission dir
files = Mcmlln::Tools.dirList(coverdir)

# ---------------------- METHODS
def readJson(jsonfile, logkey='')
  data_hash = Mcmlln::Tools.readjson(jsonfile)
  return data_hash
rescue => logstring
  return {}
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# If a cover_error file exists, delete it
## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
def checkErrorFile(file, logkey='')
	if File.file?(file)
		Mcmlln::Tools.deleteFile(file)
	else
		logstring = 'n-a'
	end
rescue => logstring
ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# checks to see if cover is in the submission dir
# if yes, copies cover to archival location and deletes from submission dir
# if no, prints an error to the archival directory
def checkCoverFile(arr, file, tmpcover, finalcover, errorfile, coversize_check, logkey='')
	if arr.include?("#{file}") && coversize_check == true
		FileUtils.mv(tmpcover, finalcover)
		covercheck = "Found a new cover submitted"
  elsif arr.include?("#{file}") && coversize_check != true
    FileUtils.mv(tmpcover, finalcover)
    File.open(errorfile, 'w') do |output|
			output.puts coversize_check
		end
    covercheck = "too-small cover submitted, auto-generated one instead, posted err-notice"
	elsif !arr.include?("#{file}") and File.file?(finalcover)
		covercheck = "Picking up existing cover"
	else
		File.open(errorfile, 'w') do |output|
			output.puts "There is no cover image for this title."
			output.puts "Place the cover image file in the submitted_images folder, then re-submit the manuscript for conversion."
			output.puts "Cover image must be named '(isbn)_FC.jpg' (e.g., '9781234567890_FC.jpg')."
		end
		covercheck = "No cover found"
	end
	return covercheck
rescue => logstring
	return ''
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

# ---------------------- PROCESSES
# remove any existing cover error alert
checkErrorFile(cover_error, 'rm_cover_error_file')

sleep 5 #to avoid Errno::EACCES errors re: Fileutils.mv in checkCoverFile method

# get coversize_check from covermaker (if it ran):
jsonlog_hash = readJson(Bkmkr::Paths.json_log, 'read_jsonlog')
if jsonlog_hash.key?("bookmaker_covermaker.rb") && jsonlog_hash["bookmaker_covermaker.rb"].key?("coversize_check")
  coversize_check = jsonlog_hash["bookmaker_covermaker.rb"]["coversize_check"]
else
  coversize_check = true
end

# checks to see if cover is in the submission dir
# if yes, copies cover to archival location and deletes from submission dir
# if no, prints an error to the archival directory
covercheck = checkCoverFile(files, cover, tmp_cover, final_cover, cover_error, coversize_check, 'cover_file_check')
@log_hash['cover_check_results'] = covercheck


# ---------------------- LOGGING
# Write json log:
Mcmlln::Tools.logtoJson(@log_hash, 'completed', Time.now)
Mcmlln::Tools.write_json(local_log_hash, Bkmkr::Paths.json_log)
