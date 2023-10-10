<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:meta="http://panax.io/metadata"
xmlns:widget="http://panax.io/widget"
xmlns:picture="http://panax.io/widget/picture"
xmlns:state="http://panax.io/state"
xmlns:source="http://panax.io/xover/binding/source"
xmlns:js="http://panax.io/languages/javascript"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
exclude-result-prefixes="#default xo session sitemap widget state source js meta xsi"
>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>

	<xsl:attribute-set name="picture:attributes">
	</xsl:attribute-set>

	<xsl:template mode="picture:preceding-siblings" match="@*"></xsl:template>
	<xsl:template mode="picture:following-siblings" match="@*"></xsl:template>
		
	<xsl:template mode="picture:widget" match="@*">
		<xsl:param name="data_field" select="current()"/>
		<xsl:param name="field" select="."/>
		<xsl:param name="type"/>
		<xsl:variable name="id" select="ancestor-or-self::*[@xo:id][1]/@xo:id"/>
		<xsl:variable name="style">
			<xsl:if test="../@xsi:type='mock'">visibility:hidden</xsl:if>
		</xsl:variable>
		<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.0/font/bootstrap-icons.css"/>
		<img src="{.}" style="max-height:100px"/>
	</xsl:template>

</xsl:stylesheet>
