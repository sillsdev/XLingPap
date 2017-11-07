<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:saxon="http://icl.com/saxon" exclude-result-prefixes="fo rx xfc saxon ">
    <xsl:variable name="sCSSContentsLabel" select="'_contents'"/>
    <xsl:variable name="iIndent">
        <xsl:call-template name="ConvertToPoints">
            <xsl:with-param name="sValue" select="$sBlockQuoteIndent"/>
            <xsl:with-param name="iValue" select="number(substring($sBlockQuoteIndent,1,string-length($sBlockQuoteIndent) - 2))"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="iExampleWidth">
        <xsl:value-of select="number($iPageWidth - 2 * $iIndent - $iPageOutsideMargin - $iPageInsideMargin)"/>
    </xsl:variable>
    <xsl:variable name="sExampleWidth">
        <xsl:value-of select="$iExampleWidth"/>
        <xsl:text>pt</xsl:text>
    </xsl:variable>
    <xsl:variable name="sAbstract" select="'abstract'"/>
    <xsl:variable name="sAbstractText" select="'abstractText'"/>
    <xsl:variable name="sAcknowledgements" select="'acknowledgements'"/>
    <xsl:variable name="sAffiliation" select="'affiliation'"/>
    <xsl:variable name="sAppendicesTitlePage" select="'appendicesTitlePageLayout'"/>
    <xsl:variable name="sAppendixTitle" select="'appendixTitle'"/>
    <xsl:variable name="sAuthor" select="'author'"/>
    <xsl:variable name="sAuthorContactInfo" select="'authorContactInfo'"/>
    <xsl:variable name="sAuthorInContents" select="'authorInContents'"/>
    <xsl:variable name="sAuthorInChapterInCollection" select="'authorInChapterInCollection'"/>
    <xsl:variable name="sChapterTitle" select="'chapterTitle'"/>
    <xsl:variable name="sContents" select="'contents'"/>
    <xsl:variable name="sDate" select="'date'"/>
    <xsl:variable name="sEmailAddress" select="'emailAddress'"/>
    <xsl:variable name="sGlossary" select="'glossaryTitle'"/>
    <xsl:variable name="sKeywords" select="'keywords'"/>
    <xsl:variable name="sNumber" select="'number'"/>
    <xsl:variable name="sPreface" select="'preface'"/>
    <xsl:variable name="sPresentedAt" select="'presentedAt'"/>
    <xsl:variable name="sReferencesTitle" select="'referencesTitle'"/>
    <xsl:variable name="sSubtitle" select="'subtitle'"/>
    <xsl:variable name="sVersionCSS" select="'version'"/>
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
        <xsl:call-template name="GetLayoutClassNameToUse">
            <xsl:with-param name="sType" select="$sSubtitle"/>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="preceding-sibling::subtitleLayout">Two</xsl:when>
            <xsl:otherwise>One</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        DoAuthorFootnoteNumber
    -->
    <xsl:template name="DoAuthorFootnoteNumber">
        <xsl:variable name="iTitleEndnote">
            <xsl:call-template name="GetCountOfEndnoteInTitleUsingSymbol"/>
        </xsl:variable>
        <xsl:variable name="iAuthorPosition" select="count(parent::author/preceding-sibling::author[endnote]) + $iTitleEndnote + 1"/>
        <xsl:call-template name="OutputAuthorFootnoteSymbol">
            <xsl:with-param name="iAuthorPosition" select="$iAuthorPosition"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        GetAuthorLayoutClassNameToUse
    -->
    <xsl:template name="GetAuthorLayoutClassNameToUse">
        <xsl:choose>
            <xsl:when test="preceding-sibling::*[1][name()='contentsLayout']">
                <xsl:value-of select="$sAuthorInContents"/>
            </xsl:when>
            <xsl:when test="ancestor::chapterInCollectionFrontMatterLayout">
                <xsl:value-of select="$sAuthorInChapterInCollection"/>
            </xsl:when>
            <xsl:when test="ancestor::chapterInCollection">
                <xsl:value-of select="$sAuthorInChapterInCollection"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sAuthor"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        GetLayoutClassNameToUse
    -->
    <xsl:template name="GetLayoutClassNameToUse">
        <xsl:param name="sType"/>
        <xsl:value-of select="$sType"/>
        <xsl:if test="ancestor::chapterInCollectionFrontMatterLayout or ancestor::chapterInCollectionBackMatterLayout or ancestor::chapterInCollectionLayout or ancestor-or-self::chapterInCollection">
            <xsl:text>InChapterInCollection</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--
        OutputComment
    -->
    <xsl:template name="OutputComment">
        <span style="background-color:yellow;">
            <xsl:apply-templates/>
        </span>
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
    <!--  
        SetMetadata
    -->
    <xsl:template name="SetMetadata">
        <meta name="author">
            <xsl:attribute name="content">
                <xsl:call-template name="SetMetadataAuthor"/>
            </xsl:attribute>
        </meta>
        <xsl:if test="$lingPaper/frontMatter/title != ''">
            <meta name="title">
                <xsl:attribute name="content">
                    <xsl:call-template name="SetMetadataTitle"/>
                </xsl:attribute>
            </meta>
        </xsl:if>
        <xsl:if test="string-length($lingPaper/publishingInfo/keywords) &gt; 0">
            <meta name="keywords">
                <xsl:attribute name="content">
                    <xsl:call-template name="SetMetadataKeywords"/>
                </xsl:attribute>
            </meta>
        </xsl:if>
        <meta name="generator">
            <xsl:attribute name="content">
                <xsl:call-template name="SetMetadataCreator"/>
            </xsl:attribute>
        </meta>
    </xsl:template>
</xsl:stylesheet>
