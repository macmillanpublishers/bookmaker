module Bkmkr
	class Project
		@@input_file = ARGV[0]
		def self.input_file
			@@input_file
		end
		@@filename_split = input_file.split(File::SEPARATOR).pop
		def self.filename_split
			@@filename_split
		end
		@@filename = input_file.split(File::SEPARATOR).pop.split(".").shift.gsub(/ /, "")
		def self.filename
			@@filename
		end
		@@filename_normalized = filename_split.gsub(/ /, "")
		def self.filename_normalized
			@@filename_normalized
		end
		@@working_dir_split = input_file.split(File::SEPARATOR)
		def self.working_dir_split
			@@working_dir_split
		end
		@@working_dir = input_file.split(File::SEPARATOR)[0...-2].join(File::SEPARATOR)
		def self.working_dir
			@@working_dir
		end
		@@project_dir = input_file.split(File::SEPARATOR)[0...-2].pop.split("_").shift
		def self.project_dir
			@@project_dir
		end
		@@stage_dir = input_file.split(File::SEPARATOR)[0...-2].pop.split("_").pop
		def self.stage_dir
			@@stage_dir
		end
	end

	class Dir
		def self.currpath
			`cd`
		end

		@@currvol = Dir.currpath.split(File::SEPARATOR).shift
		def self.currvol
			@@currvol
		end

		@@tmp_dir = File.join(currvol, "bookmaker_tmp")
		def self.tmp_dir
			@@tmp_dir
		end

		@@log_dir = File.join("S:", "resources", "logs")
		def self.log_dir
			@@log_dir
		end

		@@bookmaker_dir = File.join("S:", "resources", "bookmaker_scripts")
		def self.bookmaker_dir
			@@bookmaker_dir
		end

		@@resource_dir = "C:"
		def self.resource_dir
			@@resource_dir
		end

		@@submitted_images = File.join(Project.working_dir, "submitted_images")
		def self.submitted_images
			@@submitted_images
		end

		@@project_tmp_dir = File.join(tmp_dir, Project.filename)
		def self.project_tmp_dir
			@@project_tmp_dir
		end

		@@project_tmp_dir_img = File.join(tmp_dir, Project.filename, "images")
		def self.project_tmp_dir_img
			@@project_tmp_dir_img
		end

		@@project_tmp_file = File.join(tmp_dir, Project.filename, Project.filename_normalized)
		def self.project_tmp_file
			@@project_tmp_file
		end

		@@alert = File.join(Project.working_dir, "IN_USE_PLEASE_WAIT.txt")
		def self.alert
			@@alert
		end
	end

	class Metadata

	end
end