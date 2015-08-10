require_relative '../config.rb'

module Bkmkr
	class Project
  		@input_file = File.expand_path(ARGV[0])
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
		@@input_dir = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-1].join(File::SEPARATOR)
		def self.input_dir
			@@input_dir
		end
		@@working_dir = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].join(File::SEPARATOR)
		def self.working_dir
			@@working_dir
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

		# Path to the submitted_assets directory
		def self.submitted_images
			if $assets_dir
				$assets_dir
			else 
				Project.input_dir
			end
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
		def self.done_dir
			if $done_dir
				$done_dir
			else 
				Project.input_dir
			end
		end

		# Full path to project log file
		@@log_file = File.join(log_dir, "#{Project.filename}.txt")
		def self.log_file
			@@log_file
		end
	end

	class Keys
		def self.docraptor_key
	      if $docraptor_key
	      	$docraptor_key
	      else
	      	"none"
	      end
	    end

	    def self.http_username
	      if $http_username
	      	$http_username
	      else
	      	"none"
	      end
	    end

	    def self.http_password
	      if $http_password
	      	$http_password
	      else
	      	"none"
	      end
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

		def self.processimages
			$processimages
		end

		def self.processxsl(html_file, xsl_file, epub_file, convert_log_txt)
			if $xsl_processor
				xsl_command = $xsl_processor.gsub(/\S*\.html/,"#{html_file}").gsub(/\S*\.xsl/,"#{xsl_file}").gsub(/\S*\.epub/,"#{epub_file}")
				`#{xsl_command} 2>>"#{convert_log_txt}"`
			else
				saxonpath = File.join(Bkmkr::Paths.resource_dir, "saxon", "#{xslprocessor}.jar")
				`java -jar "#{saxonpath}" -s:"#{html_file}" -xsl:"#{xsl_file}" -o:"#{epub_file}" 2>>"#{convert_log_txt}"`
			end
		end

		def self.runpython(py_script, input_file)
			if $python_processor
				`#{$python_processor} #{py_script} #{input_file}`
			elsif os == "mac" or os == "unix"
				`python #{py_script} #{input_file}`
			elsif os == "windows"
				pythonpath = File.join(Paths.resource_dir, "Python27", "python.exe")
				`#{pythonpath} #{py_script} #{input_file}`
			else
				File.open(Bkmkr::Paths.log_file, 'a+') do |f|
					f.puts "----- PYTHON ERROR"
					f.puts "ERROR: I can't seem to run python. Is it installed and part of your system PATH?"
					f.puts "ABORTING. All following processes will fail."
				end
				File.delete(Project.alert)
			end
		end
		def self.makepdf(pdfprocessor, pisbn, pdf_html_file, pdf_html, pdf_css, testing_value, http_username, http_password)
			pdffile = File.join(Paths.project_tmp_dir, "#{pisbn}.pdf")
			if pdfprocessor == "prince"
				`prince -s #{pdf_css} --javascript #{pdf_html_file} -o #{pdffile}`
			elsif pdfprocessor == "docraptor"
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
		def self.insertaddons(inputfile, sectionparams, addonparams)
			# The section types JSON
			sectionfile = sectionparams
			file2 = File.read(sectionfile)
			section_hash = JSON.parse(file2)

			# The addon files JSON
			addonfile = addonparams
			file3 = File.read(addonfile)
			addon_hash = JSON.parse(file3)

			# figure out which addon files to apply
			addons = []

			addon_hash['projects'].each do |p|
				if p['name'] == Project.working_dir.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).pop
					addons = p['addons']
				end
			end

			puts "Addons to insert: #{addons}"
			addons = addons.split(",")

			contents = File.read(inputfile)

			# Set preliminary var values, in case of null values
			locationtype = ""
			locationclass = ""
			locationcontainer = ""
			order = "before"
			sequence = 1
			locationname = ""

			# for each addon, apply it to the HTML
			addons.each do |a|
				addon_hash['files'].each do |f|
					if f['filename'] == a
						validlocations = []
						order = "before"

						# figure out where to insert the new content
						f['locations'].each do |l|
							section = true
							datatype = true
							thisclass = true
							section_hash['sections'].each do |x|
								if x['name'] == l['name']
									if x['containertype']
										fsection = x['containertype']
										search = contents.scan(/#{fsection}/)
										unless search.any?
											section = false
										end
									end
									if x['datatype']
										fdatatype = x['datatype']
										search = contents.scan(/data-type="#{fdatatype}"/)
										unless search.any?
											datatype = false
										end
									end
									if x['class']
										fclass = x['class']
										search = contents.scan(/class="#{fclass}"/)
										unless search.any?
											thisclass = false
										end
									end
								end
							end
							if section == true and datatype == true and thisclass == true
								validlocations << l['name']
							end
						end

						location = validlocations.shift
						puts "insertion location is: #{location}"

						# get insertion point values from first existing location
						section_hash['sections'].each do |w|
							if w['name'] == location
								if w['datatype'] then locationtype = w['datatype'] end
								if w['class'] then locationclass = w['class'] end
								if w['containertype'] then locationcontainer = w['containertype'] end
							end
						end

						f['locations'].each do |v|
							if v['name'] == location
								if v['sequence'] then sequence = v['sequence'] end
								if v['order'] then order = v['order'] end
							end
						end

						addonfiledir = addonparams.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-1]
						addonfile = File.join(addonfiledir, f['filename'])
						addoncontent = File.read(addonfile).gsub(/\n/,"").gsub(/"/,"\\\"")

						# puts "2= #{inputfile}"
						# puts "3= #{addoncontent}"
						# puts "4= #{locationcontainer}"
						# puts "5= #{locationtype}"
						# puts "6= #{locationclass}"
						# puts "7= #{sequence}"
						# puts "8= #{location}"
						puts "9= #{order}"

						jsfile = File.join(Paths.core_dir, "utilities", "insertaddon.js")

						# Insert the addon via node.js
						`node #{jsfile} "#{inputfile}" "#{addoncontent}" "#{locationcontainer}" "#{locationtype}" "#{locationclass}" "#{sequence}" "#{order}" "#{location}"`

						puts "inserted #{addonfile}"
					end
				end
			end
		end
		def self.movesection(inputfile, sectionparams, src, srcseq, dest, destseq)
			# The section types JSON
			sectionfile = sectionparams
			file2 = File.read(sectionfile)
			section_hash = JSON.parse(file2)

			contents = File.read(inputfile)

			# Set preliminary var values, in case of null values
			srctype = ""
			srcclass = ""
			srccontainer = ""
			desttype = ""
			destclass = ""
			destcontainer = ""

			# get source values from src section hash
			section_hash['sections'].each do |w|
				if w['name'] == src
					if w['datatype'] then srctype = w['datatype'] end
					if w['class'] then srcclass = w['class'] end
					if w['containertype'] then srccontainer = w['containertype'] end
				elsif w['name'] == dest
					if w['datatype'] then desttype = w['datatype'] end
					if w['class'] then destclass = w['class'] end
					if w['containertype'] then destcontainer = w['containertype'] end
				end
			end

			# puts "2= #{inputfile}"
			# puts "3= #{srccontainer}"
			# puts "4= #{srctype}"
			# puts "5= #{srcclass}"
			# puts "6= #{srcseq}"
			# puts "7= #{destcontainer}"
			# puts "8= #{desttype}"
			# puts "9= #{destclass}"
			# puts "10= #{destseq}"

			jsfile = File.join(Paths.core_dir, "utilities", "movesection.js")

			# Insert the addon via node.js
			`node #{jsfile} "#{inputfile}" "#{srccontainer}" "#{srctype}" "#{srcclass}" "#{srcseq}" "#{destcontainer}" "#{desttype}" "#{destclass}" "#{destseq}"`
		end
		def self.compileJS(file)
			jsfile = File.join(Paths.core_dir, "utilities", "evaltemplates.js")
			templates = File.read(file).scan(/(")(eval-\S+)(")/)
			templates.each do |t|
				`node #{jsfile} "#{file}" "#{t[1]}"`
			end
		end
	end
end