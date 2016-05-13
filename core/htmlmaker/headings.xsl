<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="h xs">

<xsl:output method="xml"
            encoding="UTF-8"/>
<xsl:preserve-space elements="*"/>

<xsl:template match="/ | @* | node()">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()" />
  </xsl:copy>
</xsl:template>

<xsl:template match="h:section">
	<xsl:copy>
	<xsl:apply-templates select="@*"/>
	<xsl:variable name="section-type" as="xs:string">
            <xsl:choose>
              <xsl:when test="h:p[@class='CopyrightTextsinglespacecrtx'] or
              				  h:p[@class='CopyrightTextdoublespacecrtxd']">
                <xsl:value-of select="'Copyright Page'"/>
              </xsl:when>
              <xsl:when test="h:p[@class='Dedicationded']">
                <xsl:value-of select="'Dedication'"/>
              </xsl:when>
              <xsl:when test="h:p[@class='AdCardMainHeadacmh'] or
              				  h:p[@class='AdCardSubheadacsh'] or 
              				  h:p[@class='AdCardListofTitlesacl']">
                <xsl:value-of select="'Ad Card'"/>
              </xsl:when>
              <xsl:when test="h:p[@class='AboutAuthorTextNo-Indentatatx1'] or
                        h:p[@class='AboutAuthorTextHeadatah'] or 
                        h:p[@class='AboutAuthorTextatatx']">
                <xsl:value-of select="'About the Author'"/>
              </xsl:when>
              <xsl:when test="h:p[@class='FrontSalesTitlefst'] or
              				  h:p[@class='FrontSalesSubtitlefsst'] or 
              				  h:p[@class='FrontSalesQuoteHeadfsqh'] or 
              				  h:p[@class='FrontSalesTextfstx'] or 
              				  h:p[@class='FrontSalesTextNoIndentfstx1'] or 
              				  h:p[@class='FrontSalesQuotefsq'] or 
              				  h:p[@class='FrontSalesQuoteNoIndentfsq1']">
                <xsl:value-of select="'Praise'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'Frontmatter'"/>
              </xsl:otherwise>
            </xsl:choose>
    </xsl:variable>
    <xsl:if test="h:p[@class='AboutAuthorTextNo-Indentatatx1'] or
                  h:p[@class='AboutAuthorTextHeadatah'] or 
                  h:p[@class='AboutAuthorTextatatx'] or 
                  h:h1/text()='About the Author'">
            <xsl:attribute name="class">
              <xsl:value-of select="'abouttheauthor'"/>
            </xsl:attribute>
    </xsl:if>
    <xsl:if test="h:h1[@class='BOBAdTitlebobt'] or
                  h:p[@class='BOBAdTextbobtx']">
            <xsl:attribute name="class">
              <xsl:value-of select="'bobad'"/>
            </xsl:attribute>
    </xsl:if>
    <xsl:if test="h:p[@class='FrontSalesTitlefst'] or
                  h:p[@class='FrontSalesSubtitlefsst'] or 
                  h:p[@class='FrontSalesQuoteHeadfsqh'] or 
                  h:p[@class='FrontSalesTextfstx'] or 
                  h:p[@class='FrontSalesTextNoIndentfstx1'] or 
                  h:p[@class='FrontSalesQuotefsq'] or 
                  h:p[@class='FrontSalesQuoteNoIndentfsq1']">
            <xsl:attribute name="class">
              <xsl:value-of select="'frontsales'"/>
            </xsl:attribute>
    </xsl:if>
	<xsl:if test="*[1][self::h:p] or *[1][self::h:figure]">
      	<h1>
      	  <xsl:attribute name="class">
            <xsl:value-of select="'Nonprinting'"/>
          </xsl:attribute>
          <xsl:value-of select="$section-type"/>
      	</h1>
    </xsl:if>
    <xsl:apply-templates select="node()" />
</xsl:copy>
</xsl:template>

</xsl:stylesheet> 