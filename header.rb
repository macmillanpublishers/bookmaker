module Bkmkr
	class Project
		@@input_file = 'S:/bookmaker/SMP_egalley/convert/sampledoc.docx'
		def self.input_file
			@@input_file
		end
		@@filename_split = input_file.split("/").pop
		def self.filename_split
			@@filename_split
		end
		@@filename = input_file.split("/").pop.split(".").shift.gsub(/ /, "")
		def self.filename
			@@filename
		end
		@@working_dir_split = input_file.split("/")
		def self.working_dir_split
			@@working_dir_split
		end
		@@working_dir = input_file.split("/")[0...-2].join("/")
		def self.working_dir
			@@working_dir
		end
		@@project_dir = input_file.split("/")[0...-2].pop.split("_").shift
		def self.project_dir
			@@project_dir
		end
		@@stage_dir = input_file.split("/")[0...-2].pop.split("_").pop
		def self.stage_dir
			@@stage_dir
		end
	end
end