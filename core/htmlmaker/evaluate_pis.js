var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });

  // evaluate processing instructions
  $("p.BookmakerProcessingInstructionbpi").each(function () {
      var val = $( this ).text();
      if (val == "Ebook-only") {
        $( this ).parent().attr('data-format','ebook');
      } else if (val == "Print-only") {
        $( this ).parent().attr('data-format','print');
      } else if (val.indexOf("TRIM:") > -1) {
        var trimsize = val.split(":").pop().replace(/\s+/g, '');
        trimsize = trimsize.replace(/x/g, ' ');
        console.log("TRIM: " + trimsize);
        var metabooktrim = '<meta name="size" content="' + trimsize + '"/>';
        $('head').append(metabooktrim);
      } else if (val.indexOf("TOC:") > -1) {
        var toctype = val.split(":").pop().toLowerCase().replace(/\s+/g, '');
        console.log("TOC: " + toctype);
        var metatoctype = '<meta name="toc" content="' + toctype + '"/>';
        $('head').append(metatoctype);
      } else if (val.indexOf("BOOKTITLE:") > -1 || val.indexOf("BOOKAUTHOR:") > -1 || val.indexOf("BOOKSUBTITLE:") > -1 || val.indexOf("IMPRINT:") > -1 || val.indexOf("PUBLISHER:") > -1) {
        var datavalue = val.split(":").pop().replace(/\s+/g, '');
        var datatype = val.split(":").shift().toLowerCase().replace(/\s+/g, '');
        console.log(datatype + ": " + datavalue);
        var metabookdata = '<meta name="' + datatype + '" content="' + datavalue + '"/>';
        $('head').append(metabookdata);
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