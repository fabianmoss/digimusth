<?xml version="1.0" encoding="UTF-8"?>

<!-- Stylesheet zum Generieren von Tables of contents in den DigiMusTh-TEI-Dateien.
	
	Nach der Transformation folgende Korrekturen vornehmen: 
	
	1. ´xmlns=""´ im div@type="contents" löschen.
	2. Nach ´<list n="\d"/>´ suchen und durch nichts ersetzen.
-->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">

	<!-- Identity template: copies everything by default -->
	<xsl:mode on-no-match="shallow-copy"/>

	<xsl:template match="tei:front">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()[not(self::tei:titlePage)]"/>

			<!-- Process titlePage first -->
			<xsl:apply-templates select="tei:titlePage"/>

			<!-- Then insert the contents div right after titlePage -->
			<div type="contents">
				<list n="1">
					<xsl:for-each select="//tei:div[@type = 'chapter'][@n = '1']">
						<item>
							<!-- Copy the chapter heading -->
							<xsl:copy-of select="tei:head//text()"/>
							<xsl:if test="contains(., /tei:div[@type = 'chapter'][@n = '2'])">
								<list n="2">
									<xsl:for-each select=".//tei:div[@type = 'chapter'][@n = '2']">
										<item>
											<!-- Copy the chapter heading -->
											<xsl:copy-of select="tei:head//text()"/>
											<xsl:if test="contains(., /tei:div[@type = 'chapter'][@n = '3'])">
												<list n="3">
													<xsl:for-each select=".//tei:div[@type = 'chapter'][@n = '3']">
														<item>
															<!-- Copy the chapter heading -->
															<xsl:copy-of select="tei:head//text()"/>
															<xsl:if test="contains(., /tei:div[@type = 'chapter'][@n = '4'])">
																<list n="4">
																	<xsl:for-each select=".//tei:div[@type = 'chapter'][@n = '4']">
																		<item>
																			<!-- Copy the chapter heading -->
																			<xsl:copy-of select="tei:head//text()"/>
																			<xsl:if test="contains(., /tei:div[@type = 'chapter'][@n = '5'])">
																				<list n="5">
																					<xsl:for-each select=".//tei:div[@type = 'chapter'][@n = '5']">
																						<item>
																							<!-- Copy the chapter heading -->
																							<xsl:copy-of select="tei:head//text()"/>
																						</item>
																					</xsl:for-each>
																				</list>
																			</xsl:if>
																		</item>
																	</xsl:for-each>
																</list>
															</xsl:if>
														</item>
													</xsl:for-each>
												</list>
											</xsl:if>
										</item>
									</xsl:for-each>
								</list>
							</xsl:if>
						</item>
					</xsl:for-each>
				</list>
			</div>

			<!-- Then continue with the rest (after titlePage) -->
			<xsl:apply-templates select="node()[not(self::tei:titlePage)]"/>
		</xsl:copy>
	</xsl:template>


</xsl:stylesheet>
