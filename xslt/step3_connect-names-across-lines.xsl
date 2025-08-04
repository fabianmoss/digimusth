<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">
	<xsl:output method="xml" indent="no"/>
	
	<!-- Kopiere alles aus dem Dokument, was nicht von den Templates betroffen ist. -->
	<xsl:mode on-no-match="shallow-copy"/>
	
	
	<!-- Match the first <persName> containing a <pc>, followed by <lb> and another <persName> with the same @ref -->
	<xsl:template match="persName[pc and following-sibling::lb[1] and following-sibling::persName[1][@ref = ./@ref]]">
		<xsl:variable name="next-persName" select="following-sibling::persName[1][@ref = ./@ref]"/>
		<xsl:variable name="lb" select="following-sibling::lb[1]"/>
		
		<!-- Reconstruct <persName>, keeping <lb> inside -->
		<persName>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="node()"/> <!-- Keep existing content -->
			<xsl:apply-templates select="$lb"/> <!-- Move <lb> inside <persName> -->
			<xsl:apply-templates select="$next-persName/node()"/> <!-- Append content of next <persName> -->
		</persName>
	</xsl:template>
	
	<!-- Suppress the second <persName> as it is merged into the first -->
	<xsl:template match="persName[preceding-sibling::lb[1] and preceding-sibling::persName[1][pc] and @ref = preceding-sibling::persName[1]/@ref]" />
	
	
	<!-- Match the first <placeName> containing a <pc>, followed by <lb> and another <placeName> with the same @ref -->
	<xsl:template match="placeName[pc and following-sibling::lb[1] and following-sibling::placeName[1][@ref = ./@ref]]">
		<xsl:variable name="next-placeName" select="following-sibling::placeName[1][@ref = ./@ref]"/>
		<xsl:variable name="lb" select="following-sibling::lb[1]"/>
		
		<!-- Reconstruct <placeName>, keeping <lb> inside -->
		<placeName>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="node()"/> <!-- Keep existing content -->
			<xsl:apply-templates select="$lb"/> <!-- Move <lb> inside <placeName> -->
			<xsl:apply-templates select="$next-placeName/node()"/> <!-- Append content of next <placeName> -->
		</placeName>
	</xsl:template>
	
	<!-- Suppress the second <placeName> as it is merged into the first -->
	<xsl:template match="placeName[preceding-sibling::lb[1] and preceding-sibling::placeName[1][pc] and @ref = preceding-sibling::placeName[1]/@ref]" />
	
	<!-- Match the first <rs> containing a <pc>, followed by <lb> and another <rs> with the same @ana -->
	<xsl:template match="rs[pc and following-sibling::lb[1] and following-sibling::rs[1][@ana = ./@ana]]">
		<xsl:variable name="next-rs" select="following-sibling::rs[1][@ana = ./@ana]"/>
		<xsl:variable name="lb" select="following-sibling::lb[1]"/>
		
		<!-- Reconstruct <rs>, keeping <lb> inside -->
		<rs>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="node()"/> <!-- Keep existing content -->
			<xsl:apply-templates select="$lb"/> <!-- Move <lb> inside <rs> -->
			<xsl:apply-templates select="$next-rs/node()"/> <!-- Append content of next <rs> -->
		</rs>
		
		<!-- Suppress processing of the second <rs> (since it's merged) -->
		<!-- Diese Zeile führt zu Doppelungen im Text, deshalb auskommentiert. Scheint auch nicht benötigt zu werden? -->
		<!--<xsl:apply-templates select="following-sibling::*[not(self::rs[@ana = ./@ana] or self::lb)]"/>-->
	</xsl:template>
	
	<!-- Suppress the second <rs> as it is merged into the first -->
	<xsl:template match="rs[preceding-sibling::lb[1] and preceding-sibling::rs[1][pc] and @ana = preceding-sibling::rs[1]/@ana]" />
</xsl:stylesheet>