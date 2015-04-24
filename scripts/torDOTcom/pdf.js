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
    }
  }
  return matchingElements;
}

var illoSources = document.getElementsByClassName("IllustrationSourceis");
var copyright = getAllElementsWithAttribute('data-type');
for (var j = 0; illoSources.length > j; j++) {
	var figID = illoSources[j].parentNode.getAttribute('id');
	var figLink = illoSources[j].childNodes[0];
	figLink.href = '#' + figID;
	copyright.appendChild(illoSources[j]);
	}