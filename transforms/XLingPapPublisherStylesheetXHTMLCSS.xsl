<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:saxon="http://icl.com/saxon">
    <xsl:import href="XLingPapCommon.xsl"/>
    <xsl:output method="text" version="1.0" encoding="utf-8" indent="no"/>
    <!-- ===========================================================
      Parameterized Variables
      =========================================================== -->
    <xsl:param name="sFOProcessor">XEP</xsl:param>
    <xsl:variable name="pageLayoutInfo" select="//publisherStyleSheet/pageLayout"/>
<!--    <xsl:variable name="contentLayoutInfo" select="//publisherStyleSheet/contentLayout"/>-->
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
    <xsl:variable name="documentLayoutInfo" select="//publisherStyleSheet/contentLayout"/>
    <xsl:variable name="iAffiliationLayouts" select="count($frontMatterLayoutInfo/affiliationLayout)"/>
    <xsl:variable name="iEmailAddressLayouts" select="count($frontMatterLayoutInfo/emailAddressLayout)"/>
    <xsl:variable name="iAuthorLayouts" select="count($frontMatterLayoutInfo/authorLayout)"/>
    <xsl:variable name="lineSpacing" select="$pageLayoutInfo/lineSpacing"/>
    <xsl:variable name="sLineSpacing" select="$lineSpacing/@linespacing"/>
    <xsl:variable name="sSinglespacingLineHeight">1.2</xsl:variable>
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
            <xsl:when test="$sFOProcessor='XEP'">
                <!-- units are ems so the font and font size can be taken into account -->
                <xsl:text>2.75</xsl:text>
            </xsl:when>
            <xsl:when test="$sFOProcessor='XFC'">
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
    <xsl:variable name="iAbbreviationCount" select="count(//abbrRef)"/>
    <xsl:variable name="bEndnoteRefIsDirectLinkToEndnote" select="'Y'"/>
    <!-- ===========================================================
      MAIN BODY
      =========================================================== -->
    <xsl:template match="/xlingpaper">
        <xsl:text>/* Cascading Style Sheet generated by XLingPapPublisherStlesheetXHMTLCSS version </xsl:text>
        <xsl:value-of select="$sVersion"/>
        <xsl:text> */
body {</xsl:text>
        <xsl:if test="$pageLayoutInfo/@ignorePageWidthForWebPageOutput != 'yes'">
            <xsl:text>
     padding-left:</xsl:text>
            <xsl:value-of select="$sPageInsideMargin"/>
            <xsl:text>;
     padding-right:</xsl:text>
            <xsl:value-of select="$sPageOutsideMargin"/>
            <xsl:text>;
     width:</xsl:text>
            <xsl:value-of select="number($iPageWidth - $iPageOutsideMargin - $iPageInsideMargin)"/>
            <xsl:text>pt;</xsl:text>
        </xsl:if>
        <xsl:text>
     font-family:"</xsl:text>
        <xsl:value-of select="$sDefaultFontFamily"/>
        <xsl:text>";
    font-size:</xsl:text>
        <xsl:value-of select="$sBasicPointSize"/>
        <xsl:text>pt;
}
</xsl:text>
        <xsl:if test="//landscape or //appendix[@showinlandscapemode='yes']">
            <xsl:text>.landscape {
       width:8.5in;
       border-top:1.5pt solid gray;
       border-bottom:1.5pt solid gray;
}
</xsl:text>
        </xsl:if>
        <xsl:apply-templates select="//framedType"/>
        <xsl:text>.footnote{
    font-size:</xsl:text>
        <xsl:value-of select="$sFootnotePointSize"/>
        <xsl:text>pt;
</xsl:text>
        <xsl:call-template name="DoSingleSpacing">
            <xsl:with-param name="useSingleSpacing" select="$lineSpacing/@singlespaceendnotes"/>
        </xsl:call-template>
        <xsl:text>}
.paragraph_indent {
text-indent:</xsl:text>
        <xsl:value-of select="$sParagraphIndent"/>
        <xsl:text>;
}
.dt {
        font-weight:bold;
}
li.disc {
    list-style-type:disc;
}
li.decimal {
    list-style-type:decimal;
}
li.lower-alpha {
    list-style-type:lower-alpha;
}
li.lower-roman {
    list-style-type:lower-roman;
}
.figureAlignLeft {
        text-align:left;
}
.figureAlignCenter {
        text-align:center;
}
.figureAlignRight {
        text-align:right;
}
.index {
        margin-left: 0.5in;
        margin-right: 0.5in;
}
.indexMainTerm {
        font-weight:bold;
}
.source {
        text-align:center;
        font-style:italic;
}
.interlinearLineTitle {
        font-size:smaller;
        font-weight:bold
}
.tableAlignLeft {
        text-align:left;
}
.tableAlignCenter {
        text-align:center;
}
.tableAlignRight {
        text-align:right;
}
.textTitle {
        text-align:center;
        font-size:larger;
        font-weight:bold;
}

</xsl:text>
        <xsl:apply-templates select="styledPaper"/>
        <!--  We are not using CSS classes for the contents information because there are any number of
         section1, etc. items which can be embeded under appendix/nothing, etc. and it gets complicated quickly.
    <xsl:apply-templates select="styledPaper/lingPaper" mode="contents"/>
        -->
<!--        <xsl:variable name="fonts" select="//@font-family"/>
        Need following to embed a font in EPUB:
        <xsl:text>
@font-face {
    font-family: "Charis SIL", serif;
    font-weight: bold;
    font-style:normal;
    src:url(../../../../../Windows/Fonts/CharisSILB.ttf);
}
        </xsl:text>
        <xsl:for-each select="$fonts">
            <xsl:sort select="."/>
            
        </xsl:for-each>-->
    </xsl:template>
    <!--
        abbrRefLinkLayout
    -->
    <xsl:template match="abbrRefLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        abbreviations
    -->
    <xsl:template match="abbreviations">
        <xsl:text>.abbreviations {
</xsl:text>
        <xsl:apply-templates select="@*"/>
        <xsl:text>}
</xsl:text>
        <xsl:text>.abbreviationsNoFontFamily {
</xsl:text>
        <xsl:apply-templates select="@*[name()!='font-family']"/>
<xsl:text>}
</xsl:text>
    </xsl:template>
    <!-- 
        abstractLayout
    -->
    <xsl:template match="abstractLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sAbstract"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        abstractTextFontLayout
    -->
    <xsl:template match="abstractTextFontInfo">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sAbstractText"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        acknowledgementsLayout
    -->
    <xsl:template match="acknowledgementsLayout">
        <xsl:variable name="acknowledgementsName">
            <xsl:call-template name="CreateCSSName">
                <xsl:with-param name="sBase">
                        <xsl:call-template name="GetLayoutClassNameToUse">
                            <xsl:with-param name="sType" select="$sAcknowledgements"/>
                        </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="sLayout" select="parent::*"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="$acknowledgementsName"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        affilationLayout
    -->
    <xsl:template match="affiliationLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sAffiliation"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        appendixRefLinkLayout
    -->
    <xsl:template match="appendixRefLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        appendicesTitlePageLayout
    -->
    <xsl:template match="appendicesTitlePageLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sAppendicesTitlePage"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        appendixTitleLayout
    -->
    <xsl:template match="appendixTitleLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sAppendixTitle"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        authorLayout
    -->
    <xsl:template match="authorLayout">
        <xsl:variable name="sClassName">
            <xsl:call-template name="GetAuthorLayoutClassNameToUse"/>
        </xsl:variable>
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="$sClassName"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        backMatterLayout
    -->
    <xsl:template match="backMatterLayout">
        <xsl:apply-templates/>
        <xsl:if test="not(useEndNotesLayout)">
            <!-- if the style sheet does not use endnotes explicitly, do it anyway; we'll guess that there are references and use that layout -->
            <xsl:for-each select="referencesTitleLayout">
                <xsl:call-template name="OutputTitleFormatInfo">
                    <xsl:with-param name="name" select="'endnotesTitle'"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <!-- 
        chapterTitleLayout
    -->
    <xsl:template match="chapterTitleLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sChapterTitle"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        citationLinkLayout
    -->
    <xsl:template match="citationLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        contentsLayout
    -->
    <xsl:template match="contentsLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sContents"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        contentsLinkLayout
    -->
    <xsl:template match="contentsLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        dateLayout
    -->
    <xsl:template match="dateLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sDate"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        emailAddressLayout
    -->
    <xsl:template match="emailAddressLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sEmailAddress"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        endnoteRefLayout
    -->
    <xsl:template match="endnoteRefLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'endnoteRefLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        endnoteRefLinkLayout
    -->
    <xsl:template match="endnoteRefLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        exampleLayout
    -->
    <xsl:template match="exampleLayout">
        <xsl:text>.example</xsl:text>
        <xsl:text>{
</xsl:text>
        <xsl:apply-templates select="@*[name()!='referencesUseParens']"/>
        <xsl:call-template name="DoSingleSpacing">
            <xsl:with-param name="useSingleSpacing" select="$lineSpacing/@singlespaceexamples"/>
        </xsl:call-template>
        <xsl:text>}
</xsl:text>
        <xsl:apply-templates select="@referencesUseParens"/>
    </xsl:template>
    <!--
        exampleRefLinkLayout
    -->
    <xsl:template match="exampleRefLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        figureCaptionLayout
    -->
    <xsl:template match="figureCaptionLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'figureCaptionLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        figureLabelLayout
    -->
    <xsl:template match="figureLabelLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'figureLabelLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        figureNumberLayout
    -->
    <xsl:template match="figureNumberLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'figureNumberLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        figureRefCaptionLayout
    -->
    <xsl:template match="figureRefCaptionLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'figureRefCaptionLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        figureRefLayout
    -->
    <xsl:template match="figureRefLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'figureRefLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        figureRefLinkLayout
    -->
    <xsl:template match="figureRefLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        framedType
    -->
    <xsl:template match="framedType">
        <xsl:variable name="sCssTypeName">
            <xsl:text>
.framedType</xsl:text>
            <xsl:value-of select="@id"/>
        </xsl:variable>
        <xsl:value-of select="$sCssTypeName"/>
        <xsl:text>{
        </xsl:text>
        <xsl:variable name="framedtype" select="."/>
        <xsl:text>background-color:</xsl:text>
        <xsl:call-template name="SetFramedTypeItem">
            <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@backgroundcolor)"/>
            <xsl:with-param name="sDefaultValue" select="'white'"/>
        </xsl:call-template>
        <xsl:text>;
            margin-top:</xsl:text>
        <xsl:call-template name="SetFramedTypeItem">
            <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@spacebefore)"/>
            <xsl:with-param name="sDefaultValue" select="'.125in'"/>
        </xsl:call-template>
        <xsl:text>;
            margin-bottom:</xsl:text>
        <xsl:call-template name="SetFramedTypeItem">
            <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@spaceafter)"/>
            <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
        </xsl:call-template>
        <xsl:text>;
            margin-left:</xsl:text>
        <xsl:call-template name="SetFramedTypeItem">
            <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@indent-before)"/>
            <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
        </xsl:call-template>
        <xsl:text>;
            margin-right:</xsl:text>
        <xsl:call-template name="SetFramedTypeItem">
            <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@indent-after)"/>
            <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
        </xsl:call-template>
        <xsl:text>;
            padding-top:</xsl:text>
        <xsl:call-template name="SetFramedTypeItem">
            <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@innertopmargin)"/>
            <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
        </xsl:call-template>
        <xsl:text>;
            padding-bottom:</xsl:text>
        <xsl:call-template name="SetFramedTypeItem">
            <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@innerbottommargin)"/>
            <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
        </xsl:call-template>
        <xsl:text>;
            padding-left:</xsl:text>
        <xsl:call-template name="SetFramedTypeItem">
            <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@innerleftmargin)"/>
            <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
        </xsl:call-template>
        <xsl:text>;
            padding-right:</xsl:text>
        <xsl:call-template name="SetFramedTypeItem">
            <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@innerrightmargin)"/>
            <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
        </xsl:call-template>
        <xsl:text>;
            text-align:</xsl:text>
        <xsl:call-template name="SetFramedTypeItem">
            <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@align)"/>
            <xsl:with-param name="sDefaultValue">left</xsl:with-param>
        </xsl:call-template>
        <xsl:text>;
            border-width:1px;
            border-style:solid;
            border-color:black;
</xsl:text>
        <xsl:text>}
        </xsl:text>
    </xsl:template>
    <!-- 
        freeLayout
    -->
    <xsl:template match="freeLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'freeLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        frontMatterLayout
    -->
    <xsl:template match="frontMatterLayout">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
        genericRefLinkLayout
    -->
    <xsl:template match="genericRefLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        glossaryLayout
    -->
    <xsl:template match="glossaryLayout">
        <xsl:variable name="sPos">
            <xsl:choose>
                <xsl:when test="preceding-sibling::glossaryLayout or following-sibling::glossaryLayout">
                    <xsl:value-of select="count(preceding-sibling::glossaryLayout)+1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>                  
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="concat($sGlossary,$sPos)"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
        glossaryTermRefLinkLayout
    -->
    <xsl:template match="glossaryTermRefLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        glossaryTerms
    -->
    <xsl:template match="glossaryTerms">
        <xsl:text>.glossaryTerms {
</xsl:text>
        <xsl:apply-templates select="@*"/>
<xsl:text>}
</xsl:text>
        <xsl:text>.glossaryTermsNoFontFamily {
</xsl:text>
        <xsl:apply-templates select="@*[name()!='font-family']"/>
<xsl:text>}
</xsl:text>
    </xsl:template>
    
    
    <!-- 
        glossInExampleLayout
    -->
    <xsl:template match="glossInExampleLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'glossInExampleLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        glossInListTableLayout
    -->
    <xsl:template match="glossInListWordLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'glossInListWordLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        glossInProseLayout
    -->
    <xsl:template match="glossInProseLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'glossInProseLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        glossInTableLayout
    -->
    <xsl:template match="glossInTableLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'glossInTableLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        indexLayout
    -->
    <xsl:template match="indexLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'indexTitle'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        indexLinkLayout
    -->
    <xsl:template match="indexLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        interlinearRefCitationTitleLayout
    -->
    <xsl:template match="interlinearRefCitationTitleLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'interlinearRefCitationTitleLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        interlinearRefLinkLayout
    -->
    <xsl:template match="interlinearRefLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        interlinearSourceStyle
    -->
    <xsl:template match="interlinearSourceStyle">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'interlinearSourceStyle'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        iso639-3CodesLinkLayout
    -->
    <xsl:template match="iso639-3CodesLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        keywordsLayout
    -->
    <xsl:template match="keywordsLayout">
        <xsl:variable name="keywordsName">
            <xsl:call-template name="CreateCSSName">
                <xsl:with-param name="sBase">
                    <xsl:call-template name="GetLayoutClassNameToUse">
                        <xsl:with-param name="sType" select="$sKeywords"/>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="sLayout" select="parent::*"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="$keywordsName"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        langDataInExampleLayout
    -->
    <xsl:template match="langDataInExampleLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'langDataInExampleLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        langDataInProseLayout
    -->
    <xsl:template match="langDataInProseLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'langDataInProseLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        langDataInTableLayout
    -->
    <xsl:template match="langDataInTableLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'langDataInTableLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        language
    -->
    <xsl:template match="language">
        <xsl:text>.language</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>{
</xsl:text>
        <xsl:apply-templates select="@*"/>
        <xsl:text>}
</xsl:text>
    </xsl:template>
    <!-- 
        lingPaper
    -->
    <xsl:template match="lingPaper">
        <xsl:apply-templates select="backMatter/abbreviations"/>
        <xsl:apply-templates select="backMatter/glossaryTerms"/>
        <xsl:apply-templates select="languages"/>
        <xsl:apply-templates select="types"/>
    </xsl:template>
    <!--
        linkLinkLayout
    -->
    <xsl:template match="linkLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        literalLayout
    -->
    <xsl:template match="literalContentLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'literalContentLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        numberLayout
    -->
    <xsl:template match="numberLayout">
        <xsl:variable name="numberName">
            <xsl:call-template name="CreateCSSName">
                <xsl:with-param name="sBase">
                    <xsl:call-template name="GetLayoutClassNameToUse">
                        <xsl:with-param name="sType" select="$sNumber"/>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="sLayout" select="parent::*"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="$numberName"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        pageLayout
    -->
    <xsl:template match="pageLayout">
        <!-- TO DO if we ever want to try and use Prince XML to convert the output to PDF
            <xsl:text>@page {
        counter-increment: page;
        size: </xsl:text>
        <xsl:value-of select="pageWidth"/>
        <xsl:text>&#x20;</xsl:text>
        <xsl:value-of select="pageHeight"/>
        <xsl:text>;
        margin: </xsl:text>
        <xsl:value-of select="pageTopMargin"/>
        <xsl:text>&#x20;</xsl:text>
        <xsl:value-of select="pageOutsideMargin"/>
        <xsl:text>&#x20;</xsl:text>
        <xsl:value-of select="pageBottomMargin"/>
        <xsl:text>&#x20;</xsl:text>
        <xsl:value-of select="pageInsideMargin"/>
        <xsl:text>;
</xsl:text>

    @top-left {
    content: string(guideword, first);
    direction: ltr;
    font-family: "Charis SIL AmArea", sans-serif;   /* default Sans-Serif font */
    font-weight: bold;
    font-size: 12pt;
    margin-top: 1em;
    }
    @top-center {
    content: counter(page);
    margin-top: 1em
    }
    @top-right {
    content: string(guideword, last);
    direction: ltr;
    font-family: "Charis SIL AmArea", sans-serif;   /* default Sans-Serif font */
    font-weight: bold;
    font-size: 12pt;
    margin-top: 1em;
    }
    }
    @page :first {
    @top-left { content: ''; }
    @top-center { content: ''; }
    @top-right { content: ''; }
    }
    
    
    @page:left {
    counter-increment: page;
    margin: 1in 1in 1in .75in;
    @top-left {
    content: flow(guidewordwithhomographnumberleft, first);
    direction: ltr;
    font-family: "Charis SIL Compact", sans-serif;
    /* default Sans-Serif font */    
    font-weight: bold;
    font-size: 11pt;
    margin-top: 1em;
    }
    @top-center {
    font-size: 11pt;
    content:"VERNACULAR-ANALYSIS";
    }
    @top-right {
    font-family: "Charis SIL Compact", sans-serif;
    content: counter(page);
    font-weight:normal;
    font-size: 11pt;
    margin-top: 1em
    }
    @bottom-center {
    font-size: 10pt;
    content:"Borrador (date)";
    }
    }
    
    @page:right {
    counter-increment: page;
    margin: 1in .75in 1in 1in;
    @top-left {
    font-family: "Charis SIL Compact", sans-serif;
    font-weight:normal;
    content: counter(page);
    font-size: 11pt;
    margin-top: 1em
    }
    @top-center {
    font-size: 11pt;
    content:"VERNACULAR-ANALYSIS";
    }
    @top-right {
    content: flow(guidewordwithhomographnumberright, last);
    direction: ltr;
    font-family: "Charis SIL Compact", sans-serif;
    /* default Sans-Serif font */    
    font-weight: bold;
    font-size: 11pt;
    margin-top: 1em;
    }
    @bottom-center {
    font-size: 10pt;
    content:"Borrador (date)";
    }
    }

        <xsl:text>}
</xsl:text>
        -->
        <xsl:text>.paragraph {
        text-indent:</xsl:text>
        <xsl:value-of select="paragraphIndent"/>
        <xsl:text>;
}
.blockquote {
        margin-left:</xsl:text>
        <xsl:value-of select="blockQuoteIndent"/>
        <xsl:text>;
        margin-right:</xsl:text>
        <xsl:value-of select="blockQuoteIndent"/>
        <xsl:text>;
</xsl:text>
        <xsl:call-template name="DoSingleSpacing">
            <xsl:with-param name="useSingleSpacing" select="$lineSpacing/@singlespaceblockquotes"/>
        </xsl:call-template>
        <xsl:variable name="sSpaceBefore" select="normalize-space($documentLayoutInfo/blockQuoteLayout/@spacebefore)"/>
        <xsl:if test="string-length($sSpaceBefore)&gt;0">
            <xsl:text>;
                padding-top:</xsl:text>                
            <xsl:value-of select="$sSpaceBefore"/>
        </xsl:if>
        <xsl:variable name="sSpaceAfter" select="normalize-space($documentLayoutInfo/blockQuoteLayout/@spaceafter)"/>
        <xsl:if test="string-length($sSpaceAfter)&gt;0">
            <xsl:text>;
                padding-bottom:</xsl:text>                
            <xsl:value-of select="$sSpaceAfter"/>
        </xsl:if>
        <xsl:text>}
</xsl:text>
        <xsl:apply-templates select="linkLayout"/>
    </xsl:template>
    <!-- 
        partTitleLayout
    -->
    <xsl:template match="partTitleLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'partTitle'"/>
        </xsl:call-template>
        <xsl:text>.partContents {
        margin-top:</xsl:text>
        <xsl:value-of select="$sBasicPointSize"/>
        <xsl:text>pt;
</xsl:text>
        <xsl:text>        margin-bottom:</xsl:text>
        <xsl:value-of select="$sBasicPointSize"/>
        <xsl:text>pt;
        text-align:center;
}
</xsl:text>
    </xsl:template>
    <!-- 
        prefaceLayout
    -->
    <xsl:template match="prefaceLayout">
        <xsl:variable name="sPos">
            <xsl:choose>
                <xsl:when test="preceding-sibling::prefaceLayout or following-sibling::prefaceLayout">
                    <xsl:value-of select="count(preceding-sibling::prefaceLayout)+1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>                 
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="concat($sPreface,$sPos)"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        presentedAtLayout
    -->
    <xsl:template match="presentedAtLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sPresentedAt"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        prose-textTextLayout
    -->
    <xsl:template match="prose-textTextLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'prose-text'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        referencesLayout
    -->
    <xsl:template match="referencesLayout">
        <xsl:text>.references {
</xsl:text>
        <xsl:variable name="defaultFontSize" select="normalize-space(@defaultfontsize)"/>
        <xsl:if test="string-length($defaultFontSize) &gt; 0">
            <xsl:text>        font-size:</xsl:text>
            <xsl:choose>
                <xsl:when test="normalize-space(string-length($contentLayoutInfo/magnificationFactor)) &gt; 0">
                    <xsl:value-of select="number($contentLayoutInfo/magnificationFactor * substring($defaultFontSize,1,string-length($defaultFontSize)-2))"/>
                    <xsl:value-of select="substring($defaultFontSize,string-length($defaultFontSize)-1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$defaultFontSize"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>;
</xsl:text>
        </xsl:if>
        <xsl:variable name="hangingIndentSize" select="normalize-space(@hangingindentsize)"/>
        <xsl:if test="string-length($hangingIndentSize) &gt; 0">
            <xsl:text>        text-indent:-</xsl:text>
            <xsl:value-of select="$hangingIndentSize"/>
            <xsl:text>;
</xsl:text>
            <xsl:text>        padding-left:</xsl:text>
            <xsl:value-of select="$hangingIndentSize"/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
        <xsl:text>}
        </xsl:text>
        <xsl:if test="//annotationRef">
<xsl:text>
.annotationRef {
</xsl:text>
        <xsl:if test="string-length($hangingIndentSize) &gt; 0">
            <xsl:text>        text-indent:-</xsl:text>
            <xsl:value-of select="$hangingIndentSize"/>
            <xsl:text>;
</xsl:text>
            <xsl:text>        padding-left:</xsl:text>
            <xsl:value-of select="$hangingIndentSize"/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
        <xsl:text>}
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        referencesTitleLayout
    -->
    <xsl:template match="referencesTitleLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sReferencesTitle"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        sectionLayouts
    -->
    <xsl:template match="section1Layout | section2Layout | section3Layout | section4Layout | section5Layout | section6Layout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="substring-before(name(),'Layout')"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- 
        sectionRefLayout
    -->
    <xsl:template match="sectionRefLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'sectionRef'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        sectionRefLinkLayout
    -->
    <xsl:template match="sectionRefLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        sectionRefTitleLayout
    -->
    <xsl:template match="sectionRefTitleLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'sectionRefTitle'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        sectionTitleLayout
    -->
    <xsl:template match="sectionTitleLayout">
        <xsl:variable name="sectionTitleName">
            <xsl:call-template name="CreateCSSName">
                <xsl:with-param name="sBase" select="'sectionTitle'"/>
                <xsl:with-param name="sLayout" select="parent::*"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="$sectionTitleName"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        subtitleLayout
    -->
    <xsl:template match="subtitleLayout">
        <xsl:variable name="subtitleName">
            <xsl:call-template name="CreateSubtitleCSSName"/>
        </xsl:variable>
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="$subtitleName"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        tablenumberedCaptionLayout
    -->
    <xsl:template match="tablenumberedCaptionLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'tablenumberedCaptionLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        tablenumberedLabelLayout
    -->
    <xsl:template match="tablenumberedLabelLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'tablenumberedLabelLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        tablenumberedNumberLayout
    -->
    <xsl:template match="tablenumberedNumberLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'tablenumberedNumberLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        tablenumberedRefCaptionLayout
    -->
    <xsl:template match="tablenumberedRefCaptionLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'tablenumberedRefCaptionLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        tablenumberedRefLayout
    -->
    <xsl:template match="tablenumberedRefLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'tablenumberedRefLayout'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        tablenumberedRefLinkLayout
    -->
    <xsl:template match="tablenumberedRefLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        titleLayout
    -->
    <xsl:template match="textTitle">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'textTitle'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        titleLayout
    -->
    <xsl:template match="titleLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'title'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        type
    -->
    <xsl:template match="type">
        <xsl:variable name="sCssTypeName">
            <xsl:text>.type</xsl:text>
            <xsl:value-of select="@id"/>
        </xsl:variable>
        <xsl:value-of select="$sCssTypeName"/>
        <xsl:text>{
</xsl:text>
        <xsl:apply-templates select="@*"/>
        <xsl:text>}
</xsl:text>
        <!-- cannot use before and after pseudo elements because Internet Explorer does not handle them (sigh).
    <xsl:if test="string-length(@before)&gt;0">
            <xsl:value-of select="$sCssTypeName"/>
            <xsl:text>:before {
     content: "</xsl:text>
            <xsl:value-of select="@before"/>
            <xsl:text>" }
</xsl:text>
        </xsl:if>
        <xsl:if test="string-length(@after)&gt;0">
            <xsl:value-of select="$sCssTypeName"/>
            <xsl:text>:after {
     content: "</xsl:text>
            <xsl:value-of select="@after"/>
            <xsl:text>" }
</xsl:text>
        </xsl:if>
-->
    </xsl:template>
    <!--
        urlLinkLayout
    -->
    <xsl:template match="urlLinkLayout">
        <xsl:call-template name="OutputLinkAttributes">
            <xsl:with-param name="override" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        useEndNotesLayout
    -->
    <xsl:template match="useEndNotesLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'endnotesTitle'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        versionLayout
    -->
    <xsl:template match="versionLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name">
                <xsl:call-template name="GetLayoutClassNameToUse">
                    <xsl:with-param name="sType" select="$sVersionCSS"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        publishingBlurbLayout
    -->
    <xsl:template match="publishingBlurbLayout">
        <xsl:call-template name="OutputTitleFormatInfo">
            <xsl:with-param name="name" select="'publishingBlurb'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- ===========================================================
        Attribute templates
        =========================================================== -->
    <!-- 
        @backgroundcolor
    -->
    <xsl:template match="@backgroundcolor">
        <xsl:if test="string-length(normalize-space(.)) &gt; 0">
            <xsl:text>        background-color:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @color
    -->
    <xsl:template match="@color">
        <xsl:if test="string-length(normalize-space(.)) &gt; 0">
            <xsl:text>        color:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @cssSpecial
    -->
    <xsl:template match="@cssSpecial">
        <xsl:text>        </xsl:text>
        <xsl:variable name="sCssSpecial" select="normalize-space(.)"/>
        <xsl:choose>
            <xsl:when test="substring($sCssSpecial, string-length($sCssSpecial))=';'">
                <xsl:value-of select="substring($sCssSpecial, 1, string-length($sCssSpecial)-1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sCssSpecial"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>;
</xsl:text>
    </xsl:template>
    <xsl:template match="@decoration">
        <xsl:if test="string-length(normalize-space(.)) &gt; 0">
            <xsl:text>        text-decoration:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @end-indent
    -->
    <xsl:template match="@end-indent">
        <xsl:if test="string-length(.) &gt; 0">
            <xsl:text>        margin-right:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @font-family
    -->
    <xsl:template match="@font-family">
        <xsl:if test="string-length(normalize-space(.)) &gt; 0">
            <xsl:text>        font-family:"</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>";
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @font-size
    -->
    <xsl:template match="@font-size">
        <xsl:if test="string-length(normalize-space(.)) &gt; 0">
            <xsl:text>        font-size:</xsl:text>
            <xsl:call-template name="AdjustFontSizePerMagnification">
                <xsl:with-param name="sFontSize" select="."/>
            </xsl:call-template>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @font-style
    -->
    <xsl:template match="@font-style">
        <xsl:if test="string-length(normalize-space(.)) &gt; 0">
            <xsl:text>        font-style:</xsl:text>
            <xsl:choose>
                <xsl:when test=".='backslant' or .='oblique'">
                    <xsl:text>italic</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>        
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @font-variant
    -->
    <xsl:template match="@font-variant">
        <xsl:if test="string-length(normalize-space(.)) &gt; 0">
            <xsl:text>        font-variant:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @font-weight
    -->
    <xsl:template match="@font-weight">
        <xsl:if test="string-length(normalize-space(.)) &gt; 0">
            <xsl:text>        font-weight:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="@text-transform">
        <xsl:if test="string-length(normalize-space(.)) &gt; 0">
            <xsl:text>        text-transform:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @indent-after
    -->
    <xsl:template match="@indent-after">
        <xsl:if test="string-length(.) &gt; 0">
            <xsl:text>        margin-right:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @indent-before
    -->
    <xsl:template match="@indent-before">
        <xsl:if test="string-length(.) &gt; 0">
            <xsl:text>        margin-left:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @pagebreakbefore
    -->
    <xsl:template match="@pagebreakbefore | @startonoddpage | @linebefore">
        <xsl:if test=".='yes'">
            <xsl:text>        border-top:1.5pt solid gray;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @referencesUseParens
    -->
    <xsl:template match="@referencesUseParens">
        <!-- cannot use before and after pseudo elements because Internet Explorer does not handle them (sigh).
            <xsl:if test=".!='no'">
            <xsl:text>.exampleRef:before {
        content:"(";
}
.exampleRef:after {
        content:")";
}
</xsl:text>
        </xsl:if>
    -->
    </xsl:template>
    <!-- 
        @spaceafter
    -->
    <xsl:template match="@spaceafter">
        <xsl:if test="string-length(.) &gt; 0">
            <xsl:text>        padding-bottom:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @spacebefore
    -->
    <xsl:template match="@spacebefore">
        <xsl:if test="string-length(.) &gt; 0">
            <xsl:text>        padding-top:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @spaceBetweenFigureAndCaption
    -->
    <xsl:template match="@spaceBetweenFigureAndCaption">
        <xsl:if test="string-length(.) &gt; 0">
            <xsl:text>        padding-</xsl:text>
            <xsl:choose>
                <xsl:when test="$contentLayoutInfo/figureLayout/@captionLocation='after'">top:</xsl:when>
                <xsl:otherwise>bottom:</xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @start-indent
    -->
    <xsl:template match="@start-indent">
        <xsl:if test="string-length(.) &gt; 0">
            <xsl:text>        margin-left:</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        @ textalign
    -->
    <xsl:template match="@textalign">
        <xsl:text>        text-align:</xsl:text>
        <xsl:choose>
            <xsl:when test=".='left' or .='start'">
                <!-- TO DO: handle right-to-left -->
                <xsl:text>left;
</xsl:text>
            </xsl:when>
            <xsl:when test=".='right' or .='end'">
                <!-- TO DO: handle right-to-left -->
                <xsl:text>right;
</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>center;
</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        @usesmallcaps
    -->
    <xsl:template match="@usesmallcaps">
        <xsl:text>        font-variant:</xsl:text>
        <xsl:choose>
            <xsl:when test=".='yes'">
                <xsl:text>small-caps</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>normal</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>;
</xsl:text>
    </xsl:template>
    <!-- ===========================================================
        Attribute and element templates to ignore
        =========================================================== -->
    <xsl:template match="@AddPeriodAfterFinalDigit"/>
    <xsl:template match="@after"/>
    <xsl:template match="@authorform"/>
    <xsl:template match="@before"/>
    <xsl:template match="@beginsparagraph"/>
    <xsl:template match="@betweentitleandnumber"/>
    <xsl:template match="@captionLocation"/>
    <xsl:template match="@chapterlabel"/>
    <xsl:template match="@chapterlineindent"/>
    <xsl:template match="@dateIndentAuthorOverDateStyle"/>
    <xsl:template match="@dateToEntrySpaceAuthorOverDateStyle"/>
    <xsl:template match="@doubleColumnSeparation"/>
    <xsl:template match="@useAuthorOverDateStyle"/>
    <xsl:template match="@ethnCode"/>
    <xsl:template match="@exampleNumberMaxWidthInEms"/>
    <xsl:template match="@firstParagraphHasIndent"/>
    <xsl:template match="@fontissmallcaps"/>
    <xsl:template match="@format"/>
    <xsl:template match="@hyphenationExceptionsFile"/>
    <xsl:template match="@id"/>
    <xsl:template match="@ignore"/>
    <xsl:template match="@indentchapterline"/>
    <xsl:template match="@interlinearsourcestyle"/>
    <xsl:template match="@ISO639-3Code"/>
    <xsl:template match="@keywordLabelOnSameLineAsKeywords"/>
    <xsl:template match="@label"/>
    <xsl:template match="@leaderlength"/>
    <xsl:template match="@leaderpattern"/>
    <xsl:template match="@leaderwidth"/>
    <xsl:template match="@linkpagenumber"/>
    <xsl:template match="@linktitle"/>
    <xsl:template match="@listItemsHaveParenInsteadOfPeriod"/>
    <xsl:template match="@name"/>
    <xsl:template match="@numberProperAddPeriodAfterFinalDigit"/>
    <xsl:template match="@numberProperUseParens"/>
    <xsl:template match="@ORCID"/>
    <xsl:template match="@removecommonhundredsdigitsinpages"/>
    <xsl:template match="@rtl"/>
    <xsl:template match="@ruleabovelength"/>
    <xsl:template match="@ruleabovepattern"/>
    <xsl:template match="@ruleabovewidth"/>
    <xsl:template match="@rulebelowlength"/>
    <xsl:template match="@rulebelowpattern"/>
    <xsl:template match="@rulebelowwidth"/>
    <xsl:template match="@showappendices"/>
    <xsl:template match="@showAsFootnoteAtEndOfAbstract"/>
    <xsl:template match="@showbookmarks"/>
    <xsl:template match="@showchapternumber"/>
    <xsl:template match="@showChapterNumberBeforeExampleNumber"/>
    <xsl:template match="@showInHeader"/>
    <xsl:template match="@showletter"/>
    <xsl:template match="@showmarking"/>
    <xsl:template match="@showNumber"/>
    <xsl:template match="@showpagenumber"/>
    <xsl:template match="@showsectionsinappendices"/>
    <xsl:template match="@singlespaceeachcontentline"/>
    <xsl:template match="@spacebeforemainsection"/>
    <xsl:template match="@spaceBetweenEntriesAuthorOverDateStyle"/>
    <xsl:template match="@spaceBetweenEntryAndAuthorInAuthorOverDateStyle"/>
    <xsl:template match="@spaceBetweenUnits"/>
    <xsl:template match="@startNumberingOverAtEachChapter"/>
    <xsl:template match="@startSection1NumberingAtZero"/>
    <xsl:template match="@textafterletter"/>
    <xsl:template match="@textafternumber"/>
    <xsl:template match="@textbeforeafterusesfontinfo"/>
    <xsl:template match="@textBeforeCapitalizedPluralOverride"/>
    <xsl:template match="@textBeforeCapitalizedSingularOverride"/>
    <xsl:template match="@textBeforePluralOverride"/>
    <xsl:template match="@textBeforeSingularOverride"/>
    <xsl:template match="@textbetweenchapterandnumber"/>
    <xsl:template match="@textBetweenChapterNumberAndExampleNumber"/>
    <xsl:template match="@textBetweenKeywords"/>
    <xsl:template match="@titleform"/>
    <xsl:template match="@types"/>
    <xsl:template match="@useappendixlabelbeforeappendixletter"/>
    <xsl:template match="@useblankextrapage"/>
    <xsl:template match="@usechapterlabelbeforechapters"/>
    <xsl:template match="@usecitationformatwhennumberofsharedpaperis"/>
    <xsl:template match="@useDoubleColumns"/>
    <xsl:template match="@useemptyheaderfooter"/>
    <xsl:template match="@useEqualSignsColumn"/>
    <xsl:template match="@useLabel"/>
    <xsl:template match="@uselineforrepeatedauthor"/>
    <xsl:template match="@useperiodafterappendixletter"/>
    <xsl:template match="@useperiodafterchapternumber"/>
    <xsl:template match="@useperiodafternumber"/>
    <xsl:template match="@useperiodaftersectionnumber"/>
    <xsl:template match="@usetitleinheader"/>
    <xsl:template match="@version"/>
    <xsl:template match="@verticalfillafter"/>
    <xsl:template match="@verticalfillbefore"/>
    <xsl:template match="@XeLaTeXSpecial"/>
    <xsl:template match="@xsl-foSpecial"/>
    <xsl:template match="hangingIndentInitialIndent"/>
    <xsl:template match="hangingIndentNormalIndent"/>
    <xsl:template match="langName"/>
    <xsl:template match="literalLabelLayout"/>
    <!--
        AddAnyLinkAttributes
    -->
    <xsl:template name="OutputLinkAttributes">
        <xsl:param name="override"/>
        <xsl:variable name="sOverrideColor" select="$override/@color"/>
        <xsl:variable name="sOverrideDecoration" select="$override/@decoration"/>
        <xsl:text>.</xsl:text>
        <xsl:value-of select="name($override)"/>
        <xsl:text> {
</xsl:text>
        <xsl:choose>
            <xsl:when test="$override/@showmarking='yes'">
                <xsl:choose>
                    <xsl:when test="$sOverrideColor != 'default'">
                        <xsl:text>        color:</xsl:text>
                        <xsl:value-of select="$sOverrideColor"/>
                        <xsl:text>;
</xsl:text>
                    </xsl:when>
                    <xsl:when test="string-length($sLinkColor) &gt; 0">
                        <xsl:text>        color:</xsl:text>
                        <xsl:value-of select="$sLinkColor"/>
                        <xsl:text>;
</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>        color:inherit;
</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$sOverrideDecoration != 'default'">
                        <xsl:text>        text-decoration:</xsl:text>
                        <xsl:value-of select="$sOverrideDecoration"/>
                        <xsl:text>;
</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>        text-decoration:</xsl:text>
                        <xsl:value-of select="$sLinkTextDecoration"/>
                        <xsl:text>;
</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>        color:inherit;
        text-decoration:none;
</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}
</xsl:text>
    </xsl:template>
    <!--  
        AdjustFontSizePerMagnification  (also in XLingPapPublisherStylesheetFO.xsl)
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
        OutputContentLayoutFormatInfo
    -->
    <xsl:template name="OutputContentLayoutFormatInfo">
        <xsl:param name="name"/>
        <xsl:text>.</xsl:text>
        <xsl:value-of select="$name"/>
        <xsl:text> {
</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}
</xsl:text>
    </xsl:template>
    <!--
        OutputAbbreviationsInTable (not needed here, but called from common)
    -->
    <xsl:template name="OutputAbbreviationsInTable"/>    
    <!--
        OutputInterlinearTextReference (not needed here, but called from common)
    -->
    <xsl:template name="OutputInterlinearTextReference"/>
    <!--
        OutputISOCodeInExample
    -->
    <xsl:template name="OutputISOCodeInExample">
        <!-- to be done -->
    </xsl:template>
    <!-- 
        OutputISO639-3CodeInCommaSeparatedList (not needed here, but called from common)
    -->
    <xsl:template name="OutputISO639-3CodeInCommaSeparatedList"/>
    <!-- 
        OutputISO639-3CodeInTable (not needed here, but called from common)
    -->
    <xsl:template name="OutputISO639-3CodeInTable"/>
    <!-- 
        OutputISO639-3CodesInTable (not needed here, but called from common)
    -->
    <xsl:template name="OutputISO639-3CodesInTable"/>
    <!-- 
        OutputTitleFormatInfo
    -->
    <xsl:template name="OutputTitleFormatInfo">
        <xsl:param name="name"/>
        <!-- cannot use before and after pseudo elements because Internet Explorer does not handle them (sigh).
            <xsl:call-template name="DoTextBefore">
            <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
        -->
        <xsl:text>.</xsl:text>
        <xsl:value-of select="$name"/>
        <xsl:text> {
</xsl:text>
        <xsl:apply-templates select="@*[name()!='textbefore' and name()!='textafter']"/>
        <xsl:text>}
</xsl:text>
        <!-- cannot use before and after pseudo elements because Internet Explorer does not handle them (sigh).
            <xsl:call-template name="DoTextAfter">
            <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
        -->
    </xsl:template>
    <!-- 
        DoTextAfter
    -->
    <xsl:template name="DoSingleSpacing">
        <xsl:param name="useSingleSpacing"/>
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $useSingleSpacing='yes'">
            <xsl:text>        line-height:100%;
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        DoTextAfter
    -->
    <xsl:template name="DoTextAfter">
        <xsl:param name="name"/>
        <xsl:if test="string-length(@textafter) &gt; 0">
            <xsl:text>.</xsl:text>
            <xsl:value-of select="$name"/>
            <xsl:text>:after {
        content: "</xsl:text>
            <xsl:value-of select="@textafter"/>
            <xsl:text>";
}
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- 
        DoTextBefore
    -->
    <xsl:template name="DoTextBefore">
        <xsl:param name="name"/>
        <xsl:if test="string-length(@textbefore) &gt; 0">
            <xsl:text>.</xsl:text>
            <xsl:value-of select="$name"/>
            <xsl:text>:before {
        content: "</xsl:text>
            <xsl:value-of select="@textbefore"/>
            <xsl:text>";
}
</xsl:text>
        </xsl:if>
    </xsl:template>
    <!-- ===========================================================
      ELEMENTS TO IGNORE
      =========================================================== -->
    <xsl:template match="appendix/shortTitle"/>
    <xsl:template match="affiliation" mode="contents"/>
    <xsl:template match="author" mode="contents"/>
    <xsl:template match="comment"/>
    <xsl:template match="comment" mode="contents"/>
    <xsl:template match="contentControlChoice"/>
    <xsl:template match="contentType"/>
    <xsl:template match="date" mode="contents"/>
    <xsl:template match="dd"/>
    <xsl:template match="fixedText"/>
    <xsl:template match="magnificationFactor"/>
    <xsl:template match="publisherStyleSheetName"/>
    <xsl:template match="publisherStyleSheetPublisher"/>
    <xsl:template match="publisherStyleSheetVersion"/>
    <xsl:template match="section1/shortTitle"/>
    <xsl:template match="section2/shortTitle"/>
    <xsl:template match="section3/shortTitle"/>
    <xsl:template match="section4/shortTitle"/>
    <xsl:template match="section5/shortTitle"/>
    <xsl:template match="section6/shortTitle"/>
    <xsl:template match="style"/>
    <xsl:template match="styles"/>
    <xsl:template match="subtitle" mode="contents"/>
    <xsl:template match="term"/>
    <xsl:template match="textInfo/shortTitle"/>
    <xsl:template match="title" mode="contents"/>
    <xsl:template match="version" mode="contents"/>
    <!-- ===========================================================
        TEMPLATE DUMMIES
        =========================================================== -->
    <xsl:template name="DoRefWorks"/>
    <xsl:template name="HandleLiteralLabelLayoutInfo"/>
    <xsl:template name="LinkAttributesBegin"/>
    <xsl:template name="LinkAttributesEnd"/>
    <xsl:template name="OutputAbbreviationInCommaSeparatedList"/>
    <xsl:template name="OutputAbbreviationInTable"/>
    <xsl:template name="OutputGlossaryTermInTable"/>
    <xsl:template name="OutputGlossaryTermsInTable"/>
    <!-- ===========================================================
        TRANSFORMS TO INCLUDE
        =========================================================== -->
    <xsl:include href="XLingPapPublisherStylesheetXHTMLCSSContents.xsl"/>
    <!--    <xsl:include href="XLingPapPublisherStylesheetCommon.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetFOBookmarks.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetFOContents.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetFOReferences.xsl"/>
-->
    <xsl:include href="XLingPapPublisherStylesheetXHTMLCommon.xsl"/>
</xsl:stylesheet>
