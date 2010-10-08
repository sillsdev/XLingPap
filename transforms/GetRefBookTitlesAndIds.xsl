<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="/">
        <xsl:apply-templates select="//refWork[book]">
        <xsl:sort select="../@citename"/>
          <xsl:sort select="refTitle"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="//refWork">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="../@citename"/>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates select="refTitle" mode="InTitle"/>
        <xsl:text> {</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>}"
</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>
</xsl:text>
    </xsl:template>
    <xsl:template match="object" mode="InTitle">
        <xsl:variable name="type" select="id(@type)"/>
        <xsl:value-of select="$type/@before"/>
        <xsl:value-of select="."/>
        <xsl:value-of select="$type/@after"/>
    </xsl:template>
</xsl:stylesheet>
