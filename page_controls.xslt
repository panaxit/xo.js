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
exclude-result-prefixes="#default xsl px xsi xo data site"
>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>
	<xsl:param name="site:seed">''</xsl:param>

	<xsl:template match="/">
		<nav id="page_controls" class="nav col-md-8 justify-content-center list-unstyled d-flex p-3" xo-source="active">
			<xsl:apply-templates select="px:Entity/@xo:id"/>
		</nav>
	</xsl:template>

	<xsl:template match="@*" priority="-1"/>

	<xsl:template match="px:Entity/@*">
		<xsl:apply-templates select="../data:rows/@xo:id"/>
	</xsl:template>

	<xsl:template match="px:Entity[@controlType='datagridView']/data:rows/@*">
		<xsl:for-each select="..">
			<xsl:variable name="scope" select="."/>
			<ul class="pagination justify-content-center">
				<xsl:variable name="pageIndex" select="@meta:pageIndex"/>
				<xsl:variable name="pageSize" select="@meta:pageSize"/>
				<xsl:variable name="totalRows" select="*/@meta:totalCount"/>
				<xsl:if test="$totalRows &gt; $pageSize or $pageIndex &gt; 1">
					<li class="page-item" xo-scope="{$scope/@xo:id}" xo-slot="meta:pageIndex">
						<xsl:if test="$pageIndex = 1">
							<xsl:attribute name="class">page-item disabled</xsl:attribute>
						</xsl:if>
						<a class="page-link" href="#" onclick="scope.set({$pageIndex - 1})">
							Anterior
						</a>
					</li>
					<xsl:for-each select="(//*)[position() &lt;= ceiling($totalRows div $pageSize) and position()&lt;10]">
						<li class="page-item" xo-scope="{$scope/@xo:id}" xo-slot="meta:pageIndex">
							<xsl:if test="$pageIndex = position()">
								<xsl:attribute name="class">page-item active</xsl:attribute>
							</xsl:if>
							<a class="page-link" href="#" onclick="scope.set({position()})">
								<xsl:value-of select="position()"/>
							</a>
						</li>
					</xsl:for-each>
					<li class="page-item" xo-scope="{$scope/@xo:id}" xo-slot="meta:pageIndex">
						<xsl:if test="$pageIndex + 1 &gt; ceiling($totalRows div $pageSize)">
							<xsl:attribute name="class">page-item disabled</xsl:attribute>
						</xsl:if>
						<a class="page-link" href="#" onclick="scope.set({$pageIndex + 1})">
							Siguiente
						</a>
					</li>
				</xsl:if>
			</ul>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
