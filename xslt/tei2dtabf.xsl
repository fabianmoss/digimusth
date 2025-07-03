<?xml version="1.0" encoding="UTF-8"?>

<!-- Stylesheet zur Transformation der TEI-Digitmus-Texte zu DTABf-konformer Version.
		Nach der Transformation:
			1. Prüfen, ob im Front-Bereich alles stimmt (besonders byline und imprint).
			2. Alle 'tei:' in Elementnamen entfernen und alle ' xmlns:tei="http://www.tei-c.org/ns/1.0"'-Attribute entfernen.
			3. Whitespace zwischen teiHeader und text-Bereich entfernen.
			4. Falls Inhaltsverzeichnis: Seitenangaben in ref-Elemente innerhalb der item-Elemente einschließen
			5. Checken, ob die Verschachtelung der Unter-/Kapitel-Divs stimmt und die @n entsprechend anpassen.
			6.
-->
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="tei">
	
	<!-- Identity template: copies everything by default -->
	<xsl:mode on-no-match="shallow-copy"/>
	
	<!-- Suppress or change elements and attributes not allowed in DTABf (in their current form) -->
	
	<!-- Suppress facs attribute on div element -->
	<xsl:template match="tei:div/@facs"/>
	
	<!-- Suppress facs attribute on p element -->
	<xsl:template match="tei:p/@facs"/>
	
	<!-- Suppress facs attribute on lb element -->
	<xsl:template match="tei:lb/@facs"/>
	
	<!-- Suppress title elements but not their content -->
	<xsl:template match="tei:text//tei:title">
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	
	<!-- Suppress rs-elements but not their content -->
	<xsl:template match="tei:rs">
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	
	<!-- Suppress pc-elements but not their content -->
	<xsl:template match="tei:pc">
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	
	<!-- Template to suppress facsimile elements -->
	<xsl:template match="tei:facsimile"/>
	
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
	
	<!-- Suppress first div element of type other-->
	<xsl:template match="tei:div[@type='other'][1]"/>
	
	<!-- Suppress div elements of type TOC-entry -->
	<xsl:template match="tei:div[@type='TOC-entry']"/>
	
	<!-- Suppress div with type heading if it is immediately preceded by a div[@type='other'] -->
	<xsl:template match="tei:div[@type='heading']">
	</xsl:template>
	
	<!-- Change representation of page numbers to DTABf-structure -->
	<xsl:template match="tei:pb[following-sibling::*[1][self::tei:div[@type='page-number']]]">
		<xsl:variable name="new-n" select="normalize-space(string-join((following-sibling::tei:div[@type='page-number'])[1]/tei:p//text(), ''))"/>
		<tei:pb facs="{replace(@facs, '#facs_', '#f')}" n="{$new-n}"/>
	</xsl:template>
	
	<!-- Suppress the <div type='page-number'> -->
	<xsl:template match="tei:div[@type='page-number']"/>
	
	<!-- Suppress attributes from persName -->
	<xsl:template match="tei:persName">
		<tei:persName>
			<xsl:apply-templates select="node()"/>
		</tei:persName>
	</xsl:template>
	
	<!-- Insert front and fill with titlePage and table of contents -->
	<!-- Template to modify <tei:text> -->
	<xsl:template match="tei:text">
		<xsl:copy>
			<!-- Copy attributes if any -->
			<xsl:copy-of select="@*[not(name() = 'xml:space')]"/>
			
			<!-- Insert new <front> element before existing children -->
			<tei:front>
				<!-- Select all children before the <div type="other"> -->
				<xsl:apply-templates select="//tei:div[@type='other'][1]/preceding-sibling::tei:pb"/>
					<tei:titlePage type="main">
						<tei:docTitle>
							<tei:titlePart type="main">
							<!-- Extract the <title> from the first div[@type='other'] -->
							<xsl:apply-templates select=".//tei:div[@type='other'][1]//tei:title"/>
							</tei:titlePart>
						</tei:docTitle>
					</tei:titlePage>
				
					<xsl:call-template name="make-byline"/>
					<xsl:call-template name="make-docImprint"/>
					
					<!-- table of contents -->
				<xsl:if test=".//tei:div[@type='other' and following-sibling::tei:div[1][@type='heading']]">
						<tei:div type="contents">
							<tei:head><xsl:value-of select="//tei:div[@type='other']/following-sibling::tei:div[@type='heading'][1]/tei:p"/></tei:head>
							<tei:list>
								<xsl:for-each select=".//tei:div[@type='TOC-entry']/tei:p">
									<tei:item>
										<xsl:value-of select="."/>
									</tei:item>
								</xsl:for-each>
							</tei:list>
						</tei:div>
					</xsl:if>
					
			</tei:front>
			
			<!-- Copy existing children (like <body>) -->
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- front: title page -->
	
	<!-- create the byline element with content from after the title up until the end of the person-element -->
	<xsl:template name="make-byline">
		<xsl:variable name="p" select="//tei:div[@type='other'][1]/tei:p"/>
		
		<tei:byline>
			<xsl:iterate select="$p/tei:title/following-sibling::node()">
				<xsl:apply-templates select="."/>
				<xsl:if test="self::tei:persName">
					<xsl:break/>
				</xsl:if>
			</xsl:iterate>
		</tei:byline>
	</xsl:template>
	
	<!-- create the docImprint element with content from after persName until the end of the paragraph -->
	<xsl:template name="make-docImprint">
		<xsl:variable name="p" select="//tei:div[@type='other'][1]/tei:p"/>
		
		<tei:docImprint>
			<xsl:iterate select="$p/tei:persName/following-sibling::node()">
				<xsl:apply-templates select="."/>
			</xsl:iterate>
		</tei:docImprint>
	</xsl:template>
	
	<!-- Change first persName after title to docAuthor -->
	<xsl:template match="tei:div[@type='other'][1]//tei:persName">
		<tei:docAuthor>
			<xsl:apply-templates select="node()"/>
		</tei:docAuthor>
	</xsl:template>
	
	<!-- Change first placeName after title to pubPlace -->
	<xsl:template match="tei:div[@type='other'][1]//tei:placeName">
		<tei:pubPlace>
			<xsl:apply-templates select="node()"/>
		</tei:pubPlace>
	</xsl:template>
	
	<!-- Change first date after title to docDate -->
	<xsl:template match="tei:div[@type='other'][1]//tei:date">
		<tei:docDate>
			<xsl:apply-templates select="@* | node()"/>
		</tei:docDate>
	</xsl:template>
	
	<!-- body: create chapters -->
	<xsl:template match="tei:div[@type='heading'][not(preceding-sibling::tei:div[1][@type='other'])]">
		<tei:div type="chapter">
			
			<!-- Transform p to head -->
			<xsl:apply-templates select="tei:p" mode="make-head"/>
			
			<!-- Include all following siblings up to the next heading -->
			<xsl:variable name="nextHeading" select="following-sibling::tei:div[@type='heading'][1]"/>
			
			<xsl:for-each select="following-sibling::*[. &lt;&lt; $nextHeading or not($nextHeading)]">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
			
		</tei:div>
	</xsl:template>
	
	<!-- Mode to transform p into head -->
	<xsl:template match="tei:p" mode="make-head">
		<tei:head>
			<xsl:apply-templates select="node()"/>
		</tei:head>
	</xsl:template>
	
	<!-- Suppress everything that has been copied into the newly generated div@type=chapter already -->
	<!-- fehlt! -->
	
	<!-- Template to handle div[@type='paragraph-continued'] -->
	<xsl:template match="tei:div[@type='paragraph-continued']">
		<tei:p>
			<xsl:apply-templates select="tei:p/node()"/>
			
			<xsl:variable name="nextParaDiv" select="following-sibling::tei:div[@type='paragraph'][1]"/>
			
			<xsl:if test="$nextParaDiv">
				<xsl:for-each select="
					following-sibling::node()
					[
					generate-id() != generate-id($nextParaDiv)
					and (self::tei:pb or self::tei:div[@type='page-number'])
					and generate-id() &lt; generate-id($nextParaDiv)
					]
					">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
				
				<xsl:apply-templates select="$nextParaDiv/tei:p/node()"/>
			</xsl:if>
		</tei:p>
	</xsl:template>
	
	<!-- Suppress the next paragraph div that is immediately after paragraph-continued -->
	<xsl:template match="tei:div[@type='paragraph' and preceding-sibling::tei:div[1][@type='paragraph-continued']]"/>
	
	
</xsl:stylesheet>
