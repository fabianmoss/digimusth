<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">
	<xsl:output method="xml" indent="no"/>
	
	<!-- Kopiere alles aus dem Dokument, was nicht von den Templates betroffen ist. -->
	<xsl:mode on-no-match="shallow-copy"/>
	
	<xsl:key name="lb-by-facs" match="lb" use="@facs"/>
	<!-- Only keep the first lb element with this @facs value -->
	<xsl:template match="lb">
		<!-- Only keep the first lb element with this @facs value -->
		<xsl:if test="generate-id() = generate-id(key('lb-by-facs', @facs)[1])">
			<xsl:copy>
				<xsl:apply-templates select="@* | node()"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>