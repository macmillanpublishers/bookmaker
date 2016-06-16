var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });


//function to wrap lists in parent ul
  $('*:not(p.Extract-BulletListextbl) + p.Extract-BulletListextbl, p.Extract-BulletListextbl:first-child').each(function() {
    $(this).nextUntil('*:not(p.Extract-BulletListextbl)')
           .addBack()
           .wrapAll("<ul class='Extract-BulletListextbl' />");
  });

  $('p.Extract-BulletListextbl').wrapInner("<li></li>");

  $('ul.Extract-BulletListextbl > p.Extract-BulletListextbl').each(function() {
    newContent = this.firstChild;
    $(this).replaceWith(newContent);
  });

  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

      console.log("Processing instructions have been evaluated!");
	});
});