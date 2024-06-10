<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:widget="http://panax.io/widget"
xmlns:treeView="http://panax.io/widget/treeView"
xmlns:data="http://panax.io/source"
xmlns:state="http://panax.io/state"
xmlns:text="http://panax.io/state/text"
xmlns:js="http://panax.io/languages/javascript"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>
	<xsl:key name="Menu" match="Folder" use="@xo:id"/>
	<xsl:key name="Menu" match="Item[not(@IsFile='1')]" use="@xo:id"/>
	<xsl:key name="File" match="Item[@IsFile='1']" use="@xo:id"/>

	<xsl:key name="treeView:active" match="xo:f[not(@state:active-item)]/Folder" use="@xo:id"/>
	<xsl:key name="treeView:active" match="xo:f" use="@state:active-item"/>

	<xsl:key name="treeView:expanded" match="*[@state:expanded='true']" use="@xo:id"/>
	<xsl:key name="treeView:widget" match="node-expected" use="@xo:id"/>
	<xsl:template mode="treeView:header" match="@*"/>
	<xsl:template mode="treeView:footer" match="@*"/>

	<xsl:template mode="treeView:item-legend" match="@*">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template mode="treeView:item-legend" match="@*[contains(.,'?name=')]">
		<xsl:value-of select="substring-before(substring-after(.,'?name='),'&amp;')"/>
	</xsl:template>

	<xsl:template mode="treeView:widget" match="@*">
		<xsl:param name="schema" select="nodeset-expected"/>
		<xsl:param name="context" select="nodeset-expected"/>
		<xsl:param name="layout" select="nodeset-expected"/>
		<style>
			<![CDATA[
			/*tree*/
			.tree .option-text {
				white-space: nowrap;
			}
							
			.tree a {
				text-decoration: none
			}

			ul.tree, ul.tree ul {
				list-style:none;
				margin:0;
				padding:0;
				font-family: Arial, sans-serif;
				font-size: 12px;
			}

			ul.tree a:before {
				content: '';
				height: 30px;
				position: absolute;
				left: 0;
				right: 0;
				z-index: -1;/*
				border-bottom-width: 1px;
				border-bottom-color: lightgray;
				border-bottom-style: solid;*/
			}

			ul.tree a:hover:before {
				background-color: #DDDDDD;
			}

			ul.tree {
				position: relative;
			}

			.tree .folder:before {
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

			.tree li {
				padding: 8px 1px 0px 0px;
				font-size: 1rem;
				display: block;
				transition: 0.3s;
			}

			.tree .menu li a:before {
				background: #425668;
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

			.tree .menu li a:after {
				border-left: 1px solid #425668;
				bottom: 0;
				content: "";
				left: .6rem;
				position: absolute;
				top: 0;
			}

			.tree .menu li li {
				border-right: 5px solid var(--border-right-sidebar);
			}

			.tree .menu ul {
				position: relative;
				margin-left: 25px;
			}

			.tree li.menu:has(:scope > ul:not(.collapse)) a {
				border-right: 5px solid var(--border-right-sidebar);
			}

			.tree [aria-expanded=true]:before, .tree [data-toggle=collapse]:not(.collapsed):before {
				-webkit-transform: rotate( -45deg );
				transform: rotate( -45deg );
				top: 1.4rem;
			}

			.tree li.sidebar-item a:before {
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

			.tree li.sidebar-item a:after {
				border-left: 1px solid var(--bullet-color, silver);
				bottom: 0;
				content: "";
				left: .6rem;
				position: absolute;
				top: 0;
			}
			
			.tree li > * {
				font-weight: 400;
				padding-right: 15px;
				padding-left: 1.5rem;
			}

]]>
		</style>
		<xsl:variable name="rows" select="$context/ancestor-or-self::data:rows[1]/xo:r/@xo:id|$context[not(self::*) and namespace-uri()='http://www.w3.org/2001/XMLSchema-instance' and local-name()='nil']"/>
		<xsl:apply-templates mode="treeView:header" select="$rows">
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="layout" select="$layout"/>
		</xsl:apply-templates>
		<xsl:variable name="files" select="$rows/..//*[key('treeView:active',@xo:id)]//*[key('File',@xo:id)]"/>
		<ul class="tree" xo-scope="{../@xo:id}">
			<xsl:apply-templates mode="treeView:items" select="$rows[1]/..//Folder[1]/*/@Name">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="layout" select="$layout"/>
			</xsl:apply-templates>
		</ul>
		<xsl:apply-templates mode="treeView:footer" select="$rows">
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="layout" select="$layout"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template mode="treeView:items" match="@*">
		<xsl:variable name="class">
			<xsl:choose>
				<xsl:when test="key('Menu', ../@xo:id)">menu</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="show">
			<xsl:choose>
				<xsl:when test="key('treeView:expanded', ../@xo:id)">show</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="files" select="..//*[key('File',@xo:id)]"/>
		<xsl:variable name="empty-folders" select="..//descendant-or-self::*[key('Menu',@xo:id)][not(*[key('Menu',@xo:id) or key('File',@xo:id)])]"/>
		<li class="{$class}" xo-scope="{../@xo:id}" xo-slot="state:expanded">
			<a href="javascript:void(0)" class="sidebar-link collapsed" onclick="classList.toggle('collapsed'); parentElement.querySelector(':scope > ul').classList.toggle('show'); scope.toggle(true,false);">
				<xsl:choose>
					<xsl:when test="$class='menu'">
						<xsl:choose>
							<xsl:when test="not($empty-folders)">
								<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="#f3da35" class="bi bi-folder2-open" viewBox="0 0 16 16">
									<path d="M9.828 3h3.982a2 2 0 0 1 1.992 2.181l-.637 7A2 2 0 0 1 13.174 14H2.825a2 2 0 0 1-1.991-1.819l-.637-7a1.99 1.99 0 0 1 .342-1.31L.5 3a2 2 0 0 1 2-2h3.672a2 2 0 0 1 1.414.586l.828.828A2 2 0 0 0 9.828 3zm-8.322.12C1.72 3.042 1.95 3 2.19 3h5.396l-.707-.707A1 1 0 0 0 6.172 2H2.5a1 1 0 0 0-1 .981l.006.139z"/>
								</svg>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="color">
									<xsl:choose>
										<xsl:when test="$files">#f3da35</xsl:when>
										<xsl:otherwise>currentColor</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="{$color}" class="bi bi-folder2-open" viewBox="0 0 16 16">
									<path d="M1 3.5A1.5 1.5 0 0 1 2.5 2h2.764c.958 0 1.76.56 2.311 1.184C7.985 3.648 8.48 4 9 4h4.5A1.5 1.5 0 0 1 15 5.5v.64c.57.265.94.876.856 1.546l-.64 5.124A2.5 2.5 0 0 1 12.733 15H3.266a2.5 2.5 0 0 1-2.481-2.19l-.64-5.124A1.5 1.5 0 0 1 1 6.14V3.5zM2 6h12v-.5a.5.5 0 0 0-.5-.5H9c-.964 0-1.71-.629-2.174-1.154C6.374 3.334 5.82 3 5.264 3H2.5a.5.5 0 0 0-.5.5V6zm-.367 1a.5.5 0 0 0-.496.562l.64 5.124A1.5 1.5 0 0 0 3.266 14h9.468a1.5 1.5 0 0 0 1.489-1.314l.64-5.124A.5.5 0 0 0 14.367 7H1.633z"/>
								</svg>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
				<span>
					<xsl:attribute name="onclick">
						<xsl:choose>
							<xsl:when test="$class='menu'">
								<xsl:text/>scope.selectFirst('ancestor::xo:f').set('state:active-item','<xsl:value-of select="../@xo:id"/>');<xsl:text/>
							</xsl:when>
							<xsl:otherwise></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:apply-templates mode="treeView:item-legend" select="."/>
				</span>
				<xsl:if test="key('Menu',../@xo:id)">
					<span class="text-info">
						- <xsl:value-of select="count($files)"/> archivos
					</span>
				</xsl:if>
			</a>
			<ul class="list-unstyled collapse {$show}">
				<xsl:apply-templates mode="treeView:items" select="../*/@Name"/>
			</ul>
		</li>
	</xsl:template>
</xsl:stylesheet>
