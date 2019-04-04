var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];
var templateversion = process.argv[3];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });

  // add meta info for template_version if it doesn't already exist
  metacheck = $("meta[name='templateversion']")
  if (metacheck.length == 0) {
    var metatemplateversion = '<meta name="templateversion" content="' + templateversion + '"/>';
    $('head').append(metatemplateversion);
  }

  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

	    console.log("Processing instructions have been evaluated!");
	});
});
