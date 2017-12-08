<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:saxon="http://icl.com/saxon">
    <xsl:include href="XLingPapPublisherStylesheetCommonContents.xsl"/>
    <!-- 
        part (contents) 
    -->
    <xsl:template match="part" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse" select="saxon:node-set($contentsLayout)/contentsLayout"/>
        <xsl:if test="position()=1">
            <xsl:for-each select="preceding-sibling::*[name()='chapterBeforePart']">
                <xsl:apply-templates select="." mode="contents">
                    <xsl:with-param name="nLevel" select="$nLevel"/>
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:if>
        <fo:block keep-with-next.within-page="2">
            <xsl:attribute name="text-align">
                <xsl:choose>
                    <xsl:when test="$contentsLayoutToUse/@partCentered!='no'">
                        <xsl:text>center</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>left</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="space-before">
                <xsl:choose>
                    <xsl:when test="$contentsLayoutToUse/@partSpaceBefore">
                        <xsl:value-of select="$contentsLayoutToUse/@partSpaceBefore"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$sBasicPointSize - 4"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="space-after">
                <xsl:choose>
                    <xsl:when test="$contentsLayoutToUse/@partSpaceAfter">
                        <xsl:value-of select="$contentsLayoutToUse/@partSpaceAfter"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$sBasicPointSize"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
            <fo:basic-link internal-destination="{@id}">
                <xsl:variable name="linkLayout" select="$pageLayoutInfo/linkLayout/contentsLinkLayout"/>
                <xsl:choose>
                    <xsl:when test="$contentsLayoutToUse/@partCentered='no' and $contentsLayoutToUse/@partShowPageNumber!='no'">
                        <xsl:call-template name="OutputTOCLine">
                            <xsl:with-param name="sLink" select="@id"/>
                            <xsl:with-param name="sLabel">
                                <xsl:call-template name="OutputPartLabelNumberAndTitle">
                                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                                </xsl:call-template>
                            </xsl:with-param>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="OutputTOCTitle">
                            <xsl:with-param name="linkLayout" select="$linkLayout"/>
                            <xsl:with-param name="sLabel">
                                <xsl:call-template name="OutputPartLabelNumberAndTitle">
                                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                                </xsl:call-template>
                            </xsl:with-param>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:basic-link>
            <xsl:apply-templates select="child::*[contains(name(),'chapter')]" mode="contents">
                <xsl:with-param name="nLevel" select="$nLevel"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:apply-templates>
        </fo:block>
    </xsl:template>
    <!-- 
        section1 (contents) 
    -->
    <xsl:template match="section1" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:variable name="iLevel">
            <xsl:value-of select="count(ancestor::chapter) + count(ancestor::chapterInCollection) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:variable name="sSpaceBefore"> </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
            <xsl:with-param name="sSpaceBefore">
                <xsl:choose>
                    <xsl:when test="saxon:node-set($contentsLayoutToUse)/@spacebeforemainsection and not(ancestor::chapter) and not(ancestor::appendix) and not(ancestor::chapterInCollection)">
                        <xsl:value-of select="saxon:node-set($contentsLayoutToUse)/@spacebeforemainsection"/>
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
        <xsl:param name="fUseHalfSpacing"/>
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse" select="saxon:node-set($contentsLayout)/contentsLayout"/>
        <xsl:variable name="linkLayout" select="$pageLayoutInfo/linkLayout/contentsLinkLayout"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $frontMatterLayoutInfo/contentsLayout/@singlespaceeachcontentline='yes'">
            <fo:block>
                <xsl:attribute name="line-height">
                    <xsl:choose>
                        <xsl:when test="$sLineSpacing='double'">
                            <xsl:text>1.2</xsl:text>
                        </xsl:when>
                        <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                            <xsl:text>.9</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:text>&#xa0;</xsl:text>
            </fo:block>
        </xsl:if>
        <fo:block>
            <xsl:attribute name="text-align-last">
                <xsl:choose>
                    <xsl:when test="$contentsLayoutToUse/@showpagenumber!='no'">
                        <xsl:text>justify</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>start</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="$sSpaceBefore!='0'">
                <xsl:attribute name="space-before">
                    <xsl:value-of select="$sSpaceBefore"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$sIndent!='0' and $sIndent!='0pt'">
                <xsl:choose>
                    <xsl:when test="string(number($sIndent))!='NaN'">
                        <xsl:attribute name="text-indent">
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="$sIndent div 2 + 1.5"/>
                            <xsl:text>em</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="start-indent">
                            <xsl:value-of select="1.5 * $sIndent + 1.5"/>
                            <xsl:text>em</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="text-indent">
                            <xsl:text>-1em</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="start-indent">
                            <xsl:value-of select="$sIndent"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="$contentsLayoutToUse/@singlespaceeachcontentline='yes'">
                <xsl:attribute name="line-height">
                    <xsl:value-of select="$sSinglespacingLineHeight"/>
                </xsl:attribute>
            </xsl:if>
            <fo:basic-link internal-destination="{$sLink}">
                <fo:inline>
                    <xsl:call-template name="OutputTOCTitle">
                        <xsl:with-param name="linkLayout" select="$linkLayout"/>
                        <xsl:with-param name="sLabel" select="$sLabel"/>
                        <xsl:with-param name="text-transform" select="$text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:call-template>
                    <xsl:text>&#xa0;</xsl:text>
                    <xsl:if test="$contentsLayoutToUse/@showpagenumber!='no'">
                        <fo:leader leader-pattern="{$contentsLayoutToUse/@betweentitleandnumber}">
                            <xsl:if test="$sFOProcessor='XFC'">
                                <xsl:attribute name="xfc:tab-position">-30pt</xsl:attribute>
                                <xsl:attribute name="xfc:tab-align">right</xsl:attribute>
                            </xsl:if>
                        </fo:leader>
                        <xsl:text>&#xa0;</xsl:text>
                        <fo:inline>
                            <xsl:call-template name="OutputTOCPageNumber">
                                <xsl:with-param name="linkLayout" select="$linkLayout"/>
                                <xsl:with-param name="sLink" select="$sLink"/>
                            </xsl:call-template>
                        </fo:inline>
                    </xsl:if>
                </fo:inline>
            </fo:basic-link>
        </fo:block>
    </xsl:template>
    <!--  
      OutputTOCPageNumber
   -->
    <xsl:template name="OutputTOCPageNumber">
        <xsl:param name="linkLayout"/>
        <xsl:param name="sLink"/>
        <fo:inline>
            <xsl:if test="$linkLayout/@linkpagenumber!='no'">
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$linkLayout"/>
                </xsl:call-template>
            </xsl:if>
            <fo:page-number-citation ref-id="{$sLink}"/>
        </fo:inline>
    </xsl:template>
    <!--  
      OutputTOCTitle
   -->
    <xsl:template name="OutputTOCTitle">
        <xsl:param name="linkLayout"/>
        <xsl:param name="sLabel"/>
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse" select="$contentsLayout/contentsLayout"/>
        <fo:inline>
            <xsl:if test="$linkLayout/@linktitle!='no'">
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$linkLayout"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$contentsLayoutToUse/@usetext-transformofitem='yes' and string-length(normalize-space($text-transform)) &gt; 0">
                <xsl:attribute name="text-transform">
                    <xsl:value-of select="$text-transform"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="$sLabel"/>
        </fo:inline>
    </xsl:template>
</xsl:stylesheet>
