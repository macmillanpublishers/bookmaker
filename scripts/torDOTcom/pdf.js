function getAllElementsWithAttribute(attribute)
{
  var matchingElements = [];
  var allSections = document.getElementsByTagName('section');
  for (var i = 0, n = allSections.length; i < n; i++)
  {
    if (allSections[i].getAttribute(attribute) == 'copyright-page')
    {
      // Element exists with attribute. Add to array.
      matchingElements.push(allSections[i]);
    };
  };
  return matchingElements;
};

function moveIllustrationSource()
{
var illoSources = document.getElementsByClassName("IllustrationSourceis");
var copyright = getAllElementsWithAttribute("data-type")[0];
for (var j = 0; illoSources.length > j; j++) {
	var figID = illoSources[j].parentNode.getAttribute('id');
	var figLink = illoSources[j].childNodes[0];
	figLink.href = '#' + figID;
	copyright.appendChild(illoSources[j]);
	};
};

function fullpageFigures() {
  var allIllos = document.getElementsByTagName('img');
  var fullpageFigs = [];
  for (var h = 0; allIllos.length > h; h++) {
    var illoType = allIllos[h].getAttribute('src');
    if (illoType.indexOf("fullpage") > -1)
    {
      fullpageFigs.push(allIllos[h]);
    };
  };
  for (var f = 0; fullpageFigs.length > f; f++) {
    var parentFig = fullpageFigs[f].parentNode;
    parentFig.setAttribute("class", "Illustrationholderill fullpage");
  };
};

window.onload = function() {
  moveIllustrationSource();
  fullpageFigures();
};

// exclude author photo
// test in prince: done: run with --javascript flag (need to enable in DR)
// remove first funtion if poss?
// implement custom script support in pdfmaker