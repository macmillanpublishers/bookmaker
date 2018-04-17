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

//select <p>s nested in spans with data-type 'footnote'
var footnoteNestedP = $("span[data-type='footnote'] p");
//call function, replace selected <p>s to spans
replaceEl (footnoteNestedP, "<span data-type='footnote' />");
//remove unwanted sections/ empty divs put there by Word
$("section[data-type='footnotes']").remove();
$("#endnotetext_0").remove();
$("#endnotetext_-1").remove();



  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

      console.log("Processing instructions have been evaluated!");
	});
});
