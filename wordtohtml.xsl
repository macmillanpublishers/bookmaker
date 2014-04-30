<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
 xmlns="http://www.w3.org/TR/REC-html40">

 <!-- v0.1: basic support just for paragraphs; to do: add support for char styles and other block elements -->

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

<!-- converts main text tag to p and adds appropriate classes -->

    <xsl:template match="w:t">
      <p>
        <xsl:attribute name="class">
          <xsl:value-of select="preceding::w:pStyle[1]/@w:val"/>
        </xsl:attribute>
        <xsl:apply-templates select="@*|node()" />
        <xsl:value-of select="text()"/>
      </p>
    </xsl:template>

</xsl:stylesheet>