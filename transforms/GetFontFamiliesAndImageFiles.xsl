<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="/">
        <xsl:variable name="fontFamilies" select="//@font-family[string-length(normalize-space(.)) &gt; 0]"/>
        <xsl:for-each select="$fontFamilies">
            <xsl:variable name="iPos" select="position()"/>
            <xsl:variable name="thisOne">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:variable>
            <xsl:variable name="seenBefore" select="$fontFamilies[position() &lt; $iPos]/. = $thisOne"/>
            <xsl:if test="not($seenBefore)">
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:text>&#x0a;</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>XLingPaper-Images&#x0a;</xsl:text>
        <xsl:variable name="images" select="//img/@src[string-length(.) &gt; 0]"/>
        <xsl:for-each select="$images">
            <xsl:variable name="iPos" select="position()"/>
            <xsl:variable name="thisOne">
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:text>&#x0a;</xsl:text>
            </xsl:variable>
            <xsl:variable name="seenBefore" select="$images[position() &lt; $iPos]/. = $thisOne"/>
            <xsl:if test="not($seenBefore)">
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:text>&#x0a;</xsl:text>
            </xsl:if>
        </xsl:for-each>
        
    </xsl:template>
</xsl:stylesheet>
