var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];
var srcEl = process.argv[3];
var srcType = process.argv[4];
var srcClass = process.argv[5];
if (process.argv[6] > 0) {
  var num = process.argv[6] - 1;
  var ss = "[" + num.toString() + "]";
} else {
  var ss = "";
}
var destEl = process.argv[7];
var destType = process.argv[8];
var destClass = process.argv[9];
if (process.argv[10] > 0) {
  var num2 = process.argv[10] - 1;
  var ds = "[" + num2.toString() + "]";
} else {
  var ds = "";
}

fs.readFile(file, function moveSection (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });

  if (srcType && srcClass) { 
  	var source = $(srcEl + '[class="' + srcClass + '"][data-type="' + srcType + '"]') + ss; 
  } else if (srcType && !srcClass) {
  	var source = $(srcEl + '[data-type="' + srcType + '"]') + ss;
  } else if (!srcType && srcClass) {
  	var source = $(srcEl + '[class="' + srcClass + '"]') + ss;
  } else {
  	var source = $(srcEl) + ss;
  };

  if (destType && destClass) { 
    var destination = $(destEl + '[class="' + destClass + '"][data-type="' + destType + '"]') + ds; 
  } else if (destType && !destClass) {
    var destination = $(destEl + '[data-type="' + destType + '"]') + ds;
  } else if (!destType && destClass) {
    var destination = $(destEl + '[class="' + destClass + '"]') + ds;
  } else {
    var destination = $(destEl) + ds;
  };
  
  if (destEl == "body") {
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