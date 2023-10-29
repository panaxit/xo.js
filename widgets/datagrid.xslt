<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:state="http://panax.io/state"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:meta="http://panax.io/metadata"
  xmlns:data="http://panax.io/source"
  xmlns:px="http://panax.io/entity"
  xmlns:datagrid="http://panax.io/widget/datagrid"
  xmlns:field="http://panax.io/layout/fieldref"
  xmlns:container="http://panax.io/layout/container"
  xmlns:association="http://panax.io/datatypes/association"
  xmlns:widget="http://panax.io/widget"
  xmlns:route="http://panax.io/routes"
  exclude-result-prefixes="xo state xsl datagrid data px meta route"
>
	<xsl:import href="keys.xslt"/>
	<!--<xsl:import href="../keys.xslt"/>
	<xsl:import href="../values.xslt"/>
	<xsl:import href="../headers.xslt"/>-->

	<xsl:param name="state:delete"/>

	<xsl:key name="datagrid:widget" match="key-expected" use="@xo:id"/>
	<xsl:key name="datagrid:header-node" match="key-expected" use="@xo:id"/>

	<xsl:key name="data:wrapper" match="data:rows" use="generate-id()"/>

	<xsl:template match="@*" mode="datagrid:attributes"/>

	<xsl:template mode="datagrid:widget" match="@*">
		<xsl:param name="layout" select="key('layout',ancestor::px:Entity[1]/@xo:id)"/>
		<xsl:variable name="context" select="key('dataset',ancestor::px:Entity[1]/@xo:id)"/>
		<div class="w-100">
			<xsl:apply-templates mode="datagrid:attributes" select="."/>
			<style>
				<![CDATA[
				tr.deleting, tr.deleting:hover {
					background: red;
					color:white !important;
				}

				tr.deleting:after {
					background: red;
					content: '';
					left: 50%;
					position: absolute;
					transform: translateX(-50%) translateY(50%);
					width: 70%;
					height: 25px;
					vertical-align: middle;
					opacity: .5;
				}
				
				thead .field-container  {
					text-align: center
				}
				
				th {
					white-space: nowrap;
				}
				]]>
			</style>
			<table class="table table-striped table-hover table-sm datagrid">
				<xsl:apply-templates mode="datagrid:header-colgroup" select="current()">
					<xsl:with-param name="layout" select="$layout"/>
				</xsl:apply-templates>
				<thead class="freeze">
					<xsl:apply-templates mode="datagrid:header" select="current()">
						<xsl:with-param name="layout" select="$layout"/>
					</xsl:apply-templates>
				</thead>
				<xsl:apply-templates mode="datagrid:body" select="current()">
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="layout" select="$layout"/>
				</xsl:apply-templates>
				<xsl:apply-templates mode="datagrid:footer" select="current()">
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="layout" select="$layout"/>
				</xsl:apply-templates>
			</table>
		</div>
	</xsl:template>

	<!--<xsl:template mode="widget" match="px:Parameters[px:Parameter]">
		<form class="form-inline my-2 my-lg-0">
			<xsl:apply-templates mode="widget" select="px:Parameter"/>
		</form>
	</xsl:template>

	<xsl:template mode="widget" match="px:Parameter">
		<xsl:apply-templates mode="widget" select="@xo:id"/>
	</xsl:template>

	<xsl:template mode="widget" match="px:Parameter/@*">
		<div class="input-group">
			<div class="input-group-prepend">
				<span class="input-group-text" id="basic-addon1">
					<xsl:value-of select="../@parameterName"/>
				</span>
			</div>
			<input type="text" class="form-control" placeholder="Username" aria-label="Username" aria-describedby="basic-addon1"/>
		</div>
	</xsl:template>-->

	<xsl:key name="atomic-ref" match="field:ref/@Name" use="generate-id()"/>
	<xsl:key name="atomic-ref" match="association:ref/@Name" use="generate-id()"/>
	<xsl:key name="atomic-ref" match="container:fieldContainer/@Name" use="generate-id()"/>
	<xsl:key name="atomic-ref" match="container:fieldContainer[not(@Name)]/@xo:id" use="generate-id()"/>

	<xsl:template mode="datagrid:header-colgroup" match="@*">
		<xsl:param name="layout" select="key('layout',ancestor::px:Entity[1]/@xo:id)"/>
		<colgroup>
			<xsl:apply-templates mode="datagrid:header-colgroup-head" select="."/>
			<xsl:apply-templates mode="datagrid:header-colgroup-column" select="$layout"/>
			<xsl:apply-templates mode="datagrid:header-colgroup-foot" select="."/>
		</colgroup>
	</xsl:template>

	<xsl:template mode="datagrid:header-colgroup-head" match="@*">
		<col width="40px"/>
	</xsl:template>

	<xsl:template mode="datagrid:header-colgroup-column--style" match="@*">
		<xsl:text>max-width: max-content</xsl:text>
	</xsl:template>

	<xsl:template mode="datagrid:header-colgroup-column-attributes" match="@*"/>

	<xsl:template mode="datagrid:header-colgroup-column-attributes" match="*[@DataLength]/@*">
		<xsl:attribute name="width">
			<xsl:value-of select="concat(../@DataLength,'px')"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template mode="datagrid:header-colgroup-column" match="@*">
		<xsl:variable name="schema" select="key('schema',concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name))"/>
		<xsl:choose>
			<xsl:when test="count($schema|.)=1">
				<col width="150px">
					<xsl:apply-templates mode="datagrid:header-colgroup-column-attributes" select="."/>
					<xsl:attribute name="style">
						<xsl:text></xsl:text><xsl:apply-templates mode="datagrid:header-colgroup-column--style" select="."/>
					</xsl:attribute>
				</col>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>debug:info</xsl:comment>
				<xsl:apply-templates mode="datagrid:header-colgroup-column" select="$schema"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="datagrid:header-colgroup-foot" match="@*">
		<col width="40px"/>
	</xsl:template>

	<xsl:template mode="datagrid:header" match="@*"/>

	<xsl:template mode="datagrid:header" match="@*">
		<xsl:param name="mode">header</xsl:param>
		<xsl:param name="layout" select="ancestor::px:Entity[1]/*[local-name()='layout']/*/@Name|ancestor::px:Entity[1]/*[local-name()='layout']/*[not(@Name)]/@xo:id"/>
		<xsl:variable name="scope" select="current()"/>
		<!--<xsl:variable name="field-typed" select="$layout[parent::field:ref]|$layout[parent::association:ref]|$layout[parent::container:fieldContainer]"/>-->
		<xsl:variable name="row-content" select="$layout[parent::field:ref]|$layout[parent::association:ref]|$layout[parent::container:tab]|$layout[parent::container:panel]|$layout[parent::container:tabPanel]|$layout[parent::container:subGroupTabPanel]|$layout[parent::container:fieldSet]"/>
		<xsl:variable name="row-elements" select="$layout[not(../@xo:id=$row-content/../@xo:id)]"/>
		<xsl:variable name="next-level" select="$layout/../*/@Name|$layout/../*[not(@Name)]/@xo:id|$layout[parent::*[not(*)]]"/>
		<tr class="freeze">
			<xsl:apply-templates mode="datagrid:row-header" select="."/>
			<xsl:apply-templates mode="datagrid:header" select="$row-content">
				<xsl:with-param name="mode">header</xsl:with-param>
				<xsl:with-param name="layout" select="$layout"/>
			</xsl:apply-templates>
			<xsl:apply-templates mode="datagrid:row-footer" select="."/>
		</tr>
		<xsl:if test="count($layout)!=count($next-level)">
			<xsl:apply-templates mode="datagrid:header" select="current()">
				<xsl:with-param name="mode">header</xsl:with-param>
				<xsl:with-param name="layout" select="$next-level"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:key name="active" match="node-expected" use="@xo:id"/>

	<xsl:template mode="datagrid:header" match="@*">
		<xsl:param name="mode">header</xsl:param>
		<xsl:param name="layout" select="ancestor::px:Entity[1]/*[local-name()='layout']/*"/>
		<xsl:variable name="scope" select="current()"/>
		<xsl:variable name="row-content" select="$layout/ancestor-or-self::*[1]/self::field:ref|$layout/ancestor-or-self::*[1]/self::association:ref|$layout/ancestor-or-self::*[1]/self::container:fieldContainer|$layout/ancestor-or-self::*[1]/self::container:tab[key('active', @xo:id)]|$layout/ancestor-or-self::*[1]/self::container:panel/*|$layout/ancestor-or-self::*[1]/self::container:tabPanel/container:tab[key('active', @xo:id)]|$layout/ancestor-or-self::*[1]/self::container:subGroupTabPanel|$layout/ancestor-or-self::*[1]/self::container:fieldSet|$layout/ancestor-or-self::*[1]/self::px:Field|$layout/ancestor-or-self::*[1]/self::px:Association"/>
		<xsl:variable name="row-elements" select="$layout[not(../@xo:id=$row-content/../@xo:id)]"/>
		<xsl:variable name="next-level" select="$row-content/*"/>
		<tr class="freeze">
			<xsl:apply-templates mode="datagrid:row-header" select="."/>
			<xsl:apply-templates mode="datagrid:header" select="$row-content[* or not($next-level)]/@Name|$row-content[* or not($next-level)][not(@Name)]/@xo:id|$row-content[$next-level and not(*)]/@Id">
				<xsl:with-param name="mode">header</xsl:with-param>
				<xsl:with-param name="layout" select="$layout"/>
			</xsl:apply-templates>
			<xsl:apply-templates mode="datagrid:row-footer" select="."/>
		</tr>
		<xsl:if test="$next-level">
			<xsl:apply-templates mode="datagrid:header" select="current()">
				<xsl:with-param name="mode">header</xsl:with-param>
				<xsl:with-param name="layout" select="$next-level/@Name|$next-level[not(@Name)]/@xo:id|$row-content[not(*)]/@Name|$row-content[not(@Name)][not(*)]/@xo:id"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template mode="datagrid:header" match="px:Record/px:*/@*">
		<th>
			<xsl:apply-templates mode="headerText" select="."/>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:header" match="container:*/@*">
		<xsl:param name="layout" select="node-expected"/>
		<xsl:variable name="colspan">
			<xsl:value-of select="count(..//field:ref|..//association:ref)"/>
		</xsl:variable>
		<th colspan="{$colspan}" class="field-container container-{local-name(..)} container-{translate(../@Name,' ','-')}">
			<xsl:apply-templates mode="headerText" select="."/>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:header-actions" match="@*">
		<xsl:apply-templates mode="datagrid:header-sorter" select="."/>
		<xsl:apply-templates mode="datagrid:header-filters" select="."/>
	</xsl:template>

	<xsl:template mode="datagrid:header-filters" match="@*">
	</xsl:template>

	<xsl:key name="datagrid:filters-enabled" match="path-to-attribute/@*" use="concat('entity/@xo:id','::',../@Name)"/>
	<xsl:key name="datagrid:filters-disabled" match="path-to-attribute/@*" use="concat('entity/@xo:id','::',../@Name)"/>
	<xsl:template mode="datagrid:header-filters" match="@*[key('datagrid:filters-enabled',concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name)) or not(key('datagrid:filters-disabled',concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name)))]">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-funnel" viewBox="0 0 16 16" xo-scope="{../@xo:id}" xo-slot="state:filter" onclick="scope.dispatch('filter')">
			<xsl:if test="not(parent::*[@state:filter])">
				<xsl:attribute name="style">
					<xsl:text>color: gray;</xsl:text>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="datagrid:header-filters-attributes"/>
			<path d="M1.5 1.5A.5.5 0 0 1 2 1h12a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-.128.334L10 8.692V13.5a.5.5 0 0 1-.342.474l-3 1A.5.5 0 0 1 6 14.5V8.692L1.628 3.834A.5.5 0 0 1 1.5 3.5v-2zm1 .5v1.308l4.372 4.858A.5.5 0 0 1 7 8.5v5.306l2-.666V8.5a.5.5 0 0 1 .128-.334L13.5 3.308V2h-11z"/>
		</svg>
	</xsl:template>
	
	<xsl:template mode="datagrid:header-filters-attributes" match="@*"/>

	<xsl:template mode="datagrid:header-sorter" match="@*">
	</xsl:template>

	<xsl:key name="datagrid:sort-enabled" match="path-to-attribute/@*" use="concat('entity/@xo:id','::',../@Name)"/>
	<xsl:key name="datagrid:sort-disabled" match="path-to-attribute/@*" use="concat('entity/@xo:id','::',../@Name)"/>
	<xsl:template mode="datagrid:header-sorter" match="@*[key('datagrid:sort-enabled',concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name)) or not(key('datagrid:sort-disabled',concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name)))]">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-sort-down-alt" viewBox="0 0 16 16" xo-scope="{../@xo:id}" xo-slot="sortDirection" onclick="scope.toggle('DESC','ASC')">
			<xsl:if test="not(parent::*[@sortOrder])">
				<xsl:attribute name="style">
					<xsl:text>color: gray;</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="onclick">
					<xsl:text>scope.set('')</xsl:text>
				</xsl:attribute>
			</xsl:if>
			<path d="M3.5 3.5a.5.5 0 0 0-1 0v8.793l-1.146-1.147a.5.5 0 0 0-.708.708l2 1.999.007.007a.497.497 0 0 0 .7-.006l2-2a.5.5 0 0 0-.707-.708L3.5 12.293V3.5zm4 .5a.5.5 0 0 1 0-1h1a.5.5 0 0 1 0 1h-1zm0 3a.5.5 0 0 1 0-1h3a.5.5 0 0 1 0 1h-3zm0 3a.5.5 0 0 1 0-1h5a.5.5 0 0 1 0 1h-5zM7 12.5a.5.5 0 0 0 .5.5h7a.5.5 0 0 0 0-1h-7a.5.5 0 0 0-.5.5z"/>
		</svg>
	</xsl:template>

	<xsl:template mode="datagrid:header-sorter" match="*[@sortOrder][@sortDirection='DESC']/@*[key('datagrid:sort-enabled',concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name)) or not(key('datagrid:sort-disabled',concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name)))]">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-sort-down" viewBox="0 0 16 16" xo-scope="{../@xo:id}" xo-slot="sortDirection" onclick="scope.set('ASC')">
			<path d="M3.5 2.5a.5.5 0 0 0-1 0v8.793l-1.146-1.147a.5.5 0 0 0-.708.708l2 1.999.007.007a.497.497 0 0 0 .7-.006l2-2a.5.5 0 0 0-.707-.708L3.5 11.293V2.5zm3.5 1a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7a.5.5 0 0 1-.5-.5zM7.5 6a.5.5 0 0 0 0 1h5a.5.5 0 0 0 0-1h-5zm0 3a.5.5 0 0 0 0 1h3a.5.5 0 0 0 0-1h-3zm0 3a.5.5 0 0 0 0 1h1a.5.5 0 0 0 0-1h-1z"/>
		</svg>
	</xsl:template>

	<xsl:template mode="datagrid:header" match="field:ref/@*|association:ref/@*|container:fieldContainer/@*">
		<xsl:param name="layout" select="node-expected"/>
		<xsl:variable name="schema" select="key('schema',concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name))"/>
		<xsl:variable name="colspan">
			<xsl:value-of select="count(..//field:ref|..//association:ref)"/>
		</xsl:variable>
		<xsl:variable name="fk_layout" select="ancestor::px:Entity[1]/px:Record/px:Association[not(@Type='belongsTo')][@AssociationName=current()]/px:Entity/*[local-name()='layout']/*/@Name"/>
		<th colspan="{$colspan}">
			<!--<xsl:if test="key('atomic-ref',generate-id()) and not($layout[not(key('atomic-ref',generate-id()))]) or not(key('atomic-ref',generate-id()))">
				<xsl:choose>
					<xsl:when test="$fk_layout">
						<table>
							<colgroup>
								<col style="width:40px"/>
								<xsl:for-each select="$fk_layout">
									<col style="min-width: 150px"/>
								</xsl:for-each>
								<col style="width:40px"/>
							</colgroup>
							<tr>
								<th colspan="{count($fk_layout)}">
									<xsl:apply-templates mode="headerText" select="."/>
								</th>
							</tr>
							<xsl:apply-templates mode="datagrid:header" select="$fk_layout/ancestor::px:Entity[1]/@xo:id">
							</xsl:apply-templates>
						</table>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="headerText" select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>-->
			<label xo-scope="{$schema/../@xo:id}">
				<xsl:apply-templates mode="headerText" select="."/>
			</label>
			<xsl:apply-templates mode="datagrid:header-actions" select="$schema"/>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:header" match="@Id" priority="1">
		<th></th>
	</xsl:template>

	<!--<xsl:template mode="datagrid:header" match="container:subGroupTabPanel/@*|container:tab/@*">
		<xsl:param name="mode">header</xsl:param>
		<xsl:param name="context" select="node-expected"/>
		<xsl:param name="layout" select="ancestor-or-self::*[1]/@xo:id"/>
		<xsl:variable name="scope" select="current()"/>
		<xsl:variable name="row-content" select="../*"/>
		<xsl:variable name="row-elements" select="../*[not(@xo:id=$row-content/@xo:id)]"/>
		<li class="nav-item">
			<a class="nav-link active" href="#" xo-slot="state:selected" onclick="scope.set('1')">
				<xsl:apply-templates mode="headerText" select="."/>
			</a>
		</li>
	</xsl:template>-->

	<xsl:template mode="datagrid:header" match="container:groupTabPanel/@*|container:subGroupTabPanel/@*|container:tab/@*">
		<!--container:tab[not(parent::container:tabPanel)]/@*-->
		<xsl:param name="mode">header</xsl:param>
		<xsl:param name="context" select="node-expected"/>
		<xsl:param name="layout" select="ancestor-or-self::*[1]/@xo:id"/>
		<xsl:variable name="colspan">
			<xsl:value-of select="count(..//field:ref|..//association:ref)"/>
		</xsl:variable>
		<xsl:variable name="scope" select="current()"/>
		<xsl:variable name="row-content" select="../*"/>
		<xsl:variable name="row-elements" select="../*[not(@xo:id=$row-content/@xo:id)]"/>
		<th colspan="{$colspan}">
			<ul class="nav nav-tabs">
				<li class="nav-item">
					<a class="nav-link active" href="#" xo-slot="state:selected" onclick="scope.set('1')">
						<xsl:value-of select="."/>
					</a>
				</li>
			</ul>
		</th>
	</xsl:template>

	<!--<xsl:template mode="datagrid:header" match="container:groupTabPanel/@*|container:tabPanel/@*">
		<xsl:param name="mode">header</xsl:param>
		<xsl:param name="context" select="node-expected"/>
		<xsl:param name="layout" select="ancestor-or-self::*[1]/@xo:id"/>
		<xsl:variable name="colspan">
			<xsl:value-of select="count(..//field:ref|..//association:ref)"/>
		</xsl:variable>
		<xsl:variable name="scope" select="current()"/>
		<xsl:variable name="row-content" select="../container:tab|../container:subGroupTabPanel"/>
		<xsl:variable name="row-elements" select="../*[not(@xo:id=$row-content/@xo:id)]"/>
		<th colspan="{$colspan}">
			<ul class="nav nav-tabs">
				<xsl:apply-templates mode="datagrid:header" select="$row-content/@Name|$row-content[not(@Name)]/@xo:id">
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="mode">header</xsl:with-param>
					<xsl:with-param name="layout" select="current()"/>
				</xsl:apply-templates>
				<li class="nav-item">
					<a class="nav-link active" href="#" xo-slot="state:selected" onclick="scope.set('1')">
						<xsl:value-of select="."/>
					</a>
				</li>
			</ul>
		</th>
		<xsl:apply-templates mode="datagrid:header" select="$row-elements/@Name|$row-elements[not(@Name)]/@xo:id">
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="mode">header</xsl:with-param>
			<xsl:with-param name="layout" select="current()"/>
		</xsl:apply-templates>
	</xsl:template>-->

	<!--<xsl:template mode="datagrid:header" match="*[local-name()='layout']/@*">
		<xsl:param name="mode">header</xsl:param>
		<xsl:param name="context" select="node-expected"/>
		<xsl:param name="layout" select="ancestor-or-self::*[1]/@xo:id"/>
		<xsl:variable name="scope" select="current()"/>
		<xsl:apply-templates mode="datagrid:header" select="../*/@Name|../*[not(@Name)]/@xo:id">
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="mode">header</xsl:with-param>
			<xsl:with-param name="layout" select="current()"/>
		</xsl:apply-templates>
	</xsl:template>-->

	<xsl:template mode="datagrid:body" match="@*">
		<xsl:param name="mode">body</xsl:param>
		<xsl:param name="context" select="node-expected"/>
		<xsl:param name="layout" select="ancestor-or-self::*[1]/@xo:id"/>
		<xsl:variable name="rows" select="$context/ancestor-or-self::data:rows[1]/xo:r/@xo:id|$context[not(self::*) and namespace-uri()='http://www.w3.org/2001/XMLSchema-instance' and local-name()='nil']"/>
		<tbody class="table-group-divider">
			<xsl:apply-templates mode="datagrid:row" select="$context">
				<xsl:sort data-type="number" select="../@meta:position"/>
				<xsl:with-param name="mode" select="$mode"/>
				<xsl:with-param name="layout" select="$layout"/>
			</xsl:apply-templates>
		</tbody>
	</xsl:template>

	<xsl:template mode="datagrid:footer" match="@*">
		<xsl:param name="mode">footer</xsl:param>
		<xsl:param name="context" select="node-expected"/>
		<xsl:param name="layout" select="ancestor-or-self::*[1]/@xo:id"/>
		<tfoot class="table-group-divider">
			<xsl:apply-templates mode="datagrid:row" select="current()">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="mode">footer</xsl:with-param>
				<xsl:with-param name="layout" select="$layout"/>
			</xsl:apply-templates>
			<tr xo-scope="{ancestor-or-self::*[@meta:type='entity'][1]/@xo:id}">
				<td colspan="{count($layout[key('atomic-ref',generate-id())]|$layout/../*//@*[key('atomic-ref',generate-id())])+3}" style="text-align:center">
					<xsl:apply-templates mode="datagrid:footer-row" select=".">
					</xsl:apply-templates>
				</td>
			</tr>
		</tfoot>
	</xsl:template>

	<xsl:template mode="datagrid:footer-row" match="@*">
		<xsl:comment>No footer</xsl:comment>
	</xsl:template>

	<xsl:template mode="datagrid:footer-row" match="@*[ancestor-or-self::*[@meta:type='entity'][2] and not(ancestor::px:Association[1][@DataType='junctionTable'])]">
		<xsl:apply-templates mode="datagrid:buttons-new" select="."/>
	</xsl:template>

	<xsl:template mode="datagrid:footer" match="xo:f/@xo:id"/>

	<xsl:template mode="datagrid:row-attributes" match="@*">
		<xsl:comment>No more attributes</xsl:comment>
	</xsl:template>

	<xsl:template mode="datagrid:row-attributes" match="xo:r[not(ancestor::px:Association[1][@DataType='junctionTable'])][@state:delete]/@xo:id">
		<xsl:attribute name="style">height:15px !important; background-color: #dc3545 !important;</xsl:attribute>
	</xsl:template>

	<xsl:template mode="datagrid:row-attributes" match="data:rows/@xo:id">
		<xsl:attribute name="class">skeleton skeleton-text</xsl:attribute>
	</xsl:template>

	<xsl:template mode="datagrid:row-style" match="@*" priority="-1"/>

	<xsl:template mode="datagrid:row" match="@*">
		<xsl:param name="mode">body</xsl:param>
		<xsl:param name="context" select="../@*"/>
		<xsl:param name="layout" select="node-expected"/>

		<xsl:variable name="fields" select="$context[ancestor::xo:r[@xo:id=current()]]|$context[parent::*/parent::px:Record]|$context[$mode='footer']"/>
		<xsl:variable name="row-content" select="$layout/..//field:ref|$layout/..//association:ref"/>
		<tr xo-scope="{../@xo:id}">
			<xsl:attribute name="style">
				<xsl:apply-templates mode="datagrid:row-style" select="."/>
			</xsl:attribute>
			<xsl:apply-templates mode="datagrid:row-attributes" select="current()"/>
			<xsl:apply-templates mode="datagrid:row-header" select="current()">
				<xsl:with-param name="mode" select="$mode"/>
				<xsl:with-param name="context" select="$fields"/>
			</xsl:apply-templates>
			<xsl:apply-templates mode="datagrid:row-body" select="$layout[key('atomic-ref',generate-id())]|$layout/../*//@*[key('atomic-ref',generate-id())]">
				<xsl:with-param name="mode" select="$mode"/>
				<xsl:with-param name="context" select="$fields"/>
			</xsl:apply-templates>
			<xsl:apply-templates mode="datagrid:row-footer" select="current()">
				<xsl:with-param name="mode" select="$mode"/>
				<xsl:with-param name="context" select="$fields"/>
			</xsl:apply-templates>
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:row" match="data:rows/@xsi:nil">
		<xsl:param name="mode">body</xsl:param>
		<xsl:param name="context" select="node-expected"/>
		<xsl:param name="layout" select="ancestor-or-self::*[1]/@xo:id"/>
		<tr>
			<td>&#160;</td>
			<td colspan="{count($layout)}" style="text-align: center;">
				<label>
					<xsl:apply-templates select="."/>
				</label>
			</td>
			<td>&#160;</td>
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:row" match="data:rows[@xsi:type='mock']/@xsi:nil|data:rows[../data:rows/*]/@xsi:nil|data:rows[ancestor::px:Association[1][@DataType='junctionTable']]/@xsi:nil">
		<xsl:param name="mode">body</xsl:param>
		<xsl:param name="context" select="node-expected"/>
		<xsl:param name="layout" select="ancestor-or-self::*[1]/@xo:id"/>
		<xsl:comment>No records</xsl:comment>
	
	</xsl:template>

	<xsl:template match="@xsi:nil">No hay registros</xsl:template>

	<xsl:template match="data:rows[ancestor::px:Association[1][@DataType='junctionTable']]/@xsi:nil"></xsl:template>

	<xsl:template mode="datagrid:row" match="xo:r[not(ancestor::px:Association[1][@DataType='junctionTable'])][@state:delete]/@xo:id">
		<xsl:param name="mode">body</xsl:param>
		<xsl:param name="context" select="../@*"/>
		<xsl:param name="layout" select="node-expected"/>
		<tr xo-scope="{../@xo:id}" style="height:15px !important; background-color: #dc3545 !important;">
			<td colspan="{count($layout)+3}" style="text-align:center;">
				<div xo-slot="state:delete">
					<span class="badge-delete p-1 badge-danger-light" onclick="scope.remove()">
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-counterclockwise" viewBox="0 0 16 16">
							<path fill-rule="evenodd" d="M8 3a5 5 0 1 1-4.546 2.914.5.5 0 0 0-.908-.417A6 6 0 1 0 8 2v1z"></path>
							<path d="M8 4.466V.534a.25.25 0 0 0-.41-.192L5.23 2.308a.25.25 0 0 0 0 .384l2.36 1.966A.25.25 0 0 0 8 4.466z"></path>
						</svg>&#160;Cancelar borrar
					</span>
				</div>
			</td>
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:row" match="*[key('state:hidden',@xo:id)]/@*" priority="1"></xsl:template>

	<xsl:template mode="datagrid:row-header" match="@*">
		<xsl:param name="context" select="../@*"/>
		<xsl:param name="reference" select="xo:dummy"/>
		<xsl:comment>No row-header</xsl:comment>
	</xsl:template>

	<xsl:template mode="datagrid:row-footer" match="@*">
		<xsl:param name="context" select="../@*"/>
		<xsl:comment>No row-footer</xsl:comment>
	</xsl:template>

	<xsl:template mode="datagrid:row-body" match="@*">
		<xsl:param name="mode">body</xsl:param>
		<xsl:param name="context" select="node-expected"/>
		<xsl:variable name="row" select="$context"/>
		<xsl:variable name="current" select="current()"/>
		<xsl:variable name="cell_type">
			<xsl:choose>
				<xsl:when test="$mode='header'">th</xsl:when>
				<xsl:otherwise>td</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$cell_type}">
			<xsl:if test="$mode='header'">
				<xsl:attribute name="scope">col</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="style">
				<xsl:apply-templates mode="datagrid:cell-style" select="current()"/>
			</xsl:attribute>
			<xsl:apply-templates mode="datagrid:cell-attributes" select="current()"/>
			<xsl:apply-templates mode="datagrid:cell-content" select="current()">
				<xsl:with-param name="mode" select="$mode"/>
				<xsl:with-param name="context" select="$row[not(self::*)]|$row/@*|$row/xo:f/@Name|$row/px:Association/@AssociationName"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template mode="datagrid:cell-style" match="@*"/>
	<xsl:template mode="datagrid:cell-attributes" match="@*"/>

	<xsl:template mode="datagrid:field-append" match="@*">
		<xsl:text></xsl:text>
	</xsl:template>

	<xsl:template mode="datagrid:field-append" match="xo:r/@*">
		<xsl:text></xsl:text>
	</xsl:template>

	<xsl:template mode="datagrid:field-prepend" match="@*">
		<xsl:text></xsl:text>
	</xsl:template>

	<xsl:template mode="datagrid:cell-content" match="@*">
		<xsl:param name="mode">body</xsl:param>
		<xsl:param name="context" select="."/>
		<xsl:variable name="ref_field" select="$context[parent::xo:r][name()=current()[parent::field:ref]]|$context[parent::xo:f][.=current()[parent::field:ref]]|$context[name()=concat('meta:',current()[parent::association:ref])]|$context/../px:Association[@AssociationName=current()]/@AssociationName|$context[current()=ancestor::px:Association[1]/@Name and ancestor::px:Entity[2]=current()/ancestor::px:Entity[1]]/../@meta:text"/>
		<span>
			<xsl:choose>
				<xsl:when test="$mode='header'">
					<xsl:apply-templates mode="datagrid:header-content" select=".">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$mode='footer'">
					<xsl:apply-templates mode="datagrid:footer-content" select=".">
						<xsl:with-param name="context" select="$ref_field"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="count($ref_field|current())=1">
					<xsl:apply-templates mode="datagrid:field-prepend" select="."/>
					<xsl:apply-templates mode="datagrid:field" select="current()"/>
					<xsl:apply-templates mode="datagrid:field-append" select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="datagrid:cell-content" select="$ref_field">
						<xsl:with-param name="context" select="current()"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>

	<xsl:template mode="datagrid:header-content" match="@*">
		<xsl:param name="context" select="."/>
		<span>
			<xsl:apply-templates mode="headerText" select=".">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</span>
	</xsl:template>

	<xsl:template mode="datagrid:footer-content" match="@*">
		<xsl:param name="context" select="."/>
		<span/>
	</xsl:template>

	<xsl:template mode="datagrid:cell-content" match="container:*/@*">
		<xsl:param name="mode">body</xsl:param>
		<xsl:param name="schema" select="node-expected"/>
		<xsl:param name="context" select="node-expected"/>
		<xsl:apply-templates mode="datagrid:cell-content" select="../*[$mode='header']/@Name|../*[$mode!='header']/@Name|../*[$mode='header'][not(@Name)]/@xo:id|../*[$mode!='header'][not(@Name)]/@xo:id">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
	</xsl:template>

	<!--<xsl:template mode="datagrid:cell-content" match="container:*/@Name">
		<xsl:param name="mode">body</xsl:param>
		<xsl:param name="context" select="node-expected"/>
		<xsl:choose>
			<xsl:when test="$mode='header'">
				<xsl:apply-templates mode="headerText" select="."/>
				<xsl:apply-templates mode="datagrid:cell-content" select="../@xo:id">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>
					<xsl:value-of select="$mode"/>: <xsl:value-of select="name()"/>
				</xsl:comment>
				<xsl:apply-templates mode="datagrid:cell-content" select="../*/@xo:id">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>-->

	<xsl:template mode="widget:style" match="@*"/>
	<xsl:template mode="datagrid:field" match="@*">
		<span class="d-flex flex-wrap">
			<xsl:attribute name="style">
				<xsl:apply-templates mode="widget:style" select="."/>
			</xsl:attribute>
			<xsl:apply-templates mode="widget" select="."/>
		</span>
	</xsl:template>

	<xsl:template mode="datagrid:field" match="association:ref/@*">
		<div class="skeleton skeleton-text">&#160;</div>
	</xsl:template>

	<xsl:template mode="datagrid:field" match="field:ref/@*">
		<div>&#160;</div>
	</xsl:template>

	<xsl:template mode="datagrid:field" match="xo:r[@state:edit='true']/@*">
		<span>
			<xsl:apply-templates mode="widget" select="."/>
		</span>
	</xsl:template>

	<xsl:template mode="widget" match="*[key('datagrid:header-node',@xo:id)]/@*">
		<span>
			<xsl:apply-templates mode="headerText" select="."/>
		</span>
	</xsl:template>

	<xsl:template mode="datagrid:buttons-new" match="@*">
		<xsl:variable name="reference">
			<xsl:choose>
				<xsl:when test="ancestor::px:Association">
					<xsl:value-of select="concat('@',../data:rows/@xo:id)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:apply-templates mode="route:widget" select="ancestor::px:Entity[1]/px:Routes/px:Route[@Method='add']/@xo:id">
			<xsl:with-param name="context" select=".."/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:key name="selected" match="*[@state:selected]" use="@xo:id"/>

	<xsl:template mode="datagrid:list" match="*|text()"/>

	<xsl:template mode="datagrid:list" match="data:rows/*">
		<li class="list-group-item d-flex justify-content-between lh-sm">
			<div>
				<h6 class="my-0">
					<xsl:value-of select="@text"/>
				</h6>
			</div>
			<!--<span class="text-muted">$12</span>-->
		</li>
	</xsl:template>

</xsl:stylesheet>