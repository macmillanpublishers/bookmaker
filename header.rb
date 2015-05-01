module Bkmkr
	class Project
		@@input_file = ARGV[0]
		def self.input_file
			@@input_file
		end
		@@filename_split = input_file.split("\\").pop
		def self.filename_split
			@@filename_split
		end
		@@filename = input_file.split("\\").pop.split(".").shift.gsub(/ /, "")
		def self.filename
			@@filename
		end
		@@working_dir_split = input_file.split("\\")
		def self.working_dir_split
			@@working_dir_split
		end
		@@working_dir = input_file.split("\\")[0...-2].join("\\")
		def self.working_dir
			@@working_dir
		end
		@@project_dir = input_file.split("\\")[0...-2].pop.split("_").shift
		def self.project_dir
			@@project_dir
		end
		@@stage_dir = input_file.split("\\")[0...-2].pop.split("_").pop
		def self.stage_dir
			@@stage_dir
		end
	end

	class Dir

		def self.currpath
			`cd`
		end

		@@currvol = Dir.currpath.split('\\').shift
		def self.currvol
			@@currvol
		end

		@@tmp_dir = "#{@@currvol}\\bookmaker_tmp"
		def self.tmp_dir
			@@tmp_dir
		end

		@@log_dir = "S:\\resources\\logs"
		def self.log_dir
			@@log_dir
		end

		@@bookmaker_dir = "S:\\resources\\bookmaker_scripts"
		def self.bookmaker_dir
			@@bookmaker_dir
		end

		@@resource_dir = "C:"
		def self.resource_dir
			@@resource_dir
		end
	end

	class Metadata

	end
end