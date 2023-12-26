<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:shell="http://panax.io/shell"
xmlns:state="http://panax.io/state"
xmlns:globalization="http://xover.dev/globalization"
xmlns:xo="http://panax.io/xover"
exclude-result-prefixes="#default session sitemap shell state"
>
	<xsl:import href="../keys.xslt"/>
	<xsl:import href="shell.xslt"/>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>
	<xsl:param name="globalization:headerText">#globalization</xsl:param>
	<xsl:key name="item" match="dummy" use="'#any'"/>
	<xsl:key name="menu-item" match="dummy" use="'#any'"/>

	<xsl:template match="text()"/>

	<xsl:template match="/">
		<xsl:apply-templates mode="sitemap:widget" select="*/@xo:id"/>
	</xsl:template>

	<xsl:template mode="sitemap:widget" match="@*">
		<div>	
			<style>
				<![CDATA[
.menu_toggle {
    color: var(--menu-toggler,currentColor) !important;
    cursor: pointer
}

aside.sidebar li {
    font-size: 1rem;
    display: block;
}

aside.sidebar a {
    padding: 8px 8px 8px 8px;
    transition: 0.3s;
}

aside.sidebar ul {
	height:100%; 
	overflow-y:scroll;
	overflow-x: clip;
}

aside * {
    scrollbar-width: thin;
    scrollbar-color: rgba(50, 62, 72, 0.9);
}

/* Works on Chrome, Edge, and Safari */
/*

aside *::-webkit-scrollbar {
    width: 12px;
}

aside *::-webkit-scrollbar-track {
    background: rgba(50, 62, 72, 0.9);
}

aside *::-webkit-scrollbar-thumb {
    background-color: var(--scrollbar-bg-color);
    border-radius: 20px;
    border: 3px solid rgba(50, 62, 72, 0.9);
}

aside *::-webkit-scrollbar-button {
    background-color: #333; 
}*/

aside a {
    text-decoration: none;
    color: #818181;
    transition: 0.3s;
}

aside li {
    padding: 8px 1px 0px 0px;
    font-size: 1rem;
    display: block;
    transition: 0.3s;
}

aside .menu li.sidebar-item a:before {
    background-color: var(--bullet-color, silver);
    bottom: auto;
    content: "";
    height: 8px;
    left: .4rem;
    margin-top: 10px;
    position: absolute;
    right: auto;
    width: 8px;
    z-index: 1;
    border-radius: 50%;
}

aside .menu li.sidebar-item a:after {
    border-left: 1px solid var(--bullet-color, silver);
    bottom: 0;
    content: "";
    left: .6rem;
    position: absolute;
    top: 0;
}

aside .menu li.sidebar-item li {
    border-right: 5px solid var(--border-right-sidebar);
}

aside .menu ul {
    position: relative;
    margin-left: 25px;
}

aside li.sidebar-item.menu:has(:scope > ul:not(.collapse)) a {
    border-right: 5px solid var(--border-right-sidebar);
}

aside [aria-expanded=true]:before, aside [data-toggle=collapse]:not(.collapsed):before {
    -webkit-transform: rotate( -45deg );
    transform: rotate( -45deg );
    top: 1.4rem;
}

aside [data-toggle=collapse]:before {
    content: " ";
    border: solid;
    border-width: 0 .1rem .1rem 0;
    display: inline-block;
    padding: 2px;
    -webkit-transform: rotate(45deg);
    transform: rotate(45deg);
    position: absolute;
    top: 1.2rem;
    right: 1.25rem;
    -webkit-transition: all .2s ease-out;
    transition: all .2s ease-out;
}

table.datagrid tbody table.datagrid thead {
    display: none
}

.sitemap_collapsed .menu_toggle {
    color: silver
}

.sidebar-brand {
    padding-right: 8px;
    white-space: nowrap;
}

/*.sidebar a:hover {
    color: #f1f1f1;
}*/

.sidebar .closebtn {
    position: absolute;
    top: 0;
    right: 25px;
    font-size: 36px;
    margin-left: 50px;
}

@media screen and (max-height: 450px) {
    .sidebar {
        padding-top: 15px;
    }

    .sidebar a {
        font-size: 18px;
    }
}

/*
.sidebar, .sidebar-content, .sidebar-link, a.sidebar-link {
    background-color: var(--bg-sidebar, var(--bg-primary-dark, #2A3F54)) !important;
}*/

.sidebar a.sidebar-link {
    display: block;
}

.sidebar-nav {
    padding-bottom: 3.5rem;
    padding-left: 0;
    list-style: none;
}

li.sidebar-item {
    position: relative;
    white-space: nowrap;
    /*overflow-x: clip;*/
    text-overflow: ellipsis;
}

aside {
    overflow-x: clip;
    text-overflow: ellipsis;
}

aside .offcanvas-header {
    border-bottom: 1pt solid;
}

aside.offcanvas > div {
    padding-block: .5rem;
}

/*li.sidebar-item.menu > a {
    color: white
}*/

.sidebar-link i, .sidebar-link svg, a.sidebar-link i, a.sidebar-link svg {
    margin-right: .75rem;
    /*color: #fff;*/
}

.sidebar-dropdown .sidebar-link {
    /*color: #adb5bd;
    background: #313b4c;*/
    font-weight: 400;
    padding-right: 15px;
    padding-left: 1.5rem;
}

.sidebar .offcanvas-body {
    padding-right: .2rem;
}

.sidebar ul {
    margin: 0; 
}
]]>
			</style>
			<ul class="sidebar-nav sidebar-dropdown">
				<xsl:apply-templates mode="sitemap:body" select="ancestor-or-self::*[1]/*"/>
			</ul>
		</div>
	</xsl:template>

	<xsl:template mode="sitemap:body" match="key('item','#any')">
		<xsl:variable name="type">
			<xsl:if test="key('menu-item',@xo:id)">menu</xsl:if>
		</xsl:variable>
		<xsl:variable name="collapsed_status">
			<xsl:if test="1=1">collapsed</xsl:if>
		</xsl:variable>
		<li class="sidebar-item {$type}">
			<a href="javascript:void(0)" class="sidebar-link {$collapsed_status}" onclick="classList.toggle('collapsed'); parentElement.querySelector(':scope > ul').classList.toggle('show')">
				<xsl:apply-templates mode="sitemap:target-href" select="."/>
				<xsl:if test="$type='menu'">
					<xsl:attribute name="data-toggle">collapse</xsl:attribute>
					<!--<xsl:attribute name="onclick">
					<xsl:apply-templates mode="sitemap:script" select="."/><![CDATA[;/*toggle_sidebar();*/]]>
				</xsl:attribute>-->
					<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-layout align-middle">
						<rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
						<line x1="3" y1="9" x2="21" y2="9"></line>
						<line x1="9" y1="21" x2="9" y2="9"></line>
					</svg>
				</xsl:if>
				<xsl:apply-templates mode="globalization:headerText" select="@title"/>
			</a>
			<xsl:variable name="show_status">
				<xsl:if test="$collapsed_status!='collapsed'">show</xsl:if>
			</xsl:variable>
			<ul id="{generate-id()}" class="sidebar-dropdown list-unstyled collapse {$show_status}">
				<xsl:apply-templates mode="sitemap:body" select="ancestor-or-self::*[1]/*"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template mode="sitemap:footer" match="@*">
	</xsl:template>

	<xsl:template mode="sitemap:header" match="@*">
		<span class="sidebar-brand mt-1 d-flex filter-white" style="padding-left: 15pt; padding-top: .5rem; padding-bottom: .5rem;">
			<span class="menu_toggle" style="font-size:30px; color:white;" onclick="toggleSidebar()">
				&#9776;
			</span>
			<a href="javascript:void(0)" onclick="toggleSidebar()" style="margin:0;padding:0;">
				<xsl:apply-templates mode="sitemap:brand" select="."/>
			</a>
		</span>
	</xsl:template>

	<xsl:template mode="sitemap:target-href" match="*"/>

	<xsl:template mode="sitemap:target-href" match="*[@catalogName]">
		<xsl:attribute name="href">
			<xsl:value-of select="concat('#',translate(substring-before(@catalogName,'].['),'[]',''),'/',translate(substring-after(@catalogName,'].['),'[]',''),'~',@mode)"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template mode="sitemap:target-href" match="*[@target]">
		<xsl:attribute name="href">
			<xsl:value-of select="@target"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template mode="sitemap:brand" match="@*">
		<xsl:apply-templates mode="shell:nav-brand" select="."/>
	</xsl:template>
</xsl:stylesheet>
