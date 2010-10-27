<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="/">
        <xsl:variable name="sLang">
            <xsl:variable name="documentLang" select="//lingPaper/@xml:lang"></xsl:variable>
            <xsl:choose>
                <xsl:when test="string-length($documentLang) &gt; 0">
                    <xsl:value-of select="$documentLang"/>
                </xsl:when>
                <xsl:otherwise>en</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates select="//indexTerm">
<!--            <xsl:sort select="term"/>-->
            <xsl:sort lang="{$sLang}" select="term[@lang=$sLang or position()=1 and not (following-sibling::term[@lang=$sLang])]"/>
            <xsl:with-param name="sLang" select="$sLang"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="//indexTerm">
        <xsl:param name="sLang"/>
        <xsl:text>"</xsl:text>
<!--        <xsl:apply-templates select="term" mode="InTerm"/>-->
        <xsl:apply-templates select="term[@lang=$sLang or position()=1 and not (following-sibling::term[@lang=$sLang])]" mode="InTerm"/>
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
