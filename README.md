# htmlmaker: Convert MS Word Documents to HTML

**A part of Macmillan's Bookmaker toolchain**

The *htmlmaker* process consists of a collection of XSL and ruby transforms run sequentially. Taken together, these transformation convert a Word XML file to HTMLBook and prepare the file for ultimate conversion to [EPUB](https://github.com/macmillanpublishers/bookmaker_epubmaker) and [PDF](https://github.com/macmillanpublishers/bookmaker_pdfmaker) output.

The core XSL transforms are contained in [wordtohtml.xsl](https://github.com/macmillanpublishers/WordXML-to-HTML) - this XSL stylesheet hooks on Microsoft Word style names to transform a Word XML file to HTMLBook HTML. The core transformation is then followed by a handful of inline ruby substitutions and additional standalone XSL transformations to finalize the conversion from Word XML to valid HTMLBook. The entire conversion is run from within *htmlmaker.rb*, and outputs an HTML file that can be fed into the rest of the Bookmaker process.

*Htmlmaker* was written specifically for use at Macmillan, within the Bookmaker toolchain, and thus many of the filenames, arguments, and paths are direct references to that internal workflow. You can read about the entire workflow and the various script interdependencies here.