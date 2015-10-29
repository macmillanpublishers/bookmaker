# Macmillan's Bookmaker Toolchain

Welcome to the Bookmaker toolchain! Bookmaker comprises a series of scripts that turn a Word document into an HTML document, and then into a PDF and/or EPUB file. 

Each script in the Bookmaker sequence performs a distinct set of actions that builds on the scripts that came before, and depends on any number of other scripts or tools. While most of these scripts were originally written for internal use at Macmillan, we've done our best to hone them down to a cross-platform, generic core that can be used out of the box (though there are still a number of dependencies, discussed further down). The scripts all live here, in the _core_ directory.

It's important to note that correct transformation depends on correct application of the Macmillan Word template, a set of styles and rules for Microsoft Word manuscripts that create the initial structure each manuscript needs in order to cleanly transform into valid HTMLBook HTML. You can learn more about styling and the Word template [here](https://macmillan.atlassian.net/wiki/display/PBL/Manuscript+Styling+with+MS+Word).

## Bookmaker Components

The scripts are as follows:

[config.rb](https://github.com/macmillanpublishers/bookmaker/blob/master/config.rb): This is where you configure your system set-up, for example, the location of your cloned core scripts, location of the external dependencies, etc.

[header](https://github.com/macmillanpublishers/bookmaker/blob/master/core/header.rb): This is the core Bookmaker library, that contains paths and references common to all the Bookmaker scripts.

[tmparchive](https://github.com/macmillanpublishers/bookmaker/blob/master/core/tmparchive/tmparchive.rb): Creates the temporary working directory for the file to be converted, and opens an alert to the user telling them the tool is in use.

*Dependencies: Pre-determined folder structure*

[htmlmaker](https://github.com/macmillanpublishers/bookmaker/blob/master/core/htmlmaker/htmlmaker.rb): Converts the .xml file to HTML using wordtohtml.xsl.

*Dependencies: tmparchive, Python 2.7.x, correct application of [the Macmillan Word template](https://github.com/macmillanpublishers/Word-template), Java JDK, Saxon, wordtohtml.xsl*

[filearchive](https://github.com/macmillanpublishers/bookmaker/blob/master/core/filearchive/filearchive.rb): Creates the directory structure for the converted filesbookmaker_coverchecker: Verifies that a cover image has been submitted. If yes, copies the cover image file into the final archive. If no, creates an error file notifying the user that the cover is missing.

*Dependencies: tmparchive, htmlmaker*

[imagechecker](https://github.com/macmillanpublishers/bookmaker/blob/master/core/imagechecker/imagechecker.rb): Checks to see if any images are referenced in the HTML file, and if those image files exist in the submission folder. If images are present, copies them to the final archive; if missing, creates an error file noting which image files are missing.

*Dependencies: tmparchive, htmlmaker, filearchive*

[coverchecker](https://github.com/macmillanpublishers/bookmaker/blob/master/core/coverchecker/coverchecker.rb): Checks to see if a front cover image file exists in the submission folder. If the cover image is present, copies it to the final archive; if missing, creates an error file noting that the cover is missing.

*Dependencies: tmparchive, htmlmaker, filearchive*

[stylesheets](https://github.com/macmillanpublishers/bookmaker/blob/master/core/stylesheets/stylesheets.rb): Copies EPUB and PDF css into the final archive, while also counting how many chapters are in the book and adjusting the CSS to suppress chapter numbers if only one chapter is found.

*Dependencies: tmparchive, htmlmaker, filearchive*

[pdfmaker](https://github.com/macmillanpublishers/bookmaker/blob/master/core/pdfmaker/pdfmaker.rb): Preps the HTML file and sends to the DocRaptor service for conversion to PDF.

*Dependencies: tmparchive, htmlmaker, filearchive, imagechecker, coverchecker, chapterheads, SSL cert file, DocRaptor cloud service, doc_raptor ruby gem*

[epubmaker](https://github.com/macmillanpublishers/bookmaker/blob/master/core/epubmaker/epubmaker.rb): Preps the HTML file and converts to EPUB using the HTMLBook scripts.

*Dependencies: tmparchive, htmlmaker, filearchive, imagechecker, coverchecker, chapterheads, Saxon, HTMLBook, python*

[cleanup](https://github.com/macmillanpublishers/bookmaker/blob/master/core/cleanup/cleanup.rb): Removes all temporary working files and working dirs.

*Dependencies: tmparchive, htmlmaker, filearchive, imagechecker, coverchecker, stylesheets

## Project Metadata

Bookmaker requires a few pieces of metadata to accompany each project, which you can provide in a JSON file. Here's a sample:

```
config.json
{
"title":"Alice in Wonderland",
"author":"Lewis Carroll",
"productid":"99237561",
"printid":"9781234567890",
"ebookid":"9781234567899",
"imprint":"Project Gutenberg",
"publisher":"Project Gutenberg",
"printcss":"/Users/nellie/Documents/css/pdf.css",
"printjs":"/Users/nellie/Documents/js/pdf.js",
"ebookcss":"/Users/nellie/Documents/css/epub.css",
"frontcover":"cover.jpg"
}
```

Each of the following fields is used for various purposes throughout the Bookmaker toolchain:

* title. Required for ebook metadata. If not found, will fallback to input file name.
* author. Required for ebook metadata. If not found, will fallback to "Unknown".
* productid. Required for file naming. If not found, will fallback to input file name.
* printid. Required for file naming. If not found, will fallback to input file name.
* ebookid. Required for ebook metadata and file naming. If not found, will fallback to input file name.
* imprint. Required for ebook metadata. If not found, will fallback to "Unknown".
* publisher. Required for ebook metadata. If not found, will fallback to "Unknown".
* printcss. Required for PDF formatting. Can be either a full path to a file on your computer, or just a filename (if just a filename is provided, bookmaker will assume the css file is in the assets directory, along with the cover and config.json files). If not found, will use the default Prince stylesheet.
* ebookcss. Required for ebook formatting. Can be either a full path to a file on your computer, or just a filename (if just a filename is provided, bookmaker will assume the css file is in the assets directory, along with the cover and config.json files). If not found, no extra formatting will be applied.
* frontcover. Front cover image to include in the ebook. If not found, no cover image will appear.


## Folder Structure

By default, Bookmaker will look for all files (images, config.json) in the same folder as the input file, and create the output folders there as well. However, you can specify a custom submission folder and done folder in config.rb.

Additionally, the following directory structures are required:

* All supplemental resources (saxon, zip) should live in the same parent folder, at the same level (i.e., they should be siblings to each other).
* All bookmaker scripts (including WordXML-to-HTML, HTMLBook, and covermaker) should live within the same parent folder, at the same level.
* A folder must exist for storing log files. This can live anywhere.
* A temporary working directory should be created, where Bookmaker can perform the conversions before archiving the final files. This can live anywhere.

Paths for all of the above four folders must be configured in config.rb. See the installation instructions below for details.

## Dependencies

The Bookmaker scripts depend on various other utilities, as follows:

* Java: Saxon requires the Java JDK. 
* Node.js: Platform for server-side JavaScript execution, used for content transformations.
* Python (version 2.7.x): Converts Word .docx files to XML.
* Saxon: An XSLT processor that runs our Word-to-HTML scripts. 
* Ruby: The primary scripting language used in the Bookmaker scripts. 
* Prince or docraptor: The external service that performs the HTML-to-PDF conversion. Prince is downloadable software. Docraptor requires a ruby gem, and you'll also need to create an account and get your unique API key.
* An ftp server (if you'll be creating PDFs and your book contains images, custom fonts, custom CSS, or other resources besides the HTML).
* SSL Cert (Windows only): The SSL Cert file needs to be updated to allow the scripts to post and receive from DocRaptor. 
* Imagemagick: enables command line image edits. Download here and add to path via cmd line: set PATH=C:\Program Files\ImageMagick-6.9.1-Q16n;%PATH% (<-version suffix may change, use your own path)

## Installation

Install Bookmaker by following these steps, in order.

### Create the Folder Structure

On your server, create the following folders and subfolders.

* A folder to drop the project to be converted (see above).
* Temp folder: A folder where the system can store temporary files created during conversion. This can live anywhere and have the name of your choosing (you'll tell Bookmaker where it is in config.rb).
* Bookmaker folder: A main parent folder to contain all of the separate bookmaker script folders. This can live anywhere and have the name of your choosing (you'll tell Bookmaker where it is in config.rb).
* Resources folder: A folder for all the supplemental utilities (saxon, zip, etc). This can live anywhere and have the name of your choosing (you'll tell Bookmaker where it is in config.rb).
* Log folder: A folder for storing log files. This can live anywhere and have the name of your choosing (you'll tell Bookmaker where it is in config.rb).

### Install Git and Set Up Your GitHub Account

If you haven't yet set up a GitHub account, do that now (you can just set up a basic, free account).

Now install git on your server, following the standard instructions.

### Clone the Repositories

The source code for the Bookmaker scripts is hosted in the Macmillan GitHub account, broken down into several repositories. The production-ready versions of each script live in the master branch in each repository. The repositories are as follows:

* https://github.com/macmillanpublishers/bookmaker/

If you plan to make changes to the source code, you will want to fork those repositories and then clone them, so that you can maintain your version of the code.

### Install the Dependencies

Install the utilities listed in the previous section, as needed. For reference, you need to install the following in order to create these outputs:

* To create an HTML file: Ruby, Java, Saxon, Python, node.js
* To create a PDF file: Ruby, Java, Saxon (any version), Python, node.js, PrinceXML OR a Docraptor account+SSL cert file
* To create an EPUB file: Ruby, Saxon PE+Java OR xsltproc, Python, node.js, Imagemagick (optional)

#### Ruby

Bookmaker requires Ruby 1.9.x. Follow standard installation instructions for your operating system.

Once Ruby is installed, you'll need to install a few gems:

```
gem install open-uri
gem install json
gem install fileutils
gem install doc_raptor
```

#### Python

Bookmaker requires Python version 2.7. Windows users must install python in the specified Resources directory (see "Create the Folder Structure" above).

For Mac, download and install python [from here](https://www.python.org/downloads/mac-osx/).

For Windows, [follow the directions here](http://www.pythoncentral.io/add-python-to-path-python-is-not-recognized-as-an-internal-or-external-command/).

#### Saxon

Saxon is an XSLT processor that runs the script to convert the Word document to HTML, and also transforms the HTML to create the EPUB file. Right now Bookmaker can only run with Saxon, but we'd love to add support for other XSLT2.0 processors.

#### FOR PRINCE: Download Prince

Download Prince (http://www.princexml.com/download/) and follow the instructions to install.

To configure Bookmaker to use Prince, open config.rb and edit the following fields:

```ruby
$pdf_processor = "prince"
```

#### FOR DOCRAPTOR: Configure Docraptor Auth Settings

If you choose to use DocRaptor to create PDFs, you'll need to set up a DocRaptor account and give Bookmaker your authentication credentials. 

To set up a DocRaptor account, go to docraptor.com, and follow the instructions to create an account. You'll need to know your API key to use Bookmaker; you can find your API key at the top right of your Dashboard.

You also need to install the DocRaptor ruby gem. In terminal or command prompt, type: 

```
$ gem install doc_raptor
```

To configure Bookmaker to use DocRaptor, open config.rb and edit the following fields:

```ruby
$pdf_processor = "docraptor"

...

$docraptor_key = "YOUR_API_KEY_HERE"
```

Note that Docraptor requires all images that you want to include in the text to be hosted somewhere online, so you'll need to make sure your image src's in your Word or HTML file point to this online location. You can store these images behind a basic http auth barrier--you'll just need to provide the auth credentials in config.rb by editing the following fields: 

```ruby
$http_username = "YOUR_USERNAME_HERE"
$http_password = "YOUR_PASSWORD_HERE"
```

#### HTMLBook

The EPUB generation script relies on a collection of open source scripts called HTMLBook (created by O'Reilly), which are hosted on GitHub here: https://github.com/oreillymedia/HTMLBook.

The entire contents of the repository should be cloned or copied to your server, at the same level as the other Bookmaker scripts.

**If you are using Saxon PE as your EPUB XSL processor, you'll need to edit the following files:**

**htmlbook.xsl**

Line 22: Comment out this line. It refers to the exsl package, which is not supported by our conversion software.

    <!--<xsl:include href="functions-exsl.xsl"/>--> <!-- Functions that are compatible with exsl package -->

Line 24: Uncomment this line--our conversion software (Saxon) uses xslt2, so we need to activate these functions.

    <xsl:include href="functions-xslt2.xsl"/> <!-- Functions that are compatible with XSLT 2.0 processors -->

### Configure Your Settings

Within the primary Bookmaker repository (which is to say, this repository), you can configure your system paths to point to the correct folder locations for the folders you created in the steps above. Open _config.rb_ and edit the following values:

The full path of the Temp folder:

    $tmp_dir = "YOUR_PATH_HERE"

The full path of the Log folder:

    $log_dir = "YOUR_PATH_HERE"

The full path of the main parent folder where all your scripts (including this repository) live:

    $scripts_dir = "YOUR_PATH_HERE"

The full path of the Resource folder:

    $resource_dir = "YOUR_PATH_HERE"

If you didn't already do this earlier, choose either prince or docraptor to create your PDFs:

    $pdf_processor = "docraptor" #(or "prince")

## Run Bookmaker

You can run bookmaker by firing the scripts one\-by\-one on the command line, or by combining them into a bash or batch file to fire all at once. You can see examples of Macmillan's .bat files [here: https://github.com/macmillanpublishers/bookmaker_deploy/](https://github.com/macmillanpublishers/bookmaker_deploy/). A simple deployment script for Mac might look like this (this script would take the input filename as the command line argument):

```
#! /bin/sh

ruby /Users/nellie.mckesson/bookmaker/bookmaker/core/tmparchive/tmparchive.rb $1
ruby /Users/nellie.mckesson/bookmaker/bookmaker/core/htmlmaker/htmlmaker.rb $1
ruby /Users/nellie.mckesson/bookmaker/bookmaker/core/filearchive/filearchive.rb $1
ruby /Users/nellie.mckesson/bookmaker/bookmaker/core/imagechecker/imagechecker.rb $1
ruby /Users/nellie.mckesson/bookmaker/bookmaker/core/coverchecker/coverchecker.rb $1
ruby /Users/nellie.mckesson/bookmaker/bookmaker/core/stylesheets/stylesheets.rb $1
ruby /Users/nellie.mckesson/bookmaker/bookmaker/core/pdfmaker/pdfmaker.rb $1
ruby /Users/nellie.mckesson/bookmaker/bookmaker/core/epubmaker/epubmaker.rb $1
ruby /Users/nellie.mckesson/bookmaker/bookmaker/core/cleanup/cleanup.rb $1
```

To convert a project, drop the input text file along with any assets (interior images, etc.) into your conversion folder. Project metadata is read from a _config.json_ file that should be submitted along with your book assets.

## Extend Bookmaker

Because of it's modular architecture, users can insert extensions to the Bookmaker toolchain to customize their content conversions. For example, Macmillan has a number of custom content conversions that they insert before and after various pieces of the Bookmaker toolchain. You can peruse these extensions [here](https://github.com/macmillanpublishers/bookmaker_addons). Extensions are added as intermediary steps during deployment; see [Macmillan's deployment scripts](https://github.com/macmillanpublishers/bookmaker_deploy/) for examples.