var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });

  // evaluate processing instructions
  $("p.BookmakerProcessingInstructionbpi").each(function () {
      var val = $( this ).text()
      if (val = "Ebook-only") {
        $( this ).parent().attr('data-format','ebook')
      } 
      if (val = "Print-only") {
        $( this ).parent().attr('data-format','print')
      }
      if (val.indexOf("TRIM:") > -1) {
        var trimsize = val.split(":").pop().replace(/\s+/g, '');
        trimsize = trimsize.replace(/x/g, ' ');
        var metabooktrim = '<meta name="size" content="' + trimsize + '"/>';
        $('head').append(metabooktrim);
      }
      $(this).remove();
  });

  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

	    console.log("Processing instructions have been evaluated!");
	});
});