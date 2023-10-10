<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:source="http://panax.io/fetch/request"
  xmlns:state="http://panax.io/state"
  xmlns:data="http://panax.io/source"
  xmlns:groupTabPanel="http://panax.io/widget/groupTabPanel"
  xmlns:container="http://panax.io/layout/container"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:px="http://panax.io"
  exclude-result-prefixes="px state xo source data xsi"
  xmlns="http://www.w3.org/1999/xhtml"
>
	<xsl:template match="/" priority="-1">
		<xsl:apply-templates select="*/@xo:id" mode="groupTabPanel:widget"/>
	</xsl:template>

	<xsl:template match="text()" mode="groupTabPanel:widget"/>
	<xsl:template match="text()" mode="groupTabPanel:widget-header"/>
	<xsl:template match="text()" mode="groupTabPanel:widget-header-title-label"/>
	<xsl:template match="text()" mode="groupTabPanel:widget-body"/>
	<xsl:template match="text()" mode="groupTabPanel:widget-footer"/>

	<xsl:key name="active" match="node-expected" use="@xo:id"/>
	<xsl:key name="active" match="*[not(@state:active_child)]/container:groupTabPanel[1]" use="@xo:id"/>
	<xsl:key name="active" match="container:groupTabPanel[@xo:id=../@state:active_child]" use="@xo:id"/>
	<xsl:key name="active" match="*[not(@state:active_child)]/container:subGroupTabPanel[1]" use="@xo:id"/>
	<xsl:key name="active" match="container:subGroupTabPanel[@xo:id=../@state:active_child]" use="@xo:id"/>
	<xsl:key name="show" match="container:groupTabPanel[@state:show]" use="@xo:id"/>

	<xsl:template match="@*" mode="groupTabPanel:widget" priority="-1">
		<xsl:param name="schema" select="node-expected"/>
		<xsl:param name="dataset" select="node-expected"/>
		<xsl:variable name="current_panel" select="../container:groupTabPanel[key('active', @xo:id)]/container:subGroupTabPanel[key('active', @xo:id)]/container:panel/*"/>
		<div class="row group-tab-pane align-top">
			<div class="col-4 col-md-3 col-lg-2 col-xl-2 group-tab-nav">
				<div class="accordion" id="accordionExample">
					<xsl:apply-templates mode="groupTabPanel:nav-item" select="../*/@Name|../*[not(@Name)]/@xo:id"/>
				</div>
			</div>
			<div class="col-8 col-md-9 col-lg-10 col-xl-10" style="padding-left: unset;">
				<div class="tab-content" id="v-pills-tabContent">
					<xsl:apply-templates mode="widget" select="$current_panel/@Name|$current_panel[not(@Name)]/@xo:id"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template mode="groupTabPanel:body" match="@*">
	</xsl:template>

	<xsl:template mode="groupTabPanel:nav-item" match="container:groupTabPanel/@*">
		<xsl:param name="schema" select="node-expected"/>
		<xsl:param name="dataset" select="node-expected"/>
		<xsl:variable name="active">
			<xsl:choose>
				<xsl:when test="key('active', ../@xo:id)">active</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="show">
			<xsl:choose>
				<xsl:when test="key('active', ../@xo:id) or key('show', ../@xo:id)">show</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="collapsed">
			<xsl:choose>
				<xsl:when test="not($show='show')">collapsed</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="item_position" select="count(../preceding-sibling::*)"/>
		<div class="accordion-item">
			<h2 class="accordion-header" id="heading_{$item_position}">
				<button class="accordion-button {$collapsed}" type="button" data-bs-toggle="collapse" data-bs-target="#collapse_{$item_position}" aria-controls="collapse_{$item_position}" xo-scope="{../@xo:id}" onclick="scope.parentNode.set('state:active_child','{../@xo:id}')">
					<xsl:attribute name="aria-expanded">
						<xsl:choose>
							<xsl:when test="$show = 'show'">true</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:apply-templates mode="headerText" select="."/>
				</button>
			</h2>
			<div id="collapse_{$item_position}" class="accordion-collapse collapse {$show}" aria-labelledby="heading_{$item_position}" data-bs-parent="#accordionExample">
				<xsl:variable name="children_items" select="../*"/>
				<xsl:if test="count($children_items) &gt; 1">
					<div class="accordion-body">
						<ul class="nav flex-column nav-pills" id="v-pills-tab" role="tablist" aria-orientation="vertical" style="width:fit-content;">
							<xsl:apply-templates mode="groupTabPanel:nav-item" select="$children_items/@Name|$children_items[not(@Name)]/@xo:id"/>
						</ul>
					</div>
				</xsl:if>
			</div>
		</div>
	</xsl:template>

	<xsl:template mode="groupTabPanel:nav-item" match="container:subGroupTabPanel/@*">
		<xsl:param name="schema" select="node-expected"/>
		<xsl:param name="dataset" select="node-expected"/>
		<xsl:variable name="active">
			<xsl:choose>
				<xsl:when test="key('active', ../@xo:id)">active</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<li class="nav-item" style="margin-bottom: 10px;" xo-scope="{../../@xo:id}" xo-slot="state:active_child" onclick="scope.set('{../@xo:id}')">
			<a class="nav-link {$active}" id="v-pills-home-tab" data-toggle="pill" href="#v-pills-home" role="tab" aria-controls="v-pills-home" aria-selected="true">
				<xsl:apply-templates mode="headerText" select="."/>
			</a>
		</li>
	</xsl:template>

</xsl:stylesheet>