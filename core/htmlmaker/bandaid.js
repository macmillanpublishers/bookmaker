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
  $('blockquote + p.SpaceBreak-Internalint, aside + p.SpaceBreak-Internalint, pre + p.SpaceBreak-Internalint').remove();
  $('blockquote + p.BookmakerProcessingInstructionbpi, aside + p.BookmakerProcessingInstructionbpi, pre + p.BookmakerProcessingInstructionbpi').remove();

  // fix fig ids in case of duplication
  $('figure').each(function(){
    var myId = $(this).attr('id');
    var newId = "fig-" + myId;
    $(this).attr('id', newId);
  });

  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

      console.log("Processing instructions have been evaluated!");
	});
});