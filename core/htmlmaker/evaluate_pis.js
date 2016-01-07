var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });

  // evaluate processing instructions
  $("p.bookmakerprocessinginstructionbpi").each(function () {
      var val = $( this ).text()
      if (val = "Ebook-only") {
        $( this ).parent().attr('data-format','ebook')
      } else if ($( this ).text() = "Print-only") {
        $( this ).parent().attr('data-format','print')
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