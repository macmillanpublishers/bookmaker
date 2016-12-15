# ------------------ CUSTOM VARIABLES
# Add any custom variables you'd like to use in the global variables below.
$currpath = Dir.pwd
$currvol = $currpath.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).shift

if !ARGV.empty?		#adding this check for testing purposes
  unescapeargv = ARGV[0].chomp('"').reverse.chomp('"').reverse
else
  unescapeargv = '/test/test/test.docx'
end
input_file = File.expand_path(unescapeargv).split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).join(File::SEPARATOR)
working_dir = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].join(File::SEPARATOR)
project = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-2].pop
logdir = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-4].join(File::SEPARATOR)
logsubdir = input_file.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact))[0...-3].pop

# ------------------ GLOBAL VARIABLES
# These variables are required throughout the
# Bookmaker toolchain. Update these paths to
# reflect your current system setup.

# Are you on a windows, mac, or unix system?
$op_system = "windows"
#$op_system = "mac"
#$op_system = "unix"

# The location of the temporary working folder.
# This is where bookmaker will perform most actions
# before moving the finalized files to the "done" directory.
$tmp_dir = File.join($currvol, "bookmaker_tmp", project)

# The location to store the log file that gets created
# for each conversion.
$log_dir = File.join(logdir, "bookmaker_logs", logsubdir, project)

# The location where your bookmaker scripts live.
$scripts_dir = File.join("S:", "resources", "bookmaker_scripts")

# The location that any other resources are installed,
# for example your pdf processor, zip utility, etc.
# (on Windows zip is expected at path: $resource_dir\zip\zip.exe)
$resource_dir = "C:"

# Which version of saxon are you using?
# Uncomment the correct version and update the version number if needed.
$saxon_version = "saxon9pe"
#$saxon_version = "saxon9he"
#$saxon_version = "saxon9ee"

# Choose either prince or docraptor to create your PDFs.
$pdf_processor = "docraptor"
#$pdf_processor = "prince"

# Do you want to use image magick to process your images
# for optimal epub display?
# NB: This requires you to install image magick.
$processimages = "true"
# $processimages = "false"

# ------------------ OPTIONAL VARIABLES
# uncomment as needed

# Where will you drop assets to accompany your input files?
# For example, the config.json, images, cover, etc.
# If not specified, bookmaker will look in the same folder
# as the input file.
$assets_dir = File.join(working_dir, "submitted_images")

# Where should the output files be stored?
# If not specified, bookmaker will make a new subfolder
# within the input foler, named by project isbn or filename,
$done_dir = File.join(working_dir, "done")

# If the standard windows and mac/unix python commands don't work for you,
# or you want to install python in a location other than $resource_dir,
# you can specify a custom path/command here.
# $python_processor = ""

# If you're using your own xslt processor, you can specify
# the command here, including file placeholders as shown below.
# $xsl_processor = "xsltproc file.xsl file.html -o file.epub"
# $xsl_processor = "java -jar S:\saxon\saxon9pe.jar -s:"file.html" -xsl:"file.xsl" -o:"file.epub""

if File.directory?($scripts_dir)	#adding this check for travis ci tests
  # Your API key to create PDFs via DocRaptor
  $docraptor_key = File.read("#{$scripts_dir}/bookmaker_authkeys/api_key.txt")

  # username and password for online resources
  $http_username = File.read("#{$scripts_dir}/bookmaker_authkeys/http_username.txt")
  $http_password = File.read("#{$scripts_dir}/bookmaker_authkeys/http_pass.txt")
end
