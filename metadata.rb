require_relative '../bookmaker/header.rb'

class Metadata
	# This block creates a variable to point to the 
	# converted HTML file, and pulls the isbn data
	# out of the HTML file.

	# the working html file
	@html_file = Bkmkr::Paths.outputtmp_html

	# testing to see if ISBN style exists
	@spanisbn = File.read(@html_file).scan(/spanISBNisbn/)
	@multiple_isbns = File.read(@html_file).scan(/spanISBNisbn">\s*.+<\/span>\s*\(((hardcover)|(trade\s*paperback)|(e-*book))\)/)

	# determining print isbn
	if @spanisbn.length != 0 && @multiple_isbns.length != 0
		@pisbn_basestring = File.read(@html_file).match(/spanISBNisbn">\s*.+<\/span>\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
		@@pisbn = @pisbn_basestring.match(/\d+<\/span>\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
	elsif @spanisbn.length != 0 && @multiple_isbns.length == 0
		@pisbn_basestring = File.read(@html_file).match(/spanISBNisbn">\s*.+<\/span>/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
		@@pisbn = @pisbn_basestring.match(/\d+<\/span>/).to_s.gsub(/<\/span>/,"").gsub(/\["/,"").gsub(/"\]/,"")
	else
		@pisbn_basestring = File.read(@html_file).match(/ISBN\s*.+\s*\(((hardcover)|(trade\s*paperback))\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
		@@pisbn = @pisbn_basestring.match(/\d+\(.*\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
	end

	# determining ebook isbn
	if @spanisbn.length != 0 && @multiple_isbns.length != 0
		@eisbn_basestring = File.read(@html_file).match(/spanISBNisbn">\s*.+<\/span>\s*\(e-*book\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
		@@eisbn = @eisbn_basestring.match(/\d+<\/span>\(ebook\)/).to_s.gsub(/<\/span>\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
	elsif @spanisbn.length != 0 && @multiple_isbns.length == 0
		@eisbn_basestring = File.read(@html_file).match(/spanISBNisbn">\s*.+<\/span>/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
		@@eisbn = @pisbn_basestring.match(/\d+<\/span>/).to_s.gsub(/<\/span>/,"").gsub(/\["/,"").gsub(/"\]/,"")
	else
		@eisbn_basestring = File.read(@html_file).match(/ISBN\s*.+\s*\(e-*book\)/).to_s.gsub(/-/,"").gsub(/\s+/,"").gsub(/\["/,"").gsub(/"\]/,"")
		@@eisbn = @eisbn_basestring.match(/\d+\(ebook\)/).to_s.gsub(/\(.*\)/,"").gsub(/\["/,"").gsub(/"\]/,"")
	end

	# just in case no isbn is found
	if @@pisbn.length == 0
		@@pisbn = Bkmkr::Project.filename
	end

	if @@eisbn.length == 0
		@@eisbn = Bkmkr::Project.filename
	end

	def self.pisbn
		@@pisbn
	end

	def self.eisbn
		@@eisbn
	end
end