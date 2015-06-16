<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:exsl="http://exslt.org/common"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:htmlbook="https://github.com/oreillymedia/HTMLBook"
		xmlns:func="http://exslt.org/functions"
		xmlns="http://www.w3.org/1999/xhtml">

<xsl:output method="xml"
            encoding="UTF-8"/>
<xsl:preserve-space elements="*"/>

<xsl:template match="/ | @* | node()">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()" />
  </xsl:copy>
</xsl:template>

<xsl:template match="h:span[@data-type='footnote']/h:p">
	<span>
		<xsl:attribute name="class">
      		<xsl:value-of select="@class"/>
    	</xsl:attribute>
		<xsl:apply-templates select="@*|node()" />
	</span>
</xsl:template>

<xsl:template match="h:section[@data-type='footnotes']"/>

<xsl:template match="h:p[@id='endnotetext--1']"/>

<xsl:template match="h:p[@id='endnotetext-0']"/>

</xsl:stylesheet> 