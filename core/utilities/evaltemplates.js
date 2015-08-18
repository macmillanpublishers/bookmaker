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
      var LinkId;

      if (baseArgs.length > 0) {
        var seq = baseArgs[1] - 1;
      } else {
        var seq = 0;
      };

      if (baseArgs[0] == "abouttheauthor") {
        if ($('section[class="abouttheauthor"]').length) {
          Linkid = $('section[class="abouttheauthor"]')[seq].attr('id');
        } else {
          $('a[class="eval-link"][id="abouttheauthor"]').parent().remove();
        };
      } else if (baseArgs[0] == "copyright-page") {
        if ($('section[data-type="copyright-page"]').length) {
          Linkid = $('section[data-type="copyright-page"]')[seq].attr('id');
        } else {
          $('a[class="eval-link"][id="copyright-page"]').parent().remove();
        };
      } else if (baseArgs[0] == "beginreading") {
        if ($('section[data-type="introduction"]').length) {
          Linkid = $('section[data-type="introduction"]')[seq].attr('id');
        } else if ($('div[data-type="part"]').length) {
          Linkid = $('div[data-type="part"]')[seq].attr('id');
        } else {
          Linkid = $('section[data-type="chapter"]')[seq].attr('id');
        }
      } else if (baseArgs[0] == "toc") {
        LinkId = "z_TOC";
        $('nav[data-type="toc"]').attr('id', LinkId); 
      };
      
      $('a[class="eval-link"][id="' + baseArgs[0] + '"]').attr('href', LinkId);

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