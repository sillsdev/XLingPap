<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:saxon="http://icl.com/saxon" exclude-result-prefixes="fo rx xfc saxon ">
    <xsl:output method="xml" version="1.0" encoding="utf-8" indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
    <!-- ===========================================================
      Parameterized Variables
      =========================================================== -->
    <xsl:param name="sFileName">MyFileName</xsl:param>
    <xsl:variable name="pageLayoutInfo" select="//publisherStyleSheet/pageLayout"/>
    <xsl:variable name="contentLayoutInfo" select="//publisherStyleSheet/contentLayout"/>
    <xsl:variable name="iMagnificationFactor">
        <xsl:variable name="sAdjustedFactor" select="normalize-space($contentLayoutInfo/magnificationFactor)"/>
        <xsl:choose>
            <xsl:when test="string-length($sAdjustedFactor) &gt; 0 and $sAdjustedFactor!='1' and number($sAdjustedFactor)!='NaN'">
                <xsl:value-of select="$sAdjustedFactor"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sPageWidth" select="string($pageLayoutInfo/pageWidth)"/>
    <xsl:variable name="sPageHeight" select="string($pageLayoutInfo/pageHeight)"/>
    <xsl:variable name="sPageTopMargin" select="string($pageLayoutInfo/pageTopMargin)"/>
    <xsl:variable name="sPageBottomMargin" select="string($pageLayoutInfo/pageBottomMargin)"/>
    <xsl:variable name="sPageInsideMargin" select="string($pageLayoutInfo/pageInsideMargin)"/>
    <xsl:variable name="sPageOutsideMargin" select="string($pageLayoutInfo/pageOutsideMargin)"/>
    <xsl:variable name="sHeaderMargin" select="string($pageLayoutInfo/headerMargin)"/>
    <xsl:variable name="sFooterMargin" select="string($pageLayoutInfo/footerMargin)"/>
    <xsl:variable name="sParagraphIndent" select="string($pageLayoutInfo/paragraphIndent)"/>
    <xsl:variable name="sBlockQuoteIndent" select="string($pageLayoutInfo/blockQuoteIndent)"/>
    <xsl:variable name="sDefaultFontFamily" select="string($pageLayoutInfo/defaultFontFamily)"/>
    <xsl:variable name="sBasicPointSize" select="string($pageLayoutInfo/basicPointSize * $iMagnificationFactor)"/>
    <xsl:variable name="sFootnotePointSize" select="string($pageLayoutInfo/footnotePointSize * $iMagnificationFactor)"/>
    <xsl:variable name="frontMatterLayoutInfo" select="//publisherStyleSheet/frontMatterLayout"/>
    <xsl:variable name="bodyLayoutInfo" select="//publisherStyleSheet/bodyLayout"/>
    <xsl:variable name="backMatterLayoutInfo" select="//publisherStyleSheet/backMatterLayout"/>
    <xsl:variable name="iAffiliationLayouts" select="count($frontMatterLayoutInfo/affiliationLayout)"/>
    <xsl:variable name="iEmailAddressLayouts" select="count($frontMatterLayoutInfo/emailAddressLayout)"/>
    <xsl:variable name="iAuthorLayouts" select="count($frontMatterLayoutInfo/authorLayout)"/>
    <xsl:variable name="lineSpacing" select="$pageLayoutInfo/lineSpacing"/>
    <xsl:variable name="sLineSpacing" select="$lineSpacing/@linespacing"/>
    <xsl:variable name="sSinglespacingLineHeight">100%</xsl:variable>
    <xsl:variable name="nLevel">
        <xsl:choose>
            <xsl:when test="$contents/@showLevel">
                <xsl:value-of select="number($contents/@showLevel)"/>
            </xsl:when>
            <xsl:otherwise>3</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sSection1PointSize" select="'12'"/>
    <xsl:variable name="sSection2PointSize" select="'10'"/>
    <xsl:variable name="sSection3PointSize" select="'10'"/>
    <xsl:variable name="sSection4PointSize" select="'10'"/>
    <xsl:variable name="sSection5PointSize" select="'10'"/>
    <xsl:variable name="sSection6PointSize" select="'10'"/>
    <xsl:variable name="sBackMatterItemTitlePointSize" select="'12'"/>
    <xsl:variable name="sLinkColor" select="$pageLayoutInfo/linkLayout/@color"/>
    <xsl:variable name="sLinkTextDecoration" select="$pageLayoutInfo/linkLayout/@decoration"/>
    <xsl:variable name="bDoDebug" select="'n'"/>
    <!-- need a better solution for the following -->
    <xsl:variable name="sVernacularFontFamily" select="'Arial Unicode MS'"/>
    <!--
        sInterlinearSourceStyle:
        The default is AfterFirstLine (immediately after the last item in the first line)
        The other possibilities are AfterFree (immediately after the free translation, on the same line)
        and UnderFree (on the line immediately after the free translation)
    -->
    <xsl:variable name="sInterlinearSourceStyle" select="$contentLayoutInfo/interlinearSourceStyle/@interlinearsourcestyle"/>
    <xsl:variable name="styleSheetFigureLabelLayout" select="$contentLayoutInfo/figureLayout/figureLabelLayout"/>
    <xsl:variable name="styleSheetFigureNumberLayout" select="$contentLayoutInfo/figureLayout/figureNumberLayout"/>
    <xsl:variable name="styleSheetFigureCaptionLayout" select="$contentLayoutInfo/figureLayout/figureCaptionLayout"/>
    <xsl:variable name="sSpaceBetweenFigureAndCaption" select="normalize-space($contentLayoutInfo/figureLayout/@spaceBetweenFigureAndCaption)"/>
    <xsl:variable name="styleSheetTableNumberedLabelLayout" select="$contentLayoutInfo/tablenumberedLayout/tablenumberedLabelLayout"/>
    <xsl:variable name="styleSheetTableNumberedNumberLayout" select="$contentLayoutInfo/tablenumberedLayout/tablenumberedNumberLayout"/>
    <xsl:variable name="styleSheetTableNumberedCaptionLayout" select="$contentLayoutInfo/tablenumberedLayout/tablenumberedCaptionLayout"/>
    <xsl:variable name="sSpaceBetweenTableAndCaption" select="normalize-space($contentLayoutInfo/tablenumberedLayout/@spaceBetweenTableAndCaption)"/>
    <!-- ===========================================================
      Variables
      =========================================================== -->
    <xsl:variable name="contents" select="//contents"/>
    <xsl:variable name="references" select="//references"/>
    <xsl:variable name="sLdquo">&#8220;</xsl:variable>
    <xsl:variable name="sRdquo">&#8221;</xsl:variable>
    <xsl:variable name="iExampleCount" select="count(//example)"/>
    <xsl:variable name="iNumberWidth">
        <xsl:choose>
            <xsl:when test="$sFileName='XEP'">
                <!-- units are ems so the font and font size can be taken into account -->
                <xsl:text>2.75</xsl:text>
            </xsl:when>
            <xsl:when test="$sFileName='XFC'">
                <!--  units are inches because "XFC is not a renderer. It has a limited set of font metrics and therefore handles 'em' units in a very approximate way."
                    (email of August 10, 2007 from Jean-Yves Belmonte of XMLmind)-->
                <xsl:text>0.375</xsl:text>
            </xsl:when>
            <!--  if we can ever get FOP to do something reasonable for examples and interlinear, we'll add a 'when' clause here -->
        </xsl:choose>
        <!-- Originally thought we should vary the width depending on number of examples.  See below.  But that means
    as soon as one adds the 10th example or the 100th example, then all of a sudden the width available for the
    content of the example will change.  Just using a size for three digits. 
        <xsl:choose>
            <xsl:when test="$iExampleCount &lt; 10">1.5</xsl:when>
            <xsl:when test="$iExampleCount &lt; 100">2.25</xsl:when>
            <xsl:otherwise>3</xsl:otherwise>
        </xsl:choose>
        -->
    </xsl:variable>
    <!-- following used to calculate width of an example table.  NB: we assume all units will be the same -->
    <xsl:variable name="iPageWidth">
        <xsl:value-of select="number(substring($sPageWidth,1,string-length($sPageWidth) - 2))"/>
    </xsl:variable>
    <xsl:variable name="iPageInsideMargin">
        <xsl:value-of select="number(substring($sPageInsideMargin,1,string-length($sPageInsideMargin) - 2))"/>
    </xsl:variable>
    <xsl:variable name="iPageOutsideMargin">
        <xsl:value-of select="number(substring($sPageOutsideMargin,1,string-length($sPageOutsideMargin) - 2))"/>
    </xsl:variable>
    <xsl:variable name="iIndent">
        <xsl:value-of select="number(substring($sBlockQuoteIndent,1,string-length($sBlockQuoteIndent) - 2))"/>
    </xsl:variable>
    <xsl:variable name="iExampleWidth">
        <xsl:value-of select="number($iPageWidth - 2 * $iIndent - $iPageOutsideMargin - $iPageInsideMargin)"/>
    </xsl:variable>
    <xsl:variable name="sExampleWidth">
        <xsl:value-of select="$iExampleWidth"/>
        <xsl:value-of select="substring($sPageWidth,string-length($sPageWidth) - 1)"/>
    </xsl:variable>
    <xsl:variable name="iAbbreviationCount" select="count(//abbrRef)"/>
    <xsl:variable name="bEndnoteRefIsDirectLinkToEndnote" select="'Y'"/>
    <!-- ===========================================================
        Attribute sets
        =========================================================== -->
    <xsl:attribute-set name="ExampleCell">
        <xsl:attribute name="style">padding-end:.5em;</xsl:attribute>
    </xsl:attribute-set>
    <!-- ===========================================================
      MAIN BODY
      =========================================================== -->
    <xsl:template match="//lingPaper">
        <xsl:variable name="xhtmllang">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space($lingPaper/@xml:lang)) &gt; 0">
                    <xsl:value-of select="normalize-space($lingPaper/@xml:lang)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>en</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{$xhtmllang}" lang="{$xhtmllang}">
            <xsl:comment> generated by XLingPapPublisherStylesheetXHTML.xsl Version <xsl:value-of select="$sVersion"/>&#x20;</xsl:comment>
            <head>
                <title>
                    <xsl:value-of select="//title"/>
                </title>
                <link rel="stylesheet" href="{$sFileName}.css" type="text/css"/>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                <!--                <meta name="{$sFileName}" http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    If we decide to get serious about meta data, look at http://dublincore.org/documents/dc-html/ and follow what it says.
-->
                <style type="text/css">
                    <xsl:text>.interblock { display: -moz-inline-box; display:inline-block; vertical-align: top; } </xsl:text>
                </style>
            </head>
            <body>
                <xsl:if test="$sLineSpacing and $sLineSpacing!='single'">
                    <xsl:attribute name="style">
                        <xsl:text>line-height:</xsl:text>
                        <xsl:choose>
                            <xsl:when test="$sLineSpacing='double'">
                                <xsl:text>200</xsl:text>
                            </xsl:when>
                            <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                                <xsl:text>150</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>%;</xsl:text>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@showbookmarks!='no'">
                    <xsl:call-template name="DoBookmarksForPaper"/>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$bIsBook">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="frontMatter"/>
                        <xsl:apply-templates select="//section1[not(parent::appendix)]"/>
                        <xsl:apply-templates select="//backMatter"/>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="DoBookmarksForPaper">
        <xsl:for-each select="$contents">
            <!--  Does Prince have anything like this??     
    <fo:bookmark-tree>
                <xsl:call-template name="DoFrontMatterBookmarksPerLayout"/>
                <!-\- chapterBeforePart -\->
                <!-\-                <xsl:apply-templates select="$lingPaper/chapterBeforePart" mode="bookmarks"/>-\->
                <!-\- part -\->
                <xsl:apply-templates select="$lingPaper/part" mode="bookmarks"/>
                <!-\-                 chapter, no parts -\->
                <xsl:apply-templates select="$lingPaper/chapter" mode="bookmarks"/>
                <!-\- section, no chapters -\->
                <xsl:apply-templates select="$lingPaper/section1" mode="bookmarks"/>
                <xsl:call-template name="DoBackMatterBookmarksPerLayout"/>
            </fo:bookmark-tree>
-->
        </xsl:for-each>
    </xsl:template>
    <!-- ===========================================================
      FRONTMATTER
      =========================================================== -->
    <xsl:template match="frontMatter">
        <xsl:variable name="frontMatter" select="."/>
        <xsl:choose>
            <xsl:when test="$bIsBook">
                <xsl:call-template name="DoBookFrontMatterFirstStuffPerLayout">
                    <xsl:with-param name="frontMatter" select="."/>
                </xsl:call-template>
                <xsl:call-template name="DoBookFrontMatterPagedStuffPerLayout">
                    <xsl:with-param name="frontMatter" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoFrontMatterPerLayout">
                    <xsl:with-param name="frontMatter" select="."/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      title
      -->
    <xsl:template match="title">
        <xsl:if test="$bIsBook">
            <p class="title">
                <xsl:call-template name="DoTitleFormatInfo">
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
                    <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
                </xsl:call-template>
                <xsl:apply-templates/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
                </xsl:call-template>
            </p>
            <xsl:apply-templates select="following-sibling::subtitle"/>
        </xsl:if>
        <p class="title">
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
                <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
            </xsl:call-template>
        </p>
    </xsl:template>
    <xsl:template match="title" mode="contentOnly">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      subtitle
      -->
    <xsl:template match="subtitle">
        <p>
            <xsl:attribute name="class">
                <xsl:call-template name="CreateSubtitleCSSName"/>
            </xsl:attribute>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/subtitleLayout"/>
                <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/subtitleLayout"/>
            </xsl:call-template>
        </p>
    </xsl:template>
    <!--
      author
      -->
    <xsl:template match="author">
        <xsl:param name="authorLayoutToUse"/>
        <xsl:if test="string-length(.) &gt; 0">
            <p class="author">
                <xsl:call-template name="DoFrontMatterFormatInfo">
                    <xsl:with-param name="layoutInfo" select="$authorLayoutToUse"/>
                </xsl:call-template>
                <xsl:apply-templates/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$authorLayoutToUse"/>
                </xsl:call-template>
            </p>
        </xsl:if>
    </xsl:template>
    <xsl:template match="author" mode="contentOnly">
        <xsl:choose>
            <xsl:when test="preceding-sibling::author and not(following-sibling::author)">
                <xsl:text> and </xsl:text>
            </xsl:when>
            <xsl:when test="preceding-sibling::author">
                <xsl:text>, </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      affiliation
      -->
    <xsl:template match="affiliation">
        <xsl:param name="affiliationLayoutToUse"/>
        <p class="affiliation">
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$affiliationLayoutToUse"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$affiliationLayoutToUse"/>
            </xsl:call-template>
        </p>
    </xsl:template>
    <!--
        emailAddress
    -->
    <xsl:template match="emailAddress">
        <xsl:param name="emailAddressLayoutToUse"/>
        <p class="emailAddress">
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$emailAddressLayoutToUse"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$emailAddressLayoutToUse"/>
            </xsl:call-template>
        </p>
    </xsl:template>
    <!--
        date
    -->
    <xsl:template match="date">
        <p class="date">
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/dateLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/dateLayout"/>
            </xsl:call-template>
        </p>
    </xsl:template>
    <!--
        presentedAt
    -->
    <xsl:template match="presentedAt">
        <p class="presentedAt">
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/presentedAtLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/presentedAtLayout"/>
            </xsl:call-template>
        </p>
    </xsl:template>
    <!--
      version
      -->
    <xsl:template match="version">
        <p class="version">
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/versionLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/versionLayout"/>
            </xsl:call-template>
        </p>
    </xsl:template>
    <!--
        publishingBlurb
    -->
    <xsl:template match="publishingBlurb">
        <p class="publishingBlurb">
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/publishingBlurbLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/publishingBlurbLayout"/>
            </xsl:call-template>
        </p>
    </xsl:template>
    <!--
      contents (for book)
      -->
    <xsl:template match="contents" mode="book">
        <xsl:variable name="layoutInfo" select="$frontMatterLayoutInfo/headerFooterPageStyles"/>
        <xsl:call-template name="DoContents">
            <xsl:with-param name="bIsBook" select="'Y'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      contents (for paper)
      -->
    <xsl:template match="contents" mode="paper">
        <xsl:call-template name="DoContents">
            <xsl:with-param name="bIsBook" select="'N'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      abstract (book)
      -->
    <xsl:template match="abstract" mode="book">
        <xsl:call-template name="DoFrontMatterItemNewPage">
            <xsl:with-param name="sHeaderTitleClassName" select="'abstract-title'"/>
            <xsl:with-param name="id" select="'rXLingPapAbstract'"/>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputAbstractLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/abstractLayout"/>
            <xsl:with-param name="sMarkerClassName" select="'abstract-title'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      abstract  (paper)
      -->
    <xsl:template match="abstract" mode="paper">
        <xsl:variable name="abstractLayoutInfo" select="$frontMatterLayoutInfo/abstractLayout"/>
        <xsl:variable name="abstractTextLayoutInfo" select="$frontMatterLayoutInfo/abstractTextFontInfo"/>
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id">rXLingPapAbstract</xsl:with-param>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputAbstractLabel"/>
            </xsl:with-param>
            <xsl:with-param name="bIsBook" select="'N'"/>
            <xsl:with-param name="layoutInfo" select="$abstractLayoutInfo"/>
            <xsl:with-param name="sMarkerClassName" select="'abstract-title'"/>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="$frontMatterLayoutInfo/abstractTextFontInfo">
                <div class="abstractText">
                    <xsl:attribute name="style">
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="$abstractTextLayoutInfo"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      aknowledgements (frontmatter - book)
   -->
    <xsl:template match="acknowledgements" mode="frontmatter-book">
        <xsl:call-template name="DoFrontMatterItemNewPage">
            <xsl:with-param name="sHeaderTitleClassName" select="'acknowledgements-title'"/>
            <xsl:with-param name="id">
                <xsl:value-of select="$sAcknowledgementsID"/>
            </xsl:with-param>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputAcknowledgementsLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/acknowledgementsLayout"/>
            <xsl:with-param name="sMarkerClassName" select="'acknowledgements-title'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      aknowledgements (backmatter-book)
   -->
    <xsl:template match="acknowledgements" mode="backmatter-book">
        <xsl:call-template name="DoBackMatterItemNewPage">
            <xsl:with-param name="sHeaderTitleClassName" select="'acknowledgements-title'"/>
            <xsl:with-param name="id">
                <xsl:value-of select="$sAcknowledgementsID"/>
            </xsl:with-param>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputAcknowledgementsLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/acknowledgementsLayout"/>
            <xsl:with-param name="sMarkerClassName" select="'acknowledgements-title'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        acknowledgements (paper)
    -->
    <xsl:template match="acknowledgements" mode="paper">
        <xsl:choose>
            <xsl:when test="$frontMatterLayoutInfo/acknowledgementsLayout/@showAsFootnoteAtEndOfAbstract='yes'">
                <!-- do nothing; the content of the acknowledgements are to appear in a footnote at the end of the abstract -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::frontMatter">
                        <xsl:call-template name="OutputFrontOrBackMatterTitle">
                            <xsl:with-param name="id">
                                <xsl:value-of select="$sAcknowledgementsID"/>
                            </xsl:with-param>
                            <xsl:with-param name="sTitle">
                                <xsl:call-template name="OutputAcknowledgementsLabel"/>
                            </xsl:with-param>
                            <xsl:with-param name="bIsBook" select="'N'"/>
                            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/acknowledgementsLayout"/>
                            <xsl:with-param name="sMarkerClassName" select="'acknowledgements-title'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="OutputFrontOrBackMatterTitle">
                            <xsl:with-param name="id">
                                <xsl:value-of select="$sAcknowledgementsID"/>
                            </xsl:with-param>
                            <xsl:with-param name="sTitle">
                                <xsl:call-template name="OutputAcknowledgementsLabel"/>
                            </xsl:with-param>
                            <xsl:with-param name="bIsBook" select="'N'"/>
                            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/acknowledgementsLayout"/>
                            <xsl:with-param name="sMarkerClassName" select="'acknowledgements-title'"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      preface (book)
   -->
    <xsl:template match="preface" mode="book">
        <xsl:variable name="iPos" select="count(preceding-sibling::preface) + 1"/>
        <xsl:call-template name="DoFrontMatterItemNewPage">
            <xsl:with-param name="sHeaderTitleClassName" select="'preface-title'"/>
            <xsl:with-param name="id" select="concat('rXLingPapPreface',$iPos)"/>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputPrefaceLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/prefaceLayout"/>
            <xsl:with-param name="sMarkerClassName" select="'preface-title'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        preface (paper)
    -->
    <xsl:template match="preface" mode="paper">
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id" select="concat('rXLingPapPreface',position())"/>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputPrefaceLabel"/>
            </xsl:with-param>
            <xsl:with-param name="bIsBook" select="'N'"/>
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/prefaceLayout"/>
            <xsl:with-param name="sMarkerClassName" select="'preface-title'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- ===========================================================
      PARTS, CHAPTERS, SECTIONS, and APPENDICES
      =========================================================== -->
    <!--
      Part
      -->
    <xsl:template match="part">
        <div id="{@id}" class="numberpart">
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/numberLayout"/>
                <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
            </xsl:call-template>
            <xsl:call-template name="OutputChapTitle">
                <xsl:with-param name="sTitle">
                    <xsl:call-template name="OutputPartLabel"/>
                    <xsl:text>&#x20;</xsl:text>
                    <xsl:apply-templates select="." mode="numberPart"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/numberLayout"/>
            </xsl:call-template>
        </div>
        <div class="partTitle">
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/partTitleLayout"/>
                <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
            </xsl:call-template>
            <xsl:apply-templates select="secTitle"/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/partTitleLayout"/>
            </xsl:call-template>
        </div>
        <xsl:apply-templates select="child::node()[name()!='secTitle' and name()!='chapter']"/>
        <xsl:apply-templates select="child::node()[name()='chapter']"/>
    </xsl:template>
    <!--
      Chapter or appendix (in book with chapters)
      -->
    <xsl:template match="chapter | appendix[//chapter]  | chapterBeforePart">
        <xsl:choose>
            <xsl:when test="name(.)='appendix'">
                <xsl:call-template name="OutputChapterStaticContentForBackMatter"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputChapterStaticContent">
                    <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/headerFooterPageStyles"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <div id="{@id}">
            <xsl:choose>
                <xsl:when test="name(.)='appendix'">
                    <xsl:attribute name="class">numberappendix</xsl:attribute>
                    <xsl:call-template name="DoTitleFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendixLayout/numberLayout"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">numberchapter</xsl:attribute>
                    <xsl:call-template name="DoTitleFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/numberLayout"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="OutputChapTitle">
                <xsl:with-param name="sTitle">
                    <xsl:call-template name="OutputChapterNumber"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="name(.)='appendix'">
                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendixLayout/numberLayout"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/numberLayout"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </div>
        <div class="chapterTitle">
            <xsl:choose>
                <xsl:when test="name(.)='appendix'">
                    <xsl:call-template name="DoTitleFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="DoTitleFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="secTitle"/>
            <xsl:choose>
                <xsl:when test="name(.)='appendix'">
                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </div>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <!--
      Sections
      -->
    <xsl:template match="section1">
        <xsl:call-template name="DoSection">
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/section1Layout"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="section2">
        <xsl:call-template name="DoSection">
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/section2Layout"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="section3">
        <xsl:call-template name="DoSection">
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/section3Layout"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="section4">
        <xsl:call-template name="DoSection">
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/section4Layout"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="section5">
        <xsl:call-template name="DoSection">
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/section5Layout"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="section6">
        <xsl:call-template name="DoSection">
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/section6Layout"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      Appendix
      -->
    <xsl:template match="appendix[not(//chapter)]">
        <xsl:variable name="appLayout" select="$backMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
        <div>
            <!-- put title in marker so it can show up in running header -->
            <!--            <fo:marker marker-class-name="section-title">
                <xsl:call-template name="DoSecTitleRunningHeader"/>
            </fo:marker>
-->
        </div>
        <div id="{@id}" class="appendixTitle">
            <xsl:call-template name="DoType">
                <xsl:with-param name="type" select="@type"/>
            </xsl:call-template>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$appLayout"/>
            </xsl:call-template>
            <xsl:if test="$appLayout/@showletter!='no'">
                <xsl:apply-templates select="." mode="numberAppendix"/>
                <xsl:value-of select="$appLayout/@textafterletter"/>
                <!--         <xsl:text disable-output-escaping="yes">.&#x20;</xsl:text>-->
            </xsl:if>
            <xsl:apply-templates select="secTitle"/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$appLayout"/>
            </xsl:call-template>
        </div>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <!--
      secTitle
      -->
    <xsl:template match="secTitle" mode="InMarker">
        <xsl:apply-templates select="child::node()[name()!='endnote']"/>
    </xsl:template>
    <xsl:template match="secTitle">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      sectionRef
      -->
    <xsl:template match="sectionRef">
        <xsl:call-template name="OutputAnyTextBeforeSectionRef"/>
        <span>
            <!-- adjust reference to a section that is actually present per the style sheet -->
            <xsl:variable name="secRefToUse">
                <xsl:call-template name="GetSectionRefToUse">
                    <xsl:with-param name="section" select="id(@sec)"/>
                    <xsl:with-param name="bodyLayoutInfo" select="$bodyLayoutInfo"/>
                </xsl:call-template>
            </xsl:variable>
            <a>
                <xsl:attribute name="href">
                    <xsl:text>#</xsl:text>
                    <xsl:value-of select="$secRefToUse"/>
                </xsl:attribute>
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/sectionRefLinkLayout"/>
                </xsl:call-template>
                <span>
                    <xsl:choose>
                        <xsl:when test="@showTitle = 'short' or @showTitle='full'">
                            <xsl:if test="$contentLayoutInfo/sectionRefTitleLayout">
                                <xsl:attribute name="class">sectionRefTitle</xsl:attribute>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$contentLayoutInfo/sectionRefLayout">
                                <xsl:attribute name="class">sectionRef</xsl:attribute>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:call-template name="DoSectionRef">
                        <xsl:with-param name="secRefToUse" select="$secRefToUse"/>
                    </xsl:call-template>
                </span>
            </a>
        </span>
    </xsl:template>
    <!--
      appendixRef
      -->
    <xsl:template match="appendixRef">
        <a href="#{@app}">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/appendixRefLinkLayout"/>
            </xsl:call-template>
            <xsl:attribute name="style">
                <xsl:choose>
                    <xsl:when test="@showTitle = 'short' or @showTitle='full'">
                        <xsl:if test="$contentLayoutInfo/sectionRefTitleLayout">
                            <xsl:call-template name="OutputFontAttributes">
                                <xsl:with-param name="language" select="$contentLayoutInfo/sectionRefTitleLayout"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$contentLayoutInfo/sectionRefLayout">
                            <xsl:call-template name="OutputFontAttributes">
                                <xsl:with-param name="language" select="$contentLayoutInfo/sectionRefLayout"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:call-template name="DoAppendixRef"/>
        </a>
    </xsl:template>
    <!--
      genericRef
      -->
    <xsl:template match="genericRef">
        <a href="#{@gref}">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/genericRefLinkLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <!--
      genericTarget
   -->
    <xsl:template match="genericTarget">
        <span id="{@id}"/>
    </xsl:template>
    <!--
      link
      -->
    <xsl:template match="link">
        <a href="url({@href})">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/linkLinkLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <!-- ===========================================================
      PARAGRAPH
      =========================================================== -->
    <xsl:template match="p | pc" mode="endnote-content">
        <span baseline-shift="super">
            <xsl:attribute name="font-size">
                <xsl:value-of select="$sFootnotePointSize - 2"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:for-each select="parent::endnote">
                <xsl:choose>
                    <xsl:when test="ancestor::author">
                        <xsl:variable name="iAuthorPosition" select="count(ancestor::author/preceding-sibling::author[endnote]) + 1"/>
                        <xsl:call-template name="OutputAuthorFootnoteSymbol">
                            <xsl:with-param name="iAuthorPosition" select="$iAuthorPosition"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$bIsBook">
                        <xsl:number level="any" count="endnote[not(ancestor::author)] | endnoteRef[not(ancestor::endnote)]" from="chapter | appendix | glossary | acknowledgements | preface | abstract" format="1"/>
                        <!--                        <xsl:number level="any" count="endnote[not(ancestor::author)] | endnoteRef[not(ancestor::endnote)]" from="chapter"/>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:number level="any" count="endnote[not(ancestor::author)] | endnoteRef[not(ancestor::endnote)]" format="1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </span>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="p | pc" mode="contentOnly">
        <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@xsl-foSpecial"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="p | pc">
        <p>
            <!--            <xsl:if test="@pagecontrol='keepWithNext'">
                <xsl:attribute name="keep-with-next.within-page">1</xsl:attribute>
            </xsl:if>
            -->
            <xsl:attribute name="style">
                <xsl:call-template name="OutputTypeAttributes">
                    <xsl:with-param name="sList" select="@cssSpecial"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="count(preceding-sibling::*[name()!='secTitle'])=0">
                    <!-- is the first item -->
                    <xsl:choose>
                        <xsl:when test="parent::section1 and $bodyLayoutInfo/section1Layout/@firstParagraphHasIndent='no'">
                            <!-- do nothing to force no indent -->
                        </xsl:when>
                        <xsl:when test="parent::section2 and $bodyLayoutInfo/section2Layout/@firstParagraphHasIndent='no'">
                            <!-- do nothing to force no indent -->
                        </xsl:when>
                        <xsl:when test="parent::section3 and $bodyLayoutInfo/section3Layout/@firstParagraphHasIndent='no'">
                            <!-- do nothing to force no indent -->
                        </xsl:when>
                        <xsl:when test="parent::section4 and $bodyLayoutInfo/section4Layout/@firstParagraphHasIndent='no'">
                            <!-- do nothing to force no indent -->
                        </xsl:when>
                        <xsl:when test="parent::section5 and $bodyLayoutInfo/section5Layout/@firstParagraphHasIndent='no'">
                            <!-- do nothing to force no indent -->
                        </xsl:when>
                        <xsl:when test="parent::section6 and $bodyLayoutInfo/section6Layout/@firstParagraphHasIndent='no'">
                            <!-- do nothing to force no indent -->
                        </xsl:when>
                        <xsl:when test="parent::blockquote and count(preceding-sibling::*)=0">
                            <!-- do nothing to force no indent -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">
                                <xsl:text>paragraph_indent</xsl:text>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="name(.)='p' and not(parent::blockquote and not(preceding-sibling::*))">
                        <xsl:attribute name="class">
                            <xsl:text>paragraph_indent</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
            <xsl:if test="parent::abstract and count(following-sibling::p)=0 and $frontMatterLayoutInfo/acknowledgementsLayout/@showAsFootnoteAtEndOfAbstract='yes'">
                <xsl:call-template name="OutputEndnoteNumber">
                    <xsl:with-param name="attr">
                        <xsl:value-of select="$sAcknowledgementsID"/>
                    </xsl:with-param>
                    <xsl:with-param name="sFootnoteNumberOverride" select="'*'"/>
                </xsl:call-template>
            </xsl:if>
        </p>
    </xsl:template>
    <!-- ===========================================================
        QUOTES
        =========================================================== -->
    <xsl:template match="q">
        <span>
            <xsl:value-of select="$sLdquo"/>
            <span>
                <xsl:attribute name="style">
                    <xsl:call-template name="DoType"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </span>
            <xsl:value-of select="$sRdquo"/>
        </span>
    </xsl:template>
    <xsl:template match="blockquote">
        <div class="blockquote">
            <xsl:attribute name="style">
                <!--  handled in CSS class                <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespaceblockquotes='yes'">
                    <xsl:call-template name="DoSinglespacing"/>
                </xsl:if>
-->
                <xsl:call-template name="OutputCssSpecial">
                    <xsl:with-param name="fDoStyleAttribute" select="'N'"/>
                </xsl:call-template>
                <!--     handled by CSS
                    <xsl:attribute name="start-indent">
                    <xsl:value-of select="$sBlockQuoteIndent"/>
                    </xsl:attribute>
                    <xsl:attribute name="end-indent">
                    <xsl:value-of select="$sBlockQuoteIndent"/>
                    </xsl:attribute>
                    <xsl:attribute name="font-size">
                    <xsl:value-of select="$sBasicPointSize - 1"/>pt</xsl:attribute>
                    <xsl:attribute name="space-before">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                    <xsl:attribute name="space-after">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                -->
                <xsl:call-template name="DoType"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <!-- ===========================================================
        PROSE TEXT
        =========================================================== -->
    <xsl:template match="prose-text">
        <div class="blockquote language{@lang}">
            <xsl:attribute name="style">
                <xsl:call-template name="DoType"/>
                <xsl:call-template name="OutputTypeAttributes">
                    <xsl:with-param name="sList" select="@xsl-foSpecial"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <!-- ===========================================================
        EXAMPLES
        =========================================================== -->
    <xsl:template match="example">
        <div>
            <xsl:if test="@num">
                <xsl:attribute name="id">
                    <xsl:value-of select="@num"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="DoExample">
                <xsl:with-param name="bUseClass" select="'Y'"/>
            </xsl:call-template>
        </div>
    </xsl:template>
    <!--
        interlinearRef
    -->
    <xsl:template match="interlinearRef">
        <xsl:variable name="originalContext" select="."/>
        <xsl:for-each select="key('InterlinearReferenceID',@textref)[1]">
            <xsl:apply-templates>
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    <!--
        interlinearRef with endnote(s) for backmatter
    -->
    <xsl:template match="interlinearRef" mode="backMatter">
        <xsl:variable name="originalContext" select="."/>
        <xsl:for-each select="key('InterlinearReferenceID',@textref)[1]">
            <xsl:apply-templates select="descendant::endnote" mode="backMatter">
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    <!--
        interlinearRefCitation
    -->
    <xsl:template match="interlinearRefCitation[@showTitleOnly='short' or @showTitleOnly='full']">
        <xsl:variable name="interlinearSourceStyleLayout" select="$contentLayoutInfo/interlinearSourceStyle"/>
        <span>
            <a>
                <xsl:call-template name="DoInterlinearTextReferenceLink">
                    <xsl:with-param name="sRef" select="@textref"/>
                    <xsl:with-param name="sExtension" select="'htm'"/>
                </xsl:call-template>
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/interlinearRefLinkLayout"/>
                </xsl:call-template>
                <xsl:attribute name="style">
                    <xsl:if test="$contentLayoutInfo/interlinearRefCitationTitleLayout">
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="$contentLayoutInfo/interlinearRefCitationTitleLayout"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:attribute>
                <!-- we do not show any brackets when these options are set -->
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/interlinearRefCitationTitleLayout"/>
                </xsl:call-template>
                <xsl:call-template name="DoInterlinearRefCitationShowTitleOnly"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/interlinearRefCitationTitleLayout"/>
                </xsl:call-template>
                <!-- we do not show any brackets when these options are set -->
            </a>
        </span>
    </xsl:template>
    <xsl:template match="interlinearRefCitation">
        <xsl:variable name="interlinearSourceStyleLayout" select="$contentLayoutInfo/interlinearSourceStyle"/>
        <span>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$interlinearSourceStyleLayout"/>
            </xsl:call-template>
            <xsl:if test="not(@bracket) or @bracket='both' or @bracket='initial'">
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:variable name="interlinear" select="key('InterlinearReferenceID',@textref)"/>
            <xsl:choose>
                <xsl:when test="name($interlinear)='interlinear-text'">
                    <a>
                        <xsl:call-template name="DoInterlinearTextReferenceLink">
                            <xsl:with-param name="sRef" select="@textref"/>
                            <xsl:with-param name="sExtension" select="'htm'"/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="$interlinear/textInfo/shortTitle and string-length($interlinear/textInfo/shortTitle) &gt; 0">
                                <xsl:apply-templates select="$interlinear/textInfo/shortTitle/child::node()[name()!='endnote']"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$interlinear/textInfo/textTitle/child::node()[name()!='endnote']"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="DoInterlinearRefCitation">
                        <xsl:with-param name="sRef" select="@textref"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="not(@bracket) or @bracket='both' or @bracket='final'">
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
                </xsl:call-template>
            </xsl:if>
        </span>
    </xsl:template>
    <!--
        interlinearSource
    -->
    <xsl:template match="interlinearSource" mode="show">
        <xsl:variable name="interlinearSourceStyleLayout" select="$contentLayoutInfo/interlinearSourceStyle"/>
        <xsl:choose>
            <xsl:when test="$interlinearSourceStyleLayout/@interlinearsourcestyle='AfterFirstLine'">
                <span>
                    <xsl:call-template name="DoInterlinearSource">
                        <xsl:with-param name="interlinearSourceStyleLayout" select="$interlinearSourceStyleLayout"/>
                    </xsl:call-template>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <td>
                    <xsl:call-template name="DoInterlinearSource">
                        <xsl:with-param name="interlinearSourceStyleLayout" select="$interlinearSourceStyleLayout"/>
                    </xsl:call-template>
                </td>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      line
      -->
    <xsl:template match="line">
        <xsl:param name="originalContext"/>
        <tr>
            <xsl:call-template name="DoInterlinearLine">
                <xsl:with-param name="bUseClass" select="'Y'"/>
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
        </tr>
    </xsl:template>
    <xsl:template match="line" mode="NoTextRef">
        <tr>
            <xsl:call-template name="DoInterlinearLine">
                <xsl:with-param name="bUseClass" select="'Y'"/>
                <xsl:with-param name="mode" select="'NoTextRef'"/>
            </xsl:call-template>
        </tr>
    </xsl:template>
    <!--
        listDefinition
    -->
    <xsl:template match="listDefinition">
        <xsl:if test="count(preceding-sibling::listDefinition)=0">
            <xsl:call-template name="OutputList"/>
        </xsl:if>
    </xsl:template>
    <!--
      table
      -->
    <xsl:template match="table">
        <div>
            <xsl:attribute name="style">
                <xsl:call-template name="SetTableAlignCSS"/>
                <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacetables='yes'">
                    <xsl:call-template name="DoSinglespacing"/>
                </xsl:if>
                <xsl:call-template name="OutputCssSpecial">
                    <xsl:with-param name="fDoStyleAttribute" select="'N'"/>
                </xsl:call-template>
                <xsl:call-template name="DoType"/>
            </xsl:attribute>
            <xsl:call-template name="OutputTable"/>
        </div>
    </xsl:template>
    <!--
      exampleHeading
   -->
    <xsl:template match="exampleHeading">
        <table>
            <tbody>
                <tr>
                    <td>
                        <div>
                            <xsl:apply-templates/>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </xsl:template>
    <!--
      exampleRef
      -->
    <xsl:template match="exampleRef">
        <a>
            <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:choose>
                    <xsl:when test="@letter and name(id(@letter))!='example'">
                        <xsl:value-of select="@letter"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="@num">
                            <xsl:value-of select="@num"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/exampleRefLinkLayout"/>
            </xsl:call-template>
            <xsl:call-template name="DoExampleRefContent"/>
        </a>
    </xsl:template>
    <!--
        figure
    -->
    <xsl:template match="figure">
        <div>
            <xsl:call-template name="DoFigure"/>
        </div>
    </xsl:template>
    <!--
        figureRef
    -->
    <xsl:template match="figureRef">
        <xsl:call-template name="OutputAnyTextBeforeFigureRef"/>
        <a href="#{@figure}">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/figureRefLinkLayout"/>
            </xsl:call-template>
            <span>
                <xsl:attribute name="style">
                    <xsl:choose>
                        <xsl:when test="@showCaption = 'short' or @showCaption='full'">
                            <xsl:if test="$contentLayoutInfo/figureRefCaptionLayout">
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="$contentLayoutInfo/figureRefCaptionLayout"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$contentLayoutInfo/figureRefLayout">
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="$contentLayoutInfo/figureRefLayout"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:call-template name="DoFigureRef"/>
            </span>
        </a>
    </xsl:template>
    <!--
        listOfFiguresShownHere
    -->
    <xsl:template match="listOfFiguresShownHere">
        <xsl:for-each select="//figure">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink" select="@id"/>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputFigureLabelAndCaption">
                        <xsl:with-param name="bDoStyles" select="'N'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--
        tablenumbered
    -->
    <xsl:template match="tablenumbered">
        <xsl:call-template name="DoTableNumbered"/>
    </xsl:template>
    <!--
        tablenumberedRef
    -->
    <xsl:template match="tablenumberedRef">
        <xsl:call-template name="OutputAnyTextBeforeTablenumberedRef"/>
        <a href="#{@table}">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/tablenumberedRefLinkLayout"/>
            </xsl:call-template>
            <xsl:attribute name="style">
                <xsl:choose>
                    <xsl:when test="@showCaption = 'short' or @showCaption='full'">
                        <xsl:if test="$contentLayoutInfo/tablenumberedRefCaptionLayout">
                            <xsl:call-template name="OutputFontAttributes">
                                <xsl:with-param name="language" select="$contentLayoutInfo/tablenumberedRefCaptionLayout"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$contentLayoutInfo/tablenumberedRefLayout">
                            <xsl:call-template name="OutputFontAttributes">
                                <xsl:with-param name="language" select="$contentLayoutInfo/tablenumberedRefLayout"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:call-template name="DoTablenumberedRef"/>
        </a>
    </xsl:template>
    <!--
        listOfTablesShownHere
    -->
    <xsl:template match="listOfTablesShownHere">
        <xsl:for-each select="//tablenumbered">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink" select="@id"/>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputTableNumberedLabelAndCaption">
                        <xsl:with-param name="bDoStyles" select="'N'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!-- ===========================================================
      ENDNOTES and ENDNOTEREFS
      =========================================================== -->
    <!--
      endnotes
      -->
    <!--
      endnote in flow of text
      -->
    <!-- To consider if/when we make Prince work and it is possible to have footnotes   
    <xsl:template match="endnote">
        <xsl:choose>
            <xsl:when test="$backMatterLayoutInfo/useEndNotesLayout">
                <xsl:call-template name="DoFootnoteNumberInText"/>
            </xsl:when>
            <xsl:otherwise>
                <fo:footnote>
                    <xsl:call-template name="DoFootnoteNumberInText"/>
                    <fo:footnote-body>
                        <xsl:call-template name="DoFootnoteContent"/>
                    </fo:footnote-body>
                </fo:footnote>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
-->
    <!--
      endnoteRef
      -->
    <xsl:template match="endnoteRef">
        <xsl:choose>
            <xsl:when test="ancestor::endnote">
                <xsl:call-template name="DoEndnoteRefNumber"/>
            </xsl:when>
            <xsl:when test="@showNumberOnly='yes'">
                <xsl:call-template name="DoEndnoteRefNumber"/>
            </xsl:when>
            <xsl:otherwise>
                <span style="font-size:65%; vertical-align:super; color:black">
                    <xsl:call-template name="InsertCommaBetweenConsecutiveEndnotes"/>
                    <xsl:call-template name="DoEndnoteRefNumber"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        <!--<xsl:choose>
            <xsl:when test="ancestor::endnote">
                <!-\-             Browsers don't let us control this?
    <a href="#{@note}">
                    <xsl:call-template name="AddAnyLinkAttributes">
                        <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/endnoteRefLinkLayout"/>
                    </xsl:call-template>
-\->
                <xsl:call-template name="OutputEndnoteNumber">
                    <xsl:with-param name="attr" select="@note"/>
                    <xsl:with-param name="node" select="id(@note)"/>
                </xsl:call-template>
                <!-\-                </a>-\->
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputEndnoteNumber">
                    <xsl:with-param name="attr" select="@note"/>
                    <xsl:with-param name="node" select="id(@note)"/>
                </xsl:call-template>
                <!-\- For later when we handle book material and Prince
    <fo:footnote>
                    <xsl:variable name="sFootnoteNumber">
                        <xsl:choose>
                            <xsl:when test="$bIsBook">
                                <xsl:number level="any" count="endnote | endnoteRef" from="chapter"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:number level="any" count="endnote | endnoteRef[not(ancestor::endnote)]" format="1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <span baseline-shift="super" id="{@id}">
                        <xsl:attribute name="font-size">
                            <xsl:value-of select="$sFootnotePointSize - 2"/>
                            <xsl:text>pt</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="$sFootnoteNumber"/>
                    </span>
                    <fo:footnote-body>
                        <div text-align="left" text-indent="1em">
                            <xsl:attribute name="font-size">
                                <xsl:value-of select="$sFootnotePointSize"/>
                                <xsl:text>pt</xsl:text>
                            </xsl:attribute>
                            <span baseline-shift="super">
                                <xsl:attribute name="font-size">
                                    <xsl:value-of select="$sFootnotePointSize - 2"/>
                                    <xsl:text>pt</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="$sFootnoteNumber"/>
                            </span>
                            <xsl:variable name="endnoteRefLayout" select="$contentLayoutInfo/endnoteRefLayout"/>
                            <span>
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="$endnoteRefLayout"/>
                                </xsl:call-template>
                                <xsl:choose>
                                    <xsl:when test="string-length($endnoteRefLayout/@textbefore) &gt; 0">
                                        <xsl:value-of select="$endnoteRefLayout/@textbefore"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>See footnote </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </span>
                            <a href="#{@note}">
                                <xsl:call-template name="AddAnyLinkAttributes">
                                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/endnoteRefLinkLayout"/>
                                </xsl:call-template>
                                <xsl:apply-templates select="id(@note)" mode="endnote"/>
                            </a>
                            <xsl:choose>
                                <xsl:when test="$bIsBook">
                                    <xsl:text> in chapter </xsl:text>
                                    <xsl:variable name="sNoteId" select="@note"/>
                                    <xsl:for-each select="//chapter[descendant::endnote[@id=$sNoteId]]">
                                        <xsl:number level="any" count="chapter" format="1"/>
                                    </xsl:for-each>
                                    <xsl:text>.</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>.</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="string-length($endnoteRefLayout/@textafter) &gt; 0">
                                <span>
                                    <xsl:call-template name="OutputFontAttributes">
                                        <xsl:with-param name="language" select="$endnoteRefLayout"/>
                                    </xsl:call-template>
                                    <xsl:value-of select="$endnoteRefLayout/@textafter"/>
                                </span>
                            </xsl:if>
                        </div>
                    </fo:footnote-body>
                </fo:footnote>
-\->
            </xsl:otherwise>
        </xsl:choose>-->
    </xsl:template>
    <!--
      endnotes
   -->
    <xsl:template match="endnotes">
        <!--  until we get Prince working, always do this
        <xsl:if test="$backMatterLayoutInfo/useEndNotesLayout">-->
        <xsl:if test="$endnotesToShow or $frontMatterLayoutInfo/acknowledgementsLayout/@showAsFootnoteAtEndOfAbstract='yes' and //acknowledgements and //abstract">
            <xsl:choose>
                <xsl:when test="$bIsBook">
                    <xsl:call-template name="OutputChapterStaticContentForBackMatter"> </xsl:call-template>
                    <xsl:call-template name="DoEndnotes"/>
                </xsl:when>
                <xsl:otherwise>
                    <div>
                        <xsl:call-template name="DoEndnotes"/>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <!--        </xsl:if>-->
    </xsl:template>
    <!-- ===========================================================
      CITATIONS, Glossary, Indexes and REFERENCES 
      =========================================================== -->
    <!--
      citation
      -->
    <xsl:template match="//citation[not(parent::selectedBibliography)]">
        <xsl:variable name="refer" select="id(@ref)"/>
        <a href="#{@ref}">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/citationLinkLayout"/>
            </xsl:call-template>
            <xsl:if test="@author='yes'">
                <xsl:value-of select="$refer/../@citename"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
            <xsl:if test="not(@paren) or @paren='both' or @paren='initial'">(</xsl:if>
            <xsl:variable name="works" select="//refWork[../@name=$refer/../@name and @id=//citation/@ref]"/>
            <xsl:variable name="date">
                <xsl:value-of select="$refer/refDate"/>
            </xsl:variable>
            <xsl:if test="@author='yes' and not(not(@paren) or @paren='both' or @paren='initial')">
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
            <xsl:value-of select="$date"/>
            <xsl:if test="count($works[refDate=$date])>1">
                <xsl:apply-templates select="$refer" mode="dateLetter">
                    <xsl:with-param name="date" select="$date"/>
                </xsl:apply-templates>
            </xsl:if>
            <xsl:variable name="sPage" select="normalize-space(@page)"/>
            <xsl:if test="string-length($sPage) &gt; 0">
                <xsl:text>:</xsl:text>
                <xsl:value-of select="$sPage"/>
            </xsl:if>
            <xsl:if test="not(@paren) or @paren='both' or @paren='final'">)</xsl:if>
        </a>
    </xsl:template>
    <!--
      glossary
      -->
    <xsl:template match="glossary">
        <xsl:variable name="iPos" select="count(preceding-sibling::glossary) + 1"/>
        <xsl:choose>
            <xsl:when test="$bIsBook">
                <xsl:call-template name="OutputChapterStaticContentForBackMatter"> </xsl:call-template>
                <xsl:call-template name="DoGlossary">
                    <xsl:with-param name="iPos" select="$iPos"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoGlossary">
                    <xsl:with-param name="iPos" select="$iPos"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      index
      -->
    <xsl:template match="index">
        <xsl:choose>
            <xsl:when test="$bIsBook">
                <xsl:call-template name="DoIndex"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoIndex"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      indexedItem or indexedRangeBegin
      -->
    <xsl:template match="indexedItem | indexedRangeBegin">
        <span>
            <xsl:attribute name="id">
                <xsl:call-template name="CreateIndexedItemID">
                    <xsl:with-param name="sTermId" select="@term"/>
                </xsl:call-template>
            </xsl:attribute>
        </span>
    </xsl:template>
    <!--
      indexedRangeEnd
      -->
    <xsl:template match="indexedRangeEnd">
        <span>
            <xsl:attribute name="id">
                <xsl:call-template name="CreateIndexedItemID">
                    <xsl:with-param name="sTermId" select="@begin"/>
                </xsl:call-template>
            </xsl:attribute>
        </span>
    </xsl:template>
    <!--
      term
      -->
    <xsl:template match="term" mode="InIndex">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
        backMatter
    -->
    <xsl:template match="backMatter">
        <xsl:call-template name="DoBackMatterPerLayout">
            <xsl:with-param name="backMatter" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!--
      references
      -->
    <xsl:template match="references">
        <xsl:choose>
            <xsl:when test="$bIsBook">
                <xsl:call-template name="OutputChapterStaticContentForBackMatter"> </xsl:call-template>
                <xsl:call-template name="DoReferences"/>
            </xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:call-template name="DoReferences"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        authorContactInfo
    -->
    <xsl:template match="authorContactInfo">
        <xsl:param name="layoutInfo"/>
        <td style="padding-right:.5em;">
            <xsl:call-template name="DoAuthorContactInfoPerLayout">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                <xsl:with-param name="authorInfo" select="key('AuthorContactID',@author)"/>
            </xsl:call-template>
        </td>
    </xsl:template>
    <!-- ===========================================================
      BR
      =========================================================== -->
    <xsl:template match="br">
        <br/>
    </xsl:template>
    <!-- ===========================================================
      GLOSS
      =========================================================== -->
    <xsl:template match="gloss">
        <xsl:param name="originalContext"/>
        <xsl:variable name="language" select="key('LanguageID',@lang)"/>
        <xsl:variable name="sGlossContext">
            <xsl:call-template name="GetContextOfItem"/>
        </xsl:variable>
        <xsl:variable name="glossLayout" select="$contentLayoutInfo/glossLayout"/>
        <xsl:call-template name="HandleGlossTextBeforeOutside">
            <xsl:with-param name="glossLayout" select="$glossLayout"/>
            <xsl:with-param name="sGlossContext" select="$sGlossContext"/>
        </xsl:call-template>
        <span class="language{@lang}">
            <span>
                <xsl:call-template name="HandleGlossTextBeforeAndFontOverrides">
                    <xsl:with-param name="glossLayout" select="$glossLayout"/>
                    <xsl:with-param name="sGlossContext" select="$sGlossContext"/>
                </xsl:call-template>
                <xsl:apply-templates>
                    <xsl:with-param name="originalContext" select="$originalContext"/>
                </xsl:apply-templates>
                <xsl:call-template name="HandleGlossTextAfterInside">
                    <xsl:with-param name="glossLayout" select="$glossLayout"/>
                    <xsl:with-param name="sGlossContext" select="$sGlossContext"/>
                </xsl:call-template>
            </span>
        </span>
        <xsl:call-template name="HandleGlossTextAfterOutside">
            <xsl:with-param name="glossLayout" select="$glossLayout"/>
            <xsl:with-param name="sGlossContext" select="$sGlossContext"/>
        </xsl:call-template>
    </xsl:template>
    <!-- ===========================================================
      ABBREVIATION
      =========================================================== -->
    <xsl:template match="abbrRef">
        <xsl:choose>
            <xsl:when test="ancestor::genericRef">
                <xsl:call-template name="OutputAbbrTerm">
                    <xsl:with-param name="abbr" select="id(@abbr)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <span>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:text>#</xsl:text>
                            <xsl:value-of select="@abbr"/>
                        </xsl:attribute>
                        <xsl:call-template name="AddAnyLinkAttributes">
                            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/abbrRefLinkLayout"/>
                        </xsl:call-template>
                        <xsl:call-template name="OutputAbbrTerm">
                            <xsl:with-param name="abbr" select="id(@abbr)"/>
                        </xsl:call-template>
                    </a>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="abbreviationsShownHere">
        <xsl:if test="$iAbbreviationCount &gt; 0">
            <xsl:choose>
                <xsl:when test="ancestor::endnote">
                    <xsl:choose>
                        <xsl:when test="parent::p">
                            <xsl:call-template name="OutputAbbreviationsInCommaSeparatedList"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <div>
                                <xsl:call-template name="OutputAbbreviationsInCommaSeparatedList"/>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="not(ancestor::p)">
                    <!-- ignore any other abbreviationsShownHere in a p except when also in an endnote; everything else goes in a table -->
                    <xsl:call-template name="OutputAbbreviationsInTable"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template match="abbrTerm | abbrDefinition"/>
    <!-- ===========================================================
      LANGDATA
      =========================================================== -->
    <xsl:template match="langData">
        <xsl:param name="originalContext"/>
        <xsl:variable name="language" select="key('LanguageID',@lang)"/>
        <xsl:variable name="sLangDataContext">
            <xsl:call-template name="GetContextOfItem"/>
        </xsl:variable>
        <xsl:variable name="langDataLayout" select="$contentLayoutInfo/langDataLayout"/>
        <xsl:call-template name="HandleLangDataTextBeforeOutside">
            <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
            <xsl:with-param name="sLangDataContext" select="$sLangDataContext"/>
        </xsl:call-template>
        <span class="language{@lang}">
            <span>
                <xsl:call-template name="HandleLangDataTextBeforeAndFontOverrides">
                    <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
                    <xsl:with-param name="sLangDataContext" select="$sLangDataContext"/>
                </xsl:call-template>
                <xsl:apply-templates>
                    <xsl:with-param name="originalContext" select="$originalContext"/>
                </xsl:apply-templates>
                <xsl:call-template name="HandleLangDataTextAfterInside">
                    <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
                    <xsl:with-param name="sLangDataContext" select="$sLangDataContext"/>
                </xsl:call-template>
            </span>
        </span>
        <xsl:call-template name="HandleLangDataTextAfterOutside">
            <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
            <xsl:with-param name="sLangDataContext" select="$sLangDataContext"/>
        </xsl:call-template>
    </xsl:template>
    <!-- ===========================================================
        LANDSCAPE
        =========================================================== -->
    <xsl:template match="landscape">
        <div class="landscape">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <!-- ===========================================================
      OBJECT
      =========================================================== -->
    <xsl:template match="object">
        <span class="type{@type}">
            <span>
                <xsl:attribute name="style">
                    <xsl:call-template name="DoType"/>
                </xsl:attribute>
                <xsl:for-each select="key('TypeID',@type)">
                    <xsl:value-of select="@before"/>
                </xsl:for-each>
                <xsl:apply-templates/>
                <xsl:for-each select="key('TypeID',@type)">
                    <xsl:value-of select="@after"/>
                </xsl:for-each>
            </span>
        </span>
    </xsl:template>
    <!-- ===========================================================
        MEDIAOBJECT
        =========================================================== -->
    <xsl:template match="mediaObject">
        <xsl:if test="//lingPaper/@includemediaobjects='yes'">
            <rx:media-object content-height="{@contentheight}" content-width="{@contentwidth}" src="url({@src})">
                <xsl:attribute name="show-controls">
                    <xsl:choose>
                        <xsl:when test="@showcontrols='yes'">true</xsl:when>
                        <xsl:otherwise>false</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </rx:media-object>
        </xsl:if>
    </xsl:template>
    <!-- ===========================================================
        ELEMENTS TO IGNORE
        =========================================================== -->
    <xsl:template match="basicPointSize"/>
    <xsl:template match="blockQuoteIndent"/>
    <xsl:template match="citation[parent::selectedBibliography]"/>
    <xsl:template match="defaultFontFamily"/>
    <xsl:template match="footerMargin"/>
    <xsl:template match="footnotePointSize"/>
    <xsl:template match="headerMargin"/>
    <xsl:template match="magnificationFactor"/>
    <xsl:template match="interlinearSource"/>
    <xsl:template match="pageBottomMargin"/>
    <xsl:template match="pageHeight"/>
    <xsl:template match="pageInsideMargin"/>
    <xsl:template match="pageOutsideMargin"/>
    <xsl:template match="pageTopMargin"/>
    <xsl:template match="pageWidth"/>
    <xsl:template match="paragraphIndent"/>
    <xsl:template match="publisherStyleSheetName"/>
    <xsl:template match="publisherStyleSheetReferencesName"/>
    <xsl:template match="publisherStyleSheetReferencesVersion"/>
    <xsl:template match="publisherStyleSheetVersion"/>
    <xsl:template match="referencedInterlinearTexts"/>
    <!-- ===========================================================
      NAMED TEMPLATES
      =========================================================== -->
    <!--
                  AddAnyLinkAttributes
                                    -->
    <xsl:template name="AddAnyLinkAttributes">
        <xsl:param name="override"/>
        <xsl:attribute name="class">
            <xsl:value-of select="name($override)"/>
        </xsl:attribute>
    </xsl:template>
    <!--  
        AdjustFontSizePerMagnification
    -->
    <xsl:template name="AdjustFontSizePerMagnification">
        <xsl:param name="sFontSize"/>
        <xsl:choose>
            <xsl:when test="$iMagnificationFactor!=1">
                <xsl:variable name="iLength" select="string-length(normalize-space($sFontSize))"/>
                <xsl:variable name="iSize" select="substring($sFontSize,1, $iLength - 2)"/>
                <xsl:value-of select="$iSize * $iMagnificationFactor"/>
                <xsl:value-of select="substring($sFontSize, $iLength - 1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sFontSize"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      ApplyTemplatesPerTextRefMode
   -->
    <xsl:template name="ApplyTemplatesPerTextRefMode">
        <xsl:param name="mode"/>
        <xsl:param name="originalContext"/>
        <xsl:choose>
            <xsl:when test="$mode='NoTextRef'">
                <xsl:apply-templates mode="NoTextRef"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="*[name() !='interlinearSource']">
                    <xsl:with-param name="originalContext" select="$originalContext"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
                  CheckSeeTargetIsCitedOrItsDescendantIsCited
                                    -->
    <xsl:template name="CheckSeeTargetIsCitedOrItsDescendantIsCited">
        <xsl:variable name="sSee" select="@see"/>
        <xsl:choose>
            <xsl:when test="//indexedItem[@term=$sSee] | //indexedRangeBegin[@term=$sSee]">
                <xsl:text>Y</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="key('IndexTermID',@see)/descendant::indexTerm">
                    <xsl:variable name="sDescendantTermId" select="@id"/>
                    <xsl:if test="//indexedItem[@term=$sDescendantTermId] or //indexedRangeBegin[@term=$sDescendantTermId]">
                        <xsl:text>Y</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
                  CreateIndexID
                                    -->
    <xsl:template name="CreateIndexID">
        <xsl:text>rXLingPapIndex.</xsl:text>
        <xsl:value-of select="generate-id()"/>
    </xsl:template>
    <!--
                  CreateIndexedItemID
                  -->
    <xsl:template name="CreateIndexedItemID">
        <xsl:param name="sTermId"/>
        <xsl:text>rXLingPapIndexedItem.</xsl:text>
        <xsl:value-of select="$sTermId"/>
        <xsl:text>.</xsl:text>
        <xsl:value-of select="generate-id()"/>
    </xsl:template>
    <!--
                  CreateIndexTermID
                  -->
    <xsl:template name="CreateIndexTermID">
        <xsl:param name="sTermId"/>
        <xsl:text>rXLingPapIndexTerm.</xsl:text>
        <xsl:value-of select="$sTermId"/>
    </xsl:template>
    <!--  
      DoBackMatterBookmarksPerLayout
   -->
    <xsl:template name="DoBackMatterBookmarksPerLayout">
        <xsl:param name="nLevel"/>
        <xsl:variable name="backMatter" select="//backMatter"/>
        <xsl:for-each select="$backMatterLayoutInfo/*">
            <xsl:choose>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:apply-templates select="$backMatter/acknowledgements" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='appendixLayout'">
                    <xsl:apply-templates select="$backMatter/appendix" mode="bookmarks">
                        <xsl:with-param name="nLevel" select="$nLevel"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='glossaryLayout'">
                    <xsl:apply-templates select="$backMatter/glossary" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='indexLayout'">
                    <xsl:apply-templates select="$backMatter/index" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='referencesLayout'">
                    <xsl:apply-templates select="$backMatter/references" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='useEndNotesLayout'">
                    <xsl:apply-templates select="$backMatter/endnotes" mode="bookmarks"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoBackMatterContentsPerLayout
    -->
    <xsl:template name="DoBackMatterContentsPerLayout">
        <xsl:param name="nLevel"/>
        <xsl:variable name="backMatter" select="//backMatter"/>
        <xsl:for-each select="$backMatterLayoutInfo/*">
            <xsl:choose>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:apply-templates select="$backMatter/acknowledgements" mode="contents"/>
                </xsl:when>
                <xsl:when test="name(.)='appendixLayout'">
                    <xsl:apply-templates select="$backMatter/appendix" mode="contents">
                        <xsl:with-param name="nLevel" select="$nLevel"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='glossaryLayout'">
                    <xsl:apply-templates select="$backMatter/glossary" mode="contents"/>
                </xsl:when>
                <xsl:when test="name(.)='indexLayout'">
                    <xsl:apply-templates select="$backMatter/index" mode="contents"/>
                </xsl:when>
                <xsl:when test="name(.)='referencesLayout'">
                    <xsl:apply-templates select="$backMatter/references" mode="contents"/>
                </xsl:when>
                <xsl:when test="name(.)='useEndNotesLayout'">
                    <xsl:apply-templates select="$backMatter/endnotes" mode="contents"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoBackMatterPerLayout
    -->
    <xsl:template name="DoBackMatterPerLayout">
        <xsl:param name="backMatter"/>
        <xsl:for-each select="$backMatterLayoutInfo/*">
            <xsl:choose>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:choose>
                        <xsl:when test="$bIsBook">
                            <xsl:apply-templates select="$backMatter/acknowledgements" mode="backmatter-book"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$backMatter/acknowledgements" mode="paper"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="name(.)='appendixLayout'">
                    <xsl:apply-templates select="$backMatter/appendix"/>
                </xsl:when>
                <xsl:when test="name(.)='glossaryLayout'">
                    <xsl:apply-templates select="$backMatter/glossary"/>
                </xsl:when>
                <xsl:when test="name(.)='indexLayout'">
                    <xsl:apply-templates select="$backMatter/index"/>
                </xsl:when>
                <xsl:when test="name(.)='referencesLayout'">
                    <xsl:apply-templates select="$backMatter/references"/>
                </xsl:when>
                <xsl:when test="name(.)='authorContactInfoLayout'">
                    <div>
                        <xsl:variable name="firstLayoutItem" select="*[position()=1]"/>
                        <xsl:variable name="sSpaceBefore" select="normalize-space($firstLayoutItem/@spacebefore)"/>
                        <xsl:if test="string-length($sSpaceBefore) &gt; 0">
                            <xsl:attribute name="style">
                                <xsl:text>padding-right:</xsl:text>
                                <xsl:value-of select="$sSpaceBefore"/>
                            </xsl:attribute>
                        </xsl:if>
                        <table>
                            <tr valign="top">
                                <xsl:apply-templates select="$backMatter/authorContactInfo">
                                    <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/authorContactInfoLayout"/>
                                </xsl:apply-templates>
                            </tr>
                        </table>
                    </div>
                </xsl:when>
                <xsl:when test="name(.)='useEndNotesLayout'">
                    <xsl:apply-templates select="$backMatter/endnotes"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <xsl:if test="not($backMatterLayoutInfo/useEndNotesLayout)">
            <!-- if the style sheet does not use endnotes explicitly, do it anyway -->
            <xsl:apply-templates select="$backMatter/endnotes"/>
        </xsl:if>
    </xsl:template>
    <!--
        DoCellAttributes
    -->
    <xsl:template name="DoCellAttributes">
        <xsl:if test="@direction">
            <xsl:attribute name="style">
                <xsl:text>direction:</xsl:text>
                <xsl:value-of select="@direction"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@align">
            <xsl:attribute name="align">
                <xsl:value-of select="@align"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@colspan">
            <xsl:attribute name="colspan">
                <xsl:value-of select="@colspan"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@rowspan">
            <xsl:attribute name="rowspan">
                <xsl:value-of select="@rowspan"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@valign">
            <xsl:attribute name="valign">
                <xsl:value-of select="@valign"/>
            </xsl:attribute>
        </xsl:if>
        <!-- does not work in HTML 4.0 
            <xsl:if test="@width">
            <xsl:attribute name="width">
            <xsl:value-of select="@width"/>
            </xsl:attribute>
            </xsl:if>
        -->
    </xsl:template>
    <!--
        DoContactInfo
    -->
    <xsl:template name="DoContactInfo">
        <xsl:param name="currentLayoutInfo"/>
        <div>
            <xsl:attribute name="style">
                <xsl:variable name="sSpaceBefore" select="normalize-space($currentLayoutInfo/@spacebefore)"/>
                <xsl:if test="string-length($sSpaceBefore) &gt; 0">
                    <xsl:text>margin-top:</xsl:text>
                    <xsl:value-of select="$sSpaceBefore"/>
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:variable name="sSpaceAfter" select="normalize-space($currentLayoutInfo/@spaceafter)"/>
                <xsl:if test="string-length($sSpaceAfter) &gt; 0">
                    <xsl:text>margin-bottom:</xsl:text>
                    <xsl:value-of select="$sSpaceAfter"/>
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$currentLayoutInfo"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="."/>
        </div>
        <!--        <br/>-->
    </xsl:template>
    <!--
                  DoContents
                  -->
    <xsl:template name="DoContents">
        <xsl:param name="bIsBook" select="'Y'"/>
        <div id="rXLingPapContents" class="contents">
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/contentsLayout"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="$bIsBook='Y'">
                    <xsl:call-template name="OutputChapTitle">
                        <xsl:with-param name="sTitle">
                            <xsl:call-template name="OutputContentsLabel"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="OutputContentsLabel"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/contentsLayout"/>
            </xsl:call-template>
        </div>
        <div>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacecontents='yes'">
                <xsl:attribute name="style">
                    <xsl:call-template name="DoSinglespacing"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="DoFrontMatterContentsPerLayout"/>
            <!-- part -->
            <xsl:apply-templates select="$lingPaper/part" mode="contents"/>
            <!--                 chapter, no parts -->
            <xsl:apply-templates select="$lingPaper/chapter" mode="contents"/>
            <!-- section, no chapters -->
            <xsl:apply-templates select="$lingPaper/section1" mode="contents"/>
            <xsl:call-template name="DoBackMatterContentsPerLayout"/>
        </div>
    </xsl:template>
    <!--  
                  DoDebugExamples
-->
    <xsl:template name="DoDebugExamples">
        <xsl:if test="$bDoDebug='y'">
            <xsl:attribute name="border">solid 1pt gray</xsl:attribute>
            <xsl:attribute name="border-collapse">collapse</xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!--  
                  DoDebugFooter
-->
    <xsl:template name="DoDebugFooter">
        <xsl:if test="$bDoDebug='y'">
            <xsl:attribute name="border">
                <xsl:text>thin solid blue</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!--  
                  DoDebugFrontMatterBody
-->
    <xsl:template name="DoDebugFrontMatterBody">
        <xsl:if test="$bDoDebug='y'">
            <xsl:attribute name="border">
                <xsl:text>thick solid green</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!--  
                  DoDebugHeader
-->
    <xsl:template name="DoDebugHeader">
        <xsl:if test="$bDoDebug='y'">
            <xsl:attribute name="border">
                <xsl:text>thin solid red</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!--  
        DoEndnoteRefNumber
    -->
    <xsl:template name="DoEndnoteRefNumber">
        <xsl:text>[</xsl:text>
        <a href="#{@note}">
            <xsl:for-each select="key('EndnoteID',@note)">
                <xsl:call-template name="GetFootnoteNumber">
                    <xsl:with-param name="iAdjust" select="0"/>
                </xsl:call-template>
            </xsl:for-each>
        </a>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <!--  
      DoEndnotes
   -->
    <xsl:template name="DoEndnotes">
        <xsl:if test="contains($endnotesToShow,'X')">
            <xsl:call-template name="OutputBackMatterItemTitle">
                <xsl:with-param name="sId" select="'rXLingPapEndnotes'"/>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputEndnotesLabel"/>
                </xsl:with-param>
                <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/useEndNotesLayout"/>
            </xsl:call-template>
            <table class="footnote">
                <xsl:if test="$frontMatterLayoutInfo/acknowledgementsLayout/@showAsFootnoteAtEndOfAbstract='yes' and //acknowledgements and //abstract">
                    <tr>
                        <td valign="baseline">
                            <xsl:element name="a">
                                <xsl:attribute name="name">
                                    <xsl:value-of select="$sAcknowledgementsID"/>
                                </xsl:attribute>[*]</xsl:element>
                        </td>
                        <td valign="baseline">
                            <xsl:apply-templates select="$lingPaper/frontMatter/acknowledgements/*"/>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:apply-templates select="//endnote[not(ancestor::referencedInterlinearText)] | //interlinearRef" mode="backMatter"/>
            </table>
        </xsl:if>
        <!-- We may want this if we use Prince
            <xsl:for-each select="//endnote">
            <xsl:call-template name="DoFootnoteContent"/>
        </xsl:for-each>-->
    </xsl:template>
    <!--  
        DoFigure
    -->
    <xsl:template name="DoFigure">
        <div id="{@id}">
            <xsl:attribute name="class">
                <xsl:text>figureAlign</xsl:text>
                <xsl:choose>
                    <xsl:when test="@align='center'">
                        <xsl:text>Center</xsl:text>
                    </xsl:when>
                    <xsl:when test="@align='right'">
                        <xsl:text>Right</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Left</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="style">
                <xsl:call-template name="DoType"/>
                <xsl:call-template name="OutputTypeAttributes">
                    <xsl:with-param name="sList" select="@cssSpecial"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:if test="$contentLayoutInfo/figureLayout/@captionLocation='before' or not($contentLayoutInfo/figureLayout) and $lingPaper/@figureLabelAndCaptionLocation='before'">
                <div class="figureCaptionLayout">
                    <xsl:call-template name="OutputFigureLabelAndCaption"/>
                </div>
            </xsl:if>
            <xsl:apply-templates select="*[name()!='caption' and name()!='shortCaption']"/>
            <xsl:if test="$contentLayoutInfo/figureLayout/@captionLocation='after' or not($contentLayoutInfo/figureLayout) and $lingPaper/@figureLabelAndCaptionLocation='after'">
                <div class="figureCaptionLayout">
                    <xsl:call-template name="OutputFigureLabelAndCaption"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>
    <!--  
      DoFontVariant
   -->
    <xsl:template name="DoFontVariant">
        <xsl:param name="item"/>
        <xsl:choose>
            <xsl:when test="$item/@font-variant='small-caps'">
                <xsl:call-template name="HandleSmallCaps"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="font-variant">
                    <xsl:value-of select="$item/@font-variant"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      DoFootnoteContent
   -->
    <xsl:template name="DoFootnoteContent">
        <div>
            <xsl:if test="$backMatterLayoutInfo/useEndNotesLayout">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single'">
                <xsl:attribute name="style">
                    <xsl:text>line-height:</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$lineSpacing/@singlespaceendnotes='yes'">
                            <xsl:value-of select="$sSinglespacingLineHeight"/>
                        </xsl:when>
                        <xsl:when test="$sLineSpacing='double'">
                            <xsl:text>200%</xsl:text>
                        </xsl:when>
                        <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                            <xsl:text>150%</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:text>;</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <!-- HACK for XEP which does not yet do small-caps: -->
            <xsl:attribute name="text-transform">none</xsl:attribute>
            <!--            <xsl:attribute name="font-size">
                <xsl:value-of select="$sFootnotePointSize"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
-->
            <xsl:apply-templates select="*[1]" mode="endnote-content"/>
            <xsl:apply-templates select="*[position() &gt; 1]"/>
        </div>
    </xsl:template>
    <!--  
      DoFootnoteNumberInText
   -->
    <xsl:template name="DoFootnoteNumberInText">
        <xsl:choose>
            <xsl:when test="$backMatterLayoutInfo/useEndNotesLayout">
                <a>
                    <xsl:attribute name="href">
                        <xsl:text>#</xsl:text>
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                    <xsl:call-template name="AddAnyLinkAttributes">
                        <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/endnoteRefLinkLayout"/>
                    </xsl:call-template>
                    <span baseline-shift="super">
                        <xsl:call-template name="DoFootnoteNumberInTextValue"/>
                    </span>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <span baseline-shift="super">
                    <xsl:attribute name="id">
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                    <xsl:call-template name="DoFootnoteNumberInTextValue"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      DoFootnoteNumberInTextValue
   -->
    <xsl:template name="DoFootnoteNumberInTextValue">
        <xsl:choose>
            <xsl:when test="parent::author">
                <xsl:variable name="iAuthorPosition" select="count(parent::author/preceding-sibling::author[endnote]) + 1"/>
                <xsl:call-template name="OutputAuthorFootnoteSymbol">
                    <xsl:with-param name="iAuthorPosition" select="$iAuthorPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$bIsBook">
                <xsl:number level="any" count="endnote[not(ancestor::author)] | endnoteRef[not(ancestor::endnote)]" from="chapter | appendix | glossary | acknowledgements | preface | abstract" format="1"/>
                <!--                <xsl:number level="any" count="endnote | endnoteRef[not(ancestor::endnote)]" from="chapter"/>-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="any" count="endnote[not(parent::author)] | endnoteRef[not(ancestor::endnote)]" format="1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      DoFootnoteSeparatorStaticContent
   -->
    <xsl:template name="DoFootnoteSeparatorStaticContent">
        <xsl:variable name="layoutInfo" select="$pageLayoutInfo/footnoteLine"/>
        <xsl:if test="$layoutInfo">
            <!--            <fo:static-content flow-name="xsl-footnote-separator">
                <div>
                    <xsl:if test="$layoutInfo/@textalign">
                        <xsl:attribute name="text-align">
                            <xsl:value-of select="$layoutInfo/@textalign"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$layoutInfo/@leaderpattern and $layoutInfo/@leaderpattern!='none'">
                        <fo:leader>
                            <xsl:attribute name="leader-pattern">
                                <xsl:value-of select="$layoutInfo/@leaderpattern"/>
                            </xsl:attribute>
                            <xsl:if test="$layoutInfo/@leaderlength">
                                <xsl:attribute name="leader-length">
                                    <xsl:value-of select="$layoutInfo/@leaderlength"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if test="$layoutInfo/@leaderwidth">
                                <xsl:attribute name="leader-width">
                                    <xsl:value-of select="$layoutInfo/@leaderwidth"/>
                                </xsl:attribute>
                            </xsl:if>
                        </fo:leader>
                    </xsl:if>
                </div>
            </fo:static-content>
-->
        </xsl:if>
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
                <xsl:when test="starts-with($sAfter,'.') and substring($sPrecedingText,string-length($sPrecedingText),string-length($sPrecedingText))='.'">
                    <xsl:value-of select="substring($sAfter, 2)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$sAfter"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        DoFormatLayoutInfoTextBefore
    -->
    <xsl:template name="DoFormatLayoutInfoTextBefore">
        <xsl:param name="layoutInfo"/>
        <!--  want to handledin CSS, but Internet Explorer does not handle :before pseudo element, sigh.  -->
        <xsl:if test="string-length($layoutInfo/@textbefore) &gt; 0">
            <xsl:value-of select="$layoutInfo/@textbefore"/>
        </xsl:if>
    </xsl:template>
    <!--  
        DoFrontMatterLayoutInfo
    -->
    <xsl:template name="DoFrontMatterFormatInfo">
        <xsl:param name="layoutInfo"/>
        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
      DoFrontMatterBookmarksPerLayout
   -->
    <xsl:template name="DoFrontMatterBookmarksPerLayout">
        <xsl:variable name="frontMatter" select=".."/>
        <xsl:for-each select="$frontMatterLayoutInfo/*">
            <xsl:choose>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:apply-templates select="$frontMatter/acknowledgements" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='abstractLayout'">
                    <xsl:apply-templates select="$frontMatter/abstract" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='contentsLayout'">
                    <xsl:apply-templates select="$frontMatter/contents" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='prefaceLayout'">
                    <xsl:apply-templates select="$frontMatter/preface" mode="bookmarks"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoFrontMatterContentsPerLayout
    -->
    <xsl:template name="DoFrontMatterContentsPerLayout">
        <xsl:variable name="frontMatter" select=".."/>
        <xsl:for-each select="$frontMatterLayoutInfo/*">
            <xsl:choose>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:apply-templates select="$frontMatter/acknowledgements" mode="contents"/>
                </xsl:when>
                <xsl:when test="name(.)='abstractLayout'">
                    <xsl:apply-templates select="$frontMatter/abstract" mode="contents"/>
                </xsl:when>
                <xsl:when test="name(.)='prefaceLayout'">
                    <xsl:apply-templates select="$frontMatter/preface" mode="contents"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoBookFrontMatterFirstStuffPerLayout
    -->
    <xsl:template name="DoBookFrontMatterFirstStuffPerLayout">
        <xsl:param name="frontMatter"/>
        <xsl:call-template name="HandleBasicFrontMatterPerLayout">
            <xsl:with-param name="frontMatter" select="$frontMatter"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        DoBookFrontMatterPagedStuffPerLayout
    -->
    <xsl:template name="DoBookFrontMatterPagedStuffPerLayout">
        <xsl:param name="frontMatter"/>
        <xsl:for-each select="$frontMatterLayoutInfo/*">
            <xsl:choose>
                <xsl:when test="name(.)='contentsLayout'">
                    <xsl:apply-templates select="$frontMatter/contents" mode="book"/>
                </xsl:when>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:apply-templates select="$frontMatter/acknowledgements" mode="frontmatter-book"/>
                </xsl:when>
                <xsl:when test="name(.)='abstractLayout'">
                    <xsl:apply-templates select="$frontMatter/abstract" mode="book"/>
                </xsl:when>
                <xsl:when test="name(.)='prefaceLayout'">
                    <xsl:apply-templates select="$frontMatter/preface" mode="book"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
      DoBackMatterItemNewPage
   -->
    <xsl:template name="DoBackMatterItemNewPage">
        <xsl:param name="id"/>
        <xsl:param name="sTitle"/>
        <xsl:param name="sHeaderTitleClassName"/>
        <xsl:param name="layoutInfo"/>
        <xsl:param name="sMarkerClassName"/>
        <xsl:call-template name="OutputChapterStaticContentForBackMatter"> </xsl:call-template>
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="sTitle" select="$sTitle"/>
            <xsl:with-param name="bIsBook" select="'Y'"/>
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            <xsl:with-param name="sMarkerClassName" select="$sMarkerClassName"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <!--  
      DoFrontMatterItemNewPage
   -->
    <xsl:template name="DoFrontMatterItemNewPage">
        <xsl:param name="id"/>
        <xsl:param name="sTitle"/>
        <xsl:param name="sHeaderTitleClassName"/>
        <xsl:param name="layoutInfo"/>
        <xsl:param name="sMarkerClassName"/>
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="sTitle" select="$sTitle"/>
            <xsl:with-param name="bIsBook" select="'Y'"/>
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            <xsl:with-param name="sMarkerClassName" select="$sMarkerClassName"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <!--  
        DoFrontMatterPerLayout
    -->
    <xsl:template name="DoFrontMatterPerLayout">
        <xsl:param name="frontMatter"/>
        <xsl:call-template name="HandleBasicFrontMatterPerLayout">
            <xsl:with-param name="frontMatter" select="$frontMatter"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
                  DoGlossary
-->
    <xsl:template name="DoGlossary">
        <xsl:param name="iPos" select="'1'"/>
        <xsl:call-template name="OutputBackMatterItemTitle">
            <xsl:with-param name="sId" select="concat('rXLingPapGlossary',$iPos)"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputGlossaryLabel">
                    <xsl:with-param name="iPos" select="$iPos"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/glossaryLayout"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <!--  
      DoHeaderAndFooter
   -->
    <xsl:template name="DoHeaderAndFooter">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="layoutInfoParentWithFontInfo"/>
        <xsl:param name="sFlowName"/>
        <xsl:param name="sRetrieveClassName"/>
        <xsl:variable name="header" select="$layoutInfo/header"/>
        <xsl:if test="$header/*/*[name()!='nothing']">
            <xsl:call-template name="DoHeaderOrFooter">
                <xsl:with-param name="sFlowName" select="$sFlowName"/>
                <xsl:with-param name="sFlowDisplayAlign" select="'before'"/>
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                <xsl:with-param name="layoutInfoParentWithFontInfo" select="$layoutInfoParentWithFontInfo"/>
                <xsl:with-param name="headerOrFooter" select="$header"/>
                <xsl:with-param name="sRetrieveClassName" select="$sRetrieveClassName"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="footer" select="$layoutInfo/footer"/>
        <xsl:if test="$footer/*/*[name()!='nothing']">
            <xsl:call-template name="DoHeaderOrFooter">
                <xsl:with-param name="sFlowName" select="$sFlowName"/>
                <xsl:with-param name="sFlowDisplayAlign" select="'after'"/>
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                <xsl:with-param name="layoutInfoParentWithFontInfo" select="$layoutInfoParentWithFontInfo"/>
                <xsl:with-param name="headerOrFooter" select="$footer"/>
                <xsl:with-param name="sRetrieveClassName" select="$sRetrieveClassName"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
      DoHeaderFooterItem
   -->
    <xsl:template name="DoHeaderFooterItem">
        <xsl:param name="item"/>
        <xsl:param name="sRetrieveClassName"/>
        <!--        <xsl:for-each select="$item/*">
            <xsl:choose>
                <xsl:when test="name()='nothing'">
                    <fo:leader/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="parent" select="parent::*"/>
                    <xsl:variable name="beforeme" select="$parent/preceding-sibling::*"/>
                    <xsl:if test="$parent[name()!='leftHeaderFooterItem'] and not($parent/preceding-sibling::*[1]/nothing)">
                        <fo:leader/>
                    </xsl:if>
                    <span>
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="."/>
                        </xsl:call-template>
                        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                            <xsl:with-param name="layoutInfo" select="."/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="name()='chapterTitle'">
                                <fo:retrieve-marker>
                                    <xsl:attribute name="retrieve-class-name">
                                        <xsl:choose>
                                            <xsl:when test="string-length($sRetrieveClassName) &gt; 0">
                                                <xsl:value-of select="$sRetrieveClassName"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>chap-title</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </fo:retrieve-marker>
                            </xsl:when>
                            <xsl:when test="name()='fixedText'">
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="."/>
                                </xsl:call-template>
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:when test="name()='pageNumber'">
                                <fo:page-number/>
                            </xsl:when>
                            <xsl:when test="name()='paperAuthor'">
                                <xsl:choose>
                                    <xsl:when test="string-length(normalize-space(//frontMatter/shortAuthor)) &gt; 0">
                                        <xsl:apply-templates select="."/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="//author" mode="contentOnly"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="name()='paperTitle'">
                                <xsl:choose>
                                    <xsl:when test="string-length(normalize-space(//frontMatter/shortTitle)) &gt; 0">
                                        <xsl:apply-templates select="//frontMatter/shortTitle"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-\-                              <xsl:apply-templates select="//frontMatter//title/child::node()[name()!='endnote']" mode="contentOnly"/>-\->
                                        <xsl:apply-templates select="//frontMatter//title/child::node()[name()!='endnote']"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="name()='sectionTitle'">
                                <fo:retrieve-marker>
                                    <xsl:attribute name="retrieve-class-name">
                                        <xsl:choose>
                                            <xsl:when test="string-length($sRetrieveClassName) &gt; 0">
                                                <xsl:value-of select="$sRetrieveClassName"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>section-title</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </fo:retrieve-marker>
                            </xsl:when>
                            <xsl:when test="name()='volumeAuthorRef'">
                                <xsl:choose>
                                    <xsl:when test="string-length(//volumeAuthor) &gt;0">
                                        <xsl:apply-templates select="//volumeAuthor"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Volume Author Will Show Here</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="name()='volumeTitleRef'">
                                <xsl:choose>
                                    <xsl:when test="string-length(//volumeAuthor) &gt;0">
                                        <xsl:apply-templates select="//volumeTitle"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Volume Title Will Show Here</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="name()='img'">
                                <xsl:apply-templates select="."/>
                            </xsl:when>
                            <!-\-  we ignore the 'nothing' case -\->
                        </xsl:choose>
                        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                            <xsl:with-param name="layoutInfo" select="."/>
                        </xsl:call-template>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
-->
    </xsl:template>
    <!--  
      DoHeaderOrFooter
   -->
    <xsl:template name="DoHeaderOrFooter">
        <xsl:param name="sFlowName"/>
        <xsl:param name="layoutInfo"/>
        <xsl:param name="layoutInfoParentWithFontInfo"/>
        <xsl:param name="headerOrFooter"/>
        <xsl:param name="sFlowDisplayAlign"/>
        <xsl:param name="sRetrieveClassName"/>
        <!--        <fo:static-content display-align="{$sFlowDisplayAlign}">
            <xsl:attribute name="flow-name">
                <xsl:value-of select="$sFlowName"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$sFlowDisplayAlign"/>
            </xsl:attribute>
            <div text-align-last="justify">
                <xsl:if test="$sFlowDisplayAlign='after'">
                    <xsl:attribute name="margin-top">
                        <xsl:text>6pt</xsl:text>
                    </xsl:attribute>
                </xsl:if>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$layoutInfoParentWithFontInfo"/>
                </xsl:call-template>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$layoutInfo"/>
                </xsl:call-template>
                <xsl:call-template name="DoHeaderFooterItem">
                    <xsl:with-param name="item" select="$headerOrFooter/leftHeaderFooterItem"/>
                    <xsl:with-param name="sRetrieveClassName" select="$sRetrieveClassName"/>
                </xsl:call-template>
                <xsl:call-template name="DoHeaderFooterItem">
                    <xsl:with-param name="item" select="$headerOrFooter/centerHeaderFooterItem"/>
                    <xsl:with-param name="sRetrieveClassName" select="$sRetrieveClassName"/>
                </xsl:call-template>
                <xsl:call-template name="DoHeaderFooterItem">
                    <xsl:with-param name="item" select="$headerOrFooter/rightHeaderFooterItem"/>
                    <xsl:with-param name="sRetrieveClassName" select="$sRetrieveClassName"/>
                </xsl:call-template>
            </div>
        </fo:static-content>
-->
    </xsl:template>
    <!--  
                  DoIndex
-->
    <xsl:template name="DoIndex">
        <xsl:call-template name="OutputBackMatterItemTitle">
            <xsl:with-param name="sId">
                <xsl:call-template name="CreateIndexID"/>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputIndexLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/indexLayout"/>
        </xsl:call-template>
        <!-- process any paragraphs, etc. that may be at the beginning -->
        <xsl:apply-templates/>
        <!-- now process the contents of this index -->
        <xsl:variable name="sIndexKind">
            <xsl:choose>
                <xsl:when test="@kind">
                    <xsl:value-of select="@kind"/>
                </xsl:when>
                <xsl:otherwise>common</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespaceindexes='yes'">
                <xsl:attribute name="style">
                    <xsl:call-template name="DoSinglespacing"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputIndexTerms">
                <xsl:with-param name="sIndexKind" select="$sIndexKind"/>
                <xsl:with-param name="lang" select="$indexLang"/>
                <xsl:with-param name="terms" select="//lingPaper/indexTerms"/>
            </xsl:call-template>
        </div>
    </xsl:template>
    <!--  
      DoInitialPageNumberAttribute
   -->
    <xsl:template name="DoInitialPageNumberAttribute">
        <xsl:param name="layoutInfo"/>
        <xsl:attribute name="initial-page-number">
            <xsl:choose>
                <xsl:when test="$layoutInfo/@startonoddpage='yes'">
                    <xsl:text>auto-odd</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>auto</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <!--  
      DoInterlinearFree
   -->
    <xsl:template name="DoInterlinearFree">
        <xsl:param name="originalContext"/>
        <xsl:param name="mode"/>
        <table>
            <xsl:if test="following-sibling::interlinearSource and $sInterlinearSourceStyle='AfterFree' and not(following-sibling::free)">
                <xsl:attribute name="text-align-last">justify</xsl:attribute>
            </xsl:if>
            <!-- add extra indent for when have an embedded interlinear; 
            be sure to allow for the case of when a listInterlinear begins with an interlinear -->
            <xsl:variable name="parent" select=".."/>
            <xsl:variable name="iParentPosition">
                <xsl:for-each select="../../*">
                    <xsl:if test=".=$parent">
                        <xsl:value-of select="position()"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="sCurrentLanguage" select="@lang"/>
            <xsl:if test="preceding-sibling::free[@lang=$sCurrentLanguage][position()=1] or preceding-sibling::*[1][name()='free'][not(@lang)][position()=1] or name(../..)='interlinear' or name(../..)='listInterlinear' and name(..)='interlinear' and $iParentPosition!=1">
                <!--                <xsl:if test="preceding-sibling::free[@lang=$sCurrentLanguage][position()=1] or preceding-sibling::free[not(@lang)][position()=1] or name(../..)='interlinear' or name(../..)='listInterlinear' and name(..)='interlinear' and $iParentPosition!=1">-->
                <xsl:attribute name="style">
                    <xsl:text>margin-left:0.1in;</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:variable name="language" select="key('LanguageID',@lang)"/>
            <xsl:variable name="freeLayout" select="$contentLayoutInfo/freeLayout"/>
            <tr>
                <td>
                    <xsl:call-template name="HandleFreeTextBeforeOutside">
                        <xsl:with-param name="freeLayout" select="$freeLayout"/>
                    </xsl:call-template>
                    <span class="language{@lang}">
                        <span>
                            <xsl:call-template name="HandleFreeTextBeforeAndFontOverrides">
                                <xsl:with-param name="freeLayout" select="$freeLayout"/>
                            </xsl:call-template>
                            <xsl:apply-templates>
                                <xsl:with-param name="originalContext" select="$originalContext"/>
                            </xsl:apply-templates>
                            <xsl:call-template name="HandleFreeTextAfterInside">
                                <xsl:with-param name="freeLayout" select="$freeLayout"/>
                            </xsl:call-template>
                        </span>
                    </span>
                    <xsl:call-template name="HandleFreeTextAfterOutside">
                        <xsl:with-param name="freeLayout" select="$freeLayout"/>
                    </xsl:call-template>
                </td>
                <xsl:if test="$sInterlinearSourceStyle='AfterFree' and not(following-sibling::free) and $mode!='NoTextRef'">
                    <xsl:if test="name(../..)='example'  or name(../..)='listInterlinear' or ancestor::interlinear[@textref]">
                        <td>
                            <xsl:call-template name="OutputInterlinearTextReference">
                                <xsl:with-param name="sRef" select="../@textref"/>
                                <xsl:with-param name="sSource" select="../interlinearSource"/>
                            </xsl:call-template>
                        </td>
                    </xsl:if>
                </xsl:if>
            </tr>
        </table>
        <xsl:if test="$sInterlinearSourceStyle='UnderFree' and not(following-sibling::free) and $mode!='NoTextRef'">
            <xsl:if test="name(../..)='example' or name(../..)='listInterlinear' or ancestor::interlinear[@textref]">
                <xsl:if test="../interlinearSource or string-length(normalize-space(../@textref)) &gt; 0">
                    <table>
                        <tr>
                            <td>
                                <xsl:call-template name="OutputInterlinearTextReference">
                                    <xsl:with-param name="sRef" select="../@textref"/>
                                    <xsl:with-param name="sSource" select="../interlinearSource"/>
                                </xsl:call-template>
                            </td>
                        </tr>
                    </table>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        DoInterlinearRefCitation
    -->
    <xsl:template name="DoInterlinearRefCitation">
        <xsl:param name="sRef"/>
        <span>
            <a>
                <xsl:call-template name="DoInterlinearTextReferenceLink">
                    <xsl:with-param name="sRef" select="$sRef"/>
                    <xsl:with-param name="sExtension" select="'htm'"/>
                </xsl:call-template>
                <xsl:attribute name="class">
                    <xsl:text>interlinearRefLinkLayout interlinearSourceStyle</xsl:text>
                </xsl:attribute>
                <xsl:variable name="interlinearSourceStyleLayout" select="$contentLayoutInfo/interlinearSourceStyle"/>
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
                </xsl:call-template>
                <xsl:call-template name="DoInterlinearRefCitationContent">
                    <xsl:with-param name="sRef" select="$sRef"/>
                </xsl:call-template>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
                </xsl:call-template>
            </a>
        </span>
    </xsl:template>
    <!--  
        DoInterlinearSource
    -->
    <xsl:template name="DoInterlinearSource">
        <xsl:param name="interlinearSourceStyleLayout"/>
        <xsl:attribute name="style">
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$interlinearSourceStyleLayout"/>
            </xsl:call-template>
        </xsl:attribute>
        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
            <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
            <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        DoItemRefLabel
    -->
    <xsl:template name="DoItemRefLabel">
        <xsl:param name="sLabel"/>
        <xsl:param name="sDefault"/>
        <xsl:param name="sOverride"/>
        <xsl:choose>
            <xsl:when test="string-length($sOverride) &gt; 0">
                <xsl:value-of select="$sOverride"/>
            </xsl:when>
            <xsl:when test="string-length($sLabel) &gt; 0">
                <xsl:value-of select="$sLabel"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sDefault"/>
            </xsl:otherwise>
        </xsl:choose>
        <!--        <xsl:text>&#xa0;</xsl:text>-->
    </xsl:template>
    <!--  
        DoPageBreakFormatInfo
    -->
    <xsl:template name="DoPageBreakFormatInfo">
        <xsl:param name="layoutInfo"/>
        <!--  handled in CSS now -->
        <!--        <xsl:if test="$layoutInfo/@pagebreakbefore='yes' or $layoutInfo/@startonoddpage='yes'">
            <hr/>
        </xsl:if>
-->
        <!--        <xsl:if test="$layoutInfo/@startonoddpage='yes'">
            <!-\-       <xsl:attribute name="break-before">
                <xsl:text>odd-page</xsl:text>
            </xsl:attribute>
     -\->
        </xsl:if>
-->
    </xsl:template>
    <!--  
        DoReferences
    -->
    <xsl:template name="DoReferences">
        <xsl:variable name="refAuthors" select="//refAuthor"/>
        <xsl:variable name="directlyCitedAuthors" select="$refAuthors[refWork/@id=//citation[not(ancestor::comment)]/@ref]"/>
        <xsl:if test="$directlyCitedAuthors">
            <xsl:call-template name="OutputBackMatterItemTitle">
                <xsl:with-param name="sId" select="'rXLingPapReferences'"/>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputReferencesLabel"/>
                </xsl:with-param>
                <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/referencesTitleLayout"/>
            </xsl:call-template>
            <div class="references">
                <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacereferences='yes'">
                    <xsl:attribute name="style">
                        <xsl:call-template name="DoSinglespacing"/>
                    </xsl:attribute>
                </xsl:if>
                <!--            <xsl:for-each select="//refAuthor[refWork/@id=//citation[not(ancestor::comment)]/@ref]">
                <xsl:variable name="works" select="refWork[@id=//citation[not(ancestor::comment)]/@ref]"/>
                <xsl:for-each select="$works">
            -->
                <xsl:call-template name="DoRefAuthors"/>
            </div>
        </xsl:if>
    </xsl:template>
    <!--  
        DoRefWorks
    -->
    <xsl:template name="DoRefWorks">
        <xsl:variable name="thisAuthor" select="."/>
        <xsl:variable name="works" select="refWork[@id=$citations[not(ancestor::comment)][not(ancestor::refWork) or ancestor::refWork[@id=$citations[not(ancestor::refWork)]/@ref]]/@ref] | $refWorks[@id=saxon:node-set($collOrProcVolumesToInclude)/refWork/@id][parent::refAuthor=$thisAuthor]"/>
        <xsl:for-each select="$works">
            <xsl:variable name="work" select="."/>
            <div id="{@id}">
                <!--  Is this still needed?                <xsl:if test="$referencesLayoutInfo/@defaultfontsize">
                    <xsl:attribute name="font-size">
                        <xsl:call-template name="AdjustFontSizePerMagnification">
                            <xsl:with-param name="sFontSize" select="$referencesLayoutInfo/@defaultfontsize"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </xsl:if>
-->
                <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacereferencesbetween='no'">
                    <xsl:attribute name="space-after">
                        <xsl:variable name="sExtraSpace">
                            <xsl:choose>
                                <xsl:when test="$sLineSpacing='double'">
                                    <xsl:value-of select="$sBasicPointSize"/>
                                </xsl:when>
                                <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                                    <xsl:value-of select=" number($sBasicPointSize div 2)"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="$sExtraSpace"/>
                        <xsl:text>pt</xsl:text>
                    </xsl:attribute>
                </xsl:if>
                <xsl:call-template name="DoAuthorLayout">
                    <xsl:with-param name="referencesLayoutInfo" select="$referencesLayoutInfo"/>
                    <xsl:with-param name="work" select="$work"/>
                    <xsl:with-param name="works" select="$works"/>
                    <xsl:with-param name="iPos" select="position()"/>
                </xsl:call-template>
                <xsl:apply-templates select="book | collection | dissertation | article | fieldNotes | ms | paper | proceedings | thesis | webPage"/>
            </div>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoSection
    -->
    <xsl:template name="DoSection">
        <xsl:param name="layoutInfo"/>
        <xsl:variable name="formatTitleLayoutInfo" select="$layoutInfo/*[name()!='numberLayout'][1]"/>
        <xsl:variable name="numberLayoutInfo" select="$layoutInfo/numberLayout"/>
        <xsl:choose>
            <xsl:when test="$layoutInfo/@ignore='yes'">
                <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
            </xsl:when>
            <xsl:when test="$layoutInfo/@beginsparagraph='yes'">
                <xsl:call-template name="DoSectionBeginsParagraph">
                    <xsl:with-param name="formatTitleLayoutInfo" select="$formatTitleLayoutInfo"/>
                    <xsl:with-param name="numberLayoutInfo" select="$numberLayoutInfo"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoSectionAsTitle">
                    <xsl:with-param name="formatTitleLayoutInfo" select="$formatTitleLayoutInfo"/>
                    <xsl:with-param name="numberLayoutInfo" select="$numberLayoutInfo"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      DoSectionAsTitle
   -->
    <xsl:template name="DoSectionAsTitle">
        <xsl:param name="formatTitleLayoutInfo"/>
        <xsl:param name="numberLayoutInfo"/>
        <div id="{@id}">
            <xsl:attribute name="class">
                <xsl:text>sectionTitle</xsl:text>
                <xsl:value-of select="name()"/>
            </xsl:attribute>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
            </xsl:call-template>
            <xsl:call-template name="DoType"/>
            <!-- put title in marker so it can show up in running header -->
            <!--            <fo:marker marker-class-name="section-title">
                <xsl:call-template name="DoSecTitleRunningHeader"/>
            </fo:marker>
-->
            <span>
                <xsl:call-template name="OutputSectionNumber">
                    <xsl:with-param name="layoutInfo" select="$numberLayoutInfo"/>
                </xsl:call-template>
                <xsl:call-template name="OutputSectionTitle"/>
            </span>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
            </xsl:call-template>
        </div>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <!--  
      DoSectionBeginsParagraph
   -->
    <xsl:template name="DoSectionBeginsParagraph">
        <xsl:param name="formatTitleLayoutInfo"/>
        <xsl:param name="numberLayoutInfo"/>
        <p id="{@id}" class="paragraph_indent">
            <!-- put title in marker so it can show up in running header -->
            <!--            <fo:marker marker-class-name="section-title">
                <xsl:call-template name="DoSecTitleRunningHeader"/>
            </fo:marker>
-->
            <span class="number{name()}">
                <xsl:call-template name="OutputSectionNumber">
                    <xsl:with-param name="layoutInfo" select="$numberLayoutInfo"/>
                </xsl:call-template>
            </span>
            <span class="sectionTitle{name()}">
                <xsl:call-template name="DoTitleFormatInfo">
                    <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
                </xsl:call-template>
                <xsl:call-template name="OutputSectionTitle"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
                </xsl:call-template>
            </span>
            <!--            <xsl:text>.  </xsl:text>-->
            <xsl:apply-templates select="child::node()[name()!='secTitle'][1][name()='p']" mode="contentOnly"/>
        </p>
        <xsl:choose>
            <xsl:when test="child::node()[name()!='secTitle'][1][name()='p']">
                <xsl:apply-templates select="child::node()[name()!='secTitle'][position()&gt;1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  DoSecTitleRunningHeader
-->
    <xsl:template name="DoSecTitleRunningHeader">
        <xsl:variable name="shortTitle" select="shortTitle"/>
        <xsl:choose>
            <xsl:when test="string-length($shortTitle) &gt; 0">
                <xsl:apply-templates select="$shortTitle" mode="InMarker"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="secTitle" mode="InMarker"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoSinglespacing
    -->
    <xsl:template name="DoSinglespacing">
        <xsl:text>line-height:</xsl:text>
        <xsl:value-of select="$sSinglespacingLineHeight"/>
        <xsl:text>;</xsl:text>
    </xsl:template>
    <!--  
      DoSpaceBeforeAfter
   -->
    <xsl:template name="DoSpaceBeforeAfter">
        <xsl:param name="layoutInfo"/>
        <xsl:if test="string-length($layoutInfo/@spacebefore) &gt; 0">
            <xsl:attribute name="space-before">
                <xsl:value-of select="$layoutInfo/@spacebefore"/>
            </xsl:attribute>
            <xsl:attribute name="space-before.conditionality">retain</xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length($layoutInfo/@spaceafter) &gt; 0">
            <xsl:attribute name="space-after">
                <xsl:value-of select="$layoutInfo/@spaceafter"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!--  
        DoTableNumbered
    -->
    <xsl:template name="DoTableNumbered">
        <div id="{@id}">
            <xsl:call-template name="SetTableAlignCSS"/>
            <xsl:attribute name="style">
                <xsl:call-template name="DoType"/>
                <xsl:call-template name="OutputTypeAttributes">
                    <xsl:with-param name="sList" select="@cssSpecial"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:if test="$contentLayoutInfo/tablenumberedLayout/@captionLocation='before' or not($contentLayoutInfo/tablenumberedLayout) and $lingPaper/@tablenumberedLabelAndCaptionLocation='before'">
                <div class="tablenumberedCaptionLayout">
                    <xsl:call-template name="OutputTableNumberedLabelAndCaption"/>
                </div>
            </xsl:if>
            <xsl:apply-templates select="*[name()!='shortCaption']"/>
            <xsl:if test="$contentLayoutInfo/tablenumberedLayout/@captionLocation='after' or not($contentLayoutInfo/tablenumberedLayout) and $lingPaper/@tablenumberedLabelAndCaptionLocation='after'">
                <div class="tablenumberedCaptionLayout">
                    <xsl:call-template name="OutputTableNumberedLabelAndCaption"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>
    <!--  
        DoTitleFormatInfo
    -->
    <xsl:template name="DoTitleFormatInfo">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="bCheckPageBreakFormatInfo" select="'N'"/>
        <xsl:if test="$bCheckPageBreakFormatInfo='Y'">
            <xsl:call-template name="DoPageBreakFormatInfo">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="DoFrontMatterFormatInfo">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        GetBestLayout
    -->
    <xsl:template name="GetBestLayout">
        <xsl:param name="iPos"/>
        <xsl:param name="iLayouts"/>
        <xsl:choose>
            <xsl:when test="$iPos &gt; $iLayouts">
                <xsl:value-of select="$iLayouts"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$iPos"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        HandleSectionNumberOutput
    -->
    <xsl:template name="HandleSectionNumberOutput">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="bAppendix"/>
        <xsl:if test="$layoutInfo">
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$bAppendix='Y'">
                <xsl:apply-templates select="." mode="numberAppendix"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="number"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$layoutInfo">
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
      HandleSmallCaps
   -->
    <xsl:template name="HandleSmallCaps">
        <xsl:choose>
            <xsl:when test="$sFileName = 'XEP'">
                <!-- HACK for RenderX XEP: it does not (yet) support small-caps -->
                <!-- Use font-size:smaller and do a text-transform to uppercase -->
                <xsl:attribute name="font-size">
                    <xsl:text>smaller</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="text-transform">
                    <xsl:text>uppercase</xsl:text>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="font-variant">
                    <xsl:text>small-caps</xsl:text>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      OutputAbbreviationInCommaSeparatedList
   -->
    <xsl:template name="OutputAbbreviationInCommaSeparatedList">
        <span id="{@id}">
            <xsl:call-template name="OutputAbbrTerm">
                <xsl:with-param name="abbr" select="."/>
            </xsl:call-template>
            <xsl:text> = </xsl:text>
            <xsl:call-template name="OutputAbbrDefinition">
                <xsl:with-param name="abbr" select="."/>
            </xsl:call-template>
        </span>
        <xsl:choose>
            <xsl:when test="position() = last()">
                <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>, </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      OutputAbbrTerm
   -->
    <xsl:template name="OutputAbbrTerm">
        <xsl:param name="abbr"/>
        <xsl:variable name="sAbbrTerm">
            <xsl:choose>
                <xsl:when test="string-length($abbrLang) &gt; 0">
                    <xsl:choose>
                        <xsl:when test="string-length($abbr//abbrInLang[@lang=$abbrLang]/abbrTerm) &gt; 0">
                            <xsl:value-of select="$abbr/abbrInLang[@lang=$abbrLang]/abbrTerm"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- a language is specified, but this abbreviation does not have anything; try using the default;
                        this assumes that something is better than nothing -->
                            <xsl:value-of select="$abbr/abbrInLang[1]/abbrTerm"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!--  no language specified; just use the first one -->
                    <xsl:value-of select="$abbr/abbrInLang[1]/abbrTerm"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <span class="abbreviations">
            <!--            <xsl:if test="$abbreviations/@usesmallcaps='yes'">
                <xsl:call-template name="HandleSmallCaps"/>
            </xsl:if>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$abbreviations"/>
            </xsl:call-template>
-->
            <xsl:value-of select="$sAbbrTerm"/>
        </span>
    </xsl:template>
    <!--
        OutputAnyTextBeforeFigureRef
    -->
    <xsl:template name="OutputAnyTextBeforeFigureRef">
        <!-- output any canned text before the section reference -->
        <xsl:variable name="ssingular" select="'figure '"/>
        <xsl:variable name="splural" select="'figures '"/>
        <xsl:variable name="sSingular" select="'Figure '"/>
        <xsl:variable name="sPlural" select="'Figures '"/>
        <xsl:variable name="figureRefLayout" select="$contentLayoutInfo/figureRefLayout"/>
        <xsl:variable name="singularOverride" select="$figureRefLayout/@textBeforeSingularOverride"/>
        <xsl:variable name="pluralOverride" select="$figureRefLayout/@textBeforePluralOverride"/>
        <xsl:variable name="capitalizedSingularOverride" select="$figureRefLayout/@textBeforeCapitalizedSingularOverride"/>
        <xsl:variable name="capitalizedPluralOverride" select="$figureRefLayout/@textBeforeCapitalizedPluralOverride"/>
        <xsl:choose>
            <xsl:when test="@textBefore='useDefault'">
                <xsl:choose>
                    <xsl:when test="$lingPaper/@figureRefDefault='none'">
                        <!-- do nothing -->
                    </xsl:when>
                    <xsl:when test="$lingPaper/@figureRefDefault='singular'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@figureRefSingularLabel"/>
                            <xsl:with-param name="sDefault" select="$ssingular"/>
                            <xsl:with-param name="sOverride" select="$singularOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@figureRefDefault='capitalizedSingular'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@figureRefCapitalizedSingularLabel"/>
                            <xsl:with-param name="sDefault" select="$sSingular"/>
                            <xsl:with-param name="sOverride" select="$capitalizedSingularOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@figureRefDefault='plural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@figureRefPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$splural"/>
                            <xsl:with-param name="sOverride" select="$pluralOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@figureRefDefault='capitalizedPlural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@figureRefCapitalizedPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$sPlural"/>
                            <xsl:with-param name="sOverride" select="$capitalizedPluralOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@textBefore='singular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@figureRefSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$ssingular"/>
                    <xsl:with-param name="sOverride" select="$singularOverride"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedSingular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@figureRefCapitalizedSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$sSingular"/>
                    <xsl:with-param name="sOverride" select="$capitalizedSingularOverride"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='plural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@figureRefPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$splural"/>
                    <xsl:with-param name="sOverride" select="$pluralOverride"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedPlural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@figureRefCapitalizedPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$sPlural"/>
                    <xsl:with-param name="sOverride" select="$capitalizedPluralOverride"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        OutputAnyTextBeforeSectionRef
    -->
    <xsl:template name="OutputAnyTextBeforeSectionRef">
        <!-- output any canned text before the section reference -->
        <xsl:variable name="ssingular" select="'section '"/>
        <xsl:variable name="splural" select="'sections '"/>
        <xsl:variable name="sSingular" select="'Section '"/>
        <xsl:variable name="sPlural" select="'Sections '"/>
        <xsl:variable name="sectionRefLayout" select="$contentLayoutInfo/sectionRefLayout"/>
        <xsl:variable name="singularOverride" select="$sectionRefLayout/@textBeforeSingularOverride"/>
        <xsl:variable name="pluralOverride" select="$sectionRefLayout/@textBeforePluralOverride"/>
        <xsl:variable name="capitalizedSingularOverride" select="$sectionRefLayout/@textBeforeCapitalizedSingularOverride"/>
        <xsl:variable name="capitalizedPluralOverride" select="$sectionRefLayout/@textBeforeCapitalizedPluralOverride"/>
        <xsl:choose>
            <xsl:when test="@textBefore='useDefault'">
                <xsl:choose>
                    <xsl:when test="$lingPaper/@sectionRefDefault='none'">
                        <!-- do nothing -->
                    </xsl:when>
                    <xsl:when test="$lingPaper/@sectionRefDefault='singular'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefSingularLabel"/>
                            <xsl:with-param name="sDefault" select="$ssingular"/>
                            <xsl:with-param name="sOverride" select="$singularOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@sectionRefDefault='capitalizedSingular'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedSingularLabel"/>
                            <xsl:with-param name="sDefault" select="$sSingular"/>
                            <xsl:with-param name="sOverride" select="$capitalizedSingularOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@sectionRefDefault='plural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$splural"/>
                            <xsl:with-param name="sOverride" select="$pluralOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@sectionRefDefault='capitalizedPlural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$sPlural"/>
                            <xsl:with-param name="sOverride" select="$capitalizedPluralOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@textBefore='singular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$ssingular"/>
                    <xsl:with-param name="sOverride" select="$singularOverride"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedSingular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$sSingular"/>
                    <xsl:with-param name="sOverride" select="$capitalizedSingularOverride"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='plural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$splural"/>
                    <xsl:with-param name="sOverride" select="$pluralOverride"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedPlural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$sPlural"/>
                    <xsl:with-param name="sOverride" select="$capitalizedPluralOverride"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        OutputAnyTextBeforeTablenumberedRef
    -->
    <xsl:template name="OutputAnyTextBeforeTablenumberedRef">
        <!-- output any canned text before the section reference -->
        <xsl:variable name="ssingular" select="'table '"/>
        <xsl:variable name="splural" select="'tables '"/>
        <xsl:variable name="sSingular" select="'Table '"/>
        <xsl:variable name="sPlural" select="'Tables '"/>
        <xsl:variable name="tablenumberedRefLayout" select="$contentLayoutInfo/tablenumberedRefLayout"/>
        <xsl:variable name="singularOverride" select="$tablenumberedRefLayout/@textBeforeSingularOverride"/>
        <xsl:variable name="pluralOverride" select="$tablenumberedRefLayout/@textBeforePluralOverride"/>
        <xsl:variable name="capitalizedSingularOverride" select="$tablenumberedRefLayout/@textBeforeCapitalizedSingularOverride"/>
        <xsl:variable name="capitalizedPluralOverride" select="$tablenumberedRefLayout/@textBeforeCapitalizedPluralOverride"/>
        <xsl:choose>
            <xsl:when test="@textBefore='useDefault'">
                <xsl:choose>
                    <xsl:when test="$lingPaper/@tablenumberedRefDefault='none'">
                        <!-- do nothing -->
                    </xsl:when>
                    <xsl:when test="$lingPaper/@tablenumberedRefDefault='singular'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefSingularLabel"/>
                            <xsl:with-param name="sDefault" select="$ssingular"/>
                            <xsl:with-param name="sOverride" select="$singularOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@tablenumberedRefDefault='capitalizedSingular'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefCapitalizedSingularLabel"/>
                            <xsl:with-param name="sDefault" select="$sSingular"/>
                            <xsl:with-param name="sOverride" select="$capitalizedSingularOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@tablenumberedRefDefault='plural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$splural"/>
                            <xsl:with-param name="sOverride" select="$pluralOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@tablenumberedRefDefault='capitalizedPlural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefCapitalizedPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$sPlural"/>
                            <xsl:with-param name="sOverride" select="$capitalizedPluralOverride"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@textBefore='singular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$ssingular"/>
                    <xsl:with-param name="sOverride" select="$singularOverride"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedSingular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefCapitalizedSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$sSingular"/>
                    <xsl:with-param name="sOverride" select="$capitalizedSingularOverride"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='plural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$splural"/>
                    <xsl:with-param name="sOverride" select="$pluralOverride"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedPlural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefCapitalizedPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$sPlural"/>
                    <xsl:with-param name="sOverride" select="$capitalizedPluralOverride"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
                   OutputBackMatterItemTitle
-->
    <xsl:template name="OutputBackMatterItemTitle">
        <xsl:param name="sId"/>
        <xsl:param name="sLabel"/>
        <xsl:param name="layoutInfo"/>
        <xsl:choose>
            <xsl:when test="$bIsBook">
                <div id="{$sId}" class="{name()}Title">
                    <xsl:call-template name="DoTitleFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputChapTitle">
                        <xsl:with-param name="sTitle" select="$sLabel"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    </xsl:call-template>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div id="{$sId}" class="{name()}Title">
                    <xsl:call-template name="DoType"/>
                    <xsl:call-template name="DoTitleFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
                    </xsl:call-template>
                    <!--                    <fo:marker marker-class-name="section-title">
                        <xsl:value-of select="$sLabel"/>
                    </fo:marker>
-->
                    <span>
                        <xsl:value-of select="$sLabel"/>
                    </span>
                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    </xsl:call-template>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputChapterNumber
-->
    <xsl:template name="OutputChapterNumber">
        <xsl:param name="fDoTextAfterLetter" select="'Y'"/>
        <xsl:param name="fIgnoreTextAfterLetter" select="'N'"/>
        <xsl:choose>
            <xsl:when test="name()='chapter'">
                <xsl:apply-templates select="." mode="numberChapter"/>
            </xsl:when>
            <xsl:when test="name()='chapterBeforePart'">
                <xsl:text>0</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="appLayout" select="$backMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                <xsl:if test="$appLayout/@showletter!='no'">
                    <xsl:apply-templates select="." mode="numberAppendix"/>
                    <xsl:choose>
                        <xsl:when test="$fIgnoreTextAfterLetter='Y'">
                            <!-- do nothing -->
                        </xsl:when>
                        <xsl:when test="$fDoTextAfterLetter='Y'">
                            <xsl:value-of select="$appLayout/@textafterletter"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>&#xa0;</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputChapterStaticContent
-->
    <xsl:template name="OutputChapterStaticContent">
        <xsl:param name="layoutInfo"/>
        <!--        <xsl:call-template name="DoHeaderAndFooter">
            <xsl:with-param name="layoutInfo" select="$layoutInfo/headerFooterFirstPage"/>
            <xsl:with-param name="layoutInfoParentWithFontInfo" select="$layoutInfo"/>
            <xsl:with-param name="sFlowName" select="'ChapterFirstPage'"/>
        </xsl:call-template>
        <xsl:call-template name="DoHeaderAndFooter">
            <xsl:with-param name="layoutInfo" select="$layoutInfo/headerFooterPage"/>
            <xsl:with-param name="layoutInfoParentWithFontInfo" select="$layoutInfo"/>
            <xsl:with-param name="sFlowName" select="'ChapterRegularPage'"/>
        </xsl:call-template>
        <xsl:call-template name="DoHeaderAndFooter">
            <xsl:with-param name="layoutInfo" select="$layoutInfo/headerFooterOddEvenPages/headerFooterEvenPage"/>
            <xsl:with-param name="layoutInfoParentWithFontInfo" select="$layoutInfo"/>
            <xsl:with-param name="sFlowName" select="'ChapterEvenPage'"/>
        </xsl:call-template>
        <xsl:call-template name="DoHeaderAndFooter">
            <xsl:with-param name="layoutInfo" select="$layoutInfo/headerFooterOddEvenPages/headerFooterOddPage"/>
            <xsl:with-param name="layoutInfoParentWithFontInfo" select="$layoutInfo"/>
            <xsl:with-param name="sFlowName" select="'ChapterOddPage'"/>
        </xsl:call-template>
        <xsl:call-template name="DoFootnoteSeparatorStaticContent"/>
-->
    </xsl:template>
    <!--  
      OutputChapterStaticContentForBackMatter
   -->
    <xsl:template name="OutputChapterStaticContentForBackMatter">
        <!--        <xsl:choose>
            <xsl:when test="$backMatterLayoutInfo/headerFooterPageStyles">
                <xsl:call-template name="OutputChapterStaticContent">
                    <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/headerFooterPageStyles"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputChapterStaticContent">
                    <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/headerFooterPageStyles"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
-->
    </xsl:template>
    <!--  
                  OutputChapTitle
-->
    <xsl:template name="OutputChapTitle">
        <xsl:param name="sTitle"/>
        <!--      <div span="all">-->
        <xsl:value-of select="$sTitle"/>
        <!--      </div>-->
    </xsl:template>
    <!--  
        OutputTableNumberedLabel
    -->
    <xsl:template name="OutputTableNumberedLabel">
        <xsl:variable name="styleSheetLabelLayout" select="$styleSheetTableNumberedLabelLayout"/>
        <xsl:variable name="styleSheetLabelLayoutLabel" select="$styleSheetLabelLayout/@label"/>
        <xsl:variable name="label" select="$lingPaper/@tablenumberedLabel"/>
        <span>
            <xsl:value-of select="$styleSheetLabelLayout/@textbefore"/>
            <xsl:choose>
                <xsl:when test="string-length($styleSheetLabelLayoutLabel) &gt; 0">
                    <xsl:value-of select="$styleSheetLabelLayoutLabel"/>
                </xsl:when>
                <xsl:when test="string-length($label) &gt; 0">
                    <xsl:value-of select="$label"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Table</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$styleSheetLabelLayout/@textafter"/>
        </span>
    </xsl:template>
    <!--  
        OutputTableNumberedLabelAndCaption
    -->
    <xsl:template name="OutputTableNumberedLabelAndCaption">
        <xsl:param name="bDoStyles" select="'Y'"/>
        <span>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:attribute name="class">tablenumberedLabelLayout</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputTableNumberedLabel"/>
        </span>
        <span>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:attribute name="class">figureNumberLayout</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$styleSheetTableNumberedNumberLayout/@textbefore"/>
            <xsl:apply-templates select="." mode="tablenumbered"/>
            <xsl:value-of select="$styleSheetTableNumberedNumberLayout/@textafter"/>
        </span>
        <span>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:attribute name="class">tablenumberedCaptionLayout</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$styleSheetTableNumberedCaptionLayout/@textbefore"/>
            <xsl:choose>
                <xsl:when test="$bDoStyles='Y'">
                    <xsl:apply-templates select="table/caption | table/endCaption" mode="show">
                        <xsl:with-param name="styleSheetLabelLayout" select="$contentLayoutInfo/tablenumberedLabelLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="table/caption | table/endCaption" mode="contents"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$styleSheetTableNumberedCaptionLayout/@textafter"/>
        </span>
    </xsl:template>
    <!--  
                  OutputTypeAttributes
-->
    <xsl:template name="OutputTypeAttributes">
        <xsl:param name="sList"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:if test="string-length($sFirst) &gt; 0 and contains($sFirst, '=')">
            <xsl:variable name="sAttr" select="substring-before($sFirst,'=')"/>
            <xsl:variable name="sValue" select="substring($sFirst,string-length($sAttr) + 3, string-length($sFirst) - string-length($sAttr) - 3)"/>
            <xsl:attribute name="{$sAttr}">
                <xsl:value-of select="$sValue"/>
            </xsl:attribute>
            <xsl:if test="$sRest">
                <xsl:call-template name="OutputTypeAttributes">
                    <xsl:with-param name="sList" select="$sRest"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
                  OutputExampleNumber
-->
    <xsl:template name="OutputExampleNumber">
        <xsl:element name="a">
            <xsl:attribute name="name">
                <xsl:value-of select="../../@num"/>
            </xsl:attribute>
            <xsl:text>(</xsl:text>
            <xsl:call-template name="GetExampleNumber">
                <xsl:with-param name="example" select="."/>
            </xsl:call-template>
            <xsl:text>)</xsl:text>
        </xsl:element>
    </xsl:template>
    <!--  
        OutputFigureLabel
    -->
    <xsl:template name="OutputFigureLabel">
        <xsl:variable name="styleSheetLabelLayout" select="$styleSheetFigureLabelLayout"/>
        <xsl:variable name="styleSheetLabelLayoutLabel" select="$styleSheetLabelLayout/@label"/>
        <xsl:variable name="label" select="$lingPaper/@figureLabel"/>
        <span>
            <xsl:value-of select="$styleSheetLabelLayout/@textbefore"/>
            <xsl:choose>
                <xsl:when test="string-length($styleSheetLabelLayoutLabel) &gt; 0">
                    <xsl:value-of select="$styleSheetLabelLayoutLabel"/>
                </xsl:when>
                <xsl:when test="string-length($label) &gt; 0">
                    <xsl:value-of select="$label"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Figure</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$styleSheetLabelLayout/@textafter"/>
        </span>
    </xsl:template>
    <!--  
        OutputFigureLabelAndCaption
    -->
    <xsl:template name="OutputFigureLabelAndCaption">
        <xsl:param name="bDoStyles" select="'Y'"/>
        <span>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:attribute name="class">figureLabelLayout</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputFigureLabel"/>
        </span>
        <span>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:attribute name="class">figureNumberLayout</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$styleSheetFigureNumberLayout/@textbefore"/>
            <xsl:apply-templates select="." mode="figure"/>
            <xsl:value-of select="$styleSheetFigureNumberLayout/@textafter"/>
        </span>
        <span>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:attribute name="class">figureCaptionLayout</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$styleSheetFigureCaptionLayout/@textbefore"/>
            <xsl:choose>
                <xsl:when test="$bDoStyles='Y'">
                    <xsl:apply-templates select="caption" mode="show"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="caption" mode="contents"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$styleSheetFigureCaptionLayout/@textafter"/>
        </span>
    </xsl:template>
    <xsl:template match="caption | endCaption" mode="show">
        <xsl:param name="styleSheetLabelLayout" select="$contentLayoutInfo/figureLabelLayout"/>
        <xsl:choose>
            <xsl:when test="ancestor::tablenumbered or ancestor::figure">
                <span>
                    <xsl:attribute name="style">
                        <xsl:call-template name="DoType"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <tr>
                    <xsl:attribute name="style">
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="."/>
                        </xsl:call-template>
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="$styleSheetLabelLayout"/>
                        </xsl:call-template>
                        <xsl:call-template name="DoType"/>
                    </xsl:attribute>
                    <td colspan="30">
                        <xsl:call-template name="DoCellAttributes"/>
                        <b>
                            <!-- default is bold -->
                            <xsl:apply-templates/>
                        </b>
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputFrontOrBackMatterTitle
-->
    <xsl:template name="OutputFrontOrBackMatterTitle">
        <xsl:param name="id"/>
        <xsl:param name="sTitle"/>
        <xsl:param name="bIsBook" select="'Y'"/>
        <xsl:param name="bForcePageBreak" select="'N'"/>
        <xsl:param name="layoutInfo"/>
        <xsl:param name="sMarkerClassName"/>
        <xsl:if test="not($layoutInfo/@useLabel) or $layoutInfo/@useLabel='yes'">
            <xsl:if test="$bIsBook='Y'">
                <!--            <fo:marker marker-class-name="{$sMarkerClassName}">
                <xsl:value-of select="$sTitle"/>
            </fo:marker>
-->
            </xsl:if>
            <div>
                <xsl:attribute name="id">
                    <xsl:value-of select="$id"/>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:value-of select="name()"/>
                    <xsl:if test="name()='acknowledgements'">
                        <xsl:value-of select="name(parent::*)"/>
                    </xsl:if>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$bIsBook='Y'">
                        <xsl:call-template name="DoTitleFormatInfo">
                            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        </xsl:call-template>
                        <xsl:call-template name="OutputChapTitle">
                            <xsl:with-param name="sTitle" select="$sTitle"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="DoTitleFormatInfo">
                            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                            <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
                        </xsl:call-template>
                        <!-- put title in marker so it can show up in running header -->
                        <!--                    <fo:marker marker-class-name="{$sMarkerClassName}">
                        <xsl:value-of select="$sTitle"/>
                    </fo:marker>
-->
                        <span>
                            <xsl:value-of select="$sTitle"/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                </xsl:call-template>
            </div>
        </xsl:if>
    </xsl:template>
    <!--
        OutputIndexedItemsRange
    -->
    <xsl:template name="OutputIndexedItemsRange">
        <xsl:param name="sIndexedItemID"/>
        <xsl:variable name="sBeginSectionNumber">
            <!-- output section number of lowest-level section containing the indexedItem -->
            <xsl:call-template name="OutputIndexedItemsSectionNumber"/>
        </xsl:variable>
        <a href="#{$sIndexedItemID}">
            <xsl:value-of select="$sBeginSectionNumber"/>
        </a>
        <xsl:if test="name()='indexedRangeBegin'">
            <xsl:variable name="sBeginId" select="@id"/>
            <!-- only use first one because that's all there should be -->
            <xsl:variable name="indexedRangeEnd" select="//indexedRangeEnd[@begin=$sBeginId][1]"/>
            <xsl:variable name="sEndSectionNumber">
                <xsl:for-each select="$indexedRangeEnd">
                    <xsl:call-template name="OutputIndexedItemsSectionNumber"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:if test="$sEndSectionNumber != $sBeginSectionNumber">
                <!-- only output range if the start and end differ -->
                <xsl:text>-</xsl:text>
                <xsl:variable name="sIndexedEndItemID">
                    <xsl:for-each select="$indexedRangeEnd">
                        <xsl:call-template name="CreateIndexedItemID">
                            <xsl:with-param name="sTermId" select="@begin"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:variable>
                <a href="#{$sIndexedEndItemID}">
                    <xsl:value-of select="$sEndSectionNumber"/>
                </a>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--
        OutputIndexedItemsSectionNumber
    -->
    <xsl:template name="OutputIndexedItemsSectionNumber">
        <xsl:choose>
            <xsl:when test="ancestor::section6">
                <xsl:for-each select="ancestor::section6">
                    <xsl:call-template name="OutputSectionNumber"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="ancestor::section5">
                <xsl:for-each select="ancestor::section5">
                    <xsl:call-template name="OutputSectionNumber"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="ancestor::section4">
                <xsl:for-each select="ancestor::section4">
                    <xsl:call-template name="OutputSectionNumber"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="ancestor::section3">
                <xsl:for-each select="ancestor::section3">
                    <xsl:call-template name="OutputSectionNumber"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="ancestor::section2">
                <xsl:for-each select="ancestor::section2">
                    <xsl:call-template name="OutputSectionNumber"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="ancestor::section1">
                <xsl:for-each select="ancestor::section1">
                    <xsl:call-template name="OutputSectionNumber"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="ancestor::chapter">
                <xsl:apply-templates select="ancestor::chapter" mode="number"/>
            </xsl:when>
            <xsl:when test="ancestor::chapterBeforePart">
                <xsl:text>0</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::appendix">
                <xsl:for-each select="ancestor::appendix">
                    <xsl:call-template name="OutputSectionNumber"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="ancestor::part">
                <xsl:apply-templates select="ancestor::part" mode="numberPart"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="ancestor::endnote">
            <xsl:text>n</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--
        OutputIndexTerms
    -->
    <xsl:template name="OutputIndexTerms">
        <xsl:param name="sIndexKind"/>
        <xsl:param name="lang"/>
        <xsl:param name="terms"/>
        <xsl:variable name="indexTermsToShow" select="$terms/indexTerm[@kind=$sIndexKind or @kind='subject' and $sIndexKind='common' or count(//index)=1]"/>
        <xsl:if test="$indexTermsToShow">
            <div class="index">
                <!-- force line break so we can more effectively use a line-oriented differences tool -->
                <xsl:text>&#xA;</xsl:text>
                <xsl:for-each select="$indexTermsToShow">
                    <xsl:sort lang="{$lang}" select="term[@lang=$lang or position()=1 and not (following-sibling::term[@lang=$lang])]"/>
                    <xsl:variable name="sTermId" select="@id"/>
                    <!-- if a nested index term is cited, we need to be sure to show its parents, even if they are not cited -->
                    <xsl:variable name="bHasCitedDescendant">
                        <xsl:for-each select="descendant::indexTerm">
                            <xsl:variable name="sDescendantTermId" select="@id"/>
                            <xsl:if test="//indexedItem[@term=$sDescendantTermId] or //indexedRangeBegin[@term=$sDescendantTermId]">
                                <xsl:text>Y</xsl:text>
                            </xsl:if>
                            <xsl:if test="@see">
                                <xsl:call-template name="CheckSeeTargetIsCitedOrItsDescendantIsCited"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="indexedItems" select="//indexedItem[@term=$sTermId] | //indexedRangeBegin[@term=$sTermId]"/>
                    <xsl:variable name="bHasSeeAttribute">
                        <xsl:if test="string-length(@see) &gt; 0">
                            <xsl:text>Y</xsl:text>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="bSeeTargetIsCitedOrItsDescendantIsCited">
                        <xsl:if test="$bHasSeeAttribute='Y'">
                            <xsl:call-template name="CheckSeeTargetIsCitedOrItsDescendantIsCited"/>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$indexedItems or contains($bHasCitedDescendant,'Y')">
                            <!-- this term or one its descendants is cited; show it -->
                            <a>
                                <xsl:attribute name="name">
                                    <xsl:call-template name="CreateIndexTermID">
                                        <xsl:with-param name="sTermId" select="$sTermId"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:call-template name="OutputIndexTermsTerm">
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="indexTerm" select="."/>
                                </xsl:call-template>
                                <xsl:text>&#xa0;&#xa0;</xsl:text>
                            </a>
                            <xsl:for-each select="$indexedItems">
                                <!-- show each reference -->
                                <xsl:variable name="sIndexedItemID">
                                    <xsl:call-template name="CreateIndexedItemID">
                                        <xsl:with-param name="sTermId" select="$sTermId"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="@main='yes' and count($indexedItems) &gt; 1">
                                        <b>
                                            <xsl:call-template name="OutputIndexedItemsRange">
                                                <xsl:with-param name="sIndexedItemID" select="$sIndexedItemID"/>
                                            </xsl:call-template>
                                        </b>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="OutputIndexedItemsRange">
                                            <xsl:with-param name="sIndexedItemID" select="$sIndexedItemID"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="position()!=last()">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:if test="$bHasSeeAttribute='Y' and contains($bSeeTargetIsCitedOrItsDescendantIsCited, 'Y')">
                                <!-- this term also has a @see attribute which refers to a term that is cited or whose descendant is cited -->
                                <xsl:call-template name="OutputIndexTermSeeBefore">
                                    <xsl:with-param name="indexedItems" select="$indexedItems"/>
                                </xsl:call-template>
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:text>#</xsl:text>
                                        <xsl:call-template name="CreateIndexTermID">
                                            <xsl:with-param name="sTermId" select="@see"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="key('IndexTermID',@see)/term[@lang=$lang or position()=1 and not (following-sibling::term[@lang=$lang])]" mode="InIndex"/>
                                </a>
                                <xsl:call-template name="OutputIndexTermSeeAfter">
                                    <xsl:with-param name="indexedItems" select="$indexedItems"/>
                                </xsl:call-template>
                            </xsl:if>
                            <br/>
                            <xsl:call-template name="OutputIndexTerms">
                                <xsl:with-param name="sIndexKind" select="$sIndexKind"/>
                                <xsl:with-param name="lang" select="$lang"/>
                                <xsl:with-param name="terms" select="indexTerms"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$bHasSeeAttribute='Y' and contains($bSeeTargetIsCitedOrItsDescendantIsCited, 'Y')">
                            <!-- neither this term nor its decendants are cited, but it has a @see attribute which refers to a term that is cited or for which one of its descendants is cited -->
                            <!--                            <xsl:apply-templates select="term[1]" mode="InIndex"/>-->
                            <xsl:apply-templates select="term[@lang=$lang or position()=1 and not (following-sibling::term[@lang=$lang])]" mode="InIndex"/>
                            <xsl:call-template name="OutputIndexTermSeeAloneBefore"/>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:text>#</xsl:text>
                                    <xsl:call-template name="CreateIndexTermID">
                                        <xsl:with-param name="sTermId" select="@see"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:call-template name="OutputIndexTermsTerm">
                                    <xsl:with-param name="lang" select="$lang"/>
                                    <xsl:with-param name="indexTerm" select="key('IndexTermID',@see)"/>
                                </xsl:call-template>
                            </a>
                            <xsl:call-template name="OutputIndexTermSeeAloneAfter"/>
                            <br/>
                            <!-- force line break so we can more effectively use a line-oriented differences tool -->
                            <xsl:text>&#xA;</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputInterlinearTextReference
    -->
    <xsl:template name="OutputInterlinearTextReference">
        <xsl:param name="sRef"/>
        <xsl:param name="sSource"/>
        <!--      <xsl:if test="string-length(normalize-space($sRef)) &gt; 0 or $sSource and string-length(normalize-space($sSource)) &gt; 0">-->
        <xsl:if test="string-length(normalize-space($sRef)) &gt; 0 or $sSource">
            <xsl:choose>
                <xsl:when test="$sInterlinearSourceStyle='UnderFree'">
                    <xsl:call-template name="OutputInterlinearTextReferenceContent">
                        <xsl:with-param name="sSource" select="$sSource"/>
                        <xsl:with-param name="sRef" select="$sRef"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text disable-output-escaping="yes">&#xa0;&#xa0;</xsl:text>
                    <xsl:call-template name="OutputInterlinearTextReferenceContent">
                        <xsl:with-param name="sSource" select="$sSource"/>
                        <xsl:with-param name="sRef" select="$sRef"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputInterlinearTextReferenceContent
    -->
    <xsl:template name="OutputInterlinearTextReferenceContent">
        <xsl:param name="sSource"/>
        <xsl:param name="sRef"/>
        <xsl:choose>
            <xsl:when test="$sSource">
                <xsl:apply-templates select="$sSource" mode="show"/>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($sRef)) &gt; 0">
                <xsl:call-template name="DoInterlinearRefCitation">
                    <xsl:with-param name="sRef" select="$sRef"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputList
    -->
    <xsl:template name="OutputList">
        <xsl:variable name="iLetterCount" select="count(parent::example/listWord | parent::example/listWord)"/>
        <xsl:variable name="sLetterWidth">
            <xsl:choose>
                <xsl:when test="$iLetterCount &lt; 27">1.5</xsl:when>
                <xsl:when test="$iLetterCount &lt; 53">2.5</xsl:when>
                <xsl:otherwise>3</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="ancestor::example">
                <tr>
                    <td>
                        <xsl:call-template name="OutputListProper"/>
                    </td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:call-template name="OutputListProper"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputListProper
    -->
    <xsl:template name="OutputListProper">
        <table>
            <xsl:call-template name="DoDebugExamples"/>
            <!--                <fo:table-column column-number="1">
                <xsl:attribute name="column-width">
                <xsl:value-of select="$sLetterWidth"/>em</xsl:attribute>
                </fo:table-column>
                <!-\-  By not specifiying a width for the second column, it appears to use what is left over 
                (which is what we want). -\->
                <fo:table-column column-number="2"/>
            -->
            <tbody>
                <tr>
                    <xsl:if test="name()='listInterlinear'">
                        <xsl:attribute name="padding-top">
                            <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                    </xsl:if>
                    <td>
                        <xsl:call-template name="DoDebugExamples"/>
                        <div>
                            <xsl:attribute name="id">
                                <xsl:value-of select="@letter"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="." mode="letter"/>
                            <xsl:text>.</xsl:text>
                        </div>
                    </td>
                    <xsl:choose>
                        <xsl:when test="name()='listInterlinear'">
                            <td>
                                <xsl:call-template name="DoDebugExamples"/>
                                <xsl:apply-templates select="child::node()[name()!='interlinearSource']"/>
                            </td>
                        </xsl:when>
                        <xsl:when test="name()='listDefinition'">
                            <td>
                                <xsl:call-template name="DoDebugExamples"/>
                                <div>
                                    <xsl:call-template name="DoType"/>
                                    <xsl:apply-templates/>
                                </div>
                            </td>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="OutputWordOrSingle"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </tr>
                <xsl:for-each select="following-sibling::listWord | following-sibling::listSingle | following-sibling::listInterlinear | following-sibling::listDefinition">
                    <xsl:if test="name()='listInterlinear'">
                        <!-- output a fake row to add spacing between iterlinears -->
                        <tr>
                            <td>
                                <div>&#xa0;</div>
                            </td>
                        </tr>
                    </xsl:if>
                    <tr>
                        <td>
                            <xsl:call-template name="DoDebugExamples"/>
                            <div>
                                <xsl:attribute name="id">
                                    <xsl:value-of select="@letter"/>
                                </xsl:attribute>
                                <xsl:apply-templates select="." mode="letter"/>
                                <xsl:text>.</xsl:text>
                            </div>
                        </td>
                        <xsl:choose>
                            <xsl:when test="name()='listInterlinear'">
                                <td>
                                    <xsl:call-template name="DoDebugExamples"/>
                                    <xsl:apply-templates select="child::node()[name()!='interlinearSource']"/>
                                </td>
                            </xsl:when>
                            <xsl:when test="name()='listDefinition'">
                                <td>
                                    <xsl:call-template name="DoDebugExamples"/>
                                    <div>
                                        <xsl:call-template name="DoType"/>
                                        <xsl:apply-templates/>
                                    </div>
                                </td>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="OutputWordOrSingle"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>
    <!--  
                  OutputSectionNumber
-->
    <xsl:template name="OutputSectionNumber">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="bIsForBookmark" select="'N'"/>
        <xsl:variable name="bAppendix">
            <xsl:for-each select="ancestor::*">
                <xsl:if test="name(.)='appendix'">Y</xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$bIsForBookmark='N'">
                <span>
                    <xsl:call-template name="OutputSectionNumberProper">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        <xsl:with-param name="bAppendix" select="$bAppendix"/>
                    </xsl:call-template>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputSectionNumberProper">
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    <xsl:with-param name="bAppendix" select="$bAppendix"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      OutputSectionNumberAndTitle
   -->
    <xsl:template name="OutputSectionNumberAndTitle">
        <xsl:param name="layoutInfo"/>
        <xsl:call-template name="OutputSectionNumber">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
        <xsl:call-template name="OutputSectionTitle"/>
    </xsl:template>
    <!--  
      OutputSectionNumberAndTitleInContents
   -->
    <xsl:template name="OutputSectionNumberAndTitleInContents">
        <xsl:param name="layoutInfo"/>
        <xsl:call-template name="OutputSectionNumber">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
        <xsl:call-template name="OutputSectionTitleInContents"/>
    </xsl:template>
    <!--  
      OutputSectionTitle
   -->
    <xsl:template name="OutputSectionTitle">
        <xsl:text disable-output-escaping="yes">&#x20;</xsl:text>
        <xsl:apply-templates select="secTitle"/>
    </xsl:template>
    <!--  
      OutputSectionTitleInContents
   -->
    <xsl:template name="OutputSectionTitleInContents">
        <xsl:text disable-output-escaping="yes">&#x20;</xsl:text>
        <xsl:apply-templates select="secTitle" mode="InMarker"/>
    </xsl:template>
    <!--  
                  OutputTableCells
-->
    <xsl:template name="OutputTableCells">
        <xsl:param name="sList"/>
        <xsl:param name="lang"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <td class="language{$lang}" style="{$sExampleCellPadding}">
            <xsl:call-template name="DoDebugExamples"/>
            <xsl:variable name="sContext">
                <xsl:call-template name="GetContextOfItem"/>
            </xsl:variable>
            <xsl:variable name="langDataLayout" select="$contentLayoutInfo/langDataLayout"/>
            <xsl:variable name="glossLayout" select="$contentLayoutInfo/glossLayout"/>
            <xsl:choose>
                <xsl:when test="langData">
                    <xsl:call-template name="HandleLangDataTextBeforeOutside">
                        <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
                        <xsl:with-param name="sLangDataContext" select="$sContext"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="HandleGlossTextBeforeOutside">
                        <xsl:with-param name="glossLayout" select="$glossLayout"/>
                        <xsl:with-param name="sGlossContext" select="$sContext"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <span class="language{$lang}">
                <span>
                    <xsl:choose>
                        <xsl:when test="langData">
                            <xsl:call-template name="HandleLangDataTextBeforeAndFontOverrides">
                                <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
                                <xsl:with-param name="sLangDataContext" select="$sContext"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="HandleGlossTextBeforeAndFontOverrides">
                                <xsl:with-param name="glossLayout" select="$glossLayout"/>
                                <xsl:with-param name="sGlossContext" select="$sContext"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="$sFirst"/>
                    <xsl:choose>
                        <xsl:when test="langData">
                            <xsl:call-template name="HandleLangDataTextAfterInside">
                                <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
                                <xsl:with-param name="sLangDataContext" select="$sContext"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="HandleGlossTextAfterInside">
                                <xsl:with-param name="glossLayout" select="$glossLayout"/>
                                <xsl:with-param name="sGlossContext" select="$sContext"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </span>
            <xsl:choose>
                <xsl:when test="langData">
                    <xsl:call-template name="HandleLangDataTextAfterOutside">
                        <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
                        <xsl:with-param name="sLangDataContext" select="$sContext"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="HandleGlossTextAfterOutside">
                        <xsl:with-param name="glossLayout" select="$glossLayout"/>
                        <xsl:with-param name="sGlossContext" select="$sContext"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <xsl:if test="$sRest">
            <xsl:call-template name="OutputTableCells">
                <xsl:with-param name="sList" select="$sRest"/>
                <xsl:with-param name="lang" select="$lang"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--
                OutputWordOrSingle
-->
    <xsl:template name="OutputWordOrSingle">
        <xsl:choose>
            <xsl:when test="name()='listWord'">
                <xsl:for-each select="langData | gloss">
                    <td xsl:use-attribute-sets="ExampleCell">
                        <xsl:call-template name="DoDebugExamples"/>
                        <div>
                            <xsl:apply-templates select="self::*"/>
                        </div>
                    </td>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="name()='listSingle'">
                <td xsl:use-attribute-sets="ExampleCell">
                    <xsl:call-template name="DoDebugExamples"/>
                    <div>
                        <xsl:for-each select="langData | gloss">
                            <xsl:apply-templates select="self::*"/>
                        </xsl:for-each>
                    </div>
                </td>
            </xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:for-each select="langData | gloss">
                        <xsl:apply-templates select="self::*"/>
                        <xsl:if test="position()!=last()">
                            <span>&#xa0;&#xa0;</span>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  ReverseContent
-->
    <xsl:template name="ReverseContents">
        <xsl:param name="sList"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:if test="$sRest">
            <xsl:call-template name="ReverseContents">
                <xsl:with-param name="sList" select="$sRest"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:value-of select="$sFirst"/>
        <xsl:text>&#x20;</xsl:text>
    </xsl:template>
    <!--  
        SetTableAlignCSS
    -->
    <xsl:template name="SetTableAlignCSS">
        <!--  We do not have a good way to align a table horizontally in a browser, so we're disabling this 
        <xsl:attribute name="class">
            <xsl:text>tableAlign</xsl:text>
            <xsl:choose>
                <xsl:when test="table/@align='center'">
                    <xsl:text>Center</xsl:text>
                </xsl:when>
                <xsl:when test="table/@align='right'">
                    <xsl:text>Right</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Left</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        -->
    </xsl:template>
    <!-- ===========================================================
      ELEMENTS TO IGNORE
      =========================================================== -->
    <xsl:template match="appendix/shortTitle"/>
    <xsl:template match="comment"/>
    <!--<xsl:template match="dd"/>-->
    <xsl:template match="fixedText"/>
    <xsl:template match="language"/>
    <xsl:template match="section1/shortTitle"/>
    <xsl:template match="section2/shortTitle"/>
    <xsl:template match="section3/shortTitle"/>
    <xsl:template match="section4/shortTitle"/>
    <xsl:template match="section5/shortTitle"/>
    <xsl:template match="section6/shortTitle"/>
    <xsl:template match="style"/>
    <xsl:template match="styles"/>
    <xsl:template match="term"/>
    <xsl:template match="textInfo/shortTitle"/>
    <xsl:template match="type"/>
    <!-- ===========================================================
        TRANSFORMS TO INCLUDE
        =========================================================== -->
    <xsl:include href="XLingPapCommon.xsl"/>
    <xsl:include href="XLingPapXHTMLCommon.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetCommon.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetXHTMLCommon.xsl"/>
    <!--    <xsl:include href="XLingPapPublisherStylesheetXHTMLBookmarks.xsl"/>-->
    <xsl:include href="XLingPapPublisherStylesheetXHTMLContents.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetXHTMLReferences.xsl"/>
</xsl:stylesheet>
