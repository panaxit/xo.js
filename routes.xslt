<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:state="http://panax.io/state"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:control="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:layout_datagrid="http://panax.io/layout"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:data="http://panax.io/source"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:meta="http://panax.io/metadata"
  xmlns:custom="http://panax.io/custom"
  xmlns:px="http://panax.io/entity"
  xmlns:route="http://panax.io/routes"
  xmlns:globalization="http://xover.dev/globalization"
  xmlns:menu="http://xover.dev/widgets/menu"
  exclude-result-prefixes="xo state xsl meta custom data route"
>
	<xsl:param name="globalization:system">#globalization-system</xsl:param>
	<xsl:key name="hidden" match="node-expected" use="@xo:id"/>
	<xsl:template mode="route:widget-attributes" match="*|@*" priority="-1"/>

	<xsl:template mode="route:widget" match="px:Route/@*">
		<xsl:param name="xo:context" select="node-expected"/>
		<xsl:variable name="route" select="current()"/>
		<a href="#">
			<xsl:apply-templates mode="route:link-attribute" select="."/>
			<xsl:apply-templates mode="route:widget-attributes" select="."/>
			<xsl:apply-templates mode="route:widget-button" select="$route">
				<xsl:with-param name="xo:context" select="$xo:context"/>
			</xsl:apply-templates>
		</a>
	</xsl:template>

	<xsl:template name="route:link-attribute" mode="route:link-attribute" match="px:Route/@*" priority="-1">
		<xsl:variable name="route" select="current()"/>
		<xsl:attribute name="href">
			<xsl:value-of select="concat('#',ancestor-or-self::px:Entity[1]/@Schema,'/',ancestor-or-self::px:Entity[1]/@Name,'~',$route/../@Method)"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template mode="route:link-attribute" match="px:Route[@Method='edit']/@*" priority="-1">
		<xsl:call-template name="route:link-attribute"/>
		<!--<xsl:attribute name="href">javascript:void(0)</xsl:attribute>-->
		<xsl:attribute name="onclick">px.editSelectedOption(this)</xsl:attribute>
	</xsl:template>

	<xsl:template mode="route:link-attribute" match="px:Route[@Method='delete']/@*" priority="-1">
		<xsl:attribute name="onclick">event.preventDefault(); event.stopPropagation();</xsl:attribute>
	</xsl:template>

	<xsl:template mode="route:link-attribute" match="px:Route[@Method='addToCart']/@*" priority="-1">
		<xsl:attribute name="onclick">cart.add(scope)</xsl:attribute>
	</xsl:template>

	<xsl:template mode="route:link-attribute" match="px:Route[@Method='facturar']/@*" priority="-1">
		<xsl:attribute name="onclick">ventas.generarFactura(scope)</xsl:attribute>
	</xsl:template>

	<xsl:template mode="route:item-icon" match="px:Route[@Method='add']/@*" priority="-1">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-plus-circle" viewBox="0 0 16 16">
			<path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
			<path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"/>
		</svg>
	</xsl:template>

	<xsl:template mode="route:item-icon" match="px:Route[@Method='edit']/@*" priority="-1">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-box-arrow-in-right" viewBox="0 0 16 16">
			<path fill-rule="evenodd" d="M6 3.5a.5.5 0 0 1 .5-.5h8a.5.5 0 0 1 .5.5v9a.5.5 0 0 1-.5.5h-8a.5.5 0 0 1-.5-.5v-2a.5.5 0 0 0-1 0v2A1.5 1.5 0 0 0 6.5 14h8a1.5 1.5 0 0 0 1.5-1.5v-9A1.5 1.5 0 0 0 14.5 2h-8A1.5 1.5 0 0 0 5 3.5v2a.5.5 0 0 0 1 0v-2z"/>
			<path fill-rule="evenodd" d="M11.854 8.354a.5.5 0 0 0 0-.708l-3-3a.5.5 0 1 0-.708.708L10.293 7.5H1.5a.5.5 0 0 0 0 1h8.793l-2.147 2.146a.5.5 0 0 0 .708.708l3-3z"/>
		</svg>
	</xsl:template>

	<xsl:template mode="route:item-icon" match="px:Route[@Method='delete']/@*" priority="-1">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-trash" viewBox="0 0 16 16">
			<path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
			<path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
		</svg>
	</xsl:template>

	<xsl:template mode="route:item-icon" match="px:Route[@Method='facturar']/@*" priority="-1">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-filetype-xml" viewBox="0 0 16 16">
			<path fill-rule="evenodd" d="M14 4.5V14a2 2 0 0 1-2 2v-1a1 1 0 0 0 1-1V4.5h-2A1.5 1.5 0 0 1 9.5 3V1H4a1 1 0 0 0-1 1v9H2V2a2 2 0 0 1 2-2h5.5L14 4.5ZM3.527 11.85h-.893l-.823 1.439h-.036L.943 11.85H.012l1.227 1.983L0 15.85h.861l.853-1.415h.035l.85 1.415h.908l-1.254-1.992 1.274-2.007Zm.954 3.999v-2.66h.038l.952 2.159h.516l.946-2.16h.038v2.661h.715V11.85h-.8l-1.14 2.596h-.025L4.58 11.85h-.806v3.999h.706Zm4.71-.674h1.696v.674H8.4V11.85h.791v3.325Z"/>
		</svg>
	</xsl:template>

	<xsl:template mode="route:item-icon" match="px:Route[@Method='addToCart']/@*" priority="-1">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-cart" viewBox="0 0 16 16">
			<path d="M0 1.5A.5.5 0 0 1 .5 1H2a.5.5 0 0 1 .485.379L2.89 3H14.5a.5.5 0 0 1 .491.592l-1.5 8A.5.5 0 0 1 13 12H4a.5.5 0 0 1-.491-.408L2.01 3.607 1.61 2H.5a.5.5 0 0 1-.5-.5zM3.102 4l1.313 7h8.17l1.313-7H3.102zM5 12a2 2 0 1 0 0 4 2 2 0 0 0 0-4zm7 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4zm-7 1a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm7 0a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>
		</svg>
	</xsl:template>

	<xsl:template mode="route:item-icon" match="px:Association[@DataType='junctionTable']/px:Entity/px:Routes/px:Route[@Method='delete']/@*" priority="-1">
		<xsl:param name="xo:context" select="node-expected"/>
		<xsl:for-each select="$xo:context[self::px:Entity or self::data:rows or self::xo:r]">
			<xsl:if test="@meta:id!=''">
				<xsl:choose>
					<xsl:when test="@state:delete='true'">
						<xsl:attribute name="onclick">scope.removeAttribute('state:delete'); event.preventDefault();</xsl:attribute>
						<xsl:attribute name="class">btn btn-sm btn-outline-primary</xsl:attribute>
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-square" viewBox="0 0 16 16">
							<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"/>
						</svg>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="onclick">scope.setAttribute('state:delete',true); event.preventDefault();</xsl:attribute>
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-check-square" viewBox="0 0 16 16">
							<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"/>
							<path d="M10.97 4.97a.75.75 0 0 1 1.071 1.05l-3.992 4.99a.75.75 0 0 1-1.08.02L4.324 8.384a.75.75 0 1 1 1.06-1.06l2.094 2.093 3.473-4.425a.235.235 0 0 1 .02-.022z"/>
						</svg>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="route:widget-button" match="px:Route[@Method='edit']/@*" priority="-1">
		<xsl:param name="xo:context" select="node-expected"/>
		<xsl:for-each select="$xo:context[self::px:Entity or self::data:rows or self::xo:r]">
			<button type="button" class="btn btn-sm btn-primary">
				<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-box-arrow-in-right" viewBox="0 0 16 16">
					<path fill-rule="evenodd" d="M6 3.5a.5.5 0 0 1 .5-.5h8a.5.5 0 0 1 .5.5v9a.5.5 0 0 1-.5.5h-8a.5.5 0 0 1-.5-.5v-2a.5.5 0 0 0-1 0v2A1.5 1.5 0 0 0 6.5 14h8a1.5 1.5 0 0 0 1.5-1.5v-9A1.5 1.5 0 0 0 14.5 2h-8A1.5 1.5 0 0 0 5 3.5v2a.5.5 0 0 0 1 0v-2z"/>
					<path fill-rule="evenodd" d="M11.854 8.354a.5.5 0 0 0 0-.708l-3-3a.5.5 0 1 0-.708.708L10.293 7.5H1.5a.5.5 0 0 0 0 1h8.793l-2.147 2.146a.5.5 0 0 0 .708.708l3-3z"/>
				</svg>
			</button>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="route:widget-button" match="px:Route[@Method='add']/@*" priority="-1">
		<xsl:param name="xo:context" select="node-expected"/>
		<xsl:variable name="route" select="current()"/>
		<xsl:for-each select="$xo:context[self::px:Entity or self::data:rows or self::xo:r]">
			<xsl:choose>
				<xsl:when test="parent::px:Association">
					<button type="button" class="btn btn-success btn-sm" onclick="event.preventDefault(); px.navigateTo(parentNode.getAttribute('href'),'{ancestor-or-self::*[@meta:type='entity'][1]/data:rows/@xo:id}')" xo-scope="{data:rows/@xo:id}">Agregar registro</button>
				</xsl:when>
				<xsl:otherwise>
					<button type="button" class="btn btn-success" onclick="event.preventDefault(); px.navigateTo(parentNode.getAttribute('href'),'{ancestor-or-self::*[@meta:type='entity'][1]/data:rows/@xo:id}')" xo-scope="{data:rows/@xo:id}">Nuevo registro</button>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="route:widget-button" match="px:Route[@Method='delete']/@*" priority="-1">
		<xsl:param name="xo:context" select="node-expected"/>
		<xsl:variable name="route" select="current()"/>
		<xsl:for-each select="$xo:context[self::px:Entity or self::data:rows or self::xo:r]">
			<button type="button" class="btn btn-sm btn-danger" xo-scope="{ancestor-or-self::*[1]/@xo:id}" xo-slot="state:delete" onclick="scope.set(true); event.preventDefault();">
				<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-trash" viewBox="0 0 16 16">
					<path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
					<path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
				</svg>
			</button>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="route:widget-button" match="px:Association[@DataType='junctionTable']/px:Entity/px:Routes/px:Route[@Method='add']/@*" priority="-1">
		<xsl:param name="xo:context" select="node-expected"/>
		<xsl:variable name="route" select="current()"/>
		<xsl:for-each select="$xo:context[self::px:Entity or self::data:rows or self::xo:r]">
			<xsl:if test="not(@meta:id!='')">
				<button type="button" class="btn btn-sm btn-primary" xo-scope="inherit" xo-slot="state:checked" onclick="scope.set(true); event.preventDefault();">
					<xsl:choose>
						<xsl:when test="@state:checked='true'">
							<xsl:attribute name="onclick">scope.remove(); event.preventDefault();</xsl:attribute>
							<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-check-square" viewBox="0 0 16 16">
								<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"/>
								<path d="M10.97 4.97a.75.75 0 0 1 1.071 1.05l-3.992 4.99a.75.75 0 0 1-1.08.02L4.324 8.384a.75.75 0 1 1 1.06-1.06l2.094 2.093 3.473-4.425a.235.235 0 0 1 .02-.022z"/>
							</svg>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">btn btn-sm btn-outline-primary</xsl:attribute>
							<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-square" viewBox="0 0 16 16">
								<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"/>
							</svg>
						</xsl:otherwise>
					</xsl:choose>
				</button>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="route:widget-button" match="px:Association[@DataType='junctionTable']/px:Entity/px:Record/px:Association/px:Entity/px:Routes/px:Route[@Method='edit']/@*" priority="-1">
		<xsl:param name="xo:context" select="node-expected"/>
		<xsl:variable name="route" select="current()"/>
		<xsl:if test="not(@meta:id!='')">
			<button type="button" class="btn btn-sm btn-primary" xo-scope="inherit" xo-slot="state:checked" onclick="scope.set(true); event.preventDefault();">
				<xsl:choose>
					<xsl:when test="@state:checked='true'">
						<xsl:attribute name="onclick">scope.remove(); event.preventDefault();</xsl:attribute>
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-check-square" viewBox="0 0 16 16">
							<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"/>
							<path d="M10.97 4.97a.75.75 0 0 1 1.071 1.05l-3.992 4.99a.75.75 0 0 1-1.08.02L4.324 8.384a.75.75 0 1 1 1.06-1.06l2.094 2.093 3.473-4.425a.235.235 0 0 1 .02-.022z"/>
						</svg>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="class">btn btn-sm btn-outline-primary</xsl:attribute>
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-square" viewBox="0 0 16 16">
							<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"/>
						</svg>
					</xsl:otherwise>
				</xsl:choose>
			</button>
		</xsl:if>
	</xsl:template>

	<xsl:template mode="route:widget-button" match="px:Route[key('hidden',@xo:id)]/@*" priority="-1">
	</xsl:template>

	<xsl:template mode="route:widget-button" match="px:Route[ancestor-or-self::*/@mode='readonly']/@*" priority="-1">
		<xsl:comment>
			La ruta <xsl:value-of select="../@Method"/> no está disponible
		</xsl:comment>
	</xsl:template>

	<xsl:template mode="label" match="px:Route/@*" priority="-1">
		label
	</xsl:template>

	<xsl:template mode="menu:item-link-attribute" match="px:Route/@*">
		<xsl:apply-templates mode="route:link-attribute" select="."/>
	</xsl:template>

	<xsl:template mode="menu:item-icon" match="px:Route/@*" priority="-1">
		<xsl:apply-templates mode="route:item-icon" select="."/>
	</xsl:template>

	<xsl:template mode="title" match="px:Route/@Method">
		<xsl:apply-templates mode="globalization:system" select="."/>
	</xsl:template>
</xsl:stylesheet>