var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];
var src = process.argv[3];
var srcType = process.argv[4];
var srcClass = process.argv[5];
var ss = process.argv[6];
var dest = process.argv[7];
var destType = process.argv[8];
var destClass = process.argv[9];
var ds = process.argv[10];

fs.readFile(file, function moveSection (err, contents) {
  $ = cheerio.load(contents);
  if (srcType && srcClass) { 
  	var source = $(src + '[class="' + srcClass + '"][data-type="' + srcType + '"]')[ss]; 
  } else if (srcType && !srcClass) {
  	var source = $(src + '[data-type="' + srcType + '"]')[ss];
  } else if (!srcType && srcClass) {
  	var source = $(src + '[class="' + srcClass + '"]')[ss];
  } else {
  	var source = $(src)[ss];
  };

  if (destType && destClass) { 
    var destination = $(dest + '[class="' + destClass + '"][data-type="' + destType + '"]')[ds]; 
  } else if (destType && !destClass) {
    var destination = $(dest + '[data-type="' + destType + '"]')[ds];
  } else if (!destType && destClass) {
    var destination = $(dest + '[class="' + destClass + '"]')[ds];
  } else {
    var destination = $(dest)[ds];
  };
  
  if (dest == "body") {
  	$('body').append(source);
  } else {
    $(source).insertBefore(destination);
  };

  var output = $.html();
	  fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

	    console.log("Section has been moved!");
	});
});

// find section to be moved
// find position to move it to
// move it

var cover = $()
var halftitlepage = $()
var titlepage = $()