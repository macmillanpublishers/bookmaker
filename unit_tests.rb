require "test/unit"
require_relative "./core/htmlmaker/htmlmaker.rb"


class HtmlmakerTests < Test::Unit::TestCase

  def test_strip_endnotes
    endnotes_with_content = '<section data-type="appendix" class="abouttheauthor" id="d1e4739"><h1 class="BMHeadbmh">About the Author</h1><p class="BMTextNo-Indentbmtx1"><span class="spansmallcapscharacterssc">Kai Ashante Wilson</span>&#x2019;s stories &#x201C;Super Bass&#x201D; and &#x201C;The Devil in America,&#x201D; the latter of which was nominated for the Nebula, the Shirley Jackson, and the World Fantasy Awards, can be read online gratis at <em class="spanitaliccharactersital">Tor.com</em>. His story &#xAB;<em class="spanitaliccharactersital">L&#xE9;gendaire</em>.&#xBB; can be read in the anthology <em class="spanitaliccharactersital">Stories for Chip,</em> which celebrates the legacy of science fiction grandmaster Samuel R. Delany. Kai Ashante Wilson lives in New York City.</p></section><section data-type="appendix" class="endnotes"><h1 class="BMHeadbmh">Endnotes</h1><div class="endnotetext" id="endnotetext-1"><p class="EndnoteText"><span class="EndnoteReference"/> See Burrough (2015, p. 5). On Watts, see Bloom and Martin (2013, p. 29) and Barber (2010).</p></div></section></body></html>'
    endnotes_without_content = '<section data-type="appendix" class="abouttheauthor" id="d1e4739"><h1 class="BMHeadbmh">About the Author</h1><p class="BMTextNo-Indentbmtx1"><span class="spansmallcapscharacterssc">Kai Ashante Wilson</span>&#x2019;s stories &#x201C;Super Bass&#x201D; and &#x201C;The Devil in America,&#x201D; the latter of which was nominated for the Nebula, the Shirley Jackson, and the World Fantasy Awards, can be read online gratis at <em class="spanitaliccharactersital">Tor.com</em>. His story &#xAB;<em class="spanitaliccharactersital">L&#xE9;gendaire</em>.&#xBB; can be read in the anthology <em class="spanitaliccharactersital">Stories for Chip,</em> which celebrates the legacy of science fiction grandmaster Samuel R. Delany. Kai Ashante Wilson lives in New York City.</p></section><section data-type="appendix" class="endnotes"><h1 class="BMHeadbmh">Endnotes</h1><div class="endnotetext" id="endnotetext-1"><p><span class="EndnoteReference"/></div></section></body></html>'
    no_endnotes = '<section data-type="appendix" class="abouttheauthor" id="d1e4739"><h1 class="BMHeadbmh">About the Author</h1><p class="BMTextNo-Indentbmtx1"><span class="spansmallcapscharacterssc">Kai Ashante Wilson</span>&#x2019;s stories &#x201C;Super Bass&#x201D; and &#x201C;The Devil in America,&#x201D; the latter of which was nominated for the Nebula, the Shirley Jackson, and the World Fantasy Awards, can be read online gratis at <em class="spanitaliccharactersital">Tor.com</em>. His story &#xAB;<em class="spanitaliccharactersital">L&#xE9;gendaire</em>.&#xBB; can be read in the anthology <em class="spanitaliccharactersital">Stories for Chip,</em> which celebrates the legacy of science fiction grandmaster Samuel R. Delany. Kai Ashante Wilson lives in New York City.</p></section></body></html>'

    # test that our method doesn't bother endnotes with content
    assert_equal(endnotes_with_content, stripEndnotes(endnotes_with_content))
    # test to verify our method strips endnotes without content
    assert_equal(no_endnotes, stripEndnotes(endnotes_without_content))
    # test to verify our method doesn't err or make undesired transformations with no endnotes
    assert_equal(no_endnotes, stripEndnotes(no_endnotes))
    #testing with empty string, probably not necessary--
    assert_equal('', stripEndnotes(''))
    #other tests (for raising exception?) could include passing an undefined var, or nil, or no argument.
    #likely overkill

  end

end
