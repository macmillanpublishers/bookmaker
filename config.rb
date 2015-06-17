# ------------------ CUSTOM VARIABLES
# Add any custom variables you'd like to use in the global variables below.
$currpath = Dir.pwd
$currvol = $currpath.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).shift

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
$tmp_dir = File.join($currvol, "bookmaker_tmp")

# The location to store the log file that gets created 
# for each conversion.
$log_dir = File.join("S:", "resources", "logs")

# The location where your bookmaker scripts live.
$scripts_dir = File.join("S:", "resources", "bookmaker_scripts")

# The location that any other resources are installed, 
# for example your pdf processor, zip utility, etc.
$resource_dir = "C:"

# Which version of saxon are you using?
# Uncomment the correct version and update the version number if needed.
$saxon_version = "saxon9pe"
#$saxon_version = "saxon9he"
#$saxon_version = "saxon9ee"

# Choose either prince or docraptor to create your PDFs.
$pdf_processor = "docraptor"
#$pdf_processor = "prince"

# Your API key to create PDFs via DocRaptor
$docraptor_key = File.read("#{$scripts_dir}/bookmaker_authkeys/api_key.txt")

# username and password for online resources
$http_username = File.read("#{$scripts_dir}/bookmaker_authkeys/ftp_username.txt")
$http_password = File.read("#{$scripts_dir}/bookmaker_authkeys/ftp_pass.txt")

# OPTIONAL VARIABLES
# uncomment as needed

# If the standard windows and mac/unix python commands don't work for you,
# you can specify a custom command here.
# $python_processor = ""