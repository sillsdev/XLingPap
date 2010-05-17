<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
    <!--
        abstract  (contents)
    -->
    <xsl:template match="abstract" mode="contents">
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="'rXLingPapAbstract'"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputAbstractLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        acknowledgements (contents)
    -->
    <xsl:template match="acknowledgements" mode="contents">
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="'rXLingPapAcknowledgements'"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputAcknowledgementsLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        appendix (contents)
    -->
    <xsl:template match="appendix" mode="contents">
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputChapterNumber">
                    <xsl:with-param name="fDoTextAfterLetter" select="'N'"/>
                </xsl:call-template>
                <xsl:apply-templates select="secTitle"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="section1 | section2" mode="contents"/>
    </xsl:template>
    <!-- 
        chapter (contents) 
    -->
    <xsl:template match="chapter | chapterBeforePart" mode="contents">
        <!--        <xsl:template match="chapter[not(//part)]" mode="contents">-->
        <!--            <xsl:param name="nLevel"/>-->
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputChapterNumber"/>
                <xsl:text>&#xa0;</xsl:text>
                <xsl:apply-templates select="secTitle"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="section1 | section2" mode="contents">
            <!--            <xsl:with-param name="nLevel" select="$nLevel"/>-->
        </xsl:apply-templates>
    </xsl:template>
    <!--
      endnotes (contents)
   -->
    <xsl:template match="endnotes" mode="contents">
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="'rXLingPapEndnotes'"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputEndnotesLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        glossary (contents)
    -->
    <xsl:template match="glossary" mode="contents">
        <xsl:variable name="iPos" select="count(preceding-sibling::glossary) + 1"/>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="concat('rXLingPapGlossary',$iPos)"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputGlossaryLabel">
                    <xsl:with-param name="iPos" select="$iPos"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        index  (contents)
    -->
    <xsl:template match="index" mode="contents">
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
                <xsl:call-template name="CreateIndexID"/>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputIndexLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
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
        <fo:block text-align="center" space-before="{$sBasicPointSize - 4}pt" space-after="{$sBasicPointSize}pt" keep-with-next.within-page="2">
            <fo:basic-link internal-destination="{@id}">
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
            </fo:basic-link>
            <xsl:apply-templates mode="contents">
                <!--                <xsl:with-param name="nLevel" select="$nLevel"/>-->
            </xsl:apply-templates>
        </fo:block>
    </xsl:template>
    <!--
        preface (contents)
    -->
    <xsl:template match="preface" mode="contents">
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="concat('rXLingPapPreface',position())"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputPrefaceLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        references (contents)
    -->
    <xsl:template match="references" mode="contents">
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="'rXLingPapReferences'"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputReferencesLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        section1 (contents) 
    -->
    <xsl:template match="section1" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="count(ancestor::chapter) + count(ancestor::appendix)"/>
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
        section2 (contents) 
    -->
    <xsl:template match="section2" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="count(ancestor::section1) + count(ancestor::chapter) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=3 and $bodyLayoutInfo/section3Layout/@ignore!='yes'">
            <xsl:apply-templates select="section3" mode="contents"/>
        </xsl:if>
    </xsl:template>
    <!-- 
        section3 (contents) 
    -->
    <xsl:template match="section3" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="1 + count(ancestor::section1) + count(ancestor::chapter) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=4 and $bodyLayoutInfo/section4Layout/@ignore!='yes'">
            <xsl:apply-templates select="section4" mode="contents"/>
        </xsl:if>
    </xsl:template>
    <!-- 
        section4 (contents) 
    -->
    <xsl:template match="section4" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="2 + count(ancestor::section1) + count(ancestor::chapter) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=5 and $bodyLayoutInfo/section5Layout/@ignore!='yes'">
            <xsl:apply-templates select="section5" mode="contents"/>
        </xsl:if>
    </xsl:template>
    <!-- 
        section5 (contents) 
    -->
    <xsl:template match="section5" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="3 + count(ancestor::section1) + count(ancestor::chapter) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=6 and $bodyLayoutInfo/section6Layout/@ignore!='yes'">
            <xsl:apply-templates select="section6" mode="contents"/>
        </xsl:if>
    </xsl:template>
    <!-- 
        section6 (contents) 
    -->
    <xsl:template match="section6" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="4 + count(ancestor::section1) + count(ancestor::chapter) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
      DoSpaceBeforeContentsLine
   -->
    <xsl:template name="DoSpaceBeforeContentsLine">
        <xsl:choose>
            <xsl:when test="$frontMatterLayoutInfo/contentsLayout/@spacebeforemainsection">
                <xsl:value-of select="$frontMatterLayoutInfo/contentsLayout/@spacebeforemainsection"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>0</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
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
        <fo:block>
            <xsl:attribute name="text-align-last">
                <xsl:choose>
                    <xsl:when test="$layout/@showpagenumber!='no'">
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
            <xsl:if test="$sIndent!='0'">
                <xsl:attribute name="text-indent">-<xsl:value-of select="$sIndent div 2 + 1.5"/>em</xsl:attribute>
                <xsl:attribute name="start-indent">
                    <xsl:value-of select="1.5 * $sIndent + 1.5"/>em</xsl:attribute>
            </xsl:if>
            <fo:basic-link internal-destination="{$sLink}">
                <fo:inline>
                    <xsl:call-template name="OutputTOCTitle">
                        <xsl:with-param name="linkLayout" select="$linkLayout"/>
                        <xsl:with-param name="sLabel" select="$sLabel"/>
                    </xsl:call-template>
                    <xsl:text>&#xa0;</xsl:text>
                    <xsl:if test="$layout/@showpagenumber!='no'">
                        <fo:leader leader-pattern="{$layout/@betweentitleandnumber}">
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
        <fo:inline>
            <xsl:if test="$linkLayout/@linktitle!='no'">
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$linkLayout"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:copy-of select="$sLabel"/>
        </fo:inline>
    </xsl:template>
</xsl:stylesheet>
