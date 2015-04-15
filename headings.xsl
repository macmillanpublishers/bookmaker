<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="h">

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
                <xsl:value-of select="'Section'"/>
              </xsl:otherwise>
            </xsl:choose>
    </xsl:variable>
	<xsl:if test="*[1][self::h:p]">
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