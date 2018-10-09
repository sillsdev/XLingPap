<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
    xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:saxon="http://icl.com/saxon">
    <xsl:output method="xml" version="1.0" encoding="utf-8" indent="no"/>
    <!-- ===========================================================
      Parameterized Variables
      =========================================================== -->
    <xsl:param name="sFOProcessor">XEP</xsl:param>
    <xsl:variable name="pageLayoutInfo" select="//publisherStyleSheet[1]/pageLayout"/>
    <!--    <xsl:variable name="contentLayoutInfo" select="//publisherStyleSheet[1]/contentLayout"/>-->
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
<!--    <xsl:variable name="frontMatterLayoutInfo" select="//publisherStyleSheet[1]/frontMatterLayout"/>-->
<!--    <xsl:variable name="bodyLayoutInfo" select="//publisherStyleSheet[1]/bodyLayout"/>-->
    <xsl:variable name="backMatterLayoutInfo" select="//publisherStyleSheet[1]/backMatterLayout"/>
    <xsl:variable name="documentLayoutInfo" select="//publisherStyleSheet[1]/contentLayout"/>
    <xsl:variable name="iAffiliationLayouts" select="count($frontMatterLayoutInfo/affiliationLayout)"/>
    <xsl:variable name="iEmailAddressLayouts" select="count($frontMatterLayoutInfo/emailAddressLayout)"/>
    <xsl:variable name="iAuthorLayouts" select="count($frontMatterLayoutInfo/authorLayout)"/>
    <xsl:variable name="lineSpacing" select="$pageLayoutInfo/lineSpacing"/>
    <xsl:variable name="sLineSpacing" select="$lineSpacing/@linespacing"/>
    <xsl:variable name="sSinglespacingLineHeight">1.2</xsl:variable>
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
    <xsl:variable name="sHangingIndentInitialIndent" select="normalize-space($pageLayoutInfo/hangingIndentInitialIndent)"/>
    <xsl:variable name="sHangingIndentNormalIndent" select="normalize-space($pageLayoutInfo/hangingIndentNormalIndent)"/>
    <!-- ===========================================================
      Variables
      =========================================================== -->
    <xsl:variable name="references" select="//references"/>
    <xsl:variable name="sLdquo">&#8220;</xsl:variable>
    <xsl:variable name="sRdquo">&#8221;</xsl:variable>
    <xsl:variable name="iExampleCount" select="count(//example)"/>
    <xsl:variable name="iNumberWidth">
        <xsl:choose>
            <xsl:when test="$sFOProcessor='XEP'">
                <!-- units are ems so the font and font size can be taken into account -->
                <xsl:text>2.75</xsl:text>
            </xsl:when>
            <xsl:when test="$sFOProcessor='XFC'">
                <!--  units are points because "XFC is not a renderer. It has a limited set of font metrics and therefore handles 'em' units in a very approximate way."
                    (email of August 10, 2007 from Jean-Yves Belmonte of XMLmind)-->
                <xsl:text>27.10125</xsl:text>
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
    <xsl:variable name="iAbbreviationCount" select="count(//abbrRef)"/>
    <xsl:variable name="sListInitialHorizontalOffset">
        <xsl:choose>
            <xsl:when test="$contentLayoutInfo/listLayout">
                <xsl:value-of select="$contentLayoutInfo/listLayout/@indent-before"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>0pt</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sListLayoutSpaceBetween" select="normalize-space($contentLayoutInfo/listLayout/@spacebetween)"/>
    <!-- ===========================================================
      Attribute sets
      =========================================================== -->
    <xsl:attribute-set name="HeaderFooterFontInfo">
        <xsl:attribute name="font-family">
            <xsl:value-of select="$sDefaultFontFamily"/>
        </xsl:attribute>
        <xsl:attribute name="font-size">9pt</xsl:attribute>
        <xsl:attribute name="font-style">italic</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="PageLayout">
        <xsl:attribute name="page-width">
            <xsl:value-of select="$sPageWidth"/>
        </xsl:attribute>
        <xsl:attribute name="page-height">
            <xsl:value-of select="$sPageHeight"/>
        </xsl:attribute>
        <xsl:attribute name="margin-top">
            <xsl:value-of select="$sPageTopMargin"/>
        </xsl:attribute>
        <xsl:attribute name="margin-bottom">
            <xsl:value-of select="$sPageBottomMargin"/>
        </xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="OddPageLayout" use-attribute-sets="PageLayout">
        <xsl:attribute name="margin-left">
            <xsl:value-of select="$sPageInsideMargin"/>
        </xsl:attribute>
        <xsl:attribute name="margin-right">
            <xsl:value-of select="$sPageOutsideMargin"/>
        </xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="EvenPageLayout" use-attribute-sets="PageLayout">
        <xsl:attribute name="margin-left">
            <xsl:choose>
                <xsl:when test="$pageLayoutInfo/useThesisSubmissionStyle/@singlesided='yes'">
                    <xsl:value-of select="$sPageInsideMargin"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$sPageOutsideMargin"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="margin-right">
            <xsl:choose>
                <xsl:when test="$pageLayoutInfo/useThesisSubmissionStyle/@singlesided='yes'">
                    <xsl:value-of select="$sPageOutsideMargin"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$sPageInsideMargin"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="ExampleCell">
        <xsl:attribute name="padding-end">.5em</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="FootnoteCommon">
        <xsl:attribute name="font-family">
            <xsl:value-of select="$sDefaultFontFamily"/>
        </xsl:attribute>
        <xsl:attribute name="text-align">left</xsl:attribute>
        <xsl:attribute name="text-align-last">left</xsl:attribute>
        <xsl:attribute name="text-indent">
            <xsl:variable name="sFootnoteIndent" select="normalize-space($pageLayoutInfo/footnoteIndent)"/>
            <xsl:choose>
                <xsl:when test="string-length($sFootnoteIndent)&gt;0">
                    <xsl:value-of select="$sFootnoteIndent"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$sParagraphIndent"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="start-indent">0pt</xsl:attribute>
        <xsl:attribute name="end-indent">0pt</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-variant">normal</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="FootnoteMarker" use-attribute-sets="FootnoteCommon">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$sFootnotePointSize - 2"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="FootnoteBody" use-attribute-sets="FootnoteCommon">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$sFootnotePointSize"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
    </xsl:attribute-set>
    <!-- ===========================================================
      MAIN BODY
      =========================================================== -->
    <xsl:template match="//lingPaper">
        <!-- using line-height-shift-adjustment="disregard-shifts" to keep ugly gaps from appearing between lines with footnotes. -->
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" line-height-shift-adjustment="disregard-shifts">
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single'">
                <xsl:attribute name="line-height">
                    <xsl:choose>
                        <xsl:when test="$sLineSpacing='double'">
                            <xsl:text>2.4</xsl:text>
                        </xsl:when>
                        <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                            <xsl:text>1.8</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="SetMetadata"/>
            <xsl:comment> generated by XLingPapPublisherStylesheetFO.xsl Version <xsl:value-of select="$sVersion"/>&#x20;</xsl:comment>
            <!-- Page layouts -->
            <xsl:call-template name="DoLayoutMasterSet"/>
            <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@showbookmarks!='no'">
                <xsl:call-template name="DoBookmarksForPaper"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$bIsBook">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- insert a new line so we don't get everything all on one line -->
                    <xsl:text>&#xa;</xsl:text>
                    <fo:page-sequence master-reference="Chapter">
                        <xsl:attribute name="initial-page-number">
                            <xsl:variable name="sStartingPageNumber" select="normalize-space($lingPaper/publishingInfo/@startingPageNumber)"/>
                            <xsl:choose>
                                <xsl:when test="string-length($sStartingPageNumber) &gt; 0">
                                    <xsl:value-of select="$sStartingPageNumber"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>auto-odd</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:call-template name="OutputChapterStaticContent">
                            <xsl:with-param name="layoutInfo" select="$pageLayoutInfo/headerFooterPageStyles"/>
                        </xsl:call-template>
                        <fo:flow flow-name="xsl-region-body">
                            <xsl:attribute name="font-family">
                                <xsl:value-of select="$sDefaultFontFamily"/>
                            </xsl:attribute>
                            <xsl:attribute name="font-size">
                                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                            <!-- put title in marker so it can show up in running header -->
                            <fo:marker marker-class-name="chap-title">
                                <xsl:choose>
                                    <xsl:when test="//frontMatter/shortTitle">
                                        <xsl:apply-templates select="//frontMatter/shortTitle"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="//title/child::node()[name()!='endnote']"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:marker>
                            <xsl:apply-templates select="frontMatter"/>
                            <xsl:apply-templates select="//section1[not(parent::appendix)]"/>
                            <xsl:apply-templates select="//backMatter"/>
                        </fo:flow>
                    </fo:page-sequence>
                </xsl:otherwise>
            </xsl:choose>
        </fo:root>
    </xsl:template>
    <xsl:template name="DoBookmarksForPaper">
        <xsl:for-each select="$contents[not(ancestor::chapterInCollection)]">
            <fo:bookmark-tree>
                <xsl:call-template name="DoFrontMatterBookmarksPerLayout"/>
                <!-- chapterBeforePart -->
                <!--                <xsl:apply-templates select="$lingPaper/chapterBeforePart" mode="bookmarks"/>-->
                <!-- part -->
                <xsl:apply-templates select="$lingPaper/part" mode="bookmarks"/>
                <!--                 chapter, no parts -->
                <xsl:apply-templates select="$lingPaper/chapter | $lingPaper/chapterInCollection" mode="bookmarks"/>
                <!-- section, no chapters -->
                <xsl:apply-templates select="$lingPaper/section1" mode="bookmarks"/>
                <xsl:call-template name="DoBackMatterBookmarksPerLayout"/>
            </fo:bookmark-tree>
        </xsl:for-each>
    </xsl:template>
    <!-- ===========================================================
      FRONTMATTER
      =========================================================== -->
    <xsl:template match="frontMatter">
        <xsl:param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <xsl:variable name="frontMatter" select="."/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <xsl:choose>
            <xsl:when test="$bIsBook and not(ancestor::chapterInCollection)">
                <!-- insert a new line so we don't get everything all on one line -->
                <xsl:text>&#xa;</xsl:text>
                <fo:page-sequence master-reference="FrontMatter" format="i">
                    <xsl:call-template name="DoFootnoteSeparatorStaticContent"/>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:attribute name="font-family">
                            <xsl:value-of select="$sDefaultFontFamily"/>
                        </xsl:attribute>
                        <xsl:call-template name="DoBookFrontMatterFirstStuffPerLayout">
                            <xsl:with-param name="frontMatter" select="."/>
                            <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                        </xsl:call-template>
                    </fo:flow>
                </fo:page-sequence>
                <xsl:call-template name="DoBookFrontMatterPagedStuffPerLayout">
                    <xsl:with-param name="frontMatter" select="."/>
                    <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoFrontMatterPerLayout">
                    <xsl:with-param name="frontMatter" select="."/>
                    <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      title
      -->
    <xsl:template match="title">
        <xsl:if test="$bIsBook">
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <fo:block space-before.conditionality="retain">
                <xsl:call-template name="DoTitleFormatInfo">
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
                    <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
                </xsl:call-template>
                <xsl:apply-templates select="child::node()[name()!='endnote']"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
                </xsl:call-template>
            </fo:block>
            <xsl:apply-templates select="following-sibling::subtitle"/>
        </xsl:if>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block space-before.conditionality="retain">
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
                <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <xsl:template match="title" mode="contentOnly">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      subtitle
      -->
    <xsl:template match="subtitle">
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block space-before.conditionality="retain">
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/subtitleLayout"/>
                <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/subtitleLayout"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <!--
      author
      -->
    <xsl:template match="author">
        <xsl:param name="authorLayoutToUse"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block>
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$authorLayoutToUse"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$authorLayoutToUse"/>
            </xsl:call-template>
        </fo:block>
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
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block>
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$affiliationLayoutToUse"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$affiliationLayoutToUse"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <!--
        emailAddress
    -->
    <xsl:template match="emailAddress">
        <xsl:param name="emailAddressLayoutToUse"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block>
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$emailAddressLayoutToUse"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$emailAddressLayoutToUse"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <!--
        date
    -->
    <xsl:template match="date">
        <xsl:param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block>
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayout/dateLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayout/dateLayout"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <!--
        presentedAt
    -->
    <xsl:template match="presentedAt">
        <xsl:param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block>
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayout/presentedAtLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayout/presentedAtLayout"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <!--
      version
      -->
    <xsl:template match="version">
        <xsl:param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block>
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayout/versionLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayout/versionLayout"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <!--
        publishingBlurb
    -->
    <xsl:template match="publishingBlurb">
        <fo:block>
            <xsl:call-template name="DoFrontMatterFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/publishingBlurbLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/publishingBlurbLayout"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <!--
      contents (for book)
      -->
    <xsl:template match="contents" mode="book">
        <xsl:param name="contentsLayoutToUse" select="$frontMatterLayoutInfo"/>
        <xsl:choose>
            <xsl:when test="$contentsLayoutToUse[ancestor::backMatterLayout]">
                <fo:page-sequence master-reference="Chapter">
                    <xsl:attribute name="initial-page-number">
                        <xsl:choose>
                            <xsl:when test="$contentsLayoutToUse/@startonoddpage='yes'">
                                <xsl:text>auto-odd</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>auto</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:call-template name="OutputChapterStaticContentForBackMatter"/>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:attribute name="font-family">
                            <xsl:value-of select="$sDefaultFontFamily"/>
                        </xsl:attribute>
                        <xsl:attribute name="font-size">
                            <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                        <!-- put title in marker so it can show up in running header -->
                        <fo:marker marker-class-name="chap-title">
                            <xsl:call-template name="OutputContentsLabel">
                                <xsl:with-param name="layoutInfo" select="$contentsLayoutToUse"/>
                                <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                            </xsl:call-template>
                        </fo:marker>
                        <xsl:call-template name="DoContents">
                            <xsl:with-param name="bIsBook" select="'Y'"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="layoutInfo" select="$frontMatterLayoutInfo/headerFooterPageStyles"/>
                <!-- insert a new line so we don't get everything all on one line -->
                <xsl:text>&#xa;</xsl:text>
                <fo:page-sequence master-reference="FrontMatterTOC" format="i">
                    <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@startonoddpage='yes'">
                        <xsl:attribute name="initial-page-number">
                            <xsl:text>auto-odd</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="DoHeaderAndFooter">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo/headerFooterFirstPage"/>
                        <xsl:with-param name="layoutInfoParentWithFontInfo" select="$layoutInfo"/>
                        <xsl:with-param name="sFlowName" select="'FrontMatterTOCFirstPage'"/>
                        <xsl:with-param name="sRetrieveClassName" select="'contents-title'"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoHeaderAndFooter">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo/headerFooterPage"/>
                        <xsl:with-param name="layoutInfoParentWithFontInfo" select="$layoutInfo"/>
                        <xsl:with-param name="sFlowName" select="'FrontMatterTOCRegularPage'"/>
                        <xsl:with-param name="sRetrieveClassName" select="'contents-title'"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoHeaderAndFooter">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo/headerFooterOddEvenPages/headerFooterEvenPage"/>
                        <xsl:with-param name="layoutInfoParentWithFontInfo" select="$layoutInfo"/>
                        <xsl:with-param name="sFlowName" select="'FrontMatterTOCEvenPage'"/>
                        <xsl:with-param name="sRetrieveClassName" select="'contents-title'"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoHeaderAndFooter">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo/headerFooterOddEvenPages/headerFooterOddPage"/>
                        <xsl:with-param name="layoutInfoParentWithFontInfo" select="$layoutInfo"/>
                        <xsl:with-param name="sFlowName" select="'FrontMatterTOCOddPage'"/>
                        <xsl:with-param name="sRetrieveClassName" select="'contents-title'"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoFootnoteSeparatorStaticContent"/>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:attribute name="font-family">
                            <xsl:value-of select="$sDefaultFontFamily"/>
                        </xsl:attribute>
                        <xsl:attribute name="font-size">
                            <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                        <!-- put title in marker so it can show up in running header -->
                        <fo:marker marker-class-name="contents-title">
                            <xsl:call-template name="OutputContentsLabel">
                                <xsl:with-param name="layoutInfo" select="$contentsLayoutToUse/contentsLayout"/>
                                <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                            </xsl:call-template>
                        </fo:marker>
                        <xsl:call-template name="DoContents">
                            <xsl:with-param name="bIsBook" select="'Y'"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$frontMatterLayoutInfo/contentsLayout"/>
                        </xsl:call-template>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      contents (for paper)
      -->
    <xsl:template match="contents" mode="paper">
        <xsl:param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <xsl:param name="contentsLayoutToUse" select="$contentsLayout"/>
        <xsl:call-template name="DoContents">
            <xsl:with-param name="bIsBook" select="'N'"/>
            <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      abstract (book)
      -->
    <xsl:template name="DoAbstractPerBookLayout">
        <xsl:param name="abstractLayout"/>
        <xsl:call-template name="DoFrontMatterItemNewPage">
            <xsl:with-param name="sHeaderTitleClassName" select="'abstract-title'"/>
            <xsl:with-param name="id" select="concat($sAbstractID,count(preceding-sibling::abstract))"/>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputAbstractLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$abstractLayout"/>
            <xsl:with-param name="sMarkerClassName" select="'abstract-title'"/>
            <xsl:with-param name="sRunningHeader">
                <xsl:call-template name="OutputAbstractLabel">
                    <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
      abstract  (paper)
      -->
    <xsl:template name="DoAbstractPerPaperLayout">
        <xsl:param name="abstractLayout"/>
        <xsl:variable name="abstractTextLayoutInfo" select="$abstractLayout/following-sibling::*[1][name()='abstractTextFontInfo']"/>
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="concat($sAbstractID,count(preceding-sibling::abstract))"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputAbstractLabel"/>
            </xsl:with-param>
            <xsl:with-param name="bIsBook" select="'N'"/>
            <xsl:with-param name="layoutInfo" select="$abstractLayout"/>
            <xsl:with-param name="sMarkerClassName" select="'abstract-title'"/>
            <xsl:with-param name="sRunningHeader">
                <xsl:call-template name="OutputAbstractLabel">
                    <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="$abstractTextLayoutInfo">
                <fo:block>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="$abstractTextLayoutInfo"/>
                    </xsl:call-template>
                    <xsl:if test="string-length(normalize-space($abstractTextLayoutInfo/@textalign)) &gt; 0">
                        <xsl:attribute name="text-align">
                            <xsl:value-of select="$abstractTextLayoutInfo/@textalign"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="string-length(normalize-space($abstractTextLayoutInfo/@start-indent)) &gt; 0">
                        <xsl:attribute name="start-indent">
                            <xsl:value-of select="$abstractTextLayoutInfo/@start-indent"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="string-length(normalize-space($abstractTextLayoutInfo/@end-indent)) &gt; 0">
                        <xsl:attribute name="end-indent">
                            <xsl:value-of select="$abstractTextLayoutInfo/@end-indent"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="string-length($abstractLayout/@spaceafter) &gt; 0">
                        <xsl:attribute name="space-after">
                            <xsl:value-of select="$abstractLayout/@spaceafter"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </fo:block>
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
            <xsl:with-param name="sRunningHeader">
                <xsl:call-template name="OutputAcknowledgementsLabel">
                    <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
      acknowledgements (backmatter-book)
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
            <xsl:with-param name="sRunningHeader">
                <xsl:call-template name="OutputAcknowledgementsLabel">
                    <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                </xsl:call-template>
            </xsl:with-param>
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
                <xsl:variable name="layoutToUse">
                    <xsl:choose>
                        <xsl:when test="parent::frontMatter and ancestor::chapterInCollection">
                            <xsl:copy-of select="$bodyLayoutInfo/chapterInCollectionFrontMatterLayout/acknowledgementsLayout"/>
                        </xsl:when>
                        <xsl:when test="parent::frontMatter">
                            <xsl:copy-of select="$frontMatterLayoutInfo/acknowledgementsLayout"/>
                        </xsl:when>
                        <xsl:when test="parent::backMatter and ancestor::chapterInCollection">
                            <xsl:copy-of select="$bodyLayoutInfo/chapterInCollectionBackMatterLayout/acknowledgementsLayout"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$backMatterLayoutInfo/acknowledgementsLayout"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id">
                        <xsl:call-template name="GetIdToUse">
                            <xsl:with-param name="sBaseId" select="$sAcknowledgementsID"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="sTitle">
                        <xsl:call-template name="OutputAcknowledgementsLabel"/>
                    </xsl:with-param>
                    <xsl:with-param name="bIsBook" select="'N'"/>
                    <xsl:with-param name="layoutInfo" select="$layoutToUse/*"/>
                    <xsl:with-param name="sMarkerClassName" select="'acknowledgements-title'"/>
                    <xsl:with-param name="sRunningHeader">
                        <xsl:call-template name="OutputAcknowledgementsLabel">
                            <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                <!--<xsl:choose>
                    <xsl:when test="parent::frontMatter">
                        <xsl:call-template name="OutputFrontOrBackMatterTitle">
                            <xsl:with-param name="id">
                                <xsl:call-template name="GetIdToUse">
                                    <xsl:with-param name="sBaseId" select="$sAcknowledgementsID"/>
                                </xsl:call-template>
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
                                <xsl:call-template name="GetIdToUse">
                                    <xsl:with-param name="sBaseId" select="$sAcknowledgementsID"/>
                                </xsl:call-template>
                            </xsl:with-param>
                            <xsl:with-param name="sTitle">
                                <xsl:call-template name="OutputAcknowledgementsLabel"/>
                            </xsl:with-param>
                            <xsl:with-param name="bIsBook" select="'N'"/>
                            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/acknowledgementsLayout"/>
                            <xsl:with-param name="sMarkerClassName" select="'acknowledgements-title'"/>
                            </xsl:call-template>
                            </xsl:otherwise>
                            </xsl:choose>-->
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        keywordsShownHere
    -->
    <xsl:template match="keywordsShownHere" mode="paper">
        <xsl:param name="frontMatterLayout"/>
        <xsl:apply-templates select="self::*">
            <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="keywordsShownHere">
        <xsl:param name="frontMatterLayout"/>
        <xsl:choose>
            <xsl:when test="parent::frontMatter">
                <xsl:call-template name="OutputKeywordsTitleAndContent">
                    <xsl:with-param name="sKeywordsID" select="$sKeywordsInFrontMatterID"/>
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$frontMatterLayout/keywordsLayout/@pagebreakbefore='yes'">
                        <!-- insert a new line so we don't get everything all on one line -->
                        <xsl:text>&#xa;</xsl:text>
                        <fo:page-sequence master-reference="Chapter">
                            <xsl:call-template name="DoInitialPageNumberAttribute">
                                <xsl:with-param name="layoutInfo" select="$frontMatterLayout/keywordsLayout"/>
                            </xsl:call-template>
                            <xsl:call-template name="OutputChapterStaticContentForBackMatter"/>
                            <fo:flow flow-name="xsl-region-body">
                                <xsl:attribute name="font-family">
                                    <xsl:value-of select="$sDefaultFontFamily"/>
                                </xsl:attribute>
                                <xsl:attribute name="font-size">
                                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                                <fo:marker marker-class-name="chap-title">
                                    <xsl:call-template name="OutputKeywordsLabel">
                                        <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                                    </xsl:call-template>
                                </fo:marker>
                                <xsl:call-template name="OutputKeywordsTitleAndContent">
                                    <xsl:with-param name="sKeywordsID" select="$sKeywordsInBackMatterID"/>
                                    <xsl:with-param name="layoutInfo" select="$frontMatterLayout"/>
                                </xsl:call-template>
                            </fo:flow>
                        </fo:page-sequence>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="OutputKeywordsTitleAndContent">
                            <xsl:with-param name="sKeywordsID" select="$sKeywordsInBackMatterID"/>
                            <xsl:with-param name="layoutInfo" select="$frontMatterLayout"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ===========================================================
      PARTS, CHAPTERS, SECTIONS, and APPENDICES
      =========================================================== -->
    <!--
      Part
      -->
    <xsl:template match="part">
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:page-sequence master-reference="Chapter">
            <xsl:attribute name="initial-page-number">
                <xsl:choose>
                    <xsl:when test="contains(name(),'chapter') and position()=1 or preceding-sibling::*[1][name(.)='frontMatter']">
                        <xsl:text>1</xsl:text>
                    </xsl:when>
                    <xsl:when test="$bodyLayoutInfo/partLayout/partTitleLayout/@startonoddpage='yes'">
                        <xsl:text>auto-odd</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>auto</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:call-template name="DoFootnoteSeparatorStaticContent"/>
            <fo:flow flow-name="xsl-region-body">
                <xsl:attribute name="font-family">
                    <xsl:value-of select="$sDefaultFontFamily"/>
                </xsl:attribute>
                <xsl:attribute name="font-size">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                <!-- put title in marker so it can show up in running header -->
                <fo:marker marker-class-name="chap-title">
                    <xsl:call-template name="DoSecTitleRunningHeader">
                        <xsl:with-param name="number" select="$chapterNumberInHeaderLayout"/>
                        <xsl:with-param name="bNumberIsBeforeTitle" select="$bChapterNumberIsBeforeTitle"/>
                    </xsl:call-template>
                </fo:marker>
                <fo:block id="{@id}" span="all">
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
                </fo:block>
                <fo:block>
                    <xsl:call-template name="DoTitleFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/partTitleLayout"/>
                        <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="secTitle"/>
                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/partTitleLayout"/>
                    </xsl:call-template>
                </fo:block>
                <xsl:apply-templates select="child::node()[name()!='secTitle' and not(contains(name(),'chapter'))]"/>
            </fo:flow>
        </fo:page-sequence>
        <xsl:apply-templates select="child::node()[name()='chapter' or name()='chapterInCollection']"/>
    </xsl:template>
    <!--
      Chapter or appendix (in book with chapters)
      -->
    <xsl:template match="chapter | appendix[//chapter]  | chapterBeforePart | chapterInCollection | appendix[//chapterInCollection and not(ancestor::chapterInCollection)]">
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:page-sequence master-reference="Chapter">
            <xsl:attribute name="initial-page-number">
                <xsl:choose>
                    <xsl:when test="contains(name(),'chapter') and not(parent::part) and position()=1 or preceding-sibling::*[1][name(.)='frontMatter']">
                        <xsl:variable name="sStartingPageNumberInBook" select="normalize-space($lingPaper/publishingInfo/@startingPageNumberInBook)"/>
                        <xsl:choose>
                            <xsl:when test="string-length($sStartingPageNumberInBook) &gt; 0">
                                <xsl:value-of select="$sStartingPageNumberInBook"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>1</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="contains(name(),'chapter') and $bodyLayoutInfo/chapterInCollectionLayout/*[1]/@startonoddpage='yes'">
                        <xsl:text>auto-odd</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(name(),'chapter') and $bodyLayoutInfo/chapterLayout/*[1]/@startonoddpage='yes'">
                        <xsl:text>auto-odd</xsl:text>
                    </xsl:when>
                    <xsl:when test="name()='appendix' and $backMatterLayoutInfo/appendixLayout/*[1]/@startonoddpage='yes'">
                        <xsl:text>auto-odd</xsl:text>
                    </xsl:when>
                    <xsl:when test="name()!='appendix' and $bodyLayoutInfo/chapterLayout/*[1]/@startonoddpage='yes'">
                        <xsl:text>auto-odd</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>auto</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
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
            <fo:flow flow-name="xsl-region-body">
                <xsl:attribute name="font-family">
                    <xsl:value-of select="$sDefaultFontFamily"/>
                </xsl:attribute>
                <xsl:attribute name="font-size">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                <xsl:if test="$bodyLayoutInfo/chapterLayout/chapterTitleLayout/@usetitleinheader!='no' or $bodyLayoutInfo/chapterInCollectionLayout/chapterTitleLayout/@usetitleinheader!='no'">
                    <!-- put title in marker so it can show up in running header -->
                    <fo:marker marker-class-name="chap-title">
                        <xsl:call-template name="DoSecTitleRunningHeader">
                            <xsl:with-param name="number" select="$chapterNumberInHeaderLayout"/>
                            <xsl:with-param name="bNumberIsBeforeTitle" select="$bChapterNumberIsBeforeTitle"/>
                        </xsl:call-template>
                    </fo:marker>
                </xsl:if>
                <xsl:if test="$bodyLayoutInfo/headerFooterPageStyles/descendant::chapterInCollectionAuthor">
                    <fo:marker marker-class-name="chap-in-collection-author">
                        <xsl:choose>
                            <xsl:when test="string-length(normalize-space(frontMatter/shortAuthor)) &gt; 0">
                                <xsl:apply-templates select="frontMatter/shortAuthor"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="frontMatter/author" mode="contentOnly"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:marker>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$bodyLayoutInfo/chapterLayout/numberLayout or $bodyLayoutInfo/chapterInCollectionLayout/numberLayout">
                        <fo:block id="{@id}" span="all">
                            <xsl:choose>
                                <xsl:when test="name(.)='appendix' and not(ancestor::chapterInCollection)">
                                    <xsl:call-template name="DoTitleFormatInfo">
                                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendixLayout/numberLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="name(.)='appendix' and ancestor::chapterInCollection">
                                    <xsl:call-template name="DoTitleFormatInfo">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterInCollectionBackMatterLayout/appendixLayout/numberLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="DoTitleFormatInfo">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/numberLayout | $bodyLayoutInfo/chapterInCollectionLayout/numberLayout"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:call-template name="OutputChapTitle">
                                <xsl:with-param name="sTitle">
                                    <xsl:call-template name="OutputChapterNumber"/>
                                </xsl:with-param>
                            </xsl:call-template>
                            <xsl:choose>
                                <xsl:when test="name(.)='appendix' and not(ancestor::chapterInCollection)">
                                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendixLayout/numberLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="name(.)='appendix' and ancestor::chapterInCollection">
                                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterInCollectionBackMatterLayoutInfo/appendixLayout/numberLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/numberLayout | $bodyLayoutInfo/chapterInCollectionLayout/numberLayout"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:block>
                        <fo:block>
                            <xsl:choose>
                                <xsl:when test="name(.)='appendix' and not(ancestor::chapterInCollection)">
                                    <xsl:call-template name="DoTitleFormatInfo">
                                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="name(.)='appendix' and ancestor::chapterInCollection">
                                    <xsl:call-template name="DoTitleFormatInfo">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterInCollectionBackMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="DoTitleFormatInfo">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout | $bodyLayoutInfo/chapterInCollectionLayout/chapterTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:apply-templates select="secTitle | frontMatter/title"/>
                            <xsl:choose>
                                <xsl:when test="name(.)='appendix' and not(chapterInCollection)">
                                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="name(.)='appendix' and ancestor::chapterInCollection">
                                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterInCollectionBackMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout | $bodyLayoutInfo/chapterInCollectionLayout/chapterTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:block>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:block id="{@id}" span="all">
                            <xsl:choose>
                                <xsl:when test="name(.)='appendix' and not(ancestor::chapterInCollection)">
                                    <xsl:call-template name="DoTitleFormatInfo">
                                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="name(.)='appendix' and ancestor::chapterInCollection">
                                    <xsl:call-template name="DoTitleFormatInfo">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterInCollectionBackMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="DoTitleFormatInfo">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout | $bodyLayoutInfo/chapterInCollectionLayout/chapterTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:call-template name="OutputChapTitle">
                                <xsl:with-param name="sTitle">
                                    <xsl:call-template name="OutputChapterNumber"/>
                                </xsl:with-param>
                            </xsl:call-template>
                            <xsl:apply-templates select="secTitle | frontMatter/title"/>
                            <xsl:choose>
                                <xsl:when test="name(.)='appendix' and not(ancestor::chapterInCollection)">
                                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="name(.)='appendix' and ancestor::chapterInCollection">
                                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterInCollectionBackMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                        <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout | $bodyLayoutInfo/chapterInCollectionLayout/chapterTitleLayout"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="child::node()[name()!='secTitle' and name()!='shortTitle']">
                    <xsl:with-param name="frontMatterLayout" select="$bodyLayoutInfo/chapterInCollectionFrontMatterLayout"/>
                    <xsl:with-param name="backMatterLayout" select="$bodyLayoutInfo/chapterInCollectionBackMatterLayout"/>
                </xsl:apply-templates>
                <xsl:if test="name()='appendix' and not(following-sibling::appendix)">
                    <xsl:call-template name="HandleKeywordsLayoutWithoutPageBreak">
                        <xsl:with-param name="keywordsLayout" select="$backMatterLayoutInfo/appendixLayout/following-sibling::*[1]"/>
                        <xsl:with-param name="backMatterLayout" select="$backMatterLayoutInfo"/>
                    </xsl:call-template>
                </xsl:if>
            </fo:flow>
        </fo:page-sequence>
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
    <xsl:template match="appendix[not(//chapter | //chapterInCollection) or ancestor::chapterInCollection]">
        <xsl:param name="appLayout" select="$backMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block>
            <!-- put title in marker so it can show up in running header -->
            <fo:marker marker-class-name="section-title">
                <xsl:call-template name="DoSecTitleRunningHeader">
                    <xsl:with-param name="number" select="$chapterNumberInHeaderLayout"/>
                    <xsl:with-param name="bNumberIsBeforeTitle" select="$bChapterNumberIsBeforeTitle"/>
                </xsl:call-template>
            </fo:marker>
        </fo:block>
        <fo:block id="{@id}" keep-with-next.within-page="always">
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
        </fo:block>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <!--
      secTitle
      -->
    <xsl:template match="secTitle" mode="InMarker">
        <xsl:apply-templates select="child::node()[name()!='endnote']" mode="contents"/>
    </xsl:template>
    <xsl:template match="secTitle">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      sectionRef
      -->
    <xsl:template match="sectionRef">
        <xsl:call-template name="OutputAnyTextBeforeSectionRef"/>
        <fo:inline>
            <!-- adjust reference to a section that is actually present per the style sheet -->
            <xsl:variable name="secRefToUse">
                <xsl:call-template name="GetSectionRefToUse">
                    <xsl:with-param name="section" select="id(@sec)"/>
                    <xsl:with-param name="bodyLayoutInfo" select="$bodyLayoutInfo"/>
                </xsl:call-template>
            </xsl:variable>
            <fo:basic-link>
                <xsl:attribute name="internal-destination">
                    <xsl:value-of select="$secRefToUse"/>
                </xsl:attribute>
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/sectionRefLinkLayout"/>
                </xsl:call-template>
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
                <xsl:call-template name="DoSectionRef">
                    <xsl:with-param name="secRefToUse" select="$secRefToUse"/>
                </xsl:call-template>
            </fo:basic-link>
        </fo:inline>
    </xsl:template>
    <xsl:template match="sectionRef" mode="bookmarks">
        <xsl:apply-templates select="id(@sec)" mode="number"/>
    </xsl:template>
    <!--
      appendixRef
      -->
    <xsl:template match="appendixRef">
        <fo:basic-link internal-destination="{@app}">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/appendixRefLinkLayout"/>
            </xsl:call-template>
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
            <xsl:call-template name="DoAppendixRef"/>
        </fo:basic-link>
    </xsl:template>
    <xsl:template match="appendixRef" mode="bookmarks">
        <xsl:apply-templates select="id(@app)" mode="numberAppendix"/>
    </xsl:template>
    <!--
      genericRef
      -->
    <xsl:template match="genericRef">
        <fo:basic-link internal-destination="{@gref}">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/genericRefLinkLayout"/>
            </xsl:call-template>
            <xsl:call-template name="OutputGenericRef"/>
        </fo:basic-link>
    </xsl:template>
    <!--
      genericTarget
   -->
    <xsl:template match="genericTarget">
        <fo:inline id="{@id}"/>
    </xsl:template>
    <!--
      link
      -->
    <xsl:template match="link">
        <fo:basic-link external-destination="url({@href})">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/linkLinkLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </fo:basic-link>
    </xsl:template>
    <!-- ===========================================================
      PARAGRAPH
      =========================================================== -->
    <xsl:template match="p | pc" mode="endnote-content">
        <xsl:param name="originalContext"/>
        <xsl:param name="iTablenumberedAdjust" select="0"/>
        <fo:inline baseline-shift="super">
            <xsl:attribute name="font-size">
                <xsl:value-of select="$sFootnotePointSize - 2"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:for-each select="parent::endnote">
                <xsl:call-template name="GetFootnoteNumber">
                    <xsl:with-param name="originalContext" select="$originalContext"/>
                    <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:if test="string-length($sContentBetweenFootnoteNumberAndFootnoteContent) &gt; 0">
                <xsl:value-of select="$sContentBetweenFootnoteNumberAndFootnoteContent"/>
            </xsl:if>
        </fo:inline>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="p | pc" mode="contentOnly">
        <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@xsl-foSpecial"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="p | pc">
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block orphans="2" widows="2">
            <xsl:variable name="sSpaceBefore" select="normalize-space($contentLayoutInfo/paragraphLayout/@spacebefore)"/>
            <xsl:if test="string-length($sSpaceBefore) &gt; 0">
                <xsl:attribute name="space-before">
                    <xsl:value-of select="$sSpaceBefore"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:variable name="sSpaceAfter" select="normalize-space($contentLayoutInfo/paragraphLayout/@spaceafter)"/>
            <xsl:if test="string-length($sSpaceAfter) &gt; 0">
                <xsl:attribute name="space-after">
                    <xsl:value-of select="$sSpaceAfter"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@pagecontrol='keepWithNext'">
                <xsl:attribute name="keep-with-next.within-page">1</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="count(preceding-sibling::*[name()!='secTitle' and name()!='shortTitle' and name()!='frontMatter'])=0">
                    <!-- is the first item -->
                    <xsl:choose>
                        <xsl:when test="parent::appendix and $backMatterLayoutInfo/appendixLayout/@firstParagraphHasIndent='no'">
                            <!-- do nothing to force no indent -->
                        </xsl:when>
                        <xsl:when test="parent::chapter and $bodyLayoutInfo/chapterLayout/@firstParagraphHasIndent='no'">
                            <!-- do nothing to force no indent -->
                        </xsl:when>
                        <xsl:when test="parent::chapterInCollection and $bodyLayoutInfo/chapterInCollectionLayout/@firstParagraphHasIndent='no'">
                            <!-- do nothing to force no indent -->
                        </xsl:when>
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
                        <xsl:otherwise>
                            <xsl:attribute name="text-indent">
                                <xsl:value-of select="$sParagraphIndent"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="name(.)='p' and not(parent::blockquote and not(preceding-sibling::*))">
                        <xsl:attribute name="text-indent">
                            <xsl:value-of select="$sParagraphIndent"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
            <xsl:if test="parent::abstract and count(following-sibling::p)=0 and $frontMatterLayoutInfo/acknowledgementsLayout/@showAsFootnoteAtEndOfAbstract='yes'">
                <fo:footnote>
                    <fo:inline baseline-shift="super" xsl:use-attribute-sets="FootnoteMarker">
                        <xsl:text>*</xsl:text>
                    </fo:inline>
                    <fo:footnote-body>
                        <fo:block xsl:use-attribute-sets="FootnoteBody">
                            <fo:inline baseline-shift="super" xsl:use-attribute-sets="FootnoteMarker">
                                <xsl:attribute name="id">
                                    <xsl:value-of select="$sAcknowledgementsID"/>
                                </xsl:attribute>
                                <xsl:call-template name="InsertCommaBetweenConsecutiveEndnotes"/>
                                <xsl:text>*</xsl:text>
                            </fo:inline>
                            <xsl:apply-templates select="$lingPaper/frontMatter/acknowledgements/*" mode="contentOnly"/>
                        </fo:block>
                    </fo:footnote-body>
                </fo:footnote>
            </xsl:if>
        </fo:block>
    </xsl:template>
    <!-- ===========================================================
        Hanging indent paragraph
        =========================================================== -->
    <xsl:template match="hangingIndent">
        <xsl:variable name="sThisInitialIndent" select="normalize-space(@initialIndent)"/>
        <xsl:variable name="sThisHangingIndent" select="normalize-space(@hangingIndent)"/>
        <fo:block>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:attribute name="start-indent">
                <xsl:call-template name="GetHangingIndentNormalIndent">
                    <xsl:with-param name="sThisHangingIndent" select="$sThisHangingIndent"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="text-indent">
                <xsl:text>-</xsl:text>
                <xsl:choose>
                    <xsl:when test="string-length($sThisInitialIndent) &gt; 0">
                        <xsl:call-template name="GetBestHangingIndentInitialIndent">
                            <xsl:with-param name="sThisHangingIndent" select="$sThisHangingIndent"/>
                            <xsl:with-param name="sThisInitialIndent" select="$sThisInitialIndent"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="string-length($sHangingIndentInitialIndent) &gt; 0">
                        <xsl:call-template name="GetBestHangingIndentInitialIndent">
                            <xsl:with-param name="sThisHangingIndent" select="$sHangingIndentNormalIndent"/>
                            <xsl:with-param name="sThisInitialIndent" select="$sHangingIndentInitialIndent"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="string-length($sThisHangingIndent) &gt; 0">
                                <xsl:value-of select="$sThisHangingIndent"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>1em</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!-- ===========================================================
        Annotation reference (part of an annotated bibliography)
        =========================================================== -->
    <xsl:template match="annotationRef">
        <xsl:for-each select="key('RefWorkID',@citation)">
            <xsl:call-template name="DoRefWork">
                <xsl:with-param name="works" select="."/>
                <xsl:with-param name="bDoTarget" select="'N'"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:variable name="annotation" select="key('AnnotationID',@annotation)"/>
        <xsl:if test="$annotation">
            <fo:block>
                <xsl:variable name="sStartIndent" select="normalize-space($annotationLayoutInfo/@start-indent)"/>
                <xsl:attribute name="start-indent">
                    <xsl:choose>
                        <xsl:when test="string-length($sStartIndent) &gt; 0">
                            <xsl:value-of select="$sStartIndent"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>.25in</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:variable name="sEndIndent" select="normalize-space($annotationLayoutInfo/@end-indent)"/>
                <xsl:if test="string-length($sEndIndent) &gt; 0">
                    <xsl:attribute name="end-indent">
                        <xsl:value-of select="$sEndIndent"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:variable name="sSpaceBefore" select="normalize-space($annotationLayoutInfo/@spacebefore)"/>
                <xsl:attribute name="space-before">
                    <xsl:choose>
                        <xsl:when test="string-length($sSpaceBefore) &gt; 0">
                            <xsl:value-of select="$sSpaceBefore"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>3pt</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:variable name="sSpaceAfter" select="normalize-space($annotationLayoutInfo/@spaceafter)"/>
                <xsl:attribute name="space-after">
                    <xsl:choose>
                        <xsl:when test="string-length($sSpaceAfter) &gt; 0">
                            <xsl:value-of select="$sSpaceAfter"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>3pt</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$annotationLayoutInfo"/>
                </xsl:call-template>
                <xsl:call-template name="OutputCannedText">
                    <xsl:with-param name="sCannedText" select="$annotationLayoutInfo/@textbefore"/>
                </xsl:call-template>
                <xsl:apply-templates select="key('AnnotationID',@annotation)"/>
                <xsl:variable name="sTextAfter" select="$annotationLayoutInfo/@textafter"/>
                <xsl:call-template name="OutputCannedText">
                    <xsl:with-param name="sCannedText" select="$annotationLayoutInfo/@textafter"/>
                </xsl:call-template>
            </fo:block>
        </xsl:if>
    </xsl:template>
    <!-- ===========================================================
      QUOTES
      =========================================================== -->
    <xsl:template match="q">
        <fo:inline>
            <xsl:call-template name="DoType"/>
            <xsl:call-template name="DoQuoteTextBefore"/>
            <xsl:apply-templates/>
            <xsl:call-template name="DoQuoteTextAfter"/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="blockquote">
        <fo:block>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespaceblockquotes='yes'">
                <xsl:attribute name="line-height">
                    <xsl:value-of select="$sSinglespacingLineHeight"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:attribute name="start-indent">
                <xsl:value-of select="$sBlockQuoteIndent"/>
            </xsl:attribute>
            <xsl:attribute name="end-indent">
                <xsl:value-of select="$sBlockQuoteIndent"/>
            </xsl:attribute>
            <xsl:attribute name="font-size">
                <xsl:value-of select="$sBasicPointSize - 1"/>pt</xsl:attribute>
            <xsl:attribute name="space-before">
                <xsl:variable name="sSpaceBefore" select="normalize-space($documentLayoutInfo/blockQuoteLayout/@spacebefore)"/>
                <xsl:choose>
                    <xsl:when test="string-length($sSpaceBefore)&gt;0">
                        <xsl:value-of select="$sSpaceBefore"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$sBasicPointSize"/>
                        <xsl:text>pt</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="space-after">
                <xsl:variable name="sSpaceAfter" select="normalize-space($documentLayoutInfo/blockQuoteLayout/@spaceafter)"/>
                <xsl:choose>
                    <xsl:when test="string-length($sSpaceAfter)&gt;0">
                        <xsl:value-of select="$sSpaceAfter"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$sBasicPointSize"/>
                        <xsl:text>pt</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!-- ===========================================================
        PROSE TEXT
        =========================================================== -->
    <xsl:template match="prose-text">
        <xsl:choose>
            <xsl:when test="$documentLayoutInfo/prose-textTextLayout">
                <fo:block>
                    <xsl:variable name="sSpaceBefore" select="normalize-space($documentLayoutInfo/prose-textTextLayout/@spacebefore)"/>
                    <xsl:if test="string-length($sSpaceBefore)&gt;0">
                        <xsl:attribute name="space-before">
                            <xsl:value-of select="$sSpaceBefore"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:variable name="sSpaceAfter" select="normalize-space($documentLayoutInfo/prose-textTextLayout/@spaceafter)"/>
                    <xsl:if test="string-length($sSpaceAfter)&gt;0">
                        <xsl:attribute name="space-after">
                            <xsl:value-of select="$sSpaceAfter"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:variable name="sStartIndent" select="normalize-space($documentLayoutInfo/prose-textTextLayout/@start-indent)"/>
                    <xsl:if test="string-length($sStartIndent)&gt;0">
                        <xsl:attribute name="start-indent">
                            <xsl:value-of select="$sStartIndent"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:variable name="sEndIndent" select="normalize-space($documentLayoutInfo/prose-textTextLayout/@end-indent)"/>
                    <xsl:if test="string-length($sEndIndent)&gt;0">
                        <xsl:attribute name="end-indent">
                            <xsl:value-of select="$sEndIndent"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoType"/>
                    <xsl:call-template name="OutputTypeAttributes">
                        <xsl:with-param name="sList" select="@xsl-foSpecial"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="$documentLayoutInfo/prose-textTextLayout"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block>
                    <xsl:attribute name="start-indent">
                        <xsl:value-of select="$sBlockQuoteIndent"/>
                    </xsl:attribute>
                    <xsl:attribute name="end-indent">
                        <xsl:value-of select="$sBlockQuoteIndent"/>
                    </xsl:attribute>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoType"/>
                    <xsl:call-template name="OutputTypeAttributes">
                        <xsl:with-param name="sList" select="@xsl-foSpecial"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ===========================================================
        LISTS
        =========================================================== -->
    <xsl:template match="ol">
        <xsl:call-template name="DoOl"/>
    </xsl:template>
    <xsl:template match="ul">
        <xsl:call-template name="DoUl"/>
    </xsl:template>
    <xsl:template match="li">
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:list-item relative-align="baseline">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="following-sibling::*[1][name()='li'] and string-length($sListLayoutSpaceBetween) &gt; 0">
                <xsl:attribute name="space-after">
                    <xsl:value-of select="$sListLayoutSpaceBetween"/>
                </xsl:attribute>
            </xsl:if>
            <fo:list-item-label end-indent="label-end()">
                <fo:block>
                    <xsl:choose>
                        <xsl:when test="parent::*[name(.)='ul']">&#x2022;</xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="text-align">end</xsl:attribute>
                            <xsl:variable name="NestingLevel">
                                <xsl:choose>
                                    <xsl:when test="ancestor::endnote">
                                        <xsl:value-of select="count(ancestor::ol[not(descendant::endnote)])"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="count(ancestor::ol)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="($NestingLevel mod 3)=1">
                                    <xsl:number count="li" format="1"/>
                                </xsl:when>
                                <xsl:when test="($NestingLevel mod 3)=2">
                                    <xsl:number count="li" format="a"/>
                                </xsl:when>
                                <xsl:when test="($NestingLevel mod 3)=0">
                                    <xsl:number count="li" format="i"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="position()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>.</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
                <fo:block>
                    <xsl:apply-templates select="child::node()[name()!='ul']"/>
                </fo:block>
                <xsl:apply-templates select="child::node()[name()='ul']"/>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>
    <xsl:template match="dl">
        <fo:list-block>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:if test="not(ancestor::dl)">
                <xsl:attribute name="start-indent">1em</xsl:attribute>
                <xsl:attribute name="provisional-distance-between-starts">6em</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:list-block>
    </xsl:template>
    <xsl:template match="dt">
        <fo:list-item>
            <fo:list-item-label end-indent="label-end()">
                <fo:block font-weight="bold">
                    <xsl:apply-templates select="child::node()[name()!='dd']"/>
                </fo:block>
            </fo:list-item-label>
            <xsl:choose>
                <xsl:when test="following-sibling::dd[1][name()='dd']">
                    <xsl:apply-templates select="following-sibling::dd[1][name()='dd']" mode="dt"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- fo requires a body element; insert it -->
                    <fo:list-item-body start-indent="body-start()">
                        <fo:block/>
                    </fo:list-item-body>
                </xsl:otherwise>
            </xsl:choose>
        </fo:list-item>
    </xsl:template>
    <xsl:template match="dd" mode="dt">
        <fo:list-item-body start-indent="body-start()">
            <fo:block>
                <xsl:apply-templates/>
            </fo:block>
        </fo:list-item-body>
    </xsl:template>
    <!-- ===========================================================
      EXAMPLES
      =========================================================== -->
    <xsl:template match="example">
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block>
            <xsl:if test="@num">
                <xsl:attribute name="id">
                    <xsl:value-of select="@num"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespaceexamples='yes'">
                <xsl:attribute name="line-height">
                    <xsl:value-of select="$sSinglespacingLineHeight"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:attribute name="space-before">
                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:attribute name="space-after">
                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:attribute name="start-indent">
                <xsl:if test="ancestor::framedUnit">
                    <xsl:variable name="framedtype" select="key('FramedTypeID',ancestor::framedUnit/@framedtype)"/>
                    <xsl:call-template name="SetFramedTypeItem">
                        <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@indent-before)"/>
                        <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
                    </xsl:call-template>
                    <xsl:text> + </xsl:text>
                    <xsl:call-template name="SetFramedTypeItem">
                        <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@innerleftmargin)"/>
                        <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
                    </xsl:call-template>
                    <xsl:text> + </xsl:text>
                </xsl:if>
                <xsl:value-of select="$contentLayoutInfo/exampleLayout/@indent-before"/>
            </xsl:attribute>
            <xsl:attribute name="end-indent">
                <xsl:if test="ancestor::framedUnit">
                    <xsl:variable name="framedtype" select="key('FramedTypeID',ancestor::framedUnit/@framedtype)"/>
                    <xsl:call-template name="SetFramedTypeItem">
                        <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@indent-after)"/>
                        <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
                    </xsl:call-template>
                    <xsl:text> + </xsl:text>
                    <xsl:call-template name="SetFramedTypeItem">
                        <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@innerrightmargin)"/>
                        <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
                    </xsl:call-template>
                    <xsl:text> + </xsl:text>
                </xsl:if>
                <xsl:value-of select="$contentLayoutInfo/exampleLayout/@indent-after"/>
            </xsl:attribute>
            <xsl:if test="$sFOProcessor='XFC' and ancestor::endnote">
                <xsl:call-template name="InsertEndnoteWarningMessage">
                    <xsl:with-param name="sKind" select="'example'"/>
                    <xsl:with-param name="sId" select="@num"/>
                </xsl:call-template>
            </xsl:if>
            <fo:table space-before="0pt">
                <xsl:call-template name="DoDebugExamples"/>
                <xsl:attribute name="width">
                    <xsl:value-of select="$sExampleWidth"/>
                </xsl:attribute>
                <fo:table-column column-number="1">
                    <xsl:attribute name="column-width">
                        <xsl:value-of select="$iNumberWidth"/>
                        <xsl:choose>
                            <xsl:when test="$sFOProcessor='XEP'">
                                <!-- units are ems so the font and font size can be taken into account -->
                                <xsl:text>em</xsl:text>
                            </xsl:when>
                            <xsl:when test="$sFOProcessor='XFC'">
                                <!--  units are points because "XFC is not a renderer. It has a limited set of font metrics and therefore handles 'em' units in a very approximate way."
                                    (email of August 10, 2007 from Jean-Yves Belmonte of XMLmind)-->
                                <xsl:text>pt</xsl:text>
                            </xsl:when>
                            <!--  if we can ever get FOP to do something reasonable for examples and interlinear, we'll add a 'when' clause here -->
                        </xsl:choose>
                    </xsl:attribute>
                </fo:table-column>
                <!--  By not specifiying a width for the second column, it appears to use what is left over 
                    (which is what we want).  While this works for XEP, it does not for XFC (or FOP). -->
                <fo:table-column column-number="2">
                    <xsl:choose>
                        <xsl:when test="$sFOProcessor='XEP'">
                            <!-- units are ems so the font and font size can be taken into account for the example number; XEP handles the second column fine without specifying any width -->
                        </xsl:when>
                        <xsl:when test="$sFOProcessor='XFC'">
                            <xsl:attribute name="column-width">
                                <!--  units are points because "XFC is not a renderer. It has a limited set of font metrics and therefore handles 'em' units in a very approximate way."
                                    (email of August 10, 2007 from Jean-Yves Belmonte of XMLmind)-->
                                <xsl:value-of select="number($iExampleWidth - $iNumberWidth)"/>
                                <xsl:text>pt</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <!--  if we can ever get FOP to do something reasonable for examples and interlinear, we'll add a 'when' clause here -->
                    </xsl:choose>
                </fo:table-column>
                <fo:table-body start-indent="0pt" end-indent="0pt">
                    <fo:table-row>
                        <xsl:variable name="bListsShareSameCode">
                            <xsl:call-template name="DetermineIfListsShareSameISOCode"/>
                        </xsl:variable>
                        <fo:table-cell text-align="start" end-indent=".2em">
                            <xsl:call-template name="DoDebugExamples"/>
                            <!--                 <xsl:call-template name="DoCellAttributes"/> -->
                            <fo:block>
                                <xsl:call-template name="GetAndFormatExampleNumber"/>
                                <xsl:if test="not(listDefinition) and not(definition)">
                                    <xsl:call-template name="OutputExampleLevelISOCode">
                                        <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
                                        <xsl:with-param name="sIsoCode">
                                            <xsl:call-template name="GetISOCode">
                                                <xsl:with-param name="originalContext" select="."/>
                                            </xsl:call-template>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:if>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <xsl:call-template name="DoDebugExamples"/>
                            <xsl:apply-templates>
                                <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
                            </xsl:apply-templates>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>
    <!--
      word
      -->
    <xsl:template match="word">
        <xsl:choose>
            <xsl:when test="descendant::word">
                <fo:block>
                    <fo:table space-before="0pt">
                        <fo:table-body start-indent="0pt" end-indent="0pt" keep-together.within-page="1" keep-with-next.within-page="1">
                            <fo:table-row>
                                <xsl:call-template name="OutputWordOrSingle"/>
                            </fo:table-row>
                            <xsl:apply-templates select="word"/>
                        </fo:table-body>
                    </fo:table>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputWordOrSingle"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="word[ancestor::listWord]">
        <xsl:param name="bListsShareSameCode"/>
        <fo:table-row>
            <fo:table-cell text-align="start" end-indent=".2em">
                <!-- letter column -->
                <fo:block/>
            </fo:table-cell>
            <xsl:if test="contains($bListsShareSameCode,'N')">
                <fo:table-cell>
                    <!-- ISO code -->
                    <fo:block/>
                </fo:table-cell>
            </xsl:if>
            <xsl:call-template name="OutputWordOrSingle"/>
        </fo:table-row>
        <xsl:apply-templates select="word">
            <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="word[parent::word and not(ancestor::listWord)]">
        <fo:table-row>
            <xsl:call-template name="HandleLangDataGlossInWordOrListWord"/>
        </fo:table-row>
        <xsl:apply-templates select="word"/>
    </xsl:template>
    <!--
      listWord
      -->
    <xsl:template match="listWord">
        <xsl:param name="bListsShareSameCode"/>
        <xsl:if test="parent::example and count(preceding-sibling::listWord) = 0">
            <xsl:call-template name="OutputList">
                <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--
      single
      -->
    <xsl:template match="single">
        <xsl:call-template name="OutputWordOrSingle"/>
    </xsl:template>
    <!--
      listSingle
      -->
    <xsl:template match="listSingle">
        <xsl:param name="bListsShareSameCode"/>
        <xsl:if test="parent::example and count(preceding-sibling::listSingle) = 0">
            <xsl:call-template name="OutputList">
                <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--
      interlinear
      -->
    <xsl:template match="interlinear">
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <xsl:choose>
            <xsl:when test="parent::interlinear-text">
                <xsl:variable name="sSpaceBetweenUnits">
                    <xsl:value-of select="normalize-space($documentLayoutInfo/interlinearTextLayout/@spaceBetweenUnits)"/>
                </xsl:variable>
                <xsl:if test="string-length($sSpaceBetweenUnits) &gt; 0 and count(preceding-sibling::interlinear) &gt; 0">
                    <fo:block space-before="{$sSpaceBetweenUnits}"/>
                </xsl:if>
                <fo:block id="{@text}" font-size="smaller" font-weight="bold" keep-with-next.within-page="2" orphans="2" widows="2">
                    <xsl:call-template name="GetInterlinearTextShortTitleAndNumber"/>
                </fo:block>
                <fo:block margin-left="0.125in">
                    <xsl:call-template name="OutputInterlinear">
                        <xsl:with-param name="mode" select="'NoTextRef'"/>
                    </xsl:call-template>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputInterlinear"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        interlinearRefCitation
    -->
    <xsl:template match="interlinearRefCitation[@showTitleOnly='short' or @showTitleOnly='full']">
        <xsl:variable name="interlinearSourceStyleLayout" select="$contentLayoutInfo/interlinearSourceStyle"/>
        <fo:inline>
            <fo:basic-link>
                <xsl:call-template name="DoInterlinearTextReferenceLink">
                    <xsl:with-param name="sAttrName">
                        <xsl:call-template name="DetermineInternalOrExternalDestination">
                            <xsl:with-param name="sRef" select="@textref"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/interlinearRefLinkLayout"/>
                </xsl:call-template>
                <xsl:if test="$contentLayoutInfo/interlinearRefCitationTitleLayout">
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="$contentLayoutInfo/interlinearRefCitationTitleLayout"/>
                    </xsl:call-template>
                </xsl:if>
                <!-- we do not show any brackets when these options are set -->
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/interlinearRefCitationTitleLayout"/>
                </xsl:call-template>
                <xsl:call-template name="DoInterlinearRefCitationShowTitleOnly"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$contentLayoutInfo/interlinearRefCitationTitleLayout"/>
                </xsl:call-template>
                <!-- we do not show any brackets when these options are set -->
            </fo:basic-link>
        </fo:inline>
    </xsl:template>
    <xsl:template match="interlinearRefCitation">
        <xsl:variable name="interlinearSourceStyleLayout" select="$contentLayoutInfo/interlinearSourceStyle"/>
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$interlinearSourceStyleLayout"/>
            </xsl:call-template>
            <xsl:if test="not(@bracket) or @bracket='both' or @bracket='initial'">
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:variable name="interlinear" select="key('InterlinearReferenceID',@textref)"/>
            <fo:basic-link>
                <xsl:call-template name="DoInterlinearTextReferenceLink">
                    <xsl:with-param name="sAttrName">
                        <xsl:call-template name="DetermineInternalOrExternalDestination">
                            <xsl:with-param name="sRef" select="@textref"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="name($interlinear)='interlinear-text'">
                        <xsl:choose>
                            <xsl:when test="$interlinear/textInfo/shortTitle and string-length($interlinear/textInfo/shortTitle) &gt; 0">
                                <xsl:apply-templates select="$interlinear/textInfo/shortTitle/child::node()[name()!='endnote']"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$interlinear/textInfo/textTitle/child::node()[name()!='endnote']"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="DoInterlinearRefCitationContent">
                            <xsl:with-param name="sRef" select="@textref"/>
                        </xsl:call-template>

                        <!--                    <xsl:call-template name="DoInterlinearRefCitation">
                        <xsl:with-param name="sRef" select="@textref"/>
                    </xsl:call-template>
-->
                    </xsl:otherwise>
                </xsl:choose>
            </fo:basic-link>
            <xsl:if test="not(@bracket) or @bracket='both' or @bracket='final'">
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
                </xsl:call-template>
            </xsl:if>
        </fo:inline>
    </xsl:template>
    <!--
      interlinearSource
   -->
    <xsl:template match="interlinearSource" mode="contents">
        <xsl:variable name="interlinearSourceStyleLayout" select="$contentLayoutInfo/interlinearSourceStyle"/>
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$interlinearSourceStyleLayout"/>
            </xsl:call-template>
            <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>
    <!--
      conflatedLine
      -->
    <xsl:template match="conflatedLine">
        <tr style="line-height:87.5%">
            <td valign="top">
                <xsl:if test="name(..)='interlinear' and position()=1">
                    <xsl:call-template name="OutputExampleNumber"/>
                </xsl:if>
            </td>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    <!--
      lineSet
      -->
    <xsl:template match="lineSet">
        <xsl:choose>
            <xsl:when test="name(..)='conflation'">
                <tr>
                    <xsl:if test="@letter">
                        <td valign="top">
                            <xsl:element name="a">
                                <xsl:attribute name="name">
                                    <xsl:value-of select="@letter"/>
                                </xsl:attribute>
                                <xsl:apply-templates select="." mode="letter"/>.</xsl:element>
                        </td>
                    </xsl:if>
                    <td>
                        <table>
                            <xsl:apply-templates/>
                        </table>
                    </td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <td>
                    <table>
                        <xsl:apply-templates/>
                    </table>
                </td>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      conflation
      -->
    <xsl:template match="conflation">
        <xsl:variable name="sCount" select="count(descendant::*[lineSetRow])"/>
        <!--  sCount = <xsl:value-of select="$sCount"/> -->
        <td>
            <img align="middle">
                <xsl:attribute name="src">
                    <xsl:text>LeftBrace</xsl:text>
                    <xsl:value-of select="$sCount"/>
                    <xsl:text>.png</xsl:text>
                </xsl:attribute>
            </img>
        </td>
        <td>
            <table>
                <xsl:apply-templates/>
            </table>
        </td>
        <td>
            <img align="middle">
                <xsl:attribute name="src">
                    <xsl:text>RightBrace</xsl:text>
                    <xsl:value-of select="$sCount"/>
                    <xsl:text>.png</xsl:text>
                </xsl:attribute>
            </img>
        </td>
    </xsl:template>
    <!--
      lineSetRow
      -->
    <xsl:template match="lineSetRow">
        <tr style="line-height:87.5%">
            <xsl:for-each select="wrd">
                <xsl:element name="td">
                    <xsl:attribute name="class">
                        <xsl:value-of select="@lang"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:for-each>
        </tr>
    </xsl:template>
    <!--
      listInterlinear
      -->
    <xsl:template match="listInterlinear">
        <xsl:param name="bListsShareSameCode"/>
        <xsl:if test="parent::example and count(preceding-sibling::listInterlinear) = 0">
            <xsl:call-template name="OutputList">
                <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!-- ================================ -->
    <!--
      phrase
      -->
    <xsl:template match="phrase">
        <xsl:choose>
            <xsl:when test="position() != 1">
                <fo:block/>
                <!--                <fo:inline margin-left=".125in">  Should we indent here? -->
                <xsl:apply-templates/>
                <!--                </fo:inline>-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      phrase/item
      -->
    <xsl:template match="phrase/item">
        <xsl:choose>
            <xsl:when test="@type='txt'">
                <fo:block>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </fo:block>
            </xsl:when>
            <xsl:when test="@type='gls'">
                <xsl:choose>
                    <xsl:when test="count(../preceding-sibling::phrase) &gt; 0">
                        <!--                        <fo:inline margin-left=".125in"> Should we indent here? -->
                        <fo:block>
                            <xsl:call-template name="OutputFontAttributes">
                                <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                            </xsl:call-template>
                            <xsl:apply-templates/>
                        </fo:block>
                        <!--                        </fo:inline>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:block>
                            <xsl:call-template name="OutputFontAttributes">
                                <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                            </xsl:call-template>
                            <xsl:apply-templates/>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@type='note'">
                <fo:block>
                    <xsl:text>Note: </xsl:text>
                    <fo:inline>
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                        </xsl:call-template>
                        <xsl:apply-templates/>
                    </fo:inline>
                </fo:block>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
      words
      -->
    <xsl:template match="words">
        <fo:block>
            <fo:inline-container>
                <xsl:apply-templates/>
            </fo:inline-container>
        </fo:block>
    </xsl:template>
    <!--
      iword
      -->
    <xsl:template match="iword">
        <fo:table border="thin solid black">
            <fo:table-body>
                <xsl:apply-templates/>
            </fo:table-body>
        </fo:table>
    </xsl:template>
    <!--
      iword/item[@type='txt']
      -->
    <xsl:template match="iword/item[@type='txt']">
        <fo:table-row>
            <fo:table-cell>
                <fo:block>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                    <xsl:text>&#160;</xsl:text>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    <!--
      iword/item[@type='gls']
      -->
    <xsl:template match="iword/item[@type='gls']">
        <fo:table-row>
            <fo:table-cell>
                <fo:block>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    </xsl:call-template>
                    <xsl:if test="string(.)">
                        <xsl:apply-templates/>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:if>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    <!--
      iword/item[@type='pos']
      -->
    <xsl:template match="iword/item[@type='pos']">
        <fo:table-row>
            <fo:table-cell>
                <fo:block>
                    <xsl:if test="string(.)">
                        <xsl:apply-templates/>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:if>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    <!--
      iword/item[@type='punct']
      -->
    <xsl:template match="iword/item[@type='punct']">
        <fo:table-row>
            <fo:table-cell>
                <fo:block>
                    <xsl:if test="string(.)">
                        <xsl:apply-templates/>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:if>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    <!--
      morphemes
      -->
    <xsl:template match="morphemes">
        <fo:table-row>
            <fo:table-cell>
                <fo:block>
                    <xsl:apply-templates/>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    <!--
      morphset
      -->
    <xsl:template match="morphset">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      morph
      -->
    <xsl:template match="morph">
        <fo:table>
            <fo:table-body>
                <xsl:apply-templates/>
            </fo:table-body>
        </fo:table>
    </xsl:template>
    <!--
      morph/item
      -->
    <xsl:template match="morph/item[@type!='hn' and @type!='cf']">
        <fo:table-row>
            <fo:table-cell>
                <fo:block>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                    <xsl:text>&#160;</xsl:text>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    <!--
      morph/item[@type='hn']
      -->
    <!-- suppress homograph numbers, so they don't occupy an extra line-->
    <xsl:template match="morph/item[@type='hn']"/>
    <!-- This mode occurs within the 'cf' item to display the homograph number from the following item.-->
    <xsl:template match="morph/item[@type='hn']" mode="hn">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      morph/item[@type='cf']
      -->
    <xsl:template match="morph/item[@type='cf']">
        <fo:table-row>
            <fo:table-cell>
                <fo:block>
                    <xsl:apply-templates/>
                    <xsl:variable name="homographNumber" select="following-sibling::item[@type='hn']"/>
                    <xsl:if test="$homographNumber">
                        <fo:inline baseline-shift="sub">
                            <xsl:apply-templates select="$homographNumber" mode="hn"/>
                        </fo:inline>
                    </xsl:if>
                    <xsl:text>&#160;</xsl:text>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    <!-- ================================ -->
    <!--
        definition
    -->
    <xsl:template match="example/definition">
        <fo:block>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <xsl:template match="definition[not(parent::example)]">
        <fo:inline>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </fo:inline>
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
        chart
    -->
    <xsl:template match="chart">
        <fo:block>
            <xsl:call-template name="DoType"/>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!--
      tree
      -->
    <xsl:template match="tree">
        <fo:block keep-together="2">
            <xsl:call-template name="DoType"/>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!--
      table
      -->
    <xsl:template match="table">
        <fo:block>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacetables='yes'">
                <xsl:attribute name="line-height">
                    <xsl:value-of select="$sSinglespacingLineHeight"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <!--  If this is in an example, an embedded table, or within a list, then there's no need to add extra space around it. -->
            <xsl:choose>
                <xsl:when test="not(parent::example) and not(ancestor::table) and not(ancestor::li)">
                    <xsl:attribute name="space-before">
                        <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                    <xsl:attribute name="space-after">
                        <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                    <xsl:attribute name="start-indent">
                        <xsl:call-template name="HandleFramedUnitStartIndent"/>
                        <xsl:value-of select="$sBlockQuoteIndent"/>
                    </xsl:attribute>
                    <xsl:attribute name="end-indent">
                        <xsl:call-template name="HandleFramedUnitEndIndent"/>
                        <xsl:value-of select="$sBlockQuoteIndent"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="ancestor::li">
                    <xsl:attribute name="space-before">
                        <xsl:value-of select="$sBasicPointSize div 2"/>pt</xsl:attribute>
                    <xsl:attribute name="space-after">
                        <xsl:value-of select="$sBasicPointSize div 2"/>pt</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:call-template name="DoType"/>
            <xsl:if test="$sFOProcessor='XFC' and parent::endnote">
                <xsl:call-template name="InsertEndnoteWarningMessage">
                    <xsl:with-param name="sKind" select="'table'"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="caption">
                    <fo:table-and-caption>
                        <fo:table-caption>
                            <xsl:apply-templates select="caption"/>
                        </fo:table-caption>
                        <xsl:call-template name="OutputTable"/>
                    </fo:table-and-caption>
                </xsl:when>
                <xsl:when test="endCaption">
                    <xsl:call-template name="OutputTable"/>
                    <xsl:apply-templates select="endCaption"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="OutputTable"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
    <!--
          headerRow for a table
      -->
    <xsl:template match="headerRow">
        <!--
not using
        <xsl:if test="@class">
            <xsl:element name="tr">
                <xsl:attribute name="class">
                    <xsl:value-of select="@class"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="not(@class)">
            <tr>
                <xsl:apply-templates/>
            </tr>
        </xsl:if>
        -->
    </xsl:template>
    <!--
          headerCol for a table
      -->
    <xsl:template match="headerCol | th">
        <fo:table-cell border-collapse="collapse">
            <xsl:attribute name="padding">.2em</xsl:attribute>
            <xsl:call-template name="DoCellAttributes"/>
            <xsl:call-template name="DoType"/>
            <xsl:call-template name="OutputBackgroundColor"/>
            <fo:block font-weight="bold" start-indent="0pt" end-indent="0pt">
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    <!--
          row for a table
      -->
    <xsl:template match="tr | row">
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:table-row>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:call-template name="DoType"/>
            <xsl:call-template name="OutputBackgroundColor"/>
            <xsl:apply-templates/>
        </fo:table-row>
    </xsl:template>
    <!--
          col for a table
      -->
    <xsl:template match="td | col">
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:table-cell border-collapse="collapse">
            <xsl:choose>
                <xsl:when test="ancestor::table[1]/@border!='0' or count(ancestor::table)=1">
                    <xsl:attribute name="padding">.2em</xsl:attribute>
                </xsl:when>
                <xsl:when test="position() &gt; 1">
                    <xsl:attribute name="padding-left">.2em</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:call-template name="DoCellAttributes"/>
            <xsl:call-template name="DoType"/>
            <xsl:call-template name="OutputBackgroundColor"/>
            <fo:block>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    <!--
          caption for a table
      -->
    <xsl:template match="caption | endCaption">
        <xsl:if test="not(ancestor::tablenumbered)">
            <fo:block font-weight="bold">
                <xsl:call-template name="DoCellAttributes"/>
                <xsl:if test="not(@align)">
                    <!-- default to centered -->
                    <xsl:attribute name="text-align">center</xsl:attribute>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="name()='caption'">
                        <xsl:attribute name="space-after">.3em</xsl:attribute>
                        <xsl:attribute name="keep-with-next.within-page">10</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="padding-before">.3em</xsl:attribute>
                        <xsl:attribute name="keep-with-previous.within-page">10</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="DoType"/>
                <xsl:apply-templates/>
            </fo:block>
        </xsl:if>
    </xsl:template>
    <!--
      exampleHeading
   -->
    <xsl:template match="exampleHeading">
        <fo:table space-before="0pt">
            <fo:table-body start-indent="0pt" end-indent="0pt" keep-together.within-page="1" keep-with-next.within-page="1">
                <fo:table-row>
                    <fo:table-cell padding-end=".5em" text-align="start">
                        <fo:block>
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:template>
    <!--
      exampleRef
      -->
    <xsl:template match="exampleRef">
        <fo:basic-link>
            <xsl:attribute name="internal-destination">
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
        </fo:basic-link>
    </xsl:template>
    <xsl:template match="exampleRef" mode="bookmarks">
        <xsl:call-template name="DoExampleRefContent"/>
    </xsl:template>
    <!--
        iso639-3codeRef
    -->
    <xsl:template match="iso639-3codeRef">
        <fo:inline>
            <fo:basic-link internal-destination="{@lang}">
                <fo:inline>
                    <xsl:call-template name="AddAnyLinkAttributes">
                        <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/iso639-3CodesLinkLayout"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoISO639-3codeRefContent"/>
                </fo:inline>
            </fo:basic-link>
        </fo:inline>
    </xsl:template>

    <!--
        figure
    -->
    <xsl:template match="figure">
        <xsl:choose>
            <xsl:when test="descendant::endnote or $sFOProcessor='XFC' or @location='here'">
                <!--  cannot have endnotes in floats... 
                        and XFC does not handle floats.
                        If the user says, Put it here, don't treat it like a float
                -->
                <xsl:call-template name="DoFigure"/>
            </xsl:when>
            <xsl:otherwise>
                <fo:float>
                    <xsl:if test="@location='topOfPage' or @location='bottomOfPage'">
                        <xsl:attribute name="float">
                            <xsl:text>before</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="DoFigure"/>
                </fo:float>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        figureRef
    -->
    <xsl:template match="figureRef">
        <xsl:call-template name="OutputAnyTextBeforeFigureRef"/>
        <fo:basic-link internal-destination="{@figure}">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/figureRefLinkLayout"/>
            </xsl:call-template>
            <fo:inline>
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
                <xsl:call-template name="DoFigureRef"/>
            </fo:inline>
        </fo:basic-link>
    </xsl:template>
    <!--
        listOfFiguresShownHere
    -->
    <xsl:template match="listOfFiguresShownHere">
        <xsl:if test="$contentLayoutInfo/figureLayout/@listOfFiguresUsesFigureAndPageHeaders='yes'">
            <fo:block start-indent="0pt" end-indent="0pt" text-align-last="justify">
                <xsl:call-template name="OutputFigureLabel"/>
                <fo:leader leader-pattern="space"/>
                <xsl:variable name="sLabel" select="normalize-space($contentLayoutInfo/figureLayout/@pageLabelInListOfFigures)"/>
                <xsl:choose>
                    <xsl:when test="string-length($sLabel)&gt;0">
                        <xsl:value-of select="$sLabel"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Page</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:block>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $frontMatterLayoutInfo/contentsLayout/@singlespaceeachcontentline='yes'">
                <fo:block>
                    <xsl:attribute name="line-height">
                        <xsl:choose>
                            <xsl:when test="$sLineSpacing='double'">
                                <xsl:text>-.6</xsl:text>
                            </xsl:when>
                            <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                                <xsl:text>-.45</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:text>&#xa0;</xsl:text>
                </fo:block>
            </xsl:if>
        </xsl:if>
        <xsl:for-each select="//figure[not(ancestor::endnote or ancestor::framedUnit)]">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink" select="@id"/>
                <xsl:with-param name="sLabel">
                    <xsl:choose>
                        <xsl:when test="$contentLayoutInfo/figureLayout/@listOfFiguresUsesFigureAndPageHeaders='yes'">
                            <xsl:value-of select="$styleSheetFigureNumberLayout/@textbefore"/>
                            <xsl:call-template name="GetFigureNumber">
                                <xsl:with-param name="figure" select="."/>
                            </xsl:call-template>
                            <xsl:value-of select="$styleSheetFigureNumberLayout/@textafter"/>
                            <xsl:text>&#xa0;</xsl:text>
                            <xsl:text>&#xa0;</xsl:text>
                            <!--                            <xsl:value-of select="$styleSheetFigureCaptionLayout/@textbefore"/>-->
                            <xsl:apply-templates select="caption" mode="contents"/>
                            <xsl:value-of select="$styleSheetFigureCaptionLayout/@textafter"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="OutputFigureLabelAndCaption">
                                <xsl:with-param name="bDoStyles" select="'N'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="sIndent" select="'1em'"/>
                <xsl:with-param name="fInListOfItems" select="'yes'"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--
        tablenumbered
    -->
    <xsl:template match="tablenumbered">
        <xsl:choose>
            <xsl:when test="descendant::endnote or $sFOProcessor='XFC' or @location='here'">
                <!--  cannot have endnotes in floats...
                        and XFC does not handle floats
                        If the user says, Put it here, don't treat it like a float
                -->
                <xsl:call-template name="DoTableNumbered"/>
            </xsl:when>
            <xsl:otherwise>
                <fo:float>
                    <xsl:if test="@location='topOfPage' or @location='bottomOfPage'">
                        <xsl:attribute name="float">
                            <xsl:text>before</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="DoTableNumbered"/>
                </fo:float>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        tablenumberedRef
    -->
    <xsl:template match="tablenumberedRef">
        <xsl:call-template name="OutputAnyTextBeforeTablenumberedRef"/>
        <fo:basic-link internal-destination="{@table}">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/tablenumberedRefLinkLayout"/>
            </xsl:call-template>
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
            <xsl:call-template name="DoTablenumberedRef"/>
        </fo:basic-link>
    </xsl:template>
    <!--
        listOfTablesShownHere
    -->
    <xsl:template match="listOfTablesShownHere">
        <xsl:if test="$contentLayoutInfo/tablenumberedLayout/@listOfTablesUsesTableAndPageHeaders='yes'">
            <fo:block start-indent="0pt" end-indent="0pt" text-align-last="justify">
                <xsl:call-template name="OutputTableNumberedLabel"/>
                <fo:leader leader-pattern="space"/>
                <xsl:variable name="sLabel" select="normalize-space($contentLayoutInfo/tablenumberedLayout/@pageLabelInListOfTables)"/>
                <xsl:choose>
                    <xsl:when test="string-length($sLabel)&gt;0">
                        <xsl:value-of select="$sLabel"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Page</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:block>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $frontMatterLayoutInfo/contentsLayout/@singlespaceeachcontentline='yes'">
                <fo:block>
                    <xsl:attribute name="line-height">
                        <xsl:choose>
                            <xsl:when test="$sLineSpacing='double'">
                                <xsl:text>-.6</xsl:text>
                            </xsl:when>
                            <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                                <xsl:text>-.45</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:text>&#xa0;</xsl:text>
                </fo:block>
            </xsl:if>
        </xsl:if>
        <xsl:for-each select="//tablenumbered[not(ancestor::endnote or ancestor::framedUnit)]">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink" select="@id"/>
                <xsl:with-param name="sLabel">
                    <xsl:choose>
                        <xsl:when test="$contentLayoutInfo/tablenumberedLayout/@listOfTablesUsesTableAndPageHeaders='yes'">
                            <xsl:value-of select="$styleSheetTableNumberedNumberLayout/@textbefore"/>
                            <xsl:call-template name="GetTableNumberedNumber">
                                <xsl:with-param name="tablenumbered" select="."/>
                            </xsl:call-template>
                            <xsl:value-of select="$styleSheetTableNumberedNumberLayout/@textafter"/>
                            <xsl:text>&#xa0;</xsl:text>
                            <xsl:text>&#xa0;</xsl:text>
                            <!--                            <xsl:value-of select="$styleSheetFigureCaptionLayout/@textbefore"/>-->
                            <xsl:apply-templates select="table/caption | table/endCaption | caption" mode="contents"/>
                            <xsl:value-of select="$styleSheetTableNumberedCaptionLayout/@textafter"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="OutputTableNumberedLabelAndCaption">
                                <xsl:with-param name="bDoStyles" select="'N'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="sIndent" select="'1em'"/>
                <xsl:with-param name="fInListOfItems" select="'yes'"/>
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
    <xsl:template match="endnote">
        <xsl:param name="originalContext"/>
        <xsl:variable name="iTablenumberedAdjust">
            <xsl:choose>
                <xsl:when test="ancestor::tablenumbered">
                    <xsl:choose>
                        <xsl:when
                            test="$contentLayoutInfo/tablenumberedLayout/@captionLocation='after' or not($contentLayoutInfo/tablenumberedLayout) and $lingPaper/@tablenumberedLabelAndCaptionLocation='after'">
                            <xsl:choose>
                                <xsl:when test="ancestor::caption">
                                    <xsl:value-of select="count(ancestor::tablenumbered/table/descendant::*[name()!='caption']/descendant::endnote)"/>
                                </xsl:when>
                                <xsl:when test="ancestor::table">
                                    <xsl:value-of select="-count(ancestor::tablenumbered/table/caption/descendant::endnote)"/>
                                </xsl:when>
                                <xsl:otherwise>0</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$backMatterLayoutInfo/useEndNotesLayout">
                <xsl:call-template name="DoFootnoteNumberInText">
                    <xsl:with-param name="originalContext" select="$originalContext"/>
                    <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <fo:footnote>
                    <xsl:call-template name="DoFootnoteNumberInText">
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                        <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
                    </xsl:call-template>
                    <!-- insert a new line so we don't get everything all on one line -->
                    <xsl:text>&#xa;</xsl:text>
                    <fo:footnote-body>
                        <xsl:call-template name="DoFootnoteContent">
                            <xsl:with-param name="originalContext" select="$originalContext"/>
                            <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
                        </xsl:call-template>
                    </fo:footnote-body>
                </fo:footnote>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        endnote in backmatter
    -->
    <xsl:template match="endnote" mode="backMatter">
        <xsl:param name="originalContext"/>
        <xsl:choose>
            <xsl:when test="$contentLayoutInfo/tablenumberedLayout/@captionLocation='after' or not($contentLayoutInfo/tablenumberedLayout) and $lingPaper/@tablenumberedLabelAndCaptionLocation='after'">
                <xsl:choose>
                    <xsl:when test="ancestor::tablenumbered/table/descendant::endnote and ancestor::caption">
                        <!-- skip these for now -->
                    </xsl:when>
                    <xsl:when test="ancestor::tablenumbered/table/caption/descendant-or-self::endnote and ancestor::table">
                        <xsl:call-template name="HandleEndnoteInBackMatter">
                            <xsl:with-param name="originalContext" select="$originalContext"/>
                            <xsl:with-param name="iTablenumberedAdjust" select="-count(ancestor::tablenumbered/table/caption/descendant-or-self::endnote)"/>
                        </xsl:call-template>
                        <xsl:if test="ancestor::tablenumbered/table/descendant::endnote[position()=last()]=.">
                            <!-- this is the last endnote in the table; now handle all endnotes in the caption -->
                            <xsl:variable name="iTablenumberedAdjust" select="count(ancestor::tablenumbered/table/tr/descendant::endnote)"/>
                            <xsl:for-each select="ancestor::tablenumbered/table/caption/descendant-or-self::endnote">
                                <xsl:call-template name="HandleEndnoteInBackMatter">
                                    <xsl:with-param name="originalContext" select="$originalContext"/>
                                    <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="HandleEndnoteInBackMatter">
                            <xsl:with-param name="originalContext" select="$originalContext"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="HandleEndnoteInBackMatter">
                    <xsl:with-param name="originalContext" select="$originalContext"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    <!--
        endnoteRef in backmatter
    -->
    <xsl:template match="endnoteRef" mode="backMatter">
        <xsl:param name="originalContext"/>
        <xsl:call-template name="DoEndnoteRefContent">
            <xsl:with-param name="sFootnoteNumber">
                <xsl:call-template name="GetFootnoteNumber">
                    <xsl:with-param name="originalContext" select="."/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
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
            <xsl:when test="$backMatterLayoutInfo/useEndNotesLayout">
                <xsl:call-template name="DoFootnoteNumberInText">
                    <xsl:with-param name="originalContext" select="."/>
                    <xsl:with-param name="link" select="@note"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <fo:footnote>
                    <xsl:variable name="sFootnoteNumber">
                        <xsl:call-template name="GetFootnoteNumber"/>
                    </xsl:variable>
                    <fo:inline baseline-shift="super" id="{@id}">
                        <xsl:attribute name="font-size">
                            <xsl:value-of select="$sFootnotePointSize - 2"/>
                            <xsl:text>pt</xsl:text>
                        </xsl:attribute>
                        <xsl:call-template name="InsertCommaBetweenConsecutiveEndnotes"/>
                        <xsl:value-of select="$sFootnoteNumber"/>
                    </fo:inline>
                    <fo:footnote-body>
                        <xsl:call-template name="DoEndnoteRefContent">
                            <xsl:with-param name="sFootnoteNumber" select="$sFootnoteNumber"/>
                        </xsl:call-template>
                    </fo:footnote-body>
                </fo:footnote>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="DoEndnoteRefContent">
        <xsl:param name="sFootnoteNumber"/>
        <fo:block text-align="left" text-indent="1em" font-size="{$sFootnotePointSize}pt" id="{@note}">
            <fo:inline baseline-shift="super">
                <xsl:attribute name="font-size">
                    <xsl:value-of select="$sFootnotePointSize - 2"/>
                    <xsl:text>pt</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$sFootnoteNumber"/>
            </fo:inline>
            <xsl:variable name="endnoteRefLayout" select="$contentLayoutInfo/endnoteRefLayout"/>
            <fo:inline>
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
            </fo:inline>
            <xsl:call-template name="DoEndnoteRefNumber"/>
            <xsl:choose>
                <xsl:when test="$bIsBook">
                    <xsl:text> in chapter </xsl:text>
                    <xsl:variable name="sNoteId" select="@note"/>
                    <xsl:for-each select="$chapters[descendant::endnote[@id=$sNoteId]]">
                        <xsl:number level="any" count="chapter | chapterInCollection" format="1"/>
                    </xsl:for-each>
                    <xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="string-length($endnoteRefLayout/@textafter) &gt; 0">
                <fo:inline>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="$endnoteRefLayout"/>
                    </xsl:call-template>
                    <xsl:value-of select="$endnoteRefLayout/@textafter"/>
                </fo:inline>
            </xsl:if>
        </fo:block>
    </xsl:template>
    <!--
      endnotes
   -->
    <xsl:template match="endnotes">
        <xsl:if test="$backMatterLayoutInfo/useEndNotesLayout">
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:choose>
                <xsl:when test="$bIsBook">
                    <!-- insert a new line so we don't get everything all on one line -->
                    <xsl:text>&#xa;</xsl:text>
                    <fo:page-sequence master-reference="Chapter">
                        <xsl:call-template name="DoInitialPageNumberAttribute">
                            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/useEndNotesLayout"/>
                        </xsl:call-template>
                        <xsl:call-template name="OutputChapterStaticContentForBackMatter"> </xsl:call-template>
                        <fo:flow flow-name="xsl-region-body">
                            <xsl:attribute name="font-family">
                                <xsl:value-of select="$sDefaultFontFamily"/>
                            </xsl:attribute>
                            <xsl:attribute name="font-size">
                                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                            <fo:marker marker-class-name="chap-title">
                                <xsl:call-template name="OutputEndnotesLabel">
                                    <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                                </xsl:call-template>
                            </fo:marker>
                            <xsl:call-template name="DoEndnotes"/>
                        </fo:flow>
                    </fo:page-sequence>
                </xsl:when>
                <xsl:otherwise>
                    <fo:block orphans="2" widows="2">
                        <xsl:call-template name="DoEndnotes"/>
                    </fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!-- ===========================================================
        CITATIONS, Glossary, Indexes and REFERENCES 
        =========================================================== -->
    <!--
        citation
    -->
    <xsl:template match="citation" mode="bookmarks">
        <xsl:call-template name="OutputCitationContents">
            <xsl:with-param name="refer" select="id(@ref)"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="citation" mode="contents">
        <xsl:call-template name="OutputCitationContents">
            <xsl:with-param name="refer" select="id(@ref)"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="//citation[not(parent::selectedBibliography)]">
        <xsl:variable name="refer" select="id(@ref)"/>
        <fo:basic-link internal-destination="{@ref}">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/citationLinkLayout"/>
            </xsl:call-template>
            <xsl:call-template name="OutputCitationContents">
                <xsl:with-param name="refer" select="$refer"/>
            </xsl:call-template>
        </fo:basic-link>
    </xsl:template>
    <!--
      index
      -->
    <xsl:template match="index">
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <xsl:choose>
            <xsl:when test="$bIsBook">
                <!-- insert a new line so we don't get everything all on one line -->
                <xsl:text>&#xa;</xsl:text>
                <fo:page-sequence master-reference="Index">
                    <xsl:call-template name="DoInitialPageNumberAttribute">
                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/indexLayout"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputIndexStaticContent">
                        <xsl:with-param name="sIndexTitle" select="'index-title'"/>
                    </xsl:call-template>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:attribute name="font-family">
                            <xsl:value-of select="$sDefaultFontFamily"/>
                        </xsl:attribute>
                        <xsl:attribute name="font-size">
                            <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                        <fo:marker marker-class-name="index-title">
                            <xsl:call-template name="OutputIndexLabel">
                                <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                            </xsl:call-template>
                        </fo:marker>
                        <xsl:call-template name="DoIndex"/>
                        <xsl:if test="not(following-sibling::index)">
                            <xsl:call-template name="HandleKeywordsLayoutWithoutPageBreak">
                                <xsl:with-param name="keywordsLayout" select="$backMatterLayoutInfo/indexLayout/following-sibling::*[1]"/>
                                <xsl:with-param name="backMatterLayout" select="$backMatterLayoutInfo"/>
                            </xsl:call-template>
                        </xsl:if>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoIndex"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      indexedItem or indexedRangeBegin
      -->
    <xsl:template match="indexedItem[not(ancestor::comment)] | indexedRangeBegin[not(ancestor::comment)]">
        <fo:inline>
            <xsl:attribute name="id">
                <xsl:call-template name="CreateIndexedItemID">
                    <xsl:with-param name="sTermId" select="@term"/>
                </xsl:call-template>
            </xsl:attribute>
        </fo:inline>
    </xsl:template>
    <!--
      indexedRangeEnd
      -->
    <xsl:template match="indexedRangeEnd">
        <fo:inline>
            <xsl:attribute name="id">
                <xsl:call-template name="CreateIndexedItemID">
                    <xsl:with-param name="sTermId" select="@begin"/>
                </xsl:call-template>
            </xsl:attribute>
        </fo:inline>
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
        <xsl:param name="backMatterLayout" select="$backMatterLayoutInfo"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="DoBackMatterPerLayout">
            <xsl:with-param name="backMatter" select="."/>
            <xsl:with-param name="backMatterLayout" select="$backMatterLayout"/>
            <xsl:with-param name="frontMatter" select="./preceding-sibling::frontMatter"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      references
      -->
    <xsl:template match="references">
        <xsl:param name="backMatterLayout" select="$backMatterLayoutInfo"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <xsl:choose>
            <xsl:when test="$bIsBook and not(ancestor::chapterInCollection)">
                <!-- insert a new line so we don't get everything all on one line -->
                <xsl:text>&#xa;</xsl:text>
                <fo:page-sequence master-reference="Chapter">
                    <xsl:call-template name="DoInitialPageNumberAttribute">
                        <xsl:with-param name="layoutInfo" select="$backMatterLayout/referencesTitleLayout"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputChapterStaticContentForBackMatter"> </xsl:call-template>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:attribute name="font-family">
                            <xsl:value-of select="$sDefaultFontFamily"/>
                        </xsl:attribute>
                        <xsl:attribute name="font-size">
                            <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                        <fo:marker marker-class-name="chap-title">
                            <xsl:call-template name="OutputReferencesLabel">
                                <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                            </xsl:call-template>
                        </fo:marker>
                        <xsl:call-template name="DoReferences">
                            <xsl:with-param name="backMatterLayout" select="$backMatterLayout"/>
                        </xsl:call-template>
                        <xsl:call-template name="HandleKeywordsLayoutWithoutPageBreak">
                            <xsl:with-param name="keywordsLayout" select="$backMatterLayout/referencesLayout/following-sibling::*[1]"/>
                            <xsl:with-param name="backMatterLayout" select="$backMatterLayout"/>
                        </xsl:call-template>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:when>
            <xsl:otherwise>
                <fo:block orphans="2" widows="2">
                    <xsl:call-template name="DoReferences">
                        <xsl:with-param name="backMatterLayout" select="$backMatterLayout"/>
                    </xsl:call-template>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        refAuthorLastName
    -->
    <xsl:template match="refAuthorLastName">
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$referencesLayoutInfo/refAuthorLayouts/refAuthorLastNameLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <!--
        refAuthorName
    -->
    <xsl:template match="refAuthorName">
        <fo:inline>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <!--
        authorContactInfo
    -->
    <xsl:template match="authorContactInfo">
        <xsl:param name="layoutInfo"/>
        <fo:table-cell>
            <xsl:choose>
                <xsl:when test="preceding-sibling::authorContactInfo">
                    <!--                do nothing special-->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="firstLayoutItem" select="$layoutInfo/*[position()=1]"/>
                    <xsl:call-template name="DoPageBreakFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$firstLayoutItem"/>
                    </xsl:call-template>
                    <xsl:variable name="sSpaceBefore" select="normalize-space($firstLayoutItem/@spacebefore)"/>
                    <xsl:if test="string-length($sSpaceBefore)&gt;0 and $sFOProcessor='XEP'">
                        <xsl:attribute name="space-before">
                            <xsl:value-of select="$sSpaceBefore"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <fo:table>
                <fo:table-column/>
                <fo:table-body>
                    <xsl:call-template name="DoAuthorContactInfoPerLayout">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        <xsl:with-param name="authorInfo" select="key('AuthorContactID',@author)"/>
                    </xsl:call-template>
                </fo:table-body>
            </fo:table>
        </fo:table-cell>
    </xsl:template>
    <!-- ===========================================================
      BR
      =========================================================== -->
    <xsl:template match="br">
        <fo:block/>
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
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$language"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
            <!-- insert a new line so we don't get everything all on one line -->
            <!--            <xsl:text>&#xa;</xsl:text> no, it inserts an extra space-->
            <fo:inline>
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
            </fo:inline>
        </fo:inline>
        <xsl:call-template name="HandleGlossTextAfterOutside">
            <xsl:with-param name="glossLayout" select="$glossLayout"/>
            <xsl:with-param name="sGlossContext" select="$sGlossContext"/>
        </xsl:call-template>
    </xsl:template>
    <!-- ===========================================================
      ABBREVIATION
      =========================================================== -->
    <xsl:template match="abbrRef" mode="bookmarks">
        <xsl:call-template name="OutputAbbrTerm">
            <xsl:with-param name="abbr" select="id(@abbr)"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="abbrRef" mode="contents">
        <xsl:call-template name="OutputAbbrTerm">
            <xsl:with-param name="abbr" select="id(@abbr)"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="abbrRef">
        <xsl:choose>
            <xsl:when test="ancestor::genericRef">
                <xsl:call-template name="OutputAbbrTerm">
                    <xsl:with-param name="abbr" select="id(@abbr)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <fo:inline>
                    <fo:basic-link>
                        <xsl:attribute name="internal-destination">
                            <xsl:value-of select="@abbr"/>
                        </xsl:attribute>
                        <xsl:call-template name="AddAnyLinkAttributes">
                            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/abbrRefLinkLayout"/>
                        </xsl:call-template>
                        <xsl:call-template name="OutputAbbrTerm">
                            <xsl:with-param name="abbr" select="id(@abbr)"/>
                        </xsl:call-template>
                    </fo:basic-link>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="abbreviationsShownHere">
        <xsl:if test="$iAbbreviationCount &gt; 0">
            <xsl:choose>
                <xsl:when test="ancestor::endnote">
                    <xsl:choose>
                        <xsl:when test="parent::p">
                            <xsl:call-template name="HandleAbbreviationsInCommaSeparatedList"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:block>
                                <xsl:call-template name="HandleAbbreviationsInCommaSeparatedList"/>
                            </fo:block>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="not(ancestor::p)">
                    <!-- ignore any other abbreviationsShownHere in a p except when also in an endnote; everything else goes in a table -->
                    <xsl:call-template name="HandleAbbreviationsInTable"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template match="abbrDefinition"/>
    <!-- ===========================================================
        glossaryTerms
        =========================================================== -->
    <xsl:template match="glossaryTermRef">
        <xsl:choose>
            <xsl:when test="ancestor::genericRef">
                <xsl:call-template name="OutputGlossaryTerm">
                    <xsl:with-param name="glossaryTerm" select="id(@glossaryTerm)"/>
                    <xsl:with-param name="glossaryTermRef" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <fo:inline>
                    <fo:basic-link>
                        <xsl:attribute name="internal-destination">
                            <xsl:value-of select="@glossaryTerm"/>
                        </xsl:attribute>
                        <xsl:call-template name="AddAnyLinkAttributes">
                            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/glossaryTermRefLinkLayout"/>
                        </xsl:call-template>
                        <xsl:call-template name="OutputGlossaryTerm">
                            <xsl:with-param name="glossaryTerm" select="id(@glossaryTerm)"/>
                            <xsl:with-param name="glossaryTermRef" select="."/>
                        </xsl:call-template>
                    </fo:basic-link>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ===========================================================
        keyTerm
        =========================================================== -->
    <xsl:template match="keyTerm">
        <fo:inline>
            <xsl:call-template name="DoType"/>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
            <xsl:if test="not(@font-style) and not(key('TypeID',@type)/@font-style)">
                <xsl:attribute name="font-style">
                    <xsl:text>italic</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
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
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$language"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
            <!-- insert a new line so we don't get everything all on one line -->
            <!--            <xsl:text>&#xa; no, it inserts and extra space</xsl:text>-->
            <fo:inline>
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
            </fo:inline>
        </fo:inline>
        <xsl:call-template name="HandleLangDataTextAfterOutside">
            <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
            <xsl:with-param name="sLangDataContext" select="$sLangDataContext"/>
        </xsl:call-template>
    </xsl:template>
    <!-- ===========================================================
      OBJECT
      =========================================================== -->
    <xsl:template match="object">
        <fo:inline>
            <xsl:call-template name="DoType"/>
            <xsl:for-each select="key('TypeID',@type)">
                <xsl:value-of select="@before"/>
            </xsl:for-each>
            <xsl:apply-templates/>
            <xsl:for-each select="key('TypeID',@type)">
                <xsl:value-of select="@after"/>
            </xsl:for-each>
        </fo:inline>
    </xsl:template>
    <!-- ===========================================================
      IMG
      =========================================================== -->
    <xsl:template match="img">
        <fo:external-graphic scaling="uniform">
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:attribute name="src">
                <xsl:text>url(</xsl:text>
                <xsl:value-of select="@src"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
        </fo:external-graphic>
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
    <xsl:template match="footnoteIndent"/>
    <xsl:template match="footnotePointSize"/>
    <xsl:template match="hangingIndentInitialIndent"/>
    <xsl:template match="hangingIndentNormalIndent"/>
    <xsl:template match="headerMargin"/>
    <xsl:template match="magnificationFactor"/>
    <xsl:template match="pageBottomMargin"/>
    <xsl:template match="pageHeight"/>
    <xsl:template match="pageInsideMargin"/>
    <xsl:template match="pageOutsideMargin"/>
    <xsl:template match="pageTopMargin"/>
    <xsl:template match="pageWidth"/>
    <xsl:template match="paragraphIndent"/>
    <xsl:template match="publisherStyleSheetName"/>
    <xsl:template match="publisherStyleSheetPublisher"/>
    <xsl:template match="publisherStyleSheetReferencesName"/>
    <xsl:template match="publisherStyleSheetReferencesVersion"/>
    <xsl:template match="publisherStyleSheetVersion"/>
    <xsl:template match="referencedInterlinearTexts"/>
    <xsl:template match="abstract/shortTitle"/>
    <xsl:template match="acknowledgements/shortTitle"/>
    <xsl:template match="contents/shortTitle"/>
    <xsl:template match="glossary/shortTitle"/>
    <xsl:template match="index/shortTitle"/>
    <xsl:template match="keywordsShownHere/shortTitle"/>
    <xsl:template match="preface/shortTitle"/>
    <xsl:template match="selectedBibliography/shortTitle"/>
    <!--    <xsl:template match="shortTitle"/>-->
    <!-- ===========================================================
      NAMED TEMPLATES
      =========================================================== -->
    <!--
                  AddAnyLinkAttributes
                                    -->
    <xsl:template name="AddAnyLinkAttributes">
        <xsl:param name="override"/>
        <xsl:if test="$override/@showmarking='yes'">
            <xsl:variable name="sOverrideColor" select="$override/@color"/>
            <xsl:variable name="sOverrideDecoration" select="$override/@decoration"/>
            <xsl:choose>
                <xsl:when test="$sOverrideColor != 'default'">
                    <xsl:attribute name="color">
                        <xsl:value-of select="$sOverrideColor"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="string-length($sLinkColor) &gt; 0">
                        <xsl:attribute name="color">
                            <xsl:value-of select="$sLinkColor"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$sOverrideDecoration != 'default'">
                    <xsl:attribute name="text-decoration">
                        <xsl:value-of select="$sOverrideDecoration"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$sLinkTextDecoration != 'none'">
                        <xsl:attribute name="text-decoration">
                            <xsl:value-of select="$sLinkTextDecoration"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--
        AddWordSpace
    -->
    <xsl:template name="AddWordSpace"/>
    <!--  
        AdjustFontSizePerMagnification (also in XLingPapPublisherStylesheetXHTMLCSS.xsl)
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
                  CheckSeeTargetIsCitedOrItsDescendantIsCited
                                    -->
    <xsl:template name="CheckSeeTargetIsCitedOrItsDescendantIsCited">
        <xsl:variable name="sSee" select="@see"/>
        <xsl:choose>
            <xsl:when test="//indexedItem[@term=$sSee][not(ancestor::comment)] | //indexedRangeBegin[@term=$sSee][not(ancestor::comment)]">
                <xsl:text>Y</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="key('IndexTermID',@see)/descendant::indexTerm">
                    <xsl:variable name="sDescendantTermId" select="@id"/>
                    <xsl:if test="//indexedItem[@term=$sDescendantTermId][not(ancestor::comment)] or //indexedRangeBegin[@term=$sDescendantTermId][not(ancestor::comment)]">
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
        DoAppendiciesTitlePage
    -->
    <xsl:template name="DoAppendiciesTitlePage">
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id" select="$sAppendiciesPageID"/>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputAppendiciesLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendicesTitlePageLayout"/>
            <xsl:with-param name="sRunningHeader">
                <xsl:call-template name="OutputAppendiciesLabel"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <!--  
        DoAuthorOfChapterInCollectionInContents
    -->
    <xsl:template name="DoAuthorOfChapterInCollectionInContents">
        <xsl:if test="saxon:node-set($authorInContentsLayoutInfo)/authorLayout">
            <xsl:if test="frontMatter/author">
                <fo:block text-align-last="justify" text-indent="-2em" start-indent="3em">
                    <fo:inline font-style="italic">
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="saxon:node-set($authorInContentsLayoutInfo)/authorLayout"/>
                        </xsl:call-template>
                        <xsl:value-of select="saxon:node-set($authorInContentsLayoutInfo)/authorLayout/@textbefore"/>
                        <xsl:call-template name="GetAuthorsAsCommaSeparatedList"/>
                        <xsl:value-of select="saxon:node-set($authorInContentsLayoutInfo)/authorLayout/@textafter"/>
                        <xsl:text>&#xa0;</xsl:text>
                        <fo:leader leader-pattern="use-content">
                            <xsl:text>&#xa0;</xsl:text>
                        </fo:leader>
                    </fo:inline>
                </fo:block>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
      DoBackMatterBookmarksPerLayout
   -->
    <xsl:template name="DoBackMatterBookmarksPerLayout">
        <xsl:param name="nLevel"/>
        <xsl:param name="backMatter" select="$lingPaper/backMatter"/>
        <xsl:param name="backMatterLayout" select="$backMatterLayoutInfo"/>
        <xsl:for-each select="$backMatterLayout/*">
            <xsl:choose>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:apply-templates select="$backMatter/acknowledgements" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='appendicesTitlePageLayout'">
                    <xsl:if test="count(//appendix)&gt;1">
                        <xsl:call-template name="OutputBookmark">
                            <xsl:with-param name="sLink" select="$sAppendiciesPageID"/>
                            <xsl:with-param name="sLabel">
                                <xsl:call-template name="OutputAppendiciesLabel"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="name(.)='appendixLayout'">
                    <xsl:apply-templates select="$backMatter/appendix" mode="bookmarks">
                        <xsl:with-param name="nLevel" select="$nLevel"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='glossaryLayout'">
                    <xsl:apply-templates select="$backMatter/glossary" mode="bookmarks">
                        <xsl:with-param name="iLayoutPosition">
                            <xsl:choose>
                                <xsl:when test="preceding-sibling::glossaryLayout or following-sibling::glossaryLayout">
                                    <xsl:value-of select="count(preceding-sibling::glossaryLayout) + 1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>0</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='indexLayout'">
                    <xsl:apply-templates select="$backMatter/index" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='keywordsLayout'">
                    <xsl:apply-templates select="$backMatter/keywordsShownHere[@showincontents='yes']" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='referencesLayout'">
                    <xsl:apply-templates select="$backMatter/references" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='referencesTitleLayout' and $backMatter/ancestor::chapterInCollection">
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
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="backMatter" select="$lingPaper/backMatter"/>
        <xsl:param name="backMatterLayout" select="$backMatterLayoutInfo"/>
        <xsl:param name="contentsLayoutToUse" select="."/>
        <xsl:for-each select="$backMatterLayout/*">
            <xsl:choose>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:apply-templates select="$backMatter/acknowledgements" mode="contents">
                        <xsl:with-param name="text-transform" select="@text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='appendicesTitlePageLayout'">
                    <xsl:if test="count(//appendix)&gt;1">
                        <xsl:call-template name="OutputTOCLine">
                            <xsl:with-param name="sLink" select="$sAppendiciesPageID"/>
                            <xsl:with-param name="sLabel">
                                <xsl:call-template name="OutputAppendiciesLabel"/>
                            </xsl:with-param>
                            <xsl:with-param name="text-transform" select="@text-transform"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="name(.)='appendixLayout'">
                    <xsl:apply-templates select="$backMatter/appendix" mode="contents">
                        <xsl:with-param name="nLevel" select="$nLevel"/>
                        <xsl:with-param name="text-transform" select="appendixTitleLayout/@text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='glossaryLayout'">
                    <xsl:apply-templates select="$backMatter/glossary" mode="contents">
                        <xsl:with-param name="iLayoutPosition">
                            <xsl:choose>
                                <xsl:when test="preceding-sibling::glossaryLayout or following-sibling::glossaryLayout">
                                    <xsl:value-of select="count(preceding-sibling::glossaryLayout) + 1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>0</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="text-transform" select="@text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='indexLayout'">
                    <xsl:apply-templates select="$backMatter/index" mode="contents">
                        <xsl:with-param name="text-transform" select="@text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='keywordsLayout'">
                    <xsl:apply-templates select="$backMatter/keywordsShownHere[@showincontents='yes']" mode="contents">
                        <xsl:with-param name="text-transform" select="@text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='referencesTitleLayout' and $backMatter[ancestor::chapterInCollection]">
                    <xsl:apply-templates select="$backMatter/references" mode="contents">
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='referencesLayout' and not($backMatter[ancestor::chapterInCollection])">
                    <xsl:apply-templates select="$backMatter/references" mode="contents">
                        <xsl:with-param name="text-transform" select="../referencesTitleLayout/@text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='contentsLayout'">
                    <xsl:if test="@showcontents='yes' and $frontMatterLayoutInfo/contentsLayout and $backMatterLayout/contentsLayout">
                        <xsl:apply-templates select="$lingPaper/frontMatter/contents" mode="contents">
                            <xsl:with-param name="text-transform" select="@text-transform"/>
                            <xsl:with-param name="contentsLayoutToUse" select="."/>
                        </xsl:apply-templates>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="name(.)='useEndNotesLayout'">
                    <xsl:apply-templates select="$backMatter/endnotes" mode="contents">
                        <xsl:with-param name="text-transform" select="@text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoBackMatterPerLayout
    -->
    <xsl:template name="DoBackMatterPerLayout">
        <xsl:param name="backMatter"/>
        <xsl:param name="backMatterLayout" select="$backMatterLayoutInfo"/>
        <xsl:param name="frontMatter"/>
        <xsl:for-each select="$backMatterLayout/*">
            <xsl:choose>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:choose>
                        <xsl:when test="$bIsBook and not($backMatter/ancestor::chapterInCollection)">
                            <xsl:apply-templates select="$backMatter/acknowledgements" mode="backmatter-book"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$backMatter/acknowledgements" mode="paper">
                                <xsl:with-param name="backMatterLayout" select="$backMatterLayout"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="name(.)='appendicesTitlePageLayout'">
                    <xsl:if test="count(//appendix)&gt;1">
                        <xsl:choose>
                            <xsl:when test="$bIsBook">
                                <!-- insert a new line so we don't get everything all on one line -->
                                <xsl:text>&#xa;</xsl:text>
                                <fo:page-sequence master-reference="Chapter">
                                    <xsl:attribute name="initial-page-number">
                                        <xsl:choose>
                                            <xsl:when test="name()='appendix' and $backMatterLayoutInfo/appendixLayout/*[1]/@startonoddpage='yes'">
                                                <xsl:text>auto-odd</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="name()!='appendix' and $bodyLayoutInfo/chapterLayout/*[1]/@startonoddpage='yes'">
                                                <xsl:text>auto-odd</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>auto</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:if test="$backMatterLayoutInfo/appendicesTitlePageLayout/@useemptyheaderfooter!='yes'">
                                        <xsl:call-template name="OutputChapterStaticContentForBackMatter"/>
                                    </xsl:if>
                                    <fo:flow flow-name="xsl-region-body">
                                        <xsl:attribute name="font-family">
                                            <xsl:value-of select="$sDefaultFontFamily"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="font-size">
                                            <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                                        <xsl:call-template name="DoPageBreakFormatInfo">
                                            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/appendicesTitlePageLayout"/>
                                        </xsl:call-template>
                                        <xsl:call-template name="DoAppendiciesTitlePage"/>
                                    </fo:flow>
                                </fo:page-sequence>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="DoAppendiciesTitlePage"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="name(.)='appendixLayout'">
                    <xsl:apply-templates select="$backMatter/appendix">
                        <xsl:with-param name="appLayout" select="$backMatterLayout/appendixLayout/appendixTitleLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='glossaryLayout'">
                    <xsl:apply-templates select="$backMatter/glossary">
                        <xsl:with-param name="backMatterLayout" select="$backMatterLayout"/>
                        <xsl:with-param name="iLayoutPosition">
                            <xsl:choose>
                                <xsl:when test="preceding-sibling::glossaryLayout or following-sibling::glossaryLayout">
                                    <xsl:value-of select="count(preceding-sibling::glossaryLayout) + 1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>0</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='contentsLayout' and $backMatter[ancestor::chapterInCollection]">
                    <xsl:apply-templates select="$frontMatter/contents" mode="paper">
                        <xsl:with-param name="frontMatterLayout" select="$backMatterLayout"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$backMatterLayout/contentsLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='contentsLayout' and not($bIsBook)">
                    <xsl:apply-templates select="$lingPaper/frontMatter/contents" mode="paper">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$backMatterLayoutInfo/contentsLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='contentsLayout' and $bIsBook">
                    <xsl:apply-templates select="$lingPaper/frontMatter/contents" mode="book">
                        <xsl:with-param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$backMatterLayoutInfo/contentsLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='indexLayout'">
                    <xsl:apply-templates select="$backMatter/index"/>
                </xsl:when>
                <xsl:when test="name(.)='keywordsLayout'">
                    <xsl:apply-templates select="$backMatter/keywordsShownHere">
                        <xsl:with-param name="frontMatterLayout" select="$backMatterLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='referencesLayout'">
                    <xsl:apply-templates select="$backMatter/references">
                        <xsl:with-param name="backMatterLayout" select="$backMatterLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='referencesTitleLayout' and $backMatter[ancestor::chapterInCollection]">
                    <xsl:apply-templates select="$backMatter/references">
                        <xsl:with-param name="backMatterLayout" select="$backMatterLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='authorContactInfoLayout'">
                    <fo:block keep-together.within-page="1">
                        <xsl:variable name="firstLayoutItem" select="*[position()=1]"/>
                        <xsl:variable name="sSpaceBefore" select="normalize-space($firstLayoutItem/@spacebefore)"/>
                        <xsl:if test="string-length($sSpaceBefore) &gt; 0">
                            <xsl:attribute name="space-before">
                                <xsl:value-of select="$sSpaceBefore"/>
                            </xsl:attribute>
                        </xsl:if>
                        <fo:table>
                            <fo:table-column/>
                            <fo:table-body>
                                <fo:table-row>
                                    <xsl:apply-templates select="$backMatter/authorContactInfo">
                                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/authorContactInfoLayout"/>
                                    </xsl:apply-templates>
                                </fo:table-row>
                            </fo:table-body>
                        </fo:table>
                    </fo:block>
                </xsl:when>
                <xsl:when test="name(.)='useEndNotesLayout'">
                    <xsl:apply-templates select="$backMatter/endnotes">
                        <xsl:with-param name="backMatterLayout" select="$backMatterLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--
                  DoCellAttributes
                  -->
    <xsl:template name="DoCellAttributes">
        <xsl:if test="@align">
            <xsl:attribute name="text-align">
                <xsl:choose>
                    <xsl:when test="@align='left'">start</xsl:when>
                    <xsl:when test="@align='right'">end</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@align"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(@colspan)) &gt; 0">
            <xsl:attribute name="number-columns-spanned">
                <xsl:value-of select="@colspan"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(@rowspan)) &gt; 0">
            <xsl:attribute name="number-rows-spanned">
                <xsl:value-of select="@rowspan"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@valign">
            <xsl:attribute name="display-align">
                <xsl:choose>
                    <xsl:when test="@valign='top'">before</xsl:when>
                    <xsl:when test="@valign='middle'">center</xsl:when>
                    <xsl:when test="@valign='bottom'">after</xsl:when>
                    <!-- I'm not sure what we should do with this one... -->
                    <xsl:when test="@valign='baseline'">center</xsl:when>
                    <xsl:otherwise>auto</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="ancestor::table[1][@border!='0']">
            <xsl:if test="name()='td' or name()='th'">
                <xsl:attribute name="border">solid 1pt black</xsl:attribute>
            </xsl:if>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(@width)) &gt; 0">
            <xsl:attribute name="width">
                <xsl:value-of select="@width"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!--
        DoChapterLabelInContents
    -->
    <xsl:template name="DoChapterLabelInContents">
        <xsl:param name="contentsLayoutToUse" select="$frontMatterLayoutInfo/contentsLayout"/>
        <xsl:variable name="sLabel" select="normalize-space($contentsLayoutToUse/@chapterlabel)"/>
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $contentsLayoutToUse/@singlespaceeachcontentline='yes'">
            <fo:block>
                <xsl:attribute name="line-height">
                    <xsl:choose>
                        <xsl:when test="$sLineSpacing='double'">
                            <xsl:text>.6</xsl:text>
                        </xsl:when>
                        <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                            <xsl:text>.45</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:text>&#xa0;</xsl:text>
            </fo:block>
        </xsl:if>
        <fo:block>
            <xsl:choose>
                <xsl:when test="string-length($sLabel)&gt;0">
                    <xsl:value-of select="$sLabel"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Chapter</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $contentsLayoutToUse/@singlespaceeachcontentline='yes'">
            <fo:block>
                <xsl:attribute name="line-height">
                    <xsl:choose>
                        <xsl:when test="$sLineSpacing='double'">
                            <xsl:text>-.6</xsl:text>
                        </xsl:when>
                        <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                            <xsl:text>-.45</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:text>&#xa0;</xsl:text>
            </fo:block>
        </xsl:if>
    </xsl:template>
    <!-- 
        DoChapterNumberWidth
    -->
    <xsl:template name="DoChapterNumberWidth"/>
    <!--
        DoContactInfo
    -->
    <xsl:template name="DoContactInfo">
        <xsl:param name="currentLayoutInfo"/>
        <fo:table-row>
            <fo:table-cell xsl:use-attribute-sets="ExampleCell">
                <fo:block>
                    <xsl:variable name="sSpaceBefore" select="normalize-space($currentLayoutInfo/@spacebefore)"/>
                    <xsl:if test="string-length($sSpaceBefore) &gt; 0">
                        <xsl:attribute name="space-before">
                            <xsl:value-of select="$sSpaceBefore"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:variable name="sSpaceAfter" select="normalize-space($currentLayoutInfo/@spaceafter)"/>
                    <xsl:if test="string-length($sSpaceAfter) &gt; 0">
                        <xsl:attribute name="space-after">
                            <xsl:value-of select="$sSpaceAfter"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="$currentLayoutInfo"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="."/>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    <!--
                  DoContents
                  -->
    <xsl:template name="DoContents">
        <xsl:param name="bIsBook" select="'Y'"/>
        <xsl:param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <xsl:param name="contentsLayoutToUse" select="$contentsLayout"/>
        <fo:block>
            <xsl:attribute name="id">
                <xsl:call-template name="CreateContentsID">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:if test="$bIsBook='Y'">
                <xsl:attribute name="span">all</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$contentsLayoutToUse"/>
                <xsl:with-param name="bCheckPageBreakFormatInfo">
                    <xsl:choose>
                        <xsl:when test="$bIsBook='N'">
                            <xsl:text>Y</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>N</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="$bIsBook='Y'">
                    <xsl:call-template name="OutputChapTitle">
                        <xsl:with-param name="sTitle">
                            <xsl:call-template name="OutputContentsLabel">
                                <xsl:with-param name="layoutInfo" select="$contentsLayoutToUse"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="OutputContentsLabel">
                        <xsl:with-param name="layoutInfo" select="$contentsLayoutToUse"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$contentsLayoutToUse"/>
            </xsl:call-template>
        </fo:block>
        <fo:block>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacecontents='yes'">
                <xsl:attribute name="line-height">
                    <xsl:value-of select="$sSinglespacingLineHeight"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="DoFrontMatterContentsPerLayout">
                <xsl:with-param name="frontMatter" select=".."/>
                <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:call-template>
            <xsl:variable name="nLevelToUse">
                <xsl:choose>
                    <xsl:when test="$contentsLayoutToUse[ancestor-or-self::backMatterLayout]">
                        <xsl:value-of select="$nBackMatterLevel"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$nLevel"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="chapterInCollection" select="ancestor::chapterInCollection"/>
            <xsl:choose>
                <xsl:when test="$chapterInCollection">
                    <xsl:apply-templates select="$chapterInCollection/section1" mode="contents">
                        <xsl:with-param name="nLevel" select="$nLevelToUse"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="DoBackMatterContentsPerLayout">
                        <xsl:with-param name="nLevel" select="$nLevelToUse"/>
                        <xsl:with-param name="backMatter" select="$chapterInCollection/backMatter"/>
                        <xsl:with-param name="backMatterLayout" select="$bodyLayoutInfo/chapterInCollectionBackMatterLayout"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- part -->
                    <xsl:apply-templates select="$lingPaper/part" mode="contents">
                        <xsl:with-param name="nLevel" select="$nLevelToUse"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                    <!--                 chapter, no parts -->
                    <xsl:apply-templates select="$lingPaper/chapter[not($parts)] | $lingPaper//chapterInCollection[not($parts)]" mode="contents">
                        <xsl:with-param name="nLevel" select="$nLevelToUse"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                    <!-- section, no chapters -->
                    <xsl:apply-templates select="//lingPaper/section1" mode="contents">
                        <xsl:with-param name="nLevel" select="$nLevelToUse"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="DoBackMatterContentsPerLayout">
                        <xsl:with-param name="nLevel" select="$nLevelToUse"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
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
        <fo:basic-link internal-destination="{@note}">
            <xsl:call-template name="AddAnyLinkAttributes">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/endnoteRefLinkLayout"/>
            </xsl:call-template>
            <xsl:for-each select="key('EndnoteID',@note)">
                <xsl:call-template name="GetFootnoteNumber">
                    <xsl:with-param name="iAdjust" select="0"/>
                </xsl:call-template>
            </xsl:for-each>
        </fo:basic-link>
    </xsl:template>
    <!--  
      DoEndnotes
   -->
    <xsl:template name="DoEndnotes">
        <xsl:if test="contains($endnotesToShow,'X')">
            <xsl:call-template name="OutputBackMatterItemTitle">
                <xsl:with-param name="sId" select="$sEndnotesID"/>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputEndnotesLabel"/>
                </xsl:with-param>
                <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/useEndNotesLayout"/>
                <xsl:with-param name="sRunningHeader">
                    <xsl:call-template name="OutputEndnotesLabel">
                        <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="//endnote[not(ancestor::referencedInterlinearText)] | //endnoteRef[not(ancestor::endnote)][not(@showNumberOnly='yes')] | //interlinearRef" mode="backMatter"/>
            <!--        <xsl:for-each select="//endnote">
            <xsl:call-template name="DoFootnoteContent"/>
        </xsl:for-each>
-->
        </xsl:if>
    </xsl:template>
    <!--  
        DoFigure
    -->
    <xsl:template name="DoFigure">
        <fo:block text-align="{@align}" id="{@id}" space-before="{$sBasicPointSize}pt">
            <xsl:attribute name="space-after">
                <xsl:value-of select="$sBasicPointSize"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="DoType"/>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:if test="$contentLayoutInfo/figureLayout/@captionLocation='before' or not($contentLayoutInfo/figureLayout) and $lingPaper/@figureLabelAndCaptionLocation='before'">
                <fo:block>
                    <xsl:attribute name="space-after">
                        <xsl:choose>
                            <xsl:when test="string-length($sSpaceBetweenFigureAndCaption) &gt; 0">
                                <xsl:value-of select="$sSpaceBetweenFigureAndCaption"/>
                            </xsl:when>
                            <xsl:otherwise>0pt</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="keep-with-next.within-page">10</xsl:attribute>
                    <xsl:call-template name="OutputFigureLabelAndCaption"/>
                </fo:block>
            </xsl:if>
            <xsl:apply-templates select="*[name()!='caption' and name()!='shortCaption']"/>
            <xsl:if test="$contentLayoutInfo/figureLayout/@captionLocation='after' or not($contentLayoutInfo/figureLayout) and $lingPaper/@figureLabelAndCaptionLocation='after'">
                <fo:block>
                    <xsl:attribute name="padding-before">
                        <xsl:choose>
                            <xsl:when test="string-length($sSpaceBetweenFigureAndCaption) &gt; 0">
                                <xsl:value-of select="$sSpaceBetweenFigureAndCaption"/>
                            </xsl:when>
                            <xsl:otherwise>0pt</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="keep-with-previous.within-page">10</xsl:attribute>
                    <xsl:call-template name="OutputFigureLabelAndCaption"/>
                </fo:block>
            </xsl:if>
        </fo:block>
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
        <xsl:param name="originalContext"/>
        <xsl:param name="iTablenumberedAdjust" select="0"/>
        <fo:block xsl:use-attribute-sets="FootnoteBody">
            <xsl:if test="$backMatterLayoutInfo/useEndNotesLayout">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single'">
                <xsl:attribute name="line-height">
                    <xsl:choose>
                        <xsl:when test="$lineSpacing/@singlespaceendnotes='yes'">
                            <xsl:value-of select="$sSinglespacingLineHeight"/>
                        </xsl:when>
                        <xsl:when test="$sLineSpacing='double'">
                            <xsl:text>2.4</xsl:text>
                        </xsl:when>
                        <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                            <xsl:text>1.8</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <!-- HACK for XEP which does not yet do small-caps: -->
            <xsl:attribute name="text-transform">none</xsl:attribute>
            <!--            <xsl:attribute name="font-size">
                <xsl:value-of select="$sFootnotePointSize"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
-->
            <xsl:apply-templates select="*[1]" mode="endnote-content">
                <xsl:with-param name="originalContext" select="$originalContext"/>
                <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="*[position() &gt; 1]"/>
        </fo:block>
    </xsl:template>
    <!--  
      DoFootnoteNumberInText
   -->
    <xsl:template name="DoFootnoteNumberInText">
        <xsl:param name="originalContext"/>
        <xsl:param name="iTablenumberedAdjust" select="0"/>
        <xsl:param name="link" select="@id"/>
        <xsl:choose>
            <xsl:when test="$backMatterLayoutInfo/useEndNotesLayout">
                <fo:basic-link>
                    <xsl:attribute name="internal-destination">
                        <xsl:value-of select="$link"/>
                    </xsl:attribute>
                    <xsl:call-template name="AddAnyLinkAttributes">
                        <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/endnoteRefLinkLayout"/>
                    </xsl:call-template>
                    <fo:inline baseline-shift="super" xsl:use-attribute-sets="FootnoteMarker">
                        <xsl:call-template name="InsertCommaBetweenConsecutiveEndnotes"/>
                        <xsl:call-template name="DoFootnoteNumberInTextValue">
                            <xsl:with-param name="originalContext" select="$originalContext"/>
                            <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
                        </xsl:call-template>
                    </fo:inline>
                </fo:basic-link>
            </xsl:when>
            <xsl:otherwise>
                <fo:inline baseline-shift="super" xsl:use-attribute-sets="FootnoteMarker">
                    <xsl:attribute name="id">
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                    <xsl:call-template name="InsertCommaBetweenConsecutiveEndnotes"/>
                    <xsl:call-template name="DoFootnoteNumberInTextValue">
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                        <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
                    </xsl:call-template>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      DoFootnoteNumberInTextValue
   -->
    <xsl:template name="DoFootnoteNumberInTextValue">
        <xsl:param name="originalContext"/>
        <xsl:param name="iTablenumberedAdjust" select="0"/>
        <xsl:call-template name="GetFootnoteNumber">
            <xsl:with-param name="originalContext" select="$originalContext"/>
            <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
      DoFootnoteSeparatorStaticContent
   -->
    <xsl:template name="DoFootnoteSeparatorStaticContent">
        <xsl:variable name="layoutInfo" select="$pageLayoutInfo/footnoteLine"/>
        <xsl:if test="$layoutInfo">
            <fo:static-content flow-name="xsl-footnote-separator">
                <fo:block>
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
                                <xsl:attribute name="leader-pattern-width">
                                    <xsl:value-of select="$layoutInfo/@leaderwidth"/>
                                </xsl:attribute>
                            </xsl:if>
                        </fo:leader>
                    </xsl:if>
                </fo:block>
            </fo:static-content>
        </xsl:if>
    </xsl:template>
    <!--  
        DoFormatLayoutInfoTextBefore
    -->
    <xsl:template name="DoFormatLayoutInfoTextBefore">
        <xsl:param name="layoutInfo"/>
        <xsl:if test="string-length($layoutInfo/@textbefore) &gt; 0">
            <xsl:value-of select="$layoutInfo/@textbefore"/>
        </xsl:if>
    </xsl:template>
    <!--  
        DoFrontMatterLayoutInfo
    -->
    <xsl:template name="DoFrontMatterFormatInfo">
        <xsl:param name="layoutInfo"/>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="$layoutInfo"/>
        </xsl:call-template>
        <xsl:call-template name="DoSpaceBeforeAfter">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
        <xsl:if test="string-length($layoutInfo/@textalign) &gt; 0">
            <xsl:attribute name="text-align">
                <xsl:value-of select="$layoutInfo/@textalign"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
      DoFrontMatterBookmarksPerLayout
   -->
    <xsl:template name="DoFrontMatterBookmarksPerLayout">
        <xsl:param name="frontMatter" select=".."/>
        <xsl:param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <xsl:for-each select="$frontMatterLayout/*">
            <xsl:choose>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:apply-templates select="$frontMatter/acknowledgements" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='abstractLayout'">
                    <xsl:apply-templates select="$frontMatter/abstract" mode="bookmarks">
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
                <xsl:when test="name(.)='contentsLayout'">
                    <xsl:apply-templates select="$frontMatter/contents" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='keywordsLayout'">
                    <xsl:apply-templates select="$frontMatter/keywordsShownHere" mode="bookmarks"/>
                </xsl:when>
                <xsl:when test="name(.)='prefaceLayout'">
                    <xsl:apply-templates select="$frontMatter/preface" mode="bookmarks">
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
        DoFrontMatterContentsPerLayout
    -->
    <xsl:template name="DoFrontMatterContentsPerLayout">
        <xsl:param name="frontMatter" select=".."/>
        <xsl:param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <xsl:param name="contentsLayoutToUse" select="$frontMatterLayoutInfo/contentsLayout"/>
        <xsl:for-each select="$frontMatterLayout/*">
            <xsl:choose>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:apply-templates select="$frontMatter/acknowledgements" mode="contents">
                        <xsl:with-param name="text-transform" select="@text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='abstractLayout'">
                    <xsl:apply-templates select="$frontMatter/abstract" mode="contents">
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
                        <xsl:with-param name="text-transform" select="@text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='keywordsLayout'">
                    <xsl:apply-templates select="$frontMatter/keywordsShownHere[@showincontents='yes']" mode="contents">
                        <xsl:with-param name="text-transform" select="@text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='prefaceLayout'">
                    <xsl:apply-templates select="$frontMatter/preface" mode="contents">
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
                        <xsl:with-param name="text-transform" select="@text-transform"/>
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="name(.)='contentsLayout'">
                    <xsl:if test="@showcontents='yes'">
                        <xsl:apply-templates select="$lingPaper/frontMatter/contents" mode="contents">
                            <xsl:with-param name="text-transform" select="@text-transform"/>
                            <xsl:with-param name="contentsLayoutToUse" select="."/>
                        </xsl:apply-templates>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoBookEndnotesLabeling
    -->
    <xsl:template name="DoBookEndnotesLabeling">
        <xsl:param name="originalContext"/>
        <xsl:param name="chapterOrAppendixUnit"/>
        <xsl:variable name="sFootnoteNumber">
            <xsl:call-template name="GetFootnoteNumber">
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$sFootnoteNumber='1' and not(ancestor::chapterInCollection[descendant::title[descendant::endnote] or descendant::author[descendant::endnote]]) or $sFootnoteNumber='*'">
            <fo:block font-style="italic" font-size="larger" font-weight="bold" keep-with-next.within-page="1" space-before="{$sBasicPointSize}pt">
                <xsl:call-template name="DoBookEndnotesLabelingContent">
                    <xsl:with-param name="chapterOrAppendixUnit" select="$chapterOrAppendixUnit"/>
                </xsl:call-template>
                <xsl:text>&#x20;</xsl:text>
                <xsl:for-each select="$chapterOrAppendixUnit">
                    <xsl:call-template name="OutputChapterNumber"/>
                </xsl:for-each>
            </fo:block>
        </xsl:if>
    </xsl:template>
    <!--  
        DoBookFrontMatterFirstStuffPerLayout
    -->
    <xsl:template name="DoBookFrontMatterFirstStuffPerLayout">
        <xsl:param name="frontMatter"/>
        <xsl:call-template name="HandleBasicFrontMatterPerLayout">
            <xsl:with-param name="frontMatter" select="$frontMatter"/>
        </xsl:call-template>
        <!--        <xsl:for-each select="$frontMatterLayoutInfo/*">
            <xsl:choose>
                <xsl:when test="name(.)='titleLayout'">
                    <xsl:apply-templates select="$frontMatter/title"/>
                </xsl:when>
                <xsl:when test="name(.)='subtitleLayout'">
                    <xsl:apply-templates select="$frontMatter/subtitle"/>
                </xsl:when>
                <xsl:when test="name(.)='authorLayout'">
                    <xsl:apply-templates select="$frontMatter/author"/>
                </xsl:when>
                <xsl:when test="name(.)='affiliationLayout'">
                    <xsl:apply-templates select="$frontMatter/affiliation"/>
                </xsl:when>
                <xsl:when test="name(.)='emailAddressLayout'">
                    <xsl:apply-templates select="$frontMatter/emailAddress"/>
                </xsl:when>
                <xsl:when test="name(.)='presentedAtLayout'">
                    <xsl:apply-templates select="$frontMatter/presentedAt"/>
                </xsl:when>
                <xsl:when test="name(.)='dateLayout'">
                    <xsl:apply-templates select="$frontMatter/date"/>
                </xsl:when>
                <xsl:when test="name(.)='versionLayout'">
                    <xsl:apply-templates select="$frontMatter/version"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
-->
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
                    <xsl:apply-templates select="$frontMatter/preface" mode="book">
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
      DoBackMatterItemNewPage
   -->
    <xsl:template name="DoBackMatterItemNewPage">
        <xsl:param name="id"/>
        <xsl:param name="sTitle"/>
        <xsl:param name="sHeaderTitleClassName"/>
        <xsl:param name="layoutInfo"/>
        <xsl:param name="sMarkerClassName"/>
        <xsl:param name="sRunningHeader"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:page-sequence master-reference="Chapter">
            <xsl:call-template name="DoInitialPageNumberAttribute">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            </xsl:call-template>
            <xsl:call-template name="OutputChapterStaticContentForBackMatter"/>
            <fo:flow flow-name="xsl-region-body">
                <xsl:attribute name="font-family">
                    <xsl:value-of select="$sDefaultFontFamily"/>
                </xsl:attribute>
                <xsl:attribute name="font-size">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id" select="$id"/>
                    <xsl:with-param name="sTitle" select="$sTitle"/>
                    <xsl:with-param name="bIsBook" select="'Y'"/>
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    <xsl:with-param name="sMarkerClassName" select="$sMarkerClassName"/>
                    <xsl:with-param name="sRunningHeader" select="$sRunningHeader"/>
                </xsl:call-template>
                <xsl:apply-templates/>
                <xsl:call-template name="HandleKeywordsLayoutWithoutPageBreak">
                    <xsl:with-param name="keywordsLayout" select="$layoutInfo/following-sibling::*[1]"/>
                    <xsl:with-param name="backMatterLayout" select="$layoutInfo/.."/>
                </xsl:call-template>
            </fo:flow>
        </fo:page-sequence>
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
        <xsl:param name="sRunningHeader"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:page-sequence master-reference="FrontMatterTOC" format="i">
            <xsl:call-template name="DoInitialPageNumberAttribute">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            </xsl:call-template>
            <xsl:variable name="pageLayoutInfo" select="$frontMatterLayoutInfo/headerFooterPageStyles"/>
            <!-- $sHeaderTitleClassName -->
            <xsl:call-template name="DoHeaderAndFooter">
                <xsl:with-param name="layoutInfo" select="$pageLayoutInfo/headerFooterFirstPage"/>
                <xsl:with-param name="layoutInfoParentWithFontInfo" select="$pageLayoutInfo"/>
                <xsl:with-param name="sFlowName" select="'FrontMatterTOCFirstPage'"/>
                <xsl:with-param name="sRetrieveClassName" select="$sHeaderTitleClassName"/>
            </xsl:call-template>
            <xsl:call-template name="DoHeaderAndFooter">
                <xsl:with-param name="layoutInfo" select="$pageLayoutInfo/headerFooterPage"/>
                <xsl:with-param name="layoutInfoParentWithFontInfo" select="$pageLayoutInfo"/>
                <xsl:with-param name="sFlowName" select="'FrontMatterTOCRegularPage'"/>
                <xsl:with-param name="sRetrieveClassName" select="$sHeaderTitleClassName"/>
            </xsl:call-template>
            <xsl:call-template name="DoHeaderAndFooter">
                <xsl:with-param name="layoutInfo" select="$pageLayoutInfo/headerFooterOddEvenPages/headerFooterEvenPage"/>
                <xsl:with-param name="layoutInfoParentWithFontInfo" select="$pageLayoutInfo"/>
                <xsl:with-param name="sFlowName" select="'FrontMatterTOCEvenPage'"/>
                <xsl:with-param name="sRetrieveClassName" select="$sHeaderTitleClassName"/>
            </xsl:call-template>
            <xsl:call-template name="DoHeaderAndFooter">
                <xsl:with-param name="layoutInfo" select="$pageLayoutInfo/headerFooterOddEvenPages/headerFooterOddPage"/>
                <xsl:with-param name="layoutInfoParentWithFontInfo" select="$pageLayoutInfo"/>
                <xsl:with-param name="sFlowName" select="'FrontMatterTOCOddPage'"/>
                <xsl:with-param name="sRetrieveClassName" select="$sHeaderTitleClassName"/>
            </xsl:call-template>
            <!--            
            <fo:static-content flow-name="FrontMatterTOCFirstPage-after" display-align="after">
                <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                    <xsl:attribute name="text-align">center</xsl:attribute>
                    <xsl:attribute name="margin-top">6pt</xsl:attribute>
                    <fo:page-number/>
                </xsl:element>
            </fo:static-content>
            <fo:static-content flow-name="FrontMatterTOCEvenPage-before" display-align="before">
                <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                    <xsl:attribute name="text-align-last">justify</xsl:attribute>
                    <fo:inline>
                        <fo:page-number/>
                    </fo:inline>
                    <fo:leader/>
                    <fo:inline>
                        <fo:retrieve-marker>
                            <xsl:attribute name="retrieve-class-name">
                                <xsl:value-of select="$sHeaderTitleClassName"/>
                            </xsl:attribute>
                        </fo:retrieve-marker>
                    </fo:inline>
                </xsl:element>
            </fo:static-content>
            <fo:static-content flow-name="FrontMatterTOCOddPage-before" display-align="before">
                <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                    <xsl:attribute name="text-align-last">justify</xsl:attribute>
                    <fo:inline>
                        <fo:retrieve-marker>
                            <xsl:attribute name="retrieve-class-name">
                                <xsl:value-of select="$sHeaderTitleClassName"/>
                            </xsl:attribute>
                        </fo:retrieve-marker>
                    </fo:inline>
                    <fo:leader/>
                    <fo:inline>
                        <fo:page-number/>
                    </fo:inline>
                </xsl:element>
            </fo:static-content>
-->
            <xsl:call-template name="DoFootnoteSeparatorStaticContent"/>
            <fo:flow flow-name="xsl-region-body">
                <xsl:attribute name="font-family">
                    <xsl:value-of select="$sDefaultFontFamily"/>
                </xsl:attribute>
                <xsl:attribute name="font-size">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id" select="$id"/>
                    <xsl:with-param name="sTitle" select="$sTitle"/>
                    <xsl:with-param name="bIsBook" select="'Y'"/>
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    <xsl:with-param name="sMarkerClassName" select="$sMarkerClassName"/>
                    <xsl:with-param name="sRunningHeader" select="$sRunningHeader"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>
    <!--  
        DoFrontMatterPerLayout
    -->
    <xsl:template name="DoFrontMatterPerLayout">
        <xsl:param name="frontMatter"/>
        <xsl:param name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <xsl:call-template name="HandleBasicFrontMatterPerLayout">
            <xsl:with-param name="frontMatter" select="$frontMatter"/>
            <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
                  DoGlossary
-->
    <xsl:template name="DoGlossary">
        <xsl:param name="iPos" select="'1'"/>
        <xsl:param name="glossaryLayout"/>
        <xsl:call-template name="OutputBackMatterItemTitle">
            <xsl:with-param name="sId">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="concat($sGlossaryID,$iPos)"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputGlossaryLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$glossaryLayout"/>
            <xsl:with-param name="sRunningHeader">
                <xsl:call-template name="OutputGlossaryLabel">
                    <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <!--  
        DoGlossaryPerLayout
    -->
    <xsl:template name="DoGlossaryPerLayout">
        <xsl:param name="glossaryLayout"/>
        <xsl:param name="iPos"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <xsl:choose>
            <xsl:when test="$bIsBook and not(ancestor::chapterInCollection)">
                <!-- insert a new line so we don't get everything all on one line -->
                <xsl:text>&#xa;</xsl:text>
                <fo:page-sequence master-reference="Chapter">
                    <xsl:call-template name="DoInitialPageNumberAttribute">
                        <xsl:with-param name="layoutInfo" select="$glossaryLayout"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputChapterStaticContentForBackMatter"> </xsl:call-template>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:attribute name="font-family">
                            <xsl:value-of select="$sDefaultFontFamily"/>
                        </xsl:attribute>
                        <xsl:attribute name="font-size">
                            <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                        <fo:marker marker-class-name="chap-title">
                            <xsl:call-template name="OutputGlossaryLabel">
                                <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                            </xsl:call-template>
                        </fo:marker>
                        <xsl:call-template name="DoGlossary">
                            <xsl:with-param name="iPos" select="$iPos"/>
                            <xsl:with-param name="glossaryLayout" select="$glossaryLayout"/>
                        </xsl:call-template>
                        <xsl:if test="not(following-sibling::glossary)">
                            <xsl:call-template name="HandleKeywordsLayoutWithoutPageBreak">
                                <xsl:with-param name="keywordsLayout" select="$glossaryLayout/following-sibling::*[1]"/>
                                <xsl:with-param name="backMatterLayout" select="$glossaryLayout/.."/>
                            </xsl:call-template>
                        </xsl:if>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoGlossary">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="glossaryLayout" select="$glossaryLayout"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
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
        <xsl:for-each select="$item/*">
            <xsl:choose>
                <xsl:when test="name()='nothing'">
                    <fo:leader/>
                </xsl:when>
                <xsl:when test="name()='chapterNumber' and following-sibling::chapterTitle or name()='chapterNumber' and preceding-sibling::chapterTitle">
                    <!-- do nothing; handled by the chapterTitle -->
                </xsl:when>
                <xsl:when test="name()='sectionNumber' and following-sibling::sectionTitle or name()='sectionNumber' and preceding-sibling::sectionTitle">
                    <!-- do nothing; handled by the sectionTitle -->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="parent" select="parent::*"/>
                    <xsl:variable name="beforeme" select="$parent/preceding-sibling::*"/>
                    <xsl:if test="$parent[name()!='leftHeaderFooterItem'] and not($parent/preceding-sibling::*[1]/nothing)">
                        <fo:leader/>
                    </xsl:if>
                    <fo:inline>
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="."/>
                        </xsl:call-template>
                        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                            <xsl:with-param name="layoutInfo" select="."/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="name()='chapterInCollectionAuthor'">
                                <fo:retrieve-marker>
                                    <xsl:attribute name="retrieve-class-name">
                                        <xsl:text>chap-in-collection-author</xsl:text>
                                    </xsl:attribute>
                                </fo:retrieve-marker>
                            </xsl:when>
                            <xsl:when test="name()='chapterTitle' or name()='chapterNumber' and not(following-sibling::chapterTitle) and not(preceding-sibling::chapterTitle)">
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
                                        <xsl:apply-templates select="//frontMatter/shortAuthor"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="//author" mode="contentOnly"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="name()='paperPublishingBlurb'">
                                <xsl:apply-templates select="//publishingBlurb"/>
                            </xsl:when>
                            <xsl:when test="name()='paperTitle'">
                                <xsl:choose>
                                    <xsl:when test="string-length(normalize-space(//frontMatter/shortTitle)) &gt; 0">
                                        <xsl:apply-templates select="//frontMatter/shortTitle" mode="InMarker"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!--                              <xsl:apply-templates select="//frontMatter//title/child::node()[name()!='endnote']" mode="contentOnly"/>-->
                                        <xsl:apply-templates select="//frontMatter//title/child::node()[name()!='endnote' and name()!='img' and name()!='br']"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="name()='sectionTitle' or name()='sectionNumber' and not(following-sibling::sectionTitle) and not(preceding-sibling::sectionTitle)">
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
                            <!--  we ignore the 'nothing' case -->
                        </xsl:choose>
                        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                            <xsl:with-param name="layoutInfo" select="."/>
                        </xsl:call-template>
                    </fo:inline>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
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
        <fo:static-content display-align="{$sFlowDisplayAlign}">
            <xsl:attribute name="flow-name">
                <xsl:value-of select="$sFlowName"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$sFlowDisplayAlign"/>
            </xsl:attribute>
            <fo:block text-align-last="{$layoutInfo/@textalign}">
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
            </fo:block>
        </fo:static-content>
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
            <xsl:with-param name="sRunningHeader">
                <xsl:call-template name="OutputIndexLabel">
                    <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                </xsl:call-template>
            </xsl:with-param>
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
        <fo:block>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespaceindexes='yes'">
                <xsl:attribute name="line-height">
                    <xsl:value-of select="$sSinglespacingLineHeight"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputIndexTerms">
                <xsl:with-param name="sIndexKind" select="$sIndexKind"/>
                <xsl:with-param name="lang" select="$indexLang"/>
                <xsl:with-param name="terms" select="//lingPaper/indexTerms"/>
            </xsl:call-template>
        </fo:block>
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
        <fo:block keep-with-previous.within-page="1">
            <xsl:if test="following-sibling::interlinearSource and $sInterlinearSourceStyle='AfterFree' and not(following-sibling::free or following-sibling::literal)">
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
            <xsl:choose>
                <xsl:when test="name()='literal'">
                    <xsl:if
                        test="preceding-sibling::literal[@lang=$sCurrentLanguage][position()=1] or preceding-sibling::*[1][name()='literal'][not(@lang)][position()=1] or name(../..)='interlinear' or name(../..)='listInterlinear' and name(..)='interlinear' and $iParentPosition!=1">
                        <xsl:attribute name="margin-left">
                            <xsl:text>0.1in</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if
                        test="preceding-sibling::free[@lang=$sCurrentLanguage][position()=1]or preceding-sibling::*[1][name()='free'][not(@lang)][position()=1] or name(../..)='interlinear' or name(../..)='listInterlinear' and name(..)='interlinear' and $iParentPosition!=1">
                        <xsl:attribute name="margin-left">
                            <xsl:text>0.1in</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="language" select="key('LanguageID',@lang)"/>
            <xsl:choose>
                <xsl:when test="name()='free'">
                    <xsl:call-template name="DoInterlinearFreeContent">
                        <xsl:with-param name="freeLayout" select="$contentLayoutInfo/freeLayout"/>
                        <xsl:with-param name="language" select="$language"/>
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="DoInterlinearFreeContent">
                        <xsl:with-param name="freeLayout" select="$contentLayoutInfo/literalLayout/literalContentLayout"/>
                        <xsl:with-param name="language" select="$language"/>
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$sInterlinearSourceStyle='AfterFree' and not(following-sibling::free or following-sibling::literal) and $mode!='NoTextRef'">
                <xsl:if test="name(../..)='example'  or name(../..)='listInterlinear' or ancestor::interlinear[@textref]">
                    <xsl:call-template name="OutputInterlinearTextReference">
                        <xsl:with-param name="sRef" select="../@textref"/>
                        <xsl:with-param name="sSource" select="../interlinearSource"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
        </fo:block>
        <xsl:if test="$sInterlinearSourceStyle='UnderFree' and not(following-sibling::free or following-sibling::literal) and $mode!='NoTextRef'">
            <xsl:if test="name(../..)='example' or name(../..)='listInterlinear' or ancestor::interlinear[@textref]">
                <fo:block keep-with-previous.within-page="1">
                    <xsl:call-template name="OutputInterlinearTextReference">
                        <xsl:with-param name="sRef" select="../@textref"/>
                        <xsl:with-param name="sSource" select="../interlinearSource"/>
                    </xsl:call-template>
                </fo:block>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        DoInterlinearFreeContent
    -->
    <xsl:template name="DoInterlinearFreeContent">
        <xsl:param name="freeLayout"/>
        <xsl:param name="language"/>
        <xsl:param name="originalContext"/>
        <xsl:variable name="sSpaceBeforeFree" select="normalize-space($freeLayout/@spacebefore)"/>
        <xsl:if test="string-length($sSpaceBeforeFree) &gt; 0">
            <xsl:attribute name="space-before">
                <xsl:value-of select="$sSpaceBeforeFree"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:variable name="sSpaceAfterFree" select="normalize-space($freeLayout/@spaceafter)"/>
        <xsl:if test="string-length($sSpaceAfterFree) &gt; 0">
            <xsl:attribute name="space-after">
                <xsl:value-of select="$sSpaceAfterFree"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="DoLiteralLabel"/>
        <xsl:call-template name="HandleFreeTextBeforeOutside">
            <xsl:with-param name="freeLayout" select="$freeLayout"/>
        </xsl:call-template>
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$language"/>
            </xsl:call-template>
            <fo:inline>
                <xsl:call-template name="HandleFreeTextBeforeAndFontOverrides">
                    <xsl:with-param name="freeLayout" select="$freeLayout"/>
                </xsl:call-template>
                <xsl:apply-templates>
                    <xsl:with-param name="originalContext" select="$originalContext"/>
                </xsl:apply-templates>
                <xsl:call-template name="HandleFreeTextAfterInside">
                    <xsl:with-param name="freeLayout" select="$freeLayout"/>
                </xsl:call-template>
            </fo:inline>
        </fo:inline>
        <xsl:call-template name="HandleFreeTextAfterOutside">
            <xsl:with-param name="freeLayout" select="$freeLayout"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
      DoInterlinearLine
   -->
    <xsl:template name="DoInterlinearLine">
        <xsl:param name="mode"/>
        <xsl:param name="originalContext"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:table-row>
            <xsl:variable name="bRtl">
                <xsl:choose>
                    <xsl:when test="id(parent::lineGroup/line[1]/wrd/langData[1]/@lang)/@rtl='yes'">Y</xsl:when>
                    <xsl:otherwise>N</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="wrd">
                    <xsl:for-each select="wrd">
                        <!-- insert a new line so we don't get everything all on one line -->
                        <xsl:text>&#xa;</xsl:text>
                        <fo:table-cell xsl:use-attribute-sets="ExampleCell">
                            <xsl:if test="$bRtl='Y'">
                                <xsl:attribute name="text-align">right</xsl:attribute>
                            </xsl:if>
                            <xsl:call-template name="DoDebugExamples"/>
                            <fo:block>
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                                </xsl:call-template>
                                <xsl:apply-templates>
                                    <xsl:with-param name="originalContext" select="$originalContext"/>
                                </xsl:apply-templates>
                            </fo:block>
                        </fo:table-cell>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="bFlip">
                        <xsl:choose>
                            <xsl:when test="id(parent::lineGroup/line[1]/langData[1]/@lang)/@rtl='yes'">Y</xsl:when>
                            <xsl:otherwise>N</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:if test="$bFlip='Y'">
                        <xsl:attribute name="text-align">right</xsl:attribute>
                    </xsl:if>
                    <xsl:variable name="lang">
                        <xsl:if test="langData">
                            <xsl:value-of select="langData/@lang"/>
                        </xsl:if>
                        <xsl:if test="gloss">
                            <xsl:value-of select="gloss/@lang"/>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="sContents">
                        <!--                        <xsl:apply-templates/> just want the text content-->
                        <xsl:value-of select="self::*[not(descendant-or-self::endnote)]"/>
                    </xsl:variable>
                    <xsl:variable name="sOrientedContents">
                        <xsl:choose>
                            <xsl:when test="$bFlip='Y'">
                                <!-- flip order, left to right -->
                                <xsl:call-template name="ReverseContents">
                                    <xsl:with-param name="sList" select="$sContents"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="langData and id(langData/@lang)/@rtl='yes'">
                                <!-- flip order, left to right -->
                                <xsl:call-template name="ReverseContents">
                                    <xsl:with-param name="sList" select="$sContents"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$sContents"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:call-template name="OutputTableCells">
                        <xsl:with-param name="sList" select="$sOrientedContents"/>
                        <xsl:with-param name="lang" select="$lang"/>
                        <xsl:with-param name="sAlign">
                            <xsl:choose>
                                <xsl:when test="$bFlip='Y'">right</xsl:when>
                                <xsl:otherwise>start</xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$mode!='NoTextRef'">
                <xsl:if test="count(preceding-sibling::line) = 0">
                    <xsl:if test="$sInterlinearSourceStyle='AfterFirstLine'">
                        <xsl:if test="string-length(normalize-space(../../@textref)) &gt; 0 or ../../interlinearSource">
                            <fo:table-cell text-align="start" xsl:use-attribute-sets="ExampleCell">
                                <fo:block>
                                    <xsl:call-template name="DoDebugExamples"/>
                                    <xsl:call-template name="OutputInterlinearTextReference">
                                        <xsl:with-param name="sRef" select="../../@textref"/>
                                        <xsl:with-param name="sSource" select="../../interlinearSource"/>
                                    </xsl:call-template>
                                </fo:block>
                            </fo:table-cell>
                        </xsl:if>
                    </xsl:if>
                </xsl:if>
            </xsl:if>
        </fo:table-row>
    </xsl:template>
    <!--  
        DoInterlinearRefCitation
    -->
    <xsl:template name="DoInterlinearRefCitation">
        <xsl:param name="sRef"/>
        <fo:inline>
            <fo:basic-link>
                <xsl:call-template name="DoInterlinearTextReferenceLink">
                    <xsl:with-param name="sAttrName">
                        <xsl:call-template name="DetermineInternalOrExternalDestination">
                            <xsl:with-param name="sRef" select="$sRef"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="sRef" select="$sRef"/>
                </xsl:call-template>
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/interlinearRefLinkLayout"/>
                </xsl:call-template>
                <xsl:variable name="interlinearSourceStyleLayout" select="$contentLayoutInfo/interlinearSourceStyle"/>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$interlinearSourceStyleLayout"/>
                    <xsl:with-param name="originalContext" select="."/>
                </xsl:call-template>
                <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                    <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
                </xsl:call-template>
                <xsl:call-template name="DoInterlinearRefCitationContent">
                    <xsl:with-param name="sRef" select="$sRef"/>
                </xsl:call-template>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
                </xsl:call-template>
            </fo:basic-link>
        </fo:inline>
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
      DoLayoutMasterSet
    -->
    <xsl:template name="DoLayoutMasterSet">
        <fo:layout-master-set>
            <!-- Front matter -->
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                <xsl:attribute name="master-name">FrontMatterPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFrontMatterBody"/>
                </fo:region-body>
                <fo:region-before extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                <xsl:attribute name="master-name">FrontMatterTOCFirstPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFrontMatterBody"/>
                </fo:region-body>
                <fo:region-before extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="FrontMatterTOCFirstPage-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="EvenPageLayout">
                <xsl:attribute name="master-name">FrontMatterTOCEvenPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFrontMatterBody"/>
                </fo:region-body>
                <fo:region-before region-name="FrontMatterTOCEvenPage-before" extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                <xsl:attribute name="master-name">FrontMatterTOCOddPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFrontMatterBody"/>
                </fo:region-body>
                <fo:region-before region-name="FrontMatterTOCOddPage-before" extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="EvenPageLayout">
                <xsl:attribute name="master-name">FrontMatterBlankEvenPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFrontMatterBody"/>
                </fo:region-body>
                <fo:region-before region-name="xsl-region-before" extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- Chapters -->
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                <xsl:attribute name="master-name">ChapterFirstPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                    <xsl:if test="$bDoDebug='y'">
                        <xsl:attribute name="border">
                            <xsl:text>thin solid silver</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </fo:region-body>
                <fo:region-before region-name="ChapterFirstPage-before" extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="ChapterFirstPage-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="EvenPageLayout">
                <xsl:attribute name="master-name">ChapterEvenPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                    <xsl:if test="$bDoDebug='y'">
                        <xsl:attribute name="border-left">
                            <xsl:text>medium gray ridge</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </fo:region-body>
                <fo:region-before region-name="ChapterEvenPage-before" extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="ChapterEvenPage-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                <xsl:attribute name="master-name">ChapterOddPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                    <xsl:if test="$bDoDebug='y'">
                        <xsl:attribute name="border-right">
                            <xsl:text>medium gray ridge</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </fo:region-body>
                <fo:region-before region-name="ChapterOddPage-before" extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="ChapterOddPage-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                <xsl:attribute name="master-name">ChapterRegularPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                    <xsl:if test="$bDoDebug='y'">
                        <xsl:attribute name="border-right">
                            <xsl:text>medium gray ridge</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </fo:region-body>
                <fo:region-before region-name="ChapterRegularPage-before" extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="ChapterRegularPage-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- Indexes -->
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                <xsl:attribute name="master-name">IndexFirstPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}" column-count="2" column-gap="0.25in">
                    <xsl:if test="$bDoDebug='y'">
                        <xsl:attribute name="border">
                            <xsl:text>thin solid silver</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </fo:region-body>
                <fo:region-before region-name="IndexFirstPage-before" extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="IndexFirstPage-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="EvenPageLayout">
                <xsl:attribute name="master-name">IndexEvenPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}" column-count="2" column-gap="0.25in">
                    <xsl:if test="$bDoDebug='y'">
                        <xsl:attribute name="border-left">
                            <xsl:text>medium gray ridge</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </fo:region-body>
                <fo:region-before region-name="IndexEvenPage-before" extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="IndexEvenPage-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                <xsl:attribute name="master-name">IndexOddPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}" column-count="2" column-gap="0.25in">
                    <xsl:if test="$bDoDebug='y'">
                        <xsl:attribute name="border-right">
                            <xsl:text>medium gray ridge</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </fo:region-body>
                <fo:region-before region-name="IndexOddPage-before" extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="IndexOddPage-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <xsl:element name="fo:simple-page-master" use-attribute-sets="EvenPageLayout">
                <xsl:attribute name="master-name">BlankEvenPage</xsl:attribute>
                <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                    <xsl:if test="$bDoDebug='y'">
                        <xsl:attribute name="border">
                            <xsl:text>thick solid black</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </fo:region-body>
                <fo:region-before region-name="BlankEvenPage-before" extent="{$sHeaderMargin}">
                    <xsl:call-template name="DoDebugHeader"/>
                </fo:region-before>
                <fo:region-after region-name="BlankEvenPage-after" extent="{$sFooterMargin}">
                    <xsl:call-template name="DoDebugFooter"/>
                </fo:region-after>
            </xsl:element>
            <xsl:if test="$bIsBook">
                <!-- insert a new line so we don't get everything all on one line -->
                <xsl:text>&#xa;</xsl:text>
                <fo:page-sequence-master master-name="FrontMatter">
                    <fo:repeatable-page-master-alternatives>
                        <fo:conditional-page-master-reference page-position="first" master-reference="FrontMatterPage"/>
                        <fo:conditional-page-master-reference odd-or-even="odd" master-reference="FrontMatterPage"/>
                        <fo:conditional-page-master-reference odd-or-even="even" master-reference="FrontMatterPage"/>
                        <fo:conditional-page-master-reference odd-or-even="even" blank-or-not-blank="blank" master-reference="FrontMatterBlankEvenPage"/>
                    </fo:repeatable-page-master-alternatives>
                </fo:page-sequence-master>
                <!-- insert a new line so we don't get everything all on one line -->
                <xsl:text>&#xa;</xsl:text>
                <fo:page-sequence-master master-name="FrontMatterTOC">
                    <fo:repeatable-page-master-alternatives>
                        <fo:conditional-page-master-reference page-position="first" master-reference="FrontMatterTOCFirstPage"/>
                        <fo:conditional-page-master-reference odd-or-even="even" blank-or-not-blank="blank" master-reference="FrontMatterBlankEvenPage"/>
                        <fo:conditional-page-master-reference odd-or-even="even" master-reference="FrontMatterTOCEvenPage"/>
                        <fo:conditional-page-master-reference odd-or-even="odd" master-reference="FrontMatterTOCOddPage"/>
                    </fo:repeatable-page-master-alternatives>
                </fo:page-sequence-master>
            </xsl:if>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <fo:page-sequence-master master-name="Chapter">
                <fo:repeatable-page-master-alternatives>
                    <fo:conditional-page-master-reference page-position="first" master-reference="ChapterFirstPage"/>
                    <fo:conditional-page-master-reference odd-or-even="even" blank-or-not-blank="blank" master-reference="BlankEvenPage"/>
                    <xsl:choose>
                        <xsl:when test="$pageLayoutInfo/headerFooterPageStyles/headerFooterPage">
                            <fo:conditional-page-master-reference odd-or-even="any" master-reference="ChapterRegularPage"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:conditional-page-master-reference odd-or-even="even" master-reference="ChapterEvenPage"/>
                            <fo:conditional-page-master-reference odd-or-even="odd" master-reference="ChapterOddPage"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:repeatable-page-master-alternatives>
            </fo:page-sequence-master>
            <!-- insert a new line so we don't get everything all on one line -->
            <xsl:text>&#xa;</xsl:text>
            <fo:page-sequence-master master-name="Index">
                <fo:repeatable-page-master-alternatives>
                    <fo:conditional-page-master-reference page-position="first" master-reference="IndexFirstPage"/>
                    <fo:conditional-page-master-reference odd-or-even="even" blank-or-not-blank="blank" master-reference="BlankEvenPage"/>
                    <fo:conditional-page-master-reference odd-or-even="even" master-reference="IndexEvenPage"/>
                    <fo:conditional-page-master-reference odd-or-even="odd" master-reference="IndexOddPage"/>
                </fo:repeatable-page-master-alternatives>
            </fo:page-sequence-master>
        </fo:layout-master-set>
    </xsl:template>
    <!--  
                  DoNestedTypes
-->
    <xsl:template name="DoNestedTypes">
        <xsl:param name="sList"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:if test="string-length($sFirst) &gt; 0">
            <xsl:call-template name="DoType">
                <xsl:with-param name="type" select="$sFirst"/>
                <xsl:with-param name="bDoingNestedTypes" select="'y'"/>
            </xsl:call-template>
            <xsl:if test="$sRest">
                <xsl:call-template name="DoNestedTypes">
                    <xsl:with-param name="sList" select="$sRest"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        DoPageBreakFormatInfo
    -->
    <xsl:template name="DoPageBreakFormatInfo">
        <xsl:param name="layoutInfo"/>
        <xsl:if test="$layoutInfo/@pagebreakbefore='yes'">
            <xsl:attribute name="break-before">
                <xsl:text>page</xsl:text>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="$layoutInfo/@startonoddpage='yes'">
            <xsl:attribute name="break-before">
                <xsl:text>odd-page</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!--  
        DoPrefacePerBookLayout
    -->
    <xsl:template name="DoPrefacePerBookLayout">
        <xsl:param name="iPos"/>
        <xsl:param name="prefaceLayout"/>
        <xsl:call-template name="DoFrontMatterItemNewPage">
            <xsl:with-param name="sHeaderTitleClassName" select="'preface-title'"/>
            <xsl:with-param name="id">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="concat($sPrefaceID,$iPos)"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputPrefaceLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$prefaceLayout"/>
            <xsl:with-param name="sMarkerClassName" select="'preface-title'"/>
            <xsl:with-param name="sRunningHeader">
                <xsl:call-template name="OutputPrefaceLabel">
                    <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--  
        DoPrefacePerPaperLayout
    -->
    <xsl:template name="DoPrefacePerPaperLayout">
        <xsl:param name="iPos"/>
        <xsl:param name="prefaceLayout"/>
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="concat($sPrefaceID,$iPos)"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputPrefaceLabel"/>
            </xsl:with-param>
            <xsl:with-param name="bIsBook" select="'N'"/>
            <xsl:with-param name="layoutInfo" select="$prefaceLayout"/>
            <xsl:with-param name="sMarkerClassName" select="'preface-title'"/>
            <xsl:with-param name="sRunningHeader">
                <xsl:call-template name="OutputPrefaceLabel">
                    <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <!--  
        DoReferences
    -->
    <xsl:template name="DoReferences">
        <xsl:param name="backMatterLayout" select="$backMatterLayoutInfo"/>
        <xsl:call-template name="OutputBackMatterItemTitle">
            <xsl:with-param name="sId">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="$sReferencesID"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputReferencesLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$backMatterLayout/referencesTitleLayout"/>
            <xsl:with-param name="sRunningHeader">
                <xsl:call-template name="OutputReferencesLabel">
                    <xsl:with-param name="fUseShortTitleIfExists" select="'Y'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacereferences='yes'">
                <xsl:attribute name="line-height">
                    <xsl:value-of select="$sSinglespacingLineHeight"/>
                </xsl:attribute>
            </xsl:if>
            <!--            <xsl:for-each select="//refAuthor[refWork/@id=//citation[not(ancestor::comment)]/@ref]">
                <xsl:variable name="works" select="refWork[@id=//citation[not(ancestor::comment)]/@ref]"/>
                <xsl:for-each select="$works">
            -->
            <xsl:call-template name="HandleRefAuthors"/>
        </fo:block>
    </xsl:template>
    <!--  
        DoRefWork
    -->
    <xsl:template name="DoRefWork">
        <xsl:param name="works"/>
        <xsl:param name="bDoTarget" select="'Y'"/>
        <xsl:variable name="work" select="."/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block text-indent="-{$referencesLayoutInfo/@hangingindentsize}" start-indent="{$referencesLayoutInfo/@hangingindentsize}">
            <xsl:if test="$bDoTarget='Y'">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:if test="$referencesLayoutInfo/@defaultfontsize">
                    <xsl:attribute name="font-size">
                        <xsl:call-template name="AdjustFontSizePerMagnification">
                            <xsl:with-param name="sFontSize" select="$referencesLayoutInfo/@defaultfontsize"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
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
        </fo:block>
    </xsl:template>
    <!--  
        DoRefWorks
    -->
    <xsl:template name="DoRefWorks">
        <xsl:variable name="thisAuthor" select="."/>
        <xsl:variable name="works"
            select="refWork[@id=$citations[not(ancestor::comment) and not(ancestor::annotation)][not(ancestor::refWork) or ancestor::refWork[@id=$citations[not(ancestor::refWork)]/@ref]]/@ref] | $refWorks[@id=saxon:node-set($collOrProcVolumesToInclude)/refWork/@id][parent::refAuthor=$thisAuthor] | refWork[@id=$citationsInAnnotationsReferredTo[not(ancestor::comment)]/@ref]"/>
        <xsl:for-each select="$works">
            <xsl:call-template name="DoRefWork">
                <xsl:with-param name="works" select="$works"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoSecNumberRunningHeader
    -->
    <xsl:template name="DoSecNumberRunningHeader">
        <xsl:param name="number"/>
        <xsl:if test="$number">
            <!-- format and output number -->
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$number"/>
                <xsl:with-param name="originalContext" select="$number"/>
            </xsl:call-template>
            <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                <xsl:with-param name="layoutInfo" select="$number"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="name($number)='sectionNumber'">
                    <xsl:call-template name="OutputSectionNumber"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="OutputChapterNumber"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$number"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
        DoSection
    -->
    <xsl:template name="DoSection">
        <xsl:param name="layoutInfo"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
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
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoSectionAsTitle">
                    <xsl:with-param name="formatTitleLayoutInfo" select="$formatTitleLayoutInfo"/>
                    <xsl:with-param name="numberLayoutInfo" select="$numberLayoutInfo"/>
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
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
        <xsl:param name="layoutInfo"/>
        <fo:block id="{@id}" keep-with-next.within-page="always">
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
            </xsl:call-template>
            <xsl:call-template name="DoType"/>
            <xsl:if test="$layoutInfo/@showInHeader!='no'">
                <!-- put title in marker so it can show up in running header -->
                <fo:marker marker-class-name="section-title">
                    <xsl:call-template name="DoSecTitleRunningHeader">
                        <xsl:with-param name="number" select="$sectionNumberInHeaderLayout"/>
                        <xsl:with-param name="bNumberIsBeforeTitle" select="$bSectionNumberIsBeforeTitle"/>
                    </xsl:call-template>
                </fo:marker>
            </xsl:if>
            <xsl:if test="$layoutInfo/sectionTitleLayout/@linebefore='yes'">
                <xsl:call-template name="DoHorizontalRule">
                    <xsl:with-param name="line-weight" select="normalize-space($layoutInfo/sectionTitleLayout/@linebefore-weight)"/>
                    <xsl:with-param name="sFOProcessor" select="$sFOProcessor"/>
                </xsl:call-template>
            </xsl:if>
            <fo:inline>
                <xsl:call-template name="OutputSectionNumber">
                    <xsl:with-param name="numberLayoutInfo" select="$numberLayoutInfo"/>
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                </xsl:call-template>
                <xsl:call-template name="OutputSectionTitle"/>
            </fo:inline>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
            </xsl:call-template>
        </fo:block>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <!--  
      DoSectionBeginsParagraph
   -->
    <xsl:template name="DoSectionBeginsParagraph">
        <xsl:param name="formatTitleLayoutInfo"/>
        <xsl:param name="numberLayoutInfo"/>
        <xsl:param name="layoutInfo"/>
        <fo:block id="{@id}" keep-with-next.within-page="always">
            <xsl:attribute name="text-indent">
                <xsl:value-of select="$sParagraphIndent"/>
            </xsl:attribute>
            <xsl:call-template name="DoSpaceBeforeAfter">
                <xsl:with-param name="layoutInfo" select="$numberLayoutInfo"/>
            </xsl:call-template>
            <xsl:call-template name="DoSpaceBeforeAfter">
                <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
            </xsl:call-template>
            <xsl:if test="$layoutInfo/@showInHeader!='no'">
                <!-- put title in marker so it can show up in running header -->
                <fo:marker marker-class-name="section-title">
                    <xsl:call-template name="DoSecTitleRunningHeader">
                        <xsl:with-param name="number" select="$sectionNumberInHeaderLayout"/>
                        <xsl:with-param name="bNumberIsBeforeTitle" select="$bSectionNumberIsBeforeTitle"/>
                    </xsl:call-template>
                </fo:marker>
            </xsl:if>
            <fo:inline>
                <xsl:call-template name="OutputSectionNumber">
                    <xsl:with-param name="numberLayoutInfo" select="$numberLayoutInfo"/>
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                </xsl:call-template>
            </fo:inline>
            <fo:inline>
                <xsl:call-template name="DoTitleFormatInfo">
                    <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
                </xsl:call-template>
                <xsl:call-template name="OutputSectionTitle"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
                </xsl:call-template>
            </fo:inline>
            <!--            <xsl:text>.  </xsl:text>-->
            <xsl:apply-templates select="child::node()[name()!='secTitle'][1][name()='p']" mode="contentOnly"/>
        </fo:block>
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
        <xsl:param name="number"/>
        <xsl:param name="bNumberIsBeforeTitle" select="'Y'"/>
        <xsl:variable name="shortTitle" select="shortTitle"/>
        <xsl:if test="$bNumberIsBeforeTitle='Y'">
            <xsl:call-template name="DoSecNumberRunningHeader">
                <xsl:with-param name="number" select="$number"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($shortTitle) &gt; 0">
                <xsl:apply-templates select="$shortTitle" mode="InMarker"/>
            </xsl:when>
            <xsl:when test="string-length(frontMatter/shortTitle) &gt; 0">
                <xsl:apply-templates select="frontMatter/shortTitle" mode="InMarker"/>
            </xsl:when>
            <xsl:when test="string-length(frontMatter/title) &gt; 0">
                <xsl:apply-templates select="frontMatter/title" mode="InMarker"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="secTitle" mode="InMarker"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$bNumberIsBeforeTitle!='Y'">
            <xsl:call-template name="DoSecNumberRunningHeader">
                <xsl:with-param name="number" select="$number"/>
            </xsl:call-template>
        </xsl:if>
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
        <fo:block text-align="{table/@align}" id="{@id}" space-before="{$sBasicPointSize}pt">
            <xsl:attribute name="space-after">
                <xsl:value-of select="$sBasicPointSize"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="DoType"/>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:if test="$sFOProcessor='XFC' and parent::endnote">
                <xsl:call-template name="InsertEndnoteWarningMessage">
                    <xsl:with-param name="sKind" select="'tablenumbered'"/>
                    <xsl:with-param name="sId" select="@id"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$contentLayoutInfo/tablenumberedLayout/@captionLocation='before' or not($contentLayoutInfo/tablenumberedLayout) and $lingPaper/@tablenumberedLabelAndCaptionLocation='before'">
                <fo:block>
                    <xsl:attribute name="space-after">
                        <xsl:choose>
                            <xsl:when test="string-length($sSpaceBetweenTableAndCaption) &gt; 0">
                                <xsl:value-of select="$sSpaceBetweenTableAndCaption"/>
                            </xsl:when>
                            <xsl:otherwise>0pt</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:call-template name="OutputTableNumberedLabelAndCaption"/>
                </fo:block>
            </xsl:if>
            <xsl:apply-templates select="*[name()!='shortCaption']"/>
            <xsl:if test="$contentLayoutInfo/tablenumberedLayout/@captionLocation='after' or not($contentLayoutInfo/tablenumberedLayout) and $lingPaper/@tablenumberedLabelAndCaptionLocation='after'">
                <fo:block>
                    <xsl:attribute name="padding-before">
                        <xsl:choose>
                            <xsl:when test="string-length($sSpaceBetweenTableAndCaption) &gt; 0">
                                <xsl:value-of select="$sSpaceBetweenTableAndCaption"/>
                            </xsl:when>
                            <xsl:otherwise>0pt</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="keep-with-previous.within-page">10</xsl:attribute>
                    <xsl:call-template name="OutputTableNumberedLabelAndCaption"/>
                </fo:block>
            </xsl:if>
        </fo:block>
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
                  DoType
-->
    <xsl:template name="DoType">
        <xsl:param name="type" select="@type"/>
        <xsl:param name="bDoingNestedTypes" select="'n'"/>
        <xsl:for-each select="key('TypeID',$type)">
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
            <xsl:call-template name="DoNestedTypes">
                <xsl:with-param name="sList" select="@types"/>
            </xsl:call-template>
            <xsl:if test="$bDoingNestedTypes!='y'">
                <xsl:value-of select="."/>
            </xsl:if>
        </xsl:for-each>
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
        GetFirstLevelContentsIdent
    -->
    <xsl:template name="GetFirstLevelContentsIdent">
        <xsl:text>1</xsl:text>
    </xsl:template>
    <!--  
        HandleEndnoteInBackMatter
    -->
    <xsl:template name="HandleEndnoteInBackMatter">
        <xsl:param name="originalContext"/>
        <xsl:param name="iTablenumberedAdjust" select="0"/>
        <xsl:if test="$bIsBook">
            <xsl:call-template name="DoBookEndnoteSectionLabel">
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="DoFootnoteContent">
            <xsl:with-param name="originalContext" select="$originalContext"/>
            <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        HandleKeywordsLayoutWithoutPageBreak
    -->
    <xsl:template name="HandleKeywordsLayoutWithoutPageBreak">
        <xsl:param name="keywordsLayout"/>
        <xsl:param name="backMatterLayout"/>
        <xsl:if test="name($keywordsLayout)='keywordsLayout'">
            <xsl:if test="$keywordsLayout/@pagebreakbefore!='yes'">
                <xsl:apply-templates select="../keywordsShownHere">
                    <xsl:with-param name="frontMatterLayout" select="$backMatterLayout"/>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--
        HandleLiteralLabelLayoutInfo
    -->
    <xsl:template name="HandleLiteralLabelLayoutInfo">
        <xsl:param name="layoutInfo"/>
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$layoutInfo"/>
            </xsl:call-template>
            <xsl:value-of select="$layoutInfo/../literalLabelLayout"/>
        </fo:inline>
    </xsl:template>
    <!--  
        HandleSectionNumberOutput
    -->
    <xsl:template name="HandleSectionNumberOutput">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="bAppendix"/>
        <xsl:param name="sContentsPeriod"/>
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
        <xsl:value-of select="$sContentsPeriod"/>
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
            <xsl:when test="$sFOProcessor = 'XEP'">
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
        <fo:inline id="{@id}">
            <xsl:call-template name="OutputAbbrTerm">
                <xsl:with-param name="abbr" select="."/>
            </xsl:call-template>
            <xsl:call-template name="DoAnyEqualsSignBetweenAbbrAndDefinition"/>            
            <xsl:call-template name="OutputAbbrDefinition">
                <xsl:with-param name="abbr" select="."/>
            </xsl:call-template>
        </fo:inline>
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
        Dummy templates used in common file
    -->
    <xsl:template name="LinkAttributesBegin"/>
    <xsl:template name="LinkAttributesEnd"/>
    <!--
      OutputAbbrTerm
   -->
    <xsl:template name="OutputAbbrTerm">
        <xsl:param name="abbr"/>
        <fo:inline>
            <xsl:if test="$abbreviations/@usesmallcaps='yes'">
                <xsl:call-template name="HandleSmallCaps"/>
            </xsl:if>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$abbreviations"/>
                <xsl:with-param name="ignoreFontFamily">
                    <xsl:choose>
                        <xsl:when test="$abbr/@ignoreabbreviationsfontfamily='yes'">
                            <xsl:text>Y</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>N</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="string-length($abbrLang) &gt; 0">
                    <xsl:choose>
                        <xsl:when test="string-length($abbr//abbrInLang[@lang=$abbrLang]/abbrTerm) &gt; 0">
                            <xsl:apply-templates select="$abbr/abbrInLang[@lang=$abbrLang]/abbrTerm"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- a language is specified, but this abbreviation does not have anything; try using the default;
                                this assumes that something is better than nothing -->
                            <xsl:apply-templates select="$abbr/abbrInLang[1]/abbrTerm"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!--  no language specified; just use the first one -->
                    <xsl:apply-templates select="$abbr/abbrInLang[1]/abbrTerm"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:inline>
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
        OutputAppendixInChapterInCollectionTOC
    -->
    <xsl:template name="OutputAppendixInChapterInCollectionTOC">
        <xsl:param name="frontMatterLayout"/>
        <!-- output the toc line -->
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:if test="$frontMatterLayout/contentsLayout/@useappendixlabelbeforeappendixletter='yes'">
                    <xsl:choose>
                        <xsl:when test="string-length(@label) &gt; 0">
                            <xsl:value-of select="@label"/>
                        </xsl:when>
                        <xsl:otherwise>Appendix</xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>&#x20;</xsl:text>
                </xsl:if>
                <xsl:call-template name="OutputChapterNumber">
                    <xsl:with-param name="fDoTextAfterLetter" select="'N'"/>
                </xsl:call-template>
                <xsl:apply-templates select="secTitle" mode="contents"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine">
                    <xsl:with-param name="contentsLayoutToUse" select="$frontMatterLayout/contentsLayout"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">1</xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="section1 | section2" mode="contents">
            <xsl:with-param name="contentsLayoutToUse" select="$frontMatterLayout/contentsLayout"/>
        </xsl:apply-templates>
    </xsl:template>
    <!--
      OutputBackgroundColor
   -->
    <xsl:template name="OutputBackgroundColor">
        <xsl:if test="string-length(@backgroundcolor) &gt; 0">
            <xsl:attribute name="background-color">
                <xsl:value-of select="@backgroundcolor"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!--
                   OutputBackMatterItemTitle
-->
    <xsl:template name="OutputBackMatterItemTitle">
        <xsl:param name="sId"/>
        <xsl:param name="sLabel"/>
        <xsl:param name="layoutInfo"/>
        <xsl:param name="sRunningHeader"/>
        <xsl:choose>
            <xsl:when test="$bIsBook and not(ancestor::chapterInCollection)">
                <fo:block id="{$sId}" span="all">
                    <xsl:call-template name="DoTitleFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputChapTitle">
                        <xsl:with-param name="sTitle" select="$sLabel"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    </xsl:call-template>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block id="{$sId}" keep-with-next.within-page="always" span="all">
                    <xsl:call-template name="DoType"/>
                    <xsl:call-template name="DoTitleFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        <xsl:with-param name="bCheckPageBreakFormatInfo" select="'Y'"/>
                    </xsl:call-template>
                    <fo:inline>
                        <fo:marker marker-class-name="section-title">
                            <xsl:value-of select="$sRunningHeader"/>
                        </fo:marker>
                    </fo:inline>
                    <fo:inline>
                        <xsl:value-of select="$sLabel"/>
                    </fo:inline>
                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    </xsl:call-template>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputChapterNumber
-->
    <xsl:template name="OutputChapterNumber">
        <xsl:param name="fDoTextAfterLetter" select="'Y'"/>
        <xsl:param name="fIgnoreTextAfterLetter" select="'N'"/>
        <xsl:param name="fDoingContents" select="'N'"/>
        <xsl:param name="contentsLayoutToUse" select="$frontMatterLayoutInfo/contentsLayout"/>
        <xsl:choose>
            <xsl:when test="name()='chapter' or name()='chapterInCollection'">
                <xsl:apply-templates select="." mode="numberChapter"/>
                <xsl:if test="$fDoingContents='N' and not($bodyLayoutInfo/chapterLayout/numberLayout) and string-length($bodyLayoutInfo/chapterLayout/chapterTitleLayout/@textafternumber) &gt; 0">
                    <xsl:value-of select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout/@textafternumber"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="name()='chapterBeforePart'">
                <xsl:text>0</xsl:text>
            </xsl:when>
            <xsl:when test="name()='part'">
                <xsl:apply-templates select="." mode="numberPart"/>
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
                        <xsl:when test="$contentsLayoutToUse/@useperiodafterappendixletter='yes'">
                            <xsl:text>.&#xa0;</xsl:text>
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
        <xsl:call-template name="DoHeaderAndFooter">
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
    </xsl:template>
    <!--  
      OutputChapterStaticContentForBackMatter
   -->
    <xsl:template name="OutputChapterStaticContentForBackMatter">
        <xsl:choose>
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
    </xsl:template>
    <!--  
                  OutputChapTitle
-->
    <xsl:template name="OutputChapTitle">
        <xsl:param name="sTitle"/>
        <!--      <fo:block span="all">-->
        <xsl:value-of select="$sTitle"/>
        <!--      </fo:block>-->
    </xsl:template>
    <!--  
        OutputTableNumberedLabel
    -->
    <xsl:template name="OutputTableNumberedLabel">
        <xsl:variable name="styleSheetLabelLayout" select="$styleSheetTableNumberedLabelLayout"/>
        <xsl:variable name="styleSheetLabelLayoutLabel" select="$styleSheetLabelLayout/@label"/>
        <xsl:variable name="label" select="$lingPaper/@tablenumberedLabel"/>
        <fo:inline>
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
        </fo:inline>
    </xsl:template>
    <!--  
        OutputTableNumberedLabelAndCaption
    -->
    <xsl:template name="OutputTableNumberedLabelAndCaption">
        <xsl:param name="bDoStyles" select="'Y'"/>
        <fo:inline>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$styleSheetTableNumberedLabelLayout"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="OutputTableNumberedLabel"/>
        </fo:inline>
        <fo:inline>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$styleSheetTableNumberedNumberLayout"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:value-of select="$styleSheetTableNumberedNumberLayout/@textbefore"/>
            <!--            <xsl:apply-templates select="." mode="tablenumbered"/>-->
            <xsl:call-template name="GetTableNumberedNumber">
                <xsl:with-param name="tablenumbered" select="."/>
            </xsl:call-template>
            <xsl:value-of select="$styleSheetTableNumberedNumberLayout/@textafter"/>
        </fo:inline>
        <fo:inline>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$styleSheetTableNumberedCaptionLayout"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:value-of select="$styleSheetTableNumberedCaptionLayout/@textbefore"/>
            <xsl:choose>
                <xsl:when test="$bDoStyles='Y'">
                    <xsl:apply-templates select="table/caption | table/endCaption | caption" mode="show">
                        <xsl:with-param name="styleSheetLabelLayout" select="$contentLayoutInfo/tablenumberedLabelLayout"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="table/caption | table/endCaption | caption" mode="contents"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$styleSheetTableNumberedCaptionLayout/@textafter"/>
        </fo:inline>
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
        <fo:inline>
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
        </fo:inline>
    </xsl:template>
    <!--  
        OutputFigureLabelAndCaption
    -->
    <xsl:template name="OutputFigureLabelAndCaption">
        <xsl:param name="bDoStyles" select="'Y'"/>
        <fo:inline>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$styleSheetFigureLabelLayout"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="OutputFigureLabel"/>
        </fo:inline>
        <fo:inline>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$styleSheetFigureNumberLayout"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:value-of select="$styleSheetFigureNumberLayout/@textbefore"/>
            <!--            <xsl:apply-templates select="." mode="figure"/>-->
            <xsl:call-template name="GetFigureNumber">
                <xsl:with-param name="figure" select="."/>
            </xsl:call-template>
            <xsl:value-of select="$styleSheetFigureNumberLayout/@textafter"/>
        </fo:inline>
        <fo:inline>
            <xsl:if test="$bDoStyles='Y'">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$styleSheetFigureCaptionLayout"/>
                </xsl:call-template>
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
        </fo:inline>
    </xsl:template>
    <xsl:template match="caption | endCaption" mode="show">
        <xsl:param name="styleSheetLabelLayout" select="$contentLayoutInfo/figureLabelLayout"/>
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$styleSheetLabelLayout"/>
            </xsl:call-template>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="caption | endCaption" mode="contents">
        <xsl:choose>
            <xsl:when test="following-sibling::shortCaption">
                <xsl:apply-templates select="following-sibling::shortCaption"/>
            </xsl:when>
            <xsl:when test="ancestor::tablenumbered/shortCaption">
                <xsl:apply-templates select="ancestor::tablenumbered/shortCaption"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="text() | *[not(descendant-or-self::endnote)]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputFontAttributes
-->
    <xsl:template name="OutputFontAttributes">
        <xsl:param name="language"/>
        <xsl:param name="ignoreFontFamily" select="'N'"/>
        <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="$language/@xsl-foSpecial"/>
        </xsl:call-template>
        <xsl:if test="string-length(normalize-space($language/@font-family)) &gt; 0 and $ignoreFontFamily='N'">
            <xsl:attribute name="font-family">
                <xsl:value-of select="$language/@font-family"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($language/@font-size)) &gt; 0">
            <xsl:attribute name="font-size">
                <xsl:call-template name="AdjustFontSizePerMagnification">
                    <xsl:with-param name="sFontSize" select="$language/@font-size"/>
                </xsl:call-template>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($language/@font-style)) &gt; 0">
            <xsl:attribute name="font-style">
                <xsl:value-of select="$language/@font-style"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($language/@font-variant)) &gt; 0">
            <xsl:call-template name="DoFontVariant">
                <xsl:with-param name="item" select="$language"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($language/@font-weight)) &gt; 0">
            <xsl:attribute name="font-weight">
                <xsl:value-of select="$language/@font-weight"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($language/@color)) &gt; 0">
            <xsl:attribute name="color">
                <xsl:value-of select="$language/@color"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($language/@backgroundcolor)) &gt; 0">
            <xsl:attribute name="background-color">
                <xsl:value-of select="$language/@backgroundcolor"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($language/@text-transform)) &gt; 0">
            <xsl:attribute name="text-transform">
                <xsl:value-of select="$language/@text-transform"/>
            </xsl:attribute>
        </xsl:if>
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
        <xsl:param name="sRunningHeader"/>
        <xsl:if test="$bIsBook='Y'">
            <fo:marker marker-class-name="{$sMarkerClassName}">
                <xsl:value-of select="$sRunningHeader"/>
            </fo:marker>
        </xsl:if>
        <fo:block>
            <xsl:attribute name="id">
                <xsl:value-of select="$id"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$bIsBook='Y'">
                    <xsl:attribute name="span">all</xsl:attribute>
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
                    <fo:inline>
                        <!-- put title in marker so it can show up in running header -->
                        <fo:marker marker-class-name="{$sMarkerClassName}">
                            <xsl:value-of select="$sRunningHeader"/>
                        </fo:marker>
                    </fo:inline>
                    <xsl:if test="not($layoutInfo/@useLabel) or $layoutInfo/@useLabel='yes'">
                        <fo:inline>
                            <xsl:value-of select="$sTitle"/>
                        </fo:inline>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <!--
                   OutputIndexedItemsRange
-->
    <xsl:template name="OutputIndexedItemsRange">
        <xsl:param name="sIndexedItemID"/>
        <xsl:call-template name="OutputIndexedItemsPageNumber">
            <xsl:with-param name="sIndexedItemID" select="$sIndexedItemID"/>
        </xsl:call-template>
        <xsl:if test="name()='indexedRangeBegin'">
            <xsl:variable name="sBeginId" select="@id"/>
            <xsl:for-each select="//indexedRangeEnd[@begin=$sBeginId][1]">
                <!-- only use first one because that's all there should be -->
                <xsl:text>-</xsl:text>
                <xsl:call-template name="OutputIndexedItemsPageNumber">
                    <xsl:with-param name="sIndexedItemID">
                        <xsl:call-template name="CreateIndexedItemID">
                            <xsl:with-param name="sTermId" select="@begin"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <!--
                   OutputIndexedItemsPageNumber
-->
    <xsl:template name="OutputIndexedItemsPageNumber">
        <xsl:param name="sIndexedItemID"/>
        <fo:inline>
            <fo:basic-link internal-destination="{$sIndexedItemID}">
                <xsl:call-template name="AddAnyLinkAttributes">
                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/indexLinkLayout"/>
                </xsl:call-template>
                <fo:page-number-citation ref-id="{$sIndexedItemID}"/>
                <xsl:if test="ancestor::endnote">
                    <xsl:text>n</xsl:text>
                </xsl:if>
            </fo:basic-link>
        </fo:inline>
    </xsl:template>
    <!--  
                  OutputIndexStaticContent
-->
    <xsl:template name="OutputIndexStaticContent">
        <xsl:param name="sIndexTitle" select="'index-title'"/>
        <fo:static-content flow-name="IndexFirstPage-after" display-align="after">
            <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                <xsl:attribute name="text-align">center</xsl:attribute>
                <xsl:attribute name="margin-top">6pt</xsl:attribute>
                <fo:page-number/>
            </xsl:element>
        </fo:static-content>
        <fo:static-content flow-name="IndexEvenPage-before" display-align="before">
            <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                <xsl:attribute name="text-align-last">justify</xsl:attribute>
                <fo:inline>
                    <fo:page-number/>
                </fo:inline>
                <fo:leader/>
                <fo:inline>
                    <fo:retrieve-marker retrieve-class-name="{$sIndexTitle}"/>
                </fo:inline>
            </xsl:element>
        </fo:static-content>
        <fo:static-content flow-name="IndexOddPage-before" display-align="before">
            <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                <xsl:attribute name="text-align-last">justify</xsl:attribute>
                <fo:inline>
                    <fo:retrieve-marker retrieve-class-name="{$sIndexTitle}"/>
                </fo:inline>
                <fo:leader/>
                <fo:inline>
                    <fo:page-number/>
                </fo:inline>
            </xsl:element>
        </fo:static-content>
        <xsl:call-template name="DoFootnoteSeparatorStaticContent"/>
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
            <fo:block text-indent="-.5in">
                <xsl:variable name="iIndent" select="count($terms/ancestor::*[name()='indexTerm']) * .25 + .5"/>
                <xsl:attribute name="start-indent">
                    <xsl:value-of select="$iIndent"/>
                    <xsl:text>in</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="$indexTermsToShow">
                    <!--                    <xsl:sort select="term[1]"/>-->
                    <xsl:sort lang="{$lang}" select="term[@lang=$lang or position()=1 and not (following-sibling::term[@lang=$lang])]"/>
                    <xsl:variable name="sTermId" select="@id"/>
                    <!-- if a nested index term is cited, we need to be sure to show its parents, even if they are not cited -->
                    <xsl:variable name="bHasCitedDescendant">
                        <xsl:for-each select="descendant::indexTerm">
                            <xsl:variable name="sDescendantTermId" select="@id"/>
                            <xsl:if test="//indexedItem[@term=$sDescendantTermId][not(ancestor::comment)] or //indexedRangeBegin[@term=$sDescendantTermId][not(ancestor::comment)]">
                                <xsl:text>Y</xsl:text>
                            </xsl:if>
                            <xsl:if test="@see">
                                <xsl:call-template name="CheckSeeTargetIsCitedOrItsDescendantIsCited"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="indexedItems" select="//indexedItem[@term=$sTermId][not(ancestor::comment)] | //indexedRangeBegin[@term=$sTermId][not(ancestor::comment)]"/>
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
                            <fo:block>
                                <fo:inline>
                                    <xsl:attribute name="id">
                                        <xsl:call-template name="CreateIndexTermID">
                                            <xsl:with-param name="sTermId" select="$sTermId"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                    <xsl:call-template name="OutputIndexTermsTerm">
                                        <xsl:with-param name="lang" select="$lang"/>
                                        <xsl:with-param name="indexTerm" select="."/>
                                    </xsl:call-template>
                                    <xsl:text>&#x20;&#x20;</xsl:text>
                                </fo:inline>
                                <xsl:for-each select="$indexedItems">
                                    <!-- show each reference -->
                                    <fo:inline>
                                        <xsl:variable name="sIndexedItemID">
                                            <xsl:call-template name="CreateIndexedItemID">
                                                <xsl:with-param name="sTermId" select="$sTermId"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:choose>
                                            <xsl:when test="@main='yes' and count($indexedItems) &gt; 1">
                                                <fo:inline font-weight="bold">
                                                    <xsl:call-template name="OutputIndexedItemsRange">
                                                        <xsl:with-param name="sIndexedItemID" select="$sIndexedItemID"/>
                                                    </xsl:call-template>
                                                </fo:inline>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="OutputIndexedItemsRange">
                                                    <xsl:with-param name="sIndexedItemID" select="$sIndexedItemID"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </fo:inline>
                                    <xsl:if test="position()!=last()">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:if test="$bHasSeeAttribute='Y' and contains($bSeeTargetIsCitedOrItsDescendantIsCited, 'Y')">
                                    <!-- this term also has a @see attribute which refers to a term that is cited or whose descendant is cited -->
                                    <xsl:call-template name="OutputIndexTermSeeBefore">
                                        <xsl:with-param name="indexedItems" select="$indexedItems"/>
                                    </xsl:call-template>
                                    <fo:inline>
                                        <fo:basic-link>
                                            <xsl:attribute name="internal-destination">
                                                <xsl:call-template name="CreateIndexTermID">
                                                    <xsl:with-param name="sTermId" select="@see"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:call-template name="AddAnyLinkAttributes">
                                                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/indexLinkLayout"/>
                                            </xsl:call-template>
                                            <!--                                            <xsl:apply-templates select="key('IndexTermID',@see)/term[1]" mode="InIndex"/>-->
                                            <xsl:apply-templates select="key('IndexTermID',@see)/term[@lang=$lang or position()=1 and not (following-sibling::term[@lang=$lang])]" mode="InIndex"/>
                                        </fo:basic-link>
                                    </fo:inline>
                                    <xsl:call-template name="OutputIndexTermSeeAfter">
                                        <xsl:with-param name="indexedItems" select="$indexedItems"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </fo:block>
                            <xsl:call-template name="OutputIndexTerms">
                                <xsl:with-param name="sIndexKind" select="$sIndexKind"/>
                                <xsl:with-param name="lang" select="$lang"/>
                                <xsl:with-param name="terms" select="indexTerms"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$bHasSeeAttribute='Y' and contains($bSeeTargetIsCitedOrItsDescendantIsCited, 'Y')">
                            <!-- neither this term nor its decendants are cited, but it has a @see attribute which refers to a term that is cited or for which one of its descendants is cited -->
                            <fo:block>
                                <!--<xsl:apply-templates select="term[1]" mode="InIndex"/>
                                <xsl:text>&#x20;&#x20;See </xsl:text>-->
                                <xsl:apply-templates select="term[@lang=$lang or position()=1 and not (following-sibling::term[@lang=$lang])]" mode="InIndex"/>
                                <xsl:call-template name="OutputIndexTermSeeAloneBefore"/>
                                <fo:inline>
                                    <fo:basic-link>
                                        <xsl:attribute name="internal-destination">
                                            <xsl:call-template name="CreateIndexTermID">
                                                <xsl:with-param name="sTermId" select="@see"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                        <xsl:call-template name="AddAnyLinkAttributes">
                                            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/indexLinkLayout"/>
                                        </xsl:call-template>
                                        <xsl:call-template name="OutputIndexTermsTerm">
                                            <xsl:with-param name="lang" select="$lang"/>
                                            <xsl:with-param name="indexTerm" select="key('IndexTermID',@see)"/>
                                        </xsl:call-template>
                                    </fo:basic-link>
                                </fo:inline>
                                <xsl:text>.</xsl:text>
                            </fo:block>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </fo:block>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputInterlinear
    -->
    <xsl:template name="OutputInterlinear">
        <xsl:param name="mode"/>
        <xsl:choose>
            <xsl:when test="lineSet">
                <xsl:for-each select="lineSet | conflation">
                    <xsl:call-template name="ApplyTemplatesPerTextRefMode">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="ApplyTemplatesPerTextRefMode">
                    <xsl:with-param name="mode" select="$mode"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputInterlinearTextReferenceContent
    -->
    <xsl:template name="OutputInterlinearTextReferenceContent">
        <xsl:param name="sSource"/>
        <xsl:param name="sRef"/>
        <xsl:choose>
            <xsl:when test="$sSource">
                <xsl:apply-templates select="$sSource" mode="contents"/>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($sRef)) &gt; 0">
                <xsl:call-template name="DoInterlinearRefCitation">
                    <xsl:with-param name="sRef" select="$sRef"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputKeywordsTitleAndContent
    -->
    <xsl:template name="OutputKeywordsTitleAndContent">
        <xsl:param name="sKeywordsID"/>
        <xsl:param name="layoutInfo"/>
        <fo:block>
            <xsl:attribute name="id">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="$sKeywordsID"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$layoutInfo/keywordsLayout"/>
            </xsl:call-template>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$layoutInfo/keywordsLayout"/>
                <xsl:with-param name="bCheckPageBreakFormatInfo" select="'N'"/>
            </xsl:call-template>
            <fo:inline>
                <xsl:call-template name="OutputKeywordsLabel"/>
            </fo:inline>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$layoutInfo/keywordsLayout"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="$layoutInfo/keywordsLayout/@keywordLabelOnSameLineAsKeywords!='no'">
                    <fo:inline>
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="$layoutInfo/keywordsLayout/keywordLayout"/>
                        </xsl:call-template>
                        <xsl:call-template name="OutputKeywordsShownHere">
                            <xsl:with-param name="sTextBetweenKeywords">
                                <xsl:call-template name="GetTextBetweenKeywords">
                                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </fo:inline>
                </xsl:when>
                <xsl:otherwise>
                    <fo:block>
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="$layoutInfo/keywordsLayout/keywordLayout"/>
                        </xsl:call-template>
                        <xsl:call-template name="OutputKeywordsShownHere">
                            <xsl:with-param name="sTextBetweenKeywords">
                                <xsl:call-template name="GetTextBetweenKeywords">
                                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
    <!--  
                  OutputList
-->
    <xsl:template name="OutputList">
        <xsl:param name="bListsShareSameCode"/>
        <xsl:variable name="iLetterCount" select="count(parent::example/listWord | parent::example/listWord)"/>
        <xsl:variable name="sLetterWidth">
            <xsl:choose>
                <xsl:when test="$iLetterCount &lt; 27">1.5</xsl:when>
                <xsl:when test="$iLetterCount &lt; 53">2.5</xsl:when>
                <xsl:otherwise>3</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:block>
            <fo:table space-before="0pt">
                <xsl:call-template name="DoDebugExamples"/>
                <fo:table-column column-number="1">
                    <xsl:attribute name="column-width">
                        <xsl:value-of select="$sLetterWidth"/>em</xsl:attribute>
                </fo:table-column>
                <!--  By not specifiying a width for the second column, it appears to use what is left over 
                        (which is what we want). -->
                <fo:table-column column-number="2"/>
                <fo:table-body start-indent="0pt" end-indent="0pt">
                    <fo:table-row keep-with-next.within-page="1">
                        <xsl:if test="name()='listInterlinear'">
                            <xsl:attribute name="padding-top">
                                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                        </xsl:if>
                        <fo:table-cell text-align="start" end-indent=".2em">
                            <xsl:call-template name="DoDebugExamples"/>
                            <fo:block>
                                <xsl:attribute name="id">
                                    <xsl:value-of select="@letter"/>
                                </xsl:attribute>
                                <xsl:apply-templates select="." mode="letter"/>
                                <xsl:choose>
                                    <xsl:when test="$contentLayoutInfo/exampleLayout/@listItemsHaveParenInsteadOfPeriod='yes'">
                                        <xsl:text>)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>.</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:block>
                        </fo:table-cell>
                        <xsl:call-template name="OutputListLevelISOCode">
                            <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="name()='listInterlinear'">
                                <fo:table-cell keep-together.within-page="1">
                                    <xsl:call-template name="DoDebugExamples"/>
                                    <xsl:apply-templates select="child::node()[name()!='interlinearSource']"/>
                                </fo:table-cell>
                            </xsl:when>
                            <xsl:when test="name()='listDefinition'">
                                <fo:table-cell keep-together.within-page="1">
                                    <xsl:call-template name="DoDebugExamples"/>
                                    <fo:block>
                                        <xsl:call-template name="DoType"/>
                                        <xsl:apply-templates/>
                                    </fo:block>
                                </fo:table-cell>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="OutputWordOrSingle"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:table-row>
                    <xsl:if test="name()='listWord'">
                        <xsl:apply-templates select="word">
                            <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
                        </xsl:apply-templates>
                    </xsl:if>
                    <xsl:for-each select="following-sibling::listWord | following-sibling::listSingle | following-sibling::listInterlinear | following-sibling::listDefinition">
                        <xsl:if test="name()='listInterlinear'">
                            <!-- output a fake row to add spacing between iterlinears -->
                            <fo:table-row>
                                <fo:table-cell>
                                    <fo:block>&#xa0;</fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </xsl:if>
                        <!-- insert a new line so we don't get everything all on one line -->
                        <xsl:text>&#xa;</xsl:text>
                        <fo:table-row>
                            <fo:table-cell text-align="start" end-indent=".2em">
                                <xsl:call-template name="DoDebugExamples"/>
                                <fo:block>
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="@letter"/>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="." mode="letter"/>
                                    <xsl:choose>
                                        <xsl:when test="$contentLayoutInfo/exampleLayout/@listItemsHaveParenInsteadOfPeriod='yes'">
                                            <xsl:text>)</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>.</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </fo:block>
                            </fo:table-cell>
                            <xsl:call-template name="OutputListLevelISOCode">
                                <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
                            </xsl:call-template>
                            <xsl:choose>
                                <xsl:when test="name()='listInterlinear'">
                                    <fo:table-cell>
                                        <xsl:call-template name="DoDebugExamples"/>
                                        <xsl:apply-templates select="child::node()[name()!='interlinearSource']"/>
                                    </fo:table-cell>
                                </xsl:when>
                                <xsl:when test="name()='listDefinition'">
                                    <fo:table-cell keep-together.within-page="1">
                                        <xsl:call-template name="DoDebugExamples"/>
                                        <fo:block>
                                            <xsl:call-template name="DoType"/>
                                            <xsl:apply-templates/>
                                        </fo:block>
                                    </fo:table-cell>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="OutputWordOrSingle"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:table-row>
                        <xsl:if test="name()='listWord'">
                            <xsl:apply-templates select="word">
                                <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:for-each>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>
    <!--  
                  OutputSectionNumber
-->
    <xsl:template name="OutputSectionNumber">
        <xsl:param name="numberLayoutInfo"/>
        <xsl:param name="layoutInfo"/>
        <xsl:param name="bIsForBookmark" select="'N'"/>
        <xsl:param name="sContentsPeriod"/>
        <xsl:variable name="bAppendix">
            <xsl:for-each select="ancestor::*">
                <xsl:if test="name(.)='appendix'">Y</xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="sContentsPeriodNonBookmark">
            <xsl:if test="$layoutInfo and not($numberLayoutInfo) and $layoutInfo/sectionTitleLayout/@useperiodafternumber='yes'">
                <xsl:text>.</xsl:text>
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$bIsForBookmark='N'">
                <fo:inline>
                    <xsl:call-template name="OutputSectionNumberProper">
                        <xsl:with-param name="layoutInfo" select="$numberLayoutInfo"/>
                        <xsl:with-param name="bAppendix" select="$bAppendix"/>
                        <xsl:with-param name="sContentsPeriod" select="$sContentsPeriodNonBookmark"/>
                    </xsl:call-template>
                </fo:inline>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputSectionNumberProper">
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    <xsl:with-param name="bAppendix" select="$bAppendix"/>
                    <xsl:with-param name="sContentsPeriod" select="$sContentsPeriod"/>
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
        <xsl:param name="contentsLayoutToUse" select="$frontMatterLayoutInfo/contentsLayout"/>
        <xsl:call-template name="OutputSectionNumber">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
        <xsl:if test="$contentsLayoutToUse/@useperiodaftersectionnumber='yes'">
            <xsl:text>.</xsl:text>
        </xsl:if>
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
                  OutputTable
-->
    <xsl:template name="OutputTable">
        <!--                <fo:table space-before="0pt" keep-together.within-page="1"> -->
        <!--        <fo:table space-before="0pt" keep-together.within-page="auto">-->
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:table space-before="0pt">
            <xsl:if test="@pagecontrol='keepAllOnSamePage'">
                <xsl:attribute name="keep-together.within-page">
                    <xsl:text>1</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:call-template name="OutputBackgroundColor"/>
            <xsl:if test="descendant::example">
                <xsl:attribute name="start-indent">
                    <xsl:text>-.04in</xsl:text>
                </xsl:attribute>
                <xsl:variable name="firstRowColumns" select="tr[1]/th | tr[1]/td"/>
                <xsl:variable name="iNumCols" select="count($firstRowColumns)"/>
                <xsl:for-each select="$firstRowColumns">
                    <fo:table-column column-number="{position()}">
                        <xsl:attribute name="column-width">
                            <xsl:value-of select="number(100 div $iNumCols)"/>
                            <xsl:text>%</xsl:text>
                        </xsl:attribute>
                    </fo:table-column>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="tr/th[count(following-sibling::td)=0] | headerRow">
                <fo:table-header>
                    <xsl:call-template name="OutputTypeAttributes">
                        <xsl:with-param name="sList" select="tr[th]/@xsl-foSpecial"/>
                    </xsl:call-template>
                    <xsl:for-each select="tr[1] | headerRow">
                        <xsl:call-template name="DoType"/>
                        <xsl:call-template name="OutputBackgroundColor"/>
                    </xsl:for-each>
                    <xsl:variable name="headerRows" select="tr[th[count(following-sibling::td)=0]]"/>
                    <xsl:choose>
                        <xsl:when test="count($headerRows) != 1">
                            <xsl:for-each select="$headerRows">
                                <!-- insert a new line so we don't get everything all on one line -->
                                <xsl:text>&#xa;</xsl:text>
                                <fo:table-row>
                                    <xsl:apply-templates select="th[count(following-sibling::td)=0] | headerRow"/>
                                </fo:table-row>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="tr/th[count(following-sibling::td)=0] | headerRow"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:table-header>
            </xsl:if>
            <fo:table-body start-indent="0pt" end-indent="0pt">
                <xsl:variable name="rows" select="tr[not(th) or th[count(following-sibling::td)!=0]]"/>
                <xsl:choose>
                    <xsl:when test="$rows">
                        <xsl:apply-templates select="$rows"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:table-row>
                            <fo:table-cell border-collapse="collapse">
                                <xsl:choose>
                                    <xsl:when test="ancestor::table[1]/@border!='0' or count(ancestor::table)=1">
                                        <xsl:attribute name="padding">.2em</xsl:attribute>
                                    </xsl:when>
                                    <xsl:when test="position() &gt; 1">
                                        <xsl:attribute name="padding-left">.2em</xsl:attribute>
                                    </xsl:when>
                                </xsl:choose>
                                <fo:block>
                                    <xsl:text>(This table does not have any contents!)</xsl:text>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:table-body>
        </fo:table>
    </xsl:template>
    <!--  
                  OutputTableCells
-->
    <xsl:template name="OutputTableCells">
        <xsl:param name="sList"/>
        <xsl:param name="lang"/>
        <xsl:param name="sAlign"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
        <fo:table-cell text-align="{$sAlign}" xsl:use-attribute-sets="ExampleCell">
            <xsl:call-template name="DoDebugExamples"/>
            <fo:block>
                <!--                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="key('LanguageID',$lang)"/>
                </xsl:call-template>
                <xsl:value-of select="$sFirst"/>
                
-->
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
                <fo:inline>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',$lang)"/>
                        <xsl:with-param name="originalContext" select="$sFirst"/>
                    </xsl:call-template>
                    <fo:inline>
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
                    </fo:inline>
                </fo:inline>
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
            </fo:block>
        </fo:table-cell>
        <xsl:if test="$sRest">
            <xsl:call-template name="OutputTableCells">
                <xsl:with-param name="sList" select="$sRest"/>
                <xsl:with-param name="lang" select="$lang"/>
                <xsl:with-param name="sAlign" select="$sAlign"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--
                OutputWordOrSingle
-->
    <xsl:template name="OutputWordOrSingle">
        <xsl:choose>
            <xsl:when test="name()='listWord'">
                <xsl:call-template name="HandleLangDataGlossInWordOrListWord"/>
            </xsl:when>
            <xsl:when test="name()='word' and descendant::word or name()='word' and ancestor::word">
                <xsl:call-template name="HandleLangDataGlossInWordOrListWord"/>
            </xsl:when>
            <xsl:when test="name()='word' and descendant::word or name()='word' and ancestor::listWord">
                <xsl:call-template name="HandleLangDataGlossInWordOrListWord"/>
            </xsl:when>
            <xsl:when test="name()='listSingle'">
                <fo:table-cell xsl:use-attribute-sets="ExampleCell">
                    <xsl:call-template name="DoDebugExamples"/>
                    <fo:block>
                        <xsl:for-each select="langData | gloss | interlinearSource">
                            <xsl:apply-templates select="self::*"/>
                        </xsl:for-each>
                    </fo:block>
                </fo:table-cell>
            </xsl:when>
            <xsl:otherwise>
                <fo:block>
                    <xsl:for-each select="langData | gloss | interlinearSource">
                        <xsl:apply-templates select="self::*"/>
                        <xsl:if test="position()!=last()">
                            <fo:inline>&#xa0;&#xa0;</fo:inline>
                        </xsl:if>
                    </xsl:for-each>
                </fo:block>
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
    <!-- ===========================================================
      ELEMENTS TO IGNORE
      =========================================================== -->
    <xsl:template match="appendix/shortTitle"/>
    <xsl:template match="dd"/>
    <xsl:template match="fixedText"/>
    <xsl:template match="language"/>
    <xsl:template match="part/shortTitle"/>
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
    <xsl:include href="XLingPapFOCommon.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetCommon.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetFOBookmarks.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetFOContents.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetFOReferences.xsl"/>
</xsl:stylesheet>
