<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="/">
        <xsl:apply-templates select="//part | //chapter | //chapterBeforePart | //section1 | //section2 | //section3 | //section4 | //section5 | //section6"/>
    </xsl:template>
    <xsl:template match="//part | //chapter | //chapterBeforePart | //section1 | //section2 | //section3 | //section4 | //section5 | //section6">
       <xsl:if test="not(ancestor::appendix)">
        <xsl:text>"</xsl:text>
        <xsl:call-template name="getNumber"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="secTitle" mode="InTitle"/>
        <xsl:text> {</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>}"
</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text> </xsl:text>
       </xsl:if>
    </xsl:template>
    <xsl:template match="object" mode="InTitle">
        <xsl:variable name="type" select="id(@type)"/>
        <xsl:value-of select="$type/@before"/>
        <xsl:value-of select="."/>
        <xsl:value-of select="$type/@after"/>
    </xsl:template>
    <xsl:template name="getNumber">
        <xsl:choose>
            <xsl:when test="ancestor-or-self::chapter">
                <xsl:number level="any" count="chapter" format="1"/>
                <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::chapterBeforePart">
                <xsl:text>0.</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:number level="multiple" count="section1 | section2 | section3 | section4 | section5 | section6" format="1.1"/>
    </xsl:template>
</xsl:stylesheet>
