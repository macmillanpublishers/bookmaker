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
      } else if (val.indexOf("DATA:") > -1) {
        var datavalue = val.split("DATA:").pop().replace(/^\s+/g, '');
        var datatype = val.split("DATA:").shift().toLowerCase().replace(/\s+/g, '');
        console.log(datatype + ": " + datavalue);
        var metabookdata = '<meta name="' + datatype + '" content="' + datavalue + '"/>';
        $('head').append(metabookdata);
      } else if (val.indexOf("STYLES:") > -1) {
        var el = $(this);
        var stylearr = val.split(":").pop().split(" ").filter(Boolean);
        for (i = 0; i < stylearr.length; i++) {
          $(el).prev().addClass(stylearr[i]);
        };
      } else if (val.indexOf("LINKTO:") > -1) {
        var linkdest = val.split("LINKTO:").pop().replace(/^\s+/g, '');
        var that = this.previousSibling;
        var el2 = $("<a class='temp'></a>");
        $(that).prepend(el2);
        $(".temp").attr('href', linkdest);
        while (that.firstChild.nextSibling) {
            $(".temp").prepend(that.firstChild.nextSibling);
        }
        $(".temp").removeClass("temp");
      } else if (val.indexOf("IMAGE:") > -1) {
        if (val.indexOf("global") > -1) {
          var prev = $(this).prev();
          var eltype = $(prev).attr('class');
          var imagefile = val.split(":").pop().trim().split(" ").shift();
          var imagetag = "<figure class='Illustrationholderill customimage'><img src='images/" + imagefile + "' alt='" + imagefile + "'/></figure>";
          $("*[class=" + eltype + "]").after(imagetag);
          $("*[class=" + eltype + "]").remove();
          // This code will insert the custom image inside the existing paragraph, instead of as a standard figure tag.
          //var imagetag = "<span class='spanillustrationholderilli'><img src='images/" + imagefile + "'/></span>";
          //$("*[class=" + eltype + "]").empty().append(imagetag);
          //$("*[class=" + eltype + "]").addClass("customimage");
        } else {
          var prev = $(this).prev();
          var imagefile = val.split(":").pop().trim().split(" ").shift();
          var imagetag = "<figure class='Illustrationholderill customimage'><img src='images/" + imagefile + "' alt='" + imagefile + "'/></figure>";
          $(prev).after(imagetag);
          $(prev).remove();
          // This code will insert the custom image inside the existing paragraph, instead of as a standard figure tag.
          //var imagetag = "<span class='spanillustrationholderilli'><img src='images/" + imagefile + "'/></span>";
          //$(prev).empty().append(imagetag);
          //$(prev).addClass("customimage");
        }
      }
      $(this).remove();
  });

  $("section, div").children( ".notoc" ).parent().addClass("notoc");

  var output = $.html();
    fs.writeFile(file, output, function(err) {
	    if(err) {
	        return console.log(err);
	    }

	    console.log("Processing instructions have been evaluated!");
	});
});