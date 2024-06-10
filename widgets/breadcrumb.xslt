<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:widget="http://panax.io/widget"
xmlns:breadcrumb="http://panax.io/widget/breadcrumb"
xmlns:data="http://panax.io/source"
xmlns:state="http://panax.io/state"
xmlns:text="http://panax.io/state/text"
xmlns:js="http://panax.io/languages/javascript"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>

	<xsl:key name="active" match="xo:f[not(@state:active-item)]/Folder" use="@xo:id"/>
	<xsl:key name="active" match="xo:f" use="@state:active-item"/>

	<xsl:template match="@*" mode="breadcrumb:widget">
		<xsl:param name="items" select="nodes-expected"/>
		<xsl:variable name="active" select="$items[last()]"/>
		<xsl:variable name="current" select="current()"/>
		<nav aria-label="breadcrumb">
			<ol class="breadcrumb">
				<xsl:for-each select="$items[count(.|$active)!=1]">
					<xsl:variable name="xo:id" select="ancestor-or-self::*[1]/@xo:id"/>
					<li class="breadcrumb-item" xo-scope="inherit" xo-slot="state:active-item" onclick="scope.set('{$xo:id}')">
						<a href="#" xo-scope="{$xo:id}" xo-slot="{name()}">
							<xsl:apply-templates mode="breadcrumb:item-attributes" select="."/>
							<xsl:apply-templates mode="breadcrumb:item-content" select="."/>
						</a>
					</li>
				</xsl:for-each>
				<xsl:for-each select="$active">
					<li class="breadcrumb-item active" aria-current="page">
						<xsl:apply-templates mode="breadcrumb:item-attributes" select="."/>
						<xsl:apply-templates mode="breadcrumb:item-content" select="."/>
					</li>
				</xsl:for-each>
			</ol>
		</nav>
	</xsl:template>

	<xsl:template match="Folder/@Name[.='']" mode="breadcrumb:item-content">
		<xsl:apply-templates select="../../@Name"/>
	</xsl:template>

	<xsl:template match="@*" mode="breadcrumb:item-attributes">
	</xsl:template>
</xsl:stylesheet>
