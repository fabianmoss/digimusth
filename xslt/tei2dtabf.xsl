<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="tei">
	
	<!-- Identity template: copies everything by default -->
	<xsl:mode on-no-match="shallow-copy"/>
	
	<!-- Template to suppress facsimile elements -->
	<xsl:template match="tei:facsimile"/>
	
	<!-- Template to modify <tei:text> -->
	<xsl:template match="tei:text">
		<xsl:copy>
			<!-- Copy attributes if any -->
			<xsl:copy-of select="@*[not(name() = 'xml:space')]"/>
			
			<!-- Insert new <front> element before existing children -->
			<tei:front>
				<!-- Select all children before the <div type="other"> -->
				<xsl:apply-templates select="//tei:div[@type='other']/preceding-sibling::tei:pb"/>
					<tei:titlePage type="main">
						<tei:docTitle>
							<tei:titlePart type="main">
							<!-- Extract the <title> from the first div[@type='other'] -->
							<xsl:apply-templates select=".//tei:div[@type='other'][1]//tei:title"/>
							</tei:titlePart>
						</tei:docTitle>
					</tei:titlePage>
				
					<xsl:call-template name="make-byline"/>
				
					<!-- Select the <div type="other"> itself -->
					<xsl:apply-templates select="//tei:div[@type='other']"/>
			</tei:front>
			
			<!-- Copy existing children (like <body>) -->
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	<!-- create the byline element with content from after the title up until the end of the person-element -->
	<xsl:template name="make-byline">
		<xsl:variable name="p" select="//tei:div[@type='other']/tei:p"/>
		
		<tei:byline>
			<xsl:iterate select="$p/tei:title/following-sibling::node()">
				<xsl:apply-templates select="."/>
				<xsl:if test="self::tei:persName">
					<xsl:break/>
				</xsl:if>
			</xsl:iterate>
		</tei:byline>
	</xsl:template>

	<!-- Only copy content of title-element and not the element itself or its attributes -->
	<xsl:template match="tei:title">
			<xsl:apply-templates select="node()"/>
	</xsl:template>
	
	
	
	<!-- Suppress facs attribute on div element -->
	<xsl:template match="tei:div/@facs"/>
	
	<!-- Suppress facs attribute on p element -->
	<xsl:template match="tei:p/@facs"/>
	
	<!-- Suppress facs attribute on lb element -->
	<xsl:template match="tei:lb/@facs"/>
	
	<!-- Suppress rs-elements but not their content -->
	<xsl:template match="tei:rs">
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	
	<!-- Change first persName after title to docAuthor -->
	<xsl:template match="persName[preceding-sibling::title][1]">
		<tei:docAuthor>
			<xsl:apply-templates select="node()"/>
		</tei:docAuthor>
	</xsl:template>
	
	<xsl:template match="tei:hi">
		<xsl:copy>
			<!-- Copy other attributes unchanged -->
			<xsl:apply-templates select="@* except @rend"/>
			
			<!-- Rename @rend to @rendition and clean the unwanted part -->
			<xsl:if test="@rend">
				<xsl:attribute name="rendition">
					<xsl:choose>
						<xsl:when test="@rend[contains(., 'bold:true;')]">
							<xsl:value-of select="replace(@rend, '\s*fontSize:0\.0;\s*kerning:0;\s*bold:true;', '#b')"/>
						</xsl:when>
						<xsl:when test="@rend[contains(., 'italic:true;')]">
							<xsl:value-of select="replace(@rend, '\s*fontSize:0\.0;\s*kerning:0;\s*italic:true;', '#i')"/>
						</xsl:when>
						<xsl:when test="@rend[contains(., 'letterSpaced:true;')]">
							<xsl:value-of select="replace(@rend, '\s*fontSize:0\.0;\s*kerning:0;\s*letterSpaced:true;', '#g')"/>
						</xsl:when>
						<xsl:when test="@rend[contains(., 'superscript:true;')]">
							<xsl:value-of select="replace(@rend, '\s*fontSize:0\.0;\s*kerning:0;\s*superscript:true;', '#sup')"/>
						</xsl:when>
						<xsl:when test="@rend[contains(., 'subscript:true;')]">
							<xsl:value-of select="replace(@rend, '\s*fontSize:0\.0;\s*kerning:0;\s*subscript:true;', '#sub')"/>
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			
			<!-- Copy child nodes -->
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- Rename p elements inside div[@type='TOC-entry'] to item -->
	<xsl:template match="tei:div[@type='TOC-entry']/tei:p">
		<tei:item>
			<xsl:apply-templates select="@* | node()"/>
		</tei:item>
	</xsl:template>
	
	
	
	
	
	
	
</xsl:stylesheet>
