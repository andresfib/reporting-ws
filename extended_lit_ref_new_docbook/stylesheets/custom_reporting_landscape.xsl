<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ng="http://docbook.org/docbook-ng"
                exclude-result-prefixes="ng exsl d date"
                version='1.0'>

	<xsl:import href="custom_reporting_portrait.xsl" />

	<xsl:param name="page.orientation" select="'landscape'"/>
</xsl:stylesheet>