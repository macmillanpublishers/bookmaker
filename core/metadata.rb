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

  # def self.final_dir
  #   if Dir.exists?(File.join("#{Bkmkr::Paths.done_dir}","#{@@data_hash['printid']}_#{Bkmkr::Paths.unique_run_id}"))
  #     File.join("#{Bkmkr::Paths.done_dir}","#{@@data_hash['printid']}_#{Bkmkr::Paths.unique_run_id}")
  #   else
  #     File.join("#{Bkmkr::Paths.done_dir}",@@data_hash['printid'])
  #   end
  # end

  # if Dir.exists?(File.join("#{Bkmkr::Paths.done_dir}","#{@@data_hash['printid']}_#{Bkmkr::Paths.unique_run_id}"))
  #   @@final_dir = File.join("#{Bkmkr::Paths.done_dir}","#{@@data_hash['printid']}_#{Bkmkr::Paths.unique_run_id}")
  # else
  #   @@final_dir = File.join("#{Bkmkr::Paths.done_dir}",@@data_hash['printid'])
  # end
  # def self.final_dir
  #   @@final_dir
  # end
  #
  # @@lockfile = File.join(@@final_dir, "layout", "lockfile_#{Bkmkr::Paths.unique_run_id}.txt")
  # def self.lockfile
  #   @@lockfile
  # end

  # # # # # # # METHODS for setting final_dir, lockfolder

  ## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
  def makeFolder(path, logkey='')
  # def self.makeFolder(path, logkey='')
    unless Dir.exist?(path)
      Mcmlln::Tools.makeDir(path)
    else
      logstring = 'n-a'
    end
  rescue => logstring
  ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
  end

  # def self.writeFileWithContents(file, filecontents, logkey='')
  def writeFileWithContents(file, filecontents, logkey='')
    Mcmlln::Tools.overwriteFile(file, filecontents)
  rescue => logstring
  ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
  end

  ## wrapping a Mcmlln::Tools method in a new method for this script; to return a result for json_logfile
  def deleteOldFinalDir(locked, dir, logkey='')
  # def self.deleteOldFinalDir(locked, dir, logkey='')
    if locked == true
    	Mcmlln::Tools.deleteDir(dir)
    else
      logstring = 'n-a'
    end
  rescue => logstring
  ensure
      Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
  end

  def makeLockFiles(final_dir, locked, project_tmpdir, logkey='')
  # def self.makeLockFiles(final_dir, locked, project_tmpdir, logkey='')
    timestamp = Time.now.strftime("%y%m%d-%H%M%S%1N") #timestamp to 10th of a second
    lockfile_basename = "lockfile_#{timestamp}.txt"
    tmpdir_lockfile = File.join(project_tmpdir, lockfile_basename)
    donedir_lockfile = File.join(final_dir, "layout", "lockfile_#{timestamp}.txt")

    # create & rm dirs as needed:
    deleteOldFinalDir(locked, final_dir, 'remove_any_previous_alt_final_dir')
    makeFolder(final_dir, 'create_final_dir')
    makeFolder(File.join(final_dir, "layout"), 'create_final_dir_layout')

    # make lockfile
    writeFileWithContents(tmpdir_lockfile, Time.now.strftime("%y-%m-%s"), 'write_tmpdir_lockfile')
    writeFileWithContents(donedir_lockfile, Time.now.strftime("%y-%m-%s"), 'write_donedir_lockfile')

    # write alertfile if we had to create an alternate final_dir
    if locked == true
      lock_alert_file = File.join(final_dir, "ERROR-Concurrent_Bookmaker_Runs.txt")
      lockalert_text = 'A "done" folder already exists for this title, and appears to be in use.'\
      'Wait 15 minutes and run this file again to ensure all resources are available.'\
      'If you think you\'re getting this malert in error, contact workflows@macmillan.com'
      writeFileWithContents(lock_alert_file, lockalert_text, 'writing_lock_alert_file')
    end
  rescue => logstring
  ensure
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
  end

  def setFinalDir(project_tmpdir, done_dir, pisbn, unique_run_id, logkey='')
  # def self.setFinalDir(project_tmpdir, done_dir, pisbn, unique_run_id, logkey='')
    locked = false
    final_dir = File.join(done_dir, pisbn)
    donedir_lockfile_pathroot = File.join(final_dir, "layout", "lockfile_*.txt")
    # test if default final_dir is already locked
    if !Dir.glob(donedir_lockfile_pathroot).empty?
      strange_lockfile = Dir.glob(donedir_lockfile_pathroot)[0]
      # wait_increment = 60 # < production
      wait_increment = 1 # < debug/test
      max_increments = 15
      n = 0
      # wait and see if final_dir lockfile is deleted
      while File.exist?(strange_lockfile) and n <= max_increments
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
    return final_dir, locked
  rescue => logstring
  ensure
    return final_dir, false
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
  end

  def self.getFinalDir(project_tmpdir, done_dir, pisbn, unique_run_id, logkey='')
    tmpdir_lockfile_pathroot = File.join(project_tmpdir, "lockfile_*.txt")
    if Dir.glob(tmpdir_lockfile_pathroot).empty?
      # lockfiles aren't setup! do it!
      final_dir, locked = setFinalDir(project_tmpdir, done_dir, pisbn, unique_run_id, 'set_final_dir')
      # make Lockfiles, error texts, etc!
      makeLockFiles(final_dir, locked, project_tmpdir, 'make_lockfiles')
    else
      tmpdir_lockfile = Dir.glob(tmpdir_lockfile_pathroot)[0]
      tmpdir_lockfile_basename = tmpdir_lockfile.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).pop
      final_dir_lockfile = Dir.glob(File.join(done_dir,"#{pisbn}*","layout",tmpdir_lockfile_basename))[0]
      final_dir = final_dir_lockfile.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].join(File::SEPARATOR)
    end
    return final_dir
  rescue => logstring
  ensure
    return ''
    Mcmlln::Tools.logtoJson(@log_hash, logkey, logstring)
  end

  @@final_dir = getFinalDir(Bkmkr::Paths.project_tmp_dir, Bkmkr::Paths.done_dir, @@data_hash['printid'], Bkmkr::Paths.unique_run_id)
  def self.final_dir
    @@final_dir
  end
end
