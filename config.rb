# ------------------ CUSTOM VARIABLES
# Add any custom variables you'd like to use in the global variables below.
$currpath = Dir.pwd
$currvol = $currpath.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).shift

# ------------------ GLOBAL VARIABLES
# These variables are required throughout the 
# Bookmaker toolchain. Update these paths to 
# reflect your current system setup.

# The location of the temporary working folder.
# This is where bookmaker will perform most actions
# before moving the finalized files to the "done" directory.
$tmp_dir = File.join($currvol, "bookmaker_tmp")

# The location to store the log file that gets created 
# for each conversion.
$log_dir = File.join("S:", "resources", "logs")

# The location where your bookmaker scripts live.
$bookmaker_dir = File.join("S:", "resources", "bookmaker_scripts")

# The location that any other resources are installed, 
# for example your pdf processor, zip utility, etc.
$resource_dir = "C:"