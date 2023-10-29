<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:state="http://panax.io/state"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:meta="http://panax.io/metadata"
  xmlns:data="http://panax.io/source"
  xmlns:px="http://panax.io/entity"
  xmlns:form="http://panax.io/widget/form"
  xmlns:field="http://panax.io/layout/fieldref"
  xmlns:container="http://panax.io/layout/container"
  xmlns:association="http://panax.io/datatypes/association"
  exclude-result-prefixes="xo state xsl form data px meta"
>
	<xsl:import href="keys.xslt"/>

	<!--<xsl:key name="readonly" match="@readonly:*" use="concat(@xo:id,'::',local-name())"/>-->
	<xsl:key name="reference" match="key-expected" use="@xo:id"/>
	<xsl:key name="association" match="key-expected" use="@xo:id"/>
	<xsl:key name="foreignTable" match="key-expected" use="@xo:id"/>

	<xsl:template mode="form:widget" match="@*">
		<xsl:param name="context" select="key('dataset',ancestor::px:Entity[1]/@xo:id)"/>
		<xsl:param name="layout" select="key('layout',ancestor::px:Entity[1]/@xo:id)"/>
		<xsl:for-each select="$context">
			<xsl:variable name="row" select="current()"/>
			<form class="form-view needs-validation col-12 g-3 fluid-container p-3 bg-body rounded shadow-sm" novalidate="">
				<xsl:apply-templates mode="form:header" select="."/>
				<div class="col-12 g-3">
					<xsl:apply-templates mode="form:field" select="$layout">
						<xsl:with-param name="context" select="$row"/>
					</xsl:apply-templates>
				</div>
				<xsl:apply-templates mode="form:footer" select="."/>
				<xsl:apply-templates mode="form:menu" select="."/>
			</form>
			<hr/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="form:header" match="@*"/>

	<xsl:template mode="form:footer" match="@*"/>

	<xsl:template mode="form:menu" match="@*">
		<menu class="list-group list-group-horizontal justify-content-end">
			<xsl:apply-templates mode="form:menu-content" select="."/>
		</menu>
	</xsl:template>

	<xsl:template mode="form:field-header" match="@*">
		<xsl:param name="context" select="node-expected"/>
		<xsl:param name="field-name">
			<xsl:apply-templates mode="form:field-name" select="."/>
		</xsl:param>
		<xsl:param name="ref_field" select="key('field-ref',concat($context,'::',$field-name))"/>
		<xsl:choose>
			<xsl:when test="count(.|$ref_field)=1">
				<xsl:apply-templates mode="headerText" select="../@headerText"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="headerText" select="$ref_field"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="form:field-header" match="*[@headerText]/@*">
		<xsl:apply-templates mode="headerText" select="../@headerText"/>
	</xsl:template>

	<xsl:template mode="form:field-body-prepend" match="@*">
		<xsl:text></xsl:text>
	</xsl:template>

	<xsl:template mode="form:field-body-append" match="@*">
		<xsl:text>&#160;</xsl:text>
	</xsl:template>

	<xsl:template mode="form:field-attributes" match="@*"/>

	<xsl:template mode="form:field-name" match="association:*/@*">
		<xsl:value-of select="concat('meta:',.)"/>
	</xsl:template>

	<xsl:template mode="form:field-name" match="container:*/@*">
		<xsl:text/>xo:id<xsl:text/>
	</xsl:template>

	<xsl:template mode="form:field" match="@*">
		<xsl:param name="context" select="../@xo:id"/>
		<xsl:param name="field-name">
			<xsl:apply-templates mode="form:field-name" select="."/>
		</xsl:param>
		<xsl:variable name="headerText">
			<xsl:apply-templates mode="form:field-header" select="current()">
				<xsl:with-param name="context" select="$context/ancestor::px:Entity[1]/@xo:id"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="colspan">
			<xsl:choose>
				<xsl:when test="$headerText!=''">10</xsl:when>
				<xsl:otherwise>12</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="mb-3 row" style="max-width: 992px;">
			<xsl:if test="$headerText!=''">
				<label class="col-sm-2 form-label">
					<xsl:value-of select="$headerText"/>
					<xsl:text>: </xsl:text>
				</label>
			</xsl:if>
			<div class="col-sm-{$colspan}">
				<xsl:apply-templates mode="form:field-body" select="current()">
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</div>
		</div>
	</xsl:template>

	<xsl:key name="toggler" match="container:fieldSet/*[@Name=../@Name]" use="@Name"/>

	<xsl:template mode="form:field" match="*[key('widget',concat('fieldset:',ancestor::px:Entity[1]/@xo:id,'::',@Name))]/@*">
		<xsl:param name="context" select="../@xo:id"/>
		<xsl:variable name="headerText">
			<xsl:apply-templates mode="form:field-header" select="current()">
				<xsl:with-param name="context" select="$context/ancestor::px:Entity[1]/@xo:id"/>
			</xsl:apply-templates>
		</xsl:variable>
		<div class="mb-3 row data-field {translate(name(..),':','-')}">
			<fieldset class="container-{translate(../@Name,' ','-')}">
				<xsl:variable name="toggler" select="key('toggler',../@Name)"/>
				<xsl:if test="$headerText!=''">
					<legend>
						<xsl:value-of select="normalize-space($headerText)"/>
						<xsl:text>: </xsl:text>
						<xsl:if test="$toggler">
							<xsl:apply-templates mode="form:fieldset-toggler" select="current()">
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
						</xsl:if>
					</legend>
				</xsl:if>
				<xsl:apply-templates mode="form:field-body" select="current()">
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</fieldset>
		</div>
	</xsl:template>

	<xsl:template mode="form:fieldset-toggler" match="@*">
	</xsl:template>

	<xsl:template mode="form:fieldset-toggler" match="container:fieldSet[key('toggler',@Name)]/@*">
		<xsl:param name="context" select="../@xo:id"/>
		<xsl:apply-templates mode="form:field-body" select="key('toggler',../@Name)/@Name">
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template mode="form:field-body-append" match="@*">
		<xsl:param name="label">
			<xsl:apply-templates mode="headerText" select="."/>
		</xsl:param>
		<label for="{../@xo:id}" class="floating-label">
			<xsl:value-of select="$label"/>:
		</label>
	</xsl:template>

	<xsl:template mode="form:field-body-append" match="@*[key('widget',concat('picture:',ancestor::px:Entity[1]/@xo:id,'::',name()))]"/>
	<xsl:template mode="form:field-body-append" match="@*[key('widget',concat('file:',ancestor::px:Entity[1]/@xo:id,'::',name()))]"/>
	<xsl:template mode="form:field-body-append" match="@*[key('widget',concat('files:',ancestor::px:Entity[1]/@xo:id,'::',name()))]"/>
	<xsl:template mode="form:field-body-append" match="@*[key('widget',concat('form:',ancestor::px:Entity[1]/@xo:id,'::',parent::px:Entity/@Schema,'/',parent::px:Entity/@Name))]"/>
	<xsl:template mode="form:field-body-append" match="@*[key('widget',concat('datagrid:',ancestor::px:Entity[1]/@xo:id,'::',parent::px:Entity/@Schema,'/',parent::px:Entity/@Name))]"/>
	<xsl:template mode="form:field-body-append" match="@*[key('widget',concat('dropzone:',ancestor::px:Entity[1]/@xo:id,'::',name()))]"/>
	<xsl:template mode="form:field-body-append" match="@*[key('widget',concat('percentage:',ancestor::px:Entity[1]/@xo:id,'::',name()))]"/>
	<xsl:template mode="form:field-body-append" match="@*[key('widget',concat('yesNo:',ancestor::px:Entity[1]/@xo:id,'::',name()))]"/>

	<xsl:template mode="form:field-body-attributes" match="@*"/>

	<xsl:template mode="form:field-type" match="@*"/>
	
	<xsl:template mode="form:field-type" match="@association:ref|@field:ref">
		<xsl:value-of select="translate(name(..),':','-')"/>
	</xsl:template>

	<xsl:template mode="form:field-type" match="xo:r/@*">
		<xsl:text/>field-ref<xsl:text/>
	</xsl:template>

	<xsl:template mode="form:field-type" match="xo:r/@meta:*">
		<xsl:text/>association-ref<xsl:text/>
	</xsl:template>

	<xsl:template mode="form:field-body" match="@*">
		<xsl:variable name="label">
			<xsl:apply-templates mode="headerText" select="."/>
		</xsl:variable>
		<xsl:variable name="class">
			<xsl:text>form-floating input-group</xsl:text>
		</xsl:variable>
		<xsl:variable name="field-type">
			<xsl:apply-templates mode="form:field-type" select="."/>
		</xsl:variable>
		<div class="form-group {$class} data-field {$field-type}">
			<xsl:attribute name="style">
				<xsl:text/>min-width: calc(<xsl:value-of select="concat(string-length($label)+1,'ch')"/> + 6rem);<xsl:text/>
			</xsl:attribute>
			<xsl:apply-templates mode="form:field-body-attributes" select="current()"/>
			<xsl:apply-templates mode="widget" select="current()"/>
			<xsl:apply-templates mode="widget-routes" select="current()"/>
			<xsl:apply-templates mode="form:field-body-append" select="current()">
				<xsl:with-param name="label" select="$label"/>
			</xsl:apply-templates>
		</div>
	</xsl:template>

	<xsl:template mode="form:field-body" match="field:ref/@*|association:ref/@*">
		<xsl:param name="context" select="../@xo:id"/>
		<xsl:param name="field-name">
			<xsl:apply-templates mode="form:field-name" select="."/>
		</xsl:param>
		<xsl:param name="ref_field" select="key('field-ref',concat($context,'::',$field-name))"/>
		<xsl:comment>debug:info</xsl:comment>
		<xsl:choose>
			<xsl:when test="count($ref_field|current())=1">
				<xsl:apply-templates mode="widget" select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="form:field-body" select="$ref_field">
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="form:field-body" match="container:*/@*">
		<xsl:param name="context" select="../@xo:id"/>
		<xsl:variable name="toggler" select="../*[key('toggler',@Name)]/@Name"/>
		<xsl:variable name="class">
			<xsl:choose>
				<xsl:when test="not(key('field-ref',concat($context,'::',$toggler)) = 1)">collapse</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="field-type">
			<xsl:apply-templates mode="form:field-type" select="."/>
		</xsl:variable>
		<label>
		</label>
		<style>
			<![CDATA[
			.collapse:not(.show) {
				display: none !important;
			}
		]]>
		</style>
		<div class="input-group d-flex justify-content-between {$class} data-field {$field-type}" id="{../@Name}">
			<xsl:for-each select="../*[not(@Name=$toggler)]/@Name">
				<div class="input-group">
					<xsl:apply-templates mode="form:field-attributes" select="current()"/>
					<xsl:apply-templates mode="form:field-body" select="current()">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</div>
			</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template mode="form:field-body" match="container:modal/@*|container:tabPanel/@*|container:tab[not(parent::container:tabPanel)]/@*">
		<xsl:param name="context" select="../@xo:id"/>
		<div class="" xo-scope="{../@xo:id}" xo-slot="state:active">
			<xsl:apply-templates mode="widget" select=".">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</div>
	</xsl:template>

	<xsl:template mode="form:field" match="*[key('hidden',@xo:id)]/@*|*[key('hidden',concat(ancestor::px:Entity[1]/@xo:id,'::',@Name))]/@*">
		<xsl:comment>
			<xsl:text/>hidden <xsl:value-of select="../@xo:id"/>: <xsl:value-of select="."/>
		</xsl:comment>
	</xsl:template>
</xsl:stylesheet>