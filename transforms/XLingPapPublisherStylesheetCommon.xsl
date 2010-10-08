<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:saxon="http://icl.com/saxon">
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
        collCitation
    -->
    <xsl:template match="collCitation">
        <xsl:param name="layout"/>
        <xsl:call-template name="DoCitation">
            <xsl:with-param name="layout" select="$layout"/>
        </xsl:call-template>
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
        procCitation
    -->
    <xsl:template match="procCitation">
        <xsl:param name="layout"/>
        <xsl:call-template name="DoCitation">
            <xsl:with-param name="layout" select="$layout"/>
        </xsl:call-template>
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
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <!--
        url
    -->
    <xsl:template match="url">
        <xsl:call-template name="DoUrlLayout"/>
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
                            <xsl:when test="name(.)='jIssueNumberItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($article/jIssueNumber)"/>
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
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/dateAccessed)"/>
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
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/dateAccessed)"/>
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
        DoCitation
    -->
    <xsl:template name="DoCitation">
        <xsl:param name="layout"/>
        <xsl:variable name="sThisRefToBook" select="@refToBook"/>
        <xsl:choose>
            <xsl:when test="saxon:node-set($collOrProcVolumesToInclude)/refWork[@id=$sThisRefToBook]">
                <xsl:call-template name="DoRefCitation">
                    <xsl:with-param name="citation" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="FleshOutRefCitation">
                    <xsl:with-param name="citation" select="."/>
                    <xsl:with-param name="citationLayout" select="$layout/.."/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoCitedCollectionLayout
    -->
    <xsl:template name="DoCitedCollectionLayout">
        <xsl:param name="book"/>
        <xsl:param name="citation"/>
        <xsl:param name="citationLayout"/>
        <xsl:variable name="work" select="$book/.."/>
        <xsl:variable name="citedCollectionLayoutToUsePosition">
            <xsl:for-each select="$book">
                <xsl:call-template name="GetCitedCollectionLayoutToUsePosition">
                    <xsl:with-param name="collCitation" select="$citation"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$citedCollectionLayoutToUsePosition=0 or string-length($citedCollectionLayoutToUsePosition)=0">
                <xsl:for-each select="$book">
                    <xsl:call-template name="ReportNoPatternMatchedForCollCitation">
                        <xsl:with-param name="collCitation" select="$citation"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*[position()=$citedCollectionLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='collEdItem'">
                                <xsl:for-each select="$citationLayout/authorRoleItem">
                                    <xsl:call-template name="OutputReferenceItem">
                                        <xsl:with-param name="item" select="normalize-space($work/authorRole)"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="name(.)='collTitleItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/refTitle)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='collVolItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($book/bVol)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='collPagesItem'">
                                <xsl:call-template name="OutputCitationPages">
                                    <xsl:with-param name="citation" select="$citation"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='seriesEdItem'">
                                <xsl:variable name="item" select="$book/seriesEd"/>
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($item)"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoEditorAbbreviation">
                                    <xsl:with-param name="item" select="$item"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='seriesItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($book/series)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <!--        in a series??                    <xsl:when test="name(.)='bVolItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($collection/bVol)"/>
                                </xsl:call-template>
                            </xsl:when>
-->
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/dateAccessed)"/>
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
        DoCitedProceedingsLayout
    -->
    <xsl:template name="DoCitedProceedingsLayout">
        <xsl:param name="book"/>
        <xsl:param name="citation"/>
        <xsl:param name="citationLayout"/>
        <xsl:variable name="work" select="$book/.."/>
        <xsl:variable name="citedProceedingsLayoutToUsePosition">
            <xsl:for-each select="$book">
                <xsl:call-template name="GetCitedProceedingsLayoutToUsePosition">
                    <xsl:with-param name="procCitation" select="$citation"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="proceedings" select="."/>
        <xsl:choose>
            <xsl:when test="$citedProceedingsLayoutToUsePosition=0 or string-length($citedProceedingsLayoutToUsePosition)=0">
                <xsl:for-each select="$book">
                    <xsl:call-template name="ReportNoPatternMatchedForProcCitation">
                        <xsl:with-param name="procCitation" select="$citation"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*[position()=$citedProceedingsLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='procEdItem'">
                                <xsl:for-each select="$citationLayout/authorRoleItem">
                                    <xsl:call-template name="OutputReferenceItem">
                                        <xsl:with-param name="item" select="normalize-space($work/authorRole)"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="name(.)='procTitleItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/refTitle)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='procVolItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($book/bVol)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='procPagesItem'">
                                <xsl:call-template name="OutputCitationPages">
                                    <xsl:with-param name="citation" select="$citation"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/dateAccessed)"/>
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
                <xsl:variable name="bHasCollCitation">
                    <xsl:choose>
                        <xsl:when test="collCitation">Y</xsl:when>
                        <xsl:otherwise>N</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="bUseCitationAsLink">
                    <xsl:variable name="sThisRefToBook" select="collCitation/@refToBook"/>
                    <xsl:choose>
                        <xsl:when test="saxon:node-set($collOrProcVolumesToInclude)/refWork[@id=$sThisRefToBook]">
                            <xsl:text>Y</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>N</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*[position()=$collectionLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refTitleItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='collCitationItem'">
                                <xsl:call-template name="OutputCitation">
                                    <xsl:with-param name="item" select="$collection/collCitation"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='authorRoleItem'">
                                <xsl:if test="$bHasCollCitation='Y' and $bUseCitationAsLink='Y'">
                                    <xsl:call-template name="OutputReferenceItem">
                                        <xsl:with-param name="item" select="normalize-space(key('RefWorkID',$collection/collCitation/@refToBook)/authorRole)"/>
                                    </xsl:call-template>
                                </xsl:if>
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
                                <xsl:if test="$bHasCollCitation='N' or $bUseCitationAsLink='Y'">
                                    <xsl:variable name="sNormalizedPages">
                                        <xsl:variable name="sCitationPages" select="normalize-space($collection/collCitation/@page)"/>
                                        <xsl:choose>
                                            <xsl:when test="not($collection/collPages) and string-length($sCitationPages) &gt; 0">
                                                <xsl:value-of select="$sCitationPages"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="normalize-space($collection/collPages)"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="pages">
                                        <xsl:call-template name="GetFormattedPageNumbers">
                                            <xsl:with-param name="normalizedPages" select="$sNormalizedPages"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:call-template name="OutputReferenceItem">
                                        <xsl:with-param name="item" select="$pages"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='seriesEdItem'">
                                <xsl:variable name="item" select="$collection/seriesEd"/>
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($item)"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoEditorAbbreviation">
                                    <xsl:with-param name="item" select="$item"/>
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
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/dateAccessed)"/>
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
                            <xsl:when test="name(.)='dissertationLabelItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item">
                                        <xsl:call-template name="OutputLabel">
                                            <xsl:with-param name="sDefault">Ph.D. dissertation</xsl:with-param>
                                            <xsl:with-param name="pLabel" select="$references/@labelDissertation"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='thesisLabelItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item">
                                        <xsl:call-template name="OutputLabel">
                                            <xsl:with-param name="sDefault">M.A. thesis</xsl:with-param>
                                            <xsl:with-param name="pLabel" select="$references/@labelThesis"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
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
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/dateAccessed)"/>
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
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/dateAccessed)"/>
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
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/dateAccessed)"/>
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
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/dateAccessed)"/>
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
                <xsl:variable name="bHasProcCitation">
                    <xsl:choose>
                        <xsl:when test="procCitation">Y</xsl:when>
                        <xsl:otherwise>N</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="bUseCitationAsLink">
                    <xsl:variable name="sThisRefToBook" select="procCitation/@refToBook"/>
                    <xsl:choose>
                        <xsl:when test="saxon:node-set($collOrProcVolumesToInclude)/refWork[@id=$sThisRefToBook]">
                            <xsl:text>Y</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>N</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*[position()=$proceedingsLayoutToUsePosition]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='refTitleItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='procCitationItem'">
                                <xsl:call-template name="OutputCitation">
                                    <xsl:with-param name="item" select="$proceedings/procCitation"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='authorRoleItem'">
                                <xsl:if test="$bHasProcCitation='Y' and $bUseCitationAsLink='Y'">
                                    <xsl:call-template name="OutputReferenceItem">
                                        <xsl:with-param name="item" select="normalize-space(key('RefWorkID',$proceedings/procCitation/@refToBook)/authorRole)"/>
                                    </xsl:call-template>
                                </xsl:if>
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
                                <xsl:if test="$bHasProcCitation='N' or $bUseCitationAsLink='Y'">
                                    <xsl:variable name="sNormalizedPages">
                                        <xsl:variable name="sCitationPages" select="normalize-space($proceedings/procCitation/@page)"/>
                                        <xsl:choose>
                                            <xsl:when test="not($proceedings/procPages) and string-length($sCitationPages) &gt; 0">
                                                <xsl:value-of select="$sCitationPages"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="normalize-space($proceedings/procPages)"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="pages">
                                        <xsl:call-template name="GetFormattedPageNumbers">
                                            <xsl:with-param name="normalizedPages" select="$sNormalizedPages"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:call-template name="OutputReferenceItem">
                                        <xsl:with-param name="item" select="$pages"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/dateAccessed)"/>
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
                                <xsl:call-template name="DoWebPageUrlItem">
                                    <xsl:with-param name="webPage" select="$webPage"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($work/dateAccessed)"/>
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
        FleshOutRefCitation
    -->
    <xsl:template name="FleshOutRefCitation">
        <xsl:param name="citation"/>
        <xsl:param name="citationLayout"/>
        <xsl:variable name="citedWork" select="key('RefWorkID',$citation/@refToBook)"/>
        <xsl:call-template name="ConvertLastNameFirstNameToFirstNameLastName">
            <xsl:with-param name="sCitedWorkAuthor" select="$citedWork/../@name"/>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="name($citation)='collCitation'">
                <xsl:call-template name="DoCitedCollectionLayout">
                    <xsl:with-param name="book" select="$citedWork/book"/>
                    <xsl:with-param name="citation" select="$citation"/>
                    <xsl:with-param name="citationLayout" select="$citationLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoCitedProceedingsLayout">
                    <xsl:with-param name="book" select="$citedWork/book"/>
                    <xsl:with-param name="citation" select="$citation"/>
                    <xsl:with-param name="citationLayout" select="$citationLayout"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        GetArticleLayoutToUsePosition
    -->
    <xsl:template name="GetArticleLayoutToUsePosition">
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <!-- first, indicate that the required refTitle is present -->
            <xsl:text>y</xsl:text>
            <xsl:choose>
                <xsl:when test="jTitle">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="jVol">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="jIssueNumber">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="jPages">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="jArticleNumber">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="location or publisher">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../dateAccessed">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:for-each select="$referencesLayoutInfo/articleLayouts/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and refTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(refTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and jTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(jTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and jVolItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(jVolItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and jIssueNumberItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(jIssueNumberItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and jPagesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(jPagesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and jArticleNumberItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(jArticleNumberItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='y' and locationPublisherLayoutsRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='n' and not(locationPublisherLayoutsRef)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 9, 1)='y' and dateAccessedItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 9, 1)='n' and not(dateAccessedItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 10">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
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
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <!-- first, indicate that the required refTitle is present -->
            <xsl:text>y</xsl:text>
            <xsl:choose>
                <xsl:when test="translatedBy">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="edition">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="seriesEd">y</xsl:when>
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
                <xsl:when test="bookTotalPages">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="location or publisher">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../dateAccessed">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:for-each select="$referencesLayoutInfo/bookLayouts/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and refTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(refTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and translatedByItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(translatedByItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and editionItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(editionItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and seriesEdItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(seriesEdItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and seriesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(seriesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and bVolItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(bVolItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='y' and bookTotalPagesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='n' and not(bookTotalPagesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and locationPublisherLayoutsRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(locationPublisherLayoutsRef)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 9, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 9, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='y' and dateAccessedItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='n' and not(dateAccessedItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,11, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,11, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 11">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetCitedCollectionLayoutToUsePosition
    -->
    <xsl:template name="GetCitedCollectionLayoutToUsePosition">
        <xsl:param name="collCitation"/>
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <xsl:choose>
                <xsl:when test="../authorRole">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../refTitle">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="bVol">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="string-length(normalize-space($collCitation/@page)) &gt; 0">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="seriesEd">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="series">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="location or publisher">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../dateAccessed">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:variable name="refWork" select="."/>
            <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and collEdItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(collEdItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and collTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(collTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and collVolItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(collVolItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and collPagesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(collPagesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and seriesEdItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(seriesEdItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and seriesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(seriesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='y' and locationPublisherLayoutsRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='n' and not(locationPublisherLayoutsRef)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 9, 1)='y' and dateAccessedItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,  9, 1)='n' and not(dateAccessedItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 10">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetCitedProceedingsLayoutToUsePosition
    -->
    <xsl:template name="GetCitedProceedingsLayoutToUsePosition">
        <xsl:param name="procCitation"/>
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <xsl:choose>
                <xsl:when test="../authorRole">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../refTitle">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="bVol">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="string-length(normalize-space($procCitation/@page)) &gt; 0">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="location or publisher">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../dateAccessed">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:variable name="refWork" select="."/>
            <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and procEdItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(procEdItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and procTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(procTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and procVolItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(procVolItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and procPagesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(procPagesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and locationPublisherLayoutsRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(locationPublisherLayoutsRef)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='y' and dateAccessedItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='n' and not(dateAccessedItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 8">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetCollectionLayoutToUsePosition
    -->
    <xsl:template name="GetCollectionLayoutToUsePosition">
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <!-- first, indicate that the required refTitle is present -->
            <xsl:text>y</xsl:text>
            <xsl:choose>
                <xsl:when test="collEd">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="collTitle">y</xsl:when>
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
                <xsl:when test="seriesEd">y</xsl:when>
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
                <xsl:when test="location or publisher">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="collCitation">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../dateAccessed">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="key('RefWorkID',collCitation/@refToBook)/authorRole">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:variable name="refWork" select="."/>
            <xsl:for-each select="$referencesLayoutInfo/collectionLayouts/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and refTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(refTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and collEdItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(collEdItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and collTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(collTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and collVolItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(collVolItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and collPagesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(collPagesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and seriesEdItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(seriesEdItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='y' and seriesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='n' and not(seriesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and bVolItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(bVolItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 9, 1)='y' and locationPublisherLayoutsRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 9, 1)='n' and not(locationPublisherLayoutsRef)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='y' and collCitationItem">
                            <xsl:choose>
                                <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and collPagesItem and string-length(normalize-space($refWork/collCitation/@page)) &gt; 0">xx</xsl:when>
                                <xsl:otherwise>x</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='n' and not(collCitationItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,11, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,11, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,12, 1)='y' and dateAccessedItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,12, 1)='n' and not(dateAccessedItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,13, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,13, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,14, 1)='y' and authorRoleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,14, 1)='n' and not(authorRoleItem)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 14">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetDissertationLayoutToUsePosition
    -->
    <xsl:template name="GetDissertationLayoutToUsePosition">
        <xsl:param name="layout"/>
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <!-- first, indicate that the required refTitle is present -->
            <xsl:text>y</xsl:text>
            <xsl:choose>
                <xsl:when test="location">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <!-- indicate that the implied dissertation/thesis label is present -->
            <xsl:text>y</xsl:text>
            <xsl:choose>
                <xsl:when test="institution">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="published">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../dateAccessed">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:for-each select="$layout/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and refTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(refTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and locationItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(locationItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and dissertationLabelItem or substring($sOptionsPresent, 3, 1)='y' and thesisLabelItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(dissertationLabelItem) and not(thesisLabelItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and institutionItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(institutionItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and publishedLayoutRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(publishedLayoutRef)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='y' and dateAccessedItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='n' and not(dateAccessedItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 8">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
     GetFieldNotesLayoutToUsePosition
   -->
    <xsl:template name="GetFieldNotesLayoutToUsePosition">
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <!-- first, indicate that the required refTitle is present -->
            <xsl:text>y</xsl:text>
            <xsl:choose>
                <xsl:when test="location">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="institution">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../dateAccessed">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:for-each select="$referencesLayoutInfo/fieldNotesLayouts/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and refTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(refTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and locationItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(locationItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and institutionItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(institutionItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and dateAccessedItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(dateAccessedItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 6">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
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
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <!-- first, indicate that the required refTitle is present -->
            <xsl:text>y</xsl:text>
            <xsl:choose>
                <xsl:when test="location">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="institution">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../dateAccessed">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:for-each select="$referencesLayoutInfo/msLayouts/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and refTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(refTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and locationItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(locationItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and institutionItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(institutionItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and dateAccessedItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(dateAccessedItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 6">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetPaperLayoutToUsePosition
    -->
    <xsl:template name="GetPaperLayoutToUsePosition">
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <!-- first, indicate that the required refTitle is present -->
            <xsl:text>y</xsl:text>
            <xsl:choose>
                <xsl:when test="conference">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="location">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../dateAccessed">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:for-each select="$referencesLayoutInfo/paperLayouts/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and refTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(refTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and conferenceItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(conferenceItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and locationItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(locationItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and dateAccessedItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(dateAccessedItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 6">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetProceedingsLayoutToUsePosition
    -->
    <xsl:template name="GetProceedingsLayoutToUsePosition">
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <!-- first, indicate that the required refTitle is present -->
            <xsl:text>y</xsl:text>
            <xsl:choose>
                <xsl:when test="procEd">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="procTitle">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="procVol">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="procPages">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="location or publisher">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="procCitation">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../dateAccessed">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:variable name="refWork" select="."/>
            <xsl:for-each select="$referencesLayoutInfo/proceedingsLayouts/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and refTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(refTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and procEdItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(procEdItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and procTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(procTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and procVolItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(procVolItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and procPagesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(procPagesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and locationPublisherLayoutsRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(locationPublisherLayoutsRef)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='y' and procCitationItem">
                            <xsl:choose>
                                <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and procPagesItem and string-length(normalize-space($refWork/procCitation/@page)) &gt; 0">xx</xsl:when>
                                <xsl:otherwise>x</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='n' and not(procCitationItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 9, 1)='y' and dateAccessedItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 9, 1)='n' and not(dateAccessedItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 10">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetWebPageLayoutToUsePosition
    -->
    <xsl:template name="GetWebPageLayoutToUsePosition">
        <xsl:variable name="sOptionsPresent">
            <!-- for each possible option, in order, set it to 'y' if present, otherwise 'n' -->
            <!-- first, indicate that the required refTitle is present -->
            <xsl:text>y</xsl:text>
            <xsl:choose>
                <xsl:when test="edition">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="location">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="institution">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="publisher">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="url">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="dateAccessed">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sPosition">
            <xsl:for-each select="$referencesLayoutInfo/webPageLayouts/*">
                <xsl:variable name="sItemsWhichMatchOptions">
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='y' and refTitleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 1, 1)='n' and not(refTitleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='y' and editionItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 2, 1)='n' and not(editionItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='y' and locationItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 3, 1)='n' and not(locationItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and institutionItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(institutionItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='y' and publisherItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and not(publisherItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and urlItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(urlItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='y' and dateAccessedItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='n' and not(dateAccessedItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 8">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        OutputCollCitation
    -->
    <xsl:template name="OutputCitationPages">
        <xsl:param name="citation"/>
        <xsl:variable name="sNormalizedPages">
            <xsl:variable name="sCitationPages" select="normalize-space($citation/@page)"/>
            <xsl:if test="string-length($sCitationPages) &gt; 0">
                <xsl:value-of select="$sCitationPages"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="pages">
            <xsl:call-template name="GetFormattedPageNumbers">
                <xsl:with-param name="normalizedPages" select="$sNormalizedPages"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="OutputReferenceItem">
            <xsl:with-param name="item" select="$pages"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        OutputCitation
    -->
    <xsl:template name="OutputCitation">
        <xsl:param name="item"/>
        <xsl:call-template name="OutputReferenceItemNode">
            <xsl:with-param name="item" select="$item"/>
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
        ReportPattern
    -->
    <xsl:template name="ReportPattern">
        <xsl:variable name="followingSiblings" select="following-sibling::*"/>
        <xsl:variable name="children" select="./*"/>
        <xsl:text>  It is a </xsl:text>
        <xsl:value-of select="name(.)"/>
        <xsl:text>   pattern that contains these elements: </xsl:text>
        <xsl:choose>
            <xsl:when test="count($followingSiblings) + count($children) =0">
                <xsl:text>(it is empty).</xsl:text>
            </xsl:when>
            <xsl:otherwise>
<!--                <xsl:text>, </xsl:text>-->
            </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="./*">
            <xsl:if test="not(contains(name(.), 'LowerCase'))">
                <xsl:value-of select="name(.)"/>
                <xsl:if test="name()='collCitation'">
                    <xsl:if test="key('RefWorkID',@refToBook)/authorRole">
                        <xsl:text>, authorRole</xsl:text>
                    </xsl:if>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="position()=last() and count($followingSiblings) = 0">
                        <xsl:text>.</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>, </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="$followingSiblings">
            <xsl:value-of select="name(.)"/>
            <xsl:choose>
                <xsl:when test="position()=last()">
                    <xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>, </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
        ReportPatternForCollCitation
    -->
    <xsl:template name="ReportPatternForCollCitation">
        <xsl:param name="collCitation"/>
        <xsl:variable name="followingSiblings" select="following-sibling::*"/>
        <xsl:variable name="children" select="./*"/>
        <xsl:text>  It is a collection pattern that contains these elements:</xsl:text>
        <xsl:if test="../authorRole">
            <xsl:text>, collEd</xsl:text>
        </xsl:if>
        <xsl:if test="../refTitle">
            <xsl:text>, collTitle</xsl:text>
        </xsl:if>
        <xsl:if test="bVol">
            <xsl:text>, collVol</xsl:text>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($collCitation/@page)) &gt; 0">
            <xsl:text>, collPages</xsl:text>
        </xsl:if>
        <xsl:if test="seriesEd">
            <xsl:text>, seriesEd</xsl:text>
        </xsl:if>
        <xsl:if test="series">
            <xsl:text>, series</xsl:text>
        </xsl:if>
        <xsl:if test="location or publisher">
            <xsl:text>, location or publisher</xsl:text>
        </xsl:if>
        <xsl:if test="../url">
            <xsl:text>, url</xsl:text>
        </xsl:if>
        <xsl:if test="../dateAccessed">
            <xsl:text>, dateAccessed</xsl:text>
        </xsl:if>
        <xsl:if test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">
            <xsl:text>, iso639-3code</xsl:text>
        </xsl:if>
        <xsl:text>.</xsl:text>
    </xsl:template>
    <!--  
        ReportPatternForPorcCitation
    -->
    <xsl:template name="ReportPatternForProcCitation">
        <xsl:param name="procCitation"/>
        <xsl:variable name="followingSiblings" select="following-sibling::*"/>
        <xsl:variable name="children" select="./*"/>
        <xsl:text>  It is a proceedings pattern that contains these elements:</xsl:text>
        <xsl:if test="../authorRole">
            <xsl:text>, procEd</xsl:text>
        </xsl:if>
        <xsl:if test="../refTitle">
            <xsl:text>, procTitle</xsl:text>
        </xsl:if>
        <xsl:if test="bVol">
            <xsl:text>, procVol</xsl:text>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($procCitation/@page)) &gt; 0">
            <xsl:text>, procPages</xsl:text>
        </xsl:if>
        <xsl:if test="location or publisher">
            <xsl:text>, location or publisher</xsl:text>
        </xsl:if>
        <xsl:if test="../url">
            <xsl:text>, url</xsl:text>
        </xsl:if>
        <xsl:if test="../dateAccessed">
            <xsl:text>, dateAccessed</xsl:text>
        </xsl:if>
        <xsl:if test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">
            <xsl:text>, iso639-3code</xsl:text>
        </xsl:if>
        <xsl:text>.</xsl:text>
    </xsl:template>
</xsl:stylesheet>
