<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

<xsl:template match="h:section[@data-type='preface'][h:h1[contains(., 'Contents')]]/@class">
    <xsl:attribute name="class">texttoc</xsl:attribute>
</xsl:template>

</xsl:stylesheet> 