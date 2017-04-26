var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });


//select sections without first-child h1's
var noHeadSection = $("section:not(:has(h1:first-child))");
// //select sections' nested elements (<p>s, h1's) with classes or text matching key criteria
// var ataSection = $("section").find("p.AboutAuthorTextNo-Indentatatx1,p.AboutAuthorTextHeadatah,p.AboutAuthorTextatatx,h1:contains(About the Author)");
// var bobadSection = $("section").find("h1.BOBAdTitlebobt,p.BOBAdTextbobtx")
// var fsSection = $("section").find("p.FrontSalesTitlefst,p.FrontSalesSubtitlefsst,p.FrontSalesQuoteHeadfsqh,p.FrontSalesTextfstx,p.FrontSalesTextNoIndentfstx1,p.FrontSalesQuotefsq,p.FrontSalesQuoteNoIndentfsq1")

//for each section without first-child h1's, create one with .Nonprinting and approporate h1 text
noHeadSection.each (function() {
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
  $(this).prepend("<h1 class='Nonprinting'>"+hText+"</h1>");
});

// //addClass for sections containing related selections
// ataSection.each(function() {
//   $(this).parents("section").addClass("abouttheauthor");
// });
// bobadSection.each(function() {
//   $(this).parents("section").addClass("bobad");
// });
// fsSection.each(function() {
//   $(this).parents("section").addClass("frontsales");
// });



  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

      console.log("Processing instructions have been evaluated!");
	});
});
