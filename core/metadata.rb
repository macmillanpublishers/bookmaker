require 'json'

require_relative 'header.rb'

class Metadata

	@@configfile = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")
	def self.configfile
		@@configfile
	end

	@@data_hash = Mcmlln::Tools.readjson(configfile)

	def self.booktitle
		if @@data_hash['title'].nil? or @@data_hash['title'].empty? or !@@data_hash['title']
			Bkmkr::Project.filename
		else
			@@data_hash['title']
		end
	end

	def self.booksubtitle
		if @@data_hash['subtitle'].nil? or @@data_hash['subtitle'].empty? or !@@data_hash['subtitle']
			"Unknown"
		else
			@@data_hash['subtitle']
		end
	end

	def self.bookauthor
		if @@data_hash['author'].nil? or @@data_hash['author'].empty? or !@@data_hash['author']
			"Unknown"
		else
			@@data_hash['author']
		end
	end

	def self.productid
		if @@data_hash['productid'].nil? or @@data_hash['productid'].empty? or !@@data_hash['productid']
			Bkmkr::Project.filename
		else
			@@data_hash['productid']
		end
	end

	def self.pisbn
		if @@data_hash['printid'].nil? or @@data_hash['printid'].empty? or !@@data_hash['printid']
			Bkmkr::Project.filename
		else
			@@data_hash['printid']
		end
	end

	def self.eisbn
		if @@data_hash['ebookid'].nil? or @@data_hash['ebookid'].empty? or !@@data_hash['ebookid']
			Bkmkr::Project.filename
		else
			@@data_hash['ebookid']
		end
	end

	def self.imprint
		if @@data_hash['imprint'].nil? or @@data_hash['imprint'].empty? or !@@data_hash['imprint']
			"Unknown"
		else
			@@data_hash['imprint']
		end
	end

	def self.publisher
		if @@data_hash['publisher'].nil? or @@data_hash['publisher'].empty? or !@@data_hash['publisher']
			"Unknown"
		else
			@@data_hash['publisher']
		end
	end

	def self.printcss
		if @@data_hash['printcss'].nil? or @@data_hash['printcss'].empty? or !@@data_hash['printcss']
			"none"
		else
			@@data_hash['printcss']
		end
	end

	def self.printjs
		if @@data_hash['printjs'].nil? or @@data_hash['printjs'].empty? or !@@data_hash['printjs']
			"none"
		else
			@@data_hash['printjs']
		end
	end

	def self.epubcss
		if @@data_hash['ebookcss'].nil? or @@data_hash['ebookcss'].empty? or !@@data_hash['ebookcss']
			"none"
		else
			@@data_hash['ebookcss']
		end
	end

	def self.frontcover
		if @@data_hash['frontcover'].nil? or @@data_hash['frontcover'].empty? or !@@data_hash['frontcover']
			"Unknown"
		else
			@@data_hash['frontcover']
		end
	end

	def self.epubtitlepage
		if @@data_hash['epubtitlepage'].nil? or @@data_hash['epubtitlepage'].empty? or !@@data_hash['epubtitlepage']
			"Unknown"
		else
			@@data_hash['epubtitlepage']
		end
	end

	def self.podtitlepage
		if @@data_hash['podtitlepage'].nil? or @@data_hash['podtitlepage'].empty? or !@@data_hash['podtitlepage']
			"Unknown"
		else
			@@data_hash['podtitlepage']
		end
	end

  def self.final_dir
    # set a default final_dir
    final_dir = File.join(Bkmkr::Paths.done_dir, @@data_hash['printid'])
    # now find true final_dir based on lockfiles
    tmpdir_lockfile_pathroot = File.join(Bkmkr::Paths.project_tmp_dir, "lockfile_*.txt")
    if !Dir.glob(tmpdir_lockfile_pathroot).empty?
      # get lockfile
      tmpdir_lockfile = Dir.glob(tmpdir_lockfile_pathroot)[0]
      tmpdir_lockfile_basename = tmpdir_lockfile.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).pop
      # look for matching lockfile in Done dirs
      final_dir_lockfile_arr = Dir.glob(File.join(Bkmkr::Paths.done_dir,"#{@@data_hash['printid']}*","layout",tmpdir_lockfile_basename))
      if !final_dir_lockfile_arr.empty?
        final_dir_lockfile = final_dir_lockfile_arr[0]
        final_dir = final_dir_lockfile.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].join(File::SEPARATOR)
      end
    end
    final_dir
  end

  # # # # # # # METHODS for setting final_dir, lockfolder

  ## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
  def self.makeFolder(path, log_hash, logkey='')
    unless Dir.exist?(path)
      Mcmlln::Tools.makeDir(path)
    else
      logstring = 'n-a'
    end
  rescue => logstring
  ensure
    Mcmlln::Tools.logtoJson(log_hash, logkey, logstring)
    return log_hash
  end

  def self.writeFileWithContents(file, filecontents, log_hash, logkey='')
    Mcmlln::Tools.overwriteFile(file, filecontents)
  rescue => logstring
  ensure
    Mcmlln::Tools.logtoJson(log_hash, logkey, logstring)
    return log_hash
  end

  ## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
  def self.deleteOldFinalDir(locked, dir, log_hash, logkey='')
    if locked == true
      Mcmlln::Tools.deleteDir(dir)
    else
      logstring = 'n-a'
    end
  rescue => logstring
  ensure
    Mcmlln::Tools.logtoJson(log_hash, logkey, logstring)
    return log_hash
  end

  def self.makeLockFiles(final_dir, locked, project_tmpdir, log_hash, logkey='')
    timestamp = Time.now.strftime("%y%m%d-%H%M%S%1N") #timestamp to 10th of a second
    lockfile_basename = "lockfile_#{timestamp}.txt"
    tmpdir_lockfile = File.join(project_tmpdir, lockfile_basename)
    donedir_lockfile = File.join(final_dir, "layout", "lockfile_#{timestamp}.txt")

    # create & rm dirs as needed:
    deleteOldFinalDir(locked, final_dir, log_hash, 'metadata.rb-remove_any_previous_alt_final_dir')
    makeFolder(final_dir, log_hash, 'metadata.rb-create_final_dir')
    makeFolder(File.join(final_dir, "layout"), log_hash, 'metadata.rb-create_final_dir_layout')

    # make lockfile
    writeFileWithContents(tmpdir_lockfile, timestamp, log_hash, 'metadata.rb-write_tmpdir_lockfile')
    writeFileWithContents(donedir_lockfile, timestamp, log_hash, 'metadata.rb-write_donedir_lockfile')

    # write alertfile if we had to create an alternate final_dir
    if locked == true
      lock_alert_file = File.join(final_dir, "ERROR-Concurrent_Bookmaker_Runs.txt")
      lockalert_text = 'A "done" folder already exists for this title, and appears to be in use. '\
      'Wait 15 minutes and run this file again to ensure all resources are available. '\
      'If you think you\'re getting this alert in error, contact workflows@macmillan.com'
      writeFileWithContents(lock_alert_file, lockalert_text, log_hash, 'metadata.rb-writing_lock_alert_file')
    end
  rescue => logstring
  ensure
    Mcmlln::Tools.logtoJson(log_hash, logkey, logstring)
    return log_hash
  end

  def self.setFinalDir(project_tmpdir, done_dir, pisbn, unique_run_id, log_hash, logkey='')
    locked = false
    final_dir = File.join(done_dir, pisbn)
    donedir_lockfile_pathroot = File.join(final_dir, "layout", "lockfile_*.txt")
    # if we are running files dropped from rsuite, we always create/use a unique done folder.
    # => just checking for presence of rsuite_metadata.json as evidence of rsuite run
    if File.exist?(Bkmkr::Paths.fromrsuite_Metadata_json)
      final_dir = File.join(done_dir, "#{pisbn}_#{Time.now.strftime("%y%m%d-%H%M%S")}")
      logstring = "this is an rs->bkmkr run, spawning new donedir: \"#{pisbn}_#{unique_run_id}\""
    # other cases are non-rsuite>bkmkr runs:
    # => test if default final_dir is already locked
    elsif !Dir.glob(donedir_lockfile_pathroot).empty?
      strange_lockfile = Dir.glob(donedir_lockfile_pathroot)[0]
      wait_increment = 60 # < production
      if $op_system == "mac"
        wait_increment = 1 # < debug/test
      end
      max_increments = 15
      n = 0
      # wait and see if final_dir lockfile is deleted
      while File.exist?(strange_lockfile) and n < max_increments
        sleep(wait_increment)
        n += 1
      end
      # check again after whileloop
      if File.exist?(strange_lockfile) # still locked :(
        final_dir = File.join(done_dir, "#{pisbn}_#{unique_run_id}")
        locked = true
        logstring = "final_dir locked for #{n} minutes, setting new one: #{final_dir}"
      else
        logstring = "existing final_dir was locked, unlocked after #{n} minutes"
      end
    else
      # final_dir not locked at all!
      logstring = "no pre-existing final_dir, or existing one not locked"
    end
  rescue => logstring
    final_dir = ''
    locked = false
  ensure
    Mcmlln::Tools.logtoJson(log_hash, logkey, logstring)
    return final_dir, locked, log_hash
  end

  def self.setupFinalDir(project_tmpdir, done_dir, pisbn, unique_run_id, log_hash, logkey='')
    tmpdir_lockfile_pathroot = File.join(project_tmpdir, "lockfile_*.txt")
    if Dir.glob(tmpdir_lockfile_pathroot).empty?
      # lockfiles aren't setup! do it!
      final_dir, locked = setFinalDir(project_tmpdir, done_dir, pisbn, unique_run_id, log_hash, 'metadata.rb-set_final_dir')
      # make Lockfiles, error texts, etc!
      makeLockFiles(final_dir, locked, project_tmpdir, log_hash, 'metadata.rb-make_lockfiles')
    else
      tmpdir_lockfile = Dir.glob(tmpdir_lockfile_pathroot)[0]
      tmpdir_lockfile_basename = tmpdir_lockfile.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).pop
      final_dir_lockfile_arr = Dir.glob(File.join(done_dir,"#{pisbn}*","layout",tmpdir_lockfile_basename))
      if final_dir_lockfile_arr.empty?
        # somehow done_dir got deleted (likely in course of troubleshooting). Reset, make new lockfiles
        Mcmlln::Tools.deleteFile(tmpdir_lockfile)
        final_dir = File.join(done_dir, pisbn)
        makeLockFiles(final_dir, false, project_tmpdir, log_hash, 'metadata.rb-make_lockfiles')
      else
        final_dir_lockfile = final_dir_lockfile_arr[0]
        final_dir = final_dir_lockfile.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].join(File::SEPARATOR)
      end
      final_dir = final_dir_lockfile.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].join(File::SEPARATOR)
    end
  rescue => logstring
    final_dir = ''
  ensure
    Mcmlln::Tools.logtoJson(log_hash, logkey, logstring)
    return final_dir, log_hash
  end
end
