<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:state="http://panax.io/state"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:meta="http://panax.io/metadata"
  xmlns:data="http://panax.io/source"
  xmlns:px="http://panax.io/entity"
  xmlns:form="http://panax.io/widget/form"
  xmlns:custom="http://panax.io/custom"
  xmlns:combobox="http://panax.io/widget/combobox"
  xmlns:container="http://panax.io/layout/container"
  exclude-result-prefixes="xo state xsl form combobox data px meta container"
  extension-element-prefixes="state"
>
	<xsl:import href="keys.xslt"/>
	<xsl:import href="widgets/form.xslt"/>

	<xsl:param name="data:rows"/>
	<!--<xsl:param name="state:dirty"/>-->

	<xsl:key name="form:widget" match="dummy" use="@xo:id"/>

	<!--<xsl:template mode="widget" match="@*[key('form:widget',concat(ancestor-or-self::*[@meta:type='entity'][1]/@xo:id,'.',name()))]">
		<xsl:param name="context" select="../data:rows/xo:r"/>
		<xsl:param name="layout" select="../data:rows/xo:r[1]/@*"/>
		<xsl:param name="selection" select="node-expected"/>
		<div class="row g-5" style="margin-top:0px;">
			<div class="col-md-9 col-lg-11">
				<xsl:apply-templates mode="form:widget" select="current()">
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="layout" select="$layout"/>
					<xsl:with-param name="selection" select="$selection"/>
				</xsl:apply-templates>
			</div>
		</div>
	</xsl:template>-->
	
	<!-- layout -->

	<xsl:template mode="form:field-header" match="@*">
		<xsl:param name="context" select="node-expected"/>
		<xsl:param name="field-name">
			<xsl:apply-templates mode="form:field-name" select="."/>
		</xsl:param>
		<xsl:param name="ref_field" select="key('schema',concat($context,'::',$field-name))"/>
		
		<xsl:attribute name="scope">col</xsl:attribute>
		<xsl:attribute name="ondblclick">this.toggle('contenteditable','')</xsl:attribute>
		<xsl:attribute name="xo-scope">
			<xsl:value-of select="../@xo:id"/>
		</xsl:attribute>
		<xsl:attribute name="xo-slot">headerText</xsl:attribute>
		<xsl:choose>
			<xsl:when test="$ref_field">
				<xsl:apply-templates mode="form:field-header" select="$ref_field"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="headerText" select="../@Name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>