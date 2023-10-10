<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:source="http://panax.io/fetch/request"
  xmlns:state="http://panax.io/state"
  xmlns:data="http://panax.io/source"
  xmlns:tabPanel="http://panax.io/widget/tabPanel"
  xmlns:container="http://panax.io/layout/container"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:px="http://panax.io"
  exclude-result-prefixes="px state xo source data xsi"
  xmlns="http://www.w3.org/1999/xhtml"
>
	<xsl:key name="state:hidden" match="node-expected" use="."/>
	<xsl:template match="/" priority="-1">
		<xsl:apply-templates select="*/@xo:id" mode="tabPanel:widget"/>
	</xsl:template>

	<xsl:template match="text()" mode="tabPanel:widget"/>
	<xsl:template match="text()" mode="tabPanel:widget-header"/>
	<xsl:template match="text()" mode="tabPanel:widget-header-title-label"/>
	<xsl:template match="text()" mode="tabPanel:widget-body"/>
	<xsl:template match="text()" mode="tabPanel:widget-footer"/>

	<xsl:key name="active" match="node-expected" use="@xo:id"/>
	<xsl:key name="active" match="*[not(@state:active)]/container:tab[1]" use="@xo:id"/>
	<xsl:key name="active" match="container:tab[not(parent::container:tabPanel)]" use="@xo:id"/>
	<xsl:key name="active" match="container:tab[@xo:id=../@state:active]" use="@xo:id"/>

	<xsl:template match="@*" mode="tabPanel:widget" priority="-1">
		<xsl:param name="items" select="../container:tab/@Name|../container:tab[not(@Name)]/@xo:id"/>
		<div class="tab-pane fade show active" role="tabpanel" aria-labelledby="v-pills-profile-tab">
			<ul class="nav nav-tabs">
				<xsl:apply-templates mode="tabPanel:nav-item" select="$items"/>
			</ul>
			<xsl:variable name="active_tab" select="$items[key('active', ../@xo:id)]"/>
			<xsl:apply-templates mode="tabPanel:body" select="$active_tab"/>
		</div>
	</xsl:template>

	<xsl:template mode="tabPanel:body" match="@*">
		<xsl:variable name="active_panel" select="../container:panel"/>
		<div class="tab-content p-3">
			<xsl:apply-templates mode="widget" select="$active_panel/@Name|$active_panel[not(@Name)]/@xo:id"/>
		</div>
	</xsl:template>

	<xsl:template mode="tabPanel:nav-item" match="@*">
		<xsl:variable name="active">
			<xsl:choose>
				<xsl:when test="key('active', ../@xo:id)">active</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<li class="nav-item">
			<a class="nav-link {$active}" href="#" xo-scope="{../../@xo:id}" xo-slot="state:active" onclick="scope.set('{../@xo:id}')">
				<xsl:apply-templates mode="headerText" select="."/>
			</a>
		</li>
	</xsl:template>

	<xsl:template mode="tabPanel:body" match="*[key('state:hidden',@xo:id)]/@*|@*[key('state:hidden',concat(ancestor::px:Entity[1]/@xo:id,'::',name(..),'::',.))]">
	</xsl:template>

	<xsl:template mode="tabPanel:nav-item" match="*[key('state:hidden',@xo:id)]/@*|@*[key('state:hidden',concat(ancestor::px:Entity[1]/@xo:id,'::',name(..),'::',.))]">
		<xsl:comment>
			hidden:<xsl:value-of select="."/>
		</xsl:comment>
	</xsl:template>

</xsl:stylesheet>