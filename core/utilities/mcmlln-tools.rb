module Mcmlln
  class Tools

    def self.checkFileExist(file)
      File.exists?("#{file}")
    end

    def self.checkFileEmpty(file)
      File.zero?("#{file}")
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

    # An array listing all files in a directory
    def self.dirList(directory)
      Dir.entries(directory)
    end

    def self.readjson(inputfile)
      file = File.read(inputfile)
      json_hash = JSON.parse(file)
      json_hash
    end

  end
end