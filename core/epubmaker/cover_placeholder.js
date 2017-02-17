var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });


// insert <fig> placeholder for cover image immediately following <body>
  $("body[data-type='book']").prepend(
    $("<figure>")
    .attr('data-type','cover')
    .attr('id','bookcover01').append(
      $("<img>")
      .attr('src','cover.jpg')
    ))


  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

	    console.log("TOC has been emptied!");
	});
});
