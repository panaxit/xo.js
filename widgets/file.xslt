<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:px="http://panax.io/entity"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:data="http://panax.io/source"
xmlns:meta="http://panax.io/metadata"
xmlns:widget="http://panax.io/widget"
xmlns:login="http://panax.io/widget/login"
xmlns:file="http://panax.io/widget/file"
xmlns:state="http://panax.io/state"
xmlns:text="http://panax.io/state/text"
xmlns:form="http://panax.io/widget/form"
xmlns:source="http://panax.io/xover/binding/source"
xmlns:js="http://panax.io/languages/javascript"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
exclude-result-prefixes="#default xo session sitemap login widget state source js meta xsi"
>
	<xsl:import href="keys.xslt"/>
	<xsl:import href="../functions.xslt"/>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>

	<xsl:key name="file:widget" match="node-expected" use="concat(@xo:id,'::header')"/>

	<xsl:attribute-set name="file:attributes">
	</xsl:attribute-set>

	<xsl:template mode="file:preceding-siblings" match="@*"></xsl:template>
	<xsl:template mode="file:following-siblings" match="@*"></xsl:template>

	<xsl:key name="display-text" match="xo:r/@text:*" use="concat(../@xo:id, '::',local-name())" />

	<xsl:template mode="file:widget-actions-remove" match="@*"></xsl:template>

	<xsl:template mode="file:widget-actions-remove" match="px:Entity[key('widget',concat('form:',@xo:id,'::',@Schema,'/',@Name))]/data:rows/*/@*">
		<xsl:param name="file_index" select="required-param"/>
		<xsl:param name="style">
			<xsl:if test="../@xsi:type='mock'">visibility:hidden</xsl:if>
		</xsl:param>
		<label style="float: right; margin:10px; " alt="eliminar">
			<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="button bi bi-trash" viewBox="0 0 16 16" style="{$style}" onclick="scope.set(scope => scope.value.split(';').filter((item,ix)=>ix!={ $file_index - 1 }).join(';'))">
				<path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
				<path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
			</svg>
		</label>
	</xsl:template>

	<xsl:template mode="file:widget-actions-add" match="@*"></xsl:template>

	<xsl:template mode="file:widget-actions-add" match="px:Entity[key('widget',concat('form:',@xo:id,'::',@Schema,'/',@Name))]/data:rows/*/@*">
		<xsl:param name="ref_id" select="required-param"/>
		<xsl:param name="file_index" select="required-param"/>
		<xsl:param name="style">
			<xsl:if test="../@xsi:type='mock'">visibility:hidden</xsl:if>
		</xsl:param>
		<label for="{$ref_id}" class="file button" style="float: right; margin:10px; ">
			<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="button bi bi-file-earmark-plus" viewBox="0 0 16 16">
				<path d="M8 6.5a.5.5 0 0 1 .5.5v1.5H10a.5.5 0 0 1 0 1H8.5V11a.5.5 0 0 1-1 0V9.5H6a.5.5 0 0 1 0-1h1.5V7a.5.5 0 0 1 .5-.5z"/>
				<path d="M14 4.5V14a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V2a2 2 0 0 1 2-2h5.5L14 4.5zm-3 0A1.5 1.5 0 0 1 9.5 3V1H4a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V4.5h-2z"/>
			</svg>
		</label>
	</xsl:template>

	<xsl:template mode="file:widget" match="@*">
		<xsl:param name="files" select="."/>
		<xsl:param name="current_file" select="substring-before(concat($files,';'),';')"/>
		<xsl:param name="file_index" select="1"/>
		<xsl:param name="field" select="."/>
		<xsl:variable name="schema" select="key('schema', concat(ancestor::px:Entity[1]/@xo:id,'::',name()))"/>
		<xsl:variable name="id" select="ancestor-or-self::*[@xo:id][1]/@xo:id"/>

		<xsl:variable name="display_name">
			<xsl:choose>
				<xsl:when test="contains($current_file,'?name=')">
					<xsl:value-of select="substring-before(substring-after(concat($current_file,'&amp;'),'?name='),'&amp;')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="substring-after-last">
						<xsl:with-param name="string" select="$current_file" />
						<xsl:with-param name="delimiter" select="'\'" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="file_name">
			<xsl:choose>
				<xsl:when test="starts-with($current_file,'blob:')">
					<xsl:value-of select="substring-before(concat($current_file,'?'),'?')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$current_file"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<style>
			<![CDATA[
      .datagrid .file_control .custom-file {display:none;}
      .datagrid .file_control .input-group-append {display:none;}
      .datagrid .file_control .progress {display:none;}
      .datagrid .file_control .validar_documento {background-color: silver;}
      .datagrid td {white-space:unset;}
	  .card-body { min-height: 120px; }	  
    ]]>
		</style>

		<div class="card shadow col-2" style="width: 200px;text-align: center;">
			<div class="card-body" style="padding: unset;">
				<xsl:if test="not(self::xo:id)">
					<xsl:attribute name="xo-slot">
						<xsl:value-of select="name()"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates mode="file:preceding-siblings" select="."/>
				<input type="file" id="file_{$id}" hidden="">
					<xsl:if test="key('widget',concat('files:',ancestor::px:Entity[1]/@xo:id,'::',../@Schema,'/',name()))">
						<xsl:attribute name="multiple"/>
					</xsl:if>
					<xsl:if test="not(self::*)">
						<xsl:attribute name="xo-slot">
							<xsl:value-of select="name()"/>
						</xsl:attribute>
					</xsl:if>
				</input>
				<xsl:variable name="style">
					<xsl:if test="../@xsi:type='mock'">visibility:hidden</xsl:if>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test=".!=''">
						<xsl:apply-templates mode="file:widget-actions-remove" select=".">
							<xsl:with-param name="style" select="$style"/>
							<xsl:with-param name="file_index" select="$file_index"/>
						</xsl:apply-templates>
						<a href="{$file_name}" style="float: left; margin:10px; {$style}" target="_blank">
							<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-box-arrow-up-right" viewBox="0 0 16 16">
								<path fill-rule="evenodd" d="M8.636 3.5a.5.5 0 0 0-.5-.5H1.5A1.5 1.5 0 0 0 0 4.5v10A1.5 1.5 0 0 0 1.5 16h10a1.5 1.5 0 0 0 1.5-1.5V7.864a.5.5 0 0 0-1 0V14.5a.5.5 0 0 1-.5.5h-10a.5.5 0 0 1-.5-.5v-10a.5.5 0 0 1 .5-.5h6.636a.5.5 0 0 0 .5-.5z"/>
								<path fill-rule="evenodd" d="M16 .5a.5.5 0 0 0-.5-.5h-5a.5.5 0 0 0 0 1h3.793L6.146 9.146a.5.5 0 1 0 .708.708L15 1.707V5.5a.5.5 0 0 0 1 0v-5z"/>
							</svg>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="file:widget-actions-add" select=".">
							<xsl:with-param name="ref_id" select="concat('file_',$id)"/>
							<xsl:with-param name="style" select="$style"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
				<!--<xsl:value-of select="$display_name"/>-->
				<img id="{@xo:id}" src="{$current_file}" style="height:100px;" />
			</div>
			<div class="card-footer">
				<xsl:value-of select="$display_name"/>
				<xsl:apply-templates mode="file:following-siblings" select="."/>
			</div>
		</div>
		<xsl:if test="contains($files,';')">
			<xsl:apply-templates mode="file:widget" select=".">
				<xsl:with-param name="files" select="substring-after($files,';')"></xsl:with-param>
				<xsl:with-param name="file_index" select="$file_index + 1"/>
			</xsl:apply-templates>
		</xsl:if>
		<!--<div class="input-group mb-2 file_control">
			<xsl:choose>
				<xsl:when test="$data_field/@value!=''">
					<div class="input-group-prepend">
						<button class="btn btn-outline-info" type="button">
							<xsl:choose>
								<xsl:when test="starts-with(@value,'blob:')">
									<a href="{@value}" style="float: left; margin:10px;" target="_blank">
										<i class="fas fa-external-link-alt" style="cursor:pointer;"></i>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="onclick">
										<xsl:text/>window.open('xover/server/open_file.asp?rfc={translate($data_field/ancestor::px:dataRow[last()]/RFC/@value,'\','/')}&amp;full_path={translate($full_path,'\','/')}{$file_name}','_blank');<xsl:text/>
									</xsl:attribute>
									<i class="fas fa-external-link-alt" style="cursor:pointer;"></i>
								</xsl:otherwise>
							</xsl:choose>
						</button>
						-->
		<!--<xsl:if test="not(starts-with(@value,'blob:'))">
							<button class="btn btn-outline-info" type="button" onclick="window.open('xover/server/download_file.asp?rfc={translate($data_field/ancestor::px:dataRow[last()]/RFC/@value,'\','/')}&amp;full_path={translate($full_path,'\','/')}{$file_name}');">
								<i class="fas fa-download" style="cursor:pointer;"></i>
							</button>
						</xsl:if>
						<xsl:if test="$data_field[self::RFC]">
							-->
		<!--
						-->
		<!-- CIF -->
		<!--
						-->
		<!--
							<button class="btn btn-outline-info" type="button" onclick="var id_CIF = prompt('IdCIF',''); if (!id_CIF) return; window.open('https://siat.sat.gob.mx/app/qr/faces/pages/mobile/validadorqr.jsf?D1=10&amp;D2=1&amp;D3='+id_CIF+'_{translate($data_field/ancestor::px:dataRow[last()]/RFC/@value,'\','/')}','_blank');">
								<i class="fas fa-globe" style="cursor:pointer;"></i>
							</button>
						</xsl:if>
						<xsl:if test="$data_field[self::OpinionCumplimiento]">
							-->
		<!--
						-->
		<!-- OPINION -->
		<!--
						-->
		<!--
							<button class="btn btn-outline-info" type="button" onclick="window.open('https://siat.sat.gob.mx/app/qr/faces/pages/mobile/validadorqr.jsf?D1=1&amp;D2=1&amp;D3='+prompt('Folio','')+'_{translate($data_field/ancestor::px:dataRow[last()]/RFC/@value,'\','/')}_'+prompt('Fecha dd-mm-aaaa','')+'_P','_blank');">
								<i class="fas fa-globe" style="cursor:pointer;"></i>
							</button>
						</xsl:if>-->
		<!--
						<xsl:apply-templates mode="control.file.buttons.prepend" select="$data_field"/>
					</div>
				</xsl:when>
			</xsl:choose>
			<xsl:variable name="parent_folder">
				<xsl:choose>
					<xsl:when test="$type='picture'">app/custom/images</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<div class="custom-file">
				<input type="file" readonly="readonly" class="custom-file-input" id="{$data_field/@xo:id}" name="{$data_field/@xo:id}" onchange="xover.server.uploadFile(this, '{$data_field/@xo:id}', '{$parent_folder}');" xo-slot="value">
					<xsl:if test="$data_field/@value!=''">
						-->
		<!--<xsl:attribute name="type">text</xsl:attribute>-->
		<!--
						<xsl:attribute name="style">cursor:pointer;</xsl:attribute>
					</xsl:if>
				</input>
				<label for="{$data_field/@xo:id}">
					<xsl:choose>
						<xsl:when test="$data_field/@value!=''">
							<xsl:attribute name="class">custom-file-label</xsl:attribute>
							<xsl:value-of select="$display_name"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">custom-file-label text-black-50</xsl:attribute>
							Buscar archivo...
						</xsl:otherwise>
					</xsl:choose>
				</label>
				<div class="invalid-feedback">Example invalid custom file feedback</div>
				-->
		<!--<img id="{@xo:id}" src="#" alt="your image" style="height:100px;" />-->
		<!--
			</div>
			<xsl:choose>
				<xsl:when test="$data_field/@value!=''">
					<div class="input-group-append">
						<button class="btn btn-outline-danger" type="button" xo-source="{$data_field/@xo:id}" onclick="this.source.setAttribute('value','')">
							<xsl:apply-templates mode="control.attributes" select="$data_field"/>
							<i class="far fa-trash-alt" style="cursor:pointer;"></i>
						</button>
					</div>
				</xsl:when>
			</xsl:choose>
			<div class="progress" style="height: 5px; width:100%">
				<div id="_progress_bar_{$data_field/@xo:id}" class="progress-bar bg-success" role="progressbar" aria-valuenow="75" aria-valuemin="0" aria-valuemax="100">
					<xsl:if test="$data_field/@value!=''">
						<xsl:attribute name="style">
							width: <xsl:value-of select="$data_field/@state:progress"/>
						</xsl:attribute>
					</xsl:if>
				</div>
			</div>
		</div>-->
	</xsl:template>

</xsl:stylesheet>
