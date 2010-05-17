<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tex="http://getfo.sourceforge.net/texml/ns1">
    <xsl:variable name="referencesLayoutInfo" select="//publisherStyleSheet/backMatterLayout/referencesLayout"/>
    <xsl:variable name="authorForm" select="//publisherStyleSheet/backMatterLayout/referencesLayout/@authorform"/>
    <xsl:variable name="titleForm" select="//publisherStyleSheet/backMatterLayout/referencesLayout/@titleform"/>
    <xsl:variable name="iso639-3codeItem" select="//publisherStyleSheet/backMatterLayout/referencesLayout/iso639-3codeItem"/>
    <!--
        authorRole
    -->
    <xsl:template match="authorRole">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <!--
        book
    -->
    <xsl:template match="book">
        <xsl:call-template name="DoBookLayout"/>
    </xsl:template>
    <!--
        collection
    -->
    <xsl:template match="collection">
        <xsl:call-template name="DoCollectionLayout"/>
    </xsl:template>
    <!--
        dissertation
    -->
    <xsl:template match="dissertation">
        <xsl:call-template name="DoDissertationLayout">
            <xsl:with-param name="layout" select="$referencesLayoutInfo/dissertationLayouts"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        article
    -->
    <xsl:template match="article">
        <xsl:call-template name="DoArticleLayout"/>
    </xsl:template>
    <!--
      field notes
   -->
    <xsl:template match="fieldNotes">
        <xsl:call-template name="DoFieldNotesLayout"/>
    </xsl:template>
    <!--
      ms
   -->
    <xsl:template match="ms">
        <xsl:call-template name="DoMsLayout"/>
    </xsl:template>
    <!--
        paper
    -->
    <xsl:template match="paper">
        <xsl:call-template name="DoPaperLayout"/>
    </xsl:template>
    <!--
        proceedings
    -->
    <xsl:template match="proceedings">
        <xsl:call-template name="DoProceedingsLayout"/>
    </xsl:template>
    <!--
        thesis
    -->
    <xsl:template match="thesis">
        <xsl:call-template name="DoDissertationLayout">
            <xsl:with-param name="layout" select="$referencesLayoutInfo/thesisLayouts"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      iso639-3code
   -->
    <xsl:template match="iso639code">
        <xsl:call-template name="DoExternalHyperRefBegin">
            <xsl:with-param name="sName" select="normalize-space(.)"/>
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
        url
    -->
    <xsl:template match="url">
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
        webPage
    -->
    <xsl:template match="webPage">
        <xsl:call-template name="DoWebPageLayout"/>
    </xsl:template>
    <!--
        refAuthor
    -->
    <xsl:template match="refAuthor">
        <xsl:choose>
            <xsl:when test="$authorForm='full' or not(refAuthorInitials)">
                <xsl:value-of select="normalize-space(@name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space(refAuthorInitials)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        refDate
    -->
    <xsl:template match="refDate">
        <xsl:param name="works"/>
        <xsl:variable name="date" select="."/>
        <xsl:value-of select="$date"/>
        <xsl:if test="count($works[refDate=$date])>1">
            <xsl:apply-templates select="." mode="dateLetter">
                <xsl:with-param name="date" select="$date"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    <!--
        refTitle
    -->
    <xsl:template match="refTitle">
        <xsl:choose>
            <xsl:when test="$titleForm='uppercase' or not(following-sibling::refTitleLowerCase)">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="following-sibling::refTitleLowerCase"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoArticleLayout
    -->
    <xsl:template name="DoArticleLayout">
        <xsl:variable name="article" select="."/>
        <xsl:variable name="work" select=".."/>
        <xsl:variable name="articleLayoutToUsePosition">
            <xsl:call-template name="GetArticleLayoutToUsePosition"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$articleLayoutToUsePosition=0 or string-length($articleLayoutToUsePosition)=0">
                <xsl:call-template name="ReportNoPatternMatched"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*[position()=$articleLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refTitleItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='jTitleItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($article/jTitle)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='jVolItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($article/jVol)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='jPagesItem'">
                                <xsl:variable name="normalizedPages" select="normalize-space($article/jPages)"/>
                                <xsl:variable name="pages">
                                    <xsl:call-template name="GetFormattedPageNumbers">
                                        <xsl:with-param name="normalizedPages" select="$normalizedPages"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$pages"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='jArticleNumberItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($article/jArticleNumber)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationPublisherLayoutsRef'">
                                <xsl:call-template name="DoLocationPublisherLayout">
                                    <xsl:with-param name="reference" select="$article"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='iso639-3codeItemRef'">
                                <xsl:call-template name="DoISO639-3Codes">
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
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
        DoBookLayout
    -->
    <xsl:template name="DoBookLayout">
        <xsl:variable name="book" select="."/>
        <xsl:variable name="work" select=".."/>
        <xsl:variable name="bookLayoutToUsePosition">
            <xsl:call-template name="GetBookLayoutToUsePosition"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$bookLayoutToUsePosition=0 or string-length($bookLayoutToUsePosition)=0">
                <xsl:call-template name="ReportNoPatternMatched"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*[position()=$bookLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refTitleItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='translatedByItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($book/translatedBy)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='editionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($book/edition)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='seriesItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($book/series)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='bVolItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($book/bVol)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='bookTotalPagesItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($book/bookTotalPages)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationPublisherLayoutsRef'">
                                <xsl:call-template name="DoLocationPublisherLayout">
                                    <xsl:with-param name="reference" select="$book"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='iso639-3codeItemRef'">
                                <xsl:call-template name="DoISO639-3Codes">
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoCollectionLayout
    -->
    <xsl:template name="DoCollectionLayout">
        <xsl:variable name="collection" select="."/>
        <xsl:variable name="work" select=".."/>
        <xsl:variable name="collectionLayoutToUsePosition">
            <xsl:call-template name="GetCollectionLayoutToUsePosition"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$collectionLayoutToUsePosition=0 or string-length($collectionLayoutToUsePosition)=0">
                <xsl:call-template name="ReportNoPatternMatched"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*[position()=$collectionLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refTitleItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='collEdItem'">
                                <xsl:variable name="item" select="$collection/collEd"/>
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($item)"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoEditorAbbreviation">
                                    <xsl:with-param name="item" select="$item"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='collTitleItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($collection/collTitle)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='collVolItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($collection/collVol)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='collPagesItem'">
                                <xsl:variable name="normalizedPages" select="normalize-space($collection/collPages)"/>
                                <xsl:variable name="pages">
                                    <xsl:call-template name="GetFormattedPageNumbers">
                                        <xsl:with-param name="normalizedPages" select="$normalizedPages"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$pages"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='seriesItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($collection/series)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='bVolItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($collection/bVol)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationPublisherLayoutsRef'">
                                <xsl:call-template name="DoLocationPublisherLayout">
                                    <xsl:with-param name="reference" select="$collection"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='iso639-3codeItemRef'">
                                <xsl:call-template name="DoISO639-3Codes">
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoDissertationLayout
    -->
    <xsl:template name="DoDissertationLayout">
        <xsl:param name="layout"/>
        <xsl:variable name="dissertation" select="."/>
        <xsl:variable name="work" select=".."/>
        <xsl:variable name="dissertationLayoutToUsePosition">
            <xsl:call-template name="GetDissertationLayoutToUsePosition">
                <xsl:with-param name="layout" select="$layout"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$dissertationLayoutToUsePosition=0 or string-length($dissertationLayoutToUsePosition)=0">
                <xsl:call-template name="ReportNoPatternMatched"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$layout/*[position()=$dissertationLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refTitleItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='institutionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($dissertation/institution)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($dissertation/location)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='publishedLayoutRef'">
                                <xsl:call-template name="DoPublishedLayout">
                                    <xsl:with-param name="reference" select="$dissertation/published"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='iso639-3codeItemRef'">
                                <xsl:call-template name="DoISO639-3Codes">
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      DoEditorAbbreviation
   -->
    <xsl:template name="DoEditorAbbreviation">
        <xsl:param name="item"/>
        <xsl:if test="string-length(normalize-space($item)) &gt; 0">
            <xsl:choose>
                <xsl:when test="$item/@plural='no'">
                    <xsl:text>, ed. </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>, eds. </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
      DoISO639-3Codes
   -->
    <xsl:template name="DoISO639-3Codes">
        <xsl:param name="work"/>
        <xsl:choose>
            <xsl:when test="$iso639-3codeItem/@sort='no'">
                <xsl:for-each select="$work/iso639-3code">
                    <xsl:call-template name="OutputISO639-3Code"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$work/iso639-3code">
                    <xsl:sort/>
                    <xsl:call-template name="OutputISO639-3Code"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoLocationPublisherLayout
    -->
    <xsl:template name="DoLocationPublisherLayout">
        <xsl:param name="reference"/>
        <xsl:choose>
            <xsl:when test="$reference/location and $reference/publisher">
                <xsl:for-each select="$referencesLayoutInfo/locationPublisherLayouts/*[locationItem and publisherItem]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='locationItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($reference/location)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='publisherItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($reference/publisher)"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$reference/location and not($reference/publisher)">
                <xsl:for-each select="$referencesLayoutInfo/locationPublisherLayouts/*[locationItem and not(publisherItem)]">
                    <xsl:for-each select="*">
                        <xsl:call-template name="OutputReferenceItem">
                            <xsl:with-param name="item" select="normalize-space($reference/location)"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="not($reference/location) and $reference/publisher">
                <xsl:for-each select="$referencesLayoutInfo/locationPublisherLayouts/*[not(locationItem) and publisherItem]">
                    <xsl:for-each select="*">
                        <xsl:call-template name="OutputReferenceItem">
                            <xsl:with-param name="item" select="normalize-space($reference/publisher)"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
      DoFieldNotesLayout
   -->
    <xsl:template name="DoFieldNotesLayout">
        <xsl:variable name="fieldNotes" select="."/>
        <xsl:variable name="work" select=".."/>
        <xsl:variable name="fieldNotesLayoutToUsePosition">
            <xsl:call-template name="GetFieldNotesLayoutToUsePosition"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$fieldNotesLayoutToUsePosition=0 or string-length($fieldNotesLayoutToUsePosition)=0">
                <xsl:call-template name="ReportNoPatternMatched"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$referencesLayoutInfo/fieldNotesLayouts/*[position()=$fieldNotesLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refTitleItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='institutionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($fieldNotes/institution)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($fieldNotes/location)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='iso639-3codeItemRef'">
                                <xsl:call-template name="DoISO639-3Codes">
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoMsLayout
    -->
    <xsl:template name="DoMsLayout">
        <xsl:variable name="ms" select="."/>
        <xsl:variable name="work" select=".."/>
        <xsl:variable name="msLayoutToUsePosition">
            <xsl:call-template name="GetMsLayoutToUsePosition"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$msLayoutToUsePosition=0 or string-length($msLayoutToUsePosition)=0">
                <xsl:call-template name="ReportNoPatternMatched"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$referencesLayoutInfo/msLayouts/*[position()=$msLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refTitleItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='institutionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($ms/institution)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($ms/location)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='iso639-3codeItemRef'">
                                <xsl:call-template name="DoISO639-3Codes">
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoPaperLayout
    -->
    <xsl:template name="DoPaperLayout">
        <xsl:variable name="paper" select="."/>
        <xsl:variable name="work" select=".."/>
        <xsl:variable name="paperLayoutToUsePosition">
            <xsl:call-template name="GetPaperLayoutToUsePosition"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$paperLayoutToUsePosition=0 or string-length($paperLayoutToUsePosition)=0">
                <xsl:call-template name="ReportNoPatternMatched"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$referencesLayoutInfo/paperLayouts/*[position()=$paperLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refTitleItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='conferenceItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($paper/conference)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($paper/location)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='iso639-3codeItemRef'">
                                <xsl:call-template name="DoISO639-3Codes">
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoProceedingsLayout
    -->
    <xsl:template name="DoProceedingsLayout">
        <xsl:variable name="proceedings" select="."/>
        <xsl:variable name="work" select=".."/>
        <xsl:variable name="proceedingsLayoutToUsePosition">
            <xsl:call-template name="GetProceedingsLayoutToUsePosition"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$proceedingsLayoutToUsePosition=0 or string-length($proceedingsLayoutToUsePosition)=0">
                <xsl:call-template name="ReportNoPatternMatched"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*[position()=$proceedingsLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refTitleItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='procEdItem'">
                                <xsl:variable name="item" select="$proceedings/procEd"/>
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($item)"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoEditorAbbreviation">
                                    <xsl:with-param name="item" select="$item"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='procTitleItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($proceedings/procTitle)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='procVolItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($proceedings/procVol)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='procPagesItem'">
                                <xsl:variable name="normalizedPages" select="normalize-space($proceedings/procPages)"/>
                                <xsl:variable name="pages">
                                    <xsl:call-template name="GetFormattedPageNumbers">
                                        <xsl:with-param name="normalizedPages" select="$normalizedPages"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$pages"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationPublisherLayoutsRef'">
                                <xsl:call-template name="DoLocationPublisherLayout">
                                    <xsl:with-param name="reference" select="$proceedings"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='iso639-3codeItemRef'">
                                <xsl:call-template name="DoISO639-3Codes">
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoPublishedLayout
    -->
    <xsl:template name="DoPublishedLayout">
        <xsl:param name="reference"/>
        <xsl:for-each select="$referencesLayoutInfo/publishedLayout/*">
            <xsl:choose>
                <xsl:when test="name(.)='locationItem'">
                    <xsl:call-template name="OutputReferenceItem">
                        <xsl:with-param name="item" select="normalize-space($reference/location)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="name(.)='publisherItem'">
                    <xsl:call-template name="OutputReferenceItem">
                        <xsl:with-param name="item" select="normalize-space($reference/publisher)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="name(.)='pubDateItem'">
                    <xsl:call-template name="OutputReferenceItem">
                        <xsl:with-param name="item" select="normalize-space($reference/pubDate)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoWebPageLayout
    -->
    <xsl:template name="DoWebPageLayout">
        <xsl:variable name="webPage" select="."/>
        <xsl:variable name="work" select=".."/>
        <xsl:variable name="webPageLayoutToUsePosition">
            <xsl:call-template name="GetWebPageLayoutToUsePosition"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$webPageLayoutToUsePosition=0 or string-length($webPageLayoutToUsePosition)=0">
                <xsl:call-template name="ReportNoPatternMatched"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*[position()=$webPageLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refTitleItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='editionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($webPage/edition)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($webPage/location)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='institutionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($webPage/institution)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='publisherItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($webPage/publisher)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($webPage/dateAccessed)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
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
                            </xsl:when>
                            <xsl:when test="name(.)='iso639-3codeItemRef'">
                                <xsl:call-template name="DoISO639-3Codes">
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        GetArticleLayoutToUsePosition
    -->
    <xsl:template name="GetArticleLayoutToUsePosition">
        <xsl:variable name="sPosition">
            <xsl:choose>
                <xsl:when test="jPages and not(location) and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jPagesItem and not(locationPublisherLayoutsRef) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jPages and not(location) and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jPagesItem and  not(locationPublisherLayoutsRef) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jPages and not(location) and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jPagesItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jPages and not(location) and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jPagesItem and  locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jPages and location and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jPagesItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jPages and location and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jPagesItem and  locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jPages and location and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jPagesItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jPages and location and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jPagesItem and  locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jArticleNumber and not(location) and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jArticleNumberItem and not(locationPublisherLayoutsRef) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jArticleNumber and not(location) and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jArticleNumberItem and  not(locationPublisherLayoutsRef) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jArticleNumber and not(location) and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jArticleNumberItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jArticleNumber and not(location) and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jArticleNumberItem and  locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jArticleNumber and location and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jArticleNumberItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jArticleNumber and location and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jArticleNumberItem and  locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jArticleNumber and location and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jArticleNumberItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="jArticleNumber and location and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                        <xsl:if test="jArticleNumberItem and  locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetAuthorLayoutToUsePosition
    -->
    <xsl:template name="GetAuthorLayoutToUsePosition">
        <xsl:param name="referencesLayoutInfo"/>
        <xsl:variable name="sPosition">
            <xsl:choose>
                <xsl:when test="authorRole">
                    <xsl:for-each select="$referencesLayoutInfo/refAuthorLayouts/*">
                        <xsl:if test="authorRoleItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$referencesLayoutInfo/refAuthorLayouts/*">
                        <xsl:if test="not(authorRoleItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetBookLayoutToUsePosition
    -->
    <xsl:template name="GetBookLayoutToUsePosition">
        <xsl:variable name="sPosition">
            <xsl:choose>
                <xsl:when test="not(translatedBy) and not(edition) and not(series) and not(bookTotalPages) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and not(editionItem) and not(seriesItem) and not(bookTotalPagesItem) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and not(edition) and not(series) and not(bookTotalPages) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and not(editionItem) and not(seriesItem) and not(bookTotalPagesItem) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and not(edition) and not(series) and bookTotalPages and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and not(editionItem) and not(seriesItem) and bookTotalPagesItem and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and not(edition) and not(series) and bookTotalPages and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and not(editionItem) and not(seriesItem) and bookTotalPagesItem and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and not(edition) and series and not(bookTotalPages) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and not(editionItem) and seriesItem and not(bookTotalPagesItem) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and not(edition) and series and not(bookTotalPages) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and not(editionItem) and seriesItem and not(bookTotalPagesItem) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and not(edition) and series and bookTotalPages and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and not(editionItem) and seriesItem and bookTotalPagesItem and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and not(edition) and series and bookTotalPages and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and not(editionItem) and seriesItem and bookTotalPagesItem and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and edition and not(series) and not(bookTotalPages) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and editionItem and not(seriesItem) and not(bookTotalPagesItem) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and edition and not(series) and not(bookTotalPages) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and editionItem and not(seriesItem) and not(bookTotalPagesItem) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and edition and not(series) and bookTotalPages and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and editionItem and not(seriesItem) and bookTotalPagesItem and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and edition and not(series) and bookTotalPages and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and editionItem and not(seriesItem) and bookTotalPagesItem and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and edition and series and not(bookTotalPages) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and editionItem and seriesItem and not(bookTotalPagesItem) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and edition and series and not(bookTotalPages) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and editionItem and seriesItem and not(bookTotalPagesItem) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and edition and series and bookTotalPages and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and editionItem and seriesItem and bookTotalPagesItem and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(translatedBy) and edition and series and bookTotalPages and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="not(translatedByItem) and editionItem and seriesItem and bookTotalPagesItem and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and not(edition) and not(series) and not(bookTotalPages) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and not(editionItem) and not(seriesItem) and not(bookTotalPagesItem) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and not(edition) and not(series) and not(bookTotalPages) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and not(editionItem) and not(seriesItem) and not(bookTotalPagesItem) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and not(edition) and not(series) and bookTotalPages and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and not(editionItem) and not(seriesItem) and bookTotalPagesItem and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and not(edition) and not(series) and bookTotalPages and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and not(editionItem) and not(seriesItem) and bookTotalPagesItem and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and not(edition) and series and not(bookTotalPages) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and not(editionItem) and seriesItem and not(bookTotalPagesItem) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and not(edition) and series and not(bookTotalPages) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and not(editionItem) and seriesItem and not(bookTotalPagesItem) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and not(edition) and series and bookTotalPages and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and not(editionItem) and seriesItem and bookTotalPagesItem and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and not(edition) and series and bookTotalPages and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and not(editionItem) and seriesItem and bookTotalPagesItem and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and edition and not(series) and not(bookTotalPages) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and editionItem and not(seriesItem) and not(bookTotalPagesItem) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and edition and not(series) and not(bookTotalPages) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and editionItem and not(seriesItem) and not(bookTotalPagesItem) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and edition and not(series) and bookTotalPages and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and editionItem and not(seriesItem) and bookTotalPagesItem and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and edition and not(series) and bookTotalPages and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and editionItem and not(seriesItem) and bookTotalPagesItem and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and edition and series and not(bookTotalPages) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and editionItem and seriesItem and not(bookTotalPagesItem) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and edition and series and not(bookTotalPages) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and editionItem and seriesItem and not(bookTotalPagesItem) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and edition and series and bookTotalPages and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and editionItem and seriesItem and bookTotalPagesItem and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="translatedBy and edition and series and bookTotalPages and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                        <xsl:if test="translatedByItem and editionItem and seriesItem and bookTotalPagesItem and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetCollectionLayoutToUsePosition
    -->
    <xsl:template name="GetCollectionLayoutToUsePosition">
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <xsl:choose>
                <xsl:when test="collEd">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="collVol">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="collPages">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="series">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="bVol">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and collEdItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(collEdItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and collVolItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(collVolItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and collPagesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(collPagesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and seriesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(seriesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and bVolItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(bVolItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 6">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
            <!--  extensional method
         <xsl:choose>
            <xsl:when test="not(collVol) and not(collPages) and not(../url)">
               <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*">
                  <xsl:if test="not(collVolItem) and not(collPagesItem) and not(urlItem)">
                     <xsl:call-template name="RecordPosition"/>
                  </xsl:if>
               </xsl:for-each>
            </xsl:when>
            <xsl:when test="not(collVol) and not(collPages) and ../url">
               <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*">
                  <xsl:if test="not(collVolItem) and not(collPagesItem) and urlItem">
                     <xsl:call-template name="RecordPosition"/>
                  </xsl:if>
               </xsl:for-each>
            </xsl:when>
            <xsl:when test="not(collVol) and collPages and not(../url)">
               <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*">
                  <xsl:if test="not(collVolItem) and collPagesItem and not(urlItem)">
                     <xsl:call-template name="RecordPosition"/>
                  </xsl:if>
               </xsl:for-each>
            </xsl:when>
            <xsl:when test="not(collVol) and collPages and ../url">
               <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*">
                  <xsl:if test="not(collVolItem) and collPagesItem and urlItem">
                     <xsl:call-template name="RecordPosition"/>
                  </xsl:if>
               </xsl:for-each>
            </xsl:when>
            <xsl:when test="collVol and not(collPages) and not(../url)">
               <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*">
                  <xsl:if test="collVolItem and not(collPagesItem) and not(urlItem)">
                     <xsl:call-template name="RecordPosition"/>
                  </xsl:if>
               </xsl:for-each>
            </xsl:when>
            <xsl:when test="collVol and not(collPages) and ../url">
               <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*">
                  <xsl:if test="collVolItem and not(collPagesItem) and urlItem">
                     <xsl:call-template name="RecordPosition"/>
                  </xsl:if>
               </xsl:for-each>
            </xsl:when>
            <xsl:when test="collVol and collPages and not(../url)">
               <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*">
                  <xsl:if test="collVolItem and collPagesItem and not(urlItem)">
                     <xsl:call-template name="RecordPosition"/>
                  </xsl:if>
               </xsl:for-each>
            </xsl:when>
            <xsl:when test="collVol and collPages and ../url">
               <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*">
                  <xsl:if test="collVolItem and collPagesItem and urlItem">
                     <xsl:call-template name="RecordPosition"/>
                  </xsl:if>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>0;</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
         -->
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetDissertationLayoutToUsePosition
    -->
    <xsl:template name="GetDissertationLayoutToUsePosition">
        <xsl:param name="layout"/>
        <xsl:variable name="sPosition">
            <xsl:choose>
                <xsl:when test="not(location) and not(published) and not(../url)">
                    <xsl:for-each select="$layout/*">
                        <xsl:if test="not(locationItem) and not(publishedLayoutRef) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(location) and not(published) and ../url">
                    <xsl:for-each select="$layout/*">
                        <xsl:if test="not(locationItem) and not(publishedLayoutRef) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(location) and published and not(../url)">
                    <xsl:for-each select="$layout/*">
                        <xsl:if test="not(locationItem) and publishedLayoutRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(location) and published and ../url">
                    <xsl:for-each select="$layout/*">
                        <xsl:if test="not(locationItem) and publishedLayoutRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="location and not(published) and not(../url)">
                    <xsl:for-each select="$layout/*">
                        <xsl:if test="locationItem and not(publishedLayoutRef) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="location and not(published) and ../url">
                    <xsl:for-each select="$layout/*">
                        <xsl:if test="locationItem and not(publishedLayoutRef) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="location and published and not(../url)">
                    <xsl:for-each select="$layout/*">
                        <xsl:if test="locationItem and publishedLayoutRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="location and published and ../url">
                    <xsl:for-each select="$layout/*">
                        <xsl:if test="locationItem and publishedLayoutRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
     GetFieldNotesLayoutToUsePosition
   -->
    <xsl:template name="GetFieldNotesLayoutToUsePosition">
        <xsl:variable name="sPosition">
            <xsl:choose>
                <xsl:when test="not(location) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/fieldNotesLayouts/*">
                        <xsl:if test="not(locationItem) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(location) and ./url">
                    <xsl:for-each select="$referencesLayoutInfo/fieldNotesLayouts/*">
                        <xsl:if test="not(locationItem) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="location and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/fieldNotesLayouts/*">
                        <xsl:if test="locationItem and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="location and ./url">
                    <xsl:for-each select="$referencesLayoutInfo/fieldNotesLayouts/*">
                        <xsl:if test="locationItem and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetFormattedPageNumbers
    -->
    <xsl:template name="GetFormattedPageNumbers">
        <xsl:param name="normalizedPages"/>
        <xsl:choose>
            <xsl:when test="$referencesLayoutInfo/@removecommonhundredsdigitsinpages='yes'">
                <xsl:variable name="startPage" select="substring-before($normalizedPages,'-')"/>
                <xsl:variable name="endPage" select="substring-after($normalizedPages,'-')"/>
                <xsl:choose>
                    <xsl:when test="string-length($startPage) = 3 and string-length($endPage) = 3 and substring($startPage,1,1)=substring($endPage,1,1)">
                        <xsl:value-of select="$startPage"/>
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="substring($endPage,2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$normalizedPages"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$normalizedPages"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      GetMsLayoutToUsePosition
   -->
    <xsl:template name="GetMsLayoutToUsePosition">
        <xsl:variable name="sPosition">
            <xsl:choose>
                <xsl:when test="not(location) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/msLayouts/*">
                        <xsl:if test="not(locationItem) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(location) and ./url">
                    <xsl:for-each select="$referencesLayoutInfo/msLayouts/*">
                        <xsl:if test="not(locationItem) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="location and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/msLayouts/*">
                        <xsl:if test="locationItem and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="location and ./url">
                    <xsl:for-each select="$referencesLayoutInfo/msLayouts/*">
                        <xsl:if test="locationItem and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetPaperLayoutToUsePosition
    -->
    <xsl:template name="GetPaperLayoutToUsePosition">
        <xsl:variable name="sPosition">
            <xsl:choose>
                <xsl:when test="not(location) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/paperLayouts/*">
                        <xsl:if test="not(locationItem) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(location) and ./url">
                    <xsl:for-each select="$referencesLayoutInfo/paperLayouts/*">
                        <xsl:if test="not(locationItem) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="location and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/paperLayouts/*">
                        <xsl:if test="locationItem and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="location and ./url">
                    <xsl:for-each select="$referencesLayoutInfo/paperLayouts/*">
                        <xsl:if test="locationItem and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetProceedingsLayoutToUsePosition
    -->
    <xsl:template name="GetProceedingsLayoutToUsePosition">
        <xsl:variable name="sPosition">
            <xsl:choose>
                <xsl:when test="not(procVol) and not(procPages) and not(location) and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and not(procPagesItem) and not(locationPublisherLayoutsRef) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and not(procPages) and not(location) and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and not(procPagesItem) and not(locationPublisherLayoutsRef) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and not(procPages) and not(location) and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and not(procPagesItem) and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and not(procPages) and not(location) and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and not(procPagesItem) and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and not(procPages) and location and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and not(procPagesItem) and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and not(procPages) and location and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and not(procPagesItem) and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and not(procPages) and location and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and not(procPagesItem) and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and not(procPages) and location and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and not(procPagesItem) and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and procPages and not(location) and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and procPagesItem and not(locationPublisherLayoutsRef) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and procPages and not(location) and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and procPagesItem and not(locationPublisherLayoutsRef) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and procPages and not(location) and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and procPagesItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and procPages and not(location) and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and procPagesItem and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and procPages and location and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and procPagesItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and procPages and location and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and procPagesItem and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and procPages and location and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and procPagesItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(procVol) and procPages and location and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="not(procVolItem) and procPagesItem and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and not(procPages) and not(location) and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and not(procPagesItem) and not(locationPublisherLayoutsRef) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and not(procPages) and not(location) and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and not(procPagesItem) and not(locationPublisherLayoutsRef) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and not(procPages) and not(location) and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and not(procPagesItem) and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and not(procPages) and not(location) and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and not(procPagesItem) and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and not(procPages) and location and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and not(procPagesItem) and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and not(procPages) and location and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and not(procPagesItem) and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and not(procPages) and location and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and not(procPagesItem) and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and not(procPages) and location and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and not(procPagesItem) and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and procPages and not(location) and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and procPagesItem and not(locationPublisherLayoutsRef) and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and procPages and not(location) and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and procPagesItem and not(locationPublisherLayoutsRef) and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and procPages and not(location) and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and procPagesItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and procPages and not(location) and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and procPagesItem and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and procPages and location and not(publisher) and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and procPagesItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and procPages and location and not(publisher) and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and procPagesItem and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and procPages and location and publisher and not(../url)">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and procPagesItem and locationPublisherLayoutsRef and not(urlItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="procVol and procPages and location and publisher and ../url">
                    <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                        <xsl:if test="procVolItem and procPagesItem and locationPublisherLayoutsRef and urlItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetWebPageLayoutToUsePosition
    -->
    <xsl:template name="GetWebPageLayoutToUsePosition">
        <xsl:variable name="sPosition">
            <xsl:choose>
                <!--                    edition?, location?, (institution | publisher)?, url, dateAccessed?-->
                <xsl:when test="not(institution) and not(publisher) and not(edition) and not(location) and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and not(publisherItem) and not(editionItem) and not(locationItem) and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and not(publisher) and not(edition) and not(location) and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and not(publisherItem) and not(editionItem) and not(locationItem) and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and not(publisher) and not(edition) and location and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and not(publisherItem) and not(editionItem) and locationItem and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and not(publisher) and not(edition) and location and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and not(publisherItem) and not(editionItem) and locationItem and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and not(publisher) and edition and not(location) and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and not(publisherItem) and editionItem and not(locationItem) and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and not(publisher) and edition and not(location) and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and not(publisherItem) and editionItem and not(locationItem) and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and not(publisher) and edition and location and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and not(publisherItem) and editionItem and locationItem and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and not(publisher) and edition and location and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and not(publisherItem) and editionItem and locationItem and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and publisher and not(edition) and not(location) and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and publisherItem and not(editionItem) and not(locationItem) and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and publisher and not(edition) and not(location) and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and publisherItem and not(editionItem) and not(locationItem) and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and publisher and not(edition) and location and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and publisherItem and not(editionItem) and locationItem and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and publisher and not(edition) and location and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and publisherItem and not(editionItem) and locationItem and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and publisher and edition and not(location) and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and publisherItem and editionItem and not(locationItem) and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and publisher and edition and not(location) and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and publisherItem and editionItem and not(locationItem) and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and publisher and edition and location and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and publisherItem and editionItem and locationItem and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not(institution) and publisher and edition and location and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="not(institutionItem) and publisherItem and editionItem and locationItem and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="institution and not(publisher) and not(edition) and not(location) and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="institutionItem and not(publisherItem) and not(editionItem) and not(locationItem) and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="institution and not(publisher) and not(edition) and not(location) and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="institutionItem and not(publisherItem) and not(editionItem) and not(locationItem) and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="institution and not(publisher) and not(edition) and location and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="institutionItem and not(publisherItem) and not(editionItem) and locationItem and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="institution and not(publisher) and not(edition) and location and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="institutionItem and not(publisherItem) and not(editionItem) and locationItem and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="institution and not(publisher) and edition and not(location) and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="institutionItem and not(publisherItem) and editionItem and not(locationItem) and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="institution and not(publisher) and edition and not(location) and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="institutionItem and not(publisherItem) and editionItem and not(locationItem) and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="institution and not(publisher) and edition and location and not(dateAccessed)">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="institutionItem and not(publisherItem) and editionItem and locationItem and not(dateAccessedItem)">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="institution and not(publisher) and edition and location and dateAccessed">
                    <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                        <xsl:if test="institutionItem and not(publisherItem) and editionItem and locationItem and dateAccessedItem">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
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
        <xsl:apply-templates select="$item"/>
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
        RecordPosition
    -->
    <xsl:template name="RecordPosition">
        <xsl:value-of select="position()"/>
        <xsl:text>;</xsl:text>
    </xsl:template>
    <!--  
        ReportNoPatternMatched
    -->
    <xsl:template name="ReportNoPatternMatched">
        <xsl:call-template name="ReportTeXCannotHandleThisMessage">
            <xsl:with-param name="sMessage"><xsl:text>Sorry, but there is no matching layout for this item in the publisher style sheet.  Please add  (or have someone add) the pattern.</xsl:text></xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
