<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:debug="http://panax.io/debug"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt"
  xmlns:x="http://panax.io/xover"
  xmlns:state="http://panax.io/state"
  xmlns:metadata="http://panax.io/metadata"
  xmlns:session="http://panax.io/session"
  xmlns:filters="http://panax.io/filters"
  xmlns:custom="http://panax.io/custom"
  xmlns:cardview="http://panax.io/widgets/cardview"
  xmlns:datagrid="http://panax.io/widgets/datagrid"
  xmlns:source="http://panax.io/xover/binding/source"
  exclude-result-prefixes="debug msxsl x state session filters custom datagrid source cardview"
  xmlns="http://www.w3.org/1999/xhtml"
>
	<xsl:output method="xml" indent="yes" />
	<xsl:template match="*|@*" mode="cardview">
		<xsl:param name="items" select="."/>
		<div class="card-group">
			<xsl:apply-templates mode="cardview:attributes" select=".">
				<xsl:with-param name="items" select="$items"></xsl:with-param>
			</xsl:apply-templates>
			<xsl:apply-templates mode="cardview:Card" select="$items"/>
		</div>
		<!--<div class="card-group">
			<div class="card">
				<img src="..." class="card-img-top" alt="..."/>
				<div class="card-body">
					<h5 class="card-title">Card title</h5>
					<p class="card-text">This is a wider card with supporting text below as a natural lead-in to additional content. This content is a little bit longer.</p>
				</div>
				<div class="card-footer">
					<small class="text-muted">Last updated 3 mins ago</small>
				</div>
			</div>
			<div class="card">
				<img src="..." class="card-img-top" alt="..."/>
				<div class="card-body">
					<h5 class="card-title">Card title</h5>
					<p class="card-text">This card has supporting text below as a natural lead-in to additional content.</p>
				</div>
				<div class="card-footer">
					<small class="text-muted">Last updated 3 mins ago</small>
				</div>
			</div>
			<div class="card">
				<img src="..." class="card-img-top" alt="..."/>
				<div class="card-body">
					<h5 class="card-title">Card title</h5>
					<p class="card-text">This is a wider card with supporting text below as a natural lead-in to additional content. This card has even longer content than the first to show that equal height action.</p>
				</div>
				<div class="card-footer">
					<small class="text-muted">Last updated 3 mins ago</small>
				</div>
			</div>
		</div>-->
	</xsl:template>

	<xsl:template mode="cardview:Card" match="*|@*">
		<div class="card">
			<xsl:apply-templates mode="cardview:Card.attributes" select="."/>
			<xsl:apply-templates mode="cardview:Card.Picture" select="."/>
			<xsl:apply-templates mode="cardview:Card.Body" select="."/>
			<xsl:apply-templates mode="cardview:Card.Footer" select="."/>
		</div>
	</xsl:template>

	<xsl:template mode="cardview:Card" match="*[@x:deleting='true']">
		<div class="card" style="width:15px; background-color:red; flex: 0 1%;"></div>
	</xsl:template>

	<xsl:template mode="cardview:Card.Body" match="*|@*">
		<div class="card-body">
			<xsl:apply-templates mode="cardview:Card.Body.content" select="."/>
		</div>
	</xsl:template>

	<xsl:template mode="cardview:Card.Body.content" match="*|@*">
		<xsl:apply-templates mode="cardview:Card.Body.Header" select="."/>
		<xsl:apply-templates mode="cardview:Card.Body.Description" select="."/>
		<xsl:apply-templates mode="cardview:Card.Body.Footer" select="."/>
	</xsl:template>

	<xsl:template mode="cardview:Card.Footer" match="*|@*">
		<div class="card-footer">
			<xsl:apply-templates mode="cardview:Card.Footer.content" select="."/>
		</div>
	</xsl:template>

	<xsl:template mode="cardview:Card.Picture" match="*|@*">
		<xsl:variable name="id" select="ancestor-or-self::*[@x:id][1]/@x:id"/>
		<picture class="card-img-top">
			<xsl:apply-templates mode="cardview:Card.Picture.attributes" select="."/>
			<xsl:apply-templates mode="cardview:Card.Picture.Sources" select="."/>
			<xsl:apply-templates mode="cardview:Card.Image" select="."/>
		</picture>
	</xsl:template>
	<xsl:template mode="cardview:Card.Picture.attributes" match="*|@*"/>
	<xsl:template mode="cardview:Card.Picture.Sources" match="*|@*"/>

	<xsl:template mode="cardview:Card.Image" match="*|@*">
		<xsl:variable name="id" select="ancestor-or-self::*[@x:id][1]/@x:id"/>
		<xsl:variable name="class"><xsl:apply-templates mode="cardview:Card.Image.attributes.class" select="."/></xsl:variable>
		<img class="card-img-top {$class}" alt="Imagen" id="img_{$id}">
			<xsl:attribute name="src">
				<xsl:apply-templates mode="cardview:Card.Image.attributes.src" select="."/>
			</xsl:attribute>
			<xsl:apply-templates mode="cardview:Card.Image.attributes" select="."/>
		</img>
	</xsl:template>

	<xsl:template mode="cardview:Card.Body.Header" match="*|@*">
		<h5 class="card-title">
			<xsl:apply-templates mode="cardview:Card.Body.Header.content" select="."/>
		</h5>
	</xsl:template>

	<xsl:template mode="cardview:Card.Body.Description" match="*|@*">
		<p class="card-text">
			<xsl:apply-templates mode="cardview:Card.Body.Description.content" select="."/>
		</p>
	</xsl:template>

	<xsl:template mode="cardview:Card.Body.Footer" match="*|@*">
		<p class="card-text">
			<small class="text-muted">
				<xsl:apply-templates mode="cardview:Card.Body.Footer.content" select="."/>
			</small>
		</p>
	</xsl:template>

	<!-- ATTRIBUTES -->
	<xsl:template mode="cardview:attributes" match="*|@*">
		<xsl:param name="items" select="."/>
		<xsl:attribute name="class">
			<xsl:apply-templates mode="cardview:attributes.class" select=".">
				<xsl:with-param name="items" select="$items"></xsl:with-param>
			</xsl:apply-templates>
		</xsl:attribute>
		<xsl:attribute name="onclick">
			<xsl:apply-templates mode="cardview:attributes.onclick" select=".">
				<xsl:with-param name="items" select="$items"></xsl:with-param>
			</xsl:apply-templates>
		</xsl:attribute>
	</xsl:template>

	<xsl:template mode="cardview:Card.attributes" match="*|@*">
		<xsl:attribute name="class">card shadow col-2</xsl:attribute>
	</xsl:template>

	<xsl:template mode="cardview:attributes.class" match="*|@*">card-group row</xsl:template>
	<xsl:template mode="cardview:attributes.onclick" match="*|@*"/>

	<xsl:template mode="cardview:Card.attributes.class" match="*|@*"></xsl:template>
	<xsl:template mode="cardview:Card.attributes.onclick" match="*|@*"></xsl:template>

	<!-- VALUES -->
	<xsl:template mode="cardview:Card.Image.attributes" match="*|@*"/>

	<xsl:template mode="cardview:Card.Image.attributes.src" match="*|@*[.='']">resources/images/image-placeholder.jpg</xsl:template>
	<xsl:template mode="cardview:Card.Image.attributes.class" match="*|@*"></xsl:template>

	<xsl:template mode="cardview:Card.Header.content" match="text()|@*"></xsl:template>
	<xsl:template mode="cardview:Card.Description.content" match="text()|@*"></xsl:template>
	<xsl:template mode="cardview:Card.Footer.content" match="text()|@*"></xsl:template>

	<xsl:template mode="cardview:Card.Body.Header.content" match="text()|@*"></xsl:template>
	<xsl:template mode="cardview:Card.Body.Description.content" match="text()|@*"></xsl:template>
	<xsl:template mode="cardview:Card.Body.Footer.content" match="text()|@*"></xsl:template>

</xsl:stylesheet>
