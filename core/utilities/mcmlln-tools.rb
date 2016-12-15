require 'fileutils'
require 'json'

module Mcmlln
  class Tools

    def self.checkFileExist(file)
      File.exist?("#{file}")
    end

    def self.checkFileEmpty(file)
      File.zero?("#{file}")
    end

    def self.copyFile(file, dest)
      check = Mcmlln::Tools.checkFileExist(file)
      if check == true
        FileUtils.cp(file, dest)
      end
    end

    def self.copyAllFiles(dir, dest)
      FileUtils.cp Dir["#{dir}/*"].select {|f| test ?f, f}, dest
    end

    def self.moveFile(file, dest)
      check = Mcmlln::Tools.checkFileExist(file)
      if check == true
        FileUtils.mv(file, dest)
      end
    end

    def self.deleteDir(dir)
      if Dir.exist?(dir)
        FileUtils.rm_rf(dir)
      end
    end

    def self.deleteFile(file)
      check = Mcmlln::Tools.checkFileExist(file)
      if check == true
        FileUtils.rm(file)
      end
    end

    def self.readFile(file)
      File.read(file)
    end

    def self.makeDir(directory)
      Dir.mkdir(directory)
    end

    # An array listing everything in a directory
    def self.dirList(directory)
      Dir.entries(directory) - ['..', '.']
    end

    # An array listing all files in a directory
    def self.dirListFiles(directory)
      Dir.entries(directory).select {|f| !File.directory? f}
    end

    def self.readjson(inputfile)
      file = File.open(inputfile, "r:utf-8")
      content = file.read
      file.close
      json_hash = JSON.parse(content)
      json_hash
    end

    def self.write_json(hash, json)
      finaljson = JSON.pretty_generate(hash)
      File.open(json, 'w+:UTF-8') { |f| f.puts finaljson }
    end

    def self.overwriteFile(file, content)
      File.open(file, 'w') do |output|
        output.write content
      end
    end

    # for logging all methods in bookmaker to the json_log 
    def self.logtoJson(log_hash, logkey, logstring)
      #if the logkey is empty we skip writing to the log
      unless logkey.empty?
        #if the logstring is mil or undefined, set logstring to true
        if !defined?(logstring) || logstring.nil?
          logstring = true
        end
        log_hash[logkey] = logstring
      end
    rescue => e
      log_hash[logkey] = "LOGGING_ERROR: #{e}"
    end

  end
end
