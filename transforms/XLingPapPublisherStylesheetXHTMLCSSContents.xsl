<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions">
    <!--
        abstract  (contents)
    -->
    <xsl:template match="abstract" mode="contents">
        <xsl:call-template name="OutputCSSForTOC">
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        acknowledgements (contents)
    -->
    <xsl:template match="acknowledgements" mode="contents">
        <xsl:call-template name="OutputCSSForTOC">
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        appendix (contents)
    -->
    <xsl:template match="appendix" mode="contents">
        <xsl:call-template name="OutputCSSForTOC">
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="section1 | section2" mode="contents"/>
    </xsl:template>
    <!-- 
        chapter (contents) 
    -->
    <xsl:template match="chapter | chapterBeforePart | chapterInCollection" mode="contents">
        <xsl:call-template name="OutputCSSForTOC">
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="section1 | section2" mode="contents"> 
        </xsl:apply-templates>
    </xsl:template>
    <!--
      endnotes (contents)
   -->
    <xsl:template match="endnotes" mode="contents">
        <xsl:call-template name="OutputCSSForTOC">
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
        <xsl:call-template name="OutputCSSForTOC">
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        index  (contents)
    -->
    <xsl:template match="index" mode="contents">
        <xsl:call-template name="OutputCSSForTOC">
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        keywords (contents)
    -->
    <xsl:template match="keywords" mode="contents">
        <xsl:call-template name="OutputCSSForTOC">
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
        <xsl:text>.partContents {
        margin-top:</xsl:text>
        <xsl:choose>
            <xsl:when test="$frontMatterLayoutInfo/contentsLayout/@partSpaceBefore">
                <xsl:value-of select="$frontMatterLayoutInfo/contentsLayout/partSpaceBefore"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sBasicPointSize"/>                
            </xsl:otherwise>
        </xsl:choose>
            <xsl:text>pt;
</xsl:text>
            <xsl:text>        margin-bottom:</xsl:text>
        <xsl:choose>
            <xsl:when test="$frontMatterLayoutInfo/contentsLayout/@partSpaceAfter">
                <xsl:value-of select="$frontMatterLayoutInfo/contentsLayout/partSpaceAfter"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sBasicPointSize"/>                
            </xsl:otherwise>
        </xsl:choose>
            <xsl:text>pt;
            text-align:</xsl:text>
        <xsl:choose>
            <xsl:when test="$frontMatterLayoutInfo/contentsLayout/@partCentered='yes'">
                <xsl:text>center;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>left;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>
}
</xsl:text>
    </xsl:template>
    <!--
        preface (contents)
    -->
    <xsl:template match="preface" mode="contents">
        <xsl:call-template name="OutputCSSForTOC">
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        references (contents)
    -->
    <xsl:template match="references" mode="contents">
        <xsl:call-template name="OutputCSSForTOC">
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
            <xsl:value-of select="count(ancestor::chapter) + count(ancestor::chapterBeforePart) + count(ancestor::appendix) + count(ancestor::chapterInCollection)"/>
        </xsl:variable>
        <xsl:call-template name="OutputCSSForSectionTOC">
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
        section2 (contents) 
    -->
    <xsl:template match="section2" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="count(ancestor::section1) + count(ancestor::chapter) + count(ancestor::appendix) + count(ancestor::chapterInCollection)"/>
        </xsl:variable>
        <xsl:call-template name="OutputCSSForSectionTOC">
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
            <xsl:value-of select="1 + count(ancestor::section1) + count(ancestor::chapter) + count(ancestor::appendix) + count(ancestor::chapterInCollection)"/>
        </xsl:variable>
        <xsl:call-template name="OutputCSSForSectionTOC">
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
            <xsl:value-of select="2 + count(ancestor::section1) + count(ancestor::chapter) + count(ancestor::appendix) + count(ancestor::chapterInCollection)"/>
        </xsl:variable>
        <xsl:call-template name="OutputCSSForSectionTOC">
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
            <xsl:value-of select="3 + count(ancestor::section1) + count(ancestor::chapter) + count(ancestor::appendix) + count(ancestor::chapterInCollection)"/>
        </xsl:variable>
        <xsl:call-template name="OutputCSSForSectionTOC">
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
            <xsl:value-of select="4 + count(ancestor::section1) + count(ancestor::chapter) + count(ancestor::appendix) + count(ancestor::chapterInCollection)"/>
        </xsl:variable>
        <xsl:call-template name="OutputCSSForSectionTOC">
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
        OutputCSSForSectionTOC
    -->
    <xsl:template name="OutputCSSForSectionTOC">
        <xsl:param name="sLevel"/>
        <xsl:param name="sSpaceBefore" select="'0'"/>
        <xsl:call-template name="OutputCSSForTOC">
            <xsl:with-param name="sIndent" select="$sLevel"/>
            <xsl:with-param name="sSpaceBefore" select="$sSpaceBefore"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        OutputCSSForTOC
    -->
    <xsl:template name="OutputCSSForTOC">
        <xsl:param name="sSpaceBefore" select="'0'"/>
        <xsl:param name="sIndent" select="'0'"/>
        <xsl:param name="override"/>
        <xsl:variable name="layout" select="$frontMatterLayoutInfo/contentsLayout"/>
        <xsl:variable name="linkLayout" select="$pageLayoutInfo/linkLayout/contentsLinkLayout"/>
        <xsl:text>.</xsl:text>
        <xsl:call-template name="CreateCSSContentsClassName"/>
        <xsl:text> {
</xsl:text>
        <xsl:if test="$sSpaceBefore!='0'">
            <xsl:text>        margin-top:</xsl:text>
            <xsl:value-of select="$sSpaceBefore"/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
        <xsl:if test="$sIndent!='0'">
            <xsl:text>        text-indent:-</xsl:text>
            <xsl:value-of select="$sIndent div 2 + 1.5"/>
            <xsl:text>em;
        padding-left:</xsl:text>
            <xsl:value-of select="1.5 * $sIndent + 1.5"/>
            <xsl:text>em;
</xsl:text>
        </xsl:if>
        <xsl:text>}
</xsl:text>
    </xsl:template>
</xsl:stylesheet>
