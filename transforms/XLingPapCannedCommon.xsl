<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!--  
        DoCollectionEdition
    -->
    <xsl:template name="DoCollectionEdition">
        <xsl:if test="collection/edition">
            <xsl:text>&#x20;</xsl:text>
            <xsl:value-of select="normalize-space(collection/edition)"/>
            <xsl:call-template name="OutputPeriodIfNeeded">
                <xsl:with-param name="sText" select="collection/edition"/>
            </xsl:call-template>
            <xsl:text>&#x20;</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputFigureLabel
    -->
    <xsl:template name="OutputFigureLabel">
        <xsl:variable name="label" select="$lingPaper/@figureLabel"/>
        <xsl:choose>
            <xsl:when test="string-length($label) &gt; 0">
                <xsl:value-of select="$label"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Figure </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
