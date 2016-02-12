require 'fileutils'

module Mcmlln
  class Tools

    def self.checkFileExist(file)
      File.exists?("#{file}")
    end

    def self.checkFileEmpty(file)
      File.zero?("#{file}")
    end

    def self.copyFile(file, dest)
      FileUtils.cp(file, dest)
    end

    def self.copyAllFiles(dir, dest)
      FileUtils.cp Dir["#{dir}/*"].select {|f| test ?f, f}, dest
    end

    def self.moveFile(file, dest)
      FileUtils.mv(file, dest)
    end

    def self.deleteDir(dir)
      FileUtils.rm_r(dir)
    end

    def self.deleteFile(file)
      FileUtils.rm(file)
    end

    def self.readFile(file)
      File.read(file)
    end

    def self.makeDir(directory)
      Dir.mkdir(directory)
    end

    # An array listing everything in a directory
    def self.dirList(directory)
      Dir.entries(directory)
    end

    # An array listing all files in a directory
    def self.dirListFiles(directory)
      Dir.entries(directory).select {|f| !File.directory? f}
    end

    def self.readjson(inputfile)
      file = File.open(inputfile, "r:utf-8")
      content = file.read
      json_hash = JSON.parse(content)
      json_hash
    end

    def self.overwriteFile(file, content)
      File.open(file, 'w') do |output| 
        output.write content
      end
    end

  end
end