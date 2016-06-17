var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });


//function to wrap lists in parent ul
function tagLists (myclass, listtype) {
  $( "p." + myclass ).wrap("<li class='" + myclass + "'></li>");

  $( "li." + myclass ).wrap("<" + listtype + " class='" + myclass + "'></" + listtype + ">");

  $(listtype + "." + myclass).each(function () {
      var that = this.previousSibling;
      var thisclass = $(this).attr('class');
      var previousclass = $(that).attr('class');
      if ((that && that.nodeType === 1 && that.tagName === this.tagName && typeof $(that).attr('class') !== 'undefined' && thisclass === previousclass)) {
        var mytag = this.tagName.toString();
        var el = $("<" + mytag + "/>").addClass("temp");
        $(this).after(el);
        var node = $(".temp");
        while (that.firstChild) {
            node.append(that.firstChild);
        }
        while (this.firstChild) {
            node.append(this.firstChild);
        }
        $(that).remove();
        $(this).remove();
      }
      $(".temp").addClass(thisclass).removeClass("temp");
    });
}

tagLists ("Extract-BulletListextbl", "ul");
tagLists ("SidebarListBulletsbbl", "ul");
tagLists ("SidebarListNumsbnl", "ol");
tagLists ("BoxListBulletbbl", "ul");
tagLists ("BoxListNumbnl", "ol");

  var output = $.html();
    fs.writeFile(file, output, function(err) {
      if(err) {
          return console.log(err);
      }

      console.log("Processing instructions have been evaluated!");
  });
});