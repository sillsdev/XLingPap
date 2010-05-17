<?xml version="1.0" encoding="UTF-8"?>
<!-- transform to convert XLingPap file from version 1.10.0 to version 1.11.0
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:template match="@* |  node()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <!--
	lingPaper
	-->
    <xsl:template match="lingPaper">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="version">1.11.0</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <!--
	collPage -> collPages
	-->
    <xsl:template match="collPage">
        <collPages>
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:apply-templates/>
            </xsl:copy>
        </collPages>
    </xsl:template>
    <!--
	procPage -> procPages
	-->
    <xsl:template match="procPage">
        <procPages>
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:apply-templates/>
            </xsl:copy>
        </procPages>
    </xsl:template>
    <!--
	swap location and institution in dissertation
	-->
    <xsl:template match="dissertation">
        <xsl:copy-of select="location"/>
        <xsl:copy-of select="institution"/>
        <xsl:apply-templates select="published"/>
    </xsl:template>
    <!--
	swap location and institution in thesis
	-->
    <xsl:template match="thesis">
        <xsl:copy-of select="location"/>
        <xsl:copy-of select="institution"/>
        <xsl:apply-templates select="published"/>
    </xsl:template>
</xsl:stylesheet>
