<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:px="http://panax.io/entity"
xmlns:appendTo-data="http://panax.io/listener"
xmlns:data="http://panax.io/source"
xmlns:meta="http://panax.io/metadata"
xmlns:site="http://panax.io/site"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:widget="http://panax.io/widget"
exclude-result-prefixes="#default xsl px xsi xo data site widget"
>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>
	<xsl:param name="site:seed">''</xsl:param>
	<xsl:param name="appendTo-data:rows"/>

	<xsl:template match="/">
		<span><xsl:apply-templates mode="widget" select="*/@xo:id"/></span>
	</xsl:template>

	<xsl:template mode="widget" match="@*"></xsl:template>
</xsl:stylesheet>
