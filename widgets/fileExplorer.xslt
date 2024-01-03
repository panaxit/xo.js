<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:widget="http://panax.io/widget"
xmlns:treeView="http://panax.io/widget/treeView"
xmlns:fileExplorer="http://panax.io/widget/fileExplorer"
xmlns:data="http://panax.io/source"
xmlns:state="http://panax.io/state"
xmlns:text="http://panax.io/state/text"
xmlns:source="http://panax.io/xover/binding/source"
xmlns:js="http://panax.io/languages/javascript"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
exclude-result-prefixes="#default xo session sitemap widget state source js xsi"
>
	<xsl:import href="../functions.xslt"/>
	<xsl:import href="treeView.xslt"/>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>

	<xsl:key name="Menu" match="Folder" use="@xo:id"/>
	<xsl:key name="Menu" match="Item[not(@IsFile='1')]" use="@xo:id"/>
	<xsl:key name="File" match="Item[@IsFile='1']" use="@xo:id"/>

	<xsl:key name="active" match="xo:f[not(@state:active-item)]/Folder" use="@xo:id"/>
	<xsl:key name="active" match="xo:f" use="@state:active-item"/>

	<xsl:key name="expanded" match="*[@state:expanded='true']" use="@xo:id"/>

	<xsl:key name="fileExplorer:widget" match="node-expected" use="concat(@xo:id,'::header')"/>

	<xsl:attribute-set name="fileExplorer:attributes">
	</xsl:attribute-set>

	<xsl:template mode="fileExplorer:preceding-siblings" match="@*"></xsl:template>
	<xsl:template mode="fileExplorer:following-siblings" match="@*"></xsl:template>

	<xsl:key name="display-text" match="xo:r/@text:*" use="concat(../@xo:id, '::',local-name())" />

	<xsl:template mode="fileExplorer:item-legend" match="@*">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template mode="fileExplorer:item-legend" match="@*[contains(.,'?name=')]">
		<xsl:value-of select="substring-before(substring-after(.,'?name='),'&amp;')"/>
	</xsl:template>

	<xsl:template mode="fileExplorer:widget" match="@*">
		<xsl:param name="schema" select="nodeset-expected"/>
		<xsl:param name="context" select="nodeset-expected"/>
		<xsl:param name="layout" select="nodeset-expected"/>
		<div class="flow-container file-explorer">
			<div class="row">
				<div class="col-md-12">
					<style>
						<![CDATA[
							:root {
								--bg-file-explorer-default: #2A3F54;
								--border-right-sidebar: #1ABB9C;
							}
							
							.file-explorer aside {
								height: 100vh;
								background-color: var(--bg-primary-dark, var(--bg-file-explorer-default));
								color: white;
								min-width: max-content;
								overflow: auto;
								padding-bottom: 1rem;
							}
							
							.file-explorer aside ul ul {
								position: relative;
								margin-left: 25px;
							}

							
							.file-explorer aside li svg {
								margin-right: 10px;
							}
		  
							.file-explorer-item .badge {
								transform: translateX(10px);
							}

							.file_panel-paragraphs, .sidebar-item a {
							white-space: nowrap;
							text-overflow: ellipsis;
							overflow: hidden;
							}

							.simplebar-wrapper {
							overflow: hidden;
							width: inherit;
							height: inherit;
							max-width: inherit;
							max-height: inherit;
							}

							.simplebar-mask, .simplebar-offset {
							position: absolute;
							padding: 0;
							margin: 0;
							left: 0;
							top: 0;
							bottom: 0;
							right: 0;
							}

							.simplebar-mask {
							direction: inherit;
							overflow: hidden;
							width: auto !important;
							height: auto !important;
							z-index: 0;
							}

							.simplebar-offset {
							direction: inherit !important;
							box-sizing: inherit !important;
							resize: none !important;
							}

							.simplebar-content-wrapper {
							direction: inherit;
							box-sizing: border-box !important;
							position: relative;
							display: block;
							width: auto;
							max-width: 100%;
							max-height: 100%;
							}

							.simplebar-content {
							display: flex;
							flex-direction: column;
							height: 100vh;
							padding-bottom: 0 !important;
							}

							.file_panel-body .row {
							justify-content: unset;
							align-items: unset;
							}

							.bi-folder-fill {
							color: #f3da35;
							}

							.file-explorer .tree .sidebar-link {
								color: #adb5bd;
							}

							.breadcrumb {
								padding-left: 15px;
								margin-bottom: 0px;
								min-height: 25px;
							}
							]]>
					</style>
					<xsl:variable name="rows" select="$context/ancestor-or-self::data:rows[1]/xo:r/@xo:id|$context[not(self::*) and namespace-uri()='http://www.w3.org/2001/XMLSchema-instance' and local-name()='nil']"/>
					<xsl:apply-templates mode="fileExplorer:header" select="$rows">
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="layout" select="$layout"/>
					</xsl:apply-templates>
					<xsl:variable name="files" select="$rows/..//*[key('active',@xo:id)]//*[key('File',@xo:id)]"/>
					<div class="file_panel file_panel-default">
						<div class="file_panel-body">
							<div class="row">
								<aside class="col-12 col-md-4 col-lg-3 tree">
									<xsl:apply-templates mode="treeView:widget" select=".">
										<xsl:with-param name="context" select="$rows[1]/..//Folder[1]/*/@Name"/>
										<xsl:with-param name="layout" select="$layout"/>
									</xsl:apply-templates>
								</aside>
								<div class="col container">
									<nav aria-label="breadcrumb">
										<ol class="breadcrumb">
											<xsl:apply-templates mode="fileExplorer:breadcrumb" select="$rows/..//*[key('active',@xo:id)]/@Name"/>
											<li class="breadcrumb-item active">
												<a href="javascript:void(0)">
													<span class="text-info">
														- <xsl:value-of select="count($files)"/> archivos
													</span>
												</a>
											</li>
										</ol>
									</nav>
									<div class="row">
										<xsl:apply-templates mode="fileExplorer:body" select="$rows[1]">
											<xsl:with-param name="context" select="$context"/>
											<xsl:with-param name="layout" select="$layout"/>
										</xsl:apply-templates>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template mode="fileExplorer:aside" match="@*">
		<xsl:variable name="class">
			<xsl:choose>
				<xsl:when test="key('Menu', ../@xo:id)">menu</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="show">
			<xsl:choose>
				<xsl:when test="key('expanded', ../@xo:id)">show</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="files" select="..//*[key('File',@xo:id)]"/>
		<xsl:variable name="empty-folders" select="..//descendant-or-self::*[key('Menu',@xo:id)][not(*[key('Menu',@xo:id) or key('File',@xo:id)])]"/>
		<li class="sidebar-item {$class}" xo-scope="{../@xo:id}">
			<a href="javascript:void(0)" class="sidebar-link collapsed" onclick="classList.toggle('collapsed'); parentElement.querySelector(':scope > ul').classList.toggle('show'); scope.toggle('state:expanded',true,false);">
				<xsl:choose>
					<xsl:when test="$class='menu'">
						<xsl:choose>
							<xsl:when test="not($empty-folders)">
								<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="#f3da35" class="bi bi-folder2-open" viewBox="0 0 16 16" onclick="scope.selectFirst('ancestor::xo:f').set('state:active-item','{../@xo:id}')">
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
					<xsl:apply-templates mode="fileExplorer:item-legend" select="."/>
				</span>
				<xsl:if test="key('Menu',../@xo:id)">
					<span class="text-info">
						- <xsl:value-of select="count($files)"/> archivos
					</span>
				</xsl:if>
			</a>
			<ul class="sidebar-dropdown list-unstyled collapse {$show}">
				<xsl:apply-templates mode="fileExplorer:aside" select="../*/@Name"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template mode="fileExplorer:body" match="@*">
		<xsl:param name="layout" select="nodeset-expected"/>
		<xsl:param name="context" select="nodeset-expected"/>
		<xsl:variable name="rows" select="$context/ancestor-or-self::data:rows[1]/xo:r/@xo:id|$context[not(self::*) and namespace-uri()='http://www.w3.org/2001/XMLSchema-instance' and local-name()='nil']"/>
		<xsl:apply-templates mode="fileExplorer:body-item" select="..//*[key('active',@xo:id)]/*/@Name"/>
	</xsl:template>

	<xsl:template mode="fileExplorer:body-item-thumbnail-attributes" match="@*">
		<xsl:attribute name="onclick">
			<xsl:text/>scope.selectFirst('ancestor::xo:f').set('state:active-item','<xsl:value-of select="../@xo:id"/>')<xsl:text/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template mode="fileExplorer:body-item-thumbnail-badge" match="@*"/>

	<xsl:template mode="fileExplorer:body-item-thumbnail-badge" match="*[descendant::*[key('File',@xo:id)]]/@*">
		<xsl:variable name="files" select="..//*[key('File',@xo:id)]"/>
		<span class="position-absolute top-0 badge rounded-pill bg-danger" style="">
			<xsl:value-of select="count($files)"/>
			<span class="visually-hidden">
				<xsl:value-of select="count($files)"/> files
			</span>
		</span>
	</xsl:template>

	<xsl:template mode="fileExplorer:body-item-thumbnail" match="@*">
		<a href="FilesRepository/{.}" target="_blank" xo-scope="x_r_e8bac8a7_db47_4f6c_851d_7fb10e839de8" xo-slot="Archivo" xo:id="a_9e1e875a_9803_4697_afa1_61ba582e8c8e">
			<img id="" src="FilesRepository/{.}" style="height:100px;" xo-scope="x_r_e8bac8a7_db47_4f6c_851d_7fb10e839de8" xo-slot="Archivo" xo:id="img_7821a493_f8c7_496f_be62_179cb22725e8"/>
		</a>
		<xsl:apply-templates mode="fileExplorer:body-item-thumbnail-badge" select="current()"/>
	</xsl:template>

	<xsl:template mode="fileExplorer:body-item-thumbnail" match="*[key('Menu', @xo:id)]/@*">
		<xsl:variable name="files" select="..//*[key('File',@xo:id)]"/>
		<xsl:variable name="color">
			<xsl:choose>
				<xsl:when test="$files">#f3da35</xsl:when>
				<xsl:otherwise>currentColor</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="{$color}" class="bi bi-folder2-open" viewBox="0 0 16 16">
			<xsl:apply-templates mode="fileExplorer:body-item-thumbnail-attributes" select="current()"/>
			<path d="M1 3.5A1.5 1.5 0 0 1 2.5 2h2.764c.958 0 1.76.56 2.311 1.184C7.985 3.648 8.48 4 9 4h4.5A1.5 1.5 0 0 1 15 5.5v.64c.57.265.94.876.856 1.546l-.64 5.124A2.5 2.5 0 0 1 12.733 15H3.266a2.5 2.5 0 0 1-2.481-2.19l-.64-5.124A1.5 1.5 0 0 1 1 6.14V3.5zM2 6h12v-.5a.5.5 0 0 0-.5-.5H9c-.964 0-1.71-.629-2.174-1.154C6.374 3.334 5.82 3 5.264 3H2.5a.5.5 0 0 0-.5.5V6zm-.367 1a.5.5 0 0 0-.496.562l.64 5.124A1.5 1.5 0 0 0 3.266 14h9.468a1.5 1.5 0 0 0 1.489-1.314l.64-5.124A.5.5 0 0 0 14.367 7H1.633z"/>
		</svg>
		<xsl:apply-templates mode="fileExplorer:body-item-thumbnail-badge" select="current()"/>
	</xsl:template>

	<xsl:template mode="fileExplorer:body-item-thumbnail" match="*[key('Menu', @xo:id)][not(descendant-or-self::*[key('Menu',@xo:id)][not(*[key('Menu',@xo:id) or key('File',@xo:id)])])]/@*">
		<xsl:variable name="files" select="..//*[key('File',@xo:id)]"/>
		<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="currentColor" class="bi bi-folder-fill" viewBox="0 0 16 16">
			<xsl:apply-templates mode="fileExplorer:body-item-thumbnail-attributes" select="current()"/>
			<path d="M9.828 3h3.982a2 2 0 0 1 1.992 2.181l-.637 7A2 2 0 0 1 13.174 14H2.825a2 2 0 0 1-1.991-1.819l-.637-7a1.99 1.99 0 0 1 .342-1.31L.5 3a2 2 0 0 1 2-2h3.672a2 2 0 0 1 1.414.586l.828.828A2 2 0 0 0 9.828 3zm-8.322.12C1.72 3.042 1.95 3 2.19 3h5.396l-.707-.707A1 1 0 0 0 6.172 2H2.5a1 1 0 0 0-1 .981l.006.139z"/>
		</svg>
		<xsl:apply-templates mode="fileExplorer:body-item-thumbnail-badge" select="current()"/>
	</xsl:template>

	<xsl:template mode="fileExplorer:body-item" match="@*">
		<div class="col-xs-6 col-sm-6 col-md-3 col-lg-3 file-explorer-item position-relative" xo-scope="{../@xo:id}">
			<xsl:apply-templates mode="fileExplorer:body-item-thumbnail" select="."/>
			<p class="file_panel-paragraphs">
				<xsl:apply-templates mode="fileExplorer:item-legend" select="."/>
			</p>
		</div>
	</xsl:template>


	<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

	<xsl:template match="*" mode="fileExplorer">
		<div class="col-md-12">
			<style>
				<![CDATA[
		  .file_panel-paragraphs, .sidebar-item a {
			  white-space: nowrap;
			  text-overflow: ellipsis;
			  overflow: hidden;
		  }

		  .navbar-file {
			  background-color: #313b4c !important;
			  color: #fff !important;
		  }

		  .file_body-folders {
			cursor: pointer !important;
		  }

		  .file_container {
			min-height: 100vh;
		  }

		  .img_file_manager {
			  margin: 0 auto;
			  display: block;
			  /*max-width: 100%;*/
			  height: auto;
		  }

		  .file_panel-default {
			border-color: #ddd;
		  }

		  .file_panel {
			  margin-bottom: 20px;
			  background-color: #fff;
			  border: 1px solid transparent;
			  border-radius: 4px;
			  -webkit-box-shadow: 0 1px 1px rgb(0 0 0 / 5%);
			  box-shadow: 0 1px 1px rgb(0 0 0 / 5%);
		  }

		  .file_template-collapse {
			border-right: 1px solid gray;
		  }

		  .file_panel-body {
			padding: 15px;
		  }

		  .file_panel-paragraphs {
			  margin-top: -20px;
			  text-align: center;
		  } 
		  
		  .file-explorer-item .badge {
			transform: translateX(10px);
		  }
		  ]]>
			</style>
			<xsl:apply-templates mode="fileExplorer:header" select="."/>
			<xsl:apply-templates mode="fileExplorer:panel" select="."/>
		</div>
	</xsl:template>

	<xsl:template match="@*" mode="fileExplorer:header">
		<nav class="navbar navbar-expand-lg navbar-file">
			<div class="container-fluid">
				<a class="navbar-brand text-white" href="#">
					Explorador de archivos
				</a>
				<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarText" aria-controls="navbarText" aria-expanded="false" aria-label="Toggle navigation">
					<span class="navbar-toggler-icon"></span>
				</button>
				<div class="collapse navbar-collapse" id="navbarText">
					<ul class="navbar-nav mb-2 mb-lg-0 text-right">
						<li class="nav-item">
							<a class="nav-link active text-white" aria-current="page" href="#">
								<xsl:apply-templates mode="fileExplorer:title" select="."/>
							</a>
						</li>
					</ul>
				</div>
			</div>
		</nav>
	</xsl:template>

	<xsl:template match="@*" mode="fileExplorer:breadcrumb">
		<xsl:apply-templates mode="fileExplorer:breadcrumb" select="../../@Name"/>
		<li class="breadcrumb-item">
			<a href="javascript:void(0)"  onclick="scope.selectFirst('ancestor::xo:f').set('state:active-item','{../@xo:id}')">
				<xsl:apply-templates select="../@Name"/>
			</a>
		</li>
	</xsl:template>

	<xsl:template match="@Name[.='']" mode="fileExplorer:breadcrumb">
	</xsl:template>

	<xsl:template match="*[key('active',@xo:id)]/@*" mode="fileExplorer:breadcrumb">
		<xsl:apply-templates mode="fileExplorer:breadcrumb" select="../../@Name"/>
		<li class="breadcrumb-item active" aria-current="page">
			<xsl:apply-templates select="../@Name"/>
		</li>
	</xsl:template>

	<xsl:template match="@*" mode="fileExplorer:title">
		<xsl:attribute name="onclick">app.request(`[Compras].[Facturas]`,``)</xsl:attribute>
		<xsl:value-of select="../@Name"/>
	</xsl:template>

	<xsl:template match="@*" mode="fileExplorer:panel">
		<div class="file_panel file_panel-default">
			<div class="file_panel-body">
				<div class="row">
					<div class="col-sm-3 col-md-2 col-lg-2 file_template-collapse">
						<xsl:apply-templates mode="fileExplorer:panel.collapse" select="."/>
					</div>
					<div class="col-sm-9 col-md-10">
						<xsl:apply-templates mode="fileExplorer:panel.body" select="."/>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
