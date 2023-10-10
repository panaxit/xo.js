<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xsl"
>	<xsl:template name="format">
		<xsl:param name="value">0</xsl:param>
		<xsl:param name="mask">'$#,##0.00###;-$#,##0.00###'</xsl:param>
		<xsl:param name="value_for_invalid"></xsl:param>
		<xsl:choose>
			<xsl:when test="number($value)=$value">
		<xsl:value-of select="format-number($value,$mask)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value_for_invalid"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="substring-after-last">
		<xsl:param name="string" />
		<xsl:param name="delimiter" />
		<xsl:choose>
			<xsl:when test="contains($string, $delimiter)">
				<xsl:call-template name="substring-after-last">
					<xsl:with-param name="string"
					  select="substring-after($string, $delimiter)" />
					<xsl:with-param name="delimiter" select="$delimiter" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of
			 select="$string" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="substring-before-last">
		<xsl:param name="string" />
		<xsl:param name="delimiter" />
		<xsl:choose>
			<xsl:when test="contains($string, $delimiter)">
				<xsl:value-of select="concat(substring-before($string, $delimiter),$delimiter)"/>
				<xsl:call-template name="substring-before-last">
					<xsl:with-param name="string"
					  select="substring-after($string, $delimiter)" />
					<xsl:with-param name="delimiter" select="$delimiter" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="replace">
		<xsl:param name="string" />
		<xsl:param name="search" />
		<xsl:param name="replaceBy" />
		<xsl:choose>
			<xsl:when test="contains($string, $search)">
				<xsl:value-of disable-output-escaping="yes" select="substring-before($string, $search)" />
				<xsl:value-of disable-output-escaping="yes" select="$replaceBy" />
				<xsl:call-template name="replace">
					<xsl:with-param name="string" select="substring-after($string, $search)" />
					<xsl:with-param name="search" select="$search" />
					<xsl:with-param name="replaceBy" select="$replaceBy" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$string = ''">
						<xsl:text />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of disable-output-escaping="yes" select="$string" />
						<xsl:text />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="escape-apos">
		<xsl:param name="string" />
		<xsl:choose>
			<xsl:when test="contains($string, &quot;'&quot;)">
				<xsl:value-of select="substring-before($string, &quot;'&quot;)" />
				<xsl:text>''</xsl:text>
				<xsl:call-template name="escape-apos">
					<xsl:with-param name="string" select="substring-after($string, &quot;'&quot;)" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="distinct">
		<xsl:param name="set" select="set-expected"/>
		<xsl:variable name="current-item" select="$set[1]"/>
		<xsl:variable name="new-set" select="$set[string(.)!=string($current-item)]"/>
		<xsl:value-of select="concat($current-item,', ')"/>
		<xsl:if test="count($new-set)">
			<xsl:call-template name="distinct">
				<xsl:with-param name="set" select="$new-set"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>