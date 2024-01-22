<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
exclude-result-prefixes="#default xsl"
>

	<xsl:key name="item-value" match="@name" use="generate-id(..)"/>
	<!--<xsl:key name="item-value" match="*[not(@name)]/@*[1]" use="generate-id(..)"/>-->

	<xsl:template match="/*">
		<ol>
			<xsl:apply-templates>
				<xsl:sort select="@name"/>
			</xsl:apply-templates>
		</ol>
	</xsl:template>

	<xsl:template match="*">
		<li>
			<xsl:apply-templates select="key('item-value', generate-id())"/>
		</li>
	</xsl:template>
</xsl:stylesheet>
