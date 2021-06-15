<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:saxon="http://icl.com/saxon">
    <xsl:variable name="authorForm" select="//publisherStyleSheet[1]/backMatterLayout/referencesLayout/@authorform"/>
    <xsl:variable name="titleForm" select="//publisherStyleSheet[1]/backMatterLayout/referencesLayout/@titleform"/>
    <xsl:variable name="iso639-3codeItem" select="//publisherStyleSheet[1]/backMatterLayout/referencesLayout/iso639-3codeItem"/>
    <!--  
        DoAuthorLayout
    -->
    <xsl:template name="DoAuthorLayout">
        <xsl:param name="referencesLayoutInfo"/>
        <xsl:param name="work"/>
        <xsl:param name="works"/>
        <xsl:param name="sortedWorks"/>
        <xsl:param name="iPos" select="'0'"/>
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
                <xsl:if test="$work/../@showAuthorName!='no'">
                    <xsl:for-each select="$referencesLayoutInfo/refAuthorLayouts/*[position()=$authorLayoutToUsePosition]">
                        <xsl:for-each select="*">
                            <xsl:choose>
                                <xsl:when test="name(.)='refAuthorItem'">
                                    <fo:inline>
                                        <xsl:call-template name="OutputFontAttributes">
                                            <xsl:with-param name="language" select="."/>
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
                                        <xsl:choose>
                                            <xsl:when
                                                test="$sAuthorName!='______' and $authorForm='full' and $referencesLayoutInfo/refAuthorLayouts/refAuthorLastNameLayout or not(refAuthorInitials) and $referencesLayoutInfo/refAuthorLayouts/refAuthorLastNameLayout">
                                                <xsl:apply-templates select="$work/.."/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$sAuthorName"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                            <xsl:with-param name="layoutInfo" select="."/>
                                            <xsl:with-param name="sPrecedingText" select="$sAuthorName"/>
                                        </xsl:call-template>
                                    </fo:inline>
                                </xsl:when>
                                <xsl:when test="name(.)='authorRoleItem'">
                                    <fo:inline>
                                        <xsl:call-template name="OutputFontAttributes">
                                            <xsl:with-param name="language" select="."/>
                                        </xsl:call-template>
                                        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                                            <xsl:with-param name="layoutInfo" select="."/>
                                        </xsl:call-template>
                                        <xsl:apply-templates select="$work/authorRole"/>
                                        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                            <xsl:with-param name="layoutInfo" select="."/>
                                            <xsl:with-param name="sPrecedingText" select="$work/authorRole"/>
                                        </xsl:call-template>
                                    </fo:inline>
                                </xsl:when>
                                <xsl:when test="name(.)='refDateItem'">
                                    <xsl:if test="$referencesLayoutInfo/@useAuthorOverDateStyle!='yes'">
                                        <xsl:call-template name="DoDateLayout">
                                            <xsl:with-param name="refDateItem" select="."/>
                                            <xsl:with-param name="work" select="$work"/>
                                            <xsl:with-param name="works" select="$works"/>
                                            <xsl:with-param name="sortedWorks" select="$sortedWorks"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoDateLayout
    -->
    <xsl:template name="DoDateLayout">
        <xsl:param name="refDateItem"/>
        <xsl:param name="work"/>
        <xsl:param name="works"/>
        <xsl:param name="sortedWorks"/>
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$refDateItem"/>
            </xsl:call-template>
            <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                <xsl:with-param name="layoutInfo" select="$refDateItem"/>
            </xsl:call-template>
            <xsl:apply-templates select="$work/refDate">
                <xsl:with-param name="works" select="$works"/>
                <xsl:with-param name="sortedWorks" select="$sortedWorks"/>
            </xsl:apply-templates>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$refDateItem"/>
                <xsl:with-param name="sPrecedingText" select="$work/refDate"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>
    <!--  
        DoDoiLayout
    -->
    <xsl:template name="DoDoiLayout">
        <!-- remove any zero width spaces in the hyperlink -->
        <fo:basic-link external-destination="url(https://doi.org/{normalize-space(translate(.,$sStripFromUrl,''))})">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/doiLinkLayout"/>
            </xsl:call-template>
            <!--            <xsl:text>&#x20;</xsl:text>-->
            <xsl:value-of select="normalize-space(.)"/>
        </fo:basic-link>
    </xsl:template>
    <!--  
        DoRefCitation
    -->
    <xsl:template name="DoRefCitation">
        <xsl:param name="citation"/>
        <xsl:for-each select="$citation">
            <xsl:variable name="refer" select="id(@refToBook)"/>
            <fo:inline>
                <fo:basic-link>
                    <xsl:attribute name="internal-destination">
                        <xsl:value-of select="@refToBook"/>
                    </xsl:attribute>
                    <xsl:call-template name="AddAnyLinkAttributes">
                        <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/citationLinkLayout"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputCitationName">
                        <xsl:with-param name="citeName" select="$refer/../@citename"/>
                    </xsl:call-template>
                </fo:basic-link>
            </fo:inline>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoUrlLayout
    -->
    <xsl:template name="DoUrlLayout">
        <!-- remove any zero width spaces in the hyperlink -->
        <fo:basic-link external-destination="url({normalize-space(translate(.,$sStripFromUrl,''))})">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/urlLinkLayout"/>
            </xsl:call-template>
            <!--            <xsl:text>&#x20;</xsl:text>-->
            <xsl:value-of select="normalize-space(.)"/>
        </fo:basic-link>
    </xsl:template>
    <!--  
        DoWebPageUrlItem
    -->
    <xsl:template name="DoWebPageUrlItem">
        <xsl:param name="webPage"/>
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
            <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                <xsl:with-param name="layoutInfo" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="$webPage/url"/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="."/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>
    <!--  
      OutputISO639-3Code
   -->
    <xsl:template name="OutputISO639-3Code">
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$iso639-3codeItem"/>
            </xsl:call-template>
            <xsl:if test="position() = 1">
                <xsl:value-of select="$iso639-3codeItem/@textbeforefirst"/>
            </xsl:if>
            <xsl:value-of select="$iso639-3codeItem/@textbefore"/>
            <xsl:choose>
                <xsl:when test="$bShowISO639-3Codes='Y'">
                    <xsl:variable name="sThisCode" select="."/>
                    <fo:basic-link internal-destination="{$languages[@ISO639-3Code=$sThisCode]/@id}">
                        <xsl:call-template name="OutputISO639-3CodeCase">
                            <xsl:with-param name="iso639-3codeItem" select="$iso639-3codeItem"/>
                        </xsl:call-template>
                    </fo:basic-link>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="OutputISO639-3CodeCase">
                        <xsl:with-param name="iso639-3codeItem" select="$iso639-3codeItem"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$iso639-3codeItem/@text"/>
            <xsl:value-of select="$iso639-3codeItem/@textafter"/>
            <xsl:if test="position() != last()">
                <xsl:value-of select="$iso639-3codeItem/@textbetween"/>
            </xsl:if>
            <xsl:if test="position() = last()">
                <xsl:value-of select="$iso639-3codeItem/@textafterlast"/>
            </xsl:if>
        </fo:inline>
    </xsl:template>
    <!--  
        OutputReferenceItem
    -->
    <xsl:template name="OutputReferenceItem">
        <xsl:param name="item"/>
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
            <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                <xsl:with-param name="layoutInfo" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="saxon:node-set($item)"/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="."/>
                <xsl:with-param name="sPrecedingText" select="$item"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>
    <!--  
        OutputReferenceItemNode
    -->
    <xsl:template name="OutputReferenceItemNode">
        <xsl:param name="item"/>
        <xsl:param name="fDoTextAfter" select="'Y'"/>
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
            <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                <xsl:with-param name="layoutInfo" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="$item">
                <xsl:with-param name="layout" select="."/>
            </xsl:apply-templates>
            <xsl:if test="$fDoTextAfter='Y'">
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="."/>
                    <xsl:with-param name="sPrecedingText" select="normalize-space($item)"/>
                </xsl:call-template>
            </xsl:if>
        </fo:inline>
    </xsl:template>
    <!--  
        ReportNoPatternMatched
    -->
    <xsl:template name="ReportNoPatternMatched">
        <fo:inline background-color="yellow">Sorry, but there is no matching layout for this item in the publisher style sheet. Please add (or have someone add) the pattern. <xsl:call-template
                name="ReportPattern"/>
        </fo:inline>
    </xsl:template>
    <!--  
        ReportNoPatternMatchedForCollCitation
    -->
    <xsl:template name="ReportNoPatternMatchedForCollCitation">
        <xsl:param name="collCitation"/>
        <fo:inline background-color="yellow">Sorry, but there is no matching layout for this item in the publisher style sheet. Please add (or have someone add) the pattern. <xsl:call-template
                name="ReportPatternForCollCitation">
                <xsl:with-param name="collCitation" select="$collCitation"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>
    <!--  
        ReportNoPatternMatchedForProcCitation
    -->
    <xsl:template name="ReportNoPatternMatchedForProcCitation">
        <xsl:param name="procCitation"/>
        <fo:inline background-color="yellow">Sorry, but there is no matching layout for this item in the publisher style sheet. Please add (or have someone add) the pattern. <xsl:call-template
                name="ReportPatternForProcCitation">
                <xsl:with-param name="procCitation" select="$procCitation"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>
</xsl:stylesheet>
