require_relative '../config.rb'

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

	    def self.scripts_dir
	      $scripts_dir
	    end

	    def self.resource_dir
	      $resource_dir
	    end

	    # The location where each bookmaker component lives.
		@@core_dir = File.join(scripts_dir, "bookmaker", "core")
		def self.core_dir
			@@core_dir
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

	class Keys
		def self.docraptor_key
	      $docraptor_key
	    end

	    def self.http_username
	      $http_username
	    end

	    def self.http_password
	      $http_password
	    end
	end

	class Tools
		def self.os
			$op_system
		end

		def self.xslprocessor
			$saxon_version
		end
		
		def self.pdfprocessor
			$pdf_processor
		end

		def self.runpython(py_script, input_file)
			if os == "mac" or os == "unix"
				`python #{py_script} #{input_file}`
			elsif os == "windows"
				`python.exe #{py_script} #{input_file}`
			elsif $python_processor
				`#{$python_processor} #{py_script} #{input_file}`
			else
				File.open(Bkmkr::Paths.log_file, 'a+') do |f|
					f.puts "----- PYTHON ERROR"
					f.puts "ERROR: I can't seem to run python. Is it installed and part of your system PATH?"
					f.puts "ABORTING. All following processes will fail."
				end
				File.delete(Project.alert)
			end
		end

		def self.makepdf(pdfprocessor, pisbn, pdf_html_file, pdf_html, testing_value, http_username, http_password)
			if pdfprocessor == "prince"
				`prince #{pdf_html_file} -o #{pisbn}.pdf`
			elsif pdfprocessor == "docraptor"
				pdffile = File.join(Paths.project_tmp_dir, "#{pisbn}.pdf")
				File.open(pdffile, "w+b") do |f|
				f.write DocRaptor.create(:document_content => pdf_html,
				                           :name             => "#{pisbn}.pdf",
				                           :document_type    => "pdf",
				                           :strict			 => "none",
				                           :test             => "#{testing_value}",
					                         :prince_options	 => {
					                           :http_user		 => "#{http_username}",
					                           :http_password	 => "#{http_password}",
					                           :javascript 		 => "true"
											             }
				                       		)
				                           
				end
			else
				pdf_error = File.join(Paths.done_dir, "PDF_ERROR.txt")
				File.open(pdf_error, 'w+') do |output|
					output.write "You have not configured a PDF processor. Please open config.rb and fill in the pdfprocessor variable with either 'prince' or 'docraptor'."
				end
			end
		end
	end
end