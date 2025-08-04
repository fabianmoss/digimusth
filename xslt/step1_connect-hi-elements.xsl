<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs">
	
	<xsl:output method="xml" indent="no"/>
	<xsl:mode on-no-match="shallow-copy"/>
	
	<!-- Match the target hi elements (your full logic here) -->
	<xsl:template match="hi[
		persName and
		not(following-sibling::node()[1][self::text()[normalize-space()]])
		and following-sibling::*[1][self::lb[
		not(following-sibling::node()[1][self::text()[normalize-space()]])
		and following-sibling::*[1][self::hi[@rend = current()/@rend]]
		]]
		and not(preceding-sibling::*[1][self::lb] and preceding-sibling::*[2][self::hi])
		]">
		<hi rend="{@rend}" data-merged="true">
			<xsl:copy-of select="node()"/>
			
			<!-- Start walking the lb+hi chain -->
			<xsl:variable name="rend" select="@rend"/>
			<xsl:variable name="following" select="following-sibling::node()"/>
			
			<xsl:iterate select="$following">
				<xsl:param name="i" select="1"/>
				<xsl:variable name="current-node" select="$following[$i]"/>
				<xsl:variable name="next-node" select="$following[$i + 1]"/>
				
				<xsl:choose>
					<!-- Skip whitespace -->
					<xsl:when test="$current-node/self::text()[not(normalize-space())]">
						<xsl:next-iteration>
							<xsl:with-param name="i" select="$i + 1"/>
						</xsl:next-iteration>
					</xsl:when>
					
					<!-- Match lb + hi with same rend -->
					<xsl:when test="
						$current-node[self::lb] and
						$next-node[self::hi[@rend = $rend]]
						">
						<xsl:copy-of select="$current-node"/>
						<xsl:copy-of select="$next-node/node()"/>
						
						<!-- Skip both lb and hi -->
						<xsl:next-iteration>
							<xsl:with-param name="i" select="$i + 2"/>
						</xsl:next-iteration>
					</xsl:when>
					
					<!-- Stop at anything else -->
					<xsl:otherwise>
						<xsl:break/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:iterate>
		</hi>
	</xsl:template>
	<!-- Match the target hi elements (your full logic here) -->
	<xsl:template match="hi[
		rs and
		not(following-sibling::node()[1][self::text()[normalize-space()]])
		and following-sibling::*[1][self::lb[
		not(following-sibling::node()[1][self::text()[normalize-space()]])
		and following-sibling::*[1][self::hi[@rend = current()/@rend]]
		]]
		and not(preceding-sibling::*[1][self::lb] and preceding-sibling::*[2][self::hi])
		]">
		<hi rend="{@rend}" data-merged="true">
			<xsl:copy-of select="node()"/>
			
			<!-- Start walking the lb+hi chain -->
			<xsl:variable name="rend" select="@rend"/>
			<xsl:variable name="following" select="following-sibling::node()"/>
			
			<xsl:iterate select="$following">
				<xsl:param name="i" select="1"/>
				<xsl:variable name="current-node" select="$following[$i]"/>
				<xsl:variable name="next-node" select="$following[$i + 1]"/>
				
				<xsl:choose>
					<!-- Skip whitespace -->
					<xsl:when test="$current-node/self::text()[not(normalize-space())]">
						<xsl:next-iteration>
							<xsl:with-param name="i" select="$i + 1"/>
						</xsl:next-iteration>
					</xsl:when>
					
					<!-- Match lb + hi with same rend -->
					<xsl:when test="
						$current-node[self::lb] and
						$next-node[self::hi[@rend = $rend]]
						">
						<xsl:copy-of select="$current-node"/>
						<xsl:copy-of select="$next-node/node()"/>
						
						<!-- Skip both lb and hi -->
						<xsl:next-iteration>
							<xsl:with-param name="i" select="$i + 2"/>
						</xsl:next-iteration>
					</xsl:when>
					
					<!-- Stop at anything else -->
					<xsl:otherwise>
						<xsl:break/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:iterate>
		</hi>
	</xsl:template>
	
</xsl:stylesheet>
