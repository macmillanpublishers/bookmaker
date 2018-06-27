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

  // paragraphs to remove after conversion
  $('blockquote + p.SpaceBreak-Internalint, aside + p.SpaceBreak-Internalint, pre + p.SpaceBreak-Internalint').remove();
  $('blockquote + p.BookmakerProcessingInstructionbpi, aside + p.BookmakerProcessingInstructionbpi, pre + p.BookmakerProcessingInstructionbpi').remove();

  // fix fig ids in case of duplication
  $('figure').each(function(){
    var myId = $(this).attr('id');
    if ( myId !== undefined ) {
      var newId = "fig-" + myId;
      $(this).attr('id', newId);
    }
  });

  // remove leading and trailing brackets from image filenames
  $('figure img').each(function(){
    var mySrc = $(this).attr('src');
    var myAlt = $(this).attr('alt');
    var mypattern1 = new RegExp( "^images/\\[", "g");
    var mypattern2 = new RegExp( "\\]$", "g");
    var result1 = mypattern1.test(mySrc);
    var result2 = mypattern2.test(mySrc);
    if ( result1 === true && result2 === true ) {
      mySrc = mySrc.replace("[", "").replace("]", "");
    } else {
      mySrc = mySrc.replace("[", "%5B").replace("]", "%5D");
    }
    $(this).attr('src', mySrc);
    myAlt = myAlt.replace("[", "%5B").replace("]", "%5D");
    $(this).attr('alt', myAlt);
  });

  // fix brackets in urls
  $('a[href]').each(function(){
    var myHref = $(this).attr('href');
    myHref = myHref.replace("[", "%5B").replace("]", "%5D");
    $(this).attr('href', myHref);
  });

  $('span.spanhyperlinkurl:not(":has(a)")').each(function(){
    var myText = $(this).text();
    myText = myText.replace("[", "%5B").replace("]", "%5D");
    $(this).empty();
    $(this).append(myText);
  });

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
