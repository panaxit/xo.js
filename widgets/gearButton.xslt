<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:px="http://panax.io/entity"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:widget="http://panax.io/widget"
  xmlns:gearButton="http://panax.io/widget/gearButton"
  exclude-result-prefixes="widget gearButton"
>
	<xsl:import href="keys.xslt"/>
	<xsl:template mode="gearButton:widget" match="@*">
		<xsl:param name="selection" select="node-expected"/>
		<xsl:param name="items" select="."/>
		<xsl:variable name="id" select="ancestor-or-self::*[@xo:id][1]/@xo:id"/>
		<span class="input-group-append" style="color:black;" xo-scope="{$id}">
			<button type="button" class="btn btn-secondary btn-lg dropdown-toggle h-100" data-bs-toggle="dropdown" aria-expanded="false" tabindex="-1">
				<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-gear" viewBox="0 0 16 16">
					<path d="M8 4.754a3.246 3.246 0 1 0 0 6.492 3.246 3.246 0 0 0 0-6.492zM5.754 8a2.246 2.246 0 1 1 4.492 0 2.246 2.246 0 0 1-4.492 0z"/>
					<path d="M9.796 1.343c-.527-1.79-3.065-1.79-3.592 0l-.094.319a.873.873 0 0 1-1.255.52l-.292-.16c-1.64-.892-3.433.902-2.54 2.541l.159.292a.873.873 0 0 1-.52 1.255l-.319.094c-1.79.527-1.79 3.065 0 3.592l.319.094a.873.873 0 0 1 .52 1.255l-.16.292c-.892 1.64.901 3.434 2.541 2.54l.292-.159a.873.873 0 0 1 1.255.52l.094.319c.527 1.79 3.065 1.79 3.592 0l.094-.319a.873.873 0 0 1 1.255-.52l.292.16c1.64.893 3.434-.902 2.54-2.541l-.159-.292a.873.873 0 0 1 .52-1.255l.319-.094c1.79-.527 1.79-3.065 0-3.592l-.319-.094a.873.873 0 0 1-.52-1.255l.16-.292c.893-1.64-.902-3.433-2.541-2.54l-.292.159a.873.873 0 0 1-1.255-.52l-.094-.319zm-2.633.283c.246-.835 1.428-.835 1.674 0l.094.319a1.873 1.873 0 0 0 2.693 1.115l.291-.16c.764-.415 1.6.42 1.184 1.185l-.159.292a1.873 1.873 0 0 0 1.116 2.692l.318.094c.835.246.835 1.428 0 1.674l-.319.094a1.873 1.873 0 0 0-1.115 2.693l.16.291c.415.764-.42 1.6-1.185 1.184l-.291-.159a1.873 1.873 0 0 0-2.693 1.116l-.094.318c-.246.835-1.428.835-1.674 0l-.094-.319a1.873 1.873 0 0 0-2.692-1.115l-.292.16c-.764.415-1.6-.42-1.184-1.185l.159-.291A1.873 1.873 0 0 0 1.945 8.93l-.319-.094c-.835-.246-.835-1.428 0-1.674l.319-.094A1.873 1.873 0 0 0 3.06 4.377l-.16-.292c-.415-.764.42-1.6 1.185-1.184l.292.159a1.873 1.873 0 0 0 2.692-1.115l.094-.319z"/>
				</svg>
			</button>
			<ul class="dropdown-menu">
				<xsl:apply-templates mode="gearButton:option" select="$items">
					<xsl:with-param name="selection" select="$selection"/>
					<xsl:with-param name="items" select="$items"/>
				</xsl:apply-templates>
			</ul>
		</span>
	</xsl:template>

	<xsl:template mode="gearButton:option" match="@*">
		<li>
			<a class="dropdown-item" href="#">
				<xsl:apply-templates mode="gearButton:option-attributes" select="."/>
				<xsl:apply-templates mode="gearButton:option-content" select="."/>
			</a>
		</li>
	</xsl:template>

	<xsl:template mode="gearButton:option-content" match="@*">
		<xsl:apply-templates mode="gearButton:options-label" select="."/>
	</xsl:template>
</xsl:stylesheet>
