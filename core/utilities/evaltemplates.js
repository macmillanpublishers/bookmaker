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
      //Matt's code starts here
      var LinkId;
      var el;

      if (baseArgs.length > 1) {
        var seq = baseArgs[1] - 1;
      } else {
        var seq = 0;
      };

      if (baseArgs[0] == "abouttheauthor") {
        if ($('section[class="abouttheauthor"]').length) {
          var el = $('section[class="abouttheauthor"]')[seq];
          var LinkId = $(el).attr('id');
        } else {
          $('a[class="eval-link"][id="abouttheauthor"]').parent().remove();
        };
      } else if (baseArgs[0] == "copyright-page") {
        if ($('section[data-type="copyright-page"]').length) {
          var el = $('section[data-type="copyright-page"]')[seq];
          var LinkId = $(el).attr('id');
        } else {
          $('a[class="eval-link"][id="copyright-page"]').parent().remove();
        };
      } else if (baseArgs[0] == "beginreading") {
        if ($('section[data-type="dedication"]').length) {
          var el = $('section[data-type="dedication"]')[seq];
          var LinkId = $(el).attr('id');
        } else if ($('section[data-type="introduction"]').length) {
          var el = $('section[data-type="introduction"]')[seq];
          var LinkId = $(el).attr('id');
        } else if ($('div[data-type="part"]').length) {
          var el = $('div[data-type="part"]')[seq];
          var LinkId = $(el).attr('id');
        } else {
          var el = $('section[data-type="chapter"]')[seq];
          var LinkId = $(el).attr('id');
        }
      } else if (baseArgs[0] == "toc") {
        var LinkId = "z_TOC";
        $('nav[data-type="toc"]').attr('id', LinkId); 
      };

      target = "#" + LinkId;
      
      $('a[class="eval-link"][id="' + baseArgs[0] + '"]').attr('href', target);

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