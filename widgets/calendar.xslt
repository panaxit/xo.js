<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:msxsl="urn:schemas-microsoft-com:xslt"
xmlns:xo="http://panax.io/xover"
xmlns:xover="http://panax.io/xover"
xmlns:state="http://panax.io/state"
xmlns:data="http://panax.io/source"
xmlns:calendar="http://panax.io/widget/calendar"
xmlns:px="http://panax.io/entity"
xmlns="http://www.w3.org/1999/xhtml"
>
	<xsl:key name="data_table" match="px:Entity" use="generate-id()"/>
	<xsl:key name="data_row" match="data:rows/xo:r/@Titulo" use="concat(ancestor::px:Entity[1]/@xo:id,'::',substring(../@Fecha,1,10))"/>
	
	<xsl:key name="month_days" match="dias/dia/@value" use="substring(.,1,7)"/>
	<xsl:key name="month_days" match="dias/dia/@value" use="substring(../following-sibling::*[6]/@value,1,7)"/>
	<xsl:key name="month_days" match="dias/dia/@value" use="substring(../preceding-sibling::*[6]/@value,1,7)"/>
	<xsl:key name="week_days" match="dias/dia/@value" use="floor(count(../preceding-sibling::*) div 7)+1"/>

	<xsl:key name="hidden" match="px:dataRow[@xo:deleting='true']" use="generate-id()"/>

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" standalone="no"/>

	<xsl:template mode="calendar:widget" match="@*">
		<script src="calendar.js"/>
		<xsl:variable name="month_days" select="key('month_days',concat('',../dias/@state:current_month))"/>
		<div class="container-fluid">
			<style>
				<![CDATA[
@media (min-width: 576px) {
.day {
	min-height: 5.2857vw;
	}
}

.highlight-enabled .sidebar-aval-calendar:hover {
    background: var(--hover-highlight)  !important;
	cursor: pointer;
}

.fc-time svg {
	margin-right: 5px;
}

.avatar-calendar {
    width: 40px;
    height: 40px;
}
]]>
			</style>
			<div class="p-3">
				<xsl:apply-templates select="." mode="calendar:header">
					<xsl:with-param name="month_days" select="$month_days"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="." mode="calendar:body">
					<xsl:with-param name="month_days" select="$month_days"/>
				</xsl:apply-templates>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:header-buttons">
		<div>
			<div class="d-inline-flex" style="position: relative;vertical-align: middle;">
				<xsl:apply-templates select="../dias/@xo:id" mode="calendar:header-buttons-back"/>
				<xsl:apply-templates select="../dias/@xo:id" mode="calendar:header-buttons-next"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:header-buttons-back">
		<button class="btn btn_information_data btn-xs mx-1" type="button" xo-scope="{../@xo:id}" xo-slot="state:current_month">
			<xsl:attribute name="onclick">
				<xsl:apply-templates mode="calendar:header-buttons-back-onclick" select="."/>
			</xsl:attribute>
			<span class="fc-icon fc-icon-chevron-left">
				<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-left" viewBox="0 0 16 16">
					<path fill-rule="evenodd" d="M15 8a.5.5 0 0 0-.5-.5H2.707l3.147-3.146a.5.5 0 1 0-.708-.708l-4 4a.5.5 0 0 0 0 .708l4 4a.5.5 0 0 0 .708-.708L2.707 8.5H14.5A.5.5 0 0 0 15 8z"/>
				</svg>
			</span>
		</button>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:header-buttons-back-onclick" priority="-1"/>

	<xsl:template match="dias/@*" mode="calendar:header-buttons-back-onclick">
		<xsl:text/>moveMonth(scope, {m:-1});<xsl:text/>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:header-buttons-next">
		<button class="btn btn_information_data btn-xs mx-1" type="button" xo-scope="{../@xo:id}" xo-slot="state:current_month">
			<xsl:attribute name="onclick">
				<xsl:apply-templates mode="calendar:header-buttons-next-onclick" select="."/>
			</xsl:attribute>
			<span class="fc-icon fc-icon-chevron-right">
				<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-right" viewBox="0 0 16 16">
					<path fill-rule="evenodd" d="M1 8a.5.5 0 0 1 .5-.5h11.793l-3.147-3.146a.5.5 0 0 1 .708-.708l4 4a.5.5 0 0 1 0 .708l-4 4a.5.5 0 0 1-.708-.708L13.293 8.5H1.5A.5.5 0 0 1 1 8z"/>
				</svg>
			</span>
		</button>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:header-buttons-next-onclick" priority="-1"/>

	<xsl:template match="dias/@*" mode="calendar:header-buttons-next-onclick">
		<xsl:text/>moveMonth(scope, {m:1});<xsl:text/>
	</xsl:template>


	<xsl:template match="@*" mode="calendar:header-title-month">
		<!--<h2 class="display-4 mb-4 text-center">-->
		<div class="mb-2">
			<h2 class="text-center fw-bold month_text" style="text-align: center;">
				<xsl:value-of select="//labels/meses/mes[@value=substring(current(),6,2)]"/>
				<xsl:value-of select="concat(' ',substring(.,1,4))"/>
			</h2>
		</div>
		<!--</h2>-->
	</xsl:template>

	<xsl:template match="@*" mode="calendar:header-buttons-month">
		<div>
			<div class="d-inline-flex">
				<xsl:apply-templates select="." mode="calendar:header-buttons-month-now"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:header-buttons-month-now">
		<xsl:param name="table" select="ancestor-or-self::*[key('data_table',generate-id())][1]"/>
		<xsl:param name="parent_record"/>
		<div class="btn btn_information_data btn-xs pull-right mx-1">
			<xsl:attribute name="onclick">
				<xsl:text/>px.request(px.getEntityInfo());<xsl:text/>
			</xsl:attribute>
			<div class="fa fa-sync-alt"/>
			Actualizar calendario
		</div>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:header">
		<xsl:param name="month_days"/>
		<header>
			<div class="fc-header-toolbar fc-toolbar fc-toolbar-ltr">
				<!--<xsl:apply-templates select="." mode="calendar:header-buttons"/>-->

				<div class="d-flex justify-content-between  align-items-center">
					<xsl:apply-templates select="." mode="calendar:header-buttons"/>
					<xsl:apply-templates select="$month_days[15]" mode="calendar:header-title-month"/>
					<xsl:apply-templates select="." mode="calendar:header-buttons-month"/>
				</div>
				<xsl:apply-templates select="../labels/diaSemana/@xo:id" mode="calendar:header-days"/>
				<!--<xsl:apply-templates select="." mode="calendar:header-buttons-month"/>-->
			</div>
		</header>
	</xsl:template>

	<xsl:template match="dia/text()" mode="calendar:header-days">
		<xsl:variable name="bg-color">
			<xsl:choose>
				<xsl:when test="count(../preceding-sibling::*) mod 2 = 1">--bg-primary</xsl:when>
				<xsl:otherwise>--bg-primary-second) !important; mix-blend-mode: var(--txt-primary-second, difference</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<h3 class="col-sm p-1 text-center text-white" style="position:relative; background-color: var({$bg-color}) !important;">
			<xsl:apply-templates select="."/>
		</h3>
	</xsl:template>

	<xsl:template match="diaSemana/@*" mode="calendar:header-days">
		<div class="row d-none d-sm-flex p-1 text-white">
			<xsl:apply-templates mode="calendar:header-days" select="../dia/text()"/>
		</div>
	</xsl:template>

	<xsl:template match="diaSemana/dia/@*" mode="calendar:header-days-name">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:body">
		<xsl:param name="month_days"/>
		<xsl:apply-templates select="../dias/@xo:id" mode="calendar:body-weeks"/>
		<div class="w-100">
		</div>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:body.tbody">
	</xsl:template>

	<xsl:template match="@*" mode="calendar:body-weeks">
		<xsl:param name="current_year" select="../@state:current_year"/>
		<xsl:param name="month" select="../@state:current_month"/>
		<xsl:param name="month_days" select="key('month_days',concat('',$month))"/>
		<xsl:for-each select="$month_days[position() mod 7=1]">
			<xsl:variable name="week_days" select="key('week_days',floor(count(../preceding-sibling::*) div 7)+1)"/>
			<xsl:if test="substring($week_days[1],1,7)=concat('',$month) or substring($week_days[last()],1,7)=concat('',$month)">
				<xsl:apply-templates select="." mode="calendar:body-weeks-week">
					<xsl:with-param name="week" select="position()"/>
					<xsl:with-param name="week_days" select="$week_days"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:body-weeks-week">
		<xsl:param name="week"/>
		<xsl:param name="week_days" select="key('week_days',$week)"/>
		<div class="row border border-right-0 border-bottom-0">
			<div class="day col-sm p-2 border border-left-0 border-top-0 text-truncate" style="background-color:#D9DADB !important;">
				<h5 class="row align-items-center">
					<span class="date col-1 fw-bold" style="text-aling:right !important;">
						<xsl:value-of select="../@week"/>
					</span>
					<span class="col-1"></span>
				</h5>
			</div>
			<xsl:apply-templates select="$week_days[1]" mode="calendar:body-days"/>
			<xsl:apply-templates select="$week_days[2]" mode="calendar:body-days"/>
			<xsl:apply-templates select="$week_days[3]" mode="calendar:body-days"/>
			<xsl:apply-templates select="$week_days[4]" mode="calendar:body-days"/>
			<xsl:apply-templates select="$week_days[5]" mode="calendar:body-days"/>
			<xsl:apply-templates select="$week_days[6]" mode="calendar:body-days"/>
			<xsl:apply-templates select="$week_days[7]" mode="calendar:body-days"/>
		</div>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:body-days">
		<xsl:param name="table" select="ancestor-or-self::*[key('data_table',generate-id())][1]"/>
		<xsl:param name="parent_record"/>
		<div  class="day col-sm p-2 border border-left-0 border-top-0 text-truncate sidebar-aval-calendar" data-date="{translate(.,' ','T')}">
			<xsl:apply-templates select="." mode="calendar:body-day"/>
		</div>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:body-day">
		<div class="row">
			<div class="col mt-0">
				<span class="date col-1">
					<xsl:value-of select="../@text"/>
				</span>
			</div>
			<xsl:apply-templates select="key('data_row', concat(ancestor::px:Entity[1]/@xo:id,'::',substring(.,1,10)))" mode="calendar:body-reservation" />
			<!--<span class="col-1"></span>-->
		</div>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:body-reservation-attributes">
	</xsl:template>

	<xsl:template match="@*" mode="calendar:body-reservation">
		<xsl:apply-templates select="ancestor::px:Entity[1]/px:Routes/px:Route/@Method[.='delete']" mode="calendar:body-reservation.button.delete" />
		<a class="fc-day-grid-event fc-event fc-start fc-end mt-1" href="javascript:void(0)">
			<xsl:apply-templates mode="calendar:body-reservation-attributes" select="."/>
			<div class="fc-content">
				<span class="fc-time">
					<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-clock mr-1" viewBox="0 0 16 16">
						<path d="M8 3.5a.5.5 0 0 0-1 0V9a.5.5 0 0 0 .252.434l3.5 2a.5.5 0 0 0 .496-.868L8 8.71V3.5z"/>
						<path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm7-8A7 7 0 1 1 1 8a7 7 0 0 1 14 0z"/>
					</svg>
					<xsl:apply-templates mode="calendar:body-reservation-description" select="."/>
					<br/>
				</span>
			</div>
		</a>
	</xsl:template>

	<xsl:template match="@*" mode="calendar:body-reservation.button.delete">
		<div class="col-auto">
			<div>
				<div class="btn btn-outline-danger btn-sm-danger">
					<xsl:attribute name="onclick">
						<xsl:apply-templates mode="calendar:body-reservation.delete-onclick" select="."/>
					</xsl:attribute>
					<span>
						<i class="far fa-trash-alt"></i>
					</span>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="*[key('data_row',generate-id())][key('hidden',generate-id())]/@*" mode="calendar:body-reservation" priority="10">
		<span class="badge_danger rounded-pill badge-danger-light mt-3">
			Reservación <br/>Eliminada
		</span>
	</xsl:template>

	
</xsl:stylesheet>