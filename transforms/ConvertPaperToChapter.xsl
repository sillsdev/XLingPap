<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" encoding="UTF-8" indent="no" doctype-public="-//XMLmind//DTD XLingPap//EN" doctype-system="XLingPap.dtd"/>
    <!-- Style sheet to convert an XLingPaper paper into a chapter in a book (like a thesis or dissertation) document -->
    <xsl:template match="//lingPaper" priority="100">
        <lingPaper>
            <xsl:for-each select="@*">
                <xsl:copy/>
            </xsl:for-each>
            <frontMatter>
                <title>Some Book (maybe a thesis or a dissertation)</title>
                <xsl:for-each select="frontMatter/author">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </frontMatter>
            <chapter id="c1">
                <secTitle>
                    <xsl:copy-of select="frontMatter/title/text() | frontMatter/title/*"/>
                </secTitle>
                <xsl:if test="frontMatter/shortTitle">
                    <xsl:copy-of select="frontMatter/shortTitle"/>
                </xsl:if>
                <xsl:for-each select="section1">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </chapter>
            <xsl:copy-of select="backMatter"/>
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
