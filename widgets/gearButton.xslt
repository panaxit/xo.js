<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:px="http://panax.io/entity"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:data="http://panax.io/source"
  xmlns:widget="http://panax.io/widget"
  xmlns:gearButton="http://panax.io/widget/gearButton"
  xmlns:menu="http://panax.io/widget/menu"
  exclude-result-prefixes="widget gearButton menu"
>
	<xsl:import href="keys.xslt"/>
	<xsl:import href="menu.xslt"/>
	<xsl:template mode="gearButton:widget" match="@*">
		<xsl:param name="xo:context" select="no-context"/>
		<xsl:param name="selection" select="node-expected"/>
		<xsl:param name="items" select="."/>
		<span class="input-group-append" style="color:black;">
			<style>
				<![CDATA[
				.spin {
					-webkit-animation-name: spin;
					animation-name: spin;
					-webkit-animation-duration: 4s;
					animation-duration: 4s;
					-webkit-animation-iteration-count: infinite;
					animation-iteration-count: infinite;
					-webkit-animation-timing-function: linear;
					animation-timing-function: linear;
				}
			]]></style>
			<xsl:choose>
				<xsl:when test="$xo:context/ancestor-or-self::data:rows[1][@xsi:nil or xo:r]">
					<button type="button" class="btn btn-secondary btn-lg dropdown-toggle h-100" data-bs-toggle="dropdown" aria-expanded="false" tabindex="-1">
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-gear" viewBox="0 0 16 16">
							<path d="M8 4.754a3.246 3.246 0 1 0 0 6.492 3.246 3.246 0 0 0 0-6.492zM5.754 8a2.246 2.246 0 1 1 4.492 0 2.246 2.246 0 0 1-4.492 0z"/>
							<path d="M9.796 1.343c-.527-1.79-3.065-1.79-3.592 0l-.094.319a.873.873 0 0 1-1.255.52l-.292-.16c-1.64-.892-3.433.902-2.54 2.541l.159.292a.873.873 0 0 1-.52 1.255l-.319.094c-1.79.527-1.79 3.065 0 3.592l.319.094a.873.873 0 0 1 .52 1.255l-.16.292c-.892 1.64.901 3.434 2.541 2.54l.292-.159a.873.873 0 0 1 1.255.52l.094.319c.527 1.79 3.065 1.79 3.592 0l.094-.319a.873.873 0 0 1 1.255-.52l.292.16c1.64.893 3.434-.902 2.54-2.541l-.159-.292a.873.873 0 0 1 .52-1.255l.319-.094c1.79-.527 1.79-3.065 0-3.592l-.319-.094a.873.873 0 0 1-.52-1.255l.16-.292c.893-1.64-.902-3.433-2.541-2.54l-.292.159a.873.873 0 0 1-1.255-.52l-.094-.319zm-2.633.283c.246-.835 1.428-.835 1.674 0l.094.319a1.873 1.873 0 0 0 2.693 1.115l.291-.16c.764-.415 1.6.42 1.184 1.185l-.159.292a1.873 1.873 0 0 0 1.116 2.692l.318.094c.835.246.835 1.428 0 1.674l-.319.094a1.873 1.873 0 0 0-1.115 2.693l.16.291c.415.764-.42 1.6-1.185 1.184l-.291-.159a1.873 1.873 0 0 0-2.693 1.116l-.094.318c-.246.835-1.428.835-1.674 0l-.094-.319a1.873 1.873 0 0 0-2.692-1.115l-.292.16c-.764.415-1.6-.42-1.184-1.185l.159-.291A1.873 1.873 0 0 0 1.945 8.93l-.319-.094c-.835-.246-.835-1.428 0-1.674l.319-.094A1.873 1.873 0 0 0 3.06 4.377l-.16-.292c-.415-.764.42-1.6 1.185-1.184l.292.159a1.873 1.873 0 0 0 2.692-1.115l.094-.319z"/>
						</svg>
					</button>
					<xsl:apply-templates mode="gearButton:menu" select=".">
						<xsl:with-param name="selection" select="$selection"/>
						<xsl:with-param name="items" select="$items"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<button type="button" class="btn btn-info btn-lg h-100" tabindex="-1">
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-repeat spin" viewBox="0 0 16 16">
							<path d="M11.534 7h3.932a.25.25 0 0 1 .192.41l-1.966 2.36a.25.25 0 0 1-.384 0l-1.966-2.36a.25.25 0 0 1 .192-.41zm-11 2h3.932a.25.25 0 0 0 .192-.41L2.692 6.23a.25.25 0 0 0-.384 0L.342 8.59A.25.25 0 0 0 .534 9z"/>
							<path fill-rule="evenodd" d="M8 3c-1.552 0-2.94.707-3.857 1.818a.5.5 0 1 1-.771-.636A6.002 6.002 0 0 1 13.917 7H12.9A5.002 5.002 0 0 0 8 3zM3.1 9a5.002 5.002 0 0 0 8.757 2.182.5.5 0 1 1 .771.636A6.002 6.002 0 0 1 2.083 9H3.1z"/>
						</svg>
					</button>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>

	<xsl:template mode="gearButton:option-attributes" match="@*"/>

	<xsl:template mode="gearButton:menu" match="@*">
		<xsl:param name="selection" select="node-expected"/>
		<xsl:param name="items" select="."/>
		<xsl:apply-templates mode="menu:widget" select="$items">
			<xsl:with-param name="selection" select="$selection"/>
			<xsl:with-param name="items" select="$items"/>
		</xsl:apply-templates>
	</xsl:template>
</xsl:stylesheet>
