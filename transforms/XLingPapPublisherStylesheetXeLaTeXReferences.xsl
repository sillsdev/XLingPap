<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tex="http://getfo.sourceforge.net/texml/ns1">
    <xsl:variable name="authorForm" select="//publisherStyleSheet/backMatterLayout/referencesLayout/@authorform"/>
    <xsl:variable name="titleForm" select="//publisherStyleSheet/backMatterLayout/referencesLayout/@titleform"/>
    <xsl:variable name="iso639-3codeItem" select="//publisherStyleSheet/backMatterLayout/referencesLayout/iso639-3codeItem"/>
    <!--  
        DoAuthorLayout
    -->
    <xsl:template name="DoAuthorLayout">
        <xsl:param name="referencesLayoutInfo"/>
        <xsl:param name="work"/>
        <xsl:param name="works"/>
        <xsl:param name="iPos" select="'0'"/>
        <xsl:call-template name="DoInternalTargetBegin">
            <xsl:with-param name="sName" select="@id"/>
        </xsl:call-template>
        <xsl:variable name="authorLayoutToUsePosition">
            <xsl:call-template name="GetAuthorLayoutToUsePosition">
                <xsl:with-param name="referencesLayoutInfo" select="$referencesLayoutInfo"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$authorLayoutToUsePosition=0 or string-length($authorLayoutToUsePosition)=0">
                <xsl:call-template name="ReportNoPatternMatched"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$referencesLayoutInfo/refAuthorLayouts/*[position()=$authorLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refAuthorItem'">
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="."/>
                                    <xsl:with-param name="originalContext" select="$work/.."/>
                                </xsl:call-template>
                                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                                    <xsl:with-param name="layoutInfo" select="."/>
                                </xsl:call-template>
                                <xsl:variable name="sAuthorName">
                                    <xsl:choose>
                                        <xsl:when test="$referencesLayoutInfo/@uselineforrepeatedauthor='yes' and $iPos &gt; 1">
                                            <xsl:text>______</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates select="$work/.."/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:value-of select="$sAuthorName"/>
                                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                    <xsl:with-param name="layoutInfo" select="."/>
                                    <xsl:with-param name="sPrecedingText" select="$sAuthorName"/>
                                </xsl:call-template>
                                <xsl:call-template name="OutputFontAttributesEnd">
                                    <xsl:with-param name="language" select="."/>
                                    <xsl:with-param name="originalContext" select="$work/.."/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='authorRoleItem'">
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="."/>
                                    <xsl:with-param name="originalContext" select="$work/authorRole"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                                    <xsl:with-param name="layoutInfo" select="."/>
                                </xsl:call-template>
                                <xsl:apply-templates select="$work/authorRole"/>
                                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                    <xsl:with-param name="layoutInfo" select="."/>
                                    <xsl:with-param name="sPrecedingText" select="$work/authorRole"/>
                                </xsl:call-template>
                                <xsl:call-template name="OutputFontAttributesEnd">
                                    <xsl:with-param name="language" select="."/>
                                    <xsl:with-param name="originalContext" select="$work/authorRole"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='refDateItem'">
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="."/>
                                    <xsl:with-param name="originalContext" select="$work/refDate"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                                    <xsl:with-param name="layoutInfo" select="."/>
                                </xsl:call-template>
                                <xsl:apply-templates select="$work/refDate">
                                    <xsl:with-param name="works" select="$works"/>
                                </xsl:apply-templates>
                                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                    <xsl:with-param name="layoutInfo" select="."/>
                                    <xsl:with-param name="sPrecedingText" select="$work/refDate"/>
                                </xsl:call-template>
                                <xsl:call-template name="OutputFontAttributesEnd">
                                    <xsl:with-param name="language" select="."/>
                                    <xsl:with-param name="originalContext" select="$work/refDate"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:call-template name="DoInternalTargetEnd"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoRefCitation
    -->
    <xsl:template name="DoRefCitation">
        <xsl:param name="citation"/>
        <xsl:for-each select="$citation">
            <xsl:variable name="refer" select="id(@refToBook)"/>
            <xsl:call-template name="DoInternalHyperlinkBegin">
                <xsl:with-param name="sName" select="@refToBook"/>
            </xsl:call-template>
            <xsl:call-template name="LinkAttributesBegin">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/citationLinkLayout"/>
            </xsl:call-template>
            <xsl:value-of select="$refer/../@citename"/>
            <xsl:call-template name="LinkAttributesEnd">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/citationLinkLayout"/>
            </xsl:call-template>
            <xsl:call-template name="DoExternalHyperRefEnd"/>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoUrlLayout
    -->
    <xsl:template name="DoUrlLayout">
        <xsl:call-template name="DoExternalHyperRefBegin">
            <!-- remove any zero width spaces in the hyperlink -->
            <xsl:with-param name="sName" select="normalize-space(translate(.,'&#x200b;',''))"/>
        </xsl:call-template>
        <xsl:call-template name="LinkAttributesBegin">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/urlLinkLayout"/>
        </xsl:call-template>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:call-template name="LinkAttributesEnd">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/urlLinkLayout"/>
        </xsl:call-template>
        <xsl:call-template name="DoExternalHyperRefEnd"/>
    </xsl:template>
    <!--  
        DoWebPageUrlItem
    -->
    <xsl:template name="DoWebPageUrlItem">
        <xsl:param name="webPage"/>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="."/>
            <xsl:with-param name="originalContext" select="$webPage/url"/>
        </xsl:call-template>
        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
            <xsl:with-param name="layoutInfo" select="."/>
        </xsl:call-template>
        <xsl:apply-templates select="$webPage/url"/>
        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
            <xsl:with-param name="layoutInfo" select="."/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="."/>
            <xsl:with-param name="originalContext" select="$webPage/url"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
      OutputISO639-3Code
   -->
    <xsl:template name="OutputISO639-3Code">
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="$iso639-3codeItem"/>
        </xsl:call-template>
        <xsl:if test="position() = 1">
            <xsl:value-of select="$iso639-3codeItem/@textbeforefirst"/>
        </xsl:if>
        <xsl:value-of select="$iso639-3codeItem/@textbefore"/>
        <xsl:choose>
            <xsl:when test="$iso639-3codeItem/@case='uppercase'">
                <xsl:value-of select="translate(.,'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="translate(.,'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$iso639-3codeItem/@text"/>
        <xsl:if test="position() != last()">
            <xsl:value-of select="$iso639-3codeItem/@textbetween"/>
        </xsl:if>
        <xsl:if test="position() = last()">
            <xsl:value-of select="$iso639-3codeItem/@textafterlast"/>
        </xsl:if>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="$iso639-3codeItem"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        OutputReferenceItem
    -->
    <xsl:template name="OutputReferenceItem">
        <xsl:param name="item"/>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="."/>
            <xsl:with-param name="originalContext" select="$item"/>
        </xsl:call-template>
        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
            <xsl:with-param name="layoutInfo" select="."/>
        </xsl:call-template>
        <xsl:value-of select="$item"/>
        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
            <xsl:with-param name="layoutInfo" select="."/>
            <xsl:with-param name="sPrecedingText" select="$item"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="."/>
            <xsl:with-param name="originalContext" select="$item"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        OutputReferenceItemNode
    -->
    <xsl:template name="OutputReferenceItemNode">
        <xsl:param name="item"/>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="."/>
            <xsl:with-param name="originalContext" select="$item"/>
        </xsl:call-template>
        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
            <xsl:with-param name="layoutInfo" select="."/>
        </xsl:call-template>
        <xsl:apply-templates select="$item">
            <xsl:with-param name="layout" select="."/>
        </xsl:apply-templates>
        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
            <xsl:with-param name="layoutInfo" select="."/>
            <xsl:with-param name="sPrecedingText" select="normalize-space($item)"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="."/>
            <xsl:with-param name="originalContext" select="$item"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        ReportNoPatternMatched
    -->
    <xsl:template name="ReportNoPatternMatched">
        <xsl:call-template name="ReportTeXCannotHandleThisMessage">
            <xsl:with-param name="sMessage">
                <xsl:text>Sorry, but there is no matching layout for this item in the publisher style sheet.  Please add  (or have someone add) the pattern.</xsl:text>
                <xsl:call-template name="ReportPattern"/>
                         
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--  
        ReportNoPatternMatchedForCollCitation
    -->
    <xsl:template name="ReportNoPatternMatchedForCollCitation">
        <xsl:param name="collCitation"/>
        <xsl:call-template name="ReportTeXCannotHandleThisMessage">
            <xsl:with-param name="sMessage">
                <xsl:text>Sorry, but there is no matching layout for this item in the publisher style sheet.  Please add  (or have someone add) the pattern.</xsl:text>
                <xsl:call-template name="ReportPatternForCollCitation">
                    <xsl:with-param name="collCitation" select="$collCitation"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--  
        ReportNoPatternMatchedForProcCitation
    -->
    <xsl:template name="ReportNoPatternMatchedForProcCitation">
        <xsl:param name="procCitation"/>
        <xsl:call-template name="ReportTeXCannotHandleThisMessage">
            <xsl:with-param name="sMessage">
                <xsl:text>Sorry, but there is no matching layout for this item in the publisher style sheet.  Please add  (or have someone add) the pattern.</xsl:text>
                <xsl:call-template name="ReportPatternForProcCitation">
                    <xsl:with-param name="procCitation" select="$procCitation"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
