require 'json'

require_relative '../bookmaker/header.rb'

configfile = File.join(Bkmkr::Paths.project_tmp_dir, "config.json")

@@file = File.read(configfile)
@@data_hash = JSON.parse(file)

class Metadata
	def self.booktitle
		if @@data_hash['title']
			@@data_hash['title']
		else 
			"Unknown"
		end
	end

	def self.booksubtitle
		if @@data_hash['subtitle']
			@@data_hash['subtitle']
		else 
			"Unknown"
		end
	end

	def self.bookauthor
		if @@data_hash['author']
			@@data_hash['author']
		else 
			"Unknown"
		end
	end

	def self.productid
		if @@data_hash['productid']
			@@data_hash['productid']
		else 
			"Unknown"
		end
	end

	def self.pisbn
		if @@data_hash['printid']
			@@data_hash['printid']
		else 
			"Unknown"
		end
	end

	def self.eisbn
		if @@data_hash['ebookid']
			@@data_hash['ebookid']
		else 
			"Unknown"
		end
	end

	def self.imprint
		if @@data_hash['imprint']
			@@data_hash['imprint']
		else 
			"Unknown"
		end
	end

	def self.publisher
		if @@data_hash['publisher']
			@@data_hash['publisher']
		else 
			"Unknown"
		end
	end

	def self.frontcover
		if @@data_hash['frontcover']
			@@data_hash['frontcover']
		else 
			"Unknown"
		end
	end
end