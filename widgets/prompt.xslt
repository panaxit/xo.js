<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:source="http://panax.io/fetch/request"
  xmlns:data="http://panax.io/source"
  xmlns:meta="http://panax.io/metadata"
  xmlns:session="http://panax.io/session"
  xmlns:state="http://panax.io/state"
  xmlns:px="http://panax.io"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:widget="http://panax.io/widget"
  xmlns:modal="http://panax.io/widget/modal"
  exclude-result-prefixes="widget px state xo source"
>
	<xsl:import href="modal.xslt"/>
	<xsl:key name="hidden" match="node-expected" use="generate-id()"/>
	<xsl:key name="invalid" match="node-expected" use="generate-id()"/>
	<xsl:key name="optional" match="node-expected" use="generate-id()"/>

	<xsl:template match="Routine/@*" mode="widget">
		<xsl:apply-templates mode="widget"/>
	</xsl:template>

	<xsl:template mode="headerText" match="Routine/@*">
		<xsl:value-of select="concat(../@Schema,' - ',../@Name)"/>
	</xsl:template>

	<xsl:template mode="prepare_value" match="@*">
		<xsl:text>`</xsl:text>
		<xsl:apply-templates select="."/>
		<xsl:text>`</xsl:text>
	</xsl:template>

	<xsl:template mode="prepare_value" match="@*[key('widget',concat('datetime:',ancestor::*[key('entity',@xo:id)][1]/@xo:id,'::',../@name))]">
		<xsl:text>`</xsl:text>
		<xsl:apply-templates select="."/>
		<xsl:text>:00</xsl:text>
		<xsl:text>`</xsl:text>
	</xsl:template>

	<xsl:template mode="prepare_value" match="@value[.='DEFAULT' or .='NULL' or number(.)=.]">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="parameter/@name" mode="headerText">
		<xsl:value-of select="substring(.,2)"/>
	</xsl:template>

	<xsl:template match="parameter/@name[contains(.,'@Id')]" mode="headerText">
		<xsl:value-of select="substring(.,4)"/>
	</xsl:template>

	<xsl:template match="parameter/@value" mode="headerText">
		<xsl:apply-templates mode="headerText" select="../@name"/>
	</xsl:template>

	<xsl:template mode="widget:options" match="parameter/@value"/>

	<xsl:template mode="widget:options" match="parameter[data:rows]/@value">
		<xsl:param name="catalog" select="xo:dummy"/>
		<datalist id="options_{../@xo:id}">
			<xsl:for-each select="../data:rows/xo:r">
				<option value="{@meta:text}"/>
			</xsl:for-each>
		</datalist>
	</xsl:template>

	<xsl:template mode="widget:attributes" match="parameter/@value"/>

	<xsl:template match="parameter/@xo:id" mode="widget">
		<div class="mb-3 row">
			<label class="col-sm-2 col-form-label">
				<xsl:apply-templates select="../@name" mode="headerText"/>
			</label>
			<div class="col-sm-10">
				<div class="input-group">
					<xsl:apply-templates mode="widget" select="../@value"/>
					<xsl:apply-templates mode="widget:options" select="../@value"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="*[parameter[not(key('hidden',generate-id()))]]/parameter[key('hidden',generate-id())]/@*" mode="widget"/>

	<xsl:template match="/">
		<xsl:apply-templates mode="modal:widget" select="xo:prompt/Routine/@xo:id"/>
	</xsl:template>

	<xsl:template mode="modal:body" match="@*">
		<div class="col-12 g-3">
			<xsl:apply-templates mode="widget" select="../parameter/@xo:id"/>
		</div>
	</xsl:template>

	<xsl:template match="xo:prompt" mode="modal:body">
		<xsl:apply-templates mode="widget" select="current()"/>
	</xsl:template>

	<xsl:template match="Routine/@*" mode="modal:header-title-label">
		<xsl:apply-templates mode="headerText" select="../@Name"/>
	</xsl:template>

	<xsl:template match="Routine/@*" mode="modal:footer">
			<button type="button" class="btn btn_outline_information__data" data-dismiss="modal">
				<xsl:attribute name="onclick">
					<xsl:apply-templates mode="modal:buttons-close-attributes-onclick" select="."/>
				</xsl:attribute>
				Cancelar
			</button>
		<xsl:for-each select="ancestor-or-self::*[1]">
			<button type="button" class="btn btn_information__data">
				<xsl:choose>
					<xsl:when test="not(key('invalid',generate-id())[not(key('optional',generate-id()))])">
						<xsl:attribute name="onclick">
							<xsl:text/>const NULL = null; const DEFAULT = 'DEFAULT'; xo.server.request({command:`[<xsl:value-of select="@Schema"/>].[<xsl:value-of select="@Name"/>]`<xsl:text/>
							<xsl:for-each select="*">
								<xsl:text>,</xsl:text>
								<xsl:text>"</xsl:text>
								<xsl:apply-templates select="@name"/>
								<xsl:text>":</xsl:text>
								<xsl:choose>
									<xsl:when test="string(@value)!=''">
										<xsl:apply-templates mode="prepare_value" select="@value"/>
									</xsl:when>
									<xsl:when test="text()">
										<xsl:apply-templates select="text()"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>NULL</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
							<xsl:text>}).then(_ => this.closest('[role="alertdialog"]').remove());</xsl:text>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="class">btn btn_information__data disabled</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				Enviar
			</button>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="modal:attributes-class">modal-prompt</xsl:template>

</xsl:stylesheet>
