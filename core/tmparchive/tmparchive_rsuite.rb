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

def getDesignTemplateCSS(all_submitted_files, logkey='')
  templatecss_name = ''
  for filename in all_submitted_files
    if filename.include?('__')
      templatecss_name = filename
      all_submitted_files.delete(filename)
    end
    break
  end
  return templatecss_name, all_submitted_files
rescue => logstring
ensure
  Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def writeCSStoFile(sourcefile, targetfile, css_comment, logkey='')
  css = File.read(sourcefile)
  File.open(targetfile, 'a+') do |o|
    o.puts " "
    o.puts "/* #{css_comment} */"
    o.write css
  end
rescue => logstring
ensure
	Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
end

def consolidateSubmittedCSS(css_type, all_submitted_files, dir, logkey='')
  oneoff_filename = "oneoff_#{css_type}.css"
  oneoff_file = File.join(dir, oneoff_filename)
  css_snippetfiles = all_submitted_files.select {|x| x.include?('.css') && x.include?("#{css_type}_")}

  # check if we have snippet files _and_ oneoff of this type; if so: consolidate into tmp oneoff, then overwrite existing oneoff
  if !css_snippetfiles.empty? && all_submitted_files.include?(oneoff_filename)
    tmp_cssfile = "tmp_#{css_type}.css"
    tmp_cssfile = File.join(dir, tmpcss_filename)
    for snippet_filename in css_snippetfiles
      css_comment = "Writing css from \"#{snippet_filename}\", to #{oneoff_filename}"
      writeCSStoFile(File.join(dir, snippet_filename), tmp_cssfile, css_comment, "writing_#{css_type}_snippet_to_tmpcss")
    end
    # write oneoff contents to tmp css
    css_comment = "Writing css from \"#{oneoff_filename}\" back into #{oneoff_filename} via tmpfile"
    writeCSStoFile(oneoff_file, tmp_cssfile, css_comment, "writing_#{css_type}_oneoff_to_tmpcss")
    # now read all contents of tmp css, overwrite oneoff_pdf.css
    tmpcss = File.read(tmp_cssfile)
    Mcmlln::Tools.overwriteFile(oneoff_file, tmpcss)
    logstring = "----- Found snippet files #{css_snippetfiles} and #{oneoff_filename}. Consolidated all into #{oneoff_filename}"

  # now  if we just have snippet files (no pre-existing oneoff)
  elsif !css_snippetfiles.empty?
    for snippet_filename in css_snippetfiles
      css_comment = "Writing css from \"#{snippet_filename}\", to #{oneoff_filename}"
      writeCSStoFile(File.join(dir, snippet_filename), oneoff_file, css_comment, "writing_#{css_type}_snippet_to_oneoffcss")
    end
    logstring = "----- Found snippet files: #{css_snippetfiles}. Consolidated into #{oneoff_filename}"
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

  templatecss_name, all_submitted_files = getDesignTemplateCSS(all_submitted_files, 'get_design_template_CSS')
  if !templatecss_name.empty?
    # could delete the dummy css file here but doesn't really matter
    @log_hash['rs_templatecss_name'] = templatecss_name
    rsuite_metadata_hash['rs_design_template'] = rs_server
  end

  # users may have submitted css snippets from snippet library in RSuite. These (plus any oneoffcss) need to be consolidated,
  #   into oneoff_pdf.css and oneoff_epub.css.
  #   snippet filenames should begin with 'epub_' or 'pdf_'
  consolidateSubmittedCSS('pdf', all_submitted_files, Bkmkr::Paths.project_tmp_dir_submitted, 'consolidate_rsuite_submitted_css-pdf')
  consolidateSubmittedCSS('epub', all_submitted_files, Bkmkr::Paths.project_tmp_dir_submitted, 'consolidate_rsuite_submitted_css-epub')

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
