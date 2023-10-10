<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xo="http://panax.io/xover"
  xmlns:form="http://panax.io/widget/form"
  xmlns:field="http://panax.io/layout/fieldref"
  xmlns:association="http://panax.io/datatypes/association"
  xmlns:state="http://panax.io/state"
  xmlns:source="http://panax.io/xdom/binding/source"
  xmlns:container="http://panax.io/layout/container"
  xmlns:wizard="http://panax.io/widget/wizard"
  xmlns:px="http://panax.io/entity"
  exclude-result-prefixes="px form state xo source container wizard field association"
  xmlns="http://www.w3.org/1999/xhtml"
>
	<xsl:import href="keys.xslt"/>
	<xsl:key name="wizard:section" match="xo:dummy" use="concat(1,'::',ancestor::px:Entity[1]/@xo:id)"/>
	<xsl:key name="wizard:steps" match="//@xo:id" use="'counter'"/>
	<xsl:key name="optional" match="xo:dummy" use="generate-id()"/>
	<xsl:key name="invalid" match="xo:dummy" use="generate-id()"/>

	<xsl:template match="@*" mode="wizard:styles" priority="-10"/>

	<!--<xsl:template match="@*" mode="wizard:step-legend" priority="-10">
    <xsl:value-of select="@shortTitle|self::*[not(@shortTitle)]/@title"/>
  </xsl:template>-->

	<xsl:template match="@*" mode="wizard:step-legend" priority="-10"/>
	<xsl:template match="*[@headerText]/@*" mode="wizard:step-legend">
		<xsl:apply-templates select="." mode="headerText"/>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:step-panel-legend" priority="-10">
		<xsl:param name="step" select="position()"/>
		<xsl:apply-templates mode="wizard:step-legend" select=".">
			<xsl:with-param name="step" select="$step"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:active-step" priority="-10">
		<xsl:choose>
			<xsl:when test="ancestor-or-self::*[@state:active]">
				<xsl:value-of select="ancestor-or-self::*[@state:active]/@state:active"/>
			</xsl:when>
			<xsl:when test="string(ancestor-or-self::*[1]/@first_name)=''">1</xsl:when>
			<xsl:when test="string(ancestor-or-self::*[1]/@last_name)=''">2</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--<xsl:template match="@*" mode="wizard:step-legend" priority="-10">
    <xsl:param name="step" select="count(preceding-sibling::*|self::*)"/>
    <xsl:text/>Paso <xsl:value-of select="$step"/><xsl:text/>
  </xsl:template>-->

	<xsl:template match="@*" mode="wizard:widget" priority="-1">
		<xsl:param name="schema" select="ancestor::px:Entity[1]/px:Record/*[not(@AssociationName)]/@Name|ancestor::px:Entity[1]/px:Record/*/@AssociationName"/>
		<xsl:param name="dataset" select="key('dataset',ancestor::px:Entity[1]/@xo:id)"/>
		<xsl:param name="items" select="key('layout',ancestor::px:Entity[1]/@xo:id)"/>
		<xsl:param name="active">
			<xsl:apply-templates mode="wizard:active-step" select="$items[1]"/>
		</xsl:param>

		<xsl:variable name="current" select="current()"/>
		<xsl:variable name="steps" select="key('wizard:steps', 'counter')[key('wizard:section',concat(position(),'::',current()/ancestor::px:Entity[1]/@xo:id))]"/>
		<div id="wizard" class="wizard" style="display: block; min-width: fit-contents">
			<script defer="defer">
				<![CDATA[/*
var container = document.querySelector('#wizard').closest('main,body');
container.addEventListener('scroll', function() {
  let scrollThreshold = getComputedStyle(document.documentElement).getPropertyValue('--z-index-freeze-header') || 86;
  let stickyElement = document.querySelector('.wizard-progress-buttons-wrapper');
  if (container.scrollTop >= scrollThreshold) {
    stickyElement.style.position = 'absolute';
    stickyElement.style.top = scrollThreshold + 'px';
  } else {
    stickyElement.style.position = 'sticky';
    stickyElement.style.top = '0';
  }
});*/
]]>
			</script>
			<xsl:apply-templates mode="wizard:styles" select="."/>
			<div class="wizard-progress-buttons-wrapper" style="top: 0; top: 0px; position: sticky; background: white; z-index: 199;">
				<hr style="border-width: 4px; border-color: silver; margin: 0 0 1rem;"/>
				<div>
					<xsl:apply-templates mode="wizard:nav" select=".">
						<xsl:with-param name="steps" select="$steps"/>
						<xsl:with-param name="active" select="$active"/>
						<xsl:with-param name="dataset" select="$dataset"/>
					</xsl:apply-templates>
				</div>
				<hr style="border-width: 4px; border-color: silver;; margin: 1rem 0 0;"/>
			</div>
			<div class="wizard-steps-wrapper" style="position: relative; width: 100%; min-height: 500px; height: max-content;">
				<xsl:apply-templates mode="wizard:step-panel" select="$steps[position()=$active]">
					<xsl:with-param name="active" select="$active"/>
					<xsl:with-param name="step" select="$active"/>
					<xsl:with-param name="dataset" select="$dataset"/>
				</xsl:apply-templates>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:nav" priority="-1">
		<xsl:param name="active">1</xsl:param>
		<xsl:param name="steps" select="(//*/@*)[position()&lt;20]"/>
		<ul class="nav nav-pills nav-justified wizard-progress-buttons-placeholder" style="justify-content: space-around;">
			<xsl:for-each select="$steps">
				<xsl:variable name="current-step" select="position()"/>
				<xsl:variable name="items" select="key('wizard:section',concat($current-step,'::',ancestor::px:Entity[1]/@xo:id))"/>
				<xsl:apply-templates mode="wizard:step" select="$items[1]">
					<xsl:with-param name="active" select="$active"/>
					<xsl:with-param name="step" select="position()"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</ul>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:nav-panel-stepper" priority="-1">
	</xsl:template>

	<xsl:template match="@*" mode="wizard:step" priority="-1">
	</xsl:template>

	<xsl:template match="@*" mode="wizard:step" priority="-1">
		<xsl:param name="active">1</xsl:param>
		<xsl:param name="step" select="position()"/>
		<li data-position="{$step}" class="inactive" style="padding: 0px 43px;" xo-scope="inherit" xo-slot="state:active" onclick="scope.set('{$step}')">
			<xsl:variable name="completed" select="not(key('wizard:section',concat(number($step),'::',ancestor::px:Entity[1]/@xo:id))[not(key('optional',concat(ancestor::px:Entity[1]/@xo:id,'::',.))) and key('invalid',concat(ancestor::px:Entity[1]/@xo:id,'::',.))])"/>
			<xsl:choose>
				<xsl:when test="$active=$step">
					<xsl:attribute name="class">active</xsl:attribute>
				</xsl:when>
				<xsl:when test="$active&gt;$step">
					<xsl:attribute name="class">completed</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<a href="#">
				<h1>
					<xsl:value-of select="concat($step,'.')"/>
				</h1>
				<xsl:apply-templates mode="wizard:step-legend" select=".">
					<xsl:with-param name="step" select="$step"/>
				</xsl:apply-templates>
				<!--<xsl:if test="$completed">
					<span class="fas fa-check-circle wizard-icon-step-completed"></span>
				</xsl:if>-->
			</a>
		</li>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:step-title" priority="-1">
		<xsl:param name="step" select="position()"/>
		<xsl:param name="active">1</xsl:param>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-back-attributes" priority="-1">
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-back-attributes-onclick" priority="-1">
		<xsl:param name="step" select="count(preceding-sibling::*|self::*)"/>
		<xsl:text/>scope.set('<xsl:value-of select="number($step)-1"/>');
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-back-label" priority="-1">
		<xsl:text>Atrás</xsl:text>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-start-label" priority="-1">
		<xsl:text>Inicio</xsl:text>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-start" name="wizard:buttons-start" priority="-1">
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-back" name="wizard:buttons-back" priority="-1">
		<xsl:param name="step" select="count(preceding-sibling::*|self::*)"/>
		<xsl:if test="//*[key('wizard:section',concat(number($step)-1,'::',ancestor::px:Entity[1]/@xo:id))]">
			<button class="btn btn-primary pull-left wizard-button-previous" xo-slot="state:active">
				<xsl:attribute name="onclick">
					<xsl:apply-templates mode="wizard:buttons-back-attributes-onclick" select=".">
						<xsl:with-param name="step" select="$step"/>
					</xsl:apply-templates>
				</xsl:attribute>
				<xsl:apply-templates mode="wizard:buttons-back-attributes" select="."/>
				<span>
					<xsl:apply-templates mode="wizard:buttons-back-label" select="."/>
				</span>
			</button>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-next-attributes" priority="-1">
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-finish-attributes" priority="-1">
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-next-attributes-onclick" priority="-1">
		<xsl:param name="step" select="count(preceding-sibling::*|self::*)"/>
		<xsl:text/>scope.set('<xsl:value-of select="number($step)-(-1)"/>');
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-finish-attributes.onclick" priority="-1">
		<xsl:param name="step" select="count(preceding-sibling::*|self::*)"/>
		<xsl:text/>alert('Terminado')
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-next-label" priority="-1">
		<xsl:text>Siguiente</xsl:text>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-finish-label" priority="-1">
		<xsl:text>Guardar</xsl:text>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-next" name="wizard:buttons-next" priority="-1">
		<xsl:param name="step" select="count(preceding-sibling::*|self::*)"/>
		<xsl:param name="label">Siguiente</xsl:param>
		<button class="btn btn-primary pull-right wizard-button-next" xo-slot="state:active">
			<xsl:attribute name="onclick">
				<xsl:apply-templates mode="wizard:buttons-next-attributes-onclick" select=".">
					<xsl:with-param name="step" select="$step"/>
				</xsl:apply-templates>
			</xsl:attribute>
			<xsl:apply-templates mode="wizard:buttons-next-attributes" select="."/>
			<span>
				<xsl:apply-templates mode="wizard:buttons-next-label" select="."/>
			</span>
		</button>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:buttons-finish" name="wizard:buttons-finish" priority="-1">
		<xsl:param name="step" select="count(preceding-sibling::*|self::*)"/>
		<xsl:param name="label">Siguiente</xsl:param>
		<button class="btn btn-success pull-right wizard-button-finish" xo-slot="state:active">
			<xsl:attribute name="onclick">
				<xsl:apply-templates mode="wizard:buttons-finish-attributes.onclick" select=".">
					<xsl:with-param name="step" select="$step"/>
				</xsl:apply-templates>
			</xsl:attribute>
			<xsl:apply-templates mode="wizard:buttons-finish-attributes" select="."/>
			<span>
				<xsl:apply-templates mode="wizard:buttons-finish-label" select="."/>
			</span>
		</button>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:step-panel-content" priority="-1">
		<p>
			No hay nada que hacer aún en este paso. <xsl:value-of select="name(..)"/>: <xsl:value-of select="."/>
		</p>
	</xsl:template>

	<xsl:template match="@*" mode="wizard:step-panel" priority="-1">
		<xsl:param name="step" select="position()"/>
		<xsl:param name="items" select="key('wizard:section',concat($step,'::',ancestor::px:Entity[1]/@xo:id))"/>
		<xsl:param name="dataset" select="set-expected"/>
		<xsl:variable name="step-class">wizard-step step-<xsl:value-of select="$step"/></xsl:variable>
		<div id="container_{@xo:id}" class="{$step-class}" step="{$step}" data-position="{count(preceding-sibling::*|self::*)}" style="min-height: 400px; width: 100%; margin-left: 0px;" xo-scope="inherit">
			<xsl:choose>
				<xsl:when test="$step=1">
					<xsl:attribute name="class">
						<xsl:value-of select="$step-class"/><xsl:text/> active<xsl:text/>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="$step&gt;1">
					<xsl:attribute name="class">
						<xsl:value-of select="$step-class"/><xsl:text/> completed<xsl:text/>
					</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<div class="row wizard-step-title">
				<div>
					<h2 class="wizard-step-title-text">
						<xsl:apply-templates mode="wizard:step-panel-legend" select="$items[1]">
							<xsl:with-param name="step" select="$step"/>
						</xsl:apply-templates>
					</h2>
				</div>
			</div>
			<div class="step-content">
				<xsl:apply-templates mode="wizard:step-panel-content" select="$items[1]">
					<xsl:with-param name="step" select="$step"/>
					<xsl:with-param name="items" select="$items"/>
					<xsl:with-param name="dataset" select="$dataset"/>
				</xsl:apply-templates>
			</div>
			<div class="wizard-buttons-wrapper" style="display: block; padding: 1rem 0 3rem 0;">
				<div>
					<xsl:choose>
						<xsl:when test="//*[key('wizard:section',concat(number($step)-1,'::',ancestor::px:Entity[1]/@xo:id))]">
							<xsl:apply-templates select="." mode="wizard:buttons-back">
								<xsl:with-param name="step" select="$step"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="wizard:buttons-start">
								<xsl:with-param name="step" select="$step"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="//*[key('wizard:section',concat(number($step)+1,'::',ancestor::px:Entity[1]/@xo:id))]">
							<xsl:apply-templates select="." mode="wizard:buttons-next">
								<xsl:with-param name="step" select="$step"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="wizard:buttons-finish">
								<xsl:with-param name="step" select="$step"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template mode="wizard:step-panel-content" match="@*">
		<xsl:param name="step" select="0"/>
		<xsl:param name="items" select="nodes-expected"/>
		<div class="wizard-steps-wrapper" style="position: relative; width: 100%; min-height: 500px;">
			<xsl:apply-templates mode="form:widget" select="ancestor::px:Entity[1]/@xo:id">
				<xsl:with-param name="layout" select="$items[parent::field:ref or parent::association:ref]|$items/ancestor-or-self::*[1]/container:panel/*/@Name|$items/ancestor-or-self::*[1]/container:panel/*[not(@Name)]/@xo:id"/>
			</xsl:apply-templates>
		</div>
		<!--<xsl:for-each select="key('wizard:section',concat($step,'::',ancestor::px:Entity[1]/@xo:id))">
				<xsl:apply-templates mode="form.body.field" select="."/>
		</xsl:for-each>-->
	</xsl:template>
</xsl:stylesheet>