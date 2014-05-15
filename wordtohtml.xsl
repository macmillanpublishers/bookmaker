<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
 xmlns="http://www.w3.org/TR/REC-html40">

 <!-- v0.1: basic support just for headings, paragraphs, and char styles as spans -->

 <xsl:output omit-xml-declaration="yes"/>

 <!--adds the root html structure -->

	<xsl:output method="html"/>

	<xsl:template match="/">
		<html>
		<head>
		<title></title>
		</head>
		<body>
		<xsl:apply-templates/>
		</body>
		</html>
	</xsl:template>

<!-- removes all extraneous tags -->

    <xsl:template match="@*|node()">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>

<!-- converts main text tag to p or h1 and adds appropriate classes -->

<!-- h1 rendering relies on the applicable paragraph styles being listed in the 'when' argument below -->

    <xsl:template match="w:p">
      <xsl:choose>
        <xsl:when test=".//w:pStyle[@w:val='TitlepageBookTitletit']|.//w:pStyle[@w:val='FMHeadfmh']|.//w:pStyle[@w:val='PartTitlept']|.//w:pStyle[@w:val='ChapTitlect']">
          <h1>
            <xsl:attribute name="class">
              <xsl:value-of select=".//w:pStyle/@w:val"/>
            </xsl:attribute>
            <xsl:apply-templates select=".//w:t"/> 
          </h1>
        </xsl:when>
        <xsl:otherwise>
          <p>
            <xsl:attribute name="class">
              <xsl:value-of select=".//w:pStyle/@w:val"/>
            </xsl:attribute>
            <xsl:apply-templates select=".//w:t"/> 
          </p>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

<!-- preserves character styles -->

    <xsl:template match="w:t">
        <xsl:choose>
        <xsl:when test="preceding-sibling::*[1][self::w:rPr]">
          <span>
            <xsl:attribute name="class">
              <xsl:value-of select="preceding::w:rStyle[1]/@w:val"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--WIP - sorting out section milestones-->

    <!--<xsl:key name="text-by-last-milestone" match="* | text()"
      use="generate-id((preceding-sibling::w:pStyle[@w:val='PartStartpts'] | preceding-sibling::w:pStyle[@w:val='PartEndpte'])[last()])" />
    <xsl:template match="/">
      <xsl:for-each select="//w:pStyle[@w:val='PartStartpts'">
        <xsl:copy-of select="key('text-by-last-milestone', generate-id())"/>
      </xsl:for-each>
    </xsl:template>

    <xsl:template match="w:pStyle[@w:val='PartStartpts']">
      <div class="partstart" />
    </xsl:template>

    <xsl:template match="w:pStyle[@w:val='PartEndpte']">
      <div class="partend" />
    </xsl:template>

    <xsl:template match="w:pStyle[@w:val='SectionBreaksbr']">
      <section class="sectionmilestone" />
    </xsl:template>-->

</xsl:stylesheet>