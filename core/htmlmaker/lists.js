var fs = require('fs');
var cheerio = require('cheerio');
var file = process.argv[2];

fs.readFile(file, function processTemplates (err, contents) {
  $ = cheerio.load(contents, {
          xmlMode: true
        });


//function to wrap lists in parent ul
  $('p.Extract-BulletListextbl').wrap("<li class='Extract-BulletListextbl'></li>");

  $('li.Extract-BulletListextbl').wrap("<ul class='Extract-BulletListextbl'></ul>");

  $("ul.Extract-BulletListextbl").each(function () {
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