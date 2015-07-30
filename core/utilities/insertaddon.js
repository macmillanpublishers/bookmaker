var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];
var addonContent = process.argv[3];
var locationContainer = process.argv[4];
var locationType = process.argv[5];
var locationClass = process.argv[6];
var s = process.argv[7] - 1;
var locationName = process.argv[8];

fs.readFile(file, function insertAddon (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });
  if (locationType && locationClass) { 
  	var marker = $(locationContainer + '[class="' + locationClass + '"][data-type="' + locationType + '"]')[s]; 
  } else if (locationType && !locationClass) {
  	var marker = $(locationContainer + '[data-type="' + locationType + '"]')[s];
  } else if (!locationType && locationClass) {
  	var marker = $(locationContainer + '[class="' + locationClass + '"]')[s];
  } else {
  	var marker = $(locationContainer)[s];
  };
  
  if (locationName == "endofbook") {
  	$('body').append(addonContent);
  } else {
    $(marker).before(addonContent);
  };

  var output = $.html();
	  fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

	    console.log("Addon content has been inserted!");
	});
});