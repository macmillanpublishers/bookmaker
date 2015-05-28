require_relative '../bookmaker/config.rb'

module Bkmkr
	class Project
  		@input_file = ARGV[0]
  		@@input_file = @input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).join(File::SEPARATOR)
		def self.input_file
			@@input_file
		end
		@@filename_split = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).pop
		def self.filename_split
			@@filename_split
		end
		@@filename = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).pop.split(".").shift.gsub(/ /, "")
		def self.filename
			@@filename
		end
		@@filename_normalized = filename_split.gsub(/ /, "")
		def self.filename_normalized
			@@filename_normalized
		end
		@@working_dir_split = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))
		def self.working_dir_split
			@@working_dir_split
		end
		@@working_dir = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].join(File::SEPARATOR)
		def self.working_dir
			@@working_dir
		end
		@@project_dir = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].pop.to_s.split("_").shift
		def self.project_dir
			@@project_dir
		end
		@@stage_dir = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].pop.to_s.split("_").pop
		def self.stage_dir
			@@stage_dir
		end
	end

  class Paths
    def self.tmp_dir
      $tmp_dir
    end

    def self.log_dir
      $log_dir
    end

    def self.bookmaker_dir
      $bookmaker_dir
    end

    def self.resource_dir
      $resource_dir
    end

		# Path to the submitted_images directory
		@@submitted_images = File.join(Project.working_dir, "submitted_images")
		def self.submitted_images
			@@submitted_images
		end

		# Path to the temporary working directory
		@@project_tmp_dir = File.join(tmp_dir, Project.filename)
		def self.project_tmp_dir
			@@project_tmp_dir
		end

		# Path to the images subdirectory of the temporary working directory
		@@project_tmp_dir_img = File.join(tmp_dir, Project.filename, "images")
		def self.project_tmp_dir_img
			@@project_tmp_dir_img
		end
		
		# Full path to outputtmp.html file
		@@outputtmp_html = File.join(tmp_dir, Project.filename, "outputtmp.html")
		def self.outputtmp_html
			@@outputtmp_html
		end
		
		# Full path and filename for the normalized (i.e., spaces removed) input file in the temporary working dir
		@@project_tmp_file = File.join(tmp_dir, Project.filename, Project.filename_normalized)
		def self.project_tmp_file
			@@project_tmp_file
		end

		# Full path and filename for the "in use" alert that is created
		@@alert = File.join(Project.working_dir, "IN_USE_PLEASE_WAIT.txt")
		def self.alert
			@@alert
		end

		# Full path and filename for the "done" directory in Project working directory
		@@done_dir = File.join(Project.working_dir, "done")
		def self.done_dir
			@@done_dir
		end

		# Full path to project log file
		@@log_file = File.join(log_dir, "#{Project.filename}.txt")
		def self.log_file
			@@log_file
		end
	end
end