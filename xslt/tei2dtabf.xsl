<?xml version="1.0" encoding="UTF-8"?>

<!-- Stylesheet zur Transformation der TEI-Digitmus-Texte zu DTABf-konformer Version.
		Nach der Transformation:
			1. RNG und Schematron einfügen
			2. Alle 'tei:' in Elementnamen entfernen und alle ' xmlns:tei="http://www.tei-c.org/ns/1.0"'-Attribute entfernen. 
			3. Leere ' n=""'-Attribute entfernen.
	  !!	4. Whitespace zwischen teiHeader und text-Bereich entfernen. (Bei Transformation nicht wundern wenn das Ausgabedokument unvollsätndig aussieht und scrollen.)
			5. $ zu Beginn und Ende einer jeden formula entfernen. (XPath: //formula)
			
-->
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="tei">
	
	<!-- Identity template: copies everything by default -->
	<xsl:mode on-no-match="shallow-copy"/>
	
	<!-- Suppress or change elements and attributes not allowed in DTABf (in their current form) -->
	
	<!-- Template to suppress facsimile elements -->
	<xsl:template match="tei:facsimile"/>
	
	<!-- Template to suppress figure elements -->
	<xsl:template match="tei:figure"/>
	
	<!-- Suppress xml:space attribute on text element -->
	<xsl:template match="tei:text/@xml:space"/>
	
	<!-- Suppress ana attribute and corresp attribute on titlepart element -->
	<xsl:template match="tei:titlePart/@ana"/>
	<xsl:template match="tei:titlePart/@corresp"/>
	
	<!-- Suppress attributes from persName -->
	<xsl:template match="tei:persName">
		<tei:persName><xsl:apply-templates select="node()"/></tei:persName>
	</xsl:template>
	
	<!-- Suppress ref attribute on docAuthor element -->
	<xsl:template match="tei:docAuthor/@ref"/>
	
	<!-- Suppress title elements within body-->
	<xsl:template match="tei:body//tei:title"/>
	
	<!-- Suppress title elements within back-->
	<xsl:template match="tei:back//tei:title"/>
	
	<!-- Suppress facs attribute on note element -->
	<xsl:template match="tei:note/@facs"/>
	
	<!-- Suppress facs attribute on p element -->
	<xsl:template match="tei:p/@facs"/>
	
	<!-- Suppress facs attribute on list element -->
	<xsl:template match="tei:list/@facs"/>
	
	<!-- Suppress facs attribute on lb element -->
	<xsl:template match="tei:lb/@facs"/>
	
	<!-- Suppress rs-elements but not their content -->
	<xsl:template match="tei:rs">
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	
	<!-- Suppress pc-elements but not their content -->
	<xsl:template match="tei:pc">
		<xsl:apply-templates select="node()"/>
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
							<xsl:value-of select="string('#b')"/>
						</xsl:when>
						<xsl:when test="@rend[contains(., 'italic:true;')]">
									<xsl:value-of select="string('#i')"/>
						</xsl:when>
						<xsl:when test="@rend[contains(., 'letterSpaced:true;')]">
							<xsl:value-of select="string('#g')"/>
						</xsl:when>
						<xsl:when test="@rend[contains(., 'superscript:true;')]">
							<xsl:value-of select="string('#sup')"/>
						</xsl:when>
						<xsl:when test="@rend[contains(., 'subscript:true;')]">
							<xsl:value-of select="string('#sub')"/>
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			
			<!-- Copy child nodes -->
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- Change representation of page numbers @facs attribute -->
	<xsl:template match="tei:pb">
		<xsl:variable name="orig" select="@facs"/>
		<!-- Extract numeric part after 'facs_' -->
		<xsl:variable name="num" select="replace($orig, '^#facs_(\d+)$', '$1')"/>
		<!-- Format as 4-digit number with leading zeros -->
		<tei:pb facs="{concat('#f', format-number(number($num), '0000'))}" n="{./@n}"/>
	</xsl:template>
	
	<!-- Change representation of notadedMusic -->
	<xsl:template match="tei:notatedMusic">
		<tei:figure type="notatedMusic"/>
	</xsl:template>
	<!-- Change representation of type attribute in note -->
	<xsl:template match="tei:note/@type">
		<xsl:attribute name="type">
			<xsl:value-of select="string('remarkSource')"/>
		</xsl:attribute>
	</xsl:template>
	
	<!-- Change representation of mathematical notations -->
	<xsl:template match="tei:formula">
		<tei:formula notation="TeX"><xsl:apply-templates select="node()"/></tei:formula>
	</xsl:template>
	
	
</xsl:stylesheet>
