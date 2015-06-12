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

[DocxToXml](https://github.com/macmillanpublishers/WordXML-to-HTML): Converts the source Word file (.doc or .docx) to Word XML (via PowerShell).

*Dependencies: tmparchive, PowerShell, Microsoft Word & correct application of [the Macmillan Word template](https://github.com/macmillanpublishers/Word-template)*

[htmlmaker](https://github.com/macmillanpublishers/bookmaker/blob/master/core/htmlmaker/htmlmaker.rb): Converts the .xml file to HTML using wordtohtml.xsl.

*Dependencies: tmparchive, DocxToXml, Java JDK, Saxon, wordtohtml.xsl*

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

*Dependencies: tmparchive, htmlmaker, filearchive, imagechecker, coverchecker, chapterheads, Saxon, HTMLBook, zip.exe*

[cleanup](https://github.com/macmillanpublishers/bookmaker/blob/master/core/cleanup/cleanup.rb): Removes all temporary working files and working dirs.

*Dependencies: tmparchive, htmlmaker, filearchive, imagechecker, coverchecker, stylesheets

## Project Metadata
Bookmaker requires a few pieces of metadata to accompany each project, which you can provide in a JSON file. Please include the following fields:

## Required Folder Structure

The Bookmaker toolchain requires a specific folder structure and sequence of parent folders in order to function correctly. The requirements are as follows:

* The *conversion folder* is the folder where files to be converted should be dropped. It should contain _only_ the file to be converted.
* *submitted_images*: This is where any images (including book front cover) should be placed before initiating the conversion. This should live at the same level as the conversion folder.
* *done*: This is where completed conversion will be archived automatically by Bookmaker. This should live at the same level as the conversion and submitted_images folders.

Additionally, the following directory structures are required:
* All supplemental resources (saxon, zip) should live in the same parent folder, at the same level (i.e., they should be siblings to each other).
* All bookmaker scripts (including WordXML-to-HTML, HTMLBook, and covermaker) should live within the same parent folder, at the same level.
* A folder must exist for storing log files. This can live anywhere.
* A temporary working directory should be created, where Bookmaker can perform the conversions before archiving the final files. This can live anywhere.

Paths for the above four folders can be configured in config.rb. See the installation instructions below for details.

## Dependencies

The Bookmaker scripts depend on various other utilities, as follows:

* Java: Saxon requires the Java JDK. 
* Saxon: An XSLT processor that runs our Word-to-HTML scripts. 
* Microsoft Word: The WordXML-to-HTML converter (PowerShell) requires MS Word to convert .doc files to .xml.
* Ruby: The primary scripting language used in the Bookmaker scripts. 
* Docraptor: The external service that performs the HTML-to-PDF conversion. It requires a ruby gem, and you'll also need to create an account and get your unique API key.
* An ftp server (if you'll be creating PDFs and your book contains images, custom fonts, custom CSS, or other resources besides the HTML).
* SSL Cert: The SSL Cert file needs to be updated to allow the scripts to post and receive from DocRaptor. 
* Zip.exe: Packages the EPUB file; download here and place in your resources folder (see below).
* Imagemagick: enables command line image edits. Download here and add to path via cmd line: set PATH=C:\Program Files\ImageMagick-6.9.1-Q16n;%PATH% (<-version suffix may change, use your own path)

## Installation

Install Bookmaker by following these steps, in order.

### Install the Dependencies

Install the utilities listed in the previous section, as needed. For reference, you need to install the following in order to create these outputs:

* To create an HTML file: Ruby, Java, Saxon, Microsoft Word
* To create a PDF file: Ruby, Java, Saxon, Microsoft Word, Docraptor gem, ftp server, SSL cert file, Imagemagick
* To create an EPUB file: Ruby, Java, Saxon, Microsoft Word, Zip.exe, Imagemagick

### Create the Folder Structure

On your server, create the following folders and subfolders.

* A folder to drop the project to be converted. See the naming convention requirements above. The folder name should follow this convention: _MainParentFolder\_ProjectStage/ConversionFolder/_
* A folder to drop book images to be included in the conversion. This folder must be named _submitted\_images_.
* A folder to archive the final converted files. This folder must be named _done_.
* Temp folder: A folder where the system can store temporary files created during conversion. This can live anywhere and have the name of your choosing.
* Bookmaker folder: A main parent folder to contain all of the separate bookmaker script folders. This can live anywhere and have the name of your choosing.
* Resources folder: A folder for all the supplemental utilities (saxon, zip, etc). This can live anywhere and have the name of your choosing.
* Log folder: A folder for storing log files. This can live anywhere and have the name of your choosing.

### Install Git and Set Up Your GitHub Account

If you haven't yet set up a GitHub account, do that now (you can just set up a basic, free account).

Now install git on your server, following the standard instructions.

### Clone the Repositories

The source code for the Bookmaker scripts is hosted in the Macmillan GitHub account, broken down into several repositories. The production-ready versions of each script live in the master branch in each repository. The repositories are as follows:

* https://github.com/macmillanpublishers/bookmaker/
* https://github.com/macmillanpublishers/WordXML-to-HTML/

If you plan to make changes to the source code, you will want to fork those repositories and then clone them, so that you can maintain your version of the code.

### Create Auth Key and FTP Folders

At the same level as the bookmaker scripts, create the following folders:

* bookmaker\_authkeys
* bookmaker\_ftpupload

Within bookmaker\_authkeys, create the following three files:

* *api_key.txt*: single line of text containing your DocRaptor API key.
* *ftp_username.txt*: single line of text containing your ftp username.
* *ftp_pass.txt*: single line of text containing your ftp password.

Within bookmaker\_ftpupload, create the following two files:

imageupload.bat

    REM %1 is local upload dir, %2 is logdir
    REM to debug: capture all connection info by adding output file to ftpline, like so:
    REM ftp -i -n -s:ftpcmd.dat YOUR_SERVER_NAME_OR_IP > text.txt
    @echo off
    echo user YOUR_USER_NAME> ftpcmd.dat
    echo YOUR_PASSWORD>> ftpcmd.dat
    echo bin>> ftpcmd.dat
    echo cd YOUR_FOLDER_LOCATION>> ftpcmd.dat
    echo lcd %1>> ftpcmd.dat
    echo mput *.*>> ftpcmd.dat
    REM echo put %1>> ftpcmd.dat
    echo lcd %2>> ftpcmd.dat
    echo ls . uploaded_image_log.txt>> ftpcmd.dat
    echo quit>> ftpcmd.dat
    ftp -i -n -s:ftpcmd.dat YOUR_SERVER_NAME_OR_IP
    del ftpcmd.dat

imagedelete.bat

    REM %1 is logdir
    REM to debug: capture all connection info by adding output file to ftpline, like so:
    REM ftp -i -n -s:ftpcmd.dat YOUR_SERVER_NAME_OR_IP > text.txt
    @echo off
    echo user YOUR_USER_NAME> ftpcmd.dat
    echo YOUR_PASSWORD>> ftpcmd.dat
    echo bin>> ftpcmd.dat
    echo cd YOUR_FOLDER_LOCATION>> ftpcmd.dat
    echo mdelete *>> ftpcmd.dat
    echo lcd %1>> ftpcmd.dat
    echo ls . clear_ftp_log.txt>> ftpcmd.dat
    echo quit>> ftpcmd.dat
    ftp -i -n -s:ftpcmd.dat YOUR_SERVER_NAME_OR_IP
    del ftpcmd.dat

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

### Download HTMLBook

The EPUB generation script relies on a collection of open source scripts called HTMLBook (created by O'Reilly). Macmillan has a forked version of the HTMLBook scripts that include the customizations outlined below, and are maintained on GitHub here: https://github.com/macmillanpublishers/HTMLBook. (The original, unmodified O'Reilly scripts are hosted on GitHub here: https://github.com/oreillymedia/HTMLBook.)

The entire contents of the repository should be cloned or copied to your server, at the same level as the other Bookmaker scripts.

The following customizations have been made to the HTMLBook .xsl files:

#### epub.xsl

Lines 208-213: Comment out this whole chunk. It references font files we do not use.

    <!--<xsl:param name="embedded.fonts.list"\>DejaVuSerif.otf
    DejaVuSans-Bold.otf
    UbuntuMono-Regular.otf
    UbuntuMono-Bold.otf
    UbuntuMono-BoldItalic.otf
    UbuntuMono-Italic.otf</xsl:param>-->

We currently do not embed any fonts in our EPUB files. Update this list and uncomment if fonts ever need to be embedded.

Line 225: set xsl:param name="autogenerate.labels" to "0". This turns off autonumbering, since numbering is added to manuscripts manually.
htmlbook.xsl

Line 22: Comment out this line. It refers to the exsl package, which is not supported by our conversion software.

    <!--<xsl:include href="functions-exsl.xsl"/>--> <!-- Functions that are compatible with exsl package -->

Line 24: Uncomment this line--our conversion software uses xslt2, so we need to activate these functions.

    <xsl:include href="functions-xslt2.xsl"/> <!-- Functions that are compatible with XSLT 2.0 processors -->

#### opf.xsl

Line 152: Replace with the following, to fix namespace and iBooks metadata rendering:

    <package xmlns="http://www.idpf.org/2007/opf" version="3.0" xml:lang="en" prefix="rendition: http://www.idpf.org/vocab/rendition/#" unique-identifier="{$metadata.unique-identifier.id}">

Lines 158-160: Comment out this block. It adds extra namespace values to the content.opf file in the generated EPUB, which causes metadata not to render in iBooks.

    <!--<xsl:for-each select="exsl:node-set($package.namespaces)//*/namespace::*">
    <xsl:copy-of select="."/>
    </xsl:for-each>-->

## Run Bookmaker

You can run bookmaker by firing the scripts one\-by\-one on the command line, or by combining them into a bash or batch file to fire all at once. You can see examples of Macmillan's .bat files [here: https://github.com/macmillanpublishers/bookmaker_deploy/](https://github.com/macmillanpublishers/bookmaker_deploy/).

To convert a project, drop the input text file along with any assets (interior images, etc.) into your conversion folder. Project metadata is read from a _config.json_ file that should be submitted along with your book assets. The json file should be structured as follows, with these exact key names:

    {
    "title":"Your Book Title",
    "subtitle":"Your Book Subtitle",
    "author":"Your Book Author",
    "productid":"A general product ID",
    "printid":"A print product ID like an ISBN",
    "ebookid":"An ebook product ID like an ISBN",
    "imprint":"The name of the imprint",
    "publisher":"The name of the publisher",
    "frontcover":"The filename for the cover image"
    }

All fields are optional. If you choose not to include any of the above information, and that information is required at any point in Bookmaker (for example, _printid_ and _ebookid_ are used for naming the output files), those fields will instead use the value "Unknown" (so, you'll end up with an EPUB file called _Unknown_EPUB.epub_). If you choose not to include a front cover filename, Bookmaker will look for a file called _cover.jpg_.
