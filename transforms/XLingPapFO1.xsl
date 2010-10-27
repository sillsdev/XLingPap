<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi" xmlns:saxon="http://icl.com/saxon">
    <xsl:output method="xml" version="1.0" encoding="utf-8"/>
    <!-- ===========================================================
      Version of this stylesheet
      =========================================================== -->
    <xsl:variable name="sVersion">2.11.0</xsl:variable>
    <!-- ===========================================================
      Keys
      =========================================================== -->
    <xsl:key name="IndexTermID" match="//indexTerm" use="@id"/>
    <xsl:key name="InterlinearReferenceID" match="//interlinear" use="@text"/>
    <xsl:key name="LanguageID" match="//language" use="@id"/>
    <xsl:key name="RefWorkID" match="//refWork" use="@id"/>
    <xsl:key name="TypeID" match="//type" use="@id"/>
    <!-- ===========================================================
      Parameters
      =========================================================== -->
    <xsl:param name="sBasicPointSize" select="'10'"/>
    <xsl:param name="sSection1PointSize" select="'12'"/>
    <xsl:param name="sSection2PointSize" select="'10'"/>
    <xsl:param name="sSection3PointSize" select="'10'"/>
    <xsl:param name="sSection4PointSize" select="'10'"/>
    <xsl:param name="sSection5PointSize" select="'10'"/>
    <xsl:param name="sSection6PointSize" select="'10'"/>
    <xsl:param name="sBackMatterItemTitlePointSize" select="'12'"/>
    <xsl:param name="sBlockQuoteIndent" select="'.125in'"/>
    <xsl:param name="sDefaultFontFamily" select="'Times New Roman'"/>
    <!--        <xsl:param name="sDefaultFontFamily" select="'Charis SIL'"/> -->
    <xsl:param name="sFooterMargin" select="'.25in'"/>
    <xsl:param name="sFootnotePointSize" select="'8'"/>
    <xsl:param name="sHeaderMargin" select="'.25in'"/>
    <xsl:param name="sPageWidth" select="'6in'"/>
    <xsl:param name="sPageHeight" select="'9in'"/>
    <xsl:param name="sPageTopMargin" select="'.7in'"/>
    <xsl:param name="sPageBottomMargin" select="'.675in'"/>
    <xsl:param name="sPageInsideMargin" select="'1in'"/>
    <xsl:param name="sPageOutsideMargin" select="'.5in'"/>
    <xsl:param name="sParagraphIndent" select="'1em'"/>
    <xsl:param name="sLinkColor"/>
    <xsl:param name="sLinkTextDecoration"/>
    <xsl:param name="sFOProcessor">XEP</xsl:param>
    <xsl:param name="bDoDebug" select="'n'"/>
    <!-- need a better solution for the following -->
    <xsl:param name="sVernacularFontFamily" select="'Arial Unicode MS'"/>
    <!--
        sInterlinearSourceStyle:
        The default is AfterFirstLine (immediately after the last item in the first line)
        The other possibilities are AfterFree (immediately after the free translation, on the same line)
        and UnderFree (on the line immediately after the free translation)
    -->
    <xsl:param name="sInterlinearSourceStyle">AfterFirstLine</xsl:param>
    <!-- ===========================================================
      Variables
      =========================================================== -->
    <xsl:variable name="chapters" select="//chapter"/>
    <xsl:variable name="landscapes" select="//landscape"/>
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
    <xsl:attribute-set name="NonChapterTitleInfoBook">
        <xsl:attribute name="font-size">18pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="break-before">page</xsl:attribute>
        <xsl:attribute name="margin-top">172.2pt</xsl:attribute>
        <xsl:attribute name="margin-bottom">10.8pt</xsl:attribute>
        <xsl:attribute name="text-align">center</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="NonChapterTitleInfoPaper">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="text-align">center</xsl:attribute>
        <xsl:attribute name="space-before">
            <xsl:value-of select="2*$sBasicPointSize"/>pt</xsl:attribute>
        <xsl:attribute name="space-after">
            <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
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
            <xsl:value-of select="$sPageOutsideMargin"/>
        </xsl:attribute>
        <xsl:attribute name="margin-right">
            <xsl:value-of select="$sPageInsideMargin"/>
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
            <xsl:value-of select="$sParagraphIndent"/>
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
    <xsl:template match="/lingPaper">
        <!-- using line-height-shift-adjustment="disregard-shifts" to keep ugly gaps from appearing between lines with footnotes. -->
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" line-height-shift-adjustment="disregard-shifts">
            <xsl:comment> generated by XLingPapFO1.xsl Version <xsl:value-of select="$sVersion"/>&#x20;</xsl:comment>
            <!-- Page layouts -->
            <fo:layout-master-set>
                <!-- Front matter -->
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
                <xsl:if test="$landscapes">
                    <xsl:element name="fo:simple-page-master" use-attribute-sets="EvenPageLayout">
                        <xsl:attribute name="master-name">FrontMatterTOCLandscapeEvenPage</xsl:attribute>
                        <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}" reference-orientation="90">
                            <xsl:call-template name="DoDebugFrontMatterBody"/>
                        </fo:region-body>
                        <fo:region-before region-name="FrontMatterTOCEvenPage-before" extent="{$sHeaderMargin}">
                            <xsl:call-template name="DoDebugHeader"/>
                        </fo:region-before>
                        <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                            <xsl:call-template name="DoDebugFooter"/>
                        </fo:region-after>
                    </xsl:element>
                    <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                        <xsl:attribute name="master-name">FrontMatterTOCLandscapeOddPage</xsl:attribute>
                        <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}" reference-orientation="90">
                            <xsl:call-template name="DoDebugFrontMatterBody"/>
                        </fo:region-body>
                        <fo:region-before region-name="FrontMatterTOCOddPage-before" extent="{$sHeaderMargin}">
                            <xsl:call-template name="DoDebugHeader"/>
                        </fo:region-before>
                        <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                            <xsl:call-template name="DoDebugFooter"/>
                        </fo:region-after>
                    </xsl:element>
                </xsl:if>
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
                <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                    <xsl:attribute name="master-name">ChapterFirstPage</xsl:attribute>
                    <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                        <xsl:if test="$bDoDebug='y'">
                            <xsl:attribute name="border">
                                <xsl:text>thin solid silver</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                    </fo:region-body>
                    <fo:region-before extent="{$sHeaderMargin}">
                        <xsl:call-template name="DoDebugHeader"/>
                    </fo:region-before>
                    <fo:region-after region-name="ChapterFirstPage-after" extent="{$sFooterMargin}">
                        <xsl:call-template name="DoDebugFooter"/>
                    </fo:region-after>
                </xsl:element>
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
                    <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                        <xsl:call-template name="DoDebugFooter"/>
                    </fo:region-after>
                </xsl:element>
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
                    <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                        <xsl:call-template name="DoDebugFooter"/>
                    </fo:region-after>
                </xsl:element>
                <xsl:if test="$landscapes">
                    <xsl:element name="fo:simple-page-master" use-attribute-sets="EvenPageLayout">
                        <xsl:attribute name="master-name">ChapterLandscapeEvenPage</xsl:attribute>
                        <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}" reference-orientation="90">
                            <xsl:if test="$bDoDebug='y'">
                                <xsl:attribute name="border-left">
                                    <xsl:text>medium gray ridge</xsl:text>
                                </xsl:attribute>
                            </xsl:if>
                        </fo:region-body>
                        <fo:region-before region-name="ChapterEvenPage-before" extent="{$sHeaderMargin}">
                            <xsl:call-template name="DoDebugHeader"/>
                        </fo:region-before>
                        <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                            <xsl:call-template name="DoDebugFooter"/>
                        </fo:region-after>
                    </xsl:element>
                    <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                        <xsl:attribute name="master-name">ChapterLandscapeOddPage</xsl:attribute>
                        <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}" reference-orientation="90">
                            <xsl:if test="$bDoDebug='y'">
                                <xsl:attribute name="border-right">
                                    <xsl:text>medium gray ridge</xsl:text>
                                </xsl:attribute>
                            </xsl:if>
                        </fo:region-body>
                        <fo:region-before region-name="ChapterOddPage-before" extent="{$sHeaderMargin}">
                            <xsl:call-template name="DoDebugHeader"/>
                        </fo:region-before>
                        <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                            <xsl:call-template name="DoDebugFooter"/>
                        </fo:region-after>
                    </xsl:element>
                </xsl:if>
                <!-- Indexes -->
                <xsl:element name="fo:simple-page-master" use-attribute-sets="OddPageLayout">
                    <xsl:attribute name="master-name">IndexFirstPage</xsl:attribute>
                    <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}" column-count="2" column-gap="0.25in">
                        <xsl:if test="$bDoDebug='y'">
                            <xsl:attribute name="border">
                                <xsl:text>thin solid silver</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                    </fo:region-body>
                    <fo:region-before extent="{$sHeaderMargin}">
                        <xsl:call-template name="DoDebugHeader"/>
                    </fo:region-before>
                    <fo:region-after region-name="IndexFirstPage-after" extent="{$sFooterMargin}">
                        <xsl:call-template name="DoDebugFooter"/>
                    </fo:region-after>
                </xsl:element>
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
                    <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                        <xsl:call-template name="DoDebugFooter"/>
                    </fo:region-after>
                </xsl:element>
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
                    <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                        <xsl:call-template name="DoDebugFooter"/>
                    </fo:region-after>
                </xsl:element>
                <xsl:element name="fo:simple-page-master" use-attribute-sets="EvenPageLayout">
                    <xsl:attribute name="master-name">BlankEvenPage</xsl:attribute>
                    <fo:region-body margin-top="{$sHeaderMargin}" margin-bottom="{$sFooterMargin}">
                        <xsl:if test="$bDoDebug='y'">
                            <xsl:attribute name="border">
                                <xsl:text>thick solid black</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                    </fo:region-body>
                    <fo:region-before region-name="xsl-region-before" extent="{$sHeaderMargin}">
                        <xsl:call-template name="DoDebugHeader"/>
                    </fo:region-before>
                    <fo:region-after region-name="xsl-region-after" extent="{$sFooterMargin}">
                        <xsl:call-template name="DoDebugFooter"/>
                    </fo:region-after>
                </xsl:element>
                <xsl:if test="$chapters">
                    <fo:page-sequence-master master-name="FrontMatter">
                        <fo:repeatable-page-master-alternatives>
                            <fo:conditional-page-master-reference page-position="first" master-reference="FrontMatterPage"/>
                            <fo:conditional-page-master-reference odd-or-even="odd" master-reference="FrontMatterPage"/>
                            <fo:conditional-page-master-reference odd-or-even="even" master-reference="FrontMatterPage"/>
                            <fo:conditional-page-master-reference odd-or-even="even" blank-or-not-blank="blank" master-reference="FrontMatterBlankEvenPage"/>
                        </fo:repeatable-page-master-alternatives>
                    </fo:page-sequence-master>
                    <fo:page-sequence-master master-name="FrontMatterTOC">
                        <fo:repeatable-page-master-alternatives>
                            <fo:conditional-page-master-reference page-position="first" master-reference="FrontMatterTOCFirstPage"/>
                            <fo:conditional-page-master-reference odd-or-even="even" blank-or-not-blank="blank" master-reference="FrontMatterBlankEvenPage"/>
                            <fo:conditional-page-master-reference odd-or-even="even" master-reference="FrontMatterTOCEvenPage"/>
                            <fo:conditional-page-master-reference odd-or-even="odd" master-reference="FrontMatterTOCOddPage"/>
                        </fo:repeatable-page-master-alternatives>
                    </fo:page-sequence-master>
                    <xsl:if test="$landscapes">
                        <fo:page-sequence-master master-name="FrontMatterTOCLandscape">
                            <fo:repeatable-page-master-alternatives>
                                <fo:conditional-page-master-reference odd-or-even="even" master-reference="FrontMatterTOCLandscapeEvenPage"/>
                                <fo:conditional-page-master-reference odd-or-even="odd" master-reference="FrontMatterTOCLandscapeOddPage"/>
                            </fo:repeatable-page-master-alternatives>
                        </fo:page-sequence-master>
                    </xsl:if>
                    <fo:page-sequence-master master-name="FrontMatterTOCContinuation">
                        <fo:repeatable-page-master-alternatives>
                            <fo:conditional-page-master-reference odd-or-even="even" master-reference="FrontMatterTOCEvenPage"/>
                            <fo:conditional-page-master-reference odd-or-even="odd" master-reference="FrontMatterTOCOddPage"/>
                        </fo:repeatable-page-master-alternatives>
                    </fo:page-sequence-master>
                    <fo:page-sequence-master master-name="IndexContinuation">
                        <fo:repeatable-page-master-alternatives>
                            <fo:conditional-page-master-reference odd-or-even="even" master-reference="IndexEvenPage"/>
                            <fo:conditional-page-master-reference odd-or-even="odd" master-reference="IndexOddPage"/>
                        </fo:repeatable-page-master-alternatives>
                    </fo:page-sequence-master>
                </xsl:if>
                <fo:page-sequence-master master-name="Chapter">
                    <fo:repeatable-page-master-alternatives>
                        <fo:conditional-page-master-reference page-position="first" master-reference="ChapterFirstPage"/>
                        <fo:conditional-page-master-reference odd-or-even="even" blank-or-not-blank="blank" master-reference="BlankEvenPage"/>
                        <fo:conditional-page-master-reference odd-or-even="even" master-reference="ChapterEvenPage"/>
                        <fo:conditional-page-master-reference odd-or-even="odd" master-reference="ChapterOddPage"/>
                    </fo:repeatable-page-master-alternatives>
                </fo:page-sequence-master>
                <xsl:if test="$landscapes">
                    <fo:page-sequence-master master-name="ChapterLandscape">
                        <fo:repeatable-page-master-alternatives>
                            <fo:conditional-page-master-reference odd-or-even="even" master-reference="ChapterLandscapeEvenPage"/>
                            <fo:conditional-page-master-reference odd-or-even="odd" master-reference="ChapterLandscapeOddPage"/>
                        </fo:repeatable-page-master-alternatives>
                    </fo:page-sequence-master>
                    <fo:page-sequence-master master-name="ChapterContinuation">
                        <fo:repeatable-page-master-alternatives>
                            <fo:conditional-page-master-reference odd-or-even="even" master-reference="ChapterEvenPage"/>
                            <fo:conditional-page-master-reference odd-or-even="odd" master-reference="ChapterOddPage"/>
                        </fo:repeatable-page-master-alternatives>
                    </fo:page-sequence-master>
                </xsl:if>
                <fo:page-sequence-master master-name="Index">
                    <fo:repeatable-page-master-alternatives>
                        <fo:conditional-page-master-reference page-position="first" master-reference="IndexFirstPage"/>
                        <fo:conditional-page-master-reference odd-or-even="even" blank-or-not-blank="blank" master-reference="BlankEvenPage"/>
                        <fo:conditional-page-master-reference odd-or-even="even" master-reference="IndexEvenPage"/>
                        <fo:conditional-page-master-reference odd-or-even="odd" master-reference="IndexOddPage"/>
                    </fo:repeatable-page-master-alternatives>
                </fo:page-sequence-master>
            </fo:layout-master-set>
            <xsl:choose>
                <xsl:when test="$chapters">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="frontMatter"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:root>
    </xsl:template>
    <!-- ===========================================================
      FRONTMATTER
      =========================================================== -->
    <xsl:template match="frontMatter">
        <xsl:choose>
            <xsl:when test="$chapters">
                <fo:page-sequence master-reference="FrontMatter" format="i">
                    <fo:static-content flow-name="xsl-footnote-separator">
                        <fo:block text-align="left">
                            <fo:leader leader-pattern="rule" leader-length="2in"/>
                        </fo:block>
                    </fo:static-content>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:attribute name="font-family">
                            <xsl:value-of select="$sDefaultFontFamily"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="title | subtitle | author | affiliation | emailAddress | presentedAt | date | version"/>
                    </fo:flow>
                </fo:page-sequence>
                <xsl:apply-templates select="contents | acknowledgements | abstract | preface" mode="book"/>
            </xsl:when>
            <xsl:otherwise>
                <fo:page-sequence master-reference="Chapter">
                    <xsl:attribute name="initial-page-number">
                        <xsl:choose>
                            <xsl:when test="name()='chapter' and not(parent::part) and position()=1 or preceding-sibling::*[1][name(.)='frontMatter']">1</xsl:when>
                            <xsl:otherwise>auto-odd</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:call-template name="OutputChapterStaticContent"/>
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
                        <xsl:apply-templates select="title | subtitle | author | affiliation | emailAddress | presentedAt | date | version"/>
                        <xsl:apply-templates select="contents | acknowledgements | abstract | preface" mode="paper"/>
                        <xsl:apply-templates select="//section1[not(parent::appendix)]"/>
                        <xsl:apply-templates select="//backMatter"/>
                    </fo:flow>
                </fo:page-sequence>
                <!--                <xsl:apply-templates select="//index" mode="Index"/> -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      title
      -->
    <xsl:template match="title">
        <xsl:if test="$chapters">
            <fo:block font-size="18pt" font-weight="bold" text-align="center" space-before="1.25in" space-before.conditionality="retain">
                <xsl:apply-templates/>
            </fo:block>
            <xsl:apply-templates select="following-sibling::subtitle"/>
        </xsl:if>
        <fo:block font-size="18pt" font-weight="bold" text-align="center" space-before="1.25in" space-before.conditionality="retain" break-before="odd-page">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!--
      subtitle
      -->
    <xsl:template match="subtitle">
        <fo:block font-size="14pt" font-weight="bold" text-align="center" space-before=".25in" space-before.conditionality="retain">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!--
      author
      -->
    <xsl:template match="author">
        <fo:block font-style="italic" text-align="center">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!--
      affiliation
      -->
    <xsl:template match="affiliation">
        <fo:block font-style="italic" text-align="center">
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>
    <!--
        emailAddress
    -->
    <xsl:template match="emailAddress">
        <fo:block font-style="italic" text-align="center">
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>
    <!--
      date or presentedAt
      -->
    <xsl:template match="date | presentedAt">
        <fo:block font-size="10pt" text-align="center">
            <xsl:value-of select="."/>
        </fo:block>
    </xsl:template>
    <!--
      version
      -->
    <xsl:template match="version">
        <fo:block font-size="10pt" text-align="center">
            <xsl:text>Version: </xsl:text>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!--
      contents (for book)
      -->
    <xsl:template match="contents" mode="book">
        <fo:page-sequence master-reference="FrontMatterTOC" initial-page-number="auto-odd" format="i">
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
                        <fo:retrieve-marker retrieve-class-name="contents-title"/>
                    </fo:inline>
                </xsl:element>
            </fo:static-content>
            <fo:static-content flow-name="FrontMatterTOCOddPage-before" display-align="before">
                <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                    <xsl:attribute name="text-align-last">justify</xsl:attribute>
                    <fo:inline>
                        <fo:retrieve-marker retrieve-class-name="contents-title"/>
                    </fo:inline>
                    <fo:leader/>
                    <fo:inline>
                        <fo:page-number/>
                    </fo:inline>
                </xsl:element>
            </fo:static-content>
            <fo:static-content flow-name="xsl-footnote-separator">
                <fo:block text-align="left">
                    <fo:leader leader-pattern="rule" leader-length="2in"/>
                </fo:block>
            </fo:static-content>
            <fo:flow flow-name="xsl-region-body">
                <xsl:attribute name="font-family">
                    <xsl:value-of select="$sDefaultFontFamily"/>
                </xsl:attribute>
                <xsl:attribute name="font-size">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                <!-- put title in marker so it can show up in running header -->
                <fo:marker marker-class-name="contents-title">
                    <xsl:call-template name="OutputContentsLabel"/>
                </fo:marker>
                <xsl:call-template name="DoContents">
                    <xsl:with-param name="bIsBook" select="'Y'"/>
                </xsl:call-template>
            </fo:flow>
        </fo:page-sequence>
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
        abstract, preface and acknowledgements (for book)
    -->
    <xsl:template match="abstract | acknowledgements | preface" mode="book">
        <fo:page-sequence master-reference="FrontMatterTOC" initial-page-number="auto-odd" format="i">
            <xsl:call-template name="OutputFrontMatterStaticContent"/>
            <fo:flow flow-name="xsl-region-body">
                <xsl:attribute name="font-family">
                    <xsl:value-of select="$sDefaultFontFamily"/>
                </xsl:attribute>
                <xsl:attribute name="font-size">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                <xsl:call-template name="DoAbstractAcknowledgementsOrPreface">
                    <xsl:with-param name="bIsBook" select="'Y'"/>
                </xsl:call-template>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>
    <xsl:template name="OutputFrontMatterStaticContent">
        <fo:static-content flow-name="FrontMatterTOCFirstPage-after" display-align="after">
            <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                <xsl:attribute name="text-align">center</xsl:attribute>
                <xsl:attribute name="margin-top">6pt</xsl:attribute>
                <fo:page-number/>
            </xsl:element>
        </fo:static-content>
        <xsl:variable name="sHeaderTitleClassName">
            <xsl:choose>
                <xsl:when test="name()='abstract'">abstract-title</xsl:when>
                <xsl:when test="name()='acknowledgements'">acknowledgements-title</xsl:when>
                <xsl:otherwise>preface-title</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
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
        <fo:static-content flow-name="xsl-footnote-separator">
            <fo:block text-align="left">
                <fo:leader leader-pattern="rule" leader-length="2in"/>
            </fo:block>
        </fo:static-content>
    </xsl:template>
    <!--
      abstract, preface and acknowledgements (paper)
      -->
    <xsl:template match="abstract | acknowledgements | preface" mode="paper">
        <xsl:call-template name="DoAbstractAcknowledgementsOrPreface">
            <xsl:with-param name="bIsBook" select="'N'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- ===========================================================
      PARTS, CHAPTERS, SECTIONS, and APPENDICES
      =========================================================== -->
    <!--
      Part
      -->
    <xsl:template match="part">
        <fo:page-sequence master-reference="Chapter">
            <xsl:attribute name="initial-page-number">
                <xsl:choose>
                    <xsl:when test="name()='chapter' and position()=1 or preceding-sibling::*[1][name(.)='frontMatter']">1</xsl:when>
                    <xsl:otherwise>auto-odd</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <fo:static-content flow-name="xsl-footnote-separator">
                <fo:block text-align="left">
                    <fo:leader leader-pattern="rule" leader-length="2in"/>
                </fo:block>
            </fo:static-content>
            <fo:flow flow-name="xsl-region-body">
                <xsl:attribute name="font-family">
                    <xsl:value-of select="$sDefaultFontFamily"/>
                </xsl:attribute>
                <xsl:attribute name="font-size">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                <!-- put title in marker so it can show up in running header -->
                <fo:marker marker-class-name="chap-title">
                    <xsl:call-template name="DoSecTitleRunningHeader"/>
                </fo:marker>
                <fo:block id="{@id}" font-size="18pt" font-weight="bold" break-before="page" margin-top="144pt" margin-bottom="10.8pt" text-align="center">
                    <xsl:call-template name="OutputChapTitle">
                        <xsl:with-param name="sTitle">
                            <xsl:call-template name="OutputPartLabel"/>
                            <xsl:text>&#x20;</xsl:text>
                            <xsl:apply-templates select="." mode="numberPart"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </fo:block>
                <fo:block font-size="18pt" font-weight="bold" text-align="center" margin-bottom="21.6pt">
                    <xsl:apply-templates select="secTitle"/>
                </fo:block>
                <xsl:apply-templates select="child::node()[name()!='secTitle' and name()!='chapter']"/>
            </fo:flow>
        </fo:page-sequence>
        <xsl:apply-templates select="child::node()[name()='chapter']"/>
    </xsl:template>
    <!--
      Chapter or appendix (in book with chapters)
      -->
    <xsl:template match="chapter | appendix[//chapter]  | chapterBeforePart">
        <fo:page-sequence master-reference="Chapter">
            <xsl:attribute name="initial-page-number">
                <xsl:choose>
                    <xsl:when test="name()='chapter' and not(parent::part) and position()=1 or preceding-sibling::*[1][name(.)='frontMatter']">1</xsl:when>
                    <xsl:otherwise>auto-odd</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:call-template name="OutputChapterStaticContent"/>
            <fo:flow flow-name="xsl-region-body">
                <xsl:attribute name="font-family">
                    <xsl:value-of select="$sDefaultFontFamily"/>
                </xsl:attribute>
                <xsl:attribute name="font-size">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                <!-- put title in marker so it can show up in running header -->
                <fo:marker marker-class-name="chap-title">
                    <xsl:call-template name="DoSecTitleRunningHeader"/>
                </fo:marker>
                <fo:block id="{@id}" font-size="18pt" font-weight="bold" break-before="page" margin-top="144pt" margin-bottom="10.8pt" text-align="center">
                    <xsl:call-template name="OutputChapTitle">
                        <xsl:with-param name="sTitle">
                            <xsl:call-template name="OutputChapterNumber"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </fo:block>
                <fo:block font-size="18pt" font-weight="bold" text-align="center" margin-bottom="21.6pt">
                    <xsl:apply-templates select="secTitle"/>
                </fo:block>
                <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>
    <!--
      Sections
      -->
    <xsl:template match="section1">
        <fo:block id="{@id}" font-weight="bold" text-align="center" keep-with-next.within-page="always">
            <xsl:attribute name="font-size">
                <xsl:value-of select="$sSection1PointSize"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="space-before">
                <xsl:value-of select="2*$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:attribute name="space-after">
                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:call-template name="OutputSection"/>
        </fo:block>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <xsl:template match="section2">
        <fo:block id="{@id}" font-weight="bold" text-align="left" keep-with-next.within-page="always">
            <xsl:attribute name="font-size">
                <xsl:value-of select="$sSection2PointSize"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="space-before">
                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:attribute name="space-after">
                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:call-template name="OutputSection"/>
        </fo:block>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <xsl:template match="section3">
        <fo:block id="{@id}" font-weight="bold" font-style="italic" text-align="left" keep-with-next.within-page="always">
            <xsl:attribute name="font-size">
                <xsl:value-of select="$sSection3PointSize"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="space-before">
                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:attribute name="space-after">
                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:call-template name="OutputSection"/>
        </fo:block>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <xsl:template match="section4 | section5 | section6">
        <fo:block id="{@id}" font-style="italic" text-align="left" keep-with-next.within-page="always">
            <xsl:attribute name="font-size">
                <xsl:value-of select="$sSection4PointSize"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="space-before">
                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:attribute name="space-after">
                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:call-template name="OutputSection"/>
        </fo:block>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <!--
      Appendix
      -->
    <xsl:template match="appendix[not(//chapter)]">
        <xsl:element name="fo:block" use-attribute-sets="NonChapterTitleInfoPaper">
            <xsl:attribute name="id">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
            <xsl:call-template name="DoType">
                <xsl:with-param name="type" select="@type"/>
            </xsl:call-template>
            <xsl:apply-templates select="." mode="numberAppendix"/>
            <xsl:text disable-output-escaping="yes">.&#x20;</xsl:text>
            <xsl:apply-templates select="secTitle"/>
        </xsl:element>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <!--
      secTitle
      -->
    <xsl:template match="secTitle">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      sectionRef
      -->
    <xsl:template match="sectionRef">
        <xsl:call-template name="OutputAnyTextBeforeSectionRef"/>
        <fo:inline>
            <fo:basic-link>
                <xsl:attribute name="internal-destination">
                    <xsl:value-of select="@sec"/>
                </xsl:attribute>
                <xsl:call-template name="AddAnyLinkAttributes"/>
                <xsl:apply-templates select="id(@sec)" mode="number"/>
            </fo:basic-link>
        </fo:inline>
    </xsl:template>
    <!--
      appendixRef
      -->
    <xsl:template match="appendixRef">
        <fo:basic-link internal-destination="{@app}">
            <xsl:call-template name="AddAnyLinkAttributes"/>
            <xsl:apply-templates select="id(@app)" mode="numberAppendix"/>
        </fo:basic-link>
    </xsl:template>
    <!--
      genericRef
      -->
    <xsl:template match="genericRef">
        <fo:basic-link internal-destination="{@gref}">
            <xsl:call-template name="AddAnyLinkAttributes"/>
            <xsl:apply-templates/>
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
            <xsl:call-template name="AddAnyLinkAttributes"/>
            <xsl:apply-templates/>
        </fo:basic-link>
    </xsl:template>
    <!-- ===========================================================
      PARAGRAPH
      =========================================================== -->
    <xsl:template match="p | pc">
        <xsl:choose>
            <xsl:when test="parent::endnote and name()='p' and position()='1'">
                <xsl:call-template name="OutputTypeAttributes">
                    <xsl:with-param name="sList" select="@xsl-foSpecial"/>
                </xsl:call-template>
                <fo:inline baseline-shift="super">
                    <xsl:attribute name="font-size">
                        <xsl:value-of select="$sFootnotePointSize - 2"/>
                        <xsl:text>pt</xsl:text>
                    </xsl:attribute>
                    <xsl:for-each select="parent::endnote">
                        <xsl:choose>
                            <xsl:when test="$chapters">
                                <xsl:number level="any" count="endnote[not(ancestor::author)] | endnoteRef[not(ancestor::endnote)]" from="chapter"/>
                            </xsl:when>
                            <xsl:when test="ancestor::author">
                                <xsl:variable name="iAuthorPosition" select="count(ancestor::author/preceding-sibling::author[endnote]) + 1"/>
                                <xsl:call-template name="OutputAuthorFootnoteSymbol">
                                    <xsl:with-param name="iAuthorPosition" select="$iAuthorPosition"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:number level="any" count="endnote[not(ancestor::author)] | endnoteRef[not(ancestor::endnote)]" format="1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </fo:inline>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <fo:block orphans="2" widows="2">
                    <xsl:call-template name="OutputTypeAttributes">
                        <xsl:with-param name="sList" select="@xsl-foSpecial"/>
                    </xsl:call-template>
                    <xsl:if test="name(.)='p' and not(parent::blockquote and position()=1)">
                        <xsl:attribute name="text-indent">
                            <xsl:value-of select="$sParagraphIndent"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ===========================================================
      QUOTES
      =========================================================== -->
    <xsl:template match="q">
        <fo:inline>
            <xsl:call-template name="DoType"/>
            <xsl:value-of select="$sLdquo"/>
            <xsl:apply-templates/>
            <xsl:value-of select="$sRdquo"/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="blockquote">
        <fo:block>
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
                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:attribute name="space-after">
                <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!-- ===========================================================
        PROSE TEXT
        =========================================================== -->
    <xsl:template match="prose-text">
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
    </xsl:template>
    <!-- ===========================================================
      LISTS
      =========================================================== -->
    <xsl:template match="ol">
        <fo:list-block>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
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
            <xsl:if test="$NestingLevel = '0'">
                <xsl:attribute name="start-indent">1em</xsl:attribute>
                <xsl:attribute name="provisional-distance-between-starts">2em</xsl:attribute>
            </xsl:if>
            <xsl:if test="ancestor::endnote">
                <xsl:attribute name="provisional-label-separation">0em</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </fo:list-block>
    </xsl:template>
    <xsl:template match="ul">
        <fo:list-block>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:if test="not(ancestor::ul)">
                <xsl:attribute name="start-indent">1em</xsl:attribute>
                <xsl:attribute name="provisional-distance-between-starts">1em</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </fo:list-block>
    </xsl:template>
    <xsl:template match="li">
        <fo:list-item relative-align="baseline">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
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
                                    <xsl:value-of select="position()"/>
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
            <xsl:apply-templates select="following-sibling::dd[1][name()='dd']" mode="dt"/>
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
        <fo:block>
            <xsl:if test="@num">
                <xsl:attribute name="id">
                    <xsl:value-of select="@num"/>
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
                <xsl:value-of select="$sBlockQuoteIndent"/>
            </xsl:attribute>
            <xsl:attribute name="end-indent">
                <xsl:value-of select="$sBlockQuoteIndent"/>
            </xsl:attribute>
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
                                <!--  units are inches because "XFC is not a renderer. It has a limited set of font metrics and therefore handles 'em' units in a very approximate way."
                                    (email of August 10, 2007 from Jean-Yves Belmonte of XMLmind)-->
                                <xsl:text>in</xsl:text>
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
                                <!--  units are inches because "XFC is not a renderer. It has a limited set of font metrics and therefore handles 'em' units in a very approximate way."
                                    (email of August 10, 2007 from Jean-Yves Belmonte of XMLmind)-->
                                <xsl:value-of select="number($iExampleWidth - $iNumberWidth)"/>
                                <xsl:text>in</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <!--  if we can ever get FOP to do something reasonable for examples and interlinear, we'll add a 'when' clause here -->
                    </xsl:choose>
                </fo:table-column>
                <fo:table-body start-indent="0pt" end-indent="0pt">
                    <fo:table-row>
                        <fo:table-cell text-align="start" end-indent=".2em">
                            <xsl:call-template name="DoDebugExamples"/>
                            <!--                 <xsl:call-template name="DoCellAttributes"/> -->
                            <fo:block>
                                <xsl:text>(</xsl:text>
                                <xsl:call-template name="GetExampleNumber">
                                    <xsl:with-param name="example" select="."/>
                                </xsl:call-template>
                                <xsl:text>)</xsl:text>
                                <xsl:if test="//lingPaper/@showiso639-3codeininterlinear='yes'">
                                    <xsl:variable name="firstLangData" select="descendant::langData[1]"/>
                                    <xsl:if test="$firstLangData">
                                        <xsl:variable name="sIsoCode" select="key('LanguageID',$firstLangData/@lang)/@ISO639-3Code"/>
                                        <xsl:if test="string-length($sIsoCode) &gt; 0">
                                            <fo:block/>
                                            <fo:inline font-size="smaller">
                                                <xsl:text>[</xsl:text>
                                                <xsl:value-of select="$sIsoCode"/>
                                                <xsl:text>]</xsl:text>
                                            </fo:inline>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:if>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell>
                            <xsl:call-template name="DoDebugExamples"/>
                            <xsl:apply-templates/>
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
        <xsl:call-template name="OutputWordOrSingle"/>
    </xsl:template>
    <!--
      listWord
      -->
    <xsl:template match="listWord">
        <xsl:if test="parent::example/listWord[1]=.">
            <xsl:call-template name="OutputList"/>
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
        <xsl:if test="parent::example/listSingle[1]=.">
            <xsl:call-template name="OutputList"/>
        </xsl:if>
    </xsl:template>
    <!--
      interlinear
      -->
    <xsl:template match="interlinear">
        <xsl:choose>
            <xsl:when test="parent::interlinear-text">
                <fo:block id="{@text}" font-size="smaller" font-weight="bold" keep-with-next.within-page="2" orphans="2" widows="2">
                    <xsl:value-of select="../textInfo/shortTitle"/>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="count(preceding-sibling::interlinear) + 1"/>
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
      interlinearRef
   -->
    <xsl:template match="interlinearRef">
        <xsl:for-each select="key('InterlinearReferenceID',@textref)[1]">
            <xsl:apply-templates/>
        </xsl:for-each>
    </xsl:template>
    <!--
        interlinearRefCitation
    -->
    <xsl:template match="interlinearRefCitation">
        <xsl:if test="not(@bracket) or @bracket='both' or @bracket='initial'">
            <xsl:text>[</xsl:text>
        </xsl:if>
        <xsl:call-template name="DoInterlinearRefCitation">
            <xsl:with-param name="sRef" select="@textref"/>
        </xsl:call-template>
        <xsl:if test="not(@bracket) or @bracket='both' or @bracket='final'">
            <xsl:text>]</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--
      lineGroup
      -->
    <xsl:template match="lineGroup">
        <xsl:call-template name="DoInterlinearLineGroup"/>
    </xsl:template>
    <xsl:template match="lineGroup" mode="NoTextRef">
        <xsl:call-template name="DoInterlinearLineGroup">
            <xsl:with-param name="mode" select="'NoTextRef'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      line
      -->
    <xsl:template match="line">
        <xsl:call-template name="DoInterlinearLine"/>
    </xsl:template>
    <xsl:template match="line" mode="NoTextRef">
        <xsl:call-template name="DoInterlinearLine">
            <xsl:with-param name="mode" select="'NoTextRef'"/>
        </xsl:call-template>
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
      free
      -->
    <xsl:template match="free">
        <xsl:call-template name="DoInterlinearFree"/>
    </xsl:template>
    <xsl:template match="free" mode="NoTextRef">
        <xsl:call-template name="DoInterlinearFree"/>
    </xsl:template>
    <!--
      listInterlinear
      -->
    <xsl:template match="listInterlinear">
        <xsl:if test="parent::example and count(preceding-sibling::listInterlinear) = 0">
            <xsl:call-template name="OutputList"/>
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
        figure
    -->
    <xsl:template match="figure">
        <xsl:choose>
            <xsl:when test="descendant::endnote or $sFOProcessor='XFC'">
                <!--  cannot have endnotes in floats... 
                        and XFC does not handle floats
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
        <fo:basic-link internal-destination="{@figure}">
            <xsl:call-template name="AddAnyLinkAttributes"/>
            <xsl:call-template name="OutputAnyTextBeforeFigureRef"/>
            <xsl:apply-templates select="id(@figure)" mode="figure"/>
        </fo:basic-link>
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
                        <xsl:with-param name="bDoBold" select="'N'"/>
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
        <xsl:choose>
            <xsl:when test="descendant::endnote or $sFOProcessor='XFC'">
                <!--  cannot have endnotes in floats... 
                        and XFC does not handle floats
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
        <fo:basic-link internal-destination="{@table}">
            <xsl:call-template name="AddAnyLinkAttributes"/>
            <xsl:call-template name="OutputAnyTextBeforeTablenumberedRef"/>
            <xsl:apply-templates select="id(@table)" mode="tablenumbered"/>
        </fo:basic-link>
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
                        <xsl:with-param name="bDoBold" select="'N'"/>
                        <xsl:with-param name="bDoStyles" select="'N'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
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
                        <xsl:value-of select="$sBlockQuoteIndent"/>
                    </xsl:attribute>
                    <xsl:attribute name="end-indent">
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
    <xsl:template match="row | tr">
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
    <xsl:template match="col | td">
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
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:call-template name="OutputBackgroundColor"/>
            <fo:block>
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    <!--
          caption for a figure or table
      -->
    <xsl:template match="caption | endCaption">
        <xsl:param name="bDoBold" select="'Y'"/>
        <xsl:if test="not(ancestor::tablenumbered)">
            <fo:block>
                <xsl:if test="$bDoBold='Y'">
                    <xsl:attribute name="font-weight">
                        <xsl:text>bold</xsl:text>
                    </xsl:attribute>
                </xsl:if>
                <xsl:call-template name="DoCellAttributes"/>
                <xsl:if test="not(@align) and not(ancestor::figure or ancestor::tablenumbered)">
                    <!-- default to left -->
                    <xsl:attribute name="text-align">left</xsl:attribute>
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
    <xsl:template match="caption | endCaption" mode="show">
        <xsl:param name="bDoBold" select="'Y'"/>
        <fo:inline>
            <xsl:if test="$bDoBold='Y'">
                <xsl:attribute name="font-weight">
                    <xsl:text>bold</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
            <xsl:if test="not(@align)">
                <!-- default to centered -->
                <xsl:attribute name="text-align">center</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="caption" mode="contents">
        <xsl:choose>
            <xsl:when test="following-sibling::shortCaption">
                <xsl:apply-templates select="following-sibling::shortCaption"/>
            </xsl:when>
            <xsl:when test="ancestor::tablenumbered/shortCaption">
                <xsl:apply-templates select="ancestor::tablenumbered/shortCaption"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="endCaption" mode="contents">
        <xsl:choose>
            <xsl:when test="ancestor::tablenumbered/shortCaption">
                <xsl:apply-templates select="ancestor::tablenumbered/shortCaption"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
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
            <xsl:call-template name="AddAnyLinkAttributes"/>
            <xsl:if test="not(@paren) or @paren='both' or @paren='initial'">(</xsl:if>
            <xsl:if test="@equal='yes'">=</xsl:if>
            <xsl:choose>
                <xsl:when test="@letter">
                    <xsl:if test="not(@letterOnly='yes')">
                        <!--                        <xsl:apply-templates select="id(@letter)" mode="example"/>-->
                        <xsl:call-template name="GetExampleNumber">
                            <xsl:with-param name="example" select="id(@letter)"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:apply-templates select="id(@letter)" mode="letter"/>
                </xsl:when>
                <xsl:when test="@num">
                    <!--                    <xsl:apply-templates select="id(@num)" mode="example"/>-->
                    <xsl:call-template name="GetExampleNumber">
                        <xsl:with-param name="example" select="id(@num)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="@punct">
                <xsl:value-of select="@punct"/>
            </xsl:if>
            <xsl:if test="not(@paren) or @paren='both' or @paren='final'">)</xsl:if>
        </fo:basic-link>
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
        <fo:footnote>
            <fo:inline baseline-shift="super" id="{@id}" xsl:use-attribute-sets="FootnoteMarker">
                <xsl:choose>
                    <xsl:when test="$chapters">
                        <xsl:number level="any" count="endnote | endnoteRef[not(ancestor::endnote)]" from="chapter"/>
                    </xsl:when>
                    <xsl:when test="parent::author">
                        <xsl:variable name="iAuthorPosition" select="count(parent::author/preceding-sibling::author[endnote]) + 1"/>
                        <xsl:call-template name="OutputAuthorFootnoteSymbol">
                            <xsl:with-param name="iAuthorPosition" select="$iAuthorPosition"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:number level="any" count="endnote[not(parent::author)] | endnoteRef[not(ancestor::endnote)]" format="1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:inline>
            <fo:footnote-body>
                <fo:block xsl:use-attribute-sets="FootnoteBody">
                    <xsl:apply-templates/>
                </fo:block>
            </fo:footnote-body>
        </fo:footnote>
    </xsl:template>
    <!--
      endnoteRef
      -->
    <xsl:template match="endnoteRef">
        <xsl:choose>
            <xsl:when test="ancestor::endnote">
                <fo:basic-link internal-destination="{@note}">
                    <xsl:call-template name="AddAnyLinkAttributes"/>
                    <xsl:apply-templates select="id(@note)" mode="endnote"/>
                </fo:basic-link>
            </xsl:when>
            <xsl:otherwise>
                <fo:footnote>
                    <xsl:variable name="sFootnoteNumber">
                        <xsl:choose>
                            <xsl:when test="$chapters">
                                <xsl:number level="any" count="endnote | endnoteRef" from="chapter"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:number level="any" count="endnote | endnoteRef[not(ancestor::endnote)]" format="1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <fo:inline baseline-shift="super" id="{@id}">
                        <xsl:attribute name="font-size">
                            <xsl:value-of select="$sFootnotePointSize - 2"/>
                            <xsl:text>pt</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="$sFootnoteNumber"/>
                    </fo:inline>
                    <fo:footnote-body>
                        <fo:block text-align="left" text-indent="1em">
                            <xsl:attribute name="font-size">
                                <xsl:value-of select="$sFootnotePointSize"/>
                                <xsl:text>pt</xsl:text>
                            </xsl:attribute>
                            <fo:inline baseline-shift="super">
                                <xsl:attribute name="font-size">
                                    <xsl:value-of select="$sFootnotePointSize - 2"/>
                                    <xsl:text>pt</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="$sFootnoteNumber"/>
                                <!--
                                <xsl:for-each select="parent::endnote">
                                    <xsl:choose>
                                        <xsl:when test="$chapters">
                                            <xsl:number level="any" count="endnote" from="chapter"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:number level="any" count="endnote" format="1"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                -->
                            </fo:inline>
                            <xsl:text>See footnote </xsl:text>
                            <fo:basic-link internal-destination="{@note}">
                                <xsl:call-template name="AddAnyLinkAttributes"/>
                                <xsl:apply-templates select="id(@note)" mode="endnote"/>
                            </fo:basic-link>
                            <xsl:choose>
                                <xsl:when test="$chapters">
                                    <xsl:text> in chapter </xsl:text>
                                    <xsl:variable name="sNoteId" select="@note"/>
                                    <xsl:for-each select="$chapters[descendant::endnote[@id=$sNoteId]]">
                                        <xsl:number level="any" count="chapter" format="1"/>
                                    </xsl:for-each>
                                    <xsl:text>.</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>.</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:block>
                    </fo:footnote-body>
                </fo:footnote>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ===========================================================
      CITATIONS, Glossary, Indexes and REFERENCES 
      =========================================================== -->
    <!--
      citation
      -->
    <xsl:template match="//citation">
        <xsl:variable name="refer" select="id(@ref)"/>
        <fo:basic-link internal-destination="{@ref}">
            <xsl:call-template name="AddAnyLinkAttributes"/>
            <xsl:if test="@author='yes'">
                <xsl:value-of select="$refer/../@citename"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
            <xsl:if test="not(@paren) or @paren='both' or @paren='initial'">(</xsl:if>
            <xsl:variable name="works" select="$refWorks[../@name=$refer/../@name and @id=//citation/@ref]"/>
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
        </fo:basic-link>
    </xsl:template>
    <!--
      glossary
      -->
    <xsl:template match="glossary">
        <xsl:variable name="iPos" select="count(preceding-sibling::glossary) + 1"/>
        <xsl:choose>
            <xsl:when test="$chapters">
                <fo:page-sequence master-reference="Chapter" initial-page-number="auto-odd">
                    <xsl:call-template name="OutputChapterStaticContent">
                        <xsl:with-param name="sSectionTitle" select="'chap-title'"/>
                    </xsl:call-template>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:attribute name="font-family">
                            <xsl:value-of select="$sDefaultFontFamily"/>
                        </xsl:attribute>
                        <xsl:attribute name="font-size">
                            <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                        <fo:marker marker-class-name="chap-title">
                            <xsl:call-template name="OutputGlossaryLabel">
                                <xsl:with-param name="iPos" select="$iPos"/>
                            </xsl:call-template>
                        </fo:marker>
                        <xsl:call-template name="DoGlossary">
                            <xsl:with-param name="iPos" select="$iPos"/>
                        </xsl:call-template>
                    </fo:flow>
                </fo:page-sequence>
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
            <xsl:when test="$chapters">
                <fo:page-sequence master-reference="Index" initial-page-number="auto-odd">
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
                            <xsl:call-template name="OutputIndexLabel"/>
                        </fo:marker>
                        <xsl:call-template name="DoIndex"/>
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
    <xsl:template match="indexedItem | indexedRangeBegin">
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
      references
      -->
    <xsl:template match="references">
        <xsl:choose>
            <xsl:when test="$chapters">
                <fo:page-sequence master-reference="Chapter" initial-page-number="auto-odd">
                    <xsl:call-template name="OutputChapterStaticContent">
                        <xsl:with-param name="sSectionTitle" select="'chap-title'"/>
                    </xsl:call-template>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:attribute name="font-family">
                            <xsl:value-of select="$sDefaultFontFamily"/>
                        </xsl:attribute>
                        <xsl:attribute name="font-size">
                            <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                        <fo:marker marker-class-name="chap-title">
                            <xsl:call-template name="OutputReferencesLabel"/>
                        </fo:marker>
                        <xsl:call-template name="DoReferences"/>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:when>
            <xsl:otherwise>
                <fo:block orphans="2" widows="2">
                    <xsl:call-template name="DoReferences"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      refTitle
      -->
    <xsl:template match="refTitle">
        <xsl:apply-templates/>
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
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </fo:inline>
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
                <fo:inline>
                    <fo:basic-link>
                        <xsl:attribute name="internal-destination">
                            <xsl:value-of select="@abbr"/>
                        </xsl:attribute>
                        <xsl:call-template name="AddAnyLinkAttributes"/>
                        <xsl:call-template name="OutputAbbrTerm">
                            <xsl:with-param name="abbr" select="id(@abbr)"/>
                        </xsl:call-template>
                    </fo:basic-link>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- decided to use glossary instead
   <xsl:template match="backMatter/abbreviationsShownHere">
      <xsl:choose>
         <xsl:when test="$chapters">
            <fo:page-sequence master-reference="Chapter" initial-page-number="auto-odd">
               <xsl:call-template name="OutputChapterStaticContent">
                  <xsl:with-param name="sSectionTitle" select="'chap-title'"/>
               </xsl:call-template>
               <fo:flow flow-name="xsl-region-body">
                  <xsl:attribute name="font-family">
                     <xsl:value-of select="$sDefaultFontFamily"/>
                  </xsl:attribute>
                  <xsl:attribute name="font-size">
                     <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                  <fo:marker marker-class-name="chap-title">
                     <xsl:call-template name="OutputAbbreviationsLabel"/>
                  </fo:marker>
                  <xsl:call-template name="DoAbbreviations"/>
               </fo:flow>
            </fo:page-sequence>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="DoAbbreviations"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
-->
    <xsl:template match="abbreviationsShownHere">
        <xsl:choose>
            <xsl:when test="ancestor::endnote">
                <xsl:choose>
                    <xsl:when test="parent::p">
                        <xsl:call-template name="OutputAbbreviationsInCommaSeparatedList"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:block>
                            <xsl:call-template name="OutputAbbreviationsInCommaSeparatedList"/>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="not(ancestor::p)">
                <!-- ignore any other abbreviationsShownHere in a p except when also in an endnote; everything else goes in a table -->
                <xsl:call-template name="OutputAbbreviationsInTable"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="abbrTerm | abbrDefinition"/>
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
        LANDSCAPE
        =========================================================== -->
    <xsl:template match="landscape">
        <xsl:variable name="sMasterMainName">
            <xsl:choose>
                <xsl:when test="ancestor::preface">FrontMatterTOC</xsl:when>
                <xsl:otherwise>Chapter</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <psmi:page-sequence master-reference="{$sMasterMainName}Landscape" initial-page-number="auto">
            <xsl:choose>
                <xsl:when test="ancestor::preface">
                    <xsl:call-template name="OutputFrontMatterStaticContent"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="OutputChapterStaticContent">
                        <xsl:with-param name="bUseFirstPage" select="'N'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <fo:flow flow-name="xsl-region-body">
                <xsl:attribute name="font-family">
                    <xsl:value-of select="$sDefaultFontFamily"/>
                </xsl:attribute>
                <xsl:attribute name="font-size">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                <!-- put title in marker so it can show up in running header -->
                <xsl:choose>
                    <xsl:when test="ancestor::preface">
                        <fo:marker marker-class-name="preface-title">
                            <xsl:for-each select="ancestor::preface">
                                <xsl:call-template name="OutputPrefaceLabel"/>
                            </xsl:for-each>
                        </fo:marker>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:marker marker-class-name="chap-title">
                            <xsl:variable name="elementWithSecTitle" select="ancestor::chapter | ancestor::appendix[//chapter] | ancestor::chapterBeforePart |ancestor::part"/>
                            <xsl:choose>
                                <xsl:when test="$elementWithSecTitle">
                                    <xsl:for-each select="$elementWithSecTitle">
                                        <xsl:call-template name="DoSecTitleRunningHeader"/>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="$chapters">
                                            <xsl:choose>
                                                <xsl:when test="ancestor::glossary">
                                                    <xsl:for-each select="ancestor::glossary">
                                                        <xsl:call-template name="OutputGlossaryLabel">
                                                            <xsl:with-param name="iPos" select="count(preceding-sibling::glossary) + 1"/>
                                                        </xsl:call-template>
                                                    </xsl:for-each>
                                                </xsl:when>
                                                <xsl:when test="ancestor::index">
                                                    <xsl:for-each select="ancestor::index">
                                                        <xsl:call-template name="OutputIndexLabel"/>
                                                    </xsl:for-each>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:call-template name="OutputTitleForHeader"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="OutputTitleForHeader"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:marker>
                        <!-- put title in marker so it can show up in running header -->
                        <fo:marker marker-class-name="section-title">
                            <xsl:variable name="mySections" select="ancestor::section6 | ancestor::section5 | ancestor::section4 | ancestor::section3 | ancestor::section2 | ancestor::section1 | ancestor::appendix"/>
                            <xsl:variable name="myClosestSection" select="$mySections[last()]"/>
                            <xsl:choose>
                                <xsl:when test="$myClosestSection">
                                    <xsl:choose>
                                        <xsl:when test="$myClosestSection/shortTitle">
                                            <xsl:apply-templates select="$myClosestSection/shortTitle"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates select="$myClosestSection/secTitle/child::node()[name()!='endnote']"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="ancestor::preface">
                                    <xsl:for-each select="ancestor::preface">
                                        <xsl:call-template name="OutputPrefaceLabel"/>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="ancestor::glossary">
                                    <xsl:for-each select="ancestor::glossary">
                                        <xsl:call-template name="OutputGlossaryLabel">
                                            <xsl:with-param name="iPos" select="count(preceding-sibling::glossary) + 1"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="ancestor::index">
                                    <xsl:for-each select="ancestor::index">
                                        <xsl:call-template name="OutputIndexLabel"/>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- should not happen... -->
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:marker>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates/>
            </fo:flow>
        </psmi:page-sequence>
    </xsl:template>
    <xsl:template name="OutputTitleForHeader">
        <xsl:choose>
            <xsl:when test="//frontMatter/shortTitle">
                <xsl:apply-templates select="//frontMatter/shortTitle"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//title/child::node()[name()!='endnote']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ===========================================================
      LANGDATA
      =========================================================== -->
    <xsl:template match="langData">
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </fo:inline>
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
        INTERLINEAR TEXT
        =========================================================== -->
    <!--  
        interlinear-text
    -->
    <xsl:template match="interlinear-text">
        <xsl:choose>
            <xsl:when test="@xsl-foSpecial">
                <fo:block>
                    <xsl:call-template name="OutputTypeAttributes">
                        <xsl:with-param name="sList" select="@xsl-foSpecial"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        textInfo
    -->
    <xsl:template match="textInfo">
        <xsl:apply-templates/>
    </xsl:template>
    <!--  
        textTitle
    -->
    <xsl:template match="textTitle">
        <fo:block text-align="center" font-size="larger" font-weight="bold">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!--  
        source
    -->
    <xsl:template match="source">
        <fo:block text-align="center" font-style="italic">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!-- ===========================================================
      NUMBERING PROCESSING 
      =========================================================== -->
    <!--  
                  sections
-->
    <xsl:template mode="number" match="*">
        <xsl:choose>
            <xsl:when test="ancestor-or-self::chapter">
                <xsl:apply-templates select="." mode="numberChapter"/>
                <xsl:if test="ancestor::chapter">
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
        <!--
        <xsl:if test="$chapters">
            <xsl:apply-templates select="." mode="numberChapter"/>.</xsl:if>
      -->
        <xsl:choose>
            <xsl:when test="count($chapters)=0 and count(//section1)=1 and count(//section1/section2)=0">
                <!-- if there are no chapters and there is but one section1 (with no subsections), there's no need to have a number so don't  -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="multiple" count="section1 | section2 | section3 | section4 | section5 | section6" format="1.1"/>
            </xsl:otherwise>
        </xsl:choose>
        <!--      <xsl:variable name="numAt1">
         <xsl:number level="multiple" count="section1 | section2 | section3 | section4 | section5 | section6" format="1.1"/>
      </xsl:variable>
-->
        <!--  adjust section1 number down by one to start with 0 -->
        <!--      <xsl:variable name="num1" select="substring-before($numAt1,'.')"/>
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
-->
    </xsl:template>
    <!--  
                  appendix
-->
    <xsl:template mode="numberAppendix" match="*">
        <xsl:number level="multiple" count="appendix | section1 | section2 | section3 | section4 | section5 | section6" format="A.1"/>
    </xsl:template>
    <xsl:template mode="labelNumberAppendix" match="*">
        <xsl:choose>
            <xsl:when test="@label">
                <xsl:value-of select="@label"/>
            </xsl:when>
            <xsl:otherwise>Appendix</xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#x20;</xsl:text>
        <xsl:number level="single" count="appendix" format="A"/>
    </xsl:template>
    <!--  
                  chapter
-->
    <xsl:template mode="numberChapter" match="*">
        <xsl:number level="any" count="chapter" format="1"/>
    </xsl:template>
    <!--  
                  part
-->
    <xsl:template mode="numberPart" match="*">
        <xsl:number level="multiple" count="part" format="I"/>
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
    <xsl:template mode="endnote" match="*">
        <xsl:choose>
            <xsl:when test="$chapters">
                <xsl:number level="any" count="endnote[not(parent::author)] | endnoteRef" from="chapter" format="1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="any" count="endnote[not(parent::author)] | endnoteRef[not(ancestor::endnote)]" format="1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      example
   -->
    <xsl:template mode="example" match="*">
        <xsl:number level="any" count="example[not(ancestor::endnote)]" format="1"/>
    </xsl:template>
    <!--  
      exampleInEndnote
   -->
    <xsl:template mode="exampleInEndnote" match="*">
        <xsl:number level="single" count="example" format="i"/>
    </xsl:template>
    <!--  
        figure
    -->
    <xsl:template mode="figure" match="*">
        <xsl:choose>
            <xsl:when test="$chapters">
                <xsl:for-each select="ancestor::chapter | ancestor::appendix | ancestor::chapterBeforePart">
                    <xsl:call-template name="OutputChapterNumber">
                        <xsl:with-param name="fIgnoreTextAfterLetter" select="'Y'"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:text>.</xsl:text>
                <xsl:number level="any" count="figure" from="chapter | appendix | chapterBeforePart" format="1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="any" count="figure" format="1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        tablenumbered
    -->
    <xsl:template mode="tablenumbered" match="*">
        <xsl:choose>
            <xsl:when test="$chapters">
                <xsl:for-each select="ancestor::chapter | ancestor::appendix | ancestor::chapterBeforePart">
                    <xsl:call-template name="OutputChapterNumber">
                        <xsl:with-param name="fIgnoreTextAfterLetter" select="'Y'"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:text>.</xsl:text>
                <xsl:number level="any" count="tablenumbered" from="chapter | appendix | chapterBeforePart" format="1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="any" count="tablenumbered" format="1"/>
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
    <xsl:template mode="dateLetter" match="*">
        <xsl:param name="date"/>
        <xsl:number level="single" count="refWork[@id=//citation/@ref][refDate=$date]" format="a"/>
    </xsl:template>
    <!-- ===========================================================
      NAMED TEMPLATES
      =========================================================== -->
    <!--
                  AddAnyLinkAttributes
                                    -->
    <xsl:template name="AddAnyLinkAttributes">
        <xsl:if test="$sLinkColor">
            <xsl:attribute name="color">
                <xsl:value-of select="$sLinkColor"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="$sLinkTextDecoration">
            <xsl:attribute name="text-decoration">
                <xsl:value-of select="$sLinkTextDecoration"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!--
      ApplyTemplatesPerTextRefMode
   -->
    <xsl:template name="ApplyTemplatesPerTextRefMode">
        <xsl:param name="mode"/>
        <xsl:choose>
            <xsl:when test="$mode='NoTextRef'">
                <xsl:apply-templates mode="NoTextRef"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="*[name() !='interlinearSource']"/>
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
      DoAbbreviations
   -->
    <xsl:template name="DoAbbreviations">
        <xsl:call-template name="OutputBackMatterItemTitle">
            <xsl:with-param name="sId" select="'rXLingPapAbbreviations'"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputAbbreviationsLabel"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="OutputAbbreviationsInTable"/>
    </xsl:template>
    <!--
                  DoAbstractAcknowledgementsOrPreface
                  -->
    <xsl:template name="DoAbstractAcknowledgementsOrPreface">
        <xsl:param name="bIsBook" select="'Y'"/>
        <xsl:choose>
            <xsl:when test="name(.)='abstract'">
                <xsl:if test="$bIsBook='Y'">
                    <!-- put title in marker so it can show up in running header -->
                    <fo:marker marker-class-name="abstract-title">
                        <xsl:call-template name="OutputAbstractLabel"/>
                    </fo:marker>
                </xsl:if>
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id">rXLingPapAbstract</xsl:with-param>
                    <xsl:with-param name="sTitle">
                        <xsl:call-template name="OutputAbstractLabel"/>
                    </xsl:with-param>
                    <xsl:with-param name="bIsBook" select="$bIsBook"/>
                    <xsl:with-param name="bForcePageBreak" select="$bIsBook"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name(.)='acknowledgements'">
                <xsl:if test="$bIsBook='Y'">
                    <!-- put title in marker so it can show up in running header -->
                    <fo:marker marker-class-name="acknowledgements-title">
                        <xsl:call-template name="OutputAcknowledgementsLabel"/>
                    </fo:marker>
                </xsl:if>
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id">rXLingPapAcknowledgements</xsl:with-param>
                    <xsl:with-param name="sTitle">
                        <xsl:call-template name="OutputAcknowledgementsLabel"/>
                    </xsl:with-param>
                    <xsl:with-param name="bIsBook" select="$bIsBook"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$bIsBook='Y'">
                    <!-- put title in marker so it can show up in running header -->
                    <fo:marker marker-class-name="preface-title">
                        <xsl:call-template name="OutputPrefaceLabel"/>
                    </fo:marker>
                </xsl:if>
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id">rXLingPapPreface</xsl:with-param>
                    <xsl:with-param name="sTitle">
                        <xsl:call-template name="OutputPrefaceLabel"/>
                    </xsl:with-param>
                    <xsl:with-param name="bIsBook" select="$bIsBook"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates/>
    </xsl:template>
    <!--
        DoBook
    -->
    <xsl:template name="DoBook">
        <xsl:param name="book"/>
        <xsl:param name="pages"/>
        <xsl:for-each select="$book">
            <fo:inline font-style="italic">
                <xsl:apply-templates select="../refTitle"/>
            </fo:inline>
            <xsl:text>.  </xsl:text>
            <xsl:if test="translatedBy">
                <xsl:text>Translated by </xsl:text>
                <xsl:value-of select="normalize-space(translatedBy)"/>
                <xsl:call-template name="OutputPeriodIfNeeded">
                    <xsl:with-param name="sText" select="translatedBy"/>
                </xsl:call-template>
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
            <xsl:if test="edition">
                <xsl:value-of select="normalize-space(edition)"/>
                <xsl:call-template name="OutputPeriodIfNeeded">
                    <xsl:with-param name="sText" select="edition"/>
                </xsl:call-template>
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
            <xsl:if test="seriesEd">
                <xsl:value-of select="normalize-space(seriesEd)"/>
                <xsl:call-template name="OutputPeriodIfNeeded">
                    <xsl:with-param name="sText" select="seriesEd"/>
                </xsl:call-template>
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
            <xsl:if test="series">
                <fo:inline font-style="italic">
                    <xsl:value-of select="normalize-space(series)"/>
                </fo:inline>
                <xsl:if test="not(bVol)">
                    <xsl:call-template name="OutputPeriodIfNeeded">
                        <xsl:with-param name="sText" select="series"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
            <xsl:variable name="sPages" select="normalize-space($pages)"/>
            <xsl:choose>
                <xsl:when test="bVol">
                    <xsl:value-of select="normalize-space(bVol)"/>
                    <xsl:if test="string-length($sPages) &gt; 0">
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="$pages"/>
                    </xsl:if>
                    <xsl:call-template name="OutputPeriodIfNeeded">
                        <xsl:with-param name="sText" select="bVol"/>
                    </xsl:call-template>
                    <xsl:text>&#x20;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="string-length($sPages) &gt; 0">
                        <xsl:value-of select="$sPages"/>
                        <xsl:text>. </xsl:text>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="location and publisher">
                    <xsl:value-of select="normalize-space(location)"/>
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="normalize-space(publisher)"/>
                    <xsl:call-template name="OutputPeriodIfNeeded">
                        <xsl:with-param name="sText" select="publisher"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="location">
                    <xsl:value-of select="normalize-space(location)"/>
                    <xsl:call-template name="OutputPeriodIfNeeded">
                        <xsl:with-param name="sText" select="location"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="publisher">
                    <xsl:value-of select="normalize-space(publisher)"/>
                    <xsl:call-template name="OutputPeriodIfNeeded">
                        <xsl:with-param name="sText" select="publisher"/>
                    </xsl:call-template>
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
                  DoContents
                  -->
    <xsl:template name="DoContents">
        <xsl:param name="bIsBook" select="'Y'"/>
        <xsl:choose>
            <xsl:when test="$bIsBook='Y'">
                <xsl:element name="fo:block" use-attribute-sets="NonChapterTitleInfoBook">
                    <xsl:call-template name="OutputChapTitle">
                        <xsl:with-param name="sTitle">
                            <xsl:call-template name="OutputContentsLabel"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="fo:block" use-attribute-sets="NonChapterTitleInfoPaper">
                    <xsl:call-template name="OutputContentsLabel"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="nLevel">
            <xsl:value-of select="number(@showLevel)"/>
        </xsl:variable>
        <!-- acknowledgements -->
        <xsl:if test="//acknowledgements">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink" select="'rXLingPapAcknowledgements'"/>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputAcknowledgementsLabel"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <!-- abstract -->
        <xsl:if test="//abstract">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink" select="'rXLingPapAbstract'"/>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputAbstractLabel"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <!-- preface -->
        <xsl:if test="//preface">
            <xsl:for-each select="//preface">
                <xsl:call-template name="OutputTOCLine">
                    <xsl:with-param name="sLink" select="'rXLingPapPreface'"/>
                    <xsl:with-param name="sLabel">
                        <xsl:call-template name="OutputPrefaceLabel"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
        <!-- part -->
        <xsl:if test="//part">
            <xsl:for-each select="//part">
                <xsl:if test="position()=1">
                    <xsl:for-each select="preceding-sibling::*[name()='chapterBeforePart']">
                        <xsl:call-template name="OutputAllChapterTOC">
                            <xsl:with-param name="nLevel">
                                <xsl:value-of select="$nLevel"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:if>
                <fo:block text-align="center" space-before="{$sBasicPointSize - 4}pt" space-after="{$sBasicPointSize}pt" keep-with-next.within-page="2">
                    <fo:basic-link internal-destination="{@id}">
                        <xsl:call-template name="AddAnyLinkAttributes"/>
                        <xsl:call-template name="OutputPartLabel"/>
                        <xsl:text>&#x20;</xsl:text>
                        <xsl:apply-templates select="." mode="numberPart"/>
                        <xsl:text>&#xa0;</xsl:text>
                        <xsl:apply-templates select="secTitle"/>
                    </fo:basic-link>
                    <xsl:for-each select="chapter">
                        <xsl:call-template name="OutputAllChapterTOC">
                            <xsl:with-param name="nLevel">
                                <xsl:value-of select="$nLevel"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                </fo:block>
            </xsl:for-each>
        </xsl:if>
        <!-- chapter, no parts -->
        <xsl:if test="not(//part) and $chapters">
            <xsl:for-each select="$chapters">
                <xsl:call-template name="OutputAllChapterTOC">
                    <xsl:with-param name="nLevel">
                        <xsl:value-of select="$nLevel"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
        <!-- section, no chapters -->
        <xsl:if test="not(//part) and not($chapters)">
            <xsl:call-template name="OutputAllSectionTOC">
                <xsl:with-param name="nLevel">
                    <xsl:value-of select="$nLevel"/>
                </xsl:with-param>
                <xsl:with-param name="nodesSection1" select="//section1[not(parent::appendix)]"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:for-each select="//appendix">
            <xsl:call-template name="OutputAllChapterTOC">
                <xsl:with-param name="nLevel">
                    <xsl:value-of select="$nLevel"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
        <!--
            <xsl:for-each select="//appendix">
            <li>
            <xsl:element name="a">
            <xsl:attribute name="href">#<xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:apply-templates select="." mode="numberAppendix"/>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
            <xsl:apply-templates select="secTitle"/>
            </xsl:element>
            <xsl:call-template name="OutputAllSectionTOC">
            <xsl:with-param name="nLevel">
            <xsl:value-of select="$nLevel"/>
            </xsl:with-param>
            <xsl:with-param name="nodesSection1" select="section1"/>
            </xsl:call-template>
            </li>
            </xsl:for-each>
            <xsl:if test="//endnote">
            <li>
            <a href="#rXLingPapEndnotes">
            <xsl:call-template name="OutputEndnotesLabel"/>
            </a>
            </li>
            </xsl:if>
        -->
        <xsl:if test="//glossary">
            <xsl:for-each select="//glossary">
                <xsl:variable name="iPos" select="position()"/>
                <xsl:call-template name="OutputTOCLine">
                    <xsl:with-param name="sLink" select="concat('rXLingPapGlossary',$iPos)"/>
                    <xsl:with-param name="sLabel">
                        <xsl:call-template name="OutputGlossaryLabel">
                            <xsl:with-param name="iPos" select="$iPos"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="//references">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink" select="'rXLingPapReferences'"/>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputReferencesLabel"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:for-each select="//index">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink">
                    <xsl:call-template name="CreateIndexID"/>
                </xsl:with-param>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputIndexLabel"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
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
        DoEdPlural
    -->
    <xsl:template name="DoEdPlural">
        <xsl:param name="editor"/>
        <xsl:value-of select="normalize-space($editor)"/>
        <xsl:text>, ed</xsl:text>
        <xsl:if test="$editor/@plural='yes'">
            <xsl:text>s</xsl:text>
        </xsl:if>
        <xsl:text>.</xsl:text>
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
            <xsl:if test="$lingPaper/@figureLabelAndCaptionLocation='before'">
                <fo:block>
                    <xsl:attribute name="space-after">.3em</xsl:attribute>
                    <xsl:attribute name="keep-with-next.within-page">10</xsl:attribute>
                    <xsl:call-template name="OutputFigureLabelAndCaption"/>
                </fo:block>
            </xsl:if>
            <xsl:apply-templates select="*[name()!='caption' and name()!='shortCaption']"/>
            <xsl:if test="$lingPaper/@figureLabelAndCaptionLocation='after'">
                <fo:block>
                    <xsl:attribute name="padding-before">.3em</xsl:attribute>
                    <xsl:attribute name="keep-with-previous.within-page">10</xsl:attribute>
                    <xsl:call-template name="OutputFigureLabelAndCaption"/>
                </fo:block>
            </xsl:if>
        </fo:block>
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
        </xsl:call-template>
        <xsl:apply-templates/>
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
        <xsl:call-template name="OutputIndexTerms">
            <xsl:with-param name="sIndexKind" select="$sIndexKind"/>
            <xsl:with-param name="lang" select="$indexLang"/>
            <xsl:with-param name="terms" select="//lingPaper/indexTerms"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        DoInterlinearFree
    -->
    <xsl:template name="DoInterlinearFree">
        <fo:block keep-with-previous.within-page="1">
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
                <!--              <xsl:if test="preceding-sibling::free[@lang=$sCurrentLanguage][position()=1] or preceding-sibling::free[not(@lang)][position()=1] or name(../..)='interlinear' or name(../..)='listInterlinear' and name(..)='interlinear' and $iParentPosition!=1">-->
                <xsl:attribute name="margin-left">
                    <xsl:text>0.1in</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <fo:inline>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </fo:inline>
            <xsl:if test="$sInterlinearSourceStyle='AfterFree' and not(following-sibling::free)">
                <xsl:if test="name(../..)='example'  or name(../..)='listInterlinear'">
                    <xsl:call-template name="OutputInterlinearTextReference">
                        <xsl:with-param name="sRef" select="../@textref"/>
                        <xsl:with-param name="sSource" select="../interlinearSource"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
        </fo:block>
        <xsl:if test="$sInterlinearSourceStyle='UnderFree' and not(following-sibling::free)">
            <xsl:if test="name(../..)='example' or name(../..)='listInterlinear'">
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
        DoInterlinearLine
    -->
    <xsl:template name="DoInterlinearLine">
        <xsl:param name="mode"/>
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
                        <fo:table-cell xsl:use-attribute-sets="ExampleCell">
                            <xsl:if test="$bRtl='Y'">
                                <xsl:attribute name="text-align">right</xsl:attribute>
                            </xsl:if>
                            <xsl:call-template name="DoDebugExamples"/>
                            <fo:block>
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                                </xsl:call-template>
                                <xsl:apply-templates/>
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
                        <xsl:apply-templates/>
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
                        <!--                  <xsl:if test="string-length(normalize-space(../../@textref)) &gt; 0 or string-length(normalize-space(../../interlinearSource)) &gt; 0">-->
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
        DoInterlinearLineGroup
    -->
    <xsl:template name="DoInterlinearLineGroup">
        <xsl:param name="mode"/>
        <fo:block>
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
            <xsl:if test="name(../..)='interlinear' or name(../..)='listInterlinear' and name(..)='interlinear' and $iParentPosition!=1">
                <xsl:attribute name="margin-left">
                    <xsl:text>0.1in</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="space-before">
                    <xsl:value-of select="$sBasicPointSize div 2"/>
                    <xsl:text>pt</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <fo:table space-before="0pt">
                <xsl:call-template name="DoDebugExamples"/>
                <fo:table-body start-indent="0pt" end-indent="0pt" keep-together.within-page="1">
                    <xsl:call-template name="ApplyTemplatesPerTextRefMode">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>
    <!--  
        DoInterlinearRefCitation
    -->
    <xsl:template name="DoInterlinearRefCitation">
        <xsl:param name="sRef"/>
        <fo:basic-link internal-destination="{$sRef}">
            <xsl:call-template name="AddAnyLinkAttributes"/>
            <xsl:variable name="interlinear" select="key('InterlinearReferenceID',$sRef)"/>
            <xsl:if test="not(@lineNumberOnly) or @lineNumberOnly!='yes'">
                <xsl:value-of select="$interlinear/../textInfo/shortTitle"/>
                <xsl:text>:</xsl:text>
            </xsl:if>
            <xsl:value-of select="count($interlinear/preceding-sibling::interlinear) + 1"/>
        </fo:basic-link>
    </xsl:template>
    <!--  
        DoItemRefLabel
    -->
    <xsl:template name="DoItemRefLabel">
        <xsl:param name="sLabel"/>
        <xsl:param name="sDefault"/>
        <xsl:choose>
            <xsl:when test="string-length($sLabel) &gt; 0">
                <xsl:value-of select="$sLabel"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sDefault"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xa0;</xsl:text>
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
                    <xsl:call-template name="AddAnyLinkAttributes"/>
                    <xsl:value-of select="$refer/../@citename"/>
                    <xsl:text>,&#x20;</xsl:text>
                    <xsl:value-of select="$refer/authorRole"/>
                    <xsl:text>, </xsl:text>
                    <xsl:variable name="sPage" select="normalize-space(@page)"/>
                    <xsl:if test="string-length($sPage) &gt; 0">
                        <xsl:text>&#x20;</xsl:text>
                        <xsl:value-of select="$sPage"/>
                    </xsl:if>
                    <xsl:text>.</xsl:text>
                </fo:basic-link>
            </fo:inline>
            <!--            <xsl:element name="a">
                <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@refToBook"/>
                </xsl:attribute>
                <xsl:value-of select="$refer/../@citename"/>
                <xsl:text>,&#x20;</xsl:text>
                <xsl:value-of select="$refer/authorRole"/>
                <xsl:text>, </xsl:text>
                <xsl:variable name="sPage" select="normalize-space(@page)"/>
                <xsl:if test="string-length($sPage) &gt; 0">
                <xsl:text>&#x20;</xsl:text>
                <xsl:value-of select="$sPage"/>
                </xsl:if>
                <xsl:text>.</xsl:text>
                </xsl:element>
            -->
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoReferences
    -->
    <xsl:template name="DoReferences">
        <xsl:call-template name="OutputBackMatterItemTitle">
            <xsl:with-param name="sId" select="'rXLingPapReferences'"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputReferencesLabel"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="DoRefAuthors"/>
    </xsl:template>
    <!--  
        DoRefWorks
    -->
    <xsl:template name="DoRefWorks">
        <xsl:variable name="thisAuthor" select="."/>
        <xsl:variable name="works" select="refWork[@id=//citation[not(ancestor::comment)]/@ref] | $refWorks[@id=saxon:node-set($collOrProcVolumesToInclude)/refWork/@id][parent::refAuthor=$thisAuthor]"/>
        <xsl:for-each select="$works">
            <fo:block text-indent="-.25in" start-indent=".25in" id="{@id}">
                <xsl:variable name="author">
                    <xsl:value-of select="normalize-space(../@name)"/>
                </xsl:variable>
                <xsl:value-of select="$author"/>
                <xsl:if test="substring($author,string-length($author),string-length($author))!='.'">.</xsl:if>
                <xsl:text>&#x20;  </xsl:text>
                <xsl:if test="authorRole">
                    <xsl:value-of select="authorRole"/>
                    <xsl:text>.  </xsl:text>
                </xsl:if>
                <xsl:variable name="date">
                    <xsl:value-of select="refDate"/>
                </xsl:variable>
                <xsl:value-of select="$date"/>
                <xsl:if test="count($works[refDate=$date])>1">
                    <xsl:apply-templates select="." mode="dateLetter">
                        <xsl:with-param name="date" select="$date"/>
                    </xsl:apply-templates>
                </xsl:if>
                <xsl:text>. </xsl:text>
                <!--
                    book
                -->
                <xsl:if test="book">
                    <xsl:call-template name="DoBook">
                        <xsl:with-param name="book" select="book"/>
                    </xsl:call-template>
                    <!--                        <fo:inline font-style="italic">
                        <xsl:apply-templates select="refTitle"/>
                        </fo:inline>
                        <xsl:text>.  </xsl:text>
                        <xsl:if test="book/translatedBy">
                        <xsl:text>Translated by </xsl:text>
                        <xsl:value-of select="normalize-space(book/translatedBy)"/>
                        <xsl:call-template name="OutputPeriodIfNeeded">
                        <xsl:with-param name="sText" select="book/translatedBy"/>
                        </xsl:call-template>
                        <xsl:text>&#x20;</xsl:text>
                        </xsl:if>
                        <xsl:if test="book/edition">
                        <xsl:value-of select="normalize-space(book/edition)"/>
                        <xsl:call-template name="OutputPeriodIfNeeded">
                        <xsl:with-param name="sText" select="book/edition"/>
                        </xsl:call-template>
                        <xsl:text>&#x20;</xsl:text>
                        </xsl:if>
                        <xsl:if test="book/series">
                        <xsl:value-of select="normalize-space(book/series)"/>
                        <xsl:if test="not(book/bVol)">
                        <xsl:call-template name="OutputPeriodIfNeeded">
                        <xsl:with-param name="sText" select="book/series"/>
                        </xsl:call-template>
                        </xsl:if>
                        <xsl:text>&#x20;</xsl:text>
                        </xsl:if>
                        <xsl:if test="book/bVol">
                        <xsl:value-of select="normalize-space(book/bVol)"/>
                        <xsl:call-template name="OutputPeriodIfNeeded">
                        <xsl:with-param name="sText" select="book/bVol"/>
                        </xsl:call-template>
                        <xsl:text>&#x20;</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(book/location)"/>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="normalize-space(book/publisher)"/>
                        <xsl:call-template name="OutputPeriodIfNeeded">
                        <xsl:with-param name="sText" select="book/publisher"/>
                        </xsl:call-template>
                    -->
                </xsl:if>
                <!--
                    collection
                -->
                <xsl:if test="collection">
                    <xsl:value-of select="$sLdquo"/>
                    <xsl:apply-templates select="refTitle"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="$sRdquo"/>
                    <xsl:text> In </xsl:text>
                    <xsl:choose>
                        <xsl:when test="collection/collCitation">
                            <xsl:variable name="citation" select="collection/collCitation"/>
                            <xsl:choose>
                                <xsl:when test="saxon:node-set($collOrProcVolumesToInclude)/refWork[@id=$citation/@refToBook]">
                                    <xsl:call-template name="DoRefCitation">
                                        <xsl:with-param name="citation" select="$citation"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="FleshOutRefCitation">
                                        <xsl:with-param name="citation" select="$citation"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="DoEdPlural">
                                <xsl:with-param name="editor" select="collection/collEd"/>
                            </xsl:call-template>
                            <xsl:text>&#x20;</xsl:text>
                            <fo:inline font-style="italic">
                                <xsl:value-of select="normalize-space(collection/collTitle)"/>
                            </fo:inline>
                            <xsl:text>.</xsl:text>
                            <xsl:choose>
                                <xsl:when test="collection/collVol">
                                    <xsl:text>&#x20;</xsl:text>
                                    <xsl:value-of select="normalize-space(collection/collVol)"/>
                                    <xsl:text>:</xsl:text>
                                    <xsl:value-of select="normalize-space(collection/collPages)"/>
                                    <xsl:text>. </xsl:text>
                                </xsl:when>
                                <xsl:when test="collection/collPages">
                                    <xsl:if test="collection/collVol">
                                        <xsl:text>,</xsl:text>
                                    </xsl:if>
                                    <xsl:text>&#x20;</xsl:text>
                                    <xsl:value-of select="normalize-space(collection/collPages)"/>
                                    <xsl:text>. </xsl:text>
                                </xsl:when>
                                <!--                                    <xsl:otherwise>
                                    <xsl:text>.</xsl:text>
                                    </xsl:otherwise>
                                -->
                            </xsl:choose>
                            <xsl:if test="collection/seriesEd">
                                <xsl:call-template name="DoEdPlural">
                                    <xsl:with-param name="editor" select="collection/seriesEd"/>
                                </xsl:call-template>
                                <xsl:text>&#x20;</xsl:text>
                            </xsl:if>
                            <xsl:if test="collection/series">
                                <fo:inline font-style="italic">
                                    <xsl:value-of select="normalize-space(collection/series)"/>
                                </fo:inline>
                                <xsl:if test="not(bVol)">
                                    <xsl:call-template name="OutputPeriodIfNeeded">
                                        <xsl:with-param name="sText" select="collection/series"/>
                                    </xsl:call-template>
                                </xsl:if>
                                <xsl:text>&#x20;</xsl:text>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="collection/location">
                                    <xsl:text>&#x20;</xsl:text>
                                    <xsl:value-of select="normalize-space(collection/location)"/>
                                    <xsl:text>: </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>&#x20;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="collection/publisher">
                                <xsl:value-of select="normalize-space(collection/publisher)"/>
                                <xsl:call-template name="OutputPeriodIfNeeded">
                                    <xsl:with-param name="sText" select="collection/publisher"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <!--
                    dissertation
                -->
                <xsl:if test="dissertation">
                    <fo:inline font-style="italic">
                        <xsl:apply-templates select="refTitle"/>
                    </fo:inline>
                    <xsl:text>.  </xsl:text>
                    <xsl:call-template name="OutputLabel">
                        <xsl:with-param name="sDefault">Ph.D. dissertation</xsl:with-param>
                        <xsl:with-param name="pLabel" select="//references/@labelDissertation"/>
                    </xsl:call-template>
                    <xsl:text>. </xsl:text>
                    <xsl:if test="dissertation/location">
                        <xsl:text>(</xsl:text>
                        <xsl:value-of select="normalize-space(dissertation/location)"/>
                        <xsl:text>).  </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(dissertation/institution)"/>
                    <xsl:text>.</xsl:text>
                    <xsl:if test="dissertation/published">
                        <xsl:text>  Published by </xsl:text>
                        <xsl:value-of select="normalize-space(dissertation/published/location)"/>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="normalize-space(dissertation/published/publisher)"/>
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="normalize-space(dissertation/published/pubDate)"/>
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                </xsl:if>
                <!--
                    journal article
                -->
                <xsl:if test="article">
                    <xsl:apply-templates select="refTitle"/>
                    <xsl:text>.</xsl:text>
                    <xsl:text>&#x20;</xsl:text>
                    <fo:inline font-style="italic">
                        <xsl:value-of select="normalize-space(article/jTitle)"/>
                        <xsl:text>&#x20;</xsl:text>
                        <xsl:value-of select="normalize-space(article/jVol)"/>
                        <xsl:if test="article/jIssueNumber">
                            <xsl:text>(</xsl:text>
                            <xsl:value-of select="article/jIssueNumber"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="article/jPages">
                                <xsl:text>:</xsl:text>
                                <xsl:value-of select="normalize-space(article/jPages)"/>
                            </xsl:when>
                            <xsl:when test="article/jArticleNumber">
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="normalize-space(article/jArticleNumber)"/>
                            </xsl:when>
                        </xsl:choose>
                    </fo:inline>
                    <xsl:text>.</xsl:text>
                </xsl:if>
                <!--
                    ms (manuscript)
                -->
                <xsl:if test="ms or fieldNotes">
                    <xsl:value-of select="$sLdquo"/>
                    <xsl:apply-templates select="refTitle"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="$sRdquo"/>
                    <xsl:text>&#x20;</xsl:text>
                    <xsl:if test="ms/location">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="normalize-space(ms/location)"/>
                        <xsl:text>).  </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(ms/institution)"/>
                    <xsl:choose>
                        <xsl:when test="ms">
                            <xsl:text> ms.</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>.</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <!--
                    paper
                -->
                <xsl:if test="paper">
                    <xsl:value-of select="$sLdquo"/>
                    <xsl:apply-templates select="refTitle"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="$sRdquo"/>
                    <xsl:text>  Paper presented at the </xsl:text>
                    <xsl:value-of select="normalize-space(paper/conference)"/>
                    <xsl:if test="paper/location">
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="normalize-space(paper/location)"/>
                    </xsl:if>
                    <xsl:text>.</xsl:text>
                </xsl:if>
                <!--
                    proceedings
                -->
                <xsl:if test="proceedings">
                    <xsl:value-of select="$sLdquo"/>
                    <xsl:apply-templates select="refTitle"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="$sRdquo"/>
                    <xsl:choose>
                        <xsl:when test="proceedings/procCitation">
                            <xsl:text>  In </xsl:text>
                            <xsl:variable name="citation" select="proceedings/procCitation"/>
                            <xsl:choose>
                                <xsl:when test="saxon:node-set($collOrProcVolumesToInclude)/refWork[@id=$citation/@refToBook]">
                                    <xsl:call-template name="DoRefCitation">
                                        <xsl:with-param name="citation" select="$citation"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="FleshOutRefCitation">
                                        <xsl:with-param name="citation" select="$citation"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="proceedings/procEd">
                                    <xsl:text>  In </xsl:text>
                                    <xsl:call-template name="DoEdPlural">
                                        <xsl:with-param name="editor" select="proceedings/procEd"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>&#x20;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <!--                            <xsl:when test="proceedings/procEd">
                                <xsl:text>  In </xsl:text>
                                <xsl:value-of select="normalize-space(proceedings/procEd)"/>
                                <xsl:text>, ed</xsl:text>
                                <xsl:if test="proceedings/procEd/@plural='yes'">
                                <xsl:text>s</xsl:text>
                                </xsl:if>
                                <xsl:text>. </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                <xsl:text>&#x20;</xsl:text>
                                </xsl:otherwise>
                                </xsl:choose>-->
                            <fo:inline font-style="italic">
                                <xsl:value-of select="normalize-space(proceedings/procTitle)"/>
                            </fo:inline>
                            <xsl:choose>
                                <xsl:when test="proceedings/procVol">
                                    <xsl:text>&#x20;</xsl:text>
                                    <xsl:value-of select="normalize-space(proceedings/procVol)"/>
                                    <xsl:text>:</xsl:text>
                                    <xsl:value-of select="normalize-space(proceedings/procPages)"/>
                                    <xsl:text>. </xsl:text>
                                </xsl:when>
                                <xsl:when test="proceedings/procPages">
                                    <xsl:text>, </xsl:text>
                                    <xsl:value-of select="normalize-space(proceedings/procPages)"/>
                                    <xsl:text>. </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>. </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="proceedings/location or proceedings/publisher">
                                <xsl:value-of select="normalize-space(proceedings/location)"/>
                                <xsl:if test="proceedings/publisher">
                                    <xsl:text>: </xsl:text>
                                    <xsl:value-of select="normalize-space(proceedings/publisher)"/>
                                </xsl:if>
                                <xsl:text>.</xsl:text>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <!--
                    thesis
                -->
                <xsl:if test="thesis">
                    <fo:inline font-style="italic">
                        <xsl:apply-templates select="refTitle"/>
                    </fo:inline>
                    <xsl:text>.  </xsl:text>
                    <xsl:call-template name="OutputLabel">
                        <xsl:with-param name="sDefault">M.A. thesis</xsl:with-param>
                        <xsl:with-param name="pLabel" select="//references/@labelThesis"/>
                    </xsl:call-template>
                    <xsl:text>. </xsl:text>
                    <xsl:if test="thesis/location">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="normalize-space(thesis/location)"/>
                        <xsl:text>).  </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(thesis/institution)"/>
                    <xsl:text>.</xsl:text>
                    <xsl:if test="thesis/published">
                        <xsl:text>  Published by </xsl:text>
                        <xsl:value-of select="normalize-space(thesis/published/location)"/>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="normalize-space(thesis/published/publisher)"/>
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="normalize-space(thesis/published/pubDate)"/>
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                </xsl:if>
                <!--
                    webPage
                -->
                <xsl:if test="webPage">
                    <xsl:value-of select="$sLdquo"/>
                    <xsl:apply-templates select="refTitle"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="$sRdquo"/>
                    <xsl:text>&#x20;</xsl:text>
                    <xsl:if test="webPage/edition">
                        <xsl:value-of select="normalize-space(webPage/edition)"/>
                        <xsl:call-template name="OutputPeriodIfNeeded">
                            <xsl:with-param name="sText" select="webPage/edition"/>
                        </xsl:call-template>
                        <xsl:text>&#x20;</xsl:text>
                    </xsl:if>
                    <xsl:if test="webPage/location">
                        <xsl:value-of select="normalize-space(webPage/location)"/>
                        <xsl:text>: </xsl:text>
                    </xsl:if>
                    <xsl:if test="webPage/institution">
                        <xsl:value-of select="normalize-space(webPage/institution)"/>
                        <xsl:text>. </xsl:text>
                    </xsl:if>
                    <xsl:if test="webPage/publisher">
                        <xsl:value-of select="normalize-space(webPage/publisher)"/>
                    </xsl:if>
                    <xsl:text> (</xsl:text>
                    <fo:basic-link external-destination="url({normalize-space(webPage/url)})">
                        <xsl:call-template name="AddAnyLinkAttributes"/>
                        <xsl:value-of select="normalize-space(webPage/url)"/>
                    </fo:basic-link>
                    <xsl:text>).</xsl:text>
                    <xsl:if test="webPage/dateAccessed">
                        <xsl:text>  (accessed </xsl:text>
                        <xsl:value-of select="normalize-space(webPage/dateAccessed)"/>
                        <xsl:text>).</xsl:text>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="url">
                    <fo:basic-link external-destination="url({normalize-space(url)})">
                        <xsl:call-template name="AddAnyLinkAttributes"/>
                        <xsl:text>&#x20;</xsl:text>
                        <xsl:value-of select="normalize-space(url)"/>
                    </fo:basic-link>
                    <xsl:if test="dateAccessed">
                        <xsl:text>  (accessed </xsl:text>
                        <xsl:value-of select="normalize-space(dateAccessed)"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:text>.</xsl:text>
                </xsl:if>
                <xsl:for-each select="iso639-3code">
                    <xsl:sort/>
                    <fo:inline font-size="smaller">
                        <xsl:if test="position() = 1">
                            <xsl:text>  [</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="."/>
                        <xsl:if test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                        <xsl:if test="position() = last()">
                            <xsl:text>]</xsl:text>
                        </xsl:if>
                    </fo:inline>
                </xsl:for-each>
            </fo:block>
        </xsl:for-each>
    </xsl:template>
    <!--  
                  DoSecTitleRunningHeader
-->
    <xsl:template name="DoSecTitleRunningHeader">
        <xsl:choose>
            <xsl:when test="string-length(following-sibling::shortTitle) &gt; 0">
                <xsl:apply-templates select="following-sibling::shortTitle"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="secTitle"/>
            </xsl:otherwise>
        </xsl:choose>
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
            <xsl:if test="$lingPaper/@tablenumberedLabelAndCaptionLocation='before'">
                <fo:block>
                    <xsl:attribute name="space-after">.3em</xsl:attribute>
                    <xsl:attribute name="keep-with-next.within-page">10</xsl:attribute>
                    <xsl:call-template name="OutputTableNumberedLabelAndCaption"/>
                </fo:block>
            </xsl:if>
            <xsl:apply-templates select="*[name()!='caption' and name()!='shortCaption']"/>
            <xsl:if test="$lingPaper/@tablenumberedLabelAndCaptionLocation='after'">
                <fo:block>
                    <xsl:attribute name="padding-before">.3em</xsl:attribute>
                    <xsl:attribute name="keep-with-previous.within-page">10</xsl:attribute>
                    <xsl:call-template name="OutputTableNumberedLabelAndCaption"/>
                </fo:block>
            </xsl:if>
        </fo:block>
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
        FleshOutRefCitation
    -->
    <xsl:template name="FleshOutRefCitation">
        <xsl:param name="citation"/>
        <xsl:variable name="citedWork" select="key('RefWorkID',$citation/@refToBook)"/>
        <xsl:call-template name="ConvertLastNameFirstNameToFirstNameLastName">
            <xsl:with-param name="sCitedWorkAuthor" select="$citedWork/../@name"/>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="$citedWork/authorRole">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="$citedWork/authorRole"/>
                <xsl:call-template name="OutputPeriodIfNeeded">
                    <xsl:with-param name="sText" select="$citedWork/authorRole"/>
                </xsl:call-template>
                <xsl:text>&#x20;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>.  </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="DoBook">
            <xsl:with-param name="book" select="$citedWork/book"/>
            <xsl:with-param name="pages" select="$citation/@page"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
      ExampleNumber
   -->
    <xsl:template name="GetExampleNumber">
        <xsl:param name="example"/>
        <xsl:for-each select="$example">
            <xsl:choose>
                <xsl:when test="ancestor::endnote">
                    <xsl:apply-templates select="." mode="exampleInEndnote"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="example"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
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
            <xsl:text> = </xsl:text>
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
      OutputAbbreviationsLabel
   -->
    <xsl:template name="OutputAbbreviationsLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Abbreviations</xsl:with-param>
            <xsl:with-param name="pLabel" select="//abbreviations/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      OutputAbbrDefinition
   -->
    <xsl:template name="OutputAbbrDefinition">
        <xsl:param name="abbr"/>
        <xsl:choose>
            <xsl:when test="string-length($abbrLang) &gt; 0">
                <xsl:choose>
                    <xsl:when test="string-length($abbr//abbrInLang[@lang=$abbrLang]/abbrTerm) &gt; 0">
                        <xsl:value-of select="$abbr/abbrInLang[@lang=$abbrLang]/abbrDefinition"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- a language is specified, but this abbreviation does not have anything; try using the default;
                     this assumes that something is better than nothing -->
                        <xsl:value-of select="$abbr/abbrInLang[1]/abbrDefinition"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!--  no language specified; just use the first one -->
                <xsl:value-of select="$abbr/abbrInLang[1]/abbrDefinition"/>
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
        <fo:inline>
            <xsl:if test="$abbreviations/@usesmallcaps='yes'">
                <xsl:call-template name="HandleSmallCaps"/>
            </xsl:if>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$abbreviations"/>
            </xsl:call-template>
            <xsl:value-of select="$sAbbrTerm"/>
        </fo:inline>
    </xsl:template>
    <!--
                   OutputAbstractLabel
-->
    <xsl:template name="OutputAbstractLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Abstract</xsl:with-param>
            <xsl:with-param name="pLabel" select="//abstract/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
                   OutputAcknowledgementsLabel
-->
    <xsl:template name="OutputAcknowledgementsLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Acknowledgements</xsl:with-param>
            <xsl:with-param name="pLabel" select="//acknowledgements/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputAnyTextBeforeFigureRef
    -->
    <xsl:template name="OutputAnyTextBeforeFigureRef">
        <!-- output any canned text before the section reference -->
        <xsl:variable name="lingPaper" select="//lingPaper"/>
        <xsl:variable name="ssingular" select="'figure'"/>
        <xsl:variable name="splural" select="'figures'"/>
        <xsl:variable name="sSingular" select="'Figure'"/>
        <xsl:variable name="sPlural" select="'Figures'"/>
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
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@figureRefDefault='capitalizedSingular'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@figureRefCapitalizedSingularLabel"/>
                            <xsl:with-param name="sDefault" select="$sSingular"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@figureRefDefault='plural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@figureRefPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$splural"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@figureRefDefault='capitalizedPlural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@figureRefCapitalizedPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$sPlural"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@textBefore='singular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@figureRefSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$ssingular"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedSingular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@figureRefCapitalizedSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$sSingular"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='plural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@figureRefPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$splural"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedPlural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@figureRefCapitalizedPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$sPlural"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
      OutputAnyTextBeforeSectionRef
   -->
    <xsl:template name="OutputAnyTextBeforeSectionRef">
        <!-- output any canned text before the section reference -->
        <xsl:variable name="lingPaper" select="//lingPaper"/>
        <xsl:variable name="ssingular" select="'section'"/>
        <xsl:variable name="splural" select="'sections'"/>
        <xsl:variable name="sSingular" select="'Section'"/>
        <xsl:variable name="sPlural" select="'Sections'"/>
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
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@sectionRefDefault='capitalizedSingular'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedSingularLabel"/>
                            <xsl:with-param name="sDefault" select="$sSingular"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@sectionRefDefault='plural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$splural"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@sectionRefDefault='capitalizedPlural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$sPlural"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@textBefore='singular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$ssingular"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedSingular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$sSingular"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='plural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$splural"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedPlural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$sPlural"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        OutputAnyTextBeforeTablenumberedRef
    -->
    <xsl:template name="OutputAnyTextBeforeTablenumberedRef">
        <!-- output any canned text before the section reference -->
        <xsl:variable name="lingPaper" select="//lingPaper"/>
        <xsl:variable name="ssingular" select="'table'"/>
        <xsl:variable name="splural" select="'tables'"/>
        <xsl:variable name="sSingular" select="'Table'"/>
        <xsl:variable name="sPlural" select="'Tables'"/>
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
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@tablenumberedRefDefault='capitalizedSingular'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefCapitalizedSingularLabel"/>
                            <xsl:with-param name="sDefault" select="$sSingular"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@tablenumberedRefDefault='plural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$splural"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@tablenumberedRefDefault='capitalizedPlural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefCapitalizedPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$sPlural"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@textBefore='singular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$ssingular"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedSingular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefCapitalizedSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$sSingular"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='plural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$splural"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedPlural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@tablenumberedRefCapitalizedPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$sPlural"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        OutputAuthorFootnoteSymbol
    -->
    <xsl:template name="OutputAuthorFootnoteSymbol">
        <xsl:param name="iAuthorPosition"/>
        <xsl:choose>
            <xsl:when test="$iAuthorPosition=1">
                <xsl:text>*</xsl:text>
            </xsl:when>
            <xsl:when test="$iAuthorPosition=2">
                <xsl:text>†</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>‡</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
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
        <xsl:choose>
            <xsl:when test="$chapters">
                <fo:block id="{$sId}" font-size="18pt" font-weight="bold" break-before="page" margin-top="176pt" margin-bottom="10.8pt" text-align="center" span="all">
                    <xsl:call-template name="OutputChapTitle">
                        <xsl:with-param name="sTitle" select="$sLabel"/>
                    </xsl:call-template>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block id="{$sId}" font-weight="bold" text-align="center" keep-with-next.within-page="always" span="all">
                    <xsl:attribute name="font-size">
                        <xsl:value-of select="$sBackMatterItemTitlePointSize"/>
                        <xsl:text>pt</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="space-before">
                        <xsl:value-of select="2*$sBasicPointSize"/>pt</xsl:attribute>
                    <xsl:attribute name="space-after">
                        <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
                    <xsl:call-template name="DoType"/>
                    <fo:marker marker-class-name="section-title">
                        <xsl:value-of select="$sLabel"/>
                    </fo:marker>
                    <xsl:value-of select="$sLabel"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputChapterNumber
-->
    <xsl:template name="OutputChapterNumber">
        <xsl:choose>
            <xsl:when test="name()='chapter'">
                <xsl:apply-templates select="." mode="numberChapter"/>
            </xsl:when>
            <xsl:when test="name()='chapterBeforePart'">
                <xsl:text>0</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="numberAppendix"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputChapterStaticContent
-->
    <xsl:template name="OutputChapterStaticContent">
        <xsl:param name="sSectionTitle" select="'section-title'"/>
        <xsl:param name="bUseFirstPage" select="'Y'"/>
        <xsl:if test="$bUseFirstPage='Y'">
            <fo:static-content flow-name="ChapterFirstPage-after" display-align="after">
                <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                    <xsl:attribute name="text-align">center</xsl:attribute>
                    <xsl:attribute name="margin-top">6pt</xsl:attribute>
                    <fo:page-number/>
                </xsl:element>
            </fo:static-content>
        </xsl:if>
        <fo:static-content flow-name="ChapterEvenPage-before" display-align="before">
            <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                <xsl:attribute name="text-align-last">justify</xsl:attribute>
                <fo:inline>
                    <fo:page-number/>
                </fo:inline>
                <fo:leader/>
                <fo:inline>
                    <fo:retrieve-marker retrieve-class-name="chap-title"/>
                </fo:inline>
            </xsl:element>
        </fo:static-content>
        <fo:static-content flow-name="ChapterOddPage-before" display-align="before">
            <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                <xsl:attribute name="text-align-last">justify</xsl:attribute>
                <fo:inline>
                    <fo:retrieve-marker retrieve-class-name="{$sSectionTitle}"/>
                </fo:inline>
                <fo:leader/>
                <fo:inline>
                    <fo:page-number/>
                </fo:inline>
            </xsl:element>
        </fo:static-content>
        <fo:static-content flow-name="xsl-footnote-separator">
            <fo:block text-align="left">
                <fo:leader leader-pattern="rule" leader-length="2in"/>
            </fo:block>
        </fo:static-content>
    </xsl:template>
    <!--  
                  OutputChapTitle
-->
    <xsl:template name="OutputChapTitle">
        <xsl:param name="sTitle"/>
        <fo:block font-size="18pt" font-weight="bold" span="all">
            <xsl:value-of select="$sTitle"/>
        </fo:block>
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
                   OutputContentsLabel
-->
    <xsl:template name="OutputContentsLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Contents</xsl:with-param>
            <xsl:with-param name="pLabel" select="//contents/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
                   OutputEndnotesLabel
-->
    <xsl:template name="OutputEndnotesLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Endnotes</xsl:with-param>
            <xsl:with-param name="pLabel" select="//endnotes/@label"/>
        </xsl:call-template>
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
        <xsl:variable name="label" select="$lingPaper/@figureLabel"/>
        <xsl:choose>
            <xsl:when test="string-length($label) &gt; 0">
                <xsl:value-of select="$label"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Figure </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputFigureLabelAndCaption
    -->
    <xsl:template name="OutputFigureLabelAndCaption">
        <xsl:param name="bDoBold" select="'Y'"/>
        <xsl:param name="bDoStyles" select="'Y'"/>
        <fo:inline>
            <xsl:if test="$bDoBold='Y'">
                <xsl:attribute name="font-weight">
                    <xsl:text>bold</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputFigureLabel"/>
            <xsl:apply-templates select="." mode="figure"/>
            <xsl:text>&#xa0;</xsl:text>
        </fo:inline>
        <xsl:choose>
            <xsl:when test="$bDoStyles='Y'">
                <xsl:apply-templates select="caption" mode="show"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="caption" mode="contents"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputFontAttributes
-->
    <xsl:template name="OutputFontAttributes">
        <xsl:param name="language"/>
        <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="$language/@xsl-foSpecial"/>
        </xsl:call-template>
        <xsl:if test="string-length(normalize-space($language/@font-family)) &gt; 0">
            <xsl:attribute name="font-family">
                <xsl:value-of select="$language/@font-family"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($language/@font-size)) &gt; 0">
            <xsl:attribute name="font-size">
                <xsl:value-of select="$language/@font-size"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($language/@font-style)) &gt; 0">
            <xsl:attribute name="font-style">
                <xsl:value-of select="$language/@font-style"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="string-length(normalize-space($language/@font-variant)) &gt; 0">
            <xsl:choose>
                <xsl:when test="$language/@font-variant='small-caps'">
                    <xsl:call-template name="HandleSmallCaps"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="font-variant">
                        <xsl:value-of select="$language/@font-variant"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
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
    </xsl:template>
    <!--  
                  OutputFrontOrBackMatterTitle
-->
    <xsl:template name="OutputFrontOrBackMatterTitle">
        <xsl:param name="id"/>
        <xsl:param name="sTitle"/>
        <xsl:param name="bIsBook" select="'Y'"/>
        <xsl:param name="bForcePageBreak" select="'N'"/>
        <xsl:choose>
            <xsl:when test="$bIsBook='Y'">
                <xsl:element name="fo:block" use-attribute-sets="NonChapterTitleInfoBook">
                    <xsl:attribute name="id">
                        <xsl:value-of select="$id"/>
                    </xsl:attribute>
                    <xsl:call-template name="OutputChapTitle">
                        <xsl:with-param name="sTitle" select="$sTitle"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="fo:block" use-attribute-sets="NonChapterTitleInfoPaper">
                    <xsl:attribute name="id">
                        <xsl:value-of select="$id"/>
                    </xsl:attribute>
                    <xsl:if test="$bForcePageBreak='Y'">
                        <xsl:attribute name="break-before">
                            <xsl:text>page</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$sTitle"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
                   OutputGlossaryLabel
-->
    <xsl:template name="OutputGlossaryLabel">
        <xsl:param name="iPos" select="'1'"/>
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Glossary</xsl:with-param>
            <xsl:with-param name="pLabel" select="//glossary[$iPos]/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
                   OutputIndexLabel
-->
    <xsl:template name="OutputIndexLabel">
        <xsl:variable name="sDefaultIndexLabel">
            <xsl:choose>
                <xsl:when test="@kind='name'">
                    <xsl:text>Name Index</xsl:text>
                </xsl:when>
                <xsl:when test="@kind='language'">
                    <xsl:text>Language Index</xsl:text>
                </xsl:when>
                <xsl:when test="@kind='subject'">
                    <xsl:text>Subject Index</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Index</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault" select="$sDefaultIndexLabel"/>
            <xsl:with-param name="pLabel" select="@label"/>
        </xsl:call-template>
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
                <xsl:call-template name="AddAnyLinkAttributes"/>
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
        <fo:static-content flow-name="xsl-footnote-separator">
            <fo:block text-align="left">
                <fo:leader leader-pattern="rule" leader-length="2in"/>
            </fo:block>
        </fo:static-content>
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
                                            <xsl:call-template name="AddAnyLinkAttributes"/>
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
                                        <xsl:call-template name="AddAnyLinkAttributes"/>
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
        OutputInterlinearTextReference
    -->
    <xsl:template name="OutputInterlinearTextReference">
        <xsl:param name="sRef"/>
        <xsl:param name="sSource"/>
        <xsl:if test="string-length(normalize-space($sRef)) &gt; 0 or $sSource">
            <xsl:choose>
                <xsl:when test="$sInterlinearSourceStyle='AfterFree'">
                    <fo:inline>
                        <xsl:text disable-output-escaping="yes">&#xa0;&#xa0;</xsl:text>
                        <xsl:call-template name="OutputInterlinearTextReferenceContent">
                            <xsl:with-param name="sSource" select="$sSource"/>
                            <xsl:with-param name="sRef" select="$sRef"/>
                        </xsl:call-template>
                    </fo:inline>
                </xsl:when>
                <xsl:otherwise>
                    <fo:block>
                        <xsl:text disable-output-escaping="yes">&#xa0;&#xa0;</xsl:text>
                        <xsl:call-template name="OutputInterlinearTextReferenceContent">
                            <xsl:with-param name="sSource" select="$sSource"/>
                            <xsl:with-param name="sRef" select="$sRef"/>
                        </xsl:call-template>
                    </fo:block>
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
        <xsl:text>[</xsl:text>
        <xsl:choose>
            <xsl:when test="$sSource">
                <!--            <xsl:value-of select="$sSource"/>-->
                <xsl:apply-templates select="$sSource" mode="contents"/>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($sRef)) &gt; 0">
                <fo:inline>
                    <fo:basic-link>
                        <xsl:attribute name="internal-destination">
                            <xsl:value-of select="$sRef"/>
                        </xsl:attribute>
                        <xsl:call-template name="AddAnyLinkAttributes"/>
                        <xsl:variable name="interlinear" select="key('InterlinearReferenceID',$sRef)"/>
                        <xsl:value-of select="$interlinear/../textInfo/shortTitle"/>
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="count($interlinear/preceding-sibling::interlinear) + 1"/>
                    </fo:basic-link>
                </fo:inline>
            </xsl:when>
        </xsl:choose>
        <xsl:text>]</xsl:text>
    </xsl:template>
    <!--  
                  OutputLabel
-->
    <xsl:template name="OutputLabel">
        <xsl:param name="sDefault"/>
        <xsl:param name="pLabel"/>
        <xsl:choose>
            <xsl:when test="$pLabel">
                <xsl:value-of select="$pLabel"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sDefault"/>
            </xsl:otherwise>
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
                                <xsl:text>.</xsl:text>
                            </fo:block>
                        </fo:table-cell>
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
                    <xsl:for-each select="following-sibling::listWord | following-sibling::listSingle | following-sibling::listInterlinear | following-sibling::listDefinition">
                        <xsl:if test="name()='listInterlinear'">
                            <!-- output a fake row to add spacing between iterlinears -->
                            <fo:table-row>
                                <fo:table-cell>
                                    <fo:block>&#xa0;</fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </xsl:if>
                        <fo:table-row>
                            <fo:table-cell text-align="start" end-indent=".2em">
                                <xsl:call-template name="DoDebugExamples"/>
                                <fo:block>
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="@letter"/>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="." mode="letter"/>
                                    <xsl:text>.</xsl:text>
                                </fo:block>
                            </fo:table-cell>
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
                    </xsl:for-each>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>
    <!--  
                  OutputPeriodIfNeeded
-->
    <xsl:template name="OutputPeriodIfNeeded">
        <xsl:param name="sText"/>
        <xsl:variable name="sString">
            <xsl:value-of select="normalize-space($sText)"/>
        </xsl:variable>
        <xsl:if test="substring($sString, string-length($sString))!='.'">
            <xsl:text>.</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--
                   OutputPartLabel
-->
    <xsl:template name="OutputPartLabel">
        <xsl:choose>
            <xsl:when test="$lingPaper/@partlabel">
                <xsl:value-of select="$lingPaper/@partlabel"/>
            </xsl:when>
            <xsl:otherwise>Part</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
                   OutputPrefaceLabel
-->
    <xsl:template name="OutputPrefaceLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Preface</xsl:with-param>
            <xsl:with-param name="pLabel" select="@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
                   OutputReferencesLabel
-->
    <xsl:template name="OutputReferencesLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">References</xsl:with-param>
            <xsl:with-param name="pLabel" select="//references/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
                  OutputSection
-->
    <xsl:template name="OutputSection">
        <xsl:call-template name="DoType"/>
        <!-- put title in marker so it can show up in running header -->
        <fo:marker marker-class-name="section-title">
            <xsl:call-template name="DoSecTitleRunningHeader"/>
        </fo:marker>
        <xsl:call-template name="OutputSectionNumberAndTitle"/>
    </xsl:template>
    <!--  
                  OutputSectionNumberAndTitle
-->
    <xsl:template name="OutputSectionNumberAndTitle">
        <xsl:variable name="bAppendix">
            <xsl:for-each select="ancestor::*">
                <xsl:if test="name(.)='appendix'">Y</xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$bAppendix='Y'">
                <xsl:apply-templates select="." mode="numberAppendix"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="number"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text disable-output-escaping="yes">&#x20;</xsl:text>
        <xsl:apply-templates select="secTitle"/>
    </xsl:template>
    <!--  
                  OutputAllChapterTOC
-->
    <xsl:template name="OutputAllChapterTOC">
        <xsl:param name="nLevel" select="3"/>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputChapterNumber"/>
                <xsl:text>&#xa0;</xsl:text>
                <xsl:apply-templates select="secTitle"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="section1">
                <xsl:call-template name="OutputAllSectionTOC">
                    <xsl:with-param name="nLevel">
                        <xsl:value-of select="$nLevel"/>
                    </xsl:with-param>
                    <xsl:with-param name="nodesSection1" select="section1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="section2">
                <!-- only for appendix -->
                <xsl:call-template name="OutputAllSectionTOC">
                    <xsl:with-param name="nLevel">
                        <xsl:value-of select="$nLevel"/>
                    </xsl:with-param>
                    <xsl:with-param name="nodesSection1" select="section2"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputAllSectionTOC
-->
    <xsl:template name="OutputAllSectionTOC">
        <xsl:param name="nLevel" select="3"/>
        <xsl:param name="nodesSection1"/>
        <xsl:for-each select="$nodesSection1">
            <xsl:call-template name="OutputSectionTOC">
                <xsl:with-param name="sLevel" select="'1'"/>
            </xsl:call-template>
            <xsl:if test="section2 and $nLevel>=2">
                <xsl:for-each select="section2">
                    <xsl:call-template name="OutputSectionTOC">
                        <xsl:with-param name="sLevel" select="'2'"/>
                    </xsl:call-template>
                    <xsl:if test="section3 and $nLevel>=3">
                        <xsl:for-each select="section3">
                            <xsl:call-template name="OutputSectionTOC">
                                <xsl:with-param name="sLevel" select="'3'"/>
                            </xsl:call-template>
                            <xsl:if test="section4 and $nLevel>=4">
                                <xsl:for-each select="section4">
                                    <xsl:call-template name="OutputSectionTOC">
                                        <xsl:with-param name="sLevel" select="'4'"/>
                                    </xsl:call-template>
                                    <xsl:if test="section5 and $nLevel>=5">
                                        <xsl:for-each select="section5">
                                            <xsl:call-template name="OutputSectionTOC">
                                                <xsl:with-param name="sLevel" select="'5'"/>
                                            </xsl:call-template>
                                            <xsl:if test="section6 and $nLevel>=6">
                                                <xsl:for-each select="section6">
                                                    <xsl:call-template name="OutputSectionTOC">
                                                        <xsl:with-param name="sLevel" select="'6'"/>
                                                    </xsl:call-template>
                                                </xsl:for-each>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!--  
                  OutputSectionTOC
-->
    <xsl:template name="OutputSectionTOC">
        <xsl:param name="sLevel"/>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputSectionNumberAndTitle"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent" select="$sLevel"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
                  OutputTable
-->
    <xsl:template name="OutputTable">
        <!--                <fo:table space-before="0pt" keep-together.within-page="1"> -->
        <!--        <fo:table space-before="0pt" keep-together.within-page="auto">-->
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
        <fo:table-cell text-align="{$sAlign}" xsl:use-attribute-sets="ExampleCell">
            <xsl:call-template name="DoDebugExamples"/>
            <fo:block>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="key('LanguageID',$lang)"/>
                </xsl:call-template>
                <xsl:value-of select="$sFirst"/>
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
        OutputTableNumberedLabelAndCaption
    -->
    <xsl:template name="OutputTableNumberedLabelAndCaption">
        <xsl:param name="bDoBold" select="'Y'"/>
        <xsl:param name="bDoStyles" select="'Y'"/>
        <fo:inline>
            <xsl:if test="$bDoBold='Y'">
                <xsl:attribute name="font-weight">
                    <xsl:text>bold</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputTableNumberedLabel"/>
            <xsl:apply-templates select="." mode="tablenumbered"/>
            <xsl:text>&#xa0;</xsl:text>
        </fo:inline>
        <xsl:choose>
            <xsl:when test="$bDoStyles='Y'">
                <xsl:apply-templates select="table/caption | table/endCaption" mode="show"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="table/caption | table/endCaption" mode="contents"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputTableNumberedLabel
    -->
    <xsl:template name="OutputTableNumberedLabel">
        <xsl:variable name="label" select="$lingPaper/@tablenumberedLabel"/>
        <xsl:choose>
            <xsl:when test="string-length($label) &gt; 0">
                <xsl:value-of select="$label"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Table </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputTOCLine
-->
    <xsl:template name="OutputTOCLine">
        <xsl:param name="sLink"/>
        <xsl:param name="sLabel"/>
        <xsl:param name="sSpaceBefore" select="'0'"/>
        <xsl:param name="sIndent" select="'0'"/>
        <fo:block text-align-last="justify">
            <xsl:if test="number($sSpaceBefore)>0">
                <xsl:attribute name="space-before">
                    <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
            </xsl:if>
            <xsl:if test="$sIndent!='0'">
                <xsl:attribute name="text-indent">-<xsl:value-of select="$sIndent div 2 + 1.5"/>em</xsl:attribute>
                <xsl:attribute name="start-indent">
                    <xsl:value-of select="1.5 * $sIndent + 1.5"/>em</xsl:attribute>
            </xsl:if>
            <fo:basic-link internal-destination="{$sLink}">
                <xsl:call-template name="AddAnyLinkAttributes"/>
                <fo:inline>
                    <xsl:copy-of select="$sLabel"/>
                    <xsl:text>&#xa0;</xsl:text>
                    <fo:leader leader-pattern="dots">
                        <xsl:if test="$sFOProcessor='XFC'">
                            <xsl:attribute name="xfc:tab-position">-30pt</xsl:attribute>
                            <xsl:attribute name="xfc:tab-align">right</xsl:attribute>
                        </xsl:if>
                    </fo:leader>
                    <xsl:text>&#xa0;</xsl:text>
                    <fo:page-number-citation ref-id="{$sLink}"/>
                </fo:inline>
            </fo:basic-link>
        </fo:block>
    </xsl:template>
    <!--
                OutputWordOrSingle
-->
    <xsl:template name="OutputWordOrSingle">
        <xsl:choose>
            <xsl:when test="name()='listWord'">
                <xsl:for-each select="langData | gloss">
                    <fo:table-cell xsl:use-attribute-sets="ExampleCell">
                        <xsl:call-template name="DoDebugExamples"/>
                        <fo:block>
                            <xsl:apply-templates select="self::*"/>
                        </fo:block>
                    </fo:table-cell>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="name()='listSingle'">
                <fo:table-cell xsl:use-attribute-sets="ExampleCell">
                    <xsl:call-template name="DoDebugExamples"/>
                    <fo:block>
                        <xsl:for-each select="langData | gloss">
                            <xsl:apply-templates select="self::*"/>
                        </xsl:for-each>
                    </fo:block>
                </fo:table-cell>
            </xsl:when>
            <xsl:otherwise>
                <fo:block>
                    <xsl:for-each select="langData | gloss">
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
    <xsl:template match="interlinearSource" mode="contents">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- ===========================================================
      ELEMENTS TO IGNORE
      =========================================================== -->
    <xsl:template match="language"/>
    <xsl:template match="comment"/>
    <xsl:template match="interlinearSource"/>
    <xsl:template match="appendix/shortTitle"/>
    <xsl:template match="section1/shortTitle"/>
    <xsl:template match="section2/shortTitle"/>
    <xsl:template match="section3/shortTitle"/>
    <xsl:template match="section4/shortTitle"/>
    <xsl:template match="section5/shortTitle"/>
    <xsl:template match="section6/shortTitle"/>
    <xsl:template match="textInfo/shortTitle"/>
    <xsl:template match="styles"/>
    <xsl:template match="style"/>
    <xsl:template match="dd"/>
    <xsl:template match="term"/>
    <xsl:template match="type"/>
    <xsl:include href="XLingPapCommon.xsl"/>
    <xsl:include href="XLingPapFOCommon.xsl"/>
</xsl:stylesheet>
