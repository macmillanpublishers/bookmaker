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
//select sections with data-type 'part'
var datatypePart = $("section[data-type='part']");
//change them to 'div's
replaceEl (datatypePart, "<div />");



  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

      console.log("Processing instructions have been evaluated!");
	});
});