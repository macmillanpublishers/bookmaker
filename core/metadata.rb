require 'json'

require_relative 'header.rb'

class Metadata

	configfile = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")

	@@file = File.read(configfile)
	@@data_hash = JSON.parse(@@file)

	def self.booktitle
		if @@data_hash['title'].nil? or !@@data_hash['title']
			Bkmkr::Project.filename
		else 
			@@data_hash['title']
		end
	end

	def self.booksubtitle
		if @@data_hash['subtitle'].nil? or !@@data_hash['subtitle']
			"Unknown"
		else 
			@@data_hash['subtitle']
		end
	end

	def self.bookauthor
		if @@data_hash['author'].nil? or !@@data_hash['author']
			"Unknown"
		else 
			@@data_hash['author']
		end
	end

	def self.productid
		if @@data_hash['productid'].nil? or !@@data_hash['productid']
			Bkmkr::Project.filename
		else 
			@@data_hash['productid']
		end
	end

	def self.pisbn
		if @@data_hash['printid'].nil? or !@@data_hash['printid']
			Bkmkr::Project.filename
		else 
			@@data_hash['printid']
		end
	end

	def self.eisbn
		if @@data_hash['ebookid'].nil? or !@@data_hash['ebookid']
			Bkmkr::Project.filename
		else 
			@@data_hash['ebookid']
		end
	end

	def self.imprint
		if @@data_hash['imprint'].nil? or !@@data_hash['imprint']
			"Unknown"
		else 
			@@data_hash['imprint']
		end
	end

	def self.publisher
		if @@data_hash['publisher'].nil? or !@@data_hash['publisher']
			"Unknown"
		else 
			@@data_hash['publisher']
		end
	end

	def self.printcss
		if @@data_hash['printcss'].nil? or !@@data_hash['printcss']
			"none"
		else 
			@@data_hash['printcss']
		end
	end

	def self.printjs
		if @@data_hash['printjs'].nil? or !@@data_hash['printjs']
			"none"
		else 
			@@data_hash['printjs']
		end
	end

	def self.epubcss
		if @@data_hash['ebookcss'].nil? or !@@data_hash['ebookcss']
			"none"
		else 
			@@data_hash['ebookcss']
		end
	end

	def self.frontcover
		if @@data_hash['frontcover'].nil? or !@@data_hash['frontcover']
			"Unknown"
		else 
			@@data_hash['frontcover']
		end
	end

	def self.epubtitlepage
		if @@data_hash['epubtitlepage'].nil? or !@@data_hash['epubtitlepage']
			"Unknown"
		else 
			@@data_hash['epubtitlepage']
		end
	end

	def self.podtitlepage
		if @@data_hash['podtitlepage'].nil? or !@@data_hash['podtitlepage']
			"Unknown"
		else 
			@@data_hash['podtitlepage']
		end
	end
end