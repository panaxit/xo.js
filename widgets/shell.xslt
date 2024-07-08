<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:shell="http://panax.io/shell"
>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>

	<xsl:template match="/">
		<xsl:apply-templates mode="shell:widget" select="*/@xo:id"/>
	</xsl:template>

	<xsl:attribute-set name="shell:header-attributes-default">
		<xsl:attribute name="style"></xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="shell:header-attributes" use-attribute-sets="shell:header-attributes-default">
	</xsl:attribute-set>

	<xsl:attribute-set name="shell:nav-attributes-default">
		<xsl:attribute name="class">navbar-nav ml-auto</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="shell:nav-attributes" use-attribute-sets="shell:nav-attributes-default">
	</xsl:attribute-set>

	<xsl:template mode="shell:nav-attributes" match="@*|*"></xsl:template>

	<xsl:template mode="shell:widget" match="@*|*">
		<!--<script src="theme-toggle.js"></script>-->
		<section id="shell">
			<style>
				<![CDATA[
				body {
					overflow-y: hidden;
				}
				
				#shell > main { 
					overflow-y: scroll;
					height: calc(100vh - var(--header-height,0px) - var(--nav-height,0px) - var(--footer-height, 0px) - var(--body-margin, 0px));
				}
				
				#shell > header {
					height: var(--header-height,0px)
				}
				
				#shell > nav {
					height: var(--nav-height,0px)
				}
				
				#shell > header h1 {
					color: var(--color-title-header);
					margin-bottom: 0;
					margin-left: 5px;
					text-transform: capitalize;
				}
				
				#shell > footer {
					border-top: 2px solid silver !important;
					position: fixed;
					bottom: 0;
					height: var(--footer-height);
					background-color: var(--bg-white) !important;
					padding-top: 0 !important;
					/*z-index: var(--layer-4, 98);*/
					width: 100%;
					overflow: hidden;
					transition: 0.5s;
				}
				
				[disabled].menu-toggler {
					cursor: wait;
					display: block !important;
				}
				
				#shell > header {
					padding:.6rem 1.25rem 0px; 
					position: sticky;
					z-index: var(--layer-4)
				}
				
				#shell > nav {
					padding-left: 97px;
					z-index: var(--layer-3)
				}
				
				button[disabled] {
					opacity: .3;
				}
				
				nav menu svg.bi {
					width: 1em;
					height: 1em;
					vertical-align: -.125em;
					fill: currentcolor;
				}
				
				dialog, [role=alertdialog] {
					z-index: var(--zindex-modal, 1055);
				}
				]]>
			</style>
			<xsl:apply-templates mode="shell:header" select="."/>
			<xsl:apply-templates mode="shell:nav" select="."/>
			<xsl:apply-templates mode="shell:body" select="."/>
			<xsl:apply-templates mode="shell:footer" select="."/>
			<xsl:apply-templates mode="shell:aside" select="."/>
			<xsl:apply-templates mode="shell:extra" select="."/>
		</section>
	</xsl:template>

	<xsl:template mode="shell:header" match="@*|*">
		<xsl:element name="header" use-attribute-sets="shell:header-attributes">
			<svg xmlns="http://www.w3.org/2000/svg" class="d-none" id="symbols">
				<symbol id="check2" viewBox="0 0 16 16">
					<path d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z" />
				</symbol>
				<symbol id="circle-half" viewBox="0 0 16 16">
					<path d="M8 15A7 7 0 1 0 8 1v14zm0 1A8 8 0 1 1 8 0a8 8 0 0 1 0 16z" />
				</symbol>
				<symbol id="moon-stars-fill" viewBox="0 0 16 16">
					<path d="M6 .278a.768.768 0 0 1 .08.858 7.208 7.208 0 0 0-.878 3.46c0 4.021 3.278 7.277 7.318 7.277.527 0 1.04-.055 1.533-.16a.787.787 0 0 1 .81.316.733.733 0 0 1-.031.893A8.349 8.349 0 0 1 8.344 16C3.734 16 0 12.286 0 7.71 0 4.266 2.114 1.312 5.124.06A.752.752 0 0 1 6 .278z" />
					<path d="M10.794 3.148a.217.217 0 0 1 .412 0l.387 1.162c.173.518.579.924 1.097 1.097l1.162.387a.217.217 0 0 1 0 .412l-1.162.387a1.734 1.734 0 0 0-1.097 1.097l-.387 1.162a.217.217 0 0 1-.412 0l-.387-1.162A1.734 1.734 0 0 0 9.31 6.593l-1.162-.387a.217.217 0 0 1 0-.412l1.162-.387a1.734 1.734 0 0 0 1.097-1.097l.387-1.162zM13.863.099a.145.145 0 0 1 .274 0l.258.774c.115.346.386.617.732.732l.774.258a.145.145 0 0 1 0 .274l-.774.258a1.156 1.156 0 0 0-.732.732l-.258.774a.145.145 0 0 1-.274 0l-.258-.774a1.156 1.156 0 0 0-.732-.732l-.774-.258a.145.145 0 0 1 0-.274l.774-.258c.346-.115.617-.386.732-.732L13.863.1z" />
				</symbol>
				<symbol id="sun-fill" viewBox="0 0 16 16">
					<path d="M8 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM8 0a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 0zm0 13a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 13zm8-5a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2a.5.5 0 0 1 .5.5zM3 8a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2A.5.5 0 0 1 3 8zm10.657-5.657a.5.5 0 0 1 0 .707l-1.414 1.415a.5.5 0 1 1-.707-.708l1.414-1.414a.5.5 0 0 1 .707 0zm-9.193 9.193a.5.5 0 0 1 0 .707L3.05 13.657a.5.5 0 0 1-.707-.707l1.414-1.414a.5.5 0 0 1 .707 0zm9.193 2.121a.5.5 0 0 1-.707 0l-1.414-1.414a.5.5 0 0 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .707zM4.464 4.465a.5.5 0 0 1-.707 0L2.343 3.05a.5.5 0 1 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .708z" />
				</symbol>
				<symbol id="dashboard" viewBox="0 0 24 24">
					<rect x="3" y="3" width="7" height="7"></rect>
					<rect x="14" y="3" width="7" height="7"></rect>
					<rect x="14" y="14" width="7" height="7"></rect>
					<rect x="3" y="14" width="7" height="7"></rect>
				</symbol>
				<symbol id="submenu-item-1" viewBox="0 0 16 16">
					<path d="M5 4a.5.5 0 0 0 0 1h6a.5.5 0 0 0 0-1H5zm-.5 2.5A.5.5 0 0 1 5 6h6a.5.5 0 0 1 0 1H5a.5.5 0 0 1-.5-.5zM5 8a.5.5 0 0 0 0 1h6a.5.5 0 0 0 0-1H5zm0 2a.5.5 0 0 0 0 1h3a.5.5 0 0 0 0-1H5z"></path>
					<path d="M2 2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V2zm10-1H4a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V2a1 1 0 0 0-1-1z"></path>
				</symbol>
				<symbol id="submenu-item-2" viewBox="0 0 16 16">
					<path d="M8.235 1.559a.5.5 0 0 0-.47 0l-7.5 4a.5.5 0 0 0 0 .882L3.188 8 .264 9.559a.5.5 0 0 0 0 .882l7.5 4a.5.5 0 0 0 .47 0l7.5-4a.5.5 0 0 0 0-.882L12.813 8l2.922-1.559a.5.5 0 0 0 0-.882l-7.5-4zm3.515 7.008L14.438 10 8 13.433 1.562 10 4.25 8.567l3.515 1.874a.5.5 0 0 0 .47 0l3.515-1.874zM8 9.433 1.562 6 8 2.567 14.438 6 8 9.433z"></path>
				</symbol>
				<symbol id="user" viewBox="0 0 16 16">
					<path d="M3 14s-1 0-1-1 1-4 6-4 6 3 6 4-1 1-1 1H3zm5-6a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"/>
				</symbol>
				<symbol id="active-theme">
					<use>
						<xsl:attribute name="href">#moon-stars-fill</xsl:attribute>
					</use>
				</symbol>
				<symbol id="profile" viewBox="0 0 16 16">
					<path d="M2 2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V2zm4.5 0a.5.5 0 0 0 0 1h3a.5.5 0 0 0 0-1h-3zM8 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm5 2.755C12.146 12.825 10.623 12 8 12s-4.146.826-5 1.755V14a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1v-.245z"/>
				</symbol>
				<symbol id="logout" viewBox="0 0 16 16">
					<path d="M1.5 15a.5.5 0 0 0 0 1h13a.5.5 0 0 0 0-1H13V2.5A1.5 1.5 0 0 0 11.5 1H11V.5a.5.5 0 0 0-.57-.495l-7 1A.5.5 0 0 0 3 1.5V15H1.5zM11 2h.5a.5.5 0 0 1 .5.5V15h-1V2zm-2.5 8c-.276 0-.5-.448-.5-1s.224-1 .5-1 .5.448.5 1-.224 1-.5 1z"/>
				</symbol>
			</svg>
			<style>
				<![CDATA[
				.navbar-nav li:hover > .dropdown-menu {
					display: block;
				}
				
				.dropdown {
					position:relative;
				}
				
				.dropdown-menu .dropdown > .dropdown-menu {
					top: 0;
					left: 100%;
					margin-top:-6px;
				}

				a.dropdown-toggle:hover:after {
					text-decoration: underline;
					transform: rotate(-90deg);
				} 
				
				.menu-toggler {
					display: block !important;
				}
				
				main {
					padding-bottom: 3rem;
				}
				
				main:after {
					content: '';
					position: fixed;
					bottom: var(--footer-height);
					left: 0;
					width: 100%;
					height: 40px;
					background: linear-gradient(to bottom, transparent, rgba(0, 0, 0, 0.6));
					pointer-events: none;
					z-index: 1000;
				}
				
				dialog {
					z-index: 1055
				}
				
				button.form-control {
					border: var(--bs-border-width) solid var(--bs-border-color);
				}
			]]>
			</style>
			<nav class="navbar navbar-expand-md fixed-top">
				<div class="container-fluid">
					<button class="menu-toggler navbar-toggler p-0 border-0" type="button" id="menu" aria-label="Toggle menu" xo-scope="shell" data-bs-toggle="offcanvas" data-bs-target="#aside_menu" aria-controls="aside_menu">
						<span class="navbar-toggler-icon" xo-scope="shell"></span>
					</button>

					<a class="navbar-brand" href="./#" title="">
						<xsl:apply-templates mode="shell:nav-brand" select="."/>
					</a>
					<button class="navbar-toggler p-0 border-0" type="button" id="navbarSideCollapse" aria-label="Toggle navigation" data-bs-target="#offcanvasNavbar" data-bs-toggle="offcanvas">
						<span class="navbar-toggler-icon"></span>
					</button>
					<div class="offcanvas offcanvas-end" tabindex="-1" id="offcanvasNavbar" aria-labelledby="offcanvasNavbarLabel" aria-modal="true" role="dialog">
						<div class="offcanvas-header">
							<h5 class="offcanvas-title" id="offcanvasNavbarLabel">Opciones</h5>
							<button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
						</div>
						<div class="offcanvas-body">
							<h2 xo-source="active" xo-stylesheet="title.xslt"></h2>
							<menu class="navbar-nav justify-content-end flex-grow-1 pe-3 m-0" xo-source="#menu" xo-static="@class"/>
						</div>
					</div>
				</div>
			</nav>
			<!--
			<div class="navbar-collapse collapse">
				<div style="white-space:nowrap">
					<a href="/" title="Ir a la página principal" style="text-decoration:none;">
						<xsl:apply-templates mode="shell:nav-brand" select="."/>
					</a>
				</div>
				<div class="search navbar-left">
					<xsl:apply-templates mode="shell:nav-title" select="."/>
				</div>
				<div class="">
					<xsl:element name="nav" use-attribute-sets="shell:nav-attributes">
						<xsl:apply-templates mode="shell:header-nav" select="."/>
					</xsl:element>
				</div>
			</div>
			<xsl:apply-templates mode="shell:search" select="."/>-->
		</xsl:element>
	</xsl:template>

	<xsl:template mode="shell:nav" match="@*|*">
		<nav class="navbar navbar-expand-lg bg-primary position-static">
			<xsl:apply-templates mode="shell:nav-attributes" select="."/>
			<div class="offcanvas offcanvas-end" tabindex="-1" id="offcanvasNavbar" aria-labelledby="offcanvasNavbarLabel" aria-modal="true" role="dialog">
				<div class="offcanvas-header">
					<h5 class="offcanvas-title" id="offcanvasNavbarLabel">Offcanvas</h5>
					<button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
				</div>
				<div class="offcanvas-body">
					<xsl:apply-templates mode="shell:nav-content" select="."/>
				</div>
			</div>
		</nav>
	</xsl:template>

	<xsl:template mode="shell:header-nav" match="@*|*">
		<li class="nav-item dropdown">
			<a class="nav-icon dropdown-toggle d-inline-block d-sm-none" href="#" data-toggle="dropdown">
				<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-settings align-middle">
					<circle cx="12" cy="12" r="3"></circle>
					<path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
				</svg>
			</a>
			<span xo-source="#menu">
			</span>
		</li>
	</xsl:template>

	<xsl:template mode="shell:search" match="@*|*">
		<xsl:element name="search" use-attribute-sets="shell:nav-attributes">
			<xsl:apply-templates mode="shell:search" select="."/>
		</xsl:element>
	</xsl:template>

	<xsl:template mode="shell:body" match="@*|*">
		<main>
			<xsl:apply-templates mode="shell:body-content" select="."/>
		</main>
	</xsl:template>

	<xsl:template mode="shell:search" match="@*|*">
		<search>
			Search
		</search>
	</xsl:template>

	<xsl:template mode="shell:aside" match="@*|*">
		<aside class="offcanvas offcanvas-start sidebar" tabindex="-1" id="aside_menu" aria-labelledby="Modules">
			<div class="offcanvas-header">
				<button class="menu-toggler navbar-toggler p-0 border-0" type="button" aria-label="Toggle menu" xo-scope="shell" data-bs-dismiss="offcanvas">
					<span class="navbar-toggler-icon" xo-scope="shell"></span>
				</button>
				<a class="navbar-brand" href="#" title="">
					<xsl:apply-templates mode="shell:nav-brand" select="."/>
				</a>
				<h5 class="offcanvas-title d-flex justify-content-center flex-grow-1" id="offcanvasExampleLabel">Menú</h5>
				<button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
			</div>
			<div class="offcanvas-body" xo-source="#sitemap">
				<div>...</div>
			</div>
		</aside>
	</xsl:template>

	<xsl:template mode="shell:footer" match="@*|*">
		<footer class="d-flex p-3">
			<xsl:apply-templates mode="shell:footer-content" select="."/>
		</footer>
	</xsl:template>

	<xsl:template mode="shell:footer-content" match="@*|*">
	</xsl:template>

	<xsl:template mode="shell:extra" match="@*|*">
	</xsl:template>

	<xsl:template mode="shell:nav-brand" match="@*|*"/>
	<xsl:template mode="shell:nav-content" match="@*|*"/>
</xsl:stylesheet>