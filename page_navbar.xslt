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

	<xsl:key name="start-node" match="/*" use="'*'"/>

	<xsl:template match="/">
		<nav class="page-menu">
			<style>
				<![CDATA[.page-menu {
			    height: var(--nav-height);
			}
			.page-menu > * {
			    margin-bottom: var(--nav-padding-bottom, .25rem) !important;
				margin-top: var(--nav-padding-top, .25rem) !important;
				margin-right: var(--nav-padding-right, 1rem) !important;
				margin-left: var(--nav-padding-left, 1rem) !important;
			}
			.page-menu {
				padding: .5rem;
			}
			]]>
			</style>
			<xsl:apply-templates mode="widget" select="key('start-node','*')"/>
		</nav>
	</xsl:template>

	<xsl:template mode="widget" match="text()" priority="-1"></xsl:template>

	<xsl:template mode="widget" match="px:Entity">
		<xsl:apply-templates mode="widget" select="data:rows"/>
	</xsl:template>

	<xsl:template mode="widget" match="px:Entity[@xsi:type='datagrid:control']/data:rows">
		<xsl:apply-templates mode="widget" select="../px:Parameters"/>
	</xsl:template>

	<xsl:template mode="widget" match="px:Parameters[px:Parameter]">
		<style>
			:root { --nav-height: 46px; }
		</style>
		<form action="javascript:void(0);">
			<xsl:apply-templates mode="widget" select="px:Parameter"/>
			<button type="submit" class="btn btn-success" onclick="px.applyFilters(scope)" xo-scope="{parent::px:Entity/data:rows/@xo:id}" xo-slot="command">
				<xsl:text>Filtrar</xsl:text>
			</button>
		</form>
	</xsl:template>

	<xsl:template mode="widget" match="px:Parameter">
		<xsl:apply-templates mode="widget" select="@xo:id"/>
	</xsl:template>

	<xsl:template mode="widget" match="px:Parameter/@*">
		<div class="input-group">
			<div class="input-group-prepend">
				<span class="input-group-text" id="basic-addon1">
					<xsl:apply-templates mode="headerText" select="../@parameterName"/>
					<xsl:text>: </xsl:text>
				</span>
			</div>
			<xsl:apply-templates mode="widget" select="../@parameterName"/>
		</div>
	</xsl:template>

	<xsl:key name="parameter" match="px:Parameter/@parameterName" use="."/>

	<xsl:template mode="headerText" match="px:Parameter/@parameterName">
		<xsl:value-of select="substring(.,2)"/>
	</xsl:template>

	<xsl:template mode="widget" match="px:Parameter/@parameterName">
		<input type="text" class="form-control" placeholder="" aria-label="" xo-scope="{../@xo:id}" xo-slot="value" value="{../@value}" list="options_{../@xo:id}"/>
		<xsl:variable name="catalog" select="key('parameter-options',.)"/>
		<datalist id="options_{../@xo:id}">
			<xsl:apply-templates mode="widget:options" select="$catalog"/>
		</datalist>
	</xsl:template>

	<xsl:key name="parameter-options" match="px:Parameter/data:rows/xo:r" use="../../@parameterName"/>
	<xsl:template mode="widget:options" match="*">
		<xsl:variable name="value" select="ancestor::px:Parameter[1]/@value"/>
		<option value="{@meta:id}">
			<xsl:if test="$value=@meta:id">
				<xsl:attribute name="selected"/>
			</xsl:if>
			<xsl:value-of select="@meta:text"/>
		</option>
	</xsl:template>
</xsl:stylesheet>
