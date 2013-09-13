<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no" doctype-public="-//XMLmind//DTD XLingPap//EN" doctype-system="XLingPap.dtd"/>
<!-- Style sheet to convert an XLingPaper paper into a chapter in a collection document -->
    <xsl:template match="//lingPaper" priority="100">
        <lingPaper>
            <xsl:for-each select="@*">
                <xsl:copy/>
            </xsl:for-each>
<!--            <xsl:copy>
                <xsl:apply-templates select="@*"/>
            </xsl:copy>-->
            <frontMatter>
                <title>Some Collection Volume</title>
                <author>Name(s) of collection editor(s)</author>
            </frontMatter>
            <chapterInCollection id="cc1">
                <xsl:copy-of select="frontMatter"/>
                <xsl:for-each select="section1">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:copy-of select="backMatter"/>
            </chapterInCollection>
            <xsl:copy-of select="referencedInterlinearTexts"/>
            <xsl:copy-of select="languages"/>
            <xsl:copy-of select="types"/>
            <xsl:copy-of select="framedTypes"/>
            <xsl:copy-of select="indexTerms"/>
            <xsl:copy-of select="publishingInfo"/>
            <xsl:copy-of select="contentControl"/>
        </lingPaper>
    </xsl:template>
    <xsl:template match="//publisherStyleSheet"/>
</xsl:stylesheet>
