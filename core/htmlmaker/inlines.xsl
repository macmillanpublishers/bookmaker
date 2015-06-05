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

<xsl:template match="h:span[@class='spanboldfacecharactersbf']">
	<strong>
		<xsl:attribute name="class">
      		<xsl:value-of select="@class"/>
    	</xsl:attribute>
		<xsl:apply-templates select="@*|node()" />
	</strong>
</xsl:template>

<xsl:template match="h:span[@class='spanitaliccharactersital']">
	<em>
		<xsl:attribute name="class">
      		<xsl:value-of select="@class"/>
    	</xsl:attribute>
		<xsl:apply-templates select="@*|node()" />
	</em>
</xsl:template>

<xsl:template match="h:span[@class='spanbolditalbem']">
	<strong>
		<em>
			<xsl:attribute name="class">
      			<xsl:value-of select="@class"/>
    		</xsl:attribute>
			<xsl:apply-templates select="@*|node()" />
		</em>
	</strong>
</xsl:template>

<xsl:template match="h:span[@class='spansmcapitalscital']">
	<em>
		<span>
			<xsl:attribute name="class">
      			<xsl:value-of select="@class"/>
    		</xsl:attribute>
			<xsl:apply-templates select="@*|node()" />
		</span>
	</em>
</xsl:template>

<xsl:template match="h:span[@class='spansmcapboldscbold']">
	<strong>
		<span>
			<xsl:attribute name="class">
      			<xsl:value-of select="@class"/>
    		</xsl:attribute>
			<xsl:apply-templates select="@*|node()" />
		</span>
	</strong>
</xsl:template>

<xsl:template match="h:span[@class='spansuperscriptcharacterssup']">
	<sup>
		<xsl:attribute name="class">
      		<xsl:value-of select="@class"/>
    	</xsl:attribute>
		<xsl:apply-templates select="@*|node()" />
	</sup>
</xsl:template>

<xsl:template match="h:span[@class='spansubscriptcharacterssub']">
	<sub>
		<xsl:attribute name="class">
      		<xsl:value-of select="@class"/>
    	</xsl:attribute>
		<xsl:apply-templates select="@*|node()" />
	</sub>
</xsl:template>

</xsl:stylesheet> 