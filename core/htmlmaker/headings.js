var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });


//select sections without direct-child h1's
var noHeadSection = $("section:not(:has(>h1))");

//for each section without direct-child h1's, create one with .Nonprinting and approporate h1 text
noHeadSection.each (function() {

  // the var for new h1 text
  var hText = ''

  // find the header element
  var header = $(this).children("header")

  // get text from h1 in the header element
  var headerText = header.children("h1").text()

  // get text from the section data-type
  var dataTypeText = $(this).attr("data-type")

  // set new h1 text using, in order of preference: header text if available, then try section data-type, then scan classes of the section elements
  if (headerText) {
    hText = headerText
  } else if (dataTypeText) {
    var sanitizedDataTypeText = dataTypeText.toLowerCase().replace(/-/g, " ").replace(/\b[a-z]/g, function(letter) {
      return letter.toUpperCase();
    });
    hText = sanitizedDataTypeText
  } else {
    // This section includes several hardcoded non-RSuite stylenames; however since there is a data-type for all
    //  of the sections listed below, applied at time of conversion to html, these conditionals will never be invoked as far as I can tell.
    //  it had more value prior to SectionStart implementation.
    var hText = "Frontmatter";
    if ($(".CopyrightTextsinglespacecrtx", this).length || $(".CopyrightTextdoublespacecrtxd", this).length) {
      hText = "Copyright Page";
    }
    if ($(".Dedicationded", this).length) {
      hText = "Dedication";
    }
    if ($(".AdCardMainHeadacmh", this).length || $(".AdCardSubheadacsh", this).length || $(".AdCardListofTitlesacl", this).length) {
      hText = "Ad Card";
    }
    if ($(".AboutAuthorTextNo-Indentatatx1", this).length || $(".AboutAuthorTextHeadatah", this).length || $(".AboutAuthorTextatatx", this).length) {
      hText = "About the Author";
    }
    if ($(".FrontSalesSubtitlefsst", this).length || $(".FrontSalesQuoteHeadfsqh", this).length || $(".FrontSalesTextfstx", this).length || $(".FrontSalesTextNoIndentfstx1", this).length || $(".FrontSalesQuotefsq", this).length || $(".FrontSalesQuoteNoIndentfsq1", this).length) {
      hText = "Praise";
    }
  }

  // insert our new h1 after header element; if header is not present, otherwise prepend inside section
  if (header.length) {
    header.after("<h1 class='Nonprinting'>"+hText+"</h1>");
  } else {
    $(this).prepend("<h1 class='Nonprinting'>"+hText+"</h1>");
  }
});


  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

      console.log("Processing instructions have been evaluated!");
	});
});
