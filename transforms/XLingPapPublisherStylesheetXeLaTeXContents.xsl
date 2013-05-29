<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tex="http://getfo.sourceforge.net/texml/ns1">
    <xsl:include href="XLingPapPublisherStylesheetCommonContents.xsl"/>
    <!-- 
        part (contents) 
    -->
    <xsl:template match="part" mode="contents">
        <!--        <xsl:param name="nLevel"/>-->
        <xsl:if test="count(preceding-sibling::part)=0">
            <xsl:for-each select="preceding-sibling::*[name()='chapterBeforePart']">
                <xsl:apply-templates select="." mode="contents">
                    <!--                    <xsl:with-param name="nLevel" select="$nLevel"/>-->
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:if>
        <tex:cmd name="vspace">
            <tex:parm>
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
                <xsl:text>pt</xsl:text>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="@id"/>
        </xsl:call-template>
        <tex:cmd name="centering">
            <tex:parm>
                <xsl:call-template name="OutputPartLabel"/>
                <xsl:text>&#x20;</xsl:text>
                <xsl:apply-templates select="." mode="numberPart"/>
                <xsl:text>&#xa0;</xsl:text>
                <xsl:apply-templates select="secTitle"/>
                <tex:spec cat="esc"/>
                <tex:spec cat="esc"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="DoInternalHyperlinkEnd"/>
        <xsl:apply-templates select="chapter" mode="contents"/>
    </xsl:template>
    <!-- 
        section1 (contents) 
    -->
    <xsl:template match="section1" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="count(ancestor::chapter) + count(ancestor::appendix) + 1"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
            <xsl:with-param name="sSpaceBefore">
                <xsl:choose>
                    <xsl:when test="$frontMatterLayoutInfo/contentsLayout/@spacebeforemainsection and not(ancestor::chapter) and not(ancestor::appendix) and not(ancestor::chapterBeforePart)">
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
        <!-- set level command name -->
        <xsl:variable name="sLevelName">
            <xsl:choose>
                <xsl:when test="$sLevel='1'">
                    <xsl:text>levelone</xsl:text>
                </xsl:when>
                <xsl:when test="$sLevel='2'">
                    <xsl:text>leveltwo</xsl:text>
                </xsl:when>
                <xsl:when test="$sLevel='3'">
                    <xsl:text>levelthree</xsl:text>
                </xsl:when>
                <xsl:when test="$sLevel='4'">
                    <xsl:text>levelfour</xsl:text>
                </xsl:when>
                <xsl:when test="$sLevel='5'">
                    <xsl:text>levelfive</xsl:text>
                </xsl:when>
                <xsl:when test="$sLevel='6'">
                    <xsl:text>levelsix</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- figure out what the new value of the indent based on the section number itself -->
        <xsl:variable name="sSectionNumberIndentFormula">
            <xsl:call-template name="CalculateSectionNumberIndent"/>
        </xsl:variable>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="concat($sLevelName,'indent')"/>
            <xsl:with-param name="sValue" select="$sSectionNumberIndentFormula"/>
        </xsl:call-template>
        <!-- figure out what the new value of the number width based on the section number itself -->
        <xsl:variable name="sSectionNumberWidthFormula">
            <xsl:call-template name="CalculateSectionNumberWidth"/>
        </xsl:variable>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="concat($sLevelName,'width')"/>
            <xsl:with-param name="sValue" select="$sSectionNumberWidthFormula"/>
        </xsl:call-template>
        <xsl:if test="string-length($sChapterLineIndent)&gt;0">
            <tex:cmd name="addtolength">
                <tex:parm>
                    <tex:cmd name="{$sLevelName}indent" gr="0"/>
                </tex:parm>
                <tex:parm>
                    <xsl:value-of select="$sChapterLineIndent"/>        
                </tex:parm>
            </tex:cmd>
        </xsl:if>
        <!-- output the toc line -->
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputSectionNumberAndTitleInContents"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <tex:cmd name="{$sLevelName}indent" gr="0" nl2="0"/>
            </xsl:with-param>
            <xsl:with-param name="sNumWidth">
                <tex:cmd name="{$sLevelName}width" gr="0" nl2="0"/>
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
        <xsl:param name="sIndent" select="'0pt'"/>
        <xsl:param name="override"/>
        <xsl:param name="sNumWidth" select="'0pt'"/>
        <xsl:param name="fUseHalfSpacing"/>
        <xsl:variable name="layout" select="$frontMatterLayoutInfo/contentsLayout"/>
        <xsl:variable name="linkLayout" select="$pageLayoutInfo/linkLayout/contentsLinkLayout"/>
        <xsl:if test="number($sSpaceBefore)>0">
            <tex:cmd name="vspace">
                <tex:parm>
                    <xsl:value-of select="$sSpaceBefore"/>
                    <xsl:text>pt</xsl:text>
                </tex:parm>
            </tex:cmd>
        </xsl:if>
        <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@singlespaceeachcontentline='yes'">
            <tex:spec cat="bg"/>
            <tex:cmd name="singlespacing" gr="0" nl2="1"/>
        </xsl:if>
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="$sLink"/>
        </xsl:call-template>
        <tex:cmd name="XLingPaperdottedtocline" nl2="1">
            <tex:parm>
                <xsl:copy-of select="$sIndent"/>
            </tex:parm>
            <tex:parm>
                <xsl:copy-of select="$sNumWidth"/>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="OutputTOCTitle">
                    <xsl:with-param name="linkLayout" select="$linkLayout"/>
                    <xsl:with-param name="sLabel" select="$sLabel"/>
                </xsl:call-template>
            </tex:parm>
            <tex:parm>
                <xsl:if test="$layout/@showpagenumber!='no'">
                    <xsl:call-template name="OutputTOCPageNumber">
                        <xsl:with-param name="linkLayout" select="$linkLayout"/>
                        <xsl:with-param name="sLink" select="$sLink"/>
                    </xsl:call-template>
                </xsl:if>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="DoInternalHyperlinkEnd"/>
        <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@singlespaceeachcontentline='yes'">
            <tex:spec cat="eg"/>
        </xsl:if>
    </xsl:template>
    <!--  
      OutputTOCPageNumber
   -->
    <xsl:template name="OutputTOCPageNumber">
        <xsl:param name="linkLayout"/>
        <xsl:param name="sLink"/>
        <xsl:if test="$linkLayout/@linkpagenumber!='no'">
            <xsl:call-template name="LinkAttributesBegin">
                <xsl:with-param name="override" select="$linkLayout"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="sPage" select="document($sTableOfContentsFile)/toc/tocline[@ref=translate($sLink,$sIDcharsToMap,$sIDcharsMapped)]/@page"/>
        <xsl:choose>
            <xsl:when test="$sPage">
                <xsl:value-of select="$sPage"/>
            </xsl:when>
            <xsl:otherwise>??</xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$linkLayout/@linkpagenumber!='no'">
            <xsl:call-template name="LinkAttributesEnd">
                <xsl:with-param name="override" select="$linkLayout"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
      OutputTOCTitle
   -->
    <xsl:template name="OutputTOCTitle">
        <xsl:param name="linkLayout"/>
        <xsl:param name="sLabel"/>
        <xsl:if test="$linkLayout/@linktitle!='no'">
            <xsl:call-template name="LinkAttributesBegin">
                <xsl:with-param name="override" select="$linkLayout"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:copy-of select="$sLabel"/>
        <xsl:if test="$linkLayout/@linktitle!='no'">
            <xsl:call-template name="LinkAttributesEnd">
                <xsl:with-param name="override" select="$linkLayout"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
