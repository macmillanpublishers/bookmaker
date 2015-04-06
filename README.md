# Word XML to HTML

The *wordtohtml.xsl* transforms are a key part of Macmillan’s Bookmaker toolchain. These core transforms convert Word XML to HTML that conforms to the HTMLBook spec, and are built-on by a handful of other ruby and XSL transforms to create an HTML file that plugs into the larger Macmillan workflow. Specifically, these XSL transforms are part of the bookmaker_htmlmaker process - [you can read about the entire HTML transformation set here](https://github.com/macmillanpublishers/bookmaker_htmlmaker).

For well-formed HTMLBook, the *wordtohtml.xsl* transforms require Word documents to use Macmillan’s Microsoft Word template--a set of predefined paragraph and character styles that add semantic tagging to the different pieces of a manuscript. [You can read about the template here](http://68.71.241.9/display/PE/Manuscript+Styling+with+MS+Word). *wordtohtml.xsl* is built to look for specific Word style names, and apply HTMLBook elements accordingly--this means that in order to get predictable HTMLBook, Word documents must use the Macmillan tag set correctly. You can read about some of the specific markup requirements here.

We’ve also created a PowerShell script to convert .doc or .docx files to the required Word XML format - *DocxToXml.ps1* (also found within this repo). The PowerShell script can be run as follows:

    $ PowerShell -NoProfile -ExecutionPolicy Bypass -Command "path\to\WordXML-to-HTML\DocxToXml.ps1 'inputfile.doc'"

wordtohtml.xsl is XSL 2.0, and we currently use Saxon to run it, as follows: 

    $ java -jar saxon9pe.jar -s:inputfile.xml -xsl:path/to/wordtohtml.xsl -o:outputfile.html