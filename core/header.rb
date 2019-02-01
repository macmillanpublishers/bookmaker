require 'bundler/setup'
require "open-uri"
require 'fileutils'
require 'open3'

require_relative '../config.rb'
require_relative 'utilities/mcmlln-tools.rb'

module Bkmkr
	class Project
		unless ARGV.empty?		#adding this check for testing purposes
			@unescapeargv = ARGV[0].chomp('"').reverse.chomp('"').reverse
		else
			@unescapeargv = '/test/test/test.docx'
			puts "WARNING, no input file!!!"
		end
  		@input_file = File.expand_path(@unescapeargv)
  		@@input_file = @input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).join(File::SEPARATOR)
		def self.input_file
			@@input_file
		end
		@@input_file_normalized = input_file.gsub(/ /, "")
		def self.input_file_normalized
			@@input_file_normalized
		end
		@@filename_split = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).pop
		def self.filename_split
			@@filename_split
		end
		@@filename = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).pop.rpartition('.').first.gsub(/ /, "")
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

      @@log_archive_dir = File.join(log_dir, "past")
      def self.log_archive_dir
	      @@log_archive_dir
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
		@@project_tmp_dir_img = File.join(project_tmp_dir, "images")
		def self.project_tmp_dir_img
			@@project_tmp_dir_img
		end

		# Full path to outputtmp.html file
		@@outputtmp_html = File.join(project_tmp_dir, "outputtmp.html")
		def self.outputtmp_html
			@@outputtmp_html
		end

		# Full path and filename for the normalized (i.e., spaces removed) input file in the temporary working dir
		@@project_tmp_file = File.join(project_tmp_dir, Project.filename_normalized)
		def self.project_tmp_file
			@@project_tmp_file
		end

		# Full path and filename for the .docx file
		@@project_docx_file = File.join(project_tmp_dir, "#{Project.filename}.docx")
		def self.project_docx_file
			@@project_docx_file
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

		@@thisscript = File.basename($0)		#for easy reference to script's own name in json-logs
		def self.thisscript
			@@thisscript
		end

		# Full path to project json logfile
		@@json_log = File.join(log_dir, "#{Project.filename}.json")
		def self.json_log
			@@json_log
		end

		#hash from json log
		def self.jsonlog_hash
			json_hash = {}
			if File.file?(@@json_log)
				file = File.open(@@json_log, "r:utf-8")
				content = file.read
				file.close
				json_hash = JSON.parse(content)
			end
			json_hash
		end

		# for any script that calls this method:
		# create 'local_log' hash nested in the jsonlog_hash named after the script basename
		# add a 'begun' key/value to the new local hash
		def self.setLocalLoghash(new_hash=false)
			# if we receive optional new_hash value of 'true', we overwrite jsonlog contents & starting with a fresh new hash
			unless new_hash == true
		  	local_log_hash = Bkmkr::Paths.jsonlog_hash
			else
				local_log_hash = {}
        # archive existing json_logfile:
				if File.exist?(Bkmkr::Paths.json_log)
					archived_jsonlog = File.join(Bkmkr::Paths.log_archive_dir, "#{Project.filename}_ARCHIVED_#{Time.now.strftime('%Y-%m-%d-%H%M')}.json")
          if !Dir.exist?(Bkmkr::Paths.log_archive_dir)
            Mcmlln::Tools.makeDir(Bkmkr::Paths.log_archive_dir)
          end
          Mcmlln::Tools.moveFile(Bkmkr::Paths.json_log, archived_jsonlog)
				end
			end
		  local_log_hash[Bkmkr::Paths.thisscript] = {'begun'=>Time.now}
		  return local_log_hash, local_log_hash[Bkmkr::Paths.thisscript]
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
    @@sectionstart_template_version = '5.0'
    def self.sectionstart_template_version
      @@sectionstart_template_version
    end

    @@rsuite_template_version = '6.0'
    def self.rsuite_template_version
      @@rsuite_template_version
    end

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
				`#{xsl_command}` #2>>"#{convert_log_txt}"`
			else
				saxonpath = File.join(Bkmkr::Paths.resource_dir, "saxon", "#{xslprocessor}.jar")
				`java -jar "#{saxonpath}" -s:"#{html_file}" -xsl:"#{xsl_file}" -o:"#{epub_file}"` # 2>>"#{convert_log_txt}"`
			end
		end

		def self.runjar(jar_script, input_file)
			puts "---RUNNING #{jar_script}---"
			stdout_stderr, status = Open3.capture2e("java -jar #{jar_script} \"#{input_file}\"")
			return stdout_stderr
		end

		def self.runpython(py_script, args)
			if $python_processor
				`#{$python_processor} #{py_script} #{args}`
			elsif os == "mac" or os == "unix"
				`python #{py_script} #{args}`
			elsif os == "windows"
				pythonpath = File.join(Paths.resource_dir, "Python27", "python.exe")
				`#{pythonpath} #{py_script} #{args}`
			else
				File.open(Bkmkr::Paths.log_file, 'a+') do |f|
					f.puts "----- PYTHON ERROR"
					f.puts "ERROR: I can't seem to run python. Is it installed and part of your system PATH?"
					f.puts "ABORTING. All following processes will fail."
				end
				File.delete(Project.alert)
			end
		end

		def self.makepdf(pdfprocessor, pisbn, pdf_html_file, pdf_html, pdf_css, testing_value, watermark_css, http_username, http_password)
			pdffile = File.join(Paths.project_tmp_dir, "#{pisbn}.pdf")
			if os == "mac" or os == "unix"
				princecmd = "prince"
			elsif os == "windows"
				princecmd = File.join(Paths.resource_dir, "Program Files (x86)", "Prince", "engine", "bin", "prince.exe")
				princecmd = "\"#{princecmd}\""
			end
      if pdfprocessor == "prince"
        princecmd = "#{princecmd} -s \"#{pdf_css}\" --javascript --http-user=#{http_username} --http-password=#{http_password} \"#{pdf_html_file}\" -o \"#{pdffile}\""
        if testing_value == "true"
          princecmd = "#{princecmd} -s \"#{watermark_css}\""
        end
        if $pdf_profile && $pdf_output_intent
          princecmd = "#{princecmd} --pdf-profile=\"#{$pdf_profile}\" --pdf-output-intent=\"#{$pdf_output_intent}\""
        end
        prince_output = `#{princecmd}`
        return "used prince, any output here: #{prince_output}"
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
        return 'pdf processed via docraptor'
			else
				pdf_error = File.join(Paths.done_dir, "PDF_ERROR.txt")
				File.open(pdf_error, 'w+') do |output|
					output.write "You have not configured a PDF processor. Please open config.rb and fill in the pdfprocessor variable with either 'prince' or 'docraptor'."
				end
        return 'no pdf processor configured'
			end
		end

		def self.runnode(js, args)
			if os == "mac" or os == "unix"
				`node #{js} #{args}`
			elsif os == "windows"
				nodepath = File.join(Paths.resource_dir, "nodejs", "node.exe")
				`#{nodepath} #{js} #{args}`
			else
				File.open(Bkmkr::Paths.log_file, 'a+') do |f|
					f.puts "----- NODE ERROR"
					f.puts "ERROR: I can't seem to run node. Is it installed and part of your system PATH?"
					f.puts "ABORTING. All following processes will fail."
				end
				File.delete(Project.alert)
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
			unless addons.nil? or addons.empty? or !addons
				addons = addons.split(",")
			end

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

						puts "inserting file: #{addonfile}"
						puts "insertion location is: #{order} #{location}"

						jsfile = File.join(Paths.core_dir, "utilities", "insertaddon.js")

						# Insert the addon via node.js
						Bkmkr::Tools.runnode(jsfile, "\"#{inputfile}\" \"#{addoncontent}\" \"#{locationcontainer}\" \"#{locationtype}\" \"#{locationclass}\" \"#{sequence}\" \"#{order}\" \"#{location}\"")

						# copy any images to epub conversion dir
						epub_img_dir = File.join(Bkmkr::Paths.project_tmp_dir, "epubimg")
						images = []
						images = File.read(addonfile).scan(/<img.*?>/)
						if images.any?
							images.each do |i|
								puts "copying addon image file: #{i}"
								source = i.match(/(src=")(.*?)(")/)[2]
								imagepath = File.join(addonfiledir, "images", source)
								Mcmlln::Tools.copyFile(imagepath, epub_img_dir)
							end
						end

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

			puts "Moving #{src} before #{dest}"

			jsfile = File.join(Paths.core_dir, "utilities", "movesection.js")

			# Insert the addon via node.js
			Bkmkr::Tools.runnode(jsfile, "\"#{inputfile}\" \"#{srccontainer}\" \"#{srctype}\" \"#{srcclass}\" \"#{srcseq}\" \"#{destcontainer}\" \"#{desttype}\" \"#{destclass}\" \"#{destseq}\"")
		end

		def self.compileJS(file, link_stylename)
			jsfile = File.join(Paths.core_dir, "utilities", "evaltemplates.js")
			templates = File.read(file).scan(/(")(eval-\S+)(")/)
			templates.each do |t|
				Bkmkr::Tools.runnode(jsfile, "\"#{file}\" \"#{link_stylename}\" \"#{t[1]}\"")
			end
		end

	end
end
