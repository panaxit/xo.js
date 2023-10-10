<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:state="http://panax.io/state"
  xmlns:text="http://panax.io/state/text"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:CardView="http://panax.io/widgets/cardview"
  xmlns:metadata="http://panax.io/metadata"
  xmlns:temp="http://panax.io/temp"
  xmlns:data="http://panax.io/source"
  xmlns:story="urn:item:story"
  xmlns:height = "http://panax.io/state/height"
  xmlns:width = "http://panax.io/state/width"
  xmlns:px="http://panax.io/entity"
  xmlns:layout="http://panax.io/layout/view/form"
  exclude-result-prefixes="xo state xsl CardView data height width data story temp px layout"
>
	<xsl:import href="functions.xslt"/>
	<xsl:key name="value" match="xo:r/@*" use="concat(../@xo:id,'::',name())"/>
	<xsl:key name="display-text" match="xo:r/@text:*" use="concat(../@xo:id, '::',local-name())" />
	<xsl:key name="money" match="px:Field[@DataType='money']" use="concat(ancestor::px:Entity[1]/@xo:id,'::',@Name)"/>
	<xsl:key name="time" match="px:Field[@DataType='time']" use="concat(ancestor::px:Entity[1]/@xo:id,'::',@Name)"/>
	<xsl:key name="file" match="px:Field[@DataType='file']" use="concat(ancestor::px:Entity[1]/@xo:id,'::',@Name)"/>
	<xsl:key name="percent" match="px:Field[@DataType='percent']" use="concat(ancestor::px:Entity[1]/@xo:id,'::',@Name)"/>
	<xsl:key name="date" match="xo:r/@*[contains(.,'T00:00:00')]" use="concat(ancestor::px:Entity[1]/@xo:id,'::',name())"/>

	<xsl:key name="password" match="node-expected" use="''"/>
	<xsl:key name="combobox" match="node-expected" use="''"/>

	<xsl:key name="combobox_text" match="px:Association/px:Entity/data:rows/xo:r/@text" use="concat(ancestor::px:Entity[2]/@xo:id,'::',ancestor::px:Association/px:Mappings/px:Mapping/@Referencer,'::',../@Id)"/>

	<xsl:template match="@*">
		<xsl:variable name="text" select="key('display-text',concat(parent::xo:r[1]/@xo:id,'::',name()))"/>
		<xsl:choose>
			<xsl:when test="$text">
				<xsl:value-of select="$text" disable-output-escaping="yes"/>
			</xsl:when>
			<xsl:when test="substring(.,1,1)!='0' and number(.)=. and string-length(.)&lt;=9">
				<xsl:value-of select="number(.)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." disable-output-escaping="yes"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*[key('money',concat(ancestor::px:Entity[1]/@xo:id,'::',name()))]">
		<xsl:value-of select="format-number(translate(.,'$,',''),'$#,##0.00###;-$#,##0.00###')"/>
	</xsl:template>

	<xsl:template match="@*[key('password',concat(ancestor::px:Entity[1]/@xo:id,'::',name()))]">
		<xsl:text>**********</xsl:text>
	</xsl:template>

	<xsl:template match="@*[key('time',concat(ancestor::px:Entity[1]/@xo:id,'::',name()))]">
		<xsl:value-of select="substring(.,1,5)"/>
	</xsl:template>

	<xsl:template match="@*[key('combobox',concat(ancestor::px:Entity[1]/@xo:id,'::',name()))]">
		<xsl:value-of select="key('combobox_text',concat(ancestor::px:Entity[1]/@xo:id,'::',name(),'::',.))[1]"/>
	</xsl:template>

	<xsl:template match="@*[key('percent',concat(ancestor::px:Entity[1]/@xo:id,'::',name()))]">
		<xsl:value-of select="."/>%
	</xsl:template>

	<xsl:template match="@*[key('date',concat(ancestor::px:Entity[1]/@xo:id,'::',name()))]">
		<xsl:value-of select="substring(.,1,10)"/>
	</xsl:template>

	<xsl:template match="*[concat('datagrid:',@Schema,'.',@Name)]/*/@*[key('file',concat(ancestor::px:Entity[1]/@xo:id,'::',name()))]">
		<xsl:call-template name="substring-after-last">
			<xsl:with-param name="string" select="." />
			<xsl:with-param name="delimiter" select="'\'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="*[concat('datagrid:',@Schema,'.',@Name)]/*/@*[contains(.,'?name=')][key('file',concat(ancestor::px:Entity[1]/@xo:id,'::',name()))]">
		<xsl:value-of select="substring-before(substring-after(concat(.,'&amp;'),'?name='),'&amp;')"/>
	</xsl:template>

	<xsl:template match="@*[.='']">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="@text:*">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="@xo:id">
		<xsl:text>--</xsl:text>
	</xsl:template>
</xsl:stylesheet>