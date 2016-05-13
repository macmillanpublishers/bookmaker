var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];
var srcEl = process.argv[3];
var srcType = process.argv[4];
var srcClass = process.argv[5];
var destEl = process.argv[7];
var destType = process.argv[8];
var destClass = process.argv[9];
var ds = process.argv[10] - 1;

fs.readFile(file, function moveSection (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });

  if (process.argv[6].length > 0) {
    var ss = process.argv[6] - 1;
    if (srcType && srcClass) { 
    	var source = $(srcEl + '[class="' + srcClass + '"][data-type="' + srcType + '"]')[ss]; 
    } else if (srcType && !srcClass) {
    	var source = $(srcEl + '[data-type="' + srcType + '"]')[ss];
    } else if (!srcType && srcClass) {
    	var source = $(srcEl + '[class="' + srcClass + '"]')[ss];
    } else {
    	var source = $(srcEl)[ss];
    };
  } else {
    var ss = "";
    if (srcType && srcClass) { 
      var source = $(srcEl + '[class="' + srcClass + '"][data-type="' + srcType + '"]'); 
    } else if (srcType && !srcClass) {
      var source = $(srcEl + '[data-type="' + srcType + '"]');
    } else if (!srcType && srcClass) {
      var source = $(srcEl + '[class="' + srcClass + '"]');
    } else {
      var source = $(srcEl);
    };
  }

  if (destType && destClass) { 
    var destination = $(destEl + '[class="' + destClass + '"][data-type="' + destType + '"]')[ds]; 
  } else if (destType && !destClass) {
    var destination = $(destEl + '[data-type="' + destType + '"]')[ds];
  } else if (!destType && destClass) {
    var destination = $(destEl + '[class="' + destClass + '"]')[ds];
  } else {
    var destination = $(destEl)[ds];
  };
  
  $(source).each(function () {
    if (destEl == "body") {
    	$('body').append(this);
    } else {
      $(this).insertBefore(destination);
    };
  });

  var output = $.html();
	  fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

	    console.log("Section has been moved!");
	});
});