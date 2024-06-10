<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xo="http://panax.io/xover"
xmlns:menu="http://panax.io/widget/menu"
xmlns="http://www.w3.org/1999/xhtml"
>
	<xsl:template match="/">
		<xsl:apply-templates mode="menu:widget"></xsl:apply-templates>
	</xsl:template>

	<xsl:attribute-set name="menu:dropdown">
		<xsl:attribute name="class">dropdown-menu</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="menu:icon-badge">
		<xsl:attribute name="class">position-absolute top-0 translate-middle badge rounded-pill bg-danger</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="menu:item">
		<xsl:attribute name="class">position-absolute top-0 translate-middle badge rounded-pill bg-danger</xsl:attribute>
	</xsl:attribute-set>

	<xsl:template match="@*|*" mode="menu:widget">
		<xsl:param name="items" select="ancestor-or-self::*[1]/*"/>
		<link rel="stylesheet" href="menu.css" />
		<menu xo:use-attribute-sets="menu:dropdown">
			<xsl:apply-templates mode="menu:item" select="$items"/>
		</menu>
	</xsl:template>

	<xsl:template match="@*|*" mode="menu:icon-badge"/>

	<xsl:template match="messages[item]" mode="menu:icon-badge">
		<span xo:use-attribute-sets="menu:icon-badge">
			<xsl:value-of select="count(item)"/>
			<span class="visually-hidden">unread messages</span>
		</span>
	</xsl:template>

	<xsl:template match="@*|*" mode="menu:item-icon" priority="-1"/>

	<xsl:template match="@*|*" mode="menu:item-link-attribute" priority="-1"/>

	<xsl:template match="*[@href]|*[@href]/@*" mode="menu:item-link-attribute">
		<xsl:copy-of select="ancestor-or-self::*[1]/@href"/>
	</xsl:template>

	<xsl:template mode="menu:item-attributes" match="@*|*"></xsl:template>

	<xsl:template mode="menu:icon-attributes" match="@*|*"/>

	<xsl:template mode="menu:icon-attributes" match="*[contains(@class,'btn')]">
		<xsl:attribute name="fill">none</xsl:attribute>
		<xsl:attribute name="stroke">currentColor</xsl:attribute>
		<xsl:attribute name="stroke-width">2</xsl:attribute>
		<xsl:attribute name="stroke-linecap">round</xsl:attribute>
		<xsl:attribute name="stroke-linejoin">round</xsl:attribute>
		<xsl:attribute name="class">feather feather-grid</xsl:attribute>
	</xsl:template>

	<xsl:template match="*[@icon]" mode="menu:item-icon">
		<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" class="bi bi-file-text text-primary" viewBox="0 0 16 16" style="margin-right: 5px">
			<xsl:apply-templates mode="menu:icon-attributes" select="."/>
			<use href="#{@icon}"/>
		</svg>
	</xsl:template>

	<xsl:template match="@*|*" mode="menu:item-title">
		<slot>
			<xsl:choose>
				<xsl:when test="ancestor-or-self::*[1]/@title">
					<xsl:apply-templates select="ancestor-or-self::*[1]/@title"/>
				</xsl:when>
				<xsl:when test="not(ancestor-or-self::*[1]/@icon)">
					<xsl:apply-templates mode="title" select="."/>
				</xsl:when>
			</xsl:choose>
		</slot>
	</xsl:template>

	<xsl:template match="@*|*" mode="menu:item">
		<xsl:variable name="dropdown">
			<xsl:if test="*">dropdown</xsl:if>
		</xsl:variable>
		<xsl:variable name="class">
			<xsl:choose>
				<xsl:when test="ancestor-or-self::*[1]/@class">
					<xsl:value-of select="ancestor-or-self::*[1]/@class"/>
				</xsl:when>
				<xsl:otherwise>dropdown-item</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<li class="{$dropdown} {local-name()}-menu">
			<xsl:apply-templates mode="menu:item-attributes" select="."/>
			<a class="{$dropdown}-toggle {$class}" href="#" role="button">
				<xsl:if test="$dropdown!=''">
					<xsl:attribute name="aria-expanded">false</xsl:attribute>
					<xsl:attribute name="data-bs-toggle">dropdown</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates mode="menu:item-link-attribute" select="."/>
				<xsl:apply-templates mode="menu:item-icon" select="."/>
				<xsl:apply-templates mode="menu:icon-badge" select="."/>
				<xsl:apply-templates mode="menu:item-title" select="."/>
			</a>
			<xsl:if test="$dropdown!=''">
				<xsl:apply-templates mode="menu:widget" select="."/>
			</xsl:if>
		</li>
	</xsl:template>

	<xsl:template match="_" mode="menu:item">
		<li class="nav-item py-2 py-lg-1 col-12 col-lg-auto">
			<div class="vr d-none d-lg-flex h-100 mx-lg-2 text-white"></div>
			<hr class="d-lg-none my-2 text-white-50"/>
		</li>
	</xsl:template>

</xsl:stylesheet>