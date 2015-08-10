var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];
var template = process.argv[3];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });

  var sourceEl = $('[class="' + template + '"]');
  for (var j = 0; sourceEl.length > j; j++) {
    // find the args
    var thisNode = sourceEl[j];
    var baseArgs = $(thisNode).attr('id').split("_");

    // evaluate the templates
    if (template == "eval-link") {
      //...Matt's code...

      // replace sourceEl class so it doesn't get reprocessed
      $(thisNode).attr('class', 'spanhyperlink');
    };
  };

  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

	    console.log("Template has been compiled!");
	});
});