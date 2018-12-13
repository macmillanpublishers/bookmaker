var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });

//function to replace element, keeping innerHtml & attributes
function replaceEl (selector, newTag) {
  selector.each(function(){
    var myAttr = $(this).attr();
    var myHtml = $(this).html();
    $(this).replaceWith(function(){
        return $(newTag).html(myHtml).attr(myAttr);
    });
  });
}

///////////////////////////// FOOTNOTES
//select <p>s nested in spans with data-type 'footnote'
var footnoteNestedP = $("span[data-type='footnote'] p");
//call function, replace selected <p>s to spans
replaceEl (footnoteNestedP, "<span data-type='footnote' />");
//remove unwanted sections/ empty divs put there by Word
$("section[data-type='footnotes']").remove();
$("#endnotetext_0").remove();
$("#endnotetext_-1").remove();


///////////////////////////// STRIP-TOC
//addClass to 'preface' section (with h1 text containing 'Contents')
$("section[data-type='preface']>h1:contains('Contents')").parents("section").addClass('texttoc');
$("section[data-type='preface']>h1:contains('CONTENTS')").parents("section").addClass('texttoc');
$("section[data-type='preface']>p[class^='TOC']").parents("section").addClass('texttoc');


///////////////////////////// PARTS
//select sections with data-type 'part'
var datatypePart = $("section[data-type='part']");
//change them to 'div's
replaceEl (datatypePart, "<div />");


//////////////////////////// HEADINGS
//select sections without first-child h1's
var noHeadSection = $("section:not(:has(h1:first-child))");
//select sections' nested elements (<p>s, h1's) with classes or text matching key criteria
var ataSection = $("section").find("p.AboutAuthorTextNo-Indentatatx1,p.AboutAuthorTextHeadatah,p.AboutAuthorTextatatx,h1:contains(About the Author)");
var bobadSection = $("section").find("h1.BOBAdTitlebobt,p.BOBAdTextbobtx")
var fsSection = $("section").find("p.FrontSalesTitlefst,p.FrontSalesSubtitlefsst,p.FrontSalesQuoteHeadfsqh,p.FrontSalesTextfstx,p.FrontSalesTextNoIndentfstx1,p.FrontSalesQuotefsq,p.FrontSalesQuoteNoIndentfsq1")

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
//addClass for sections containing related selections
ataSection.each(function() {
  $(this).parents("section").addClass("abouttheauthor");
});
bobadSection.each(function() {
  $(this).parents("section").addClass("bobad");
});
fsSection.each(function() {
  $(this).parents("section").addClass("frontsales");
});


///////////////////////////// LISTS
//function to wrap lists in parent ul
function tagLists (myclass, listtype) {
  $( "p." + myclass ).wrap("<li class='" + myclass + "'></li>");

  $( "li." + myclass ).wrap("<" + listtype + " class='" + myclass + "'></" + listtype + ">");

  $(listtype + "." + myclass).each(function () {
      var that = this.previousSibling;
      var thisclass = $(this).attr('class');
      var previousclass = $(that).attr('class');
      if ((that && that.nodeType === 1 && that.tagName === this.tagName && typeof $(that).attr('class') !== 'undefined' && thisclass === previousclass)) {
        var mytag = this.tagName.toString();
        var el = $("<" + mytag + "/>").addClass("temp");
        $(this).after(el);
        var node = $(".temp");
        while (that.firstChild) {
            node.append(that.firstChild);
        }
        while (this.firstChild) {
            node.append(this.firstChild);
        }
        $(that).remove();
        $(this).remove();
      }
      $(".temp").addClass(thisclass).removeClass("temp");
    });
}

tagLists ("Extract-BulletListextbl", "ul");
tagLists ("SidebarListBulletsbbl", "ul");
tagLists ("SidebarListNumsbnl", "ol");
tagLists ("BoxListBulletbbl", "ul");
tagLists ("BoxListNumbnl", "ol");


///////////////////////////// from BANDAID.js
// paragraphs to remove after conversion
$('blockquote + p.SpaceBreak-Internalint, aside + p.SpaceBreak-Internalint, pre + p.SpaceBreak-Internalint').remove();
$('blockquote + p.BookmakerProcessingInstructionbpi, aside + p.BookmakerProcessingInstructionbpi, pre + p.BookmakerProcessingInstructionbpi').remove();

// (adding this back, was left out from orig. xsl_only capture)
// remove links to headings with no non-whitespace content from <nav>
navListItems = $("nav[data-type='toc'] li");
navListItems.each(function() {
  if($(this).find("a").text().trim() == '') {
    $(this).remove();
  }
})

  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

      console.log("Processing instructions have been evaluated!");
	});
});
