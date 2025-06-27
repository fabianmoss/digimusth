<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all">
	
	<!-- Identity transform: copy all nodes and attributes by default -->
	<xsl:mode on-no-match="shallow-copy"/>
	
	<!-- Match only <tei:p> elements that have a @facs attribute -->
	<xsl:template match="tei:div[@facs]">
		<xsl:copy>
			<!-- Copy existing attributes -->
			<xsl:apply-templates select="@*"/>
			
			<!-- Add the @type attribute based on the @subtype of the corresponding <zone> -->
			<xsl:variable name="facs-id" select="substring-after(@facs, '#')"/>
			<xsl:variable name="zone" select="root()//tei:zone[@xml:id = $facs-id]"/>
			<xsl:if test="$zone">
				<xsl:attribute name="type">
					<xsl:value-of select="$zone/@subtype"/>
				</xsl:attribute>
			</xsl:if>
			
			<!-- Copy child nodes -->
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
