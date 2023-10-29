<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:sitemap="http://panax.io/sitemap"
  xmlns:layout="http://panax.io/layout/view/form"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:px="http://panax.io/entity"
  xmlns:data="http://panax.io/source"
  xmlns:form="http://panax.io/widgets/form"
  xmlns:datagrid="http://panax.io/widgets/datagrid"
  xmlns:field="http://panax.io/layout/fieldref"
  xmlns:container="http://panax.io/layout/container"
  xmlns:association="http://panax.io/datatypes/association"
  xmlns:globalization="http://xover.dev/globalization"
  exclude-result-prefixes="xo xsl sitemap layout px data form"
>
	<xsl:param name="globalization:headerText">#globalization</xsl:param>

	<xsl:template mode="headerText" match="@*">
		<xsl:param name="context" select="ancestor::px:Entity[1]/px:Record/px:Field/@Name|ancestor::px:Entity[1]/px:Record/px:Association/@AssociationName"/>
		<xsl:variable name="ref_field" select="$context[.=current()]|$context[name()=current()[parent::field:ref]]|$context[name()=concat('meta:',current()[parent::association:ref])]"/>
		<xsl:choose>
			<xsl:when test="count($ref_field|current())=1">
				<xsl:apply-templates mode="globalization:headerText" select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="headerText" select="$ref_field"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="headerText" match="*[@headerText]/@*">
		<xsl:apply-templates mode="globalization:headerText" select="../@headerText"/>
	</xsl:template>

	<xsl:template mode="headerText" match="xo:r/@*">
		<xsl:param name="context" select="ancestor::px:Entity[1]/px:Record/*/@Name"/>
		<xsl:variable name="ref_field" select="$context[.=local-name(current())]"/>
		<xsl:choose>
			<xsl:when test="count($ref_field|current())=1">
				<xsl:apply-templates mode="globalization:headerText" select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="headerText" select="$ref_field"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>