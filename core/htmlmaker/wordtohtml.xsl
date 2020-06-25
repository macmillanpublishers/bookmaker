<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="w xs">

  <!-- v0.1: basic support just for headings, paragraphs, and char
       styles as spans -->
  <!-- additions by Christopher R. Maden, crism consulting,
       crism@maden.org
       Switched to XSLT 2.0.
       Made XHTML5 / HTMLBook valid. -->

  <!-- OPEN ISSUES:
       If a chapter has a title and a number, both will appear as
       separate list items in toc -->

  <xsl:output indent="no" method="html" omit-xml-declaration="yes"
    version="5"/>

  <!-- =-= Generalized mapping variables. =-= -->

  <!-- paragraphs that are used in many other types of blocks -->
  <xsl:variable name="versatile-block-paras" as="xs:string*">
    <xsl:sequence
      select="'SpaceBreak-Internalint',
              'BookmakerProcessingInstructionbpi'"/>
  </xsl:variable>

  <!-- Paragraph styles which should get aggregated in an epigraph
       blockquote. -->
  <xsl:variable name="epigraph-paras" as="xs:string*">
    <xsl:sequence
      select="'PartEpigraph-non-versepepi',
              'PartEpigraph-versepepiv',
              'PartEpigraphSourcepeps',
              'ChapEpigraph-non-versecepi',
              'ChapEpigraph-versecepiv',
              'ChapEpigraphSourceceps',
              'FMEpigraph-non-versefmepi',
              'FMEpigraph-versefmepiv',
              'FMEpigraphSourcefmeps',
              'Epigraph-non-verseepi',
              'Epigraph-verseepiv',
              'EpigraphSourceeps',
              'EpigraphinText-non-versetepi',
              'EpigraphinText-versetepiv',
              'EpigraphinText-Sourceteps'"/>
  </xsl:variable>

  <!-- Paragraph styles which should get aggregated in a poetry
       pre. -->
  <xsl:variable name="poetry-paras" as="xs:string*">
    <xsl:sequence
      select="'PoemTitlevt',
              'PoemSubtitlevst',
              'PoemLevel-1Subheadvh1',
              'PoemLevel-2Subheadvh2',
              'PoemLevel-3Subheadvh3',
              'PoemLevel-4Subheadvh4',
              'VerseTextvtx',
              'VerseRun-inTextNo-Indentvrtx1',
              'VerseRun-inTextvrtx'"/>
  </xsl:variable>

<!-- Paragraph styles which should get aggregated in a box
       aside. -->
  <xsl:variable name="box-paras" as="xs:string*">
    <xsl:sequence
      select="'BoxHeadbh',
              'BoxSubheadbsh',
              'BoxEpigraph-non-versebepi',
              'BoxEpigraphSourcebeps',
              'BoxEpigraph-versebepiv',
              'BoxEpigraphSourcebeps',
              'BoxTextNo-Indentbtx1',
              'BoxHead-Level-1bh1',
              'BoxTextNo-Indentbtx1',
              'BoxListNumbnl',
              'BoxListNumbnl',
              'BoxListNumbnl',
              'BoxListNumbnl',
              'BoxHead-Level-2bh2',
              'BoxListBulletbbl',
              'BoxListBulletbbl',
              'BoxTextbtx',
              'BoxTextbtx',
              'BoxHead-Level-2bh2',
              'BoxTextNo-Indentbtx1',
              'BoxHead-Level-3bh3',
              'BoxTextbtx',
              'BoxHead-Level-4bh4',
              'BoxTextNo-Indentbtx1',
              'BoxExtractbext',
              'BoxTextbtx',
              'BoxHead-Level-2bh2',
              'BoxTextNo-Indentbtx1',
              'BoxHead-Level-2bh2',
              'BoxTextNo-Indentbtx1',
              'BoxTextbtx',
              'BoxTextbtx',
              'BoxSourceNotebsn',
              'BoxFootnotebfn'"/>
  </xsl:variable>

<!-- Paragraph styles which should get aggregated in a sidebar
       aside. -->
  <xsl:variable name="sidebar-paras" as="xs:string*">
    <xsl:sequence
      select="'SidebarHeadsbh',
              'SidebarSubheadsbsh',
              'SidebarEpigraph-non-versesbepi',
              'SidebarEpigraphSourcesbeps',
              'SidebarEpigraph-versesbepiv',
              'SidebarEpigraphSourcesbeps',
              'SidebarTextNo-Indentsbtx1',
              'SidebarHead-Level-1sbh1',
              'SidebarTextNo-Indentsbtx1',
              'SidebarListNumsbnl',
              'SidebarListNumsbnl',
              'SidebarListNumsbnl',
              'SidebarListNumsbnl',
              'SidebarHead-Level-2sbh2',
              'SidebarListBulletsbbl',
              'SidebarListBulletsbbl',
              'SidebarTextsbtx',
              'SidebarTextsbtx',
              'SidebarHead-Level-2sbh2',
              'SidebarTextNo-Indentsbtx1',
              'SidebarHead-Level-3sbh3',
              'SidebarTextNo-Indentsbtx1',
              'SidebarHead-Level-4sbh4',
              'SidebarTextNo-Indentsbtx1',
              'SidebarExtractsbext',
              'SidebarTextsbtx',
              'SidebarHead-Level-2sbh2',
              'SidebarTextNo-Indentsbtx1',
              'SidebarHead-Level-2sbh2',
              'SidebarTextNo-Indentsbtx1',
              'SidebarTextsbtx',
              'SidebarTextsbtx',
              'SidebarSourceNotesbsn',
              'SidebarFootnotesbfn'"/>
  </xsl:variable>

  <!-- Figure style names — these paragraphs are expected to have
       content that gives an image filename. -->
  <xsl:variable name="fig-paras" as="xs:string*">
    <xsl:sequence
      select="'Illustrationholderill'"/>
  </xsl:variable>

  <!-- Caption styles — these paragraphs are expected to immediately
       follow or precede a style from $fig-paras. -->
  <xsl:variable name="fig-cap-paras" as="xs:string*">
    <xsl:sequence
      select="'Captioncap'"/>
  </xsl:variable>

  <!-- Illustration source styles — these paragraphs are expected to immediately
       follow or precede a style from $fig-paras. -->
  <xsl:variable name="fig-source-paras" as="xs:string*">
    <xsl:sequence
      select="'IllustrationSourceis'"/>
  </xsl:variable>

  <!-- List paragraph styles — divided by ordered and un-, but
       aggregation will always(?) be homogeneous. -->
  <xsl:variable name="list-num-paras" as="xs:string*">
    <xsl:sequence
      select="'ListNumnl',
              'AppendixListNumapnl'"/>
  </xsl:variable>
  <xsl:variable name="list-unnum-paras" as="xs:string*">
    <xsl:sequence
      select="'ListBulletbl',
              'ListUnnumul',
              'AppendixListUnnumapul',
              'AppendixListBulletapbl',
              'Checklistck',
              'ChapterContentscc'"/>
  </xsl:variable>
  <xsl:variable name="list-sub-paras" as="xs:string*">
    <xsl:sequence
      select="$list-sub-num-paras, $list-sub-unnum-paras"/>
  </xsl:variable>
  <xsl:variable name="list-sub-num-paras" as="xs:string*">
    <xsl:sequence
      select="'ListNumSubentrynsl',
              'ListAlphaSubentryasl'"/>
  </xsl:variable>
  <xsl:variable name="list-sub-unnum-paras" as="xs:string*">
    <xsl:sequence
      select="'ListBulletSubentrybsl',
              'ListUnnumSubentryusl',
              'ChecklistSubentrycksl'"/>
  </xsl:variable>

  <!-- Paragraph styles used for print formatting only, to be dropped
       in HTMLBook conversion. -->
  <xsl:variable name="omit-paras" as="xs:string*">
    <xsl:sequence
      select="'PageBreakpb',
              'SectionBreaksbr',
              'PartStartpts',
              'PartEndpte',
              'ChapNumbercn'"/>
  </xsl:variable>

  <!-- Paragraph styles used to add spacing, to be ignored when
  assigning sections and blocks. -->
  <xsl:variable name="spacing-paras" as="xs:string*">
    <xsl:sequence
      select="'SpaceBreak-1-Linels1',
              'SpaceBreak-2-Linels2',
              'SpaceBreak-3-Linels3',
              'SpaceBreak',
              'SpaceBreakwithOrnamentorn',
              'SpaceBreakOrnamentorn',
              'SpaceBreakwithALTOrnamentorn2',
              'SpaceBreak-Internalint',
              'SpaceBreak-PrintOnlypo'"/>
  </xsl:variable>

  <!-- Top-level divider paragraphs, any of which might signal the
       start of body content (and therefore trigger the table of
       contents). -->
  <xsl:variable name="top-level-body-breaks" as="xs:string*">
    <xsl:sequence
      select="'BMHeadbmh',
              'BMHeadNonprintingbmhnp',
              'BMHeadALTabmh',
              'ChapTitlect',
              'ChapTitleNonprintingctnp',
              'ChapTitleALTact',
              'PartNumberpn',
              'PartTitlept',
              'FMHeadfmh',
              'FMHeadNonprintingfmhnp',
              'FMHeadALTafmh',
              'AboutAuthorTextHeadatah'"/>
  </xsl:variable>

  <!-- Paragraphs that are part of the chapter opener block, that
  may signify the start of a new chapter if no Chapter Title
  or Chapter Number is present. -->
  <xsl:variable name="chap-opener-paras" as="xs:string*">
    <xsl:sequence
      select="'ChapOpeningTextcotx',
              'ChapOpeningTextSpaceAftercotx',
              'ChapOpeningTextNo-Indentcotx1',
              'ChapOpeningTextNo-IndentSpaceAftercotx1',
              'ChapOrnamentcorn',
              'ChapOrnamentALTcorn2',
              'ChapSubtitlecst',
              'ChapAuthorca',
              'Dateline-Chapterdl',
              'ChapEpigraph-non-versecepi',
              'ChapEpigraphSourceceps',
              'ChapEpigraph-versecepiv',
              'ChapterContentscc'"/>
  </xsl:variable>

  <!-- Top-level divider paragraphs — styles which signal the start of
       a new top-level section such as a chapter or copyright
       page. -->
  <xsl:variable name="top-level-breaks" as="xs:string*">
    <xsl:sequence
      select="$top-level-body-breaks,
              'AdCardMainHeadacmh',
              'FrontSalesTitlefst',
              'BOBAdTitlebobt',
              'CopyrightTextsinglespacecrtx',
              'CopyrightTextdoublespacecrtxd',
              'Dedicationded',
              'HalftitleBookTitlehtit',
              'TitlepageBookTitletit',
              'PartNumberpn',
              'PartTitlept'"/>
  </xsl:variable>

  <!-- Headings for top-level dividers; when they arise, they are
       converted to h1 elements. -->
  <xsl:variable name="top-level-heads" as="xs:string*">
    <xsl:sequence
      select="'BMHeadbmh',
              'BMHeadNonprintingbmhnp',
              'BMHeadALTabmh',
              'AppendixHeadaph',
              'AboutAuthorTextHeadatah',
              'PartNumberpn',
              'PartTitlept',
              'ChapTitlect',
              'ChapTitleALTact',
              'ChapTitleNonprintingctnp',
              'FMHeadfmh',
              'FMHeadNonprintingfmhnp',
              'FMHeadALTafmh',
              'FrontSalesTitlefst',
              'BOBAdTitlebobt',
              'AdCardMainHeadacmh',
              'TitlepageBookTitletit',
              'HalftitleBookTitlehtit'"/>
  </xsl:variable>

  <!-- Paragraph styles which should get aggregated in other
       blockquotes.  NOTE that we do not distinguish between letters
       and lyrics; one conceives that a single quote might consist of
       both. -->
  <xsl:variable name="quotation-paras" as="xs:string*">
    <xsl:sequence
      select="'Extractext',
              'ExtractSourceexts',
              'Extract-Newspapernews',
              'Extract-Diaryextd',
              'Extract-Transcripttrans',
              'Extract-NoIndentext1',
              'Extract-BulletListextbl',
              'Extract-NumListextnl',
              'ExtractHeadexth',
              'Extract-VerseorPoetryextv',
              'Extract-Noteextn',
              'Extract-NoteHeadextnh',
              'Extract-Headlineexthl',
              'Extract-Emailextem',
              'Extract-EmailHeadingemh',
              'Extract-Websiteextws',
              'Extract-SongLyricextsl',
              'Extract-BusinessCardextbc',
              'Extract-Telegramtel',
              'Extract-Inscriptionins',
              'Extract-ScheduleofEventssch',
              'LetterExtHeadnotehn',
              'LetterExtClosinglcl',
              'LetterExtGeneralextl',
              'LetterExtSalutationlsa',
              'LetterExtSignaturelsig',
              'LetterExtDatelineldl',
              'LetterExtAddressladd',
              'LetterExtBodyTextNo-Indentltx1',
              'LetterExtBodyTextltx',
              'LetterExtPostscriptlps',
              'BOBAdQuoteHeadbobqh',
              'BOBAdQuotebobq',
              'BOBAdQuoteNo-Indentbobq1',
              'BOBAdQuoteSourcebobqs'"/>
  </xsl:variable>

  <!-- Default rule removes all extraneous data, including
       content. -->
  <xsl:template match="@*|node()">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

  <!-- Creates the root HTML structure. -->
  <xsl:template match="/">
    <html>
      <head>
        <!-- Put the title in place as a courtesy... -->
        <title>
          <xsl:apply-templates
            select="//w:p[w:pPr/w:pStyle/
                          @w:val='TitlepageBookTitletit'][1]"
            mode="head-title"/>
        </title>
      </head>
      <body data-type="book">
        <!-- Figure out our top-level divisions by Word style. -->
        <!-- Sections will always be separated by a PageBreak paragraph in Word -->
        <xsl:for-each-group select="//w:body//w:p"
          group-starting-with="w:p[w:pPr/w:pStyle/@w:val =
                                   $top-level-breaks
                                   and
                                   not(preceding::w:p[1]
                                       [w:pPr/w:pStyle/
                                        @w:val =
                                        $top-level-breaks])
                                   and
                                   not(preceding::w:p[1]
                                       [w:pPr/w:pStyle/
                                        @w:val =
                                        $spacing-paras] and
                                        preceding::w:p[2]
                                       [w:pPr/w:pStyle/
                                        @w:val =
                                        $top-level-breaks])]">
          <xsl:variable name="word-style" as="xs:string"
            select="./w:pPr/w:pStyle/@w:val"/>
          <!-- Figure out the correct data-type value for each section
               type. -->
          <xsl:variable name="html-data-type" as="xs:string">
            <xsl:choose>
              <xsl:when test="$word-style = 'AdCardMainHeadacmh'">
                <xsl:value-of select="'preface'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'BMHeadbmh' or
                              $word-style = 'BMHeadNonprintingbmhnp' or
                              $word-style = 'BMHeadALTabmh' or
                              $word-style = 'AboutAuthorTextHeadatah' or
                              $word-style = 'BOBAdTitlebobt'">
                <xsl:value-of select="'appendix'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'PartNumberpn' or
                              $word-style = 'PartTitlept'">
                <xsl:value-of select="'part'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'ChapTitlect' or
                              $word-style = 'ChapTitleALTact' or
                              $word-style = 'ChapTitleNonprintingctnp'">
                <xsl:value-of select="'chapter'"/>
              </xsl:when>
              <xsl:when
                test="$word-style = 'CopyrightTextsinglespacecrtx' or
                      $word-style = 'CopyrightTextdoublespacecrtxd'">
                <xsl:value-of select="'copyright-page'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'Dedicationded'">
                <xsl:value-of select="'dedication'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'FMHeadfmh' or
                              $word-style = 'FMHeadNonprintingfmhnp' or
                              $word-style = 'FMHeadALTafmh'">
                <xsl:value-of select="'preface'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'HalftitleBookTitlehtit'">
                <xsl:value-of select="'halftitlepage'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'TitlepageBookTitletit'">
                <xsl:value-of select="'titlepage'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'preface'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <!-- Some sections need a class as well. -->
          <xsl:variable name="html-class-type" as="xs:string">
            <xsl:choose>
              <xsl:when test="$word-style = 'AdCardMainHeadacmh'">
                <xsl:value-of select="'adcard'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="''"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:if
            test="$word-style = $top-level-body-breaks and
                  not(preceding::w:p
                      [w:pPr/w:pStyle/@w:val =
                       $top-level-body-breaks])">
            <nav data-type="toc">
              <h1 class="toc-title">Table of Contents</h1>
              <ol class="toc">
                <xsl:apply-templates select="//w:body//w:p"
                  mode="toc"/>
              </ol>
            </nav>
          </xsl:if>
          <section data-type="{$html-data-type}" class="{$html-class-type}" id="{generate-id()}">
            <xsl:apply-templates select="current-group()"/>
          </section>
        </xsl:for-each-group>
        <section data-type="footnotes">
          <h1 class="BMHeadbmh">Footnotes</h1>
          <xsl:apply-templates select=".//w:footnote"/>
        </section>
        <section data-type="appendix" class="endnotes">
          <h1 class="BMHeadbmh">Endnotes</h1>
          <xsl:apply-templates select=".//w:endnote"/>
        </section>
      </body>
    </html>
  </xsl:template>

  <!-- Handle style property names when present. -->
  <xsl:template match="@w:val">
    <xsl:attribute name="class">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <!-- Handle id property names when present. -->
  <xsl:template match="@w:id">
    <xsl:attribute name="id">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <!-- Drop some print-formatting paragraphs from conversion. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $omit-paras]"/>

  <!-- Some headings become h1 elements. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $top-level-heads]">
    <h1>
      <xsl:if
      test="preceding::w:p
            [w:pPr/w:pStyle/@w:val = 'ChapNumbercn']
            and ./w:pPr/w:pStyle/@w:val = 'ChapTitlect'
            or ./w:pPr/w:pStyle/@w:val = 'ChapTitleALTact'">
      <xsl:attribute name="data-autolabel">
        <xsl:value-of select="'yes'"/>
      </xsl:attribute>
      <xsl:attribute name="data-labeltext">
        <xsl:value-of select="preceding::w:p[1]/w:r/w:t"/>
      </xsl:attribute>
    </xsl:if>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <xsl:apply-templates select=".//w:r"/>
    </h1>
  </xsl:template>

  <!-- Group epigraph components into a single container. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $epigraph-paras] | w:p[w:pPr/w:pStyle/@w:val = $versatile-block-paras]">
    <xsl:variable name="firstnotversatileortarget" select="preceding-sibling::w:p[w:pPr/w:pStyle[not(@w:val = $epigraph-paras or @w:val = $versatile-block-paras)]][1]" />
    <xsl:variable name="firsttargetincurrentblock" select="$firstnotversatileortarget/following-sibling::w:p[w:pPr/w:pStyle[@w:val = $epigraph-paras]][1]" />
    <xsl:variable name="firstnot_any_target" select="preceding-sibling::w:p[w:pPr/w:pStyle[not(@w:val = $epigraph-paras or @w:val = $versatile-block-paras or @w:val = $poetry-paras or @w:val = $box-paras or @w:val = $sidebar-paras or @w:val = $quotation-paras)]][1]" />
    <xsl:variable name="solo_orleadingversatile" select="$firstnot_any_target/following-sibling::w:p[1][w:pPr/w:pStyle[@w:val = $versatile-block-paras]]" />
    <xsl:choose>
      <xsl:when test="$firsttargetincurrentblock is .">
        <!-- for Debug purpose while testing"
         <xsl:message>
            <xsl:value-of select="$firstnotversatileortarget"/>
            <xsl:value-of select="$firsttargetincurrentblock/preceding-sibling::w:p[1]"/>
        </xsl:message> -->
        <blockquote data-type="epigraph">
          <xsl:apply-templates select="." mode="epigraph"/>
        </blockquote>
      </xsl:when>
      <xsl:when test="$solo_orleadingversatile is .">
        <p>
          <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
          <xsl:apply-templates select=".//w:r"/>
        </p>
      </xsl:when>
    </xsl:choose>
  </xsl:template>



  <!-- Group poetry components into a single container. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $poetry-paras] | w:p[w:pPr/w:pStyle/@w:val = $versatile-block-paras]">
    <xsl:variable name="firstnotversatileortarget" select="preceding-sibling::w:p[w:pPr/w:pStyle[not(@w:val = $poetry-paras or @w:val = $versatile-block-paras)]][1]" />
    <xsl:variable name="firsttargetincurrentblock" select="$firstnotversatileortarget/following-sibling::w:p[w:pPr/w:pStyle[@w:val = $poetry-paras]][1]" />
    <xsl:variable name="firstnot_any_target" select="preceding-sibling::w:p[w:pPr/w:pStyle[not(@w:val = $epigraph-paras or @w:val = $versatile-block-paras or @w:val = $poetry-paras or @w:val = $box-paras or @w:val = $sidebar-paras or @w:val = $quotation-paras)]][1]" />
    <xsl:variable name="solo_orleadingversatile" select="$firstnot_any_target/following-sibling::w:p[1][w:pPr/w:pStyle[@w:val = $versatile-block-paras]]" />
    <xsl:choose>
      <xsl:when test="$firsttargetincurrentblock is .">
        <pre class="poetry">
          <xsl:apply-templates select="." mode="poetry"/>
        </pre>
      </xsl:when>
      <xsl:when test="$solo_orleadingversatile is .">
        <p>
          <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
          <xsl:apply-templates select=".//w:r"/>
        </p>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Group box components into a single container. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $box-paras] | w:p[w:pPr/w:pStyle/@w:val = $versatile-block-paras]">
    <xsl:variable name="firstnotversatileortarget" select="preceding-sibling::w:p[w:pPr/w:pStyle[not(@w:val = $box-paras or @w:val = $versatile-block-paras)]][1]" />
    <xsl:variable name="firsttargetincurrentblock" select="$firstnotversatileortarget/following-sibling::w:p[w:pPr/w:pStyle[@w:val = $box-paras]][1]" />
    <xsl:variable name="firstnot_any_target" select="preceding-sibling::w:p[w:pPr/w:pStyle[not(@w:val = $epigraph-paras or @w:val = $versatile-block-paras or @w:val = $poetry-paras or @w:val = $box-paras or @w:val = $sidebar-paras or @w:val = $quotation-paras)]][1]" />
    <xsl:variable name="solo_orleadingversatile" select="$firstnot_any_target/following-sibling::w:p[1][w:pPr/w:pStyle[@w:val = $versatile-block-paras]]" />
    <xsl:choose>
      <xsl:when test="$firsttargetincurrentblock is .">
        <aside data-type="sidebar" class="box">
          <xsl:apply-templates select="." mode="box"/>
        </aside>
      </xsl:when>
      <xsl:when test="$solo_orleadingversatile is .">
        <p>
          <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
          <xsl:apply-templates select=".//w:r"/>
        </p>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Group sidebar components into a single container. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $sidebar-paras] | w:p[w:pPr/w:pStyle/@w:val = $versatile-block-paras]">
    <xsl:variable name="firstnotversatileortarget" select="preceding-sibling::w:p[w:pPr/w:pStyle[not(@w:val = $sidebar-paras or @w:val = $versatile-block-paras)]][1]" />
    <xsl:variable name="firsttargetincurrentblock" select="$firstnotversatileortarget/following-sibling::w:p[w:pPr/w:pStyle[@w:val = $sidebar-paras]][1]" />
    <xsl:variable name="firstnot_any_target" select="preceding-sibling::w:p[w:pPr/w:pStyle[not(@w:val = $epigraph-paras or @w:val = $versatile-block-paras or @w:val = $poetry-paras or @w:val = $box-paras or @w:val = $sidebar-paras or @w:val = $quotation-paras)]][1]" />
    <xsl:variable name="solo_orleadingversatile" select="$firstnot_any_target/following-sibling::w:p[1][w:pPr/w:pStyle[@w:val = $versatile-block-paras]]" />
    <xsl:choose>
      <xsl:when test="$firsttargetincurrentblock is .">
        <aside data-type="sidebar">
          <xsl:apply-templates select="." mode="sidebar"/>
        </aside>
      </xsl:when>
      <xsl:when test="$solo_orleadingversatile is .">
        <p>
          <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
          <xsl:apply-templates select=".//w:r"/>
        </p>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Handle figure placeholders, and possibly associated
       captions. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $fig-paras]">
    <xsl:variable name="caption" as="element()?">
      <xsl:choose>
        <xsl:when
          test="following::w:p[1]
                [w:pPr/w:pStyle/@w:val = $fig-cap-paras]">
          <xsl:sequence
            select="following::w:p[1]
                    [w:pPr/w:pStyle/@w:val = $fig-cap-paras]"/>
        </xsl:when>
        <xsl:when
          test="preceding::w:p[1]
                [w:pPr/w:pStyle/@w:val = $fig-cap-paras]">
          <xsl:sequence
            select="preceding::w:p[1]
                    [w:pPr/w:pStyle/@w:val = $fig-cap-paras]"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="illosource" as="element()?">
      <xsl:choose>
        <xsl:when
          test="following::w:p[1]
                [w:pPr/w:pStyle/@w:val = $fig-cap-paras] and following::w:p[2]
                [w:pPr/w:pStyle/@w:val = $fig-source-paras]">
          <xsl:sequence
            select="following::w:p[2]
                    [w:pPr/w:pStyle/@w:val = $fig-source-paras]"/>
        </xsl:when>
        <xsl:when
          test="following::w:p[1]
                [w:pPr/w:pStyle/@w:val = $fig-source-paras]">
          <xsl:sequence
            select="following::w:p[1]
                    [w:pPr/w:pStyle/@w:val = $fig-source-paras]"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <figure id="{generate-id()}">
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <img src="images/{normalize-space(.)}">
        <xsl:attribute name="alt">
          <xsl:choose>
            <xsl:when test="$caption">
              <xsl:apply-templates select="$caption"
                mode="fig-alt-text"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </img>
      <xsl:apply-templates select="$caption" mode="fig-caption"/>
      <xsl:apply-templates select="$illosource" mode="fig-source"/>
    </figure>
  </xsl:template>

  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $fig-cap-paras]"/>

  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $fig-source-paras]"/>

  <!-- Group list items into list containers.
       If this goes more than two levels deep, we should generalize
       using functions and/or named templates. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $list-num-paras]">
    <xsl:if
      test="preceding::w:p[not(w:pPr/w:pStyle/@w:val =
                               $list-sub-paras)][1]
            [not(w:pPr/w:pStyle/@w:val =
                 current()/w:pPr/w:pStyle/@w:val)]">
      <ol>
        <xsl:apply-templates select="." mode="list"/>
      </ol>
    </xsl:if>
  </xsl:template>

  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $list-unnum-paras]">
    <xsl:if
      test="preceding::w:p[not(w:pPr/w:pStyle/@w:val =
                               $list-sub-paras)][1]
            [not(w:pPr/w:pStyle/@w:val =
                 current()/w:pPr/w:pStyle/@w:val)]">
      <ul>
        <xsl:apply-templates select="." mode="list"/>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $list-sub-num-paras]">
    <xsl:if
      test="preceding::w:p[1]
            [not(w:pPr/w:pStyle/@w:val =
                 current()/w:pPr/w:pStyle/@w:val)]">
      <ol>
        <xsl:apply-templates select="." mode="sub-list"/>
      </ol>
    </xsl:if>
  </xsl:template>

  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $list-sub-unnum-paras]">
    <xsl:if
      test="preceding::w:p[1]
            [not(w:pPr/w:pStyle/@w:val =
                 current()/w:pPr/w:pStyle/@w:val)]">
      <ul>
        <xsl:apply-templates select="." mode="sub-list"/>
      </ul>
    </xsl:if>
  </xsl:template>

  <!-- Group quotation components into a single container. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $quotation-paras] | w:p[w:pPr/w:pStyle/@w:val = $versatile-block-paras]">
    <xsl:variable name="firstnotversatileortarget" select="preceding-sibling::w:p[w:pPr/w:pStyle[not(@w:val = $quotation-paras or @w:val = $versatile-block-paras)]][1]" />
    <xsl:variable name="firsttargetincurrentblock" select="$firstnotversatileortarget/following-sibling::w:p[w:pPr/w:pStyle[@w:val = $quotation-paras]][1]" />
    <xsl:variable name="firstnot_any_target" select="preceding-sibling::w:p[w:pPr/w:pStyle[not(@w:val = $epigraph-paras or @w:val = $versatile-block-paras or @w:val = $poetry-paras or @w:val = $box-paras or @w:val = $sidebar-paras or @w:val = $quotation-paras)]][1]" />
    <xsl:variable name="solo_orleadingversatile" select="$firstnot_any_target/following-sibling::w:p[1][w:pPr/w:pStyle[@w:val = $versatile-block-paras]]" />
    <xsl:variable name="second_leadingversatile" select="$solo_orleadingversatile/following-sibling::w:p[1][w:pPr/w:pStyle[@w:val = $versatile-block-paras]]" />
    <xsl:variable name="third_leadingversatile" select="$second_leadingversatile/following-sibling::w:p[1][w:pPr/w:pStyle[@w:val = $versatile-block-paras]]" />
    <xsl:variable name="fourth_leadingversatile" select="$third_leadingversatile/following-sibling::w:p[1][w:pPr/w:pStyle[@w:val = $versatile-block-paras]]" />
    <xsl:variable name="fifth_leadingversatile" select="$fourth_leadingversatile/following-sibling::w:p[1][w:pPr/w:pStyle[@w:val = $versatile-block-paras]]" />
    <xsl:choose>
      <xsl:when test="$firsttargetincurrentblock is .">
        <blockquote>
          <xsl:apply-templates select="." mode="quotation"/>
        </blockquote>
      </xsl:when>
      <xsl:when test="$solo_orleadingversatile is .
        or $second_leadingversatile is .
        or $third_leadingversatile is .
        or $fourth_leadingversatile is .
        or $fifth_leadingversatile is .">
        <p>
          <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
          <xsl:apply-templates select=".//w:r"/>
        </p>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Preserve footnote text as paras to be moved via ruby -->
  <xsl:template match=".//w:footnote">
    <div>
      <xsl:attribute name="class">
        <xsl:value-of select="'footnotetext'"/>
      </xsl:attribute>
      <xsl:apply-templates select="@w:id"/>
      <xsl:apply-templates select="w:p"/>
    </div>
  </xsl:template>

  <!-- Preserve endnote text -->
  <xsl:template match=".//w:endnote">
    <div>
      <xsl:attribute name="class">
        <xsl:value-of select="'endnotetext'"/>
      </xsl:attribute>
      <xsl:apply-templates select="@w:id"/>
      <xsl:apply-templates select="w:p"/>
    </div>
  </xsl:template>

  <!-- All other paragraphs become p elements. -->
  <xsl:template match="w:p">
    <p>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <xsl:apply-templates select=".//w:r"/>
    </p>
  </xsl:template>

  <!-- Styled inline text needs a span element with an appropriate
       class -->
  <xsl:template match="w:r[w:rPr/w:rStyle/@w:val]">
    <span>
      <xsl:apply-templates select="w:rPr/w:rStyle/@w:val"/>
      <xsl:apply-templates select="w:t | w:br | w:sym | w:footnoteReference | w:endnoteReference"/>
      <!--<xsl:apply-templates select="w:br"/>
      <xsl:apply-templates select="w:footnoteReference"/>
      <xsl:apply-templates select="w:endnoteReference"/>-->
    </span>
  </xsl:template>

  <xsl:template match="w:r">
    <xsl:apply-templates select="w:t | w:br | w:sym"/>
    <!--<xsl:apply-templates select="w:br"/>-->
  </xsl:template>

  <!-- Footnote references -->
  <xsl:template match="w:footnoteReference">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="'FootnoteReference'"/>
      </xsl:attribute>
      <xsl:apply-templates select="@w:id"/>
    </span>
  </xsl:template>

  <!-- Endnote references -->
  <xsl:template match="w:endnoteReference">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="'EndnoteReference'"/>
      </xsl:attribute>
      <xsl:apply-templates select="@w:id"/>
    </span>
  </xsl:template>

  <!-- As we drop content by default, explicitly handle text-bearing
       elements. -->
  <xsl:template match="w:t">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- preserving soft breaks -->
  <xsl:template match="w:br">
    <br/>
  </xsl:template>

  <!-- preserving soft breaks -->
  <xsl:template match="w:sym">
    <xsl:choose>
      <xsl:when test="current()/@w:char = 'F0D3'">
        <xsl:value-of select="'©'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@w:char"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Processing paragraphs in box mode.  Check each following
       sibling for inclusion. -->
  <xsl:template match="w:p" mode="box">
    <p>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <xsl:apply-templates select="w:r"/>
    </p>
    <xsl:apply-templates
      select="following::w:p[1]
              [(w:pPr/w:pStyle/@w:val = $box-paras) or (w:pPr/w:pStyle/@w:val = $versatile-block-paras)]"
      mode="box"/>
  </xsl:template>

  <!-- Processing paragraphs in sidebar mode.  Check each following
       sibling for inclusion. -->
  <xsl:template match="w:p" mode="sidebar">
    <p>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <xsl:apply-templates select="w:r"/>
    </p>
    <xsl:apply-templates
      select="following::w:p[1]
              [(w:pPr/w:pStyle/@w:val = $sidebar-paras) or (w:pPr/w:pStyle/@w:val = $versatile-block-paras)]"
      mode="sidebar"/>
  </xsl:template>

  <!-- Processing paragraphs in epigraph mode.  Check each following
       sibling for inclusion. -->
  <xsl:template match="w:p" mode="epigraph">
    <p>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <xsl:apply-templates select="w:r"/>
    </p>
    <xsl:apply-templates
      select="following::w:p[1]
              [(w:pPr/w:pStyle/@w:val = $epigraph-paras) or (w:pPr/w:pStyle/@w:val = $versatile-block-paras)]"
      mode="epigraph"/>
  </xsl:template>

  <!-- Processing paragraphs in poetry mode.  Check each following
       sibling for inclusion. -->
  <xsl:template match="w:p" mode="poetry">
    <p>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <xsl:apply-templates select="w:r"/>
    </p>
    <xsl:apply-templates
      select="following::w:p[1]
              [(w:pPr/w:pStyle/@w:val = $poetry-paras) or (w:pPr/w:pStyle/@w:val = $versatile-block-paras)]"
      mode="poetry"/>
  </xsl:template>

  <xsl:template match="w:p" mode="fig-alt-text">
    <xsl:apply-templates select="w:r//w:t"/>
  </xsl:template>

  <xsl:template match="w:p" mode="fig-caption">
    <figcaption>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <xsl:apply-templates select="w:r"/>
    </figcaption>
  </xsl:template>

  <xsl:template match="w:p" mode="fig-source">
    <p>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <a class="fig-link">
        <xsl:apply-templates select="w:r"/>
      </a>
    </p>
  </xsl:template>

  <!-- Processing the book title in the head/title output.  Should
       result in text-only output. -->
  <xsl:template match="w:p" mode="head-title">
    <xsl:apply-templates mode="head-title"/>
  </xsl:template>

  <!-- Processing paragraphs in list-item mode.  Check each following
       sibling for inclusion. -->
  <xsl:template match="w:p" mode="list">
    <li>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <p>
        <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
        <xsl:apply-templates select="w:r"/>
      </p>
      <!-- Process sub-list paragraphs in default mode. -->
      <xsl:apply-templates
        select="following::w:p[1]
                [w:pPr/w:pStyle/@w:val = $list-sub-paras]"/>
    </li>
    <xsl:apply-templates
      select="following::w:p[not(w:pPr/w:pStyle/@w:val =
                                 $list-sub-paras)][1]
              [w:pPr/w:pStyle/@w:val =
               current()/w:pPr/w:pStyle/@w:val]"
      mode="list"/>
  </xsl:template>

  <xsl:template match="w:p" mode="sub-list">
    <li>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <p>
        <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
        <xsl:apply-templates select="w:r"/>
      </p>
    </li>
    <xsl:apply-templates
      select="following::w:p[1]
              [w:pPr/w:pStyle/@w:val =
               current()/w:pPr/w:pStyle/@w:val]"
      mode="list"/>
  </xsl:template>

  <!-- Processing paragraphs in quotation mode.  Check each following
       sibling for inclusion. -->
  <xsl:template match="w:p" mode="quotation">
    <p>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <xsl:apply-templates select="w:r"/>
    </p>
    <xsl:apply-templates
      select="following::w:p[1]
              [(w:pPr/w:pStyle/@w:val = $quotation-paras) or (w:pPr/w:pStyle/@w:val = $versatile-block-paras)]"
      mode="quotation"/>
  </xsl:template>

  <!-- Table of contents mode.  Headers make list items; everything
       else is ignored.  No nesting for now, but we will need to
       handle that (logic should be similar to body list nesting). -->
  <xsl:template match="w:p" mode="toc"/>

  <!-- Currently, this is easy as every breaking paragraph is also its
       own head... if that changes, finding the head from the break
       could get a little tricky, or if chapters have both numbers and
       titles. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle/@w:val = $top-level-body-breaks]"
    mode="toc">
    <li>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <a href="#{generate-id()}" class="toc-link">
        <xsl:apply-templates select="w:r"/>
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
