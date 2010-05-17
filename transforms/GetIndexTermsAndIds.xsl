<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="/">
        <xsl:apply-templates select="//indexTerm">
            <xsl:sort select="term"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="//indexTerm">
        <xsl:text>"</xsl:text>
        <xsl:apply-templates select="term" mode="InTerm"/>
        <xsl:text> {</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:choose>
            <xsl:when test="string-length(@see) &gt; 0">
                <xsl:text>} (See </xsl:text>
                <xsl:value-of select="@see"/>
                <xsl:text>)"
</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>}"
</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="@id"/>
        <xsl:text>
</xsl:text>
    </xsl:template>
    <xsl:template match="object" mode="InTerm">
        <xsl:variable name="type" select="id(@type)"/>
        <xsl:value-of select="$type/@before"/>
        <xsl:value-of select="."/>
        <xsl:value-of select="$type/@after"/>
    </xsl:template>
</xsl:stylesheet>
