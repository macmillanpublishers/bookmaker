var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });

  // empty the nav for epub generation
  $('nav[data-type="toc"').empty();

  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

	    console.log("TOC has been emptied!");
	});
});