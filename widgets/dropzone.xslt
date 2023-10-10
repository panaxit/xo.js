<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:meta="http://panax.io/metadata"
xmlns:widget="http://panax.io/widget"
xmlns:login="http://panax.io/widget/login"
xmlns:file="http://panax.io/widget/file"
xmlns:dropzone="http://panax.io/widget/dropzone"
xmlns:state="http://panax.io/state"
xmlns:text="http://panax.io/state/text"
xmlns:source="http://panax.io/xover/binding/source"
xmlns:js="http://panax.io/languages/javascript"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
exclude-result-prefixes="#default xo session sitemap login widget state source js meta xsi"
>
	<xsl:import href="../functions.xslt"/>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>

	<xsl:key name="dropzone:widget" match="node-expected" use="concat(@xo:id,'::header')"/>

	<xsl:attribute-set name="dropzone:attributes">
	</xsl:attribute-set>

	<xsl:template mode="dropzone:preceding-siblings" match="@*"></xsl:template>
	<xsl:template mode="dropzone:following-siblings" match="@*"></xsl:template>

	<xsl:key name="display-text" match="xo:r/@text:*" use="concat(../@xo:id, '::',local-name())" />
	<xsl:template mode="dropzone:widget" match="@*">
		<xsl:variable name="display_name">
			<xsl:choose>
				<xsl:when test="contains(current(),'?name=')">
					<xsl:value-of select="substring-before(substring-after(concat(.,'&amp;'),'?name='),'&amp;')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="substring-after-last">
						<xsl:with-param name="string" select="current()" />
						<xsl:with-param name="delimiter" select="'\'" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="file_name">
			<xsl:choose>
				<xsl:when test="starts-with(current(),'blob:')">
					<xsl:value-of select="substring-before(concat(.,'?'),'?')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<style>
			<![CDATA[
		.dropzone {
		  height: max-content !important;
		  position: relative;
		  width: 100%;
		  height: 200px;
		  border: 2px dashed #ccc;
		  border-radius: 5px;
		  text-align: center;
		}

		.dropzone::after {
		  content: "Suelta archivos aquí";
		  position: relative;
		  color: silver;
		  font-size: 36px;
		  font-weight: bold;
		  z-index: -1;
		}

		.dropzone.dragover {
		  border-color: #888;
		}

    ]]>
		</style>
		<div class="dropzone d-flex flex-wrap justify-content-between">
			<xsl:apply-templates mode="file:widget" select="."/>
		</div>
		<script>
			<![CDATA[
		const dropzone = document.querySelector('.dropzone');

		dropzone.addEventListener('dragover', (e) => {
		  e.preventDefault();
		  dropzone.classList.add('dragover');
		});

		dropzone.addEventListener('dragleave', (e) => {
		  e.preventDefault();
		  dropzone.classList.remove('dragover');
		});

		dropzone.addEventListener('drop', async (e) => {
			e.preventDefault();
			dropzone.classList.remove('dragover');
			let srcElement = e.target;
			let scope = srcElement.scope;
			if (!scope) return;
			const files = e.dataTransfer.files;
			let file_string = await xover.dom.fileManager(files);
			let current_files = scope.value;
			file_string.unshift(current_files);
			scope.set(file_string.filter(el => el).join(";"));
		});
		]]></script>
	</xsl:template>

</xsl:stylesheet>
