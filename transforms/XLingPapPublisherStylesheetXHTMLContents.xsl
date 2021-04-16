<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" exclude-result-prefixes="fo xfc saxon" xmlns:saxon="http://icl.com/saxon">
    <xsl:include href="XLingPapPublisherStylesheetCommonContents.xsl"/>
    <!-- 
        part (contents) 
    -->
    <xsl:template match="part" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:if test="position()=1">
            <xsl:for-each select="preceding-sibling::*[name()='chapterBeforePart']">
                <xsl:apply-templates select="." mode="contents">
                    <xsl:with-param name="nLevel" select="$nLevel"/>
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:if>
        <div>
            <div>
                <xsl:attribute name="class">
                    <xsl:text>partContents</xsl:text>
                    <xsl:if test="$contentsLayoutToUse[ancestor::backMatterLayout]">
                        <xsl:value-of select="$sBackMatterContentsIdAddOn"/>
                    </xsl:if>
                </xsl:attribute>
                <a href="#{@id}" class="contentsLinkLayout">
                    <xsl:variable name="linkLayout" select="$pageLayoutInfo/linkLayout/contentsLinkLayout"/>
                    <xsl:call-template name="OutputTOCTitle">
                        <xsl:with-param name="linkLayout" select="$linkLayout"/>
                        <xsl:with-param name="sLabel">
                            <xsl:call-template name="OutputPartLabelNumberAndTitle">
                                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                                <xsl:with-param name="fInContents" select="'Y'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </a>
            </div>
            <xsl:apply-templates select="child::*[contains(name(),'chapter')]" mode="contents">
                <xsl:with-param name="nLevel" select="$nLevel"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:apply-templates>
        </div>
    </xsl:template>
    <!-- 
        section1 (contents) 
    -->
    <xsl:template match="section1" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse" select="$frontMatterLayoutInfo/contentsLayout"/>
        <xsl:variable name="iLevel">
            <xsl:value-of select="count(ancestor::chapter) + count(ancestor::chapterBeforePart) + count(ancestor::appendix) + count(ancestor::chapterInCollection)"/>
        </xsl:variable>
        <xsl:variable name="sSpaceBefore"> </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
            <xsl:with-param name="sSpaceBefore">
                <xsl:choose>
                    <xsl:when test="$contentsLayoutToUse/@spacebeforemainsection and not(ancestor::chapter) and not(ancestor::appendix) and not(ancestor::chapterInCollection)">
                        <xsl:value-of select="$contentsLayoutToUse/@spacebeforemainsection"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>0</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=2 and $bodyLayoutInfo/section2Layout/@ignore!='yes'">
            <xsl:apply-templates select="section2" mode="contents">
                <xsl:with-param name="nLevel" select="$nLevel"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    <!--  
        ForceItalicsInContentsTitle
    -->
    <xsl:template name="ForceItalicsInContentsTitle">
        <span style="font-style:italic;">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    <!--  
        OutputSectionTOC
    -->
    <xsl:template name="OutputSectionTOC">
        <xsl:param name="sLevel"/>
        <xsl:param name="sSpaceBefore" select="'0'"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputSectionNumberAndTitleInContents">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:variable name="sChapterLineIndent" select="normalize-space($contentsLayoutToUse/@chapterlineindent)"/>
                <xsl:variable name="sUnits" select="substring($sChapterLineIndent,string-length($sChapterLineIndent)-1)"/>
                <xsl:choose>
                    <xsl:when test="string-length($sChapterLineIndent)&gt;0 and $sChapterLineIndent!='0pt'">
                        <xsl:choose>
                            <xsl:when test="$sUnits='pt' or $sUnits='in' or $sUnits='mm' or $sUnits='cm'">
                                <xsl:variable name="sAmount" select="substring($sChapterLineIndent,1,string-length($sChapterLineIndent)-2)"/>
                                <xsl:value-of select="$sAmount * ($sLevel + 1)"/>
                                <xsl:value-of select="$sUnits"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$sLevel + 1"/>
                                <xsl:value-of select="$sUnits"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$sLevel"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore" select="$sSpaceBefore"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        OutputTOCLine
    -->
    <xsl:template name="OutputTOCLine">
        <xsl:param name="sLink"/>
        <xsl:param name="sLabel"/>
        <xsl:param name="sSpaceBefore" select="'0'"/>
        <xsl:param name="sIndent" select="'0'"/>
        <xsl:param name="override"/>
        <xsl:param name="fUseHalfSpacing" select="'N'"/>
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse" select="$frontMatterLayoutInfo/contentsLayout"/>
        <xsl:param name="fInListOfItems" select="'no'"/>
        <xsl:variable name="linkLayout" select="$pageLayoutInfo/linkLayout/contentsLinkLayout"/>
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $contentsLayoutToUse/@singlespaceeachcontentline='yes'">
            <div>
                <xsl:attribute name="style">
                    <xsl:choose>
                        <xsl:when test="$sLineSpacing='double'">
                            <xsl:choose>
                                <xsl:when test="$fUseHalfSpacing='Y'">
                                    <xsl:text>line-height:50%;</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>line-height:100%;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                            <xsl:choose>
                                <xsl:when test="$fUseHalfSpacing='Y'">
                                    <xsl:text>line-height:25%;</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>line-height:50%;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:text>&#xa0;</xsl:text>
            </div>
        </xsl:if>
        <div>
            <xsl:choose>
                <xsl:when test="$sIndent!='0' and $sIndent!='0pt'">
                    <xsl:attribute name="style">
                        <xsl:if test="$sSpaceBefore!='0'">
                            <xsl:text>margin-top:</xsl:text>
                            <xsl:value-of select="$sSpaceBefore"/>
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                        <xsl:variable name="indentValue" select="substring($sIndent,1,string-length($sIndent)-2)"/>
                        <xsl:choose>
                            <xsl:when test="$indentValue='' and string(number($sIndent))!='NaN' and $fInListOfItems='no'">
                                <xsl:text>text-indent:-</xsl:text>
                                <xsl:value-of select="$sIndent div 2 + 1.5"/>
                                <xsl:text>em; padding-left:</xsl:text>
                                <xsl:value-of select="1.5 * $sIndent + 1.5"/>
                                <xsl:text>em;</xsl:text>
                            </xsl:when>
                            <xsl:when test="string(number($indentValue))!='NaN' and $fInListOfItems='no' and substring($sIndent,string-length($sIndent)-1)='em'">
                                <xsl:text>text-indent:-</xsl:text>
                                <xsl:value-of select="$indentValue div 2 + 1.5"/>
                                <xsl:text>em; padding-left:</xsl:text>
                                <xsl:value-of select="1.5 * $indentValue + 1.5"/>
                                <xsl:text>em;</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>text-indent:-1em; padding-left:</xsl:text>
                                <xsl:value-of select="$sIndent"/>
                                <xsl:text>; </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="$contentsLayoutToUse/@singlespaceeachcontentline='yes'">
                            <xsl:text>line-height:</xsl:text>
                            <xsl:value-of select="$sSinglespacingLineHeight"/>
                            <xsl:text>;</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$contentsLayoutToUse/@singlespaceeachcontentline='yes'">
                        <xsl:attribute name="style">
                            <xsl:text>line-height:</xsl:text>
                            <xsl:value-of select="$sSinglespacingLineHeight"/>
                            <xsl:text>;</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <a href="#{$sLink}">
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$linkLayout"/>
                </xsl:call-template>
                <span>
                    <xsl:call-template name="OutputTOCTitle">
                        <xsl:with-param name="linkLayout" select="$linkLayout"/>
                        <xsl:with-param name="sLabel" select="$sLabel"/>
                        <xsl:with-param name="text-transform" select="$text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:call-template>
                    <xsl:text>&#xa0;</xsl:text>
                </span>
            </a>
        </div>
    </xsl:template>
    <!--  
      OutputTOCPageNumber
   -->
    <xsl:template name="OutputTOCPageNumber">
        <xsl:param name="linkLayout"/>
        <xsl:param name="sLink"/>
        <span>
            <xsl:if test="$linkLayout/@linkpagenumber!='no'">
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$linkLayout"/>
                </xsl:call-template>
            </xsl:if>
            <!--            <fo:page-number-citation ref-id="{$sLink}"/>-->
        </span>
    </xsl:template>
    <!--  
      OutputTOCTitle
   -->
    <xsl:template name="OutputTOCTitle">
        <xsl:param name="linkLayout"/>
        <xsl:param name="sLabel"/>
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse" select="saxon:node-set($contentsLayout)/contentsLayout"/>
        <span>
            <!--            <xsl:if test="$linkLayout/@linktitle!='no'">
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$linkLayout"/>
                </xsl:call-template>
            </xsl:if>
-->
            <xsl:if test="$contentsLayoutToUse/@usetext-transformofitem='yes' and string-length($text-transform) &gt; 0">
                <xsl:attribute name="style">
                    <xsl:text>text-transform:</xsl:text>
                    <xsl:value-of select="$text-transform"/>
                    <xsl:text>;</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="$sLabel"/>
        </span>
    </xsl:template>
</xsl:stylesheet>
