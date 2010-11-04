<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
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
</xsl:stylesheet>
