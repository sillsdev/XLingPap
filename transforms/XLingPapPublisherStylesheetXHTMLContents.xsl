<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" exclude-result-prefixes="fo xfc">
    <xsl:include href="XLingPapPublisherStylesheetCommonContents.xsl"/>
    <!-- 
        part (contents) 
    -->
    <xsl:template match="part" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:if test="position()=1">
            <xsl:for-each select="preceding-sibling::*[name()='chapterBeforePart']">
                <xsl:apply-templates select="." mode="contents">
                    <!--                    <xsl:with-param name="nLevel" select="$nLevel"/>-->
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:if>
        <div>
            <div class="partContents">
                <a href="#{@id}">
                    <xsl:variable name="linkLayout" select="$pageLayoutInfo/linkLayout/contentsLinkLayout"/>
                    <xsl:call-template name="OutputTOCTitle">
                        <xsl:with-param name="linkLayout" select="$linkLayout"/>
                        <xsl:with-param name="sLabel">
                            <xsl:call-template name="OutputPartLabelNumberAndTitle"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </a>
            </div>
            <xsl:apply-templates select="child::*[contains(name(),'chapter')]" mode="contents"/>
        </div>
    </xsl:template>
    <!-- 
        section1 (contents) 
    -->
    <xsl:template match="section1" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:variable name="iLevel">
            <xsl:value-of select="count(ancestor::chapter) + count(ancestor::chapterBeforePart) + count(ancestor::appendix) + count(ancestor::chapterInCollection)"/>
        </xsl:variable>
        <xsl:variable name="sSpaceBefore"> </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
            <xsl:with-param name="sSpaceBefore">
                <xsl:choose>
                    <xsl:when test="$frontMatterLayoutInfo/contentsLayout/@spacebeforemainsection and not(ancestor::chapter) and not(ancestor::appendix) and not(ancestor::chapterInCollection)">
                        <xsl:value-of select="$frontMatterLayoutInfo/contentsLayout/@spacebeforemainsection"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>0</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="$nLevel>=2 and $bodyLayoutInfo/section2Layout/@ignore!='yes'">
            <xsl:apply-templates select="section2" mode="contents"/>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputSectionTOC
    -->
    <xsl:template name="OutputSectionTOC">
        <xsl:param name="sLevel"/>
        <xsl:param name="sSpaceBefore" select="'0'"/>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputSectionNumberAndTitleInContents"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="string-length($sChapterLineIndent)&gt;0">
                        <xsl:value-of select="$sLevel + 1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$sLevel"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore" select="$sSpaceBefore"/>
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
        <xsl:variable name="layout" select="$frontMatterLayoutInfo/contentsLayout"/>
        <xsl:variable name="linkLayout" select="$pageLayoutInfo/linkLayout/contentsLinkLayout"/>
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $frontMatterLayoutInfo/contentsLayout/@singlespaceeachcontentline='yes'">
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
            <!--            <xsl:attribute name="text-align-last">
                <xsl:choose>
                    <xsl:when test="$layout/@showpagenumber!='no'">
                        <xsl:text>justify</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>start</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            -->
            <xsl:choose>
                <xsl:when test="$sIndent!='0' and $sIndent!='0pt'">
                    <xsl:attribute name="style">
                        <xsl:if test="$sSpaceBefore!='0'">
                            <xsl:text>margin-top:</xsl:text>
                            <xsl:value-of select="$sSpaceBefore"/>
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="string(number($sIndent))!='NaN'">
                                <xsl:text>text-indent:-</xsl:text>
                                <xsl:value-of select="$sIndent div 2 + 1.5"/>
                                <xsl:text>em; padding-left:</xsl:text>
                                <xsl:value-of select="1.5 * $sIndent + 1.5"/>
                                <xsl:text>em;</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>text-indent:-1em; padding-left:</xsl:text>
                                <xsl:value-of select="$sIndent"/>
                                <xsl:text>; </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@singlespaceeachcontentline='yes'">
                            <xsl:text>line-height:</xsl:text>
                            <xsl:value-of select="$sSinglespacingLineHeight"/>
                            <xsl:text>;</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@singlespaceeachcontentline='yes'">
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
                    </xsl:call-template>
                    <xsl:text>&#xa0;</xsl:text>
                    <xsl:if test="$layout/@showpagenumber!='no'">
                        <!--                        <fo:leader leader-pattern="{$layout/@betweentitleandnumber}">
                            <xsl:if test="$sFileName='XFC'">
                                <xsl:attribute name="xfc:tab-position">-30pt</xsl:attribute>
                                <xsl:attribute name="xfc:tab-align">right</xsl:attribute>
                            </xsl:if>
                        </fo:leader>
-->
                        <!--                        <xsl:text>&#xa0;</xsl:text>
                        <span>
                            <xsl:call-template name="OutputTOCPageNumber">
                                <xsl:with-param name="linkLayout" select="$linkLayout"/>
                                <xsl:with-param name="sLink" select="$sLink"/>
                            </xsl:call-template>
                        </span>
-->
                    </xsl:if>
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
        <span>
            <!--            <xsl:if test="$linkLayout/@linktitle!='no'">
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$linkLayout"/>
                </xsl:call-template>
            </xsl:if>
-->
            <xsl:if test="$contentsLayout/contentsLayout/@usetext-transformofitem='yes' and string-length($text-transform) &gt; 0">
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
