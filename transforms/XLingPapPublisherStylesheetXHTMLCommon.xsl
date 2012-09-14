<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:saxon="http://icl.com/saxon" exclude-result-prefixes="fo rx xfc saxon ">
    <xsl:variable name="sCSSContentsLabel" select="'_contents'"/>
    <!-- 
        CreateCSSContentsClassName
    -->
    <xsl:template name="CreateCSSContentsClassName">
        <xsl:value-of select="name()"/>
        <xsl:value-of select="$sCSSContentsLabel"/>
    </xsl:template>
    <!-- 
        CreateCSSName
    -->
    <xsl:template name="CreateCSSName">
        <xsl:param name="sBase"/>
        <xsl:param name="sLayout"/>
        <xsl:value-of select="$sBase"/>
        <xsl:value-of select="substring-before(name($sLayout), 'Layout')"/>
    </xsl:template>
    <!-- 
        CreateSubtitleCSSName
    -->
    <xsl:template name="CreateSubtitleCSSName">
        <xsl:text>subtitle</xsl:text>
        <xsl:choose>
            <xsl:when test="preceding-sibling::subtitleLayout">Two</xsl:when>
            <xsl:otherwise>One</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        DoAuthorFootnoteNumber
    -->
    <xsl:template name="DoAuthorFootnoteNumber">
        <xsl:variable name="iAuthorPosition" select="count(parent::author/preceding-sibling::author[endnote]) + 1"/>
        <xsl:call-template name="OutputAuthorFootnoteSymbol">
            <xsl:with-param name="iAuthorPosition" select="$iAuthorPosition"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        SetFramedTypeItem
    -->
    <xsl:template name="SetFramedTypeItem">
        <xsl:param name="sAttributeValue"/>
        <xsl:param name="sDefaultValue"/>
        <xsl:choose>
            <xsl:when test="string-length($sAttributeValue) &gt; 0">
                <xsl:value-of select="$sAttributeValue"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sDefaultValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
