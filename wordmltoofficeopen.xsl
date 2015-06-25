<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:word="http://schemas.microsoft.com/office/word/2003/wordml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="word">

  <!-- A trivial stylesheet by Christopher R. Maden, crism consulting,
       crism@maden.org
       Converts pre-standardization WordML to post-standardization
       OfficeOpen XML. -->

  <!-- Copy all elements and other nodes to output unchanged. -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Except that attributes and elements in the WordML namespace
       need to become OfficeOpen attributes and elements instead. -->
  <xsl:template match="@word:*">
    <xsl:attribute name="w:{local-name(.)}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="word:*">
    <xsl:element name="w:{local-name(.)}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
