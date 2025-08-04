<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
	<p:input port="source" primary="true"/>
	<p:output port="result" primary="true"/>
	<p:input port="parameters" kind="parameter"/>
	<p:serialization port="result" method="xml" indent="false" omit-xml-declaration="false"/>
	<p:xslt>
		<p:input port="stylesheet">
			<!-- durch Zeilenumbruch getrennte persName- und placeName-Elemente verbinden und darin auch einen zusätzlichen lb an der Stelle des Zeilenumbruchs einbinden. -->
			<p:document href="step1_connect-hi-elements.xsl"/>
		</p:input>
	</p:xslt>
	<p:xslt>
		<p:input port="stylesheet">
			<!-- überflüssige/doppelte/alte lb-Elemente löschen -->
			<p:document href="step2_delete-double-hi-lbs.xsl"/>
		</p:input>
	</p:xslt>
	<p:xslt>
		<p:input port="stylesheet">
			<!-- durch Zeilenumbruch getrennte persName- und placeName-Elemente verbinden und darin auch einen zusätzlichen lb an der Stelle des Zeilenumbruchs einbinden. -->
			<p:document href="step3_connect-names-across-lines.xsl"/>
		</p:input>
	</p:xslt>
	<p:xslt>
		<p:input port="stylesheet">
			<!-- überflüssige/doppelte/alte lb-Elemente löschen -->
			<p:document href="step4_delete-double-lb-elements.xsl"/>
		</p:input>
	</p:xslt>
</p:declare-step>