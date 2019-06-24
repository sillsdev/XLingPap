<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:saxon="http://icl.com/saxon">
    <!-- global variables -->
    <xsl:variable name="locationPublisherLayouts" select="$referencesLayoutInfo/locationPublisherLayouts"/>
    <xsl:variable name="urlDateAccessedLayouts" select="$referencesLayoutInfo/urlDateAccessedLayouts"/>
    <xsl:variable name="chapterNumberInHeaderLayout" select="$bodyLayoutInfo/headerFooterPageStyles/descendant::chapterNumber"/>
    <xsl:variable name="bChapterNumberIsBeforeTitle">
        <xsl:choose>
            <xsl:when test="$chapterNumberInHeaderLayout[following-sibling::chapterTitle]">
                <xsl:text>Y</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>N</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sectionNumberInHeaderLayout" select="$bodyLayoutInfo/headerFooterPageStyles/descendant::sectionNumber | $pageLayoutInfo/headerFooterPageStyles/descendant::sectionNumber"/>
    <xsl:variable name="bSectionNumberIsBeforeTitle">
        <xsl:choose>
            <xsl:when test="$sectionNumberInHeaderLayout[1][following-sibling::sectionTitle]">
                <xsl:text>Y</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>N</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sContentBetweenFootnoteNumberAndFootnoteContent" select="$pageLayoutInfo/@contentBetweenFootnoteNumberAndFootnoteContent"/>
    <xsl:variable name="citationLayout" select="$contentLayoutInfo/citationLayout"/>
    <xsl:variable name="sTextBetweenAuthorAndDate" select="$citationLayout/@textbetweenauthoranddate"/>
    <!--    <xsl:variable name="contentsLayout" select="$frontMatterLayoutInfo/contentsLayout"/>-->
    <xsl:variable name="contentsLayout">
        <xsl:choose>
            <xsl:when test="$backMatterLayoutInfo/contentsLayout">
                <xsl:copy-of select="$backMatterLayoutInfo/contentsLayout"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$frontMatterLayoutInfo/contentsLayout"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!--    <xsl:variable name="sChapterLineIndent" select="normalize-space(saxon:node-set($contentsLayout)/contentsLayout/@chapterlineindent)"/>-->
    <!--    <xsl:variable name="authorInContentsLayoutInfo" select="$frontMatterLayoutInfo/authorLayout[preceding-sibling::*[1][name()='contentsLayout']]"/>-->
    <xsl:variable name="authorInContentsLayoutInfo">
        <xsl:choose>
            <xsl:when test="$backMatterLayoutInfo/authorLayout[preceding-sibling::*[1][name()='contentsLayout']]">
                <xsl:copy-of select="$backMatterLayoutInfo/authorLayout[preceding-sibling::*[1][name()='contentsLayout']]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$frontMatterLayoutInfo/authorLayout[preceding-sibling::*[1][name()='contentsLayout']]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="annotationLayoutInfo" select="$contentLayoutInfo/annotationLayout"/>
    <xsl:variable name="nLevel">
        <xsl:choose>
            <xsl:when test="$contents/@showLevel">
                <xsl:value-of select="number($contents/@showLevel)"/>
            </xsl:when>
            <xsl:otherwise>3</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nBackMatterLevel">
        <xsl:choose>
            <xsl:when test="$contents/@backmattershowLevel">
                <xsl:value-of select="number($contents/@backmattershowLevel)"/>
            </xsl:when>
            <xsl:otherwise>3</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- ===========================================================
        NUMBERING PROCESSING 
        =========================================================== -->
    <!--  
        section
    -->
    <xsl:template mode="number" match="*">
        <xsl:choose>
            <xsl:when test="ancestor-or-self::chapter">
                <xsl:apply-templates select="." mode="numberChapter"/>
                <xsl:if test="ancestor::chapter">
                    <xsl:text>.</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:when test="ancestor-or-self::chapterInCollection">
                <xsl:apply-templates select="." mode="numberChapter"/>
                <xsl:if test="ancestor::chapterInCollection">
                    <xsl:text>.</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:when test="ancestor-or-self::chapterBeforePart">
                <xsl:text>0</xsl:text>
                <xsl:if test="ancestor::chapterBeforePart">
                    <xsl:text>.</xsl:text>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$bodyLayoutInfo/section1Layout/@startSection1NumberingAtZero='yes'">
                <xsl:variable name="numAt1">
                    <xsl:number level="multiple" count="section1 | section2 | section3 | section4 | section5 | section6" format="1.1"/>
                </xsl:variable>
                <!--  adjust section1 number down by one to start with 0 -->
                <xsl:variable name="num1" select="substring-before($numAt1,'.')"/>
                <xsl:variable name="numRest" select="substring-after($numAt1,'.')"/>
                <xsl:variable name="num1At0">
                    <xsl:choose>
                        <xsl:when test="$num1">
                            <xsl:value-of select="number($num1)-1"/>
                            <xsl:text>.</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="number($numAt1)-1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="$num1At0"/>
                <xsl:value-of select="$numRest"/>
            </xsl:when>
            <xsl:when test="count($chapters)=0 and count(//section1)=1 and count(//section1/section2)=0">
                <!-- if there are no chapters and there is but one section1 (with no subsections), there's no need to have a number so don't  -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="multiple" count="section1 | section2 | section3 | section4 | section5 | section6" format="1.1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        endnote
    -->
    <xsl:template mode="endnote" match="endnote[parent::author]">
        <xsl:variable name="iAuthorPosition" select="count(ancestor::author/preceding-sibling::author[endnote]) + 1"/>
        <xsl:call-template name="OutputAuthorFootnoteSymbol">
            <xsl:with-param name="iAuthorPosition" select="$iAuthorPosition"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        figure
    -->
    <xsl:template mode="figure" match="*" priority="10">
        <xsl:choose>
            <xsl:when test="$bIsBook and $styleSheetFigureNumberLayout/@showchapternumber='yes'">
                <xsl:for-each select="ancestor::chapter | ancestor::appendix | ancestor::chapterBeforePart | ancestor::chapterInCollection">
                    <xsl:call-template name="OutputChapterNumber">
                        <xsl:with-param name="fIgnoreTextAfterLetter" select="'Y'"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:value-of select="$styleSheetFigureNumberLayout/@textbetweenchapterandnumber"/>
                <xsl:number level="any" count="figure[not(ancestor::endnote or ancestor::framedUnit)]" from="chapter | appendix | chapterBeforePart | chapterInCollection"
                    format="{$styleSheetFigureNumberLayout/@format}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="any" count="figure[not(ancestor::endnote or ancestor::framedUnit)]" format="{$styleSheetFigureNumberLayout/@format}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        tablenumbered
    -->
    <xsl:template mode="tablenumbered" match="*" priority="10">
        <xsl:choose>
            <xsl:when test="$bIsBook and $styleSheetTableNumberedNumberLayout/@showchapternumber='yes'">
                <xsl:for-each select="ancestor::chapter | ancestor::appendix | ancestor::chapterBeforePart | ancestor::chapterInCollection">
                    <xsl:call-template name="OutputChapterNumber">
                        <xsl:with-param name="fIgnoreTextAfterLetter" select="'Y'"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:value-of select="$styleSheetTableNumberedNumberLayout/@textbetweenchapterandnumber"/>
                <xsl:number level="any" count="tablenumbered[not(ancestor::endnote or ancestor::framedUnit)]" from="chapter | appendix | chapterBeforePart | chapterInCollection"
                    format="{$styleSheetTableNumberedNumberLayout/@format}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="any" count="tablenumbered[not(ancestor::endnote or ancestor::framedUnit)]" format="{$styleSheetTableNumberedNumberLayout/@format}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        letter
    -->
    <xsl:template mode="letter" match="*">
        <xsl:number level="single" count="listWord | listSingle | listInterlinear | listDefinition | lineSet" format="a"/>
    </xsl:template>
    <!--  
        dateLetter
    -->
    <xsl:template match="*" mode="dateLetter">
        <xsl:param name="date"/>
        <xsl:number level="single" count="refWork[@id=//citation/@ref][refDate=$date or refDate/@citedate=$date]" format="a"/>
    </xsl:template>
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
        <xsl:apply-templates select="comment"/>
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
        <xsl:apply-templates select="comment"/>
    </xsl:template>
    <!--
        dissertation
    -->
    <xsl:template match="dissertation">
        <xsl:call-template name="DoDissertationLayout">
            <xsl:with-param name="layout" select="$referencesLayoutInfo/dissertationLayouts"/>
        </xsl:call-template>
        <xsl:apply-templates select="comment"/>
    </xsl:template>
    <!--
        article
    -->
    <xsl:template match="article">
        <xsl:call-template name="DoArticleLayout"/>
        <xsl:apply-templates select="comment"/>
    </xsl:template>
    <!--
        field notes
    -->
    <xsl:template match="fieldNotes">
        <xsl:call-template name="DoFieldNotesLayout"/>
        <xsl:apply-templates select="comment"/>
    </xsl:template>
    <!--
        glossary
    -->
    <xsl:template match="glossary">
        <xsl:param name="backMatterLayout" select="$backMatterLayoutInfo"/>
        <xsl:param name="iLayoutPosition" select="0"/>
        <xsl:variable name="iPos" select="count(preceding-sibling::glossary) + 1"/>
        <xsl:variable name="glossaryLayout" select="$backMatterLayout/glossaryLayout"/>
        <xsl:variable name="fLayoutIsLastOfMany">
            <xsl:choose>
                <xsl:when test="$iLayoutPosition=0">
                    <xsl:text>N</xsl:text>
                </xsl:when>
                <xsl:when test="count($glossaryLayout[number($iLayoutPosition)]/following-sibling::glossaryLayout)=0">
                    <xsl:text>Y</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>N</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$iLayoutPosition = 0">
                <!-- there's one and only one glossaryLayout; use it -->
                <xsl:call-template name="DoGlossaryPerLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="glossaryLayout" select="$glossaryLayout"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$iLayoutPosition = $iPos">
                <!-- there are many glossaryLayouts; use the one that matches in position -->
                <xsl:call-template name="DoGlossaryPerLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="glossaryLayout" select="$glossaryLayout[number($iLayoutPosition)]"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
                <!-- there are many glossaryLayouts and there are more glossary elements than glossaryLayout elements; use the last layout -->
                <xsl:call-template name="DoGlossaryPerLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="glossaryLayout" select="$glossaryLayout[number(last())]"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        ms
    -->
    <xsl:template match="ms">
        <xsl:call-template name="DoMsLayout"/>
        <xsl:apply-templates select="comment"/>
    </xsl:template>
    <!--
        paper
    -->
    <xsl:template match="paper">
        <xsl:call-template name="DoPaperLayout"/>
        <xsl:apply-templates select="comment"/>
    </xsl:template>
    <!--
        abstract (book)
    -->
    <xsl:template match="abstract" mode="book">
        <xsl:param name="iLayoutPosition" select="0"/>
        <xsl:variable name="iPos" select="count(preceding-sibling::abstract) + 1"/>
        <xsl:variable name="fLayoutIsLastOfMany">
            <xsl:choose>
                <xsl:when test="$iLayoutPosition=0">
                    <xsl:text>N</xsl:text>
                </xsl:when>
                <xsl:when test="count($frontMatterLayoutInfo/abstractLayout[number($iLayoutPosition)]/following-sibling::abstractLayout)=0">
                    <xsl:text>Y</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>N</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$iLayoutPosition = 0">
                <!-- there's one and only one abstractLayout; use it -->
                <xsl:call-template name="DoAbstractPerBookLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="abstractLayout" select="$frontMatterLayoutInfo/abstractLayout"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$iLayoutPosition = $iPos">
                <!-- there are many abstractLayouts; use the one that matches in position -->
                <xsl:call-template name="DoAbstractPerBookLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="abstractLayout" select="$frontMatterLayoutInfo/abstractLayout[number($iLayoutPosition)]"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
                <!-- there are many abstractLayouts and there are more abstract elements than abstractLayout elements; use the last layout -->
                <xsl:call-template name="DoAbstractPerBookLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="abstractLayout" select="$frontMatterLayoutInfo/abstractLayout[number(last())]"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        abstract (paper)
    -->
    <xsl:template match="abstract" mode="paper">
        <xsl:param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <xsl:param name="iLayoutPosition" select="0"/>
        <xsl:variable name="iPos" select="count(preceding-sibling::abstract) + 1"/>
        <xsl:variable name="fLayoutIsLastOfMany">
            <xsl:choose>
                <xsl:when test="$iLayoutPosition=0">
                    <xsl:text>N</xsl:text>
                </xsl:when>
                <xsl:when test="count($frontMatterLayout/abstractLayout[number($iLayoutPosition)]/following-sibling::abstractLayout)=0">
                    <xsl:text>Y</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>N</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$iLayoutPosition = 0">
                <!-- there's one and only one abstractLayout; use it -->
                <xsl:call-template name="DoAbstractPerPaperLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="abstractLayout" select="$frontMatterLayout/abstractLayout[1]"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$iLayoutPosition = $iPos">
                <!-- there are many abstractLayouts; use the one that matches in position -->
                <xsl:call-template name="DoAbstractPerPaperLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="abstractLayout" select="$frontMatterLayout/abstractLayout[number($iLayoutPosition)]"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
                <!-- there are many abstractLayouts and there are more abstract elements than abstractLayout elements; use the last layout -->
                <xsl:call-template name="DoAbstractPerPaperLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="abstractLayout" select="$frontMatterLayout/abstractLayout[number(last())]"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        preface (book)
    -->
    <xsl:template match="preface" mode="book">
        <xsl:param name="iLayoutPosition" select="0"/>
        <xsl:variable name="iPos" select="count(preceding-sibling::preface) + 1"/>
        <xsl:variable name="fLayoutIsLastOfMany">
            <xsl:choose>
                <xsl:when test="$iLayoutPosition=0">
                    <xsl:text>N</xsl:text>
                </xsl:when>
                <xsl:when test="count($frontMatterLayoutInfo/prefaceLayout[number($iLayoutPosition)]/following-sibling::prefaceLayout)=0">
                    <xsl:text>Y</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>N</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$iLayoutPosition = 0">
                <!-- there's one and only one prefaceLayout; use it -->
                <xsl:call-template name="DoPrefacePerBookLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="prefaceLayout" select="$frontMatterLayoutInfo/prefaceLayout"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$iLayoutPosition = $iPos">
                <!-- there are many prefaceLayouts; use the one that matches in position -->
                <xsl:call-template name="DoPrefacePerBookLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="prefaceLayout" select="$frontMatterLayoutInfo/prefaceLayout[number($iLayoutPosition)]"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
                <!-- there are many prefaceLayouts and there are more preface elements than prefaceLayout elements; use the last layout -->
                <xsl:call-template name="DoPrefacePerBookLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="prefaceLayout" select="$frontMatterLayoutInfo/prefaceLayout[number(last())]"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        preface (paper)
    -->
    <xsl:template match="preface" mode="paper">
        <xsl:param name="iLayoutPosition" select="0"/>
        <xsl:variable name="iPos" select="count(preceding-sibling::preface) + 1"/>
        <xsl:variable name="fLayoutIsLastOfMany">
            <xsl:choose>
                <xsl:when test="$iLayoutPosition=0">
                    <xsl:text>N</xsl:text>
                </xsl:when>
                <xsl:when test="count($frontMatterLayoutInfo/prefaceLayout[number($iLayoutPosition)]/following-sibling::prefaceLayout)=0">
                    <xsl:text>Y</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>N</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$iLayoutPosition = 0">
                <!-- there's one and only one prefaceLayout; use it -->
                <xsl:call-template name="DoPrefacePerPaperLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="prefaceLayout" select="$frontMatterLayoutInfo/prefaceLayout"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$iLayoutPosition = $iPos">
                <!-- there are many prefaceLayouts; use the one that matches in position -->
                <xsl:call-template name="DoPrefacePerPaperLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="prefaceLayout" select="$frontMatterLayoutInfo/prefaceLayout[number($iLayoutPosition)]"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
                <!-- there are many prefaceLayouts and there are more preface elements than prefaceLayout elements; use the last layout -->
                <xsl:call-template name="DoPrefacePerPaperLayout">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="prefaceLayout" select="$frontMatterLayoutInfo/prefaceLayout[number(last())]"/>
                    <xsl:with-param name="iLayoutPosition" select="$iLayoutPosition"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
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
        <xsl:apply-templates select="comment"/>
    </xsl:template>
    <!--
        thesis
    -->
    <xsl:template match="thesis">
        <xsl:call-template name="DoDissertationLayout">
            <xsl:with-param name="layout" select="$referencesLayoutInfo/thesisLayouts"/>
        </xsl:call-template>
        <xsl:apply-templates select="comment"/>
    </xsl:template>
    <!--
        doi
    -->
    <xsl:template match="doi">
        <xsl:call-template name="DoDoiLayout"/>
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
        <xsl:apply-templates select="comment"/>
    </xsl:template>
    <!--
        refAuthor
    -->
    <xsl:template match="refAuthor">
        <xsl:choose>
            <xsl:when test="$authorForm='full' or not(refAuthorInitials)">
                <xsl:choose>
                    <xsl:when test="$referencesLayoutInfo/refAuthorLayouts/refAuthorLastNameLayout and string-length(refAuthorName) &gt;0">
                        <xsl:apply-templates select="refAuthorName"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(@name)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="refAuthorInitials"/>
<!--                <xsl:value-of select="normalize-space(refAuthorInitials)"/>-->
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
        <xsl:if test="../../@showAuthorName!='no'">
            <xsl:if test="count($works[refDate=$date])>1">
                <xsl:apply-templates select="." mode="dateLetter">
                    <xsl:with-param name="date" select="$date"/>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--
        refTitle
    -->
    <xsl:template match="refTitle">
        <xsl:variable name="sTitle" select="normalize-space(.)"/>
        <xsl:if test="string-length($sTitle) &gt; 0">
            <xsl:choose>
                <xsl:when test="$titleForm='uppercase' or not(following-sibling::refTitleLowerCase)">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="following-sibling::refTitleLowerCase"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--
        Elements to ignore
    -->
    <xsl:template match="literalLabelLayout"/>
    <!--  
        DetermineIfDateAccessedMatchesLayoutPattern
    -->
    <xsl:template name="DetermineIfDateAccessedMatchesLayoutPattern">
        <xsl:param name="sOptionsPresent"/>
        <xsl:param name="dateAccessedPos"/>
        <xsl:choose>
            <xsl:when test="substring($sOptionsPresent, $dateAccessedPos, 1)='y' and dateAccessedItem">x</xsl:when>
            <xsl:when test="substring($sOptionsPresent, $dateAccessedPos, 1)='y' and urlDateAccessedLayoutsRef and $urlDateAccessedLayouts/urlDateAccessedLayout/dateAccessedItem">x</xsl:when>
            <xsl:when test="substring($sOptionsPresent, $dateAccessedPos, 1)='n' and not(dateAccessedItem)">
                <xsl:choose>
                    <xsl:when test="not(urlDateAccessedLayoutsRef)">x</xsl:when>
                    <xsl:when test="urlDateAccessedLayoutsRef and $urlDateAccessedLayouts/urlDateAccessedLayout/missingItem">x</xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        DetermineIfDoiMatchesLayoutPattern
    -->
    <xsl:template name="DetermineIfDoiMatchesLayoutPattern">
        <xsl:param name="sOptionsPresent"/>
        <xsl:param name="doiPos"/>
        <xsl:choose>
            <xsl:when test="substring($sOptionsPresent, $doiPos, 1)='y' and doiItem">x</xsl:when>
            <xsl:when test="substring($sOptionsPresent, $doiPos, 1)='y' and urlDateAccessedLayoutsRef and $urlDateAccessedLayouts/urlDateAccessedLayout/doiItem">x</xsl:when>
            <xsl:when test="substring($sOptionsPresent, $doiPos, 1)='n' and not(doiItem)">
                <xsl:choose>
                    <xsl:when test="not(urlDateAccessedLayoutsRef)">x</xsl:when>
                    <xsl:when test="urlDateAccessedLayoutsRef and $urlDateAccessedLayouts/urlDateAccessedLayout/missingItem">x</xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        DetermineIfLocationPublisherMatchesLayoutPattern
    -->
    <xsl:template name="DetermineIfLocationPublisherMatchesLayoutPattern">
        <xsl:param name="sOptionsPresent"/>
        <xsl:param name="locationPublisherPos"/>
        <xsl:choose>
            <xsl:when test="substring($sOptionsPresent, $locationPublisherPos, 1)='y' and locationPublisherLayoutsRef">x</xsl:when>
            <xsl:when test="substring($sOptionsPresent, $locationPublisherPos, 1)='n' and not(locationPublisherLayoutsRef)">x</xsl:when>
            <xsl:when test="substring($sOptionsPresent, $locationPublisherPos, 1)='n' and $locationPublisherLayouts/locationPublisherLayout/missingItem">x</xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        DetermineIfUrlMatchesLayoutPattern
    -->
    <xsl:template name="DetermineIfUrlMatchesLayoutPattern">
        <xsl:param name="sOptionsPresent"/>
        <xsl:param name="urlPos"/>
        <xsl:choose>
            <xsl:when test="substring($sOptionsPresent, $urlPos, 1)='y' and urlItem">x</xsl:when>
            <xsl:when test="substring($sOptionsPresent, $urlPos, 1)='y' and urlDateAccessedLayoutsRef and $urlDateAccessedLayouts/urlDateAccessedLayout/urlItem">x</xsl:when>
            <xsl:when test="substring($sOptionsPresent, $urlPos, 1)='n' and not(urlItem)">
                <xsl:choose>
                    <xsl:when test="not(urlDateAccessedLayoutsRef)">x</xsl:when>
                    <xsl:when test="urlDateAccessedLayoutsRef and $urlDateAccessedLayouts/urlDateAccessedLayout/missingItem">x</xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        DoAppendixRef
    -->
    <xsl:template name="DoAppendixRef">
        <xsl:variable name="appendix" select="id(@app)"/>
        <xsl:choose>
            <xsl:when test="@showTitle='short'">
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/sectionRefTitleLayout"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="$appendix/shortTitle and string-length($appendix/shortTitle) &gt; 0">
                        <xsl:apply-templates select="$appendix/shortTitle/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$appendix/secTitle/child::node()[name()!='endnote']"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/sectionRefTitleLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@showTitle='full'">
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/sectionRefTitleLayout"/>
                </xsl:call-template>
                <xsl:apply-templates select="$appendix/secTitle/child::node()[name()!='endnote']"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/sectionRefTitleLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$appendix" mode="numberAppendix"/>
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
                            <xsl:when test="name(.)='refTitleItem' and string-length($work/refTitle) &gt; 0">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                                <xsl:if test="$work/../@showAuthorName='no'">
                                    <xsl:call-template name="DoDateLayout">
                                        <xsl:with-param name="refDateItem" select="ancestor::referencesLayout/refAuthorLayouts/refAuthorLayout[position()=last()]/refDateItem"/>
                                        <xsl:with-param name="work" select="$work"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='jTitleItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$article/jTitle"/>
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
                            <xsl:when test="name(.)='reprintInfoItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$article/reprintInfo"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem' and name(following-sibling::*[2])='doiItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$article"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[2])='urlItem' and name(preceding-sibling::*[1])='dateAccessedItem' and name(.)='doi'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$article"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[1])='urlItem' and name(.)='dateAccessedItem'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="HandleUrlLayout">
                                    <xsl:with-param name="kindOfWork" select="$article"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="HandleDateAccessedLayout">
                                    <xsl:with-param name="kindOfWork" select="$article"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="HandleDoiLayout">
                                    <xsl:with-param name="kindOfWork" select="$article"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationPublisherLayoutsRef'">
                                <xsl:call-template name="DoLocationPublisherLayout">
                                    <xsl:with-param name="reference" select="$article"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlDateAccessedLayoutsRef'">
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$article"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$article/.."/>
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
        DoAuthorContactInfoPerLayout
    -->
    <xsl:template name="DoAuthorContactInfoPerLayout">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="authorInfo"/>
        <xsl:for-each select="$layoutInfo/*">
            <xsl:variable name="currentLayoutInfo" select="."/>
            <xsl:choose>
                <xsl:when test="name()='contactNameLayout'">
                    <xsl:for-each select="$authorInfo/contactName">
                        <xsl:call-template name="DoContactInfo">
                            <xsl:with-param name="currentLayoutInfo" select="$currentLayoutInfo"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="name()='contactAddressLayout'">
                    <xsl:for-each select="$authorInfo/contactAddress">
                        <xsl:call-template name="DoContactInfo">
                            <xsl:with-param name="currentLayoutInfo" select="$currentLayoutInfo"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="name()='contactAffiliationLayout'">
                    <xsl:for-each select="$authorInfo/contactAffiliation">
                        <xsl:call-template name="DoContactInfo">
                            <xsl:with-param name="currentLayoutInfo" select="$currentLayoutInfo"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="name()='contactEmailLayout'">
                    <xsl:for-each select="$authorInfo/contactEmail">
                        <xsl:call-template name="DoContactInfo">
                            <xsl:with-param name="currentLayoutInfo" select="$currentLayoutInfo"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="name()='contactElectronicLayout'">
                    <xsl:for-each select="$authorInfo/contactElectronic[@show='yes']">
                        <xsl:call-template name="DoContactInfo">
                            <xsl:with-param name="currentLayoutInfo" select="$currentLayoutInfo"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="name()='contactPhoneLayout'">
                    <xsl:for-each select="$authorInfo/contactPhone">
                        <xsl:call-template name="DoContactInfo">
                            <xsl:with-param name="currentLayoutInfo" select="$currentLayoutInfo"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoAuthorRelatedElementsPerSingleSetOfLayouts
    -->
    <xsl:template name="DoAuthorRelatedElementsPerSingleSetOfLayouts">
        <xsl:param name="authors"/>
        <xsl:param name="currentAuthors"/>
        <xsl:param name="thisAffiliationLayout" select="following-sibling::affiliationLayout"/>
        <xsl:param name="thisEmailAddressLayout" select="following-sibling::emailAddressLayout"/>
        <xsl:variable name="thisAuthorLayout" select="."/>
        <xsl:for-each select="$authors">
            <xsl:variable name="thisAuthor" select="."/>
            <xsl:if test="$currentAuthors[.=$thisAuthor]">
                <!-- format the author -->
                <!--            <xsl:for-each select="$thisAuthorLayout">-->
                <xsl:apply-templates select="$thisAuthor">
                    <xsl:with-param name="authorLayoutToUse" select="$thisAuthorLayout"/>
                </xsl:apply-templates>
                <!--            </xsl:for-each>-->
                <!-- figure out how to format any affiliations or emailAddress of this author -->
                <xsl:variable name="iThisAuthorPos" select="position()"/>
                <xsl:variable name="myAffiliations" select="following-sibling::*[name()='affiliation' and count(preceding-sibling::author) = $iThisAuthorPos]"/>
                <xsl:variable name="myEmailAddress" select="following-sibling::*[name()='emailAddress' and count(preceding-sibling::author) = $iThisAuthorPos]"/>
                <xsl:choose>
                    <xsl:when test="$thisAuthorLayout/following-sibling::*[1][name()='affiliationLayout']">
                        <!-- format any affiliations first -->
                        <!--                        <xsl:for-each select="$thisAffiliationLayout">-->
                        <xsl:apply-templates select="$myAffiliations">
                            <xsl:with-param name="affiliationLayoutToUse" select="$thisAffiliationLayout"/>
                        </xsl:apply-templates>
                        <!--                        </xsl:for-each>-->
                        <!--                        <xsl:for-each select="$thisEmailAddressLayout">-->
                        <xsl:apply-templates select="$myEmailAddress">
                            <xsl:with-param name="emailAddressLayoutToUse" select="$thisEmailAddressLayout"/>
                        </xsl:apply-templates>
                        <!--                        </xsl:for-each>-->
                    </xsl:when>
                    <xsl:when test="$thisAuthorLayout/following-sibling::*[1][name()='emailAddressLayout']">
                        <!-- format any email addresses first -->
                        <!--                        <xsl:for-each select="$thisEmailAddressLayout">-->
                        <xsl:apply-templates select="$myEmailAddress">
                            <xsl:with-param name="emailAddressLayoutToUse" select="$thisEmailAddressLayout"/>
                        </xsl:apply-templates>
                        <!--                        </xsl:for-each>-->
                        <!--                        <xsl:for-each select="$thisAffiliationLayout">-->
                        <xsl:apply-templates select="$myAffiliations">
                            <xsl:with-param name="affiliationLayoutToUse" select="$thisAffiliationLayout"/>
                        </xsl:apply-templates>
                        <!--                        </xsl:for-each>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- nothing to do -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoBookEndnotesLabelingContent
    -->
    <xsl:template name="DoBookEndnotesLabelingContent">
        <xsl:param name="chapterOrAppendixUnit"/>
        <xsl:variable name="endnotes" select="//endnotes"/>
        <xsl:choose>
            <xsl:when test="name($chapterOrAppendixUnit)='chapter' or name($chapterOrAppendixUnit)='chapterInCollection' or name($chapterOrAppendixUnit)='chapterBeforePart'">
                <xsl:call-template name="DoEndnoteSectionLabel">
                    <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout"/>
                    <!--                    <xsl:with-param name="sDefault" select="'Chapter'"/>-->
                    <xsl:with-param name="sDefault">
                        <xsl:variable name="choices" select="$endnotes/chapterLabelContentChoices"/>
                        <xsl:choose>
                            <xsl:when test="$choices">
                                <xsl:for-each select="$endnotes/chapterLabelContentChoices">
                                    <xsl:call-template name="OutputLabel">
                                        <xsl:with-param name="sDefault" select="'Chapter'"/>
                                        <xsl:with-param name="pLabel" select="@label"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="OutputLabel">
                                    <xsl:with-param name="sDefault" select="'Chapter'"/>
                                    <xsl:with-param name="pLabel" select="@label"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name($chapterOrAppendixUnit)='appendix'">
                <xsl:call-template name="DoEndnoteSectionLabel">
                    <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                    <!--                    <xsl:with-param name="sDefault" select="'Appendix'"/>-->
                    <xsl:with-param name="sDefault">
                        <xsl:variable name="choices" select="$endnotes/appendixLabelContentChoices"/>
                        <xsl:choose>
                            <xsl:when test="$choices">
                                <xsl:for-each select="$endnotes/appendixLabelContentChoices">
                                    <xsl:call-template name="OutputLabel">
                                        <xsl:with-param name="sDefault" select="'Appendix'"/>
                                        <xsl:with-param name="pLabel" select="@label"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="OutputLabel">
                                    <xsl:with-param name="sDefault" select="'Appendix'"/>
                                    <xsl:with-param name="pLabel" select="@label"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name($chapterOrAppendixUnit)='part'">
                <xsl:call-template name="DoEndnoteSectionLabel">
                    <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/partLayout/partTitleLayout"/>
                    <!--                    <xsl:with-param name="sDefault" select="'Appendix'"/>-->
                    <xsl:with-param name="sDefault">
                        <xsl:for-each select="$endnotes/partLabelContentChoices">
                            <xsl:call-template name="OutputLabel">
                                <xsl:with-param name="sDefault" select="'Part'"/>
                                <xsl:with-param name="pLabel" select="@label"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name($chapterOrAppendixUnit)='glossary'">
                <xsl:call-template name="DoEndnoteSectionLabel">
                    <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/glossaryLayout/glossaryTitleLayout"/>
                    <xsl:with-param name="sDefault">
                        <xsl:for-each select="$chapterOrAppendixUnit">
                            <xsl:call-template name="OutputGlossaryLabel"/>
                        </xsl:for-each>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name($chapterOrAppendixUnit)='acknowledgements'">
                <xsl:choose>
                    <xsl:when test="ancestor::frontMatter">
                        <xsl:call-template name="DoEndnoteSectionLabel">
                            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/acknowledgementsLayout/acknowledgementsTitleLayout"/>
                            <!--                            <xsl:with-param name="sDefault" select="'Acknowledgements'"/>-->
                            <xsl:with-param name="sDefault">
                                <xsl:for-each select="$chapterOrAppendixUnit">
                                    <xsl:call-template name="OutputAcknowledgementsLabel"/>
                                </xsl:for-each>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="DoEndnoteSectionLabel">
                            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/acknowledgementsLayout/acknowledgementsTitleLayout"/>
                            <!--                            <xsl:with-param name="sDefault" select="'Acknowledgements'"/>-->
                            <xsl:with-param name="sDefault">
                                <xsl:for-each select="$chapterOrAppendixUnit">
                                    <xsl:call-template name="OutputAcknowledgementsLabel"/>
                                </xsl:for-each>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="name($chapterOrAppendixUnit)='preface'">
                <xsl:call-template name="DoEndnoteSectionLabel">
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/prefaceLayout/prefaceTitleLayout"/>
                    <xsl:with-param name="sDefault">
                        <xsl:for-each select="$chapterOrAppendixUnit">
                            <xsl:call-template name="OutputPrefaceLabel">
                                <xsl:with-param name="iPos" select="count($chapterOrAppendixUnit/preceding-sibling::preface)+1"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name($chapterOrAppendixUnit)='abstract'">
                <xsl:call-template name="DoEndnoteSectionLabel">
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/abstractLayout/abstractTitleLayout"/>
                    <!--                    <xsl:with-param name="sDefault" select="'Abstract'"/>-->
                    <xsl:with-param name="sDefault">
                        <xsl:for-each select="$chapterOrAppendixUnit">
                            <xsl:call-template name="OutputAbstractLabel">
                                <xsl:with-param name="iPos" select="count($chapterOrAppendixUnit/preceding-sibling::abstract)+1"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoBookEndnoteSectionLabel
    -->
    <xsl:template name="DoBookEndnoteSectionLabel">
        <xsl:param name="originalContext"/>
        <xsl:choose>
            <xsl:when test="$originalContext">
                <xsl:for-each select="$originalContext">
                    <xsl:variable name="chapterOrAppendixUnit"
                        select="ancestor::chapter | ancestor::chapterBeforePart | ancestor::appendix | ancestor::glossary | ancestor::acknowledgements | ancestor::preface | ancestor::abstract | ancestor::chapterInCollection | ancestor::part"/>
                    <xsl:call-template name="DoBookEndnotesLabeling">
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                        <xsl:with-param name="chapterOrAppendixUnit" select="$chapterOrAppendixUnit"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="thisEndnote" select="."/>
                <xsl:variable name="chapterOrAppendixUnit"
                    select="ancestor::chapter | ancestor::chapterBeforePart | ancestor::appendix | ancestor::glossary | ancestor::acknowledgements | ancestor::preface | ancestor::abstract | ancestor::chapterInCollection | ancestor::part[not($thisEndnote[ancestor::chapter])]"/>
                <xsl:choose>
                    <xsl:when test="starts-with(name($chapterOrAppendixUnit),'chapter') and /xlingpaper/styledPaper/publisherStyleSheet[1]/bodyLayout/chapterLayout/@resetEndnoteNumbering='no'">
                        <!-- do nothing -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="DoBookEndnotesLabeling">
                            <xsl:with-param name="originalContext" select="$originalContext"/>
                            <xsl:with-param name="chapterOrAppendixUnit" select="$chapterOrAppendixUnit"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
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
                            <xsl:when test="name(.)='refTitleItem' and string-length($work/refTitle) &gt; 0">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                                <xsl:if test="$work/../@showAuthorName='no'">
                                    <xsl:call-template name="DoDateLayout">
                                        <xsl:with-param name="refDateItem" select="ancestor::referencesLayout/refAuthorLayouts/refAuthorLayout[position()=last()]/refDateItem"/>
                                        <xsl:with-param name="work" select="$work"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='translatedByItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$book/translatedBy"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='editionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$book/edition"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='seriesItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$book/series"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='seriesEdItem'">
                                <xsl:variable name="item" select="$book/seriesEd"/>
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$book/seriesEd"/>
                                </xsl:call-template>
                                <xsl:if test="@appendEdAbbreviation != 'no'">
                                    <xsl:call-template name="DoEditorAbbreviation">
                                        <xsl:with-param name="item" select="$item"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='bVolItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($book/bVol)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='multivolumeWorkItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$book/multivolumeWork"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='bookTotalPagesItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($book/bookTotalPages)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='reprintInfoItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$book/reprintInfo"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem' and name(following-sibling::*[2])='doiItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[2])='urlItem' and name(preceding-sibling::*[1])='dateAccessedItem' and name(.)='doi'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[1])='urlItem' and name(.)='dateAccessedItem'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="HandleUrlLayout">
                                    <xsl:with-param name="kindOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="HandleDateAccessedLayout">
                                    <xsl:with-param name="kindOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="HandleDoiLayout">
                                    <xsl:with-param name="kindOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationPublisherLayoutsRef'">
                                <xsl:call-template name="DoLocationPublisherLayout">
                                    <xsl:with-param name="reference" select="$book"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlDateAccessedLayoutsRef'">
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$book"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$book/.."/>
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
                                        <xsl:with-param name="item" select="$work/authorRole"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="name(.)='collTitleItem' and string-length($work/refTitle) &gt; 0">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='editionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$book/edition"/>
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
                                    <xsl:with-param name="item" select="$item"/>
                                </xsl:call-template>
                                <xsl:if test="@appendEdAbbreviation != 'no'">
                                    <xsl:call-template name="DoEditorAbbreviation">
                                        <xsl:with-param name="item" select="$item"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='seriesItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$book/series"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='multivolumeWorkItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$book/multivolumeWork"/>
                                </xsl:call-template>
                            </xsl:when>
                            <!--        in a series??                    <xsl:when test="name(.)='bVolItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($collection/bVol)"/>
                                </xsl:call-template>
                            </xsl:when>
-->
                            <xsl:when test="name(.)='reprintInfoItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$book/reprintInfo"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem' and name(following-sibling::*[2])='doiItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[2])='urlItem' and name(preceding-sibling::*[1])='dateAccessedItem' and name(.)='doi'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[1])='urlItem' and name(.)='dateAccessedItem'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="HandleUrlLayout">
                                    <xsl:with-param name="kindOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="HandleDateAccessedLayout">
                                    <xsl:with-param name="kindOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="HandleDoiLayout">
                                    <xsl:with-param name="kindOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationPublisherLayoutsRef'">
                                <xsl:call-template name="DoLocationPublisherLayout">
                                    <xsl:with-param name="reference" select="$book"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlDateAccessedLayoutsRef'">
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$book"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$book/.."/>
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
                                        <xsl:with-param name="item" select="$work/authorRole"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="name(.)='procTitleItem' and string-length($work/refTitle) &gt; 0">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
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
                            <xsl:when test="name(.)='reprintInfoItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$book/reprintInfo"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem' and name(following-sibling::*[2])='doiItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[2])='urlItem' and name(preceding-sibling::*[1])='dateAccessedItem' and name(.)='doi'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[1])='urlItem' and name(.)='dateAccessedItem'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="HandleUrlLayout">
                                    <xsl:with-param name="kindOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="HandleDateAccessedLayout">
                                    <xsl:with-param name="kindOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="HandleDoiLayout">
                                    <xsl:with-param name="kindOfWork" select="$book"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationPublisherLayoutsRef'">
                                <xsl:call-template name="DoLocationPublisherLayout">
                                    <xsl:with-param name="reference" select="$book"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlDateAccessedLayoutsRef'">
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$book"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$book/.."/>
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
                            <xsl:when test="name(.)='refTitleItem' and string-length($work/refTitle) &gt; 0">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                                <xsl:if test="$work/../@showAuthorName='no'">
                                    <xsl:call-template name="DoDateLayout">
                                        <xsl:with-param name="refDateItem" select="ancestor::referencesLayout/refAuthorLayouts/refAuthorLayout[position()=last()]/refDateItem"/>
                                        <xsl:with-param name="work" select="$work"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='collCitationItem'">
                                <xsl:call-template name="OutputCitation">
                                    <xsl:with-param name="item" select="$collection/collCitation"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='authorRoleItem'">
                                <xsl:if test="$bHasCollCitation='Y' and $bUseCitationAsLink='Y'">
                                    <xsl:call-template name="OutputReferenceItem">
                                        <xsl:with-param name="item" select="key('RefWorkID',$collection/collCitation/@refToBook)/authorRole"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='collEdItem'">
                                <xsl:variable name="item" select="$collection/collEd"/>
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$item"/>
                                </xsl:call-template>
                                <xsl:if test="@appendEdAbbreviation != 'no'">
                                    <xsl:call-template name="DoEditorAbbreviation">
                                        <xsl:with-param name="item" select="$item"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='collTitleItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$collection/collTitle"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='editionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$collection/edition"/>
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
                                    <xsl:with-param name="item" select="$item"/>
                                </xsl:call-template>
                                <xsl:if test="@appendEdAbbreviation != 'no'">
                                    <xsl:call-template name="DoEditorAbbreviation">
                                        <xsl:with-param name="item" select="$item"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='seriesItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$collection/series"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='bVolItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($collection/bVol)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='multivolumeWorkItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$collection/multivolumeWork"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='reprintInfoItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$collection/reprintInfo"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem' and name(following-sibling::*[2])='doiItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$collection"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[2])='urlItem' and name(preceding-sibling::*[1])='dateAccessedItem' and name(.)='doi'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$collection"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[1])='urlItem' and name(.)='dateAccessedItem'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="HandleUrlLayout">
                                    <xsl:with-param name="kindOfWork" select="$collection"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="HandleDateAccessedLayout">
                                    <xsl:with-param name="kindOfWork" select="$collection"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="HandleDoiLayout">
                                    <xsl:with-param name="kindOfWork" select="$collection"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationPublisherLayoutsRef'">
                                <xsl:call-template name="DoLocationPublisherLayout">
                                    <xsl:with-param name="reference" select="$collection"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlDateAccessedLayoutsRef'">
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$collection"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$collection/.."/>
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
                            <xsl:when test="name(.)='refTitleItem' and string-length($work/refTitle) &gt; 0">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                                <xsl:if test="$work/../@showAuthorName='no'">
                                    <xsl:call-template name="DoDateLayout">
                                        <xsl:with-param name="refDateItem" select="ancestor::referencesLayout/refAuthorLayouts/refAuthorLayout[position()=last()]/refDateItem"/>
                                        <xsl:with-param name="work" select="$work"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='dissertationLabelItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item">
                                        <xsl:choose>
                                            <xsl:when test="string-length(normalize-space(@label)) &gt; 0">
                                                <xsl:value-of select="@label"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="OutputLabel">
                                                    <xsl:with-param name="sDefault" select="$sPhDDissertationDefaultLabel"/>
                                                    <xsl:with-param name="pLabel">
                                                        <xsl:choose>
                                                            <xsl:when test="string-length(normalize-space($dissertation/@labelDissertation)) &gt; 0">
                                                                <xsl:value-of select="$dissertation/@labelDissertation"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="//references/@labelDissertation"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='thesisLabelItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item">
                                        <xsl:choose>
                                            <xsl:when test="string-length(normalize-space(@label)) &gt; 0">
                                                <xsl:value-of select="@label"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="OutputLabel">
                                                    <xsl:with-param name="sDefault" select="$sMAThesisDefaultLabel"/>
                                                    <xsl:with-param name="pLabel">
                                                        <xsl:choose>
                                                            <xsl:when test="string-length(normalize-space($dissertation/@labelThesis)) &gt; 0">
                                                                <xsl:value-of select="$dissertation/@labelThesis"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="//references/@labelThesis"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='institutionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$dissertation/institution"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$dissertation/location"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='publishedLayoutRef'">
                                <xsl:call-template name="DoPublishedLayout">
                                    <xsl:with-param name="reference" select="$dissertation/published"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='reprintInfoItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$dissertation/reprintInfo"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem' and name(following-sibling::*[2])='doiItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$dissertation"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[2])='urlItem' and name(preceding-sibling::*[1])='dateAccessedItem' and name(.)='doi'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$dissertation"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[1])='urlItem' and name(.)='dateAccessedItem'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="HandleUrlLayout">
                                    <xsl:with-param name="kindOfWork" select="$dissertation"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="HandleDateAccessedLayout">
                                    <xsl:with-param name="kindOfWork" select="$dissertation"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="HandleDoiLayout">
                                    <xsl:with-param name="kindOfWork" select="$dissertation"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlDateAccessedLayoutsRef'">
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$dissertation"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$dissertation/.."/>
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
                <xsl:when test="string-length(@edTextbefore) &gt; 0">
                    <xsl:value-of select="@edTextbefore"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>, </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$item/@plural='no'">
                    <xsl:choose>
                        <xsl:when test="string-length(@edTextSingular) &gt; 0">
                            <xsl:value-of select="@edTextSingular"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>ed</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="string-length(@edTextPlural) &gt; 0">
                            <xsl:value-of select="@edTextPlural"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>eds</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="string-length(@edTextafter) &gt; 0">
                    <xsl:value-of select="@edTextafter"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>. </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        DoFigureRef
    -->
    <xsl:template name="DoFigureRef">
        <xsl:variable name="figure" select="id(@figure)"/>
        <xsl:choose>
            <xsl:when test="@showCaption='short'">
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/figureRefCaptionLayout"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="$figure/shortCaption and string-length($figure/shortCaption) &gt; 0">
                        <xsl:apply-templates select="$figure/shortCaption/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$figure/caption/child::node()[name()!='endnote']"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/figureRefCaptionLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@showCaption='full'">
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/figureRefCaptionLayout"/>
                </xsl:call-template>
                <xsl:apply-templates select="$figure/caption/child::node()[name()!='endnote']"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/figureRefCaptionLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!--                <xsl:apply-templates select="$figure" mode="figure"/>-->
                <xsl:call-template name="GetFigureNumber">
                    <xsl:with-param name="figure" select="$figure"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoFormatLayoutInfoTextAfter
    -->
    <xsl:template name="DoFormatLayoutInfoTextAfter">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="sPrecedingText"/>
        <xsl:variable name="sAfter" select="$layoutInfo/@textafter"/>
        <xsl:if test="string-length($sAfter) &gt; 0">
            <xsl:choose>
                <xsl:when test="starts-with($sAfter,'.')">
                    <xsl:variable name="sLastChar" select="substring($sPrecedingText,string-length($sPrecedingText),string-length($sPrecedingText))"/>
                    <xsl:choose>
                        <xsl:when test="$sLastChar='.' or $sLastChar='?' or $sLastChar='!'">
                            <xsl:value-of select="substring($sAfter, 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$sAfter"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$sAfter"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        DoInterlinearRefCitationShowTitleOnly
    -->
    <xsl:template name="DoInterlinearRefCitationShowTitleOnly">
        <xsl:variable name="interlinear" select="key('InterlinearReferenceID',@textref)"/>
        <xsl:choose>
            <xsl:when test="@showTitleOnly='short'">
                <!-- only one of these will work -->
                <xsl:apply-templates select="$interlinear/textInfo/shortTitle/child::node()[name()!='endnote']"/>
                <xsl:apply-templates select="$interlinear/../textInfo/shortTitle/child::node()[name()!='endnote']"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- only one of these will work -->
                <xsl:apply-templates select="$interlinear/textInfo/textTitle/child::node()[name()!='endnote']"/>
                <xsl:apply-templates select="$interlinear/../textInfo/textTitle/child::node()[name()!='endnote']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      DoISO639-3Codes
   -->
    <xsl:template name="DoISO639-3Codes">
        <xsl:param name="work"/>
        <xsl:choose>
            <xsl:when test="$iso639-3codeItem/@sort='no'">
                <xsl:for-each select="$work/iso639-3code | $work/descendant::iso639-3code">
                    <xsl:call-template name="OutputISO639-3Code"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$work/iso639-3code | $work/descendant::iso639-3code">
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
                                    <xsl:with-param name="item" select="$reference/location"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='publisherItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$reference/publisher"/>
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
                            <xsl:with-param name="item" select="$reference/location"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="not($reference/location) and $reference/publisher">
                <xsl:for-each select="$referencesLayoutInfo/locationPublisherLayouts/*[not(locationItem) and publisherItem]">
                    <xsl:for-each select="*">
                        <xsl:call-template name="OutputReferenceItem">
                            <xsl:with-param name="item" select="$reference/publisher"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoEndnoteSectionLabel
    -->
    <xsl:template name="DoEndnoteSectionLabel">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="sDefault"/>
        <xsl:variable name="sTextBefore" select="normalize-space($layoutInfo/@textbefore)"/>
        <xsl:choose>
            <xsl:when test="string-length($sTextBefore) &gt; 0">
                <xsl:value-of select="$sTextBefore"/>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($lingPaper/@chapterlabel)) &gt; 0">
                <xsl:value-of select="$lingPaper/@chapterlabel"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sDefault"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoExampleRefContent
    -->
    <xsl:template name="DoExampleRefContent">
        <xsl:if test="$contentLayoutInfo/exampleLayout/@referencesUseParens!='no'">
            <xsl:if test="not(@paren) or @paren='both' or @paren='initial'">(</xsl:if>
        </xsl:if>
        <xsl:if test="@equal='yes'">=</xsl:if>
        <xsl:choose>
            <xsl:when test="@letter and name(id(@letter))!='example'">
                <xsl:if test="not(@letterOnly='yes')">
                    <xsl:call-template name="GetExampleNumber">
                        <xsl:with-param name="example" select="id(@letter)"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:apply-templates select="id(@letter)" mode="letter"/>
            </xsl:when>
            <xsl:when test="@num">
                <xsl:call-template name="GetExampleNumber">
                    <xsl:with-param name="example" select="id(@num)"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="@punct">
            <xsl:value-of select="@punct"/>
        </xsl:if>
        <xsl:if test="$contentLayoutInfo/exampleLayout/@referencesUseParens!='no'">
            <xsl:if test="not(@paren) or @paren='both' or @paren='final'">)</xsl:if>
        </xsl:if>
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
                            <xsl:when test="name(.)='refTitleItem' and string-length($work/refTitle) &gt; 0">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                                <xsl:if test="$work/../@showAuthorName='no'">
                                    <xsl:call-template name="DoDateLayout">
                                        <xsl:with-param name="refDateItem" select="ancestor::referencesLayout/refAuthorLayouts/refAuthorLayout[position()=last()]/refDateItem"/>
                                        <xsl:with-param name="work" select="$work"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='institutionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$fieldNotes/institution"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$fieldNotes/location"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem' and name(following-sibling::*[2])='doiItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$fieldNotes"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[2])='urlItem' and name(preceding-sibling::*[1])='dateAccessedItem' and name(.)='doi'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$fieldNotes"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[1])='urlItem' and name(.)='dateAccessedItem'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="HandleUrlLayout">
                                    <xsl:with-param name="kindOfWork" select="$fieldNotes"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="HandleDateAccessedLayout">
                                    <xsl:with-param name="kindOfWork" select="$fieldNotes"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="HandleDoiLayout">
                                    <xsl:with-param name="kindOfWork" select="$fieldNotes"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlDateAccessedLayoutsRef'">
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$fieldNotes"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$fieldNotes/.."/>
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
                            <xsl:when test="name(.)='refTitleItem' and string-length($work/refTitle) &gt; 0">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                                <xsl:if test="$work/../@showAuthorName='no'">
                                    <xsl:call-template name="DoDateLayout">
                                        <xsl:with-param name="refDateItem" select="ancestor::referencesLayout/refAuthorLayouts/refAuthorLayout[position()=last()]/refDateItem"/>
                                        <xsl:with-param name="work" select="$work"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='institutionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$ms/institution"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$ms/location"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='emptyItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($ms/empty)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem' and name(following-sibling::*[2])='doiItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$ms"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[2])='urlItem' and name(preceding-sibling::*[1])='dateAccessedItem' and name(.)='doi'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$ms"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[1])='urlItem' and name(.)='dateAccessedItem'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="HandleUrlLayout">
                                    <xsl:with-param name="kindOfWork" select="$ms"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="HandleDateAccessedLayout">
                                    <xsl:with-param name="kindOfWork" select="$ms"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="HandleDoiLayout">
                                    <xsl:with-param name="kindOfWork" select="$ms"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlDateAccessedLayoutsRef'">
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$ms"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$ms/.."/>
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
                            <xsl:when test="name(.)='refTitleItem' and string-length($work/refTitle) &gt; 0">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                                <xsl:if test="$work/../@showAuthorName='no'">
                                    <xsl:call-template name="DoDateLayout">
                                        <xsl:with-param name="refDateItem" select="ancestor::referencesLayout/refAuthorLayouts/refAuthorLayout[position()=last()]/refDateItem"/>
                                        <xsl:with-param name="work" select="$work"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='conferenceItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($paper/conference)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$paper/location"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem' and name(following-sibling::*[2])='doiItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$paper"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[2])='urlItem' and name(preceding-sibling::*[1])='dateAccessedItem' and name(.)='doi'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$paper"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[1])='urlItem' and name(.)='dateAccessedItem'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="HandleUrlLayout">
                                    <xsl:with-param name="kindOfWork" select="$paper"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="HandleDateAccessedLayout">
                                    <xsl:with-param name="kindOfWork" select="$paper"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="HandleDoiLayout">
                                    <xsl:with-param name="kindOfWork" select="$paper"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlDateAccessedLayoutsRef'">
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$paper"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$paper/.."/>
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
                            <xsl:when test="name(.)='refTitleItem' and string-length($work/refTitle) &gt; 0">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                                <xsl:if test="$work/../@showAuthorName='no'">
                                    <xsl:call-template name="DoDateLayout">
                                        <xsl:with-param name="refDateItem" select="ancestor::referencesLayout/refAuthorLayouts/refAuthorLayout[position()=last()]/refDateItem"/>
                                        <xsl:with-param name="work" select="$work"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='procCitationItem'">
                                <xsl:call-template name="OutputCitation">
                                    <xsl:with-param name="item" select="$proceedings/procCitation"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='authorRoleItem'">
                                <xsl:if test="$bHasProcCitation='Y' and $bUseCitationAsLink='Y'">
                                    <xsl:call-template name="OutputReferenceItem">
                                        <xsl:with-param name="item" select="key('RefWorkID',$proceedings/procCitation/@refToBook)/authorRole"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='procEdItem'">
                                <xsl:variable name="item" select="$proceedings/procEd"/>
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$item"/>
                                </xsl:call-template>
                                <xsl:if test="@appendEdAbbreviation != 'no'">
                                    <xsl:call-template name="DoEditorAbbreviation">
                                        <xsl:with-param name="item" select="$item"/>
                                    </xsl:call-template>
                                </xsl:if>
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
                            <xsl:when test="name(.)='reprintInfoItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$proceedings/reprintInfo"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem' and name(following-sibling::*[2])='doiItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$proceedings"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[2])='urlItem' and name(preceding-sibling::*[1])='dateAccessedItem' and name(.)='doi'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$proceedings"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[1])='urlItem' and name(.)='dateAccessedItem'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="HandleUrlLayout">
                                    <xsl:with-param name="kindOfWork" select="$proceedings"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="HandleDateAccessedLayout">
                                    <xsl:with-param name="kindOfWork" select="$proceedings"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="HandleDoiLayout">
                                    <xsl:with-param name="kindOfWork" select="$proceedings"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationPublisherLayoutsRef'">
                                <xsl:call-template name="DoLocationPublisherLayout">
                                    <xsl:with-param name="reference" select="$proceedings"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlDateAccessedLayoutsRef'">
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$proceedings"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$proceedings/.."/>
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
                        <xsl:with-param name="item" select="$reference/location"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="name(.)='publisherItem'">
                    <xsl:call-template name="OutputReferenceItem">
                        <xsl:with-param name="item" select="$reference/publisher"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="name(.)='pubDateItem'">
                    <xsl:call-template name="OutputReferenceItem">
                        <xsl:with-param name="item" select="normalize-space($reference/pubDate)"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="name(.)='reprintInfoItem'">
                    <xsl:call-template name="OutputReferenceItemNode">
                        <xsl:with-param name="item" select="$reference/reprintInfo"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoSectionRef
    -->
    <xsl:template name="DoSectionRef">
        <xsl:param name="secRefToUse"/>
        <xsl:variable name="section" select="id($secRefToUse)"/>
        <xsl:choose>
            <xsl:when test="@showTitle='short'">
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/sectionRefTitleLayout"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="$section/shortTitle and string-length($section/shortTitle) &gt; 0">
                        <xsl:apply-templates select="$section/shortTitle/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:when test="$section/frontMatter/shortTitle and string-length($section/frontMatter/shortTitle) &gt; 0">
                        <xsl:apply-templates select="$section/frontMatter/shortTitle/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$section/secTitle/child::node()[name()!='endnote']"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/sectionRefTitleLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@showTitle='full'">
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/sectionRefTitleLayout"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="name($section)='chapterInCollection'">
                        <xsl:apply-templates select="$section/frontMatter/title/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$section/secTitle/child::node()[name()!='endnote']"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/sectionRefTitleLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="sNum">
                    <xsl:choose>
                        <xsl:when test="name($section)='part'">
                            <xsl:apply-templates select="$section" mode="numberPart"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$section" mode="number"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="$sNum"/>
                <xsl:if test="$contentLayoutInfo/sectionRefLayout/@AddPeriodAfterFinalDigit='yes'">
                    <xsl:text>.</xsl:text>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoTablenumberedRef
    -->
    <xsl:template name="DoTablenumberedRef">
        <xsl:variable name="table" select="id(@table)"/>
        <xsl:choose>
            <xsl:when test="@showCaption='short'">
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/tablenumberedRefCaptionLayout"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="$table/shortCaption and string-length($table/shortCaption) &gt; 0">
                        <xsl:apply-templates select="$table/shortCaption/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$table/table/caption/child::node()[name()!='endnote']"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/tablenumberedRefCaptionLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@showCaption='full'">
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/tablenumberedRefCaptionLayout"/>
                </xsl:call-template>
                <xsl:apply-templates select="$table/table/caption/child::node()[name()!='endnote']"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/tablenumberedRefCaptionLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!--                <xsl:apply-templates select="$table" mode="tablenumbered"/>-->
                <xsl:call-template name="GetTableNumberedNumber">
                    <xsl:with-param name="tablenumbered" select="$table"/>
                </xsl:call-template>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoUrlDateAccessedLayout
    -->
    <xsl:template name="DoUrlDateAccessedLayout">
        <xsl:param name="reference"/>
        <xsl:choose>
            <xsl:when test="$reference/url and $reference/dateAccessed and $reference/doi">
                <xsl:for-each select="$urlDateAccessedLayouts/*[urlItem and dateAccessedItem and doiItem]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$reference/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($reference/dateAccessed)"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$reference/doi"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$reference/url and $reference/dateAccessed and not($reference/doi)">
                <xsl:for-each select="$urlDateAccessedLayouts/*[urlItem and dateAccessedItem and not(doiItem)]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$reference/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="normalize-space($reference/dateAccessed)"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$reference/url and not($reference/dateAccessed) and $reference/doi">
                <xsl:for-each select="$urlDateAccessedLayouts/*[urlItem and not(dateAccessedItem) and doiItem]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name()='urlItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$reference/url"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name()='doiItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$reference/doi"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$reference/dateAccessed and not($reference/url) and $reference/doi">
                <xsl:for-each select="$urlDateAccessedLayouts/*[not(urlItem) and dateAccessedItem and doiItem]">
                    <xsl:for-each select="*">
                        <xsl:choose>
                            <xsl:when test="name()='dateAccessedItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$reference/dateAccessed"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name()='doiItem'">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$reference/doi"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$reference/url and not($reference/dateAccessed) and not($reference/doi)">
                <xsl:for-each select="$urlDateAccessedLayouts/*[urlItem and not(dateAccessedItem) and not(doiItem)]">
                    <xsl:for-each select="*">
                        <xsl:call-template name="OutputReferenceItemNode">
                            <xsl:with-param name="item" select="$reference/url"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$reference/doi and not($reference/url) and not($reference/dateAccessed)">
                <xsl:for-each select="$urlDateAccessedLayouts/*[doiItem and not(urlItem) and not(dateAccessedItem)]">
                    <xsl:for-each select="*">
                        <xsl:call-template name="OutputReferenceItemNode">
                            <xsl:with-param name="item" select="$reference/doi"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="not($reference/url) and $reference/dateAccessed and not($reference/doi)">
                <xsl:for-each select="$urlDateAccessedLayouts/*[not(urlItem) and dateAccessedItem]">
                    <xsl:for-each select="*">
                        <xsl:call-template name="OutputReferenceItem">
                            <xsl:with-param name="item" select="$reference/dateAccessed"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
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
                            <xsl:when test="name(.)='refTitleItem' and string-length($work/refTitle) &gt; 0">
                                <xsl:call-template name="OutputReferenceItemNode">
                                    <xsl:with-param name="item" select="$work/refTitle"/>
                                </xsl:call-template>
                                <xsl:if test="$work/../@showAuthorName='no'">
                                    <xsl:call-template name="DoDateLayout">
                                        <xsl:with-param name="refDateItem" select="ancestor::referencesLayout/refAuthorLayouts/refAuthorLayout[position()=last()]/refDateItem"/>
                                        <xsl:with-param name="work" select="$work"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name(.)='editionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$webPage/edition"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='locationItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$webPage/location"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='institutionItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$webPage/institution"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='publisherItem'">
                                <xsl:call-template name="OutputReferenceItem">
                                    <xsl:with-param name="item" select="$webPage/publisher"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem' and name(following-sibling::*[2])='doiItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$webPage"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[2])='urlItem' and name(preceding-sibling::*[1])='dateAccessedItem' and name(.)='doi'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem' and name(following-sibling::*[1])='dateAccessedItem'">
                                <xsl:call-template name="HandleUrlAndDateAccessedLayouts">
                                    <xsl:with-param name="typeOfWork" select="$webPage"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(preceding-sibling::*[1])='urlItem' and name(.)='dateAccessedItem'">
                                <!-- do nothing; was handled above -->
                            </xsl:when>
                            <xsl:when test="name(.)='urlItem'">
                                <xsl:call-template name="HandleUrlLayout">
                                    <xsl:with-param name="kindOfWork" select="$webPage"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='dateAccessedItem'">
                                <xsl:call-template name="HandleDateAccessedLayout">
                                    <xsl:with-param name="kindOfWork" select="$webPage"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='doiItem'">
                                <xsl:call-template name="HandleDoiLayout">
                                    <xsl:with-param name="kindOfWork" select="$webPage"/>
                                    <xsl:with-param name="work" select="$work"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name(.)='urlDateAccessedLayoutsRef'">
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$webPage"/>
                                </xsl:call-template>
                                <xsl:call-template name="DoUrlDateAccessedLayout">
                                    <xsl:with-param name="reference" select="$webPage/.."/>
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
        GetAndFormatExampleNumber
    -->
    <xsl:template name="GetAndFormatExampleNumber">
        <xsl:if test="$contentLayoutInfo/exampleLayout/@numberProperUseParens!='no'">
            <xsl:text>(</xsl:text>
        </xsl:if>
        <xsl:call-template name="GetExampleNumber">
            <xsl:with-param name="example" select="."/>
        </xsl:call-template>
        <xsl:if test="$contentLayoutInfo/exampleLayout/@numberProperAddPeriodAfterFinalDigit='yes'">
            <xsl:text>.</xsl:text>
        </xsl:if>
        <xsl:if test="$contentLayoutInfo/exampleLayout/@numberProperUseParens!='no'">
            <xsl:text>)</xsl:text>
        </xsl:if>
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
            <xsl:call-template name="GetUrlEtcLayoutToUseInfo"/>
            <xsl:choose>
                <xsl:when test="reprintInfo">y</xsl:when>
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
                    <xsl:call-template name="DetermineIfLocationPublisherMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="locationPublisherPos">7</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfUrlMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="urlPos">8</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDateAccessedMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="dateAccessedPos">9</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDoiMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="doiPos">10</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 12, 1)='y' and reprintInfoItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 12, 1)='n' and not(reprintInfoItem)">x</xsl:when>
                    </xsl:choose>
                    <!--                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>
-->
                    <!-- now we always set the x for the ISO whether the pattern is there or not; it all comes out in the wash -->
                    <xsl:text>x</xsl:text>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 12">
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
                        <xsl:if test="not(authorRoleItem) and not(name()='comment')">
                            <xsl:call-template name="RecordPosition"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetBestHangingIndentInitialIndent
    -->
    <xsl:template name="GetBestHangingIndentInitialIndent">
        <xsl:param name="sThisHangingIndent"/>
        <xsl:param name="sThisInitialIndent"/>
        <xsl:variable name="sValue" select="substring($sThisInitialIndent,1,string-length($sThisHangingIndent)-2)"/>
        <xsl:choose>
            <xsl:when test="$sValue=0">
                <xsl:call-template name="GetHangingIndentNormalIndent">
                    <xsl:with-param name="sThisHangingIndent" select="$sThisHangingIndent"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sThisInitialIndent"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        GetBestLangDataLayout
    -->
    <xsl:template name="GetBestLangDataLayout">
        <xsl:variable name="sThisLang">
            <xsl:value-of select="@lang"/>
        </xsl:variable>
        <xsl:variable name="layoutSpecificToThisLanguage" select="$contentLayoutInfo/langDataLayout[@language=$sThisLang]"/>
        <xsl:variable name="firstLayout" select="$contentLayoutInfo/langDataLayout[1]"/>
        <xsl:choose>
            <xsl:when test="$layoutSpecificToThisLanguage">
                <xsl:copy-of select="$layoutSpecificToThisLanguage"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$firstLayout"/>
            </xsl:otherwise>
        </xsl:choose>
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
                <xsl:when test="multivolumeWork">y</xsl:when>
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
            <xsl:call-template name="GetUrlEtcLayoutToUseInfo"/>
            <xsl:choose>
                <xsl:when test="reprintInfo">y</xsl:when>
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
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='y' and multivolumeWorkItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='n' and not(multivolumeWorkItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and bookTotalPagesItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(bookTotalPagesItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:call-template name="DetermineIfLocationPublisherMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="locationPublisherPos">9</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfUrlMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="urlPos">10</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDateAccessedMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="dateAccessedPos">11</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDoiMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="doiPos">12</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 14, 1)='y' and reprintInfoItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 14, 1)='n' and not(reprintInfoItem)">x</xsl:when>
                    </xsl:choose>
                    <!--<xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,11, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,11, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                    </xsl:choose>-->
                    <!-- now we always set the x for the ISO whether the pattern is there or not; it all comes out in the wash -->
                    <xsl:text>x</xsl:text>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 14">
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
            <xsl:call-template name="GetUrlEtcLayoutToUseInfo"/>
            <xsl:choose>
                <xsl:when test="edition">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="reprintInfo">y</xsl:when>
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
                    <xsl:call-template name="DetermineIfLocationPublisherMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="locationPublisherPos">7</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfUrlMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="urlPos">8</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDateAccessedMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="dateAccessedPos">9</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDoiMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="doiPos">10</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 12, 1)='y' and editionItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 12, 1)='n' and not(editionItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 13, 1)='y' and reprintInfoItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 13, 1)='n' and not(reprintInfoItem)">x</xsl:when>
                    </xsl:choose>
                    <!--<xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                        </xsl:choose>-->
                    <!-- now we always set the x for the ISO whether the pattern is there or not; it all comes out in the wash -->
                    <xsl:text>x</xsl:text>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 13">
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
            <xsl:call-template name="GetUrlEtcLayoutToUseInfo"/>
            <xsl:choose>
                <xsl:when test="reprintInfo">y</xsl:when>
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
                    <xsl:call-template name="DetermineIfLocationPublisherMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="locationPublisherPos">5</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfUrlMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="urlPos">6</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDateAccessedMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="dateAccessedPos">7</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDoiMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="doiPos">8</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 10, 1)='y' and reprintInfoItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 10, 1)='n' and not(reprintInfoItem)">x</xsl:when>
                    </xsl:choose>
                    <!--                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                        </xsl:choose>-->
                    <!-- now we always set the x for the ISO whether the pattern is there or not; it all comes out in the wash -->
                    <xsl:text>x</xsl:text>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 10">
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
                <xsl:when test="multivolumeWork">y</xsl:when>
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
            <xsl:call-template name="GetUrlEtcLayoutToUseInfo"/>
            <xsl:choose>
                <xsl:when test="key('RefWorkID',collCitation/@refToBook)/authorRole">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="edition">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="reprintInfo">y</xsl:when>
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
                        <xsl:when test="substring($sOptionsPresent, 9, 1)='y' and multivolumeWorkItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 9, 1)='n' and not(multivolumeWorkItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:call-template name="DetermineIfLocationPublisherMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="locationPublisherPos">10</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,11, 1)='y' and collCitationItem">
                            <xsl:choose>
                                <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and collPagesItem and string-length(normalize-space($refWork/collCitation/@page)) &gt; 0">xx</xsl:when>
                                <xsl:otherwise>x</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="substring($sOptionsPresent,11, 1)='n' and not(collCitationItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:call-template name="DetermineIfUrlMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="urlPos">12</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDateAccessedMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="dateAccessedPos">13</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDoiMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="doiPos">14</xsl:with-param>
                    </xsl:call-template>
                    <!--<xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,13, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,13, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                        </xsl:choose>-->
                    <!-- now we always set the x for the ISO whether the pattern is there or not; it all comes out in the wash -->
                    <xsl:text>x</xsl:text>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,16, 1)='y' and authorRoleItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,16, 1)='n' and not(authorRoleItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 17, 1)='y' and editionItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 17, 1)='n' and not(editionItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 18, 1)='y' and reprintInfoItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 18, 1)='n' and not(reprintInfoItem)">x</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <!--                <xsl:variable name="iLen" select="string-length($sItemsWhichMatchOptions)"/>-->
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 18">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetContextOfItem
    -->
    <xsl:template name="GetContextOfItem">
        <xsl:variable name="closestRelevantAncestor" select="ancestor::*[name()='endnote' or name()='listWord' or name()='word' or name()='example' or name()='table' or name()='interlinear-text' or name()='annotation' or name()='refAuthor'][1]"/>
        <xsl:choose>
            <xsl:when test="name()='gloss' and name($closestRelevantAncestor)='listWord' or name()='gloss' and name($closestRelevantAncestor)='word'">
                <xsl:choose>
                    <xsl:when test="$contentLayoutInfo/glossLayout/glossInListWordLayout">
                        <xsl:text>listWord</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>example</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="name()='abbrRef' and name($closestRelevantAncestor)='listWord' or name()='abbrRef' and name($closestRelevantAncestor)='word'">
                <xsl:choose>
                    <xsl:when test="$contentLayoutInfo/glossLayout/glossInListWordLayout">
                        <xsl:text>listWord</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>example</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="name($closestRelevantAncestor)='listWord' or name($closestRelevantAncestor)='word'">
                <xsl:text>example</xsl:text>
            </xsl:when>
            <xsl:when test="name($closestRelevantAncestor)='example' or name($closestRelevantAncestor)='interlinear-text'">
                <xsl:choose>
                    <xsl:when test="ancestor::exampleHeading">
                        <xsl:text>prose</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>example</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="name($closestRelevantAncestor)='table'">
                <xsl:text>table</xsl:text>
            </xsl:when>
            <xsl:when test="name($closestRelevantAncestor)='refAuthor'">
                <xsl:text>reference</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>prose</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
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
            <xsl:call-template name="GetUrlEtcLayoutToUseInfo"/>
            <xsl:choose>
                <xsl:when test="reprintInfo">y</xsl:when>
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
                    <xsl:call-template name="DetermineIfUrlMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="urlPos">6</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDateAccessedMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="dateAccessedPos">7</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDoiMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="doiPos">8</xsl:with-param>
                    </xsl:call-template>
                    <!--<xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                        </xsl:choose>-->
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 10, 1)='y' and reprintInfoItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 10, 1)='n' and not(reprintInfoItem)">x</xsl:when>
                    </xsl:choose>
                    <!-- now we always set the x for the ISO whether the pattern is there or not; it all comes out in the wash -->
                    <xsl:text>x</xsl:text>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 10">
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
            <xsl:call-template name="GetUrlEtcLayoutToUseInfo"/>
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
                    <xsl:call-template name="DetermineIfUrlMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="urlPos">4</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDateAccessedMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="dateAccessedPos">5</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDoiMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="doiPos">6</xsl:with-param>
                    </xsl:call-template>
                    <!--<xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                        </xsl:choose>-->
                    <!-- now we always set the x for the ISO whether the pattern is there or not; it all comes out in the wash -->
                    <xsl:text>x</xsl:text>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 7">
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
                    <xsl:when test="string-length($startPage) = 4 and string-length($endPage) = 4 and substring($startPage,1,2)=substring($endPage,1,2)">
                        <xsl:value-of select="$startPage"/>
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="substring($endPage,3)"/>
                    </xsl:when>
                    <xsl:when test="string-length($startPage) = 5 and string-length($endPage) = 5 and substring($startPage,1,3)=substring($endPage,1,3)">
                        <xsl:value-of select="$startPage"/>
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="substring($endPage,4)"/>
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
        GetHangingIndentNormalIndent
    -->
    <xsl:template name="GetHangingIndentNormalIndent">
        <xsl:param name="sThisHangingIndent"/>
        <xsl:choose>
            <xsl:when test="string-length($sThisHangingIndent) &gt; 0">
                <xsl:value-of select="$sThisHangingIndent"/>
            </xsl:when>
            <xsl:when test="string-length($sHangingIndentNormalIndent) &gt; 0">
                <xsl:value-of select="$sHangingIndentNormalIndent"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>1em</xsl:text>
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
                <xsl:when test="empty">y</xsl:when>
                <xsl:otherwise>n</xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="GetUrlEtcLayoutToUseInfo"/>
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
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='y' and emptyItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 4, 1)='n' and not(emptyItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:call-template name="DetermineIfUrlMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="urlPos">5</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDateAccessedMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="dateAccessedPos">6</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDoiMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="doiPos">7</xsl:with-param>
                    </xsl:call-template>
                    <!--<xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                        </xsl:choose>-->
                    <!-- now we always set the x for the ISO whether the pattern is there or not; it all comes out in the wash -->
                    <xsl:text>x</xsl:text>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 8">
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
            <xsl:call-template name="GetUrlEtcLayoutToUseInfo"/>
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
                    <xsl:call-template name="DetermineIfUrlMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="urlPos">4</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDateAccessedMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="dateAccessedPos">5</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDoiMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="doiPos">6</xsl:with-param>
                    </xsl:call-template>
                    <!--<xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 6, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                        </xsl:choose>-->
                    <!-- now we always set the x for the ISO whether the pattern is there or not; it all comes out in the wash -->
                    <xsl:text>x</xsl:text>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 7">
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
            <xsl:call-template name="GetUrlEtcLayoutToUseInfo"/>
            <xsl:choose>
                <xsl:when test="reprintInfo">y</xsl:when>
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
                    <xsl:call-template name="DetermineIfLocationPublisherMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="locationPublisherPos">6</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='y' and procCitationItem">
                            <xsl:choose>
                                <xsl:when test="substring($sOptionsPresent, 5, 1)='n' and procPagesItem and string-length(normalize-space($refWork/procCitation/@page)) &gt; 0">xx</xsl:when>
                                <xsl:otherwise>x</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 7, 1)='n' and not(procCitationItem)">x</xsl:when>
                    </xsl:choose>
                    <xsl:call-template name="DetermineIfUrlMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="urlPos">8</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDateAccessedMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="dateAccessedPos">9</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDoiMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="doiPos">10</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 12, 1)='y' and reprintInfoItem">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 12, 1)='n' and not(reprintInfoItem)">x</xsl:when>
                    </xsl:choose>
                    <!--<xsl:choose>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent,10, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                        </xsl:choose>-->
                    <!-- now we always set the x for the ISO whether the pattern is there or not; it all comes out in the wash -->
                    <xsl:text>x</xsl:text>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 12">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        GetSectionRefToUse
    -->
    <xsl:template name="GetSectionRefToUse">
        <xsl:param name="section"/>
        <xsl:choose>
            <xsl:when test="name($section)='section1' or contains(name($section),'chapter') or name($section)='part'">
                <!-- just use section1, chapter, and part;   if section1 is being ignored, that's the style sheet's problem... -->
                <xsl:value-of select="$section/@id"/>
            </xsl:when>
            <xsl:when test="name($section)='section2'">
                <xsl:call-template name="TrySectionRef">
                    <xsl:with-param name="section" select="$section"/>
                    <xsl:with-param name="sectionLayoutInfo" select="$bodyLayoutInfo/section2Layout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name($section)='section3'">
                <xsl:call-template name="TrySectionRef">
                    <xsl:with-param name="section" select="$section"/>
                    <xsl:with-param name="sectionLayoutInfo" select="$bodyLayoutInfo/section3Layout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name($section)='section4'">
                <xsl:call-template name="TrySectionRef">
                    <xsl:with-param name="section" select="$section"/>
                    <xsl:with-param name="sectionLayoutInfo" select="$bodyLayoutInfo/section4Layout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name($section)='section5'">
                <xsl:call-template name="TrySectionRef">
                    <xsl:with-param name="section" select="$section"/>
                    <xsl:with-param name="sectionLayoutInfo" select="$bodyLayoutInfo/section5Layout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name($section)='section6'">
                <xsl:call-template name="TrySectionRef">
                    <xsl:with-param name="section" select="$section"/>
                    <xsl:with-param name="sectionLayoutInfo" select="$bodyLayoutInfo/section6Layout"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        GetTextBetweenKeywords
    -->
    <xsl:template name="GetTextBetweenKeywords">
        <xsl:param name="layoutInfo" select="$frontMatterLayoutInfo"/>
        <xsl:variable name="sLayoutText" select="$layoutInfo/keywordsLayout/@textBetweenKeywords"/>
        <xsl:choose>
            <xsl:when test="string-length($sLayoutText) &gt; 0">
                <xsl:value-of select="$sLayoutText"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>, </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        GetUrlEtcLayoutToUseInfo
    -->
    <xsl:template name="GetUrlEtcLayoutToUseInfo">
        <xsl:choose>
            <xsl:when test="../url or url">y</xsl:when>
            <xsl:otherwise>n</xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="../dateAccessed or dateAccessed">y</xsl:when>
            <xsl:otherwise>n</xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="doi">y</xsl:when>
            <xsl:otherwise>n</xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
            <xsl:when test="../iso639-3code and ancestor-or-self::refWork/@showiso639-3codes='yes'">y</xsl:when>
            <xsl:when test="iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes'">y</xsl:when>
            <xsl:when test="iso639-3code and ancestor-or-self::refWork/@showiso639-3codes='yes'">y</xsl:when>
            <xsl:otherwise>n</xsl:otherwise>
        </xsl:choose>
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
            <xsl:call-template name="GetUrlEtcLayoutToUseInfo"/>
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
                    <xsl:call-template name="DetermineIfUrlMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="urlPos">6</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDateAccessedMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="dateAccessedPos">7</xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="DetermineIfDoiMatchesLayoutPattern">
                        <xsl:with-param name="sOptionsPresent" select="$sOptionsPresent"/>
                        <xsl:with-param name="doiPos">8</xsl:with-param>
                    </xsl:call-template>
                    <!--<xsl:choose>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='y' and iso639-3codeItemRef">x</xsl:when>
                        <xsl:when test="substring($sOptionsPresent, 8, 1)='n' and not(iso639-3codeItemRef)">x</xsl:when>
                        </xsl:choose>-->
                    <!-- now we always set the x for the ISO whether the pattern is there or not; it all comes out in the wash -->
                    <xsl:text>x</xsl:text>
                </xsl:variable>
                <xsl:if test="string-length($sItemsWhichMatchOptions) = 9">
                    <xsl:call-template name="RecordPosition"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-before($sPosition,';')"/>
    </xsl:template>
    <!--  
        HandleBasicFrontMatterPerLayout
    -->
    <xsl:template name="HandleBasicFrontMatterPerLayout">
        <xsl:param name="frontMatter"/>
        <xsl:param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <xsl:variable name="iAuthorLayouts" select="count($frontMatterLayout/authorLayout[count(preceding-sibling::*[1])=0 or preceding-sibling::*[1][name()!='contentsLayout']])"/>
        <xsl:variable name="iAffiliationLayouts" select="count($frontMatterLayout/affiliationLayout)"/>
        <xsl:variable name="iEmailAddressLayouts" select="count($frontMatterLayout/emailAddressLayout)"/>
        <xsl:for-each select="$frontMatterLayout/*">
            <xsl:choose>
                <xsl:when test="name(.)='titleLayout'">
                    <xsl:apply-templates select="$frontMatter/title"/>
                </xsl:when>
                <xsl:when test="name(.)='subtitleLayout'">
                    <xsl:apply-templates select="$frontMatter/subtitle"/>
                </xsl:when>
                <xsl:when test="name(.)='authorLayout' and count(preceding-sibling::*[1])=0 or name(.)='authorLayout' and preceding-sibling::*[1][name()!='contentsLayout']">
                    <xsl:variable name="iPos" select="count(preceding-sibling::authorLayout) + 1"/>
                    <xsl:choose>
                        <xsl:when test="following-sibling::authorLayout[preceding-sibling::*[1][name()!='contentsLayout']]">
                            <xsl:call-template name="DoAuthorRelatedElementsPerSingleSetOfLayouts">
                                <xsl:with-param name="authors" select="$frontMatter/author"/>
                                <xsl:with-param name="currentAuthors" select="$frontMatter/author[$iPos]"/>
                                <xsl:with-param name="thisAffiliationLayout" select="following-sibling::*[name()='affiliationLayout' and count(preceding-sibling::authorLayout) = $iPos]"/>
                                <xsl:with-param name="thisEmailAddressLayout" select="following-sibling::*[name()='emailAddressLayout' and count(preceding-sibling::authorLayout) = $iPos]"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="preceding-sibling::authorLayout and not(following-sibling::authorLayout[preceding-sibling::*[1][name()!='contentsLayout']])">
                            <xsl:call-template name="DoAuthorRelatedElementsPerSingleSetOfLayouts">
                                <xsl:with-param name="authors" select="$frontMatter/author"/>
                                <xsl:with-param name="currentAuthors" select="$frontMatter/author[position() &gt;= $iPos]"/>
                                <xsl:with-param name="thisAffiliationLayout" select="following-sibling::*[name()='affiliationLayout' and count(preceding-sibling::authorLayout) = $iPos]"/>
                                <xsl:with-param name="thisEmailAddressLayout" select="following-sibling::*[name()='emailAddressLayout' and count(preceding-sibling::authorLayout) = $iPos]"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$iAuthorLayouts = 1 and $iAffiliationLayouts &lt;= 1 and $iEmailAddressLayouts &lt;= 1 ">
                            <!-- 
                                only one author layout and at most one affiliation layout and at most one email layout : 
                                want to try to apply each set of author/affiliation/email elements to this pattern, allowing for
                                multiple affiliations
                            -->
                            <xsl:variable name="thisAffiliationLayout" select="following-sibling::affiliationLayout"/>
                            <xsl:variable name="thisEmailAddressLayout" select="following-sibling::emailAddressLayout"/>
                            <xsl:call-template name="DoAuthorRelatedElementsPerSingleSetOfLayouts">
                                <xsl:with-param name="authors" select="$frontMatter/author"/>
                                <xsl:with-param name="currentAuthors" select="$frontMatter/author"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$frontMatter/author"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="name(.)='affiliationLayout'">
                    <xsl:choose>
                        <xsl:when test="following-sibling::affiliationLayout ">
                            <!-- already handled under the author layout case-->
                        </xsl:when>
                        <xsl:when test="preceding-sibling::affiliationLayout and not(following-sibling::affiliationLayout)">
                            <!-- already handled under the author layout case-->
                        </xsl:when>
                        <xsl:when test="$iAuthorLayouts = 1 and $iAffiliationLayouts &lt;= 1 and $iEmailAddressLayouts &lt;= 1 ">
                            <!-- already handled under the author layout case-->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$frontMatter/affiliation">
                                <xsl:with-param name="affiliationLayoutToUse" select="."/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="name(.)='emailAddressLayout'">
                    <xsl:choose>
                        <xsl:when test="following-sibling::emailAddressLayout ">
                            <!-- already handled under the author layout case-->
                        </xsl:when>
                        <xsl:when test="preceding-sibling::emailAddressLayout and not(following-sibling::emailAddressLayout)">
                            <!-- already handled under the author layout case-->
                        </xsl:when>
                        <xsl:when test="$iAuthorLayouts = 1 and $iAffiliationLayouts &lt;= 1 and $iEmailAddressLayouts &lt;= 1 ">
                            <!-- already handled under the author layout case-->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$frontMatter/emailAddress">
                                <xsl:with-param name="emailAddressLayoutToUse" select="."/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="name(.)='authorContactInfoLayout'">
                    <xsl:apply-templates select="$lingPaper/frontMatter/authorContactInfo">
                        <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/authorContactInfoLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='presentedAtLayout'">
                    <xsl:apply-templates select="$frontMatter/presentedAt"/>
                </xsl:when>
                <xsl:when test="name(.)='dateLayout'">
                    <xsl:apply-templates select="$frontMatter/date">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='versionLayout'">
                    <xsl:apply-templates select="$frontMatter/version">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='keywordsLayout'">
                    <xsl:apply-templates select="$frontMatter/keywordsShownHere">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='publishingBlurbLayout'">
                    <xsl:apply-templates select="$lingPaper/publishingInfo/publishingBlurb"/>
                </xsl:when>
                <xsl:when test="name(.)='contentsLayout' and $frontMatter[ancestor::chapterInCollection]">
                    <xsl:apply-templates select="$frontMatter/contents" mode="paper">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$frontMatterLayout/contentsLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='contentsLayout' and not($bIsBook)">
                    <xsl:apply-templates select="$lingPaper/frontMatter/contents" mode="paper">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$frontMatterLayoutInfo/contentsLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='acknowledgementsLayout' and $frontMatter[ancestor::chapterInCollection]">
                    <xsl:apply-templates select="$frontMatter/acknowledgements" mode="paper">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='acknowledgementsLayout' and not($bIsBook)">
                    <xsl:apply-templates select="$frontMatter/acknowledgements" mode="paper"/>
                </xsl:when>
                <xsl:when test="name(.)='keywordsLayout' and $frontMatter[ancestor::chapterInCollection]">
                    <xsl:apply-templates select="$frontMatter/keywordsShownHere" mode="paper">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='keywordsLayout' and not($bIsBook)">
                    <xsl:apply-templates select="$frontMatter/keywordsShownHere" mode="paper">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='abstractLayout' and $frontMatter[ancestor::chapterInCollection]">
                    <xsl:apply-templates select="$frontMatter/abstract" mode="paper">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                        <xsl:with-param name="iLayoutPosition">
                            <xsl:choose>
                                <xsl:when test="preceding-sibling::abstractLayout or following-sibling::abstractLayout">
                                    <xsl:value-of select="count(preceding-sibling::abstractLayout) + 1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>0</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='abstractLayout' and not($bIsBook)">
                    <xsl:apply-templates select="$frontMatter/abstract" mode="paper">
                        <xsl:with-param name="iLayoutPosition">
                            <xsl:choose>
                                <xsl:when test="preceding-sibling::abstractLayout or following-sibling::abstractLayout">
                                    <xsl:value-of select="count(preceding-sibling::abstractLayout) + 1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>0</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='prefaceLayout' and $frontMatter[ancestor::chapterInCollection]">
                    <xsl:apply-templates select="$frontMatter/preface" mode="paper">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                        <xsl:with-param name="iLayoutPosition">
                            <xsl:choose>
                                <xsl:when test="preceding-sibling::prefaceLayout or following-sibling::prefaceLayout">
                                    <xsl:value-of select="count(preceding-sibling::prefaceLayout) + 1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>0</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='prefaceLayout' and not($bIsBook)">
                    <xsl:apply-templates select="$frontMatter/preface" mode="paper">
                        <xsl:with-param name="iLayoutPosition">
                            <xsl:choose>
                                <xsl:when test="preceding-sibling::prefaceLayout or following-sibling::prefaceLayout">
                                    <xsl:value-of select="count(preceding-sibling::prefaceLayout) + 1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>0</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
        HandleDateAccessedLayout
    -->
    <xsl:template name="HandleDateAccessedLayout">
        <xsl:param name="kindOfWork"/>
        <xsl:param name="work"/>
        <xsl:variable name="currentItem" select="."/>
        <xsl:for-each select="$kindOfWork/dateAccessed | $work/dateAccessed">
            <xsl:variable name="item" select="."/>
            <xsl:for-each select="$currentItem">
                <xsl:call-template name="OutputReferenceItem">
                    <xsl:with-param name="item" select="$item"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <!--  
        HandleDoiLayout
    -->
    <xsl:template name="HandleDoiLayout">
        <xsl:param name="kindOfWork"/>
        <xsl:param name="work"/>
        <xsl:variable name="currentItem" select="."/>
        <xsl:for-each select="$kindOfWork/doi | $work/doi">
            <xsl:variable name="item" select="."/>
            <xsl:for-each select="$currentItem">
                <xsl:call-template name="OutputReferenceItemNode">
                    <xsl:with-param name="item" select="$item"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <!--  
        HandleFreeTextAfterInside
    -->
    <xsl:template name="HandleFreeTextAfterInside">
        <xsl:param name="freeLayout"/>
        <xsl:if test="$freeLayout/@textbeforeafterusesfontinfo='yes'">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                    <xsl:value-of select="normalize-space(@textafter)"/>
                </xsl:when>
                <xsl:when test="string-length(normalize-space($freeLayout/@textafter)) &gt; 0">
                    <xsl:value-of select="normalize-space($freeLayout/@textafter)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleFreeTextAfterOutside
    -->
    <xsl:template name="HandleFreeTextAfterOutside">
        <xsl:param name="freeLayout"/>
        <xsl:if test="$freeLayout">
            <xsl:if test="$freeLayout/@textbeforeafterusesfontinfo='no'">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space(@textafter)"/>
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($freeLayout/@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space($freeLayout/@textafter)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleFreeTextBeforeAndFontOverrides
    -->
    <xsl:template name="HandleFreeTextBeforeAndFontOverrides">
        <xsl:param name="freeLayout"/>
        <xsl:if test="$freeLayout">
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$freeLayout"/>
                <xsl:with-param name="originalContext" select="."/>
                <xsl:with-param name="bIsOverride" select="'Y'"/>
            </xsl:call-template>
            <xsl:if test="$freeLayout/@textbeforeafterusesfontinfo='yes'">
                <xsl:choose>
                    <xsl:when test="string-length(@textbefore) &gt; 0">
                        <xsl:value-of select="@textbefore"/>
                    </xsl:when>
                    <xsl:when test="string-length($freeLayout/@textbefore) &gt; 0">
                        <xsl:value-of select="$freeLayout/@textbefore"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleFreeTextBeforeOutside
    -->
    <xsl:template name="HandleFreeTextBeforeOutside">
        <xsl:param name="freeLayout"/>
        <xsl:if test="$freeLayout">
            <xsl:if test="$freeLayout/@textbeforeafterusesfontinfo='no'">
                <xsl:choose>
                    <xsl:when test="string-length(@textbefore) &gt; 0">
                        <xsl:value-of select="@textbefore"/>
                    </xsl:when>
                    <xsl:when test="string-length($freeLayout/@textbefore) &gt; 0">
                        <xsl:value-of select="$freeLayout/@textbefore"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleGlossFontOverrides
    -->
    <xsl:template name="HandleGlossFontOverrides">
        <xsl:param name="sGlossContext"/>
        <xsl:param name="glossLayout"/>
        <xsl:choose>
            <xsl:when test="$sGlossContext='listWord'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$glossLayout/glossInListWordLayout"/>
                    <xsl:with-param name="originalContext" select="."/>
                    <xsl:with-param name="bIsOverride" select="'Y'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$sGlossContext='example'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$glossLayout/glossInExampleLayout"/>
                    <xsl:with-param name="originalContext" select="."/>
                    <xsl:with-param name="bIsOverride" select="'Y'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$sGlossContext='table'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$glossLayout/glossInTableLayout"/>
                    <xsl:with-param name="originalContext" select="."/>
                    <xsl:with-param name="bIsOverride" select="'Y'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$sGlossContext='prose'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$glossLayout/glossInProseLayout"/>
                    <xsl:with-param name="originalContext" select="."/>
                    <xsl:with-param name="bIsOverride" select="'Y'"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        HandleGlossTextAfterInside
    -->
    <xsl:template name="HandleGlossTextAfterInside">
        <xsl:param name="glossLayout"/>
        <xsl:param name="sGlossContext"/>
        <xsl:choose>
            <xsl:when test="$glossLayout/glossInListWordLayout/@textbeforeafterusesfontinfo='yes' and $sGlossContext='listWord'">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space(@textafter)"/>
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($glossLayout/glossInListWordLayout/@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space($glossLayout/glossInListWordLayout/@textafter)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$glossLayout/glossInExampleLayout/@textbeforeafterusesfontinfo='yes' and $sGlossContext='example'">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space(@textafter)"/>
                    </xsl:when>
                    <xsl:when test="name()='line' and string-length(normalize-space(gloss/@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space(gloss/@textafter)"/>
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($glossLayout/glossInExampleLayout/@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space($glossLayout/glossInExampleLayout/@textafter)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$glossLayout/glossInTableLayout/@textbeforeafterusesfontinfo='yes' and $sGlossContext='table'">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space(@textafter)"/>
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($glossLayout/glossInTableLayout/@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space($glossLayout/glossInTableLayout/@textafter)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$glossLayout/glossInProseLayout/@textbeforeafterusesfontinfo='yes' and $sGlossContext='prose'">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space(@textafter)"/>
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($glossLayout/glossInProseLayout/@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space($glossLayout/glossInProseLayout/@textafter)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        HandleGlossTextAfterOutside
    -->
    <xsl:template name="HandleGlossTextAfterOutside">
        <xsl:param name="glossLayout"/>
        <xsl:param name="sGlossContext"/>
        <xsl:if test="$glossLayout">
            <xsl:choose>
                <xsl:when test="$glossLayout/glossInListWordLayout/@textbeforeafterusesfontinfo='no' and $sGlossContext='listWord'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textafter)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInListWordLayout/@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInListWordLayout/@textafter)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$glossLayout/glossInExampleLayout/@textbeforeafterusesfontinfo='no' and $sGlossContext='example'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textafter)"/>
                        </xsl:when>
                        <xsl:when test="name()='line' and string-length(normalize-space(gloss/@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space(gloss/@textafter)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInExampleLayout/@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInExampleLayout/@textafter)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$glossLayout/glossInTableLayout/@textbeforeafterusesfontinfo='no' and $sGlossContext='table'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textafter)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInTableLayout/@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInTableLayout/@textafter)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$glossLayout/glossInProseLayout/@textbeforeafterusesfontinfo='no' and $sGlossContext='prose'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textafter)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInProseLayout/@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInProseLayout/@textafter)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleGlossTextBeforeAndFontOverrides
    -->
    <xsl:template name="HandleGlossTextBeforeAndFontOverrides">
        <xsl:param name="glossLayout"/>
        <xsl:param name="sGlossContext"/>
        <xsl:if test="$glossLayout">
            <xsl:call-template name="HandleGlossFontOverrides">
                <xsl:with-param name="sGlossContext" select="$sGlossContext"/>
                <xsl:with-param name="glossLayout" select="$glossLayout"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="$glossLayout/glossInListWordLayout/@textbeforeafterusesfontinfo='yes' and $sGlossContext='listWord'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInListWordLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInListWordLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$glossLayout/glossInExampleLayout/@textbeforeafterusesfontinfo='yes' and $sGlossContext='example'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="name()='line' and string-length(normalize-space(gloss/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(gloss/@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInExampleLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInExampleLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$glossLayout/glossInTableLayout/@textbeforeafterusesfontinfo='yes' and $sGlossContext='table'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInTableLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInTableLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$glossLayout/glossInProseLayout/@textbeforeafterusesfontinfo='yes' and $sGlossContext='prose'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInProseLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInProseLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleGlossTextBeforeOutside
    -->
    <xsl:template name="HandleGlossTextBeforeOutside">
        <xsl:param name="glossLayout"/>
        <xsl:param name="sGlossContext"/>
        <xsl:if test="$glossLayout">
            <xsl:choose>
                <xsl:when test="$glossLayout/glossInListWordLayout/@textbeforeafterusesfontinfo='no' and $sGlossContext='listWord'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInListWordLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInListWordLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$glossLayout/glossInExampleLayout/@textbeforeafterusesfontinfo='no' and $sGlossContext='example'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="name()='line' and string-length(normalize-space(gloss/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(gloss/@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInExampleLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInExampleLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$glossLayout/glossInTableLayout/@textbeforeafterusesfontinfo='no' and $sGlossContext='table'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInTableLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInTableLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$glossLayout/glossInProseLayout/@textbeforeafterusesfontinfo='no' and $sGlossContext='prose'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($glossLayout/glossInProseLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($glossLayout/glossInProseLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleLangDataFontOverrides
    -->
    <xsl:template name="HandleLangDataFontOverrides">
        <xsl:param name="sLangDataContext"/>
        <xsl:param name="langDataLayout"/>
        <xsl:choose>
            <xsl:when test="$sLangDataContext='example'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$langDataLayout/langDataInExampleLayout"/>
                    <xsl:with-param name="originalContext" select="."/>
                    <xsl:with-param name="bIsOverride" select="'Y'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$sLangDataContext='table'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$langDataLayout/langDataInTableLayout"/>
                    <xsl:with-param name="originalContext" select="."/>
                    <xsl:with-param name="bIsOverride" select="'Y'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$sLangDataContext='prose'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$langDataLayout/langDataInProseLayout"/>
                    <xsl:with-param name="originalContext" select="."/>
                    <xsl:with-param name="bIsOverride" select="'Y'"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        HandleLangDataTextAfterInside
    -->
    <xsl:template name="HandleLangDataTextAfterInside">
        <xsl:param name="langDataLayout"/>
        <xsl:param name="sLangDataContext"/>
        <xsl:choose>
            <xsl:when test="$langDataLayout/langDataInExampleLayout/@textbeforeafterusesfontinfo='yes' and $sLangDataContext='example'">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space(@textafter)"/>
                    </xsl:when>
                    <xsl:when test="name()='line' and string-length(normalize-space(langData/@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space(langData/@textafter)"/>
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($langDataLayout/langDataInExampleLayout/@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space($langDataLayout/langDataInExampleLayout/@textafter)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$langDataLayout/langDataInTableLayout/@textbeforeafterusesfontinfo='yes' and $sLangDataContext='table'">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space(@textafter)"/>
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($langDataLayout/langDataInTableLayout/@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space($langDataLayout/langDataInTableLayout/@textafter)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$langDataLayout/langDataInProseLayout/@textbeforeafterusesfontinfo='yes' and $sLangDataContext='prose'">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space(@textafter)"/>
                    </xsl:when>
                    <xsl:when test="string-length(normalize-space($langDataLayout/langDataInProseLayout/@textafter)) &gt; 0">
                        <xsl:value-of select="normalize-space($langDataLayout/langDataInProseLayout/@textafter)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        HandleLangDataTextAfterOutside
    -->
    <xsl:template name="HandleLangDataTextAfterOutside">
        <xsl:param name="langDataLayout"/>
        <xsl:param name="sLangDataContext"/>
        <xsl:if test="$langDataLayout">
            <xsl:choose>
                <xsl:when test="$langDataLayout/langDataInExampleLayout/@textbeforeafterusesfontinfo='no' and $sLangDataContext='example'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textafter)"/>
                        </xsl:when>
                        <xsl:when test="name()='line' and string-length(normalize-space(langData/@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space(langData/@textafter)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($langDataLayout/langDataInExampleLayout/@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space($langDataLayout/langDataInExampleLayout/@textafter)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$langDataLayout/langDataInTableLayout/@textbeforeafterusesfontinfo='no' and $sLangDataContext='table'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textafter)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($langDataLayout/langDataInTableLayout/@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space($langDataLayout/langDataInTableLayout/@textafter)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$langDataLayout/langDataInProseLayout/@textbeforeafterusesfontinfo='no' and $sLangDataContext='prose'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textafter)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($langDataLayout/langDataInProseLayout/@textafter)) &gt; 0">
                            <xsl:value-of select="normalize-space($langDataLayout/langDataInProseLayout/@textafter)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleLangDataTextBeforeAndFontOverrides
    -->
    <xsl:template name="HandleLangDataTextBeforeAndFontOverrides">
        <xsl:param name="langDataLayout"/>
        <xsl:param name="sLangDataContext"/>
        <xsl:if test="$langDataLayout">
            <xsl:call-template name="HandleLangDataFontOverrides">
                <xsl:with-param name="sLangDataContext" select="$sLangDataContext"/>
                <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="$langDataLayout/langDataInExampleLayout/@textbeforeafterusesfontinfo='yes' and $sLangDataContext='example'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="name()='line' and string-length(normalize-space(langData/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(langData/@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($langDataLayout/langDataInExampleLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($langDataLayout/langDataInExampleLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$langDataLayout/langDataInTableLayout/@textbeforeafterusesfontinfo='yes' and $sLangDataContext='table'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($langDataLayout/langDataInTableLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($langDataLayout/langDataInTableLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$langDataLayout/langDataInProseLayout/@textbeforeafterusesfontinfo='yes' and $sLangDataContext='prose'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($langDataLayout/langDataInProseLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($langDataLayout/langDataInProseLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleLangDataTextBeforeOutside
    -->
    <xsl:template name="HandleLangDataTextBeforeOutside">
        <xsl:param name="langDataLayout"/>
        <xsl:param name="sLangDataContext"/>
        <xsl:if test="$langDataLayout">
            <xsl:choose>
                <xsl:when test="$langDataLayout/langDataInExampleLayout/@textbeforeafterusesfontinfo='no' and $sLangDataContext='example'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="name()='line' and string-length(normalize-space(langData/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(langData/@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($langDataLayout/langDataInExampleLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($langDataLayout/langDataInExampleLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$langDataLayout/langDataInTableLayout/@textbeforeafterusesfontinfo='no' and $sLangDataContext='table'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($langDataLayout/langDataInTableLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($langDataLayout/langDataInTableLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$langDataLayout/langDataInProseLayout/@textbeforeafterusesfontinfo='no' and $sLangDataContext='prose'">
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space(@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space(@textbefore)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($langDataLayout/langDataInProseLayout/@textbefore)) &gt; 0">
                            <xsl:value-of select="normalize-space($langDataLayout/langDataInProseLayout/@textbefore)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleUrlAndDateAccessedLayouts
    -->
    <xsl:template name="HandleUrlAndDateAccessedLayouts">
        <xsl:param name="typeOfWork"/>
        <xsl:param name="work"/>
        <xsl:if test="$typeOfWork/url">
            <xsl:call-template name="OutputReferenceItemNode">
                <xsl:with-param name="item" select="$typeOfWork/url"/>
            </xsl:call-template>
            <xsl:if test="$typeOfWork/dateAccessed">
                <xsl:for-each select="following-sibling::dateAccessedItem[1]">
                    <xsl:call-template name="OutputReferenceItem">
                        <xsl:with-param name="item" select="$typeOfWork/dateAccessed"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
        </xsl:if>
        <xsl:if test="$work/url">
            <xsl:call-template name="OutputReferenceItemNode">
                <xsl:with-param name="item" select="$work/url"/>
            </xsl:call-template>
            <xsl:if test="$work/dateAccessed">
                <xsl:for-each select="following-sibling::dateAccessedItem[1]">
                    <xsl:call-template name="OutputReferenceItem">
                        <xsl:with-param name="item" select="$work/dateAccessed"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
        </xsl:if>
        <xsl:if test="$typeOfWork/doi">
            <xsl:call-template name="OutputReferenceItemNode">
                <xsl:with-param name="item" select="$typeOfWork/doi"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$work/doi">
            <xsl:call-template name="OutputReferenceItemNode">
                <xsl:with-param name="item" select="$work/doi"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleUrlLayout
    -->
    <xsl:template name="HandleUrlLayout">
        <xsl:param name="kindOfWork"/>
        <xsl:param name="work"/>
        <xsl:variable name="currentItem" select="."/>
        <xsl:for-each select="$kindOfWork/url | $work/url">
            <xsl:variable name="item" select="."/>
            <xsl:for-each select="$currentItem">
                <xsl:call-template name="OutputReferenceItemNode">
                    <xsl:with-param name="item" select="$item"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <!--
        OutputAppendiciesLabel
    -->
    <xsl:template name="OutputAppendiciesLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Appendicies</xsl:with-param>
            <xsl:with-param name="pLabel" select="$backMatterLayoutInfo/appendicesTitlePageLayout/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputCannedText
    -->
    <xsl:template name="OutputCannedText">
        <xsl:param name="sCannedText"/>
        <xsl:if test="string-length($sCannedText)&gt;0">
            <xsl:value-of select="$sCannedText"/>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputCitation
    -->
    <xsl:template name="OutputCitation">
        <xsl:param name="item"/>
        <xsl:variable name="sThisRefToBook" select="$item/@refToBook"/>
        <xsl:choose>
            <xsl:when test="saxon:node-set($collOrProcVolumesToInclude)/refWork[@id=$sThisRefToBook]">
                <xsl:call-template name="OutputReferenceItemNode">
                    <xsl:with-param name="item" select="$item"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputReferenceItemNode">
                    <xsl:with-param name="item" select="$item"/>
                    <xsl:with-param name="fDoTextAfter" select="'N'"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputCitationContents
    -->
    <xsl:template name="OutputCitationContents">
        <xsl:param name="refer"/>
        <xsl:if test="@paren='citationBoth' or @paren='citationInitial'">
            <xsl:text>(</xsl:text>
        </xsl:if>
        <xsl:if test="@author='yes'">
            <xsl:value-of select="$refer/../@citename"/>
            <xsl:choose>
                <xsl:when test="string-length($sTextBetweenAuthorAndDate) &gt; 0 and @paren!='both' and @paren!='initial'">
                    <xsl:value-of select="$citationLayout/@textbetweenauthoranddate"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>&#x20;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="not(@paren) or @paren='both' or @paren='initial'">
            <xsl:text>(</xsl:text>
        </xsl:if>
        <xsl:variable name="works" select="//refWork[../@name=$refer/../@name and @id=//citation/@ref]"/>
        <xsl:variable name="date">
            <xsl:variable name="sCiteDate" select="$refer/refDate/@citedate"/>
            <xsl:choose>
                <xsl:when test="string-length($sCiteDate) &gt; 0">
                    <xsl:value-of select="$sCiteDate"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$refer/refDate"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="@author='yes' and not(not(@paren) or @paren='both' or @paren='initial')">
            <xsl:choose>
                <xsl:when test="string-length($sTextBetweenAuthorAndDate) &gt; 0">
                    <!-- do nothing; it's already there -->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>&#x20;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:value-of select="$date"/>
        <xsl:if test="count($works[refDate=$date or refDate/@citedate=$date])>1">
            <xsl:apply-templates select="$refer" mode="dateLetter">
                <xsl:with-param name="date" select="$date"/>
            </xsl:apply-templates>
        </xsl:if>
        <xsl:variable name="sPage" select="normalize-space(@page)"/>
        <xsl:if test="string-length($sPage) &gt; 0">
            <xsl:variable name="sColon" select="$citationLayout/@replacecolonwith"/>
            <xsl:choose>
                <xsl:when test="string-length($sColon) &gt; 0">
                    <xsl:value-of select="$sColon"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>:</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="string-length($citationLayout/@textbeforepages) &gt; 0">
                <xsl:value-of select="$citationLayout/@textbeforepages"/>
            </xsl:if>
            <xsl:value-of select="$sPage"/>
        </xsl:if>
        <xsl:if test="not(@paren) or @paren='both' or @paren='final' or @paren='citationBoth'">
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputCitationPages
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
        OutputISO639-3CodeCase
    -->
    <xsl:template name="OutputISO639-3CodeCase">
        <xsl:param name="iso639-3codeItem"/>
        <xsl:choose>
            <xsl:when test="$iso639-3codeItem/@case='uppercase'">
                <xsl:value-of select="translate(.,'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="translate(.,'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputSectionNumberProper
    -->
    <xsl:template name="OutputSectionNumberProper">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="bAppendix"/>
        <xsl:param name="sContentsPeriod"/>
        <xsl:variable name="bUseNumber">
            <xsl:choose>
                <xsl:when test="name()='section1' and $bodyLayoutInfo/section1Layout/@showNumber='no'">N</xsl:when>
                <xsl:when test="name()='section2' and $bodyLayoutInfo/section2Layout/@showNumber='no'">N</xsl:when>
                <xsl:when test="name()='section3' and $bodyLayoutInfo/section3Layout/@showNumber='no'">N</xsl:when>
                <xsl:when test="name()='section4' and $bodyLayoutInfo/section4Layout/@showNumber='no'">N</xsl:when>
                <xsl:when test="name()='section5' and $bodyLayoutInfo/section5Layout/@showNumber='no'">N</xsl:when>
                <xsl:when test="name()='section6' and $bodyLayoutInfo/section6Layout/@showNumber='no'">N</xsl:when>
                <xsl:otherwise>Y</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$bUseNumber='Y'">
            <xsl:call-template name="HandleSectionNumberOutput">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                <xsl:with-param name="bAppendix" select="$bAppendix"/>
                <xsl:with-param name="sContentsPeriod" select="$sContentsPeriod"/>
            </xsl:call-template>
        </xsl:if>
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
        <xsl:variable name="followingSiblings" select="following-sibling::*[name()!='comment']"/>
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
        <xsl:for-each select="$children[name()!='iso639-3code']">
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
        <xsl:if test="name()='dissertation' or name()='thesis'">
            <xsl:text>  You will also need a </xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>LabelItem in the pattern.</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--  
        ReportPatternForCollCitation
    -->
    <xsl:template name="ReportPatternForCollCitation">
        <xsl:param name="collCitation"/>
        <xsl:variable name="followingSiblings" select="following-sibling::*"/>
        <xsl:variable name="children" select="./*"/>
        <xsl:text>  It is a collection pattern that contains these elements: refTitle</xsl:text>
        <xsl:if test="../authorRole">
            <xsl:text>, collEd</xsl:text>
        </xsl:if>
        <xsl:if test="../refTitle">
            <xsl:text>, collTitle</xsl:text>
        </xsl:if>
        <xsl:if test="edition">
            <xsl:text>, edition</xsl:text>
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
        <xsl:if test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes' or ../iso639-3code and ancestor-or-self::refWork/@showiso639-3codes='yes'">
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
        <xsl:if test="../iso639-3code and $lingPaper/@showiso639-3codeininterlinear='yes' or ../iso639-3code and ancestor-or-self::refWork/@showiso639-3codes='yes'">
            <xsl:text>, iso639-3code</xsl:text>
        </xsl:if>
        <xsl:text>.</xsl:text>
    </xsl:template>
    <!--  
        TrySectionRef
    -->
    <xsl:template name="TrySectionRef">
        <xsl:param name="section"/>
        <xsl:param name="sectionLayoutInfo"/>
        <xsl:choose>
            <xsl:when test="$sectionLayoutInfo/@ignore!='yes'">
                <xsl:value-of select="$section/@id"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- recurse on the section's parent -->
                <xsl:call-template name="GetSectionRefToUse">
                    <xsl:with-param name="section" select="$section/parent::*"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
