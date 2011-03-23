<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" exclude-result-prefixes="fo xfc">
    <xsl:include href="XLingPapPublisherStylesheetCommonContents.xsl"/>
    <!-- 
        part (contents) 
    -->
    <xsl:template match="part" mode="contents">
        <!--        <xsl:param name="nLevel"/>-->
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
                            <xsl:call-template name="OutputPartLabel"/>
                            <xsl:text>&#x20;</xsl:text>
                            <xsl:apply-templates select="." mode="numberPart"/>
                            <xsl:text>&#xa0;</xsl:text>
                            <xsl:apply-templates select="secTitle"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </a>
            </div>
            <xsl:apply-templates select="child::*[name()!='secTitle']" mode="contents"/>
        </div>
    </xsl:template>
    <!-- 
        section1 (contents) 
    -->
    <xsl:template match="section1" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="count(ancestor::chapter) + count(ancestor::chapterBeforePart) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:variable name="sSpaceBefore"> </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
            <xsl:with-param name="sSpaceBefore">
                <xsl:choose>
                    <xsl:when test="$frontMatterLayoutInfo/contentsLayout/@spacebeforemainsection and not(ancestor::chapter) and not(ancestor::appendix)">
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
            <xsl:with-param name="sIndent" select="$sLevel"/>
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
        <xsl:variable name="layout" select="$frontMatterLayoutInfo/contentsLayout"/>
        <xsl:variable name="linkLayout" select="$pageLayoutInfo/linkLayout/contentsLinkLayout"/>
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
            <xsl:if test="$sIndent!='0'">
                <xsl:attribute name="style">
                    <xsl:if test="$sSpaceBefore!='0'">
                        <xsl:text>margin-top:</xsl:text>
                        <xsl:value-of select="$sSpaceBefore"/>
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                    <xsl:text>text-indent:-</xsl:text>
                    <xsl:value-of select="$sIndent div 2 + 1.5"/>
                    <xsl:text>em; padding-left:</xsl:text>
                    <xsl:value-of select="1.5 * $sIndent + 1.5"/>
                    <xsl:text>em;</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <a href="#{$sLink}">
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$linkLayout"/>
                </xsl:call-template>                
                <span>
                    <xsl:call-template name="OutputTOCTitle">
                        <xsl:with-param name="linkLayout" select="$linkLayout"/>
                        <xsl:with-param name="sLabel" select="$sLabel"/>
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
-->                    </xsl:if>
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
        <span>
<!--            <xsl:if test="$linkLayout/@linktitle!='no'">
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$linkLayout"/>
                </xsl:call-template>
            </xsl:if>
-->            <xsl:copy-of select="$sLabel"/>
        </span>
    </xsl:template>
</xsl:stylesheet>
