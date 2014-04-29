# Word XML to HTML

Convert Microsoft-Word-generated XML to HTML.

v0.1: converts all paragraphs to p elements with appropriate styles applied as classes.

Run via xsltproc: 

    $ xsltproc wordtohtml.xsl inputfile.xml > outputfile.html