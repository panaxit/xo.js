<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:px="http://panax.io/entity"
  xmlns:form="http://panax.io/widget/form"
  xmlns:data="http://panax.io/source"
  xmlns:meta="http://panax.io/metadata"
  xmlns:state="http://panax.io/state"
  xmlns:wizard="http://panax.io/widget/wizard"
  xmlns:datagrid="http://panax.io/widget/datagrid"
  xmlns:combobox="http://panax.io/widget/combobox"
  xmlns:container="http://panax.io/layout/container"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:control="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:association="http://panax.io/datatypes/association"
  exclude-result-prefixes="px form datagrid wizard combobox control data"
>
	<xsl:key name="hidden" match="node-expected" use="@xo:id"/>
	<xsl:key name="state:hidden" match="node-expected" use="@xo:id"/>

	<xsl:key name="changed" match="xo:r[@state:dirty='1']" use="@xo:id"/>
	<xsl:key name="state:changed" match="xo:r[@state:dirty='1']" use="@xo:id"/>
	
	<xsl:key name="entity" match="px:Entity" use="@xo:id"/>
	<xsl:key name="entity" match="px:Entity" use="concat(@Schema,'/',@Name)"/>
	<xsl:key name="entity" match="px:Entity[@control:type='datagrid:control']" use="concat('datagrid:',@Schema,'/',@Name)"/>
	<xsl:key name="datagrid:item" match="px:Entity[@controlType='datagridView']/*[local-name()='layout']//*" use="@xo:id"/>

	<xsl:key name="entity" match="px:Entity[@control:type='form:control']" use="concat('form:',@Schema,'/',@Name)"/>

	<!--Routes-->
	<xsl:key name="routes" match="px:Association/px:Entity/px:Routes/px:Route/@Method" use="concat(ancestor::px:Entity[2]/@xo:id,'::meta:',ancestor::px:Association[1]/@Name)"/>
	<xsl:key name="routes" match="px:Entity/px:Routes/px:Route/@Method" use="ancestor::px:Entity[1]/@xo:id"/>

	<!--Datarows?-->
	<xsl:key name="data-rows" match="data:rows/@xsi:nil" use="ancestor::px:Entity[1]/@xo:id"/>
	<xsl:key name="data-rows" match="data:rows/xo:r/@xo:id" use="ancestor::px:Entity[1]/@xo:id"/>
	
	<!--Layout-->
	<xsl:key name="layout" match="px:Entity/*[local-name()='layout']/*/@Name|px:Entity[not(*[local-name()='layout']/*)]/px:Record/px:*/@Name|px:Entity[1]/*[local-name()='layout']/*[not(@Name)]/@xo:id" use="ancestor::px:Entity[1]/@xo:id"/>
	<xsl:key name="wizard:section" match="px:Entity/*[local-name()='layout']/*/@Name|px:Entity[1]/*[local-name()='layout']/*[not(@Name)]/@xo:id" use="concat(count(../preceding-sibling::*|..),'::',ancestor::px:Entity[1]/@xo:id)"/>
	<!--<xsl:key name="wizard:section" match="px:Entity/*[local-name()='layout']//*/@Name|px:Entity[1]/*[local-name()='layout']//*[not(@Name)]/@xo:id" use="concat(count(ancestor::*[local-name(parent::*)='layout'][1]/preceding-sibling::*|.),'::',ancestor::px:Entity[1]/@xo:id)"/>-->

	<!--Datasets-->
	<xsl:key name="dataset" match="px:Entity[not(data:rows)]/@xo:id" use="concat(../@xo:id,'::',../@xo:id)"/>
	<xsl:key name="dataset" match="data:rows[not(@xsi:nil) and not(xo:r)]/@xo:id" use="concat(../../@xo:id,'::',../../@xo:id)"/>
	<xsl:key name="dataset" match="data:rows/@xsi:nil" use="concat(../../@xo:id,'::',../../@xo:id)"/>
	<xsl:key name="dataset" match="data:rows/xo:r/@xo:id" use="concat(../../../@xo:id,'::',../../../@xo:id)"/>
	<xsl:key name="dataset" match="px:Association/px:Entity/data:rows/xo:r/@meta:text" use="concat(ancestor::px:Entity[2]/@xo:id,'::meta:',ancestor::px:Association[1]/@Name)"/>
	<xsl:key name="dataset" match="px:Association/px:Entity/data:rows/@xsi:nil" use="concat(ancestor::px:Entity[2]/@xo:id,'::meta:',ancestor::px:Association[1]/@Name)"/>

	<xsl:key name="dataset" match="xo:r/@xo:id" use="."/>
	<xsl:key name="dataset" match="px:Association[@DataType='junctionTable']/px:Entity/px:Record/px:Association[@Name=../../*[local-name()='layout']/association:ref/@Name]/px:Entity/data:rows/xo:r/@xo:id" use="ancestor::px:Entity[2]/@xo:id"/>
	<xsl:key name="dataset" match="px:Entity[not(data:rows)]/@xo:id" use="ancestor::px:Entity[1]/@xo:id"/>
	<xsl:key name="dataset" match="data:rows[not(@xsi:nil) and not(xo:r)]/@xo:id" use="ancestor::px:Entity[1]/@xo:id"/>
	<xsl:key name="dataset" match="data:rows/@xsi:nil" use="ancestor::px:Entity[1]/@xo:id"/>
	<xsl:key name="dataset" match="data:rows/xo:r/@xo:id" use="ancestor::px:Entity[1]/@xo:id"/>
	<xsl:key name="dataset" match="px:Association/px:Entity/data:rows/xo:r/@meta:text" use="concat(ancestor::px:Entity[2]/@xo:id,'::meta:',ancestor::px:Association[1]/@Name)"/>

	<xsl:key name="field-ref" match="xo:r/@*" use="concat(../@xo:id,'::','xo:id')"/>
	<xsl:key name="field-ref" match="xo:r/@*" use="concat(../@xo:id,'::',name())"/>
	<xsl:key name="field-ref" match="xo:r/xo:f/@Name" use="concat(../@xo:id,'::',.)"/>
	<!--<xsl:key name="field-ref" match="xo:r/px:Association/@Name" use="concat(../../@xo:id,'::meta:',.)"/>-->
	<xsl:key name="field-ref" match="xo:r/px:Association/px:Entity/@xo:id" use="concat(../../../@xo:id,'::meta:',../../@Name)"/>
	
	<!--Schema-->
	<xsl:key name="schema" match="px:Record/px:*/@Name" use="concat(ancestor::px:Entity[1]/@xo:id,'::',.)"/>
	<xsl:key name="schema" match="px:Record/px:Association/@Name" use="concat(ancestor::px:Entity[1]/@xo:id,'::meta:',.)"/>

	<!--widgets-->
	<xsl:key name="widget" match="*[@control:type]/@*" use="concat(substring-before(../@control:type,':'),':',ancestor::px:Entity[1]/@xo:id)"/>

	<xsl:key name="widget" match="*[@control:type][@Schema]/@Name" use="concat(substring-before(../@control:type,':'),':',ancestor::px:Entity[1]/@xo:id,'::',../@Schema,'/',.)"/>
	<xsl:key name="widget" match="*[@control:type][not(@Schema)]/@Name" use="concat(substring-before(../@control:type,':'),':',ancestor::px:Entity[1]/@xo:id,'::',.)"/>
	<xsl:key name="widget" match="*[@control:type][not(@Schema)]/@Name" use="concat(substring-before(../@control:type,':'),':',ancestor::px:Entity[1]/@xo:id,'::meta:',.)"/>

	<xsl:key name="widget" match="*[@controlType][@Schema]/@Name" use="concat(../@controlType,':',ancestor::px:Entity[1]/@xo:id,'::',../@Schema,'/',.)"/>
	<xsl:key name="widget" match="*[@controlType][not(@Schema)]/@Name" use="concat(../@controlType,':',ancestor::px:Entity[1]/@xo:id,'::',.)"/>
	<xsl:key name="widget" match="*[@controlType][not(@Schema)]/@Name" use="concat(../@controlType,':',ancestor::px:Entity[1]/@xo:id,'::meta:',.)"/>

	<xsl:key name="widget" match="*[@DataType][@Schema]/@Name" use="concat(../@DataType,':',ancestor::px:Entity[1]/@xo:id,'::',../@Schema,'/',.)"/>
	<xsl:key name="widget" match="*[@DataType][not(@Schema)]/@Name" use="concat(../@DataType,':',ancestor::px:Entity[1]/@xo:id,'::',.)"/>
	<xsl:key name="widget" match="*[@DataType][not(@Schema)]/@Name" use="concat(../@DataType,':',ancestor::px:Entity[1]/@xo:id,'::meta:',.)"/>
	<xsl:key name="widget" match="px:Field[@DataType='filePath']/@Name" use="concat('file',':',ancestor::px:Entity[1]/@xo:id,'::',.)"/>
	<xsl:key name="widget" match="px:Field[@DataType='files']/@Name" use="concat('dropzone',':',ancestor::px:Entity[1]/@xo:id,'::',.)"/>

	<xsl:key name="widget" match="px:Field[starts-with(@control:type,'string:') and @DataLength&gt;255]/@Name" use="concat('textarea',':',ancestor::px:Entity[1]/@xo:id,'::',.)"/>
	<xsl:key name="widget" match="px:Field[starts-with(@control:type,'string:') and @DataLength=-1]/@Name" use="concat('textarea',':',ancestor::px:Entity[1]/@xo:id,'::',.)"/>
	<xsl:key name="widget" match="px:Field[starts-with(@control:type,'bit:')]/@Name" use="concat('yesNo',':',ancestor::px:Entity[1]/@xo:id,'::',.)"/>
	<xsl:key name="widget" match="px:Field[starts-with(@control:type,'integer:')]/@Name" use="concat('number',':',ancestor::px:Entity[1]/@xo:id,'::',.)"/>

	<xsl:key name="widget" match="px:Record/px:Field[@mode='readonly']/@Name" use="concat('readonly:',ancestor::px:Entity[1]/@xo:id,'::',.)"/>
	<xsl:key name="widget" match="px:Record/px:Association[@mode='readonly']/@Name" use="concat('readonly:',ancestor::px:Entity[1]/@xo:id,'::meta:',.)"/>

	<xsl:key name="widget" match="px:Record/px:Association[@Type='belongsTo'][not(@controlType)]/@Name" use="concat('combobox:',ancestor::px:Entity[1]/@xo:id,'::meta:',.)"/>

	<xsl:key name="widget" match="container:fieldSet/@Name" use="concat('fieldset:',ancestor::px:Entity[1]/@xo:id,'::',.)"/>

	<xsl:key name="widget" match="px:Record/px:Association[@Type='hasMany']/@Name" use="concat('fieldset:',ancestor::px:Entity[1]/@xo:id,'::',.)"/>

	<xsl:key name="widget" match="px:Record/px:Association[@Type='hasOne']/@Name" use="concat('fieldset:',ancestor::px:Entity[1]/@xo:id,'::',.)"/>

	<xsl:key name="form:item" match="px:Entity[@control:type='form:control']/*[local-name()='layout']//*" use="@xo:id"/>


</xsl:stylesheet>