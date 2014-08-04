<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="w xs">

  <!-- v0.1: basic support just for headings, paragraphs, and char
       styles as spans -->
  <!-- additions by Christopher R. Maden, crism consulting,
       crism@maden.org
       Switched to XSLT 2.0.
       Made XHTML5 / HTMLBook valid. -->

  <xsl:output indent="no" method="html" omit-xml-declaration="yes"
    version="5"/>

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
        <xsl:for-each-group select="//w:p"
          group-starting-with="w:p[w:pPr/w:pStyle
                                   [@w:val='AdCardMainHeadacmh'
                                    or @w:val='BMHeadbmh'
                                    or @w:val='ChapTitlect'
                                    or @w:val='Dedicationded'
                                    or @w:val='Epigraphnon-verseepi'
                                    or @w:val='FMHeadfmh'
                                    or @w:val='HalftitleBooktitlehtit'
                                    or @w:val='TitlepageBookTitletit'
                                   ] or
                                   (w:pPr/w:pStyle/
                                    @w:val=
                                      'CopyrightTextsinglespacecrtx'
                                    and
                                    not(preceding-sibling::w:p[1]
                                        [w:pPr/w:pStyle/
                                         @w:val=
                                         'CopyrightTextsinglespacecrtx'
                                        ]))]">
          <xsl:variable name="word-style" as="xs:string"
            select="./w:pPr/w:pStyle/@w:val"/>
          <!-- Figure out the correct data-type value for each section
               type.  Not all section types are supported in HTMLBook,
               so we had to make some up, given as “x-foo” here. -->
          <xsl:variable name="html-data-type" as="xs:string">
            <xsl:choose>
              <xsl:when test="$word-style = 'AdCardMainHeadacmh'">
                <xsl:value-of select="'x-adcard'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'BMHeadbmh'">
                <xsl:value-of select="'appendix'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'ChapTitlect'">
                <xsl:value-of select="'chapter'"/>
              </xsl:when>
              <xsl:when
                test="$word-style = 'CopyrightTextsinglespacecrtx'">
                <xsl:value-of select="'copyright-page'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'Dedicationded'">
                <xsl:value-of select="'dedication'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'Epigraphnon-verseepi'">
                <xsl:value-of select="'x-epigraph'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'FMHeadfmh'">
                <xsl:value-of select="'preface'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'HalftitleBooktitlehtit'">
                <xsl:value-of select="'halftitlepage'"/>
              </xsl:when>
              <xsl:when test="$word-style = 'TitlepageBookTitletit'">
                <xsl:value-of select="'titlepage'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="''"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <section data-type="{$html-data-type}">
            <xsl:apply-templates select="current-group()"/>
          </section>
        </xsl:for-each-group>
      </body>
    </html>
  </xsl:template>

  <!-- Handle style property names when present. -->
  <xsl:template match="@w:val">
    <xsl:attribute name="class">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <!-- Drop some print-formatting paragraphs from conversion. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle[@w:val = 'PageBreakpb'
                              or @w:val = 'PartStartpts'
                              or @w:val = 'SectionBreaksbr']]"/>

  <!-- Some headings become h1 elements. -->
  <xsl:template
    match="w:p[w:pPr/w:pStyle[@w:val = 'BMHeadbmh'
                              or @w:val = 'ChapTitlect'
                              or @w:val = 'FMHeadfmh'
                              or @w:val = 'TitlepageBookTitletit']]">
    <h1>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <xsl:apply-templates select="w:r"/>
    </h1>
  </xsl:template>

  <!-- All other paragraphs become p elements. -->
  <xsl:template match="w:p">
    <p>
      <xsl:apply-templates select="w:pPr/w:pStyle/@w:val"/>
      <xsl:apply-templates select="w:r"/>
    </p>
  </xsl:template>

  <!-- Styled inline text needs a span element with an appropriate
       class. -->
  <xsl:template match="w:r[w:rPr/w:rStyle/@w:val]">
    <span>
      <xsl:apply-templates select="w:rPr/w:rStyle/@w:val"/>
      <xsl:apply-templates select="w:t"/>
    </span>
  </xsl:template>

  <!-- Other inline text is just plain text. -->
  <xsl:template match="w:r">
    <xsl:apply-templates select="w:t"/>
  </xsl:template>

  <!-- As we drop content by default, explicitly handle text-bearing
       elements. -->
  <xsl:template match="w:t">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- Processing the book title in the head/title output.  Should
       result in text-only output. -->
  <xsl:template match="w:p" mode="head-title">
    <xsl:apply-templates mode="head-title"/>
  </xsl:template>

</xsl:stylesheet>
