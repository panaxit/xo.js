<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:state="http://panax.io/state"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:control="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:layout_datagrid="http://panax.io/layout"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:meta="http://panax.io/metadata"
  xmlns:custom="http://panax.io/custom"
  xmlns:temp="http://panax.io/temp"
  xmlns:data="http://panax.io/source"
  xmlns:height = "http://panax.io/state/height"
  xmlns:width = "http://panax.io/state/width"
  xmlns:px="http://panax.io/entity"
  xmlns:datagrid="http://panax.io/widget/datagrid"
  xmlns:form="http://panax.io/widget/form"
  xmlns:widget="http://panax.io/widget"
  xmlns:route="http://panax.io/routes"
  xmlns:container="http://panax.io/layout/container"
  xmlns:association="http://panax.io/datatypes/association"
  exclude-result-prefixes="xo state xsl datagrid container association data height width data temp meta custom"
>
	<xsl:import href="keys.xslt"/>
	<xsl:import href="headers.xslt"/>
	<xsl:import href="routes.xslt"/>
	<xsl:import href="widgets/datagrid.xslt"/>
	<xsl:param name="data:rows"/>

	<xsl:key name="datagrid:widget" match="node-expected" use="@xo:id"/>
	<xsl:key name="datagrid:row-header-element" match="px:Route[@Method='addToCart']/@Method" use="ancestor::px:Entity[1]/@xo:id"/>
	<xsl:key name="datagrid:row-header-element" match="px:Route[@Method='facturar']/@Method" use="ancestor::px:Entity[1]/@xo:id"/>
	<xsl:key name="datagrid:row-header-element" match="px:Route[@Method='select']/@Method" use="ancestor::px:Entity[1]/@xo:id"/>
	<xsl:key name="datagrid:row-header-element" match="px:Route[@Method='edit']/@Method" use="ancestor::px:Entity[1]/@xo:id"/>

	<xsl:key name="datagrid:row-footer-element" match="px:Route[@Method='delete'][not(ancestor::px:Association[1][@DataType='junctionTable'])]/@Method" use="ancestor::px:Entity[1]/@xo:id"/>

	<xsl:key name="datagrid:row-header-element" match="px:Association[@DataType='junctionTable']/px:Entity/px:Routes/px:Route[@Method='add']/@Method" use="ancestor::px:Entity[1]/@xo:id"/>
	<xsl:key name="datagrid:row-header-element" match="px:Association[@DataType='junctionTable']/px:Entity/px:Routes/px:Route[@Method='delete']/@Method" use="ancestor::px:Entity[1]/@xo:id"/>

	<!--<xsl:key name="datagrid:filters-enabled" match="dummy/@*" use="concat(/px:Entity[1]/@xo:id,'::',../@Name)"/>-->
	<xsl:key name="datagrid:filters-disabled" match="px:Association//px:Record/px:*/@*" use="concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name)"/>
	<xsl:key name="datagrid:sort-disabled" match="px:Association//px:Record/px:*/@*" use="concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name)"/>
		<xsl:key name="datagrid:filters-enabled" match="px:Association[@DataType='junctionTable']/px:Entity/px:Record/px:Association/@*" use="concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name)"/>
	<xsl:key name="datagrid:sort-enabled" match="px:Association[@DataType='junctionTable']/px:Entity/px:Record/px:Association/@*" use="concat(ancestor::px:Entity[1]/@xo:id,'::',../@Name)"/>


	<xsl:key name="hidden" match="px:Association[@DataType='junctionTable']/px:Entity/px:Routes/px:Route[@Method='edit']" use="@xo:id"/>
	<xsl:key name="hidden" match="px:Association[@DataType='junctionTable']/px:Entity/px:Record/px:Association/px:Entity/px:Routes/px:Route[@Method='delete']" use="@xo:id"/>
	
	<xsl:template mode="datagrid:row-header" match="@*">
		<!--<th scope="row">
			<xsl:value-of select="../@meta:position"/>
		</th>-->
		<th>
			<xsl:apply-templates mode="widget" select="key('datagrid:row-header-element',ancestor::px:Entity[1]/@xo:id)">
				<xsl:with-param name="context" select="parent::xo:r"/>
			</xsl:apply-templates>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:row-header" match="*[key('datagrid:header-node', @xo:id)][not(ancestor::px:Association)]/@*">
		<th>
			<button class="btn btn-sm btn-primary" onclick="event.preventDefault(); scope.remove()" xo-scope="{../../data:rows/@xo:id}">
				<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-clockwise" viewBox="0 0 16 16">
					<path fill-rule="evenodd" d="M8 3a5 5 0 1 0 4.546 2.914.5.5 0 0 1 .908-.417A6 6 0 1 1 8 2v1z"/>
					<path d="M8 4.466V.534a.25.25 0 0 1 .41-.192l2.36 1.966c.12.1.12.284 0 .384L8.41 4.658A.25.25 0 0 1 8 4.466z"/>
				</svg>
			</button>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:row-header" match="*[key('datagrid:header-node', @xo:id)][not(ancestor::px:Association)]/@*">
		<th>
			<xsl:apply-templates mode="route:widget" select="current()">
				<xsl:with-param name="context" select="parent::xo:r"/>
			</xsl:apply-templates>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:row-footer" match="@*">
		<th style="text-align: right;">
			<xsl:apply-templates mode="route:widget" select="key('datagrid:row-footer-element',ancestor::px:Entity[1]/@xo:id)">
				<xsl:with-param name="context" select="parent::xo:r"/>
			</xsl:apply-templates>
		</th>
	</xsl:template>

	<!--<xsl:key name="reference" match="px:Association/@AssociationName" use="concat(ancestor::px:Entity[1]/data:rows/xo:r/@xo:id,'::body::association:ref::',.)"/>-->
	<!--<xsl:key name="reference" match="px:Association/px:Entity[1]/data:rows/xo:r" use="ancestor::px:Association[1]/@AssociationName"/>-->
	<xsl:key name="reference" match="px:Association/px:Entity[1]/data:rows/xo:r/@xo:id" use="concat(.,'::body::association:ref::',ancestor::px:Association[1]/@AssociationName)"/>

	<!--<xsl:template mode="datagrid:cell-content" match="@*">
		<xsl:param name="context">body</xsl:param>
		<xsl:param name="context" select="node-expected"/>
		-->
	<!--<xsl:apply-templates mode="widget" select="."/>-->
	<!--
		<xsl:apply-templates mode="datagrid:cell-content" select="key('reference',concat($context,'::',$context,'::',name(..),'::',../@Name))"/>
	</xsl:template>-->

	<xsl:template mode="datagrid:cell-content" match="*[key('datagrid:header-node',@xo:id)]/@*">
		<span>
			<xsl:attribute name="scope">col</xsl:attribute>
			<xsl:attribute name="ondblclick">this.toggle('contenteditable','')</xsl:attribute>
			<xsl:attribute name="xo-scope">
				<xsl:value-of select="../@xo:id"/>
			</xsl:attribute>
			<xsl:attribute name="xo-slot">headerText</xsl:attribute>
			<xsl:apply-templates mode="headerText" select="."/>
		</span>
	</xsl:template>
</xsl:stylesheet>