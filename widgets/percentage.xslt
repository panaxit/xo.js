<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:meta="http://panax.io/metadata"
xmlns:widget="http://panax.io/widget"
xmlns:login="http://panax.io/widget/login"
xmlns:percentage="http://panax.io/widget/percentage"
xmlns:state="http://panax.io/state"
xmlns:source="http://panax.io/xover/binding/source"
xmlns:js="http://panax.io/languages/javascript"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
exclude-result-prefixes="#default xo session sitemap login widget state source js meta xsi percentage"
>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>

	<xsl:key name="percentage:widget" match="node-expected" use="concat(@xo:id,'::header')"/>

	<xsl:attribute-set name="percentage:attributes">
	</xsl:attribute-set>

	<xsl:template mode="percentage:preceding-siblings" match="@*"></xsl:template>
	<xsl:template mode="percentage:following-siblings" match="@*"></xsl:template>

	<xsl:template mode="percentage:widget" match="@*">
		<xsl:param name="data_field" select="current()"/>
		<xsl:param name="field" select="."/>
		<xsl:param name="type"/>
		<xsl:variable name="id" select="ancestor-or-self::*[@xo:id][1]/@xo:id"/>
		<xsl:variable name="style">
			<xsl:if test="../@xsi:type='mock'">visibility:hidden</xsl:if>
		</xsl:variable>
		<div class="input-group flex-nowrap">
			<div class="input-group-prepend">
				<span id="_label_{../@xo:id}" class="input-group-text" style="margin-right:10pt; width:60px;" ondblclick="this.toggle('contenteditable','')">
					<xsl:apply-templates select="."/>&#160;</span>
			</div>
			<input id="{../@xo:id}" name="{../@xo:id}" type="range" class="form-control-range" step="5" value="0{.}" list="datalist_{../@xo:id}" oninput="document.getElementById('_label_{../@xo:id}').innerHTML=this.value+'%';" style="width:100%"/>
			<datalist id="datalist_{../@xo:id}">
				<option value="0" label="0%"></option>
				<option value="10"></option>
				<option value="20"></option>
				<option value="30"></option>
				<option value="40"></option>
				<option value="50" label="50%"></option>
				<option value="60"></option>
				<option value="70"></option>
				<option value="80"></option>
				<option value="90"></option>
				<option value="100" label="100%"></option>
			</datalist>
		</div>
	</xsl:template>

</xsl:stylesheet>
