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

  //selections
  var ems = $("span[class='spanitaliccharactersital']");
  var strongs = $("span[class='spanboldfacecharactersbf']");
  var sups = $("span[class='spansuperscriptcharacterssup']");
  var subs = $("span[class='spansubscriptcharacterssub']");
  var scitals = $("span[class='spansmcapitalscital']"); 
  var scbolds = $("span[class='spansmcapboldscbold']");
  var italbems = $("span[class='spanbolditalbem']");
  //call replaceEl to replace selected span elements with formatting tags
  replaceEl (ems, "<em/>");
  replaceEl (strongs, "<strong/>");
  replaceEl (sups, "<sup/>");
  replaceEl (subs, "<sub/>");
  //these two spans require nested tags, wrapping existing span (wth appropriate class) with new tag
  scitals.each(function(){
    $(this).wrap("<em/>");
  });
  scbolds.each(function(){
    $(this).wrap("<strong/>");
  });
  //this span requires an element be replaced and wrapped, same function as above + this.wrap
  italbems.each(function(){
    var myAttr = $(this).attr();
    var myHtml = $(this).html();
    $(this).wrap("<strong/>");
    $(this).replaceWith(function(){
        return $("<em/>").html(myHtml).attr(myAttr);
    });
  });

  // support for inline images
  $('span.Illustrationholderinlineilli').each(function () {
    var mytext = $(this).text().trim();
    var el = $('<img class="illustrationholderinlineilli" src="images/' + mytext + '"></img>');
    $(this).empty();
    $(this).append(el);
  });

  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

      console.log("Processing instructions have been evaluated!");
	});
});