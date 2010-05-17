<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:tex="http://getfo.sourceforge.net/texml/ns1">
    <xsl:output method="xml" version="1.0" encoding="utf-8"/>
    <!-- ===========================================================
      Version of this stylesheet
      =========================================================== -->
    <xsl:variable name="sVersion">2.2.99</xsl:variable>
    <!-- ===========================================================
      Keys
      =========================================================== -->
    <xsl:key name="IndexTermID" match="//indexTerm" use="@id"/>
    <xsl:key name="InterlinearReferenceID" match="//interlinear" use="@text"/>
    <xsl:key name="LanguageID" match="//language" use="@id"/>
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
    <!-- the following is actually  the main source file path and name without extension -->
    <xsl:param name="sMainSourceFile" select="'C:/Documents and Settings/Andy Black/My Documents/XLingPap/XeTeX/TestTeXPaperTeXML'"/>
    <xsl:param name="sTableOfContentsFile" select="concat($sMainSourceFile,'.toc')"/>
    <xsl:param name="sFOProcessor">XEP</xsl:param>
    <xsl:param name="bUseBookTabs" select="'Y'"/>
    <xsl:param name="bDoDebug" select="'n'"/>
    <!-- need a better solution for the following -->
    <xsl:param name="sVernacularFontFamily" select="'Arial Unicode MS'"/>
    <!--
        sInterlinearSourceStyle:
        The default is AfterFirstLine (immediately after the last item in the first line)
        The other possibilities are AfterFree (immediately after the free translation, on the same line)
        and UnderFree (on the line immediately after the free translation)
    -->
<!--       <xsl:param name="sInterlinearSourceStyle">AfterFirstLine</xsl:param>-->
    <xsl:param name="sInterlinearSourceStyle">AfterFree</xsl:param>
    <!-- ===========================================================
      Variables
      =========================================================== -->
    <xsl:variable name="abbrLang" select="//lingPaper/@abbreviationlang"/>
    <xsl:variable name="sBulletPoint" select="'&#x2022;'"/>
    <xsl:variable name="sInterlinearMaxNumberOfColumns" select="'30'"/>
    <xsl:variable name="bHasChapter">
        <xsl:choose>
            <xsl:when test="//chapter">
                <xsl:text>Y</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>N</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bHasContents">
        <xsl:choose>
            <xsl:when test="//contents">
                <xsl:text>Y</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>N</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sLdquo">&#8220;</xsl:variable>
    <xsl:variable name="sRdquo">&#8221;</xsl:variable>
    <xsl:variable name="sSingleQuote">
        <xsl:text>'</xsl:text>
    </xsl:variable>
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
    <xsl:variable name="iPageHeight">
        <xsl:value-of select="number(substring($sPageHeight,1,string-length($sPageHeight) - 2))"/>
    </xsl:variable>
    <xsl:variable name="iPageTopMargin">
        <xsl:value-of select="number(substring($sPageTopMargin,1,string-length($sPageTopMargin) - 2))"/>
    </xsl:variable>
    <xsl:variable name="iPageBottomMargin">
        <xsl:value-of select="number(substring($sPageBottomMargin,1,string-length($sPageBottomMargin) - 2))"/>
    </xsl:variable>
    <xsl:variable name="iHeaderMargin">
        <xsl:value-of select="number(substring($sHeaderMargin,1,string-length($sHeaderMargin) - 2))"/>
    </xsl:variable>
    <xsl:variable name="iFooterMargin">
        <xsl:value-of select="number(substring($sFooterMargin,1,string-length($sFooterMargin) - 2))"/>
    </xsl:variable>
    <xsl:variable name="sInterlinearInitialHorizontalOffset">-.5pt</xsl:variable>
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
    <!-- ===========================================================
      MAIN BODY
      =========================================================== -->
    <xsl:template match="/lingPaper">
        <tex:TeXML>
            <xsl:comment> generated by XLingPapTeX1.xsl Version <xsl:value-of select="$sVersion"/>&#x20;</xsl:comment>
            <tex:cmd name="documentclass" nl2="1">
                <!--            <opt>a4paper</opt>-->
                <opt>
                    <xsl:text>10pt</xsl:text>
                    <xsl:if test="$bHasChapter!='Y'">
                        <xsl:text>,twoside</xsl:text>
                    </xsl:if>
                </opt>
                <tex:parm>
                    <xsl:choose>
                        <xsl:when test="$bHasChapter='Y'">
                            <xsl:text>book</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>article</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </tex:parm>
            </tex:cmd>
            <xsl:call-template name="SetPageLayoutParameters"/>
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>needspace</tex:parm>
            </tex:cmd>
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>xltxtra</tex:parm>
            </tex:cmd>
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>color</tex:parm>
            </tex:cmd>
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>colortbl</tex:parm>
            </tex:cmd>
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>tabularx</tex:parm>
            </tex:cmd>
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>longtable</tex:parm>
            </tex:cmd>
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>multirow</tex:parm>
            </tex:cmd>
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>booktabs</tex:parm>
            </tex:cmd>
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>fancyhdr</tex:parm>
            </tex:cmd>
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>fontspec</tex:parm>
            </tex:cmd>
            <!-- hyperref should be the last package listed -->
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>hyperref</tex:parm>
            </tex:cmd>
            <tex:cmd name="hypersetup" nl2="1">
                <tex:parm>colorlinks=true, citecolor=black, filecolor=black, linkcolor=black, urlcolor=blue, bookmarksopen=true</tex:parm>
            </tex:cmd>
            <xsl:call-template name="SetHeaderFooter"/>
            <xsl:call-template name="SetFonts">
                <xsl:with-param name="sDefaultFontFamily" select="$sDefaultFontFamily"/>
                <xsl:with-param name="sBasicPointSize" select="$sBasicPointSize"/>
                <xsl:with-param name="sSection1PointSize" select="$sSection1PointSize"/>
                <xsl:with-param name="sSection2PointSize" select="$sSection2PointSize"/>
                <xsl:with-param name="sSection3PointSize" select="$sSection3PointSize"/>
                <xsl:with-param name="sSection4PointSize" select="$sSection4PointSize"/>
                <xsl:with-param name="sSection5PointSize" select="$sSection5PointSize"/>
                <xsl:with-param name="sSection6PointSize" select="$sSection6PointSize"/>
            </xsl:call-template>
            <tex:cmd name="setlength" nl1="1" nl2="1">
                <tex:parm>
                    <tex:cmd name="parindent" gr="0"/>
                </tex:parm>
                <tex:parm>
                    <xsl:value-of select="$sParagraphIndent"/>
                </tex:parm>
            </tex:cmd>
            <tex:env name="document">
                <xsl:call-template name="CreateAllNumberingLevelIndentAndWidthCommands"/>
                <xsl:call-template name="SetTOCMacros"/>
                <tex:cmd name="newlength" nl2="1">
                    <tex:parm>
                        <tex:cmd name="XLingPaperpnumwidth" gr="0" nl2="0"/>
                    </tex:parm>
                </tex:cmd>
                <tex:cmd name="newlength" nl2="1">
                    <tex:parm>
                        <tex:cmd name="XLingPapertocrmarg" gr="0" nl2="0"/>
                    </tex:parm>
                </tex:cmd>
                <xsl:variable name="sMaxPageNumberInContents" select="document($sTableOfContentsFile)/toc/tocline[last()]/@page"/>
                <xsl:call-template name="SetListLengthWidths"/>
                <xsl:call-template name="SetMyListItemMacro"/>
                <xsl:call-template name="SetTeXCommand">
                    <xsl:with-param name="sTeXCommand" select="'setlength'"/>
                    <xsl:with-param name="sCommandToSet" select="'XLingPaperpnumwidth'"/>
                    <xsl:with-param name="sValue">
                        <xsl:choose>
                            <xsl:when test="$sMaxPageNumberInContents">
                                <xsl:choose>
                                    <xsl:when test="$sMaxPageNumberInContents &lt; 10">1.05em</xsl:when>
                                    <xsl:when test="$sMaxPageNumberInContents &lt; 100">1.55em</xsl:when>
                                    <xsl:when test="$sMaxPageNumberInContents &lt; 1000">2.05em</xsl:when>
                                    <xsl:otherwise>2.55em</xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>1.55em</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="SetTeXCommand">
                    <xsl:with-param name="sTeXCommand" select="'setlength'"/>
                    <xsl:with-param name="sCommandToSet" select="'XLingPapertocrmarg'"/>
                    <xsl:with-param name="sValue">
                        <tex:cmd name="XLingPaperpnumwidth" gr="0" nl2="0"/>
                        <xsl:text>+1em</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
                <tex:cmd name="raggedbottom" gr="0" nl2="1"/>
                <tex:env name="MainFont">
                    <xsl:choose>
                        <xsl:when test="//chapter">
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="frontMatter"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </tex:env>
                <xsl:if test="$bHasContents='Y'">
                    <tex:cmd name="XLingPaperendtableofcontents" gr="0" nl2="1"/>
                </xsl:if>
            </tex:env>
        </tex:TeXML>
    </xsl:template>
    <xsl:template name="SetListLengthWidths">
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperlistitemindent" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperbulletlistitemwidth" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPaperbulletlistitemwidth'"/>
            <xsl:with-param name="sValue">
                <xsl:value-of select="$sBulletPoint"/>
                <tex:spec cat="esc"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPapersingledigitlistitemwidth" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPapersingledigitlistitemwidth'"/>
            <xsl:with-param name="sValue">
                <xsl:text>8.</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperdoubledigitlistitemwidth" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPaperdoubledigitlistitemwidth'"/>
            <xsl:with-param name="sValue">
                <xsl:text>88.</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPapertripledigitlistitemwidth" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPapertripledigitlistitemwidth'"/>
            <xsl:with-param name="sValue">
                <xsl:text>888.</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPapersingleletterlistitemwidth" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPapersingleletterlistitemwidth'"/>
            <xsl:with-param name="sValue">
                <xsl:text>m.</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperdoubleletterlistitemwidth" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPaperdoubleletterlistitemwidth'"/>
            <xsl:with-param name="sValue">
                <xsl:text>mm.</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPapertripleletterlistitemwidth" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPapertripleletterlistitemwidth'"/>
            <xsl:with-param name="sValue">
                <xsl:text>mmm.</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperromanviilistitemwidth" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPaperromanviilistitemwidth'"/>
            <xsl:with-param name="sValue">
                <xsl:text>vii.</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperromanviiilistitemwidth" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPaperromanviiilistitemwidth'"/>
            <xsl:with-param name="sValue">
                <xsl:text>viii.</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperromanxviiilistitemwidth" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPaperromanxviiilistitemwidth'"/>
            <xsl:with-param name="sValue">
                <xsl:text>xviii.</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="SetTOCMacros">
        <xsl:call-template name="SetMyTableOfContentsMacro"/>
        <xsl:call-template name="SetMyAddToContentsMacro"/>
        <xsl:call-template name="SetMyEndTableOfContentsMacro"/>
        <xsl:call-template name="SetMyDotFillMacro"/>
        <xsl:call-template name="SetMyDottedTOCLineMacro"/>
    </xsl:template>
    <xsl:template name="SetMyListItemMacro">
        <!-- based on the borrowed set toc macro from LaTeX's latex.ltx file 
         #1 is the indent
         #2 is the width of the label
         #3 is the label
         #4 is the content of the list item
      -->
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperlistitem" gr="0" nl2="0"/>
            </tex:parm>
            <tex:opt>4</tex:opt>
            <tex:parm>
                <tex:cmd name="newdimen" gr="0" nl1="1" nl2="0"/>
                <tex:cmd name="XLingPapertempdim" gr="0" nl2="1"/>
                <tex:cmd name="vskip" gr="0" nl2="0"/>
                <xsl:text>0pt plus .2pt</xsl:text>
                <tex:group>
                    <tex:cmd name="leftskip" gr="0" nl1="1" nl2="0"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>1</xsl:text>
                    <tex:cmd name="relax" gr="0" nl2="0"/>
                    <tex:spec cat="comment"/>
                    <xsl:text> left glue for indent</xsl:text>
                    <tex:cmd name="parindent" gr="0" nl1="1" nl2="0"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>1</xsl:text>
                    <tex:cmd name="relax" gr="0" nl2="0"/>
                    <tex:cmd name="interlinepenalty10000" gr="0" nl1="1" nl2="0"/>
                    <tex:cmd name="leavevmode" gr="0" nl1="1" nl2="0"/>
                    <tex:cmd name="XLingPapertempdim" gr="0" nl1="1" nl2="0"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>2</xsl:text>
                    <tex:cmd name="relax" gr="0" nl2="0"/>
                    <tex:spec cat="comment"/>
                    <xsl:text> label width</xsl:text>
                    <tex:cmd name="advance" gr="0" nl1="1" nl2="0"/>
                    <tex:cmd name="leftskip" gr="0" nl2="0"/>
                    <tex:cmd name="XLingPapertempdim" gr="0" nl2="0"/>
                    <tex:cmd name="null" gr="0" nl2="0"/>
                    <tex:cmd name="nobreak" gr="0" nl2="0"/>
                    <tex:cmd name="hskip" gr="0" nl2="0"/>
                    <xsl:text>-</xsl:text>
                    <tex:cmd name="leftskip" gr="0" nl2="0"/>
                    <tex:cmd name="hbox to" gr="0" nl2="0"/>
                    <tex:cmd name="XLingPapertempdim" gr="0" nl2="0">
                        <tex:parm>
                            <tex:cmd name="hfil" gr="0" nl2="0"/>
                            <tex:cmd name="normalfont" gr="0" nl2="0"/>
                            <tex:cmd name="normalcolor" gr="0" nl2="0"/>
                            <tex:spec cat="parm"/>
                            <xsl:text>3</xsl:text>
                            <tex:spec cat="esc"/>
                            <xsl:text>&#x20;</xsl:text>
                        </tex:parm>
                    </tex:cmd>
                    <tex:spec cat="bg"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>4</xsl:text>
                    <tex:spec cat="eg"/>
                    <tex:cmd name="nobreak" gr="0" nl2="1"/>
                    <tex:cmd name="par" gr="0" nl1="1"/>
                </tex:group>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <xsl:template name="SetMyDottedTOCLineMacro">
        <!-- borrowed with slight changes (and gratitude) from LaTeX's latex.ltx file -->
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperdottedtocline" gr="0" nl2="0"/>
            </tex:parm>
            <tex:opt>4</tex:opt>
            <tex:parm>
                <tex:cmd name="newdimen" gr="0" nl1="1" nl2="0"/>
                <tex:cmd name="XLingPapertempdim" gr="0" nl2="1"/>
                <tex:cmd name="vskip" gr="0" nl2="0"/>
                <xsl:text>0pt plus .2pt</xsl:text>
                <tex:group>
                    <tex:cmd name="leftskip" gr="0" nl1="1" nl2="0"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>1</xsl:text>
                    <tex:cmd name="relax" gr="0" nl2="0"/>
                    <tex:spec cat="comment"/>
                    <xsl:text> left glue for indent</xsl:text>
                    <tex:cmd name="rightskip" gr="0" nl1="1" nl2="0"/>
                    <tex:cmd name="XLingPapertocrmarg" gr="0" nl2="0"/>
                    <tex:spec cat="comment"/>
                    <xsl:text> right glue for for right margin</xsl:text>
                    <tex:cmd name="parfillskip" gr="0" nl1="1" nl2="0"/>
                    <xsl:text>-</xsl:text>
                    <tex:cmd name="rightskip" gr="0" nl2="0"/>
                    <tex:spec cat="comment"/>
                    <xsl:text> so can go into margin if need be???</xsl:text>
                    <tex:cmd name="parindent" gr="0" nl1="1" nl2="0"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>1</xsl:text>
                    <tex:cmd name="relax" gr="0" nl2="0"/>
                    <tex:cmd name="interlinepenalty10000" gr="0" nl1="1" nl2="0"/>
                    <tex:cmd name="leavevmode" gr="0" nl1="1" nl2="0"/>
                    <tex:cmd name="XLingPapertempdim" gr="0" nl1="1" nl2="0"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>2</xsl:text>
                    <tex:cmd name="relax" gr="0" nl2="0"/>
                    <tex:spec cat="comment"/>
                    <xsl:text> numwidth</xsl:text>
                    <tex:cmd name="advance" gr="0" nl1="1" nl2="0"/>
                    <tex:cmd name="leftskip" gr="0" nl2="0"/>
                    <tex:cmd name="XLingPapertempdim" gr="0" nl2="0"/>
                    <tex:cmd name="null" gr="0" nl2="0"/>
                    <tex:cmd name="nobreak" gr="0" nl2="0"/>
                    <tex:cmd name="hskip" gr="0" nl2="0"/>
                    <xsl:text>-</xsl:text>
                    <tex:cmd name="leftskip" gr="0" nl2="0"/>
                    <tex:spec cat="bg"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>3</xsl:text>
                    <tex:spec cat="eg"/>
                    <tex:cmd name="nobreak" gr="0" nl2="1"/>
                    <tex:cmd name="XLingPaperdotfill" gr="0" nl2="0"/>
                    <tex:cmd name="nobreak" gr="0" nl2="1"/>
                    <tex:cmd name="hbox to" gr="0" nl2="0"/>
                    <tex:cmd name="XLingPaperpnumwidth" gr="0" nl2="0">
                        <tex:parm>
                            <tex:cmd name="hfil" gr="0" nl2="0"/>
                            <tex:cmd name="normalfont" gr="0" nl2="0"/>
                            <tex:cmd name="normalcolor" gr="0" nl2="0"/>
                            <tex:spec cat="parm"/>
                            <xsl:text>4</xsl:text>
                        </tex:parm>
                    </tex:cmd>
                    <tex:cmd name="par" gr="0" nl1="1"/>
                </tex:group>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <xsl:template name="SetMyDotFillMacro">
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperdotfill" gr="0" nl2="0"/>
            </tex:parm>
            <tex:parm>
                <tex:cmd name="leaders" gr="0" nl2="0"/>
                <tex:cmd name="hbox">
                    <tex:parm>
                        <tex:spec cat="mshift"/>
                        <tex:cmd name="mathsurround" gr="0" nl2="0"/>
                        <xsl:text>0pt</xsl:text>
                        <tex:cmd name="mkern" gr="0" nl2="0"/>
                        <xsl:text>4.5 mu</xsl:text>
                        <tex:cmd name="hbox">
                            <tex:parm>.</tex:parm>
                        </tex:cmd>
                        <tex:cmd name="mkern" gr="0" nl2="0"/>
                        <xsl:text>4.5 mu</xsl:text>
                        <tex:spec cat="mshift"/>
                    </tex:parm>
                </tex:cmd>
                <tex:cmd name="hfill" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <xsl:template name="SetMyEndTableOfContentsMacro">
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperendtableofcontents" gr="0" nl2="0"/>
            </tex:parm>
            <tex:parm>
                <tex:cmd name="write8">
                    <tex:parm>
                        <tex:spec cat="lt"/>
                        <xsl:text>/toc</xsl:text>
                        <tex:spec cat="gt"/>
                    </tex:parm>
                </tex:cmd>
                <tex:cmd name="closeout8" gr="0" nl2="0"/>
                <tex:cmd name="relax" gr="0" nl2="1"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <xsl:template name="SetMyAddToContentsMacro">
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperaddtocontents" gr="0" nl2="0"/>
            </tex:parm>
            <tex:opt>1</tex:opt>
            <tex:parm>
                <tex:cmd name="write8">
                    <tex:parm>
                        <tex:spec cat="lt"/>
                        <xsl:text>tocline ref="</xsl:text>
                        <tex:spec cat="parm"/>
                        <xsl:text>1" page="</xsl:text>
                        <tex:cmd name="thepage" gr="0" nl2="0"/>
                        <xsl:text>"/</xsl:text>
                        <tex:spec cat="gt"/>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <xsl:template name="SetMyTableOfContentsMacro">
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPapertableofcontents" gr="0" nl2="0"/>
            </tex:parm>
            <tex:parm>
                <tex:cmd name="immediate" gr="0" nl2="0"/>
                <tex:cmd name="openout8" gr="0" nl2="0"/>
                <xsl:text> = </xsl:text>
                <tex:cmd name="jobname.toc" gr="0" nl2="0"/>
                <tex:cmd name="relax" gr="0" nl2="1"/>
                <tex:cmd name="write8">
                    <tex:parm>
                        <tex:spec cat="lt"/>
                        <xsl:text>toc</xsl:text>
                        <tex:spec cat="gt"/>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <xsl:template name="CreateAllNumberingLevelIndentAndWidthCommands">
        <xsl:call-template name="CreateNumberingLevelIndentAndWidthCommands">
            <xsl:with-param name="sLevel" select="'levelone'"/>
        </xsl:call-template>
        <xsl:call-template name="CreateNumberingLevelIndentAndWidthCommands">
            <xsl:with-param name="sLevel" select="'leveltwo'"/>
        </xsl:call-template>
        <xsl:call-template name="CreateNumberingLevelIndentAndWidthCommands">
            <xsl:with-param name="sLevel" select="'levelthree'"/>
        </xsl:call-template>
        <xsl:call-template name="CreateNumberingLevelIndentAndWidthCommands">
            <xsl:with-param name="sLevel" select="'levelfour'"/>
        </xsl:call-template>
        <xsl:call-template name="CreateNumberingLevelIndentAndWidthCommands">
            <xsl:with-param name="sLevel" select="'levelfive'"/>
        </xsl:call-template>
        <xsl:call-template name="CreateNumberingLevelIndentAndWidthCommands">
            <xsl:with-param name="sLevel" select="'levelsix'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="CreateNumberingLevelIndentAndWidthCommands">
        <xsl:param name="sLevel"/>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="{$sLevel}indent" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="{$sLevel}width" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!-- ===========================================================
      FRONTMATTER
      =========================================================== -->
    <xsl:template match="frontMatter">
        <xsl:choose>
            <xsl:when test="//chapter">
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
                        <xsl:apply-templates select="title | subtitle | author | affiliation | presentedAt | date | version"/>
                    </fo:flow>
                </fo:page-sequence>
                <xsl:apply-templates select="contents | acknowledgements | abstract | preface" mode="book"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- 
            <xsl:attribute name="font-family">
                     <xsl:value-of select="$sDefaultFontFamily"/>
                  </xsl:attribute>
                  <xsl:attribute name="font-size">
                     <xsl:value-of select="$sBasicPointSize"/>pt</xsl:attribute>
-->
                <!-- put title in marker so it can show up in running header -->
                <!-- 
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
     -->
                <xsl:apply-templates select="title | subtitle | author | affiliation | presentedAt | date | version"/>
                <xsl:apply-templates select="contents | acknowledgements | abstract | preface" mode="paper"/>
                <xsl:apply-templates select="//section1[not(parent::appendix)]"/>
                <xsl:apply-templates select="//backMatter"/>
                <!--                <xsl:apply-templates select="//index" mode="Index"/> -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      title
      -->
    <xsl:template match="title">
        <xsl:if test="//chapter">
            <fo:block font-size="18pt" font-weight="bold" text-align="center" space-before="1.25in" space-before.conditionality="retain">
                <xsl:apply-templates/>
            </fo:block>
            <xsl:apply-templates select="following-sibling::subtitle"/>
        </xsl:if>
        <!--      <fo:block font-size="18pt" font-weight="bold" text-align="center" space-before="1.25in" space-before.conditionality="retain" break-before="odd-page">-->
        <tex:cmd name="vspace*" nl2="1">
            <tex:parm>1.25in</tex:parm>
        </tex:cmd>
        <tex:cmd name="centerline" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="TitleFontFamily">
                    <tex:parm>
                        <tex:cmd name="LARGE">
                            <tex:parm>
                                <tex:cmd name="textbf">
                                    <tex:parm>
                                        <xsl:apply-templates/>
                                    </tex:parm>
                                </tex:cmd>
                            </tex:parm>
                        </tex:cmd>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="thispagestyle" nl2="1">
            <tex:parm>plain</tex:parm>
        </tex:cmd>
        <tex:cmd name="markboth" nl2="1">
            <tex:parm>
                <xsl:choose>
                    <xsl:when test="string-length(../shortTitle) &gt; 0">
                        <xsl:apply-templates select="../shortTitle" mode="InMarker"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </tex:parm>
            <tex:parm/>
        </tex:cmd>
        <!--      </fo:block>-->
    </xsl:template>
    <!--
      subtitle
      -->
    <xsl:template match="subtitle">
        <!-- 
      <fo:block font-size="14pt" font-weight="bold" text-align="center" space-before=".25in" space-before.conditionality="retain">
         <xsl:apply-templates/>
      </fo:block>
      -->
        <tex:cmd name="vspace*">
            <tex:parm>.25in</tex:parm>
        </tex:cmd>
        <tex:cmd name="centerline" nl1="1">
            <tex:parm>
                <tex:cmd name="SubtitleFontFamily">
                    <tex:parm>
                        <tex:cmd name="Large">
                            <tex:parm>
                                <tex:cmd name="textbf">
                                    <tex:parm>
                                        <xsl:apply-templates/>
                                    </tex:parm>
                                </tex:cmd>
                            </tex:parm>
                        </tex:cmd>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--
      author
      -->
    <xsl:template match="author">
        <!-- 
      <fo:block font-style="italic" text-align="center">
         <xsl:apply-templates/>
      </fo:block>
      -->
        <tex:cmd name="centerline" nl1="1">
            <tex:parm>
                <tex:cmd name="AuthorFontFamily">
                    <tex:parm>
                        <tex:cmd name="textit">
                            <tex:parm>
                                <xsl:apply-templates/>
                            </tex:parm>
                        </tex:cmd>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--
      affiliation
      -->
    <xsl:template match="affiliation">
        <!-- 
      <fo:block font-style="italic" text-align="center">
         <xsl:value-of select="."/>
      </fo:block>
      -->
        <tex:cmd name="centerline" nl1="1">
            <tex:parm>
                <tex:cmd name="AffiliationFontFamily">
                    <tex:parm>
                        <tex:cmd name="textit">
                            <tex:parm>
                                <xsl:apply-templates/>
                            </tex:parm>
                        </tex:cmd>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--
      date or presentedAt
      -->
    <xsl:template match="date | presentedAt">
        <!-- 
      <fo:block font-size="10pt" text-align="center">
         <xsl:value-of select="."/>
      </fo:block>
   -->
        <tex:cmd name="centerline" nl1="1">
            <tex:parm>
                <tex:cmd name="DateFontFamily">
                    <tex:parm>
                        <xsl:apply-templates/>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
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
        <!-- 
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
      -->
        <xsl:call-template name="DoSectionLevelTitle">
            <xsl:with-param name="bIsCentered" select="'Y'"/>
            <xsl:with-param name="sFontFamily" select="'SectionLevelOneFontFamily'"/>
            <xsl:with-param name="sFontSize">large</xsl:with-param>
            <xsl:with-param name="sBold">textbf</xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <xsl:template match="section2">
        <!-- 
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
      -->
        <xsl:call-template name="DoSectionLevelTitle">
            <xsl:with-param name="sFontFamily" select="'SectionLevelTwoFontFamily'"/>
            <!--         <xsl:with-param name="sItalic">textit</xsl:with-param>-->
            <xsl:with-param name="sBold">textbf</xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <xsl:template match="section3">
        <!-- 
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
      -->
        <xsl:call-template name="DoSectionLevelTitle">
            <xsl:with-param name="sFontFamily" select="'SectionLevelThreeFontFamily'"/>
            <xsl:with-param name="sItalic">textit</xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <xsl:template match="section4 | section5 | section6">
        <!-- 
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
      -->
        <xsl:call-template name="DoSectionLevelTitle">
            <xsl:with-param name="sFontFamily">
                <xsl:choose>
                    <xsl:when test="name()='section4'">
                        <xsl:text>SectionLevelFourFontFamily</xsl:text>
                    </xsl:when>
                    <xsl:when test="name()='section5'">
                        <xsl:text>SectionLevelFiveFontFamily</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>SectionLevelSixFontFamily</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="sItalic">textit</xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <!--
      Appendix
      -->
    <xsl:template match="appendix[not(//chapter)]">
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id" select="@id"/>
            <xsl:with-param name="sTitle">
                <xsl:apply-templates select="." mode="numberAppendix"/>
                <xsl:text disable-output-escaping="yes">.&#x20;</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="titlePart2" select="secTitle"/>
            <xsl:with-param name="bIsBook" select="'N'"/>
            <xsl:with-param name="bForcePageBreak" select="'N'"/>
        </xsl:call-template>
        <!-- 
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
      -->
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
        <!-- 
      <fo:inline>
         <fo:basic-link>
            <xsl:attribute name="internal-destination">
               <xsl:value-of select="@sec"/>
            </xsl:attribute>
            <xsl:call-template name="AddAnyLinkAttributes"/>
            <xsl:apply-templates select="id(@sec)" mode="number"/>
         </fo:basic-link>
      </fo:inline>
-->
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="@sec"/>
        </xsl:call-template>
        <xsl:apply-templates select="id(@sec)" mode="number"/>
        <xsl:call-template name="DoExternalHyperRefEnd"/>
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
        <!--      <fo:basic-link internal-destination="{@gref}">-->
        <xsl:call-template name="AddAnyLinkAttributes"/>
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="@gref"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="DoInternalTargetEnd"/>
        <!--      </fo:basic-link>-->
    </xsl:template>
    <!--
      genericTarget
   -->
    <xsl:template match="genericTarget">
        <xsl:call-template name="DoInternalTargetBegin">
            <xsl:with-param name="sName" select="@id"/>
        </xsl:call-template>
        <xsl:call-template name="DoInternalTargetEnd"/>
        <!--      <fo:inline id="{@id}"/>-->
    </xsl:template>
    <!--
      link
      -->
    <xsl:template match="link">
        <!-- 
      <fo:basic-link external-destination="url({@href})">
         <xsl:call-template name="AddAnyLinkAttributes"/>
         <xsl:apply-templates/>
      </fo:basic-link>
      -->
        <xsl:call-template name="DoExternalHyperRefBegin">
            <xsl:with-param name="sName" select="@href"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="DoExternalHyperRefEnd"/>
    </xsl:template>
    <!-- ===========================================================
      PARAGRAPH
      =========================================================== -->
    <xsl:template match="p | pc">
        <xsl:choose>
            <xsl:when test="parent::endnote and name()='p' and not(preceding-sibling::p)">
                <!--  and position()='1'" -->
                <xsl:call-template name="OutputTypeAttributes">
                    <xsl:with-param name="sList" select="@xsl-foSpecial"/>
                </xsl:call-template>
                <!-- 
            <fo:inline baseline-shift="super">
               <xsl:attribute name="font-size">
                  <xsl:value-of select="$sFootnotePointSize - 2"/>
                  <xsl:text>pt</xsl:text>
               </xsl:attribute>
               <xsl:for-each select="parent::endnote">
                  <xsl:choose>
                     <xsl:when test="//chapter">
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
            -->
                <xsl:if test="parent::blockquote">
                    <xsl:call-template name="DoType">
                        <xsl:with-param name="type" select="parent::blockquote/@type"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:apply-templates/>
                <xsl:if test="parent::blockquote">
                    <xsl:call-template name="DoTypeEnd">
                        <xsl:with-param name="type" select="parent::blockquote/@type"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:when test="parent::endnote and name()='p' and preceding-sibling::p">
                <xsl:choose>
                    <xsl:when test="ancestor::table">
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <tex:cmd name="par" gr="0"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <!-- 
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
            -->
                <xsl:choose>
                    <xsl:when test="name()='pc'">
                        <tex:cmd name="noindent" gr="0" nl2="0"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <tex:cmd name="indent" gr="0" nl2="0"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="parent::blockquote">
                    <xsl:call-template name="DoType">
                        <xsl:with-param name="type" select="parent::blockquote/@type"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:apply-templates/>
                <xsl:if test="parent::blockquote">
                    <xsl:call-template name="DoTypeEnd">
                        <xsl:with-param name="type" select="parent::blockquote/@type"/>
                    </xsl:call-template>
                </xsl:if>
                <tex:cmd name="par"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ===========================================================
      QUOTES
      =========================================================== -->
    <xsl:template match="q">
        <!--      <fo:inline>-->
        <xsl:value-of select="$sLdquo"/>
        <xsl:call-template name="DoType"/>
        <xsl:apply-templates/>
        <xsl:call-template name="DoTypeEnd"/>
        <xsl:value-of select="$sRdquo"/>
        <!--      </fo:inline>-->
    </xsl:template>
    <xsl:template match="blockquote">
        <tex:env name="quotation">
            <!--     Needs to be done inside    <xsl:call-template name="DoType"/>-->
            <xsl:apply-templates/>
            <!--         <xsl:call-template name="DoTypeEnd"/>-->
        </tex:env>
        <!-- 
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
      -->
    </xsl:template>
    <!-- ===========================================================
      LISTS
      =========================================================== -->
    <xsl:template match="ol">
        <xsl:variable name="sThisItemWidth">
            <xsl:call-template name="GetItemWidth"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="count(ancestor::ul | ancestor::ol) = 0">
                <tex:group>
                    <tex:spec cat="esc"/>
                    <xsl:text>parskip .5pt plus 1pt minus 1pt
</xsl:text>
                    <tex:cmd name="vspace" nl1="1" nl2="1">
                        <tex:parm>
                            <tex:cmd name="baselineskip" gr="0" nl2="0"/>
                        </tex:parm>
                    </tex:cmd>
                    <xsl:apply-templates>
                        <xsl:with-param name="sListItemWidth">
                            <tex:spec cat="esc"/>
                            <xsl:value-of select="$sThisItemWidth"/>
                        </xsl:with-param>
                        <xsl:with-param name="sListItemIndent">
                            <tex:spec cat="esc"/>
                            <xsl:value-of select="$sThisItemWidth"/>
                        </xsl:with-param>
                    </xsl:apply-templates>
                    <tex:cmd name="vspace" nl1="1" nl2="1">
                        <tex:parm>
                            <tex:cmd name="baselineskip" gr="0" nl2="0"/>
                        </tex:parm>
                    </tex:cmd>
                </tex:group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="HandleEmbeddedListItem">
                    <xsl:with-param name="sThisItemWidth" select="$sThisItemWidth"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <!-- 
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
      -->
    </xsl:template>
    <xsl:template name="HandleEmbeddedListItem">
        <xsl:param name="sThisItemWidth"/>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPaperlistitemindent'"/>
            <xsl:with-param name="sValue">
                <xsl:for-each select="ancestor::ol | ancestor::ul">
                    <xsl:sort select="position()" order="descending"/>
                    <tex:spec cat="esc" gr="0" nl2="0"/>
                    <xsl:call-template name="GetItemWidth"/>
                    <xsl:text> + </xsl:text>
                    <xsl:if test="position() = last()">
                        <tex:spec cat="esc" gr="0" nl2="0"/>
                        <xsl:call-template name="GetItemWidth"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates>
            <xsl:with-param name="sListItemWidth">
                <tex:spec cat="esc"/>
                <xsl:value-of select="$sThisItemWidth"/>
            </xsl:with-param>
            <xsl:with-param name="sListItemIndent">
                <tex:spec cat="esc"/>
                <xsl:text>XLingPaperlistitemindent</xsl:text>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template name="GetItemWidth">
        <xsl:choose>
            <xsl:when test="name()='ol'">
                <xsl:call-template name="GetNumberedItemWidth"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>XLingPaperbulletlistitemwidth</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="GetNumberedItemWidth">
        <xsl:variable name="NestingLevel">
            <xsl:choose>
                <xsl:when test="ancestor::endnote">
                    <xsl:value-of select="count(ancestor::ol[not(descendant::endnote)])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="count(ancestor-or-self::ol)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="iSize" select="count(li)"/>
        <xsl:choose>
            <xsl:when test="($NestingLevel mod 3)=1">
                <xsl:choose>
                    <xsl:when test="$iSize &lt; 10">
                        <xsl:text>XLingPapersingledigitlistitemwidth</xsl:text>
                    </xsl:when>
                    <xsl:when test="$iSize &lt; 100">
                        <xsl:text>XLingPaperdoubledigitlistitemwidth</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>XLingPapertripledigitlistitemwidth</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="($NestingLevel mod 3)=2">
                <xsl:choose>
                    <xsl:when test="$iSize &lt; 10">
                        <xsl:text>XLingPapersingleletterlistitemwidth</xsl:text>
                    </xsl:when>
                    <xsl:when test="$iSize &lt; 100">
                        <xsl:text>XLingPaperdoubleletterlistitemwidth</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>XLingPapertripleletterlistitemwidth</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="($NestingLevel mod 3)=0">
                <xsl:choose>
                    <xsl:when test="$iSize &lt; 8">
                        <xsl:text>XLingPaperromanviilistitemwidth</xsl:text>
                    </xsl:when>
                    <xsl:when test="$iSize &lt; 17">
                        <xsl:text>XLingPaperromanviiilistitemwidth</xsl:text>
                    </xsl:when>
                    <xsl:when test="$iSize &lt; 19">
                        <xsl:text>XLingPaperromanxviilistitemwidth</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- hope for the best...  -->
                        <xsl:text>XLingPaperdoubleletterlistitemwidth</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="ul">
        <xsl:choose>
            <xsl:when test="count(ancestor::ul | ancestor::ol) = 0">
                <tex:group>
                    <tex:spec cat="esc"/>
                    <xsl:text>parskip .5pt plus 1pt minus 1pt
</xsl:text>
                    <tex:cmd name="vspace" nl1="1" nl2="1">
                        <tex:parm>
                            <tex:cmd name="baselineskip" gr="0" nl2="0"/>
                        </tex:parm>
                    </tex:cmd>
                    <xsl:apply-templates>
                        <xsl:with-param name="sListItemIndent">
                            <tex:spec cat="esc"/>
                            <xsl:text>XLingPaperbulletlistitemwidth</xsl:text>
                        </xsl:with-param>
                    </xsl:apply-templates>
                    <tex:cmd name="vspace" nl1="1" nl2="1">
                        <tex:parm>
                            <tex:cmd name="baselineskip" gr="0" nl2="0"/>
                        </tex:parm>
                    </tex:cmd>
                </tex:group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="HandleEmbeddedListItem">
                    <xsl:with-param name="sThisItemWidth" select="'XLingPaperbulletlistitemwidth'"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <!-- 
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
-->
    </xsl:template>
    <xsl:template match="li">
        <xsl:param name="sListItemWidth">
            <tex:spec cat="esc"/>
            <xsl:text>XLingPaperbulletlistitemwidth</xsl:text>
        </xsl:param>
        <xsl:param name="sListItemIndent" select="'1em'"/>
        <tex:cmd name="XLingPaperlistitem" nl1="1">
            <tex:parm>
                <xsl:copy-of select="$sListItemIndent"/>
            </tex:parm>
            <tex:parm>
                <xsl:copy-of select="$sListItemWidth"/>
            </tex:parm>
            <tex:parm>
                <xsl:choose>
                    <xsl:when test="parent::ul">
                        <xsl:value-of select="$sBulletPoint"/>
                    </xsl:when>
                    <xsl:otherwise>
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
                                <xsl:number level="single" count="li" format="1"/>
                            </xsl:when>
                            <xsl:when test="($NestingLevel mod 3)=2">
                                <xsl:number level="single" count="li" format="a"/>
                            </xsl:when>
                            <xsl:when test="($NestingLevel mod 3)=0">
                                <xsl:number level="single" count="li" format="i"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="position()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </tex:parm>
            <tex:parm>
                <xsl:if test="string-length(normalize-space(@id)) &gt; 0">
                    <xsl:call-template name="DoInternalTargetBegin">
                        <xsl:with-param name="sName" select="@id"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoInternalTargetEnd"/>
                </xsl:if>
                <xsl:call-template name="DoType">
                    <xsl:with-param name="type" select="parent::*/@type"/>
                </xsl:call-template>
                <xsl:apply-templates/>
                <xsl:call-template name="DoTypeEnd">
                    <xsl:with-param name="type" select="parent::*/@type"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <!-- 
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
      -->
    </xsl:template>
    <xsl:template match="dl">
        <xsl:call-template name="OKToBreakHere"/>
        <tex:env name="description">
            <!-- unsuccessful attempt to get space between embedded lists to be more like the normal spacing
            <xsl:if test="count(ancestor::ul | ancestor::ol) &gt; 0">
            <tex:cmd name="vspace*">
            <tex:parm>
            <xsl:text>-.25</xsl:text>
            <tex:cmd name="baselineskip" gr="0" nl2="0"/>
            </tex:parm>
            </tex:cmd>
            </xsl:if>
         -->
            <xsl:call-template name="SetListLengths"/>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </tex:env>
        <!-- 
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
      -->
    </xsl:template>
    <xsl:template match="dt">
        <xsl:choose>
            <xsl:when test="count(following-sibling::dt) &lt;= 1">
                <xsl:call-template name="DoNotBreakHere"/>
            </xsl:when>
            <xsl:when test="count(preceding-sibling::dt) &lt;= 1">
                <xsl:call-template name="DoNotBreakHere"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OKToBreakHere"/>
            </xsl:otherwise>
        </xsl:choose>
        <tex:cmd name="item" nl2="1">
            <tex:opt>
                <xsl:apply-templates/>
            </tex:opt>
            <tex:parm>
                <xsl:apply-templates select="following-sibling::dd[1][name()='dd']" mode="dt"/>
            </tex:parm>
        </tex:cmd>
        <!-- 
      
      <fo:list-item>
         <fo:list-item-label end-indent="label-end()">
            <fo:block font-weight="bold">
               <xsl:apply-templates select="child::node()[name()!='dd']"/>
            </fo:block>
         </fo:list-item-label>
         <xsl:apply-templates select="following-sibling::dd[1][name()='dd']" mode="dt"/>
      </fo:list-item>
      -->
    </xsl:template>
    <xsl:template match="dd" mode="dt">
        <xsl:apply-templates/>
        <!-- 
      <fo:list-item-body start-indent="body-start()">
         <fo:block>
            <xsl:apply-templates/>
         </fo:block>
      </fo:list-item-body>
      -->
    </xsl:template>
    <!-- ===========================================================
      EXAMPLES
      =========================================================== -->
    <xsl:template match="example">
        <!-- 
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
         - units are ems so the font and font size can be taken into account -
         <xsl:text>em</xsl:text>
         </xsl:when>
         <xsl:when test="$sFOProcessor='XFC'">
         -  units are inches because "XFC is not a renderer. It has a limited set of font metrics and therefore handles 'em' units in a very approximate way."
         (email of August 10, 2007 from Jean-Yves Belmonte of XMLmind)-
         <xsl:text>in</xsl:text>
         </xsl:when>
         -  if we can ever get FOP to do something reasonable for examples and interlinear, we'll add a 'when' clause here -
         </xsl:choose>
         </xsl:attribute>
         </fo:table-column>
         -  By not specifiying a width for the second column, it appears to use what is left over 
         (which is what we want).  While this works for XEP, it does not for XFC (or FOP). -
         <fo:table-column column-number="2">
         <xsl:choose>
         <xsl:when test="$sFOProcessor='XEP'">
         - units are ems so the font and font size can be taken into account for the example number; XEP handles the second column fine without specifying any width -
         </xsl:when>
         <xsl:when test="$sFOProcessor='XFC'">
         <xsl:attribute name="column-width">
         -  units are inches because "XFC is not a renderer. It has a limited set of font metrics and therefore handles 'em' units in a very approximate way."
         (email of August 10, 2007 from Jean-Yves Belmonte of XMLmind)-
         <xsl:value-of select="number($iExampleWidth - $iNumberWidth)"/>
         <xsl:text>in</xsl:text>
         </xsl:attribute>
         </xsl:when>
         -  if we can ever get FOP to do something reasonable for examples and interlinear, we'll add a 'when' clause here -
         </xsl:choose>
         </fo:table-column>
         <fo:table-body start-indent="0pt" end-indent="0pt">
         <fo:table-row>
         <fo:table-cell text-align="start" end-indent=".2em">
         <xsl:call-template name="DoDebugExamples"/>
         -                 <xsl:call-template name="DoCellAttributes"/> -
         <fo:block>
         <xsl:call-template name="ExampleNumber"/>
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
      -->
        <tex:env name="flushleft">
            <xsl:if test="not(ancestor::endnote)">
                <tex:cmd name="vspace">
                    <tex:parm>.5<tex:spec cat="esc"/>baselineskip</tex:parm>
                </tex:cmd>
            </xsl:if>
            <tex:env name="tabular">
                <tex:opt>t</tex:opt>
                <tex:parm>
                    <xsl:call-template name="DoInterlinearInitialHorizontalOffset">
                        <xsl:with-param name="sHorizontalOffset" select="$sBlockQuoteIndent"/>
                    </xsl:call-template>
                    <xsl:text>p</xsl:text>
                    <tex:spec cat="bg"/>
                    <xsl:value-of select="$iNumberWidth"/>
                    <xsl:text>em</xsl:text>
                    <tex:spec cat="eg"/>
                    <xsl:call-template name="DoInterlinearInitialHorizontalOffset"/>
                    <xsl:choose>
                        <xsl:when test="chart | tree | definition | interlinear/phrase">
                            <xsl:text>p</xsl:text>
                            <tex:spec cat="bg"/>
                            <tex:cmd name="textwidth" gr="0"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="$sBlockQuoteIndent"/>
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="$iNumberWidth"/>
                            <xsl:text>em</xsl:text>
                            <tex:spec cat="eg"/>
                            <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
                            <!--                     <tex:spec cat="eg"/>-->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="listWord | listSingle | listInterlinear">
                                <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
                                <xsl:variable name="sLetterWidth">
                                    <xsl:call-template name="GetLetterWidth">
                                        <xsl:with-param name="iLetterCount" select="count(listWord | listSingle | listInterlinear)"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:text>p</xsl:text>
                                <tex:spec cat="bg"/>
                                <xsl:value-of select="$sLetterWidth"/>
                                <xsl:text>em</xsl:text>
                                <tex:spec cat="eg"/>
                            </xsl:if>
                            <xsl:call-template name="DoInterlinearTabularMainPattern"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </tex:parm>
                <tex:cmd name="parbox">
                    <tex:opt>b</tex:opt>
                    <tex:parm>
                        <xsl:value-of select="$iNumberWidth"/>
                        <xsl:text>em</xsl:text>
                    </tex:parm>
                    <tex:parm>
                        <xsl:call-template name="DoInternalTargetBegin">
                            <xsl:with-param name="sName" select="@num"/>
                        </xsl:call-template>
                        <xsl:call-template name="ExampleNumber"/>
                        <xsl:call-template name="DoInternalTargetEnd"/>
                        <xsl:if test="//lingPaper/@showiso639-3codeininterlinear='yes'">
                            <xsl:variable name="firstLangData" select="descendant::langData[1]"/>
                            <xsl:if test="$firstLangData">
                                <xsl:variable name="sIsoCode" select="key('LanguageID',$firstLangData/@lang)/@ISO639-3Code"/>
                                <xsl:if test="string-length($sIsoCode) &gt; 0">
                                    <!-- 
                              <fo:block/>
                              <fo:inline font-size="smaller">
                              <xsl:text>[</xsl:text>
                              <xsl:value-of select="$sIsoCode"/>
                              <xsl:text>]</xsl:text>
                              </fo:inline>
                           -->
                                    <tex:spec cat="esc"/>
                                    <tex:spec cat="esc"/>
                                    <tex:cmd name="small">
                                        <tex:parm>
                                            <xsl:text>[</xsl:text>
                                            <xsl:value-of select="$sIsoCode"/>
                                            <xsl:text>]</xsl:text>
                                        </tex:parm>
                                    </tex:cmd>
                                </xsl:if>
                            </xsl:if>
                        </xsl:if>
                    </tex:parm>
                </tex:cmd>
                <!-- can we rework this somehow?  seems odd to have to check here; just always do & -->
                <xsl:if test="chart or tree or definition or interlinear/phrase">
                    <tex:spec cat="align"/>
                </xsl:if>
                <xsl:apply-templates/>
            </tex:env>
        </tex:env>
        <xsl:if test="not(following-sibling::example)">
            <tex:cmd name="vspace">
                <tex:parm>.5<tex:spec cat="esc"/>baselineskip</tex:parm>
            </tex:cmd>
        </xsl:if>
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
                <tex:cmd name="needspace" nl2="1">
                    <tex:parm>
                        <!-- try to guess the number of lines in the first bundle and then add 1 for the title-->
                        <xsl:variable name="iFirstSetOfLines" select="count(lineGroup/line) + count(free) + count(exampleHeading) + 1"/>
                        <!--                     <xsl:text>3</xsl:text>-->
                        <xsl:value-of select="$iFirstSetOfLines"/>
                        <tex:cmd name="baselineskip" gr="0" nl2="0"/>
                    </tex:parm>
                </tex:cmd>
                <tex:cmd name="noindent" gr="0"/>
                <tex:cmd name="small" gr="0"/>
                <tex:spec cat="bg"/>
                <!-- default formatting is bold -->
                <tex:spec cat="esc"/>
                <xsl:text>textbf</xsl:text>
                <tex:spec cat="bg"/>
                <xsl:call-template name="DoInternalTargetBegin">
                    <xsl:with-param name="sName" select="@text"/>
                </xsl:call-template>
                <xsl:value-of select="../textInfo/shortTitle"/>
                <xsl:text>:</xsl:text>
                <xsl:value-of select="count(preceding-sibling::interlinear) + 1"/>
                <xsl:call-template name="DoInternalTargetEnd"/>
                <tex:spec cat="eg"/>
                <tex:spec cat="eg"/>
                <tex:cmd name="par" gr="0" nl2="1"/>
<!-- this keeps the entire interlinear on the same page, even if parts of it could easily fit
    <tex:cmd name="nopagebreak" gr="0" nl2="0"/>-->
                <tex:env name="longtable">
                    <tex:opt>t</tex:opt>
                    <tex:parm>
                        <xsl:call-template name="DoInterlinearInitialHorizontalOffset"/>
                        <xsl:call-template name="DoInterlinearTabularMainPattern"/>
                    </tex:parm>
                    <xsl:call-template name="OutputInterlinear">
                        <xsl:with-param name="mode" select="'NoTextRef'"/>
                    </xsl:call-template>
                </tex:env>
                <tex:cmd name="par" gr="0" nl2="1"/>
                <!-- 
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
             -->
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
        <xsl:call-template name="DoInterlinearFree">
            <xsl:with-param name="mode" select="'NoTextRef'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      listInterlinear
      -->
    <xsl:template match="listInterlinear">
        <xsl:if test="parent::example/listInterlinear[1]=.">
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
                <!--            <fo:block/>-->
                <tex:cmd name="par" gr="0" nl2="1"/>
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
                <!--            <fo:block>-->
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                </xsl:call-template>
                <xsl:apply-templates/>
                <xsl:call-template name="OutputFontAttributesEnd">
                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                </xsl:call-template>
                <!--            </fo:block>-->
                <tex:cmd name="par" gr="0" nl2="1"/>
            </xsl:when>
            <xsl:when test="@type='gls'">
                <xsl:choose>
                    <xsl:when test="count(../preceding-sibling::phrase) &gt; 0">
                        <!--                        <fo:inline margin-left=".125in"> Should we indent here? -->
                        <!--                  <fo:block>-->
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                        </xsl:call-template>
                        <xsl:apply-templates/>
                        <xsl:call-template name="OutputFontAttributesEnd">
                            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                        </xsl:call-template>
                        <!--                  </fo:block>-->
                        <tex:cmd name="par" gr="0" nl2="1"/>
                        <!--                        </fo:inline>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <!--                  <fo:block>-->
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                        </xsl:call-template>
                        <xsl:apply-templates/>
                        <xsl:call-template name="OutputFontAttributesEnd">
                            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                        </xsl:call-template>
                        <!--                  </fo:block>-->
                        <tex:cmd name="par" gr="0" nl2="1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@type='note'">
                <!--            <fo:block>-->
                <xsl:text>Note: </xsl:text>
                <!--               <fo:inline>-->
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                </xsl:call-template>
                <xsl:apply-templates/>
                <xsl:call-template name="OutputFontAttributesEnd">
                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                </xsl:call-template>
                <!--               </fo:inline>-->
                <!--            </fo:block>-->
                <tex:cmd name="par" gr="0" nl2="1"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
      words
      -->
    <xsl:template match="words">
        <!--      <fo:block>-->
        <!--         <fo:inline-container>-->
        <xsl:apply-templates/>
        <!--         </fo:inline-container>-->
        <!--      </fo:block>-->
        <tex:cmd name="par" gr="0" nl2="1"/>
    </xsl:template>
    <!--
      iword
      -->
    <xsl:template match="iword">
        <xsl:if test="count(preceding-sibling::iword)=0">
            <tex:cmd name="raggedright" gr="0" nl2="0"/>
        </xsl:if>
        <tex:cmd name="leavevmode" gr="0" nl2="0"/>
        <tex:cmd name="hbox">
            <tex:parm>
                <tex:env name="tabular" nl1="0">
                    <tex:opt>t</tex:opt>
                    <tex:parm>
                        <xsl:text>@</xsl:text>
                        <tex:spec cat="bg"/>
                        <tex:spec cat="eg"/>
                        <xsl:text>l@</xsl:text>
                        <tex:spec cat="bg"/>
                        <tex:spec cat="eg"/>
                    </tex:parm>
                    <xsl:apply-templates/>
                </tex:env>
            </tex:parm>
        </tex:cmd>
        <!-- 
      <fo:table border="thin solid black">
         <fo:table-body>
            <xsl:apply-templates/>
         </fo:table-body>
      </fo:table>
      -->
    </xsl:template>
    <!--
      iword/item[@type='txt']
      -->
    <xsl:template match="iword/item[@type='txt']">
        <!--<tex:group>-->
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:text>&#160;</xsl:text>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
        </xsl:call-template>
        <!--</tex:group>-->
        <tex:spec cat="esc" gr="0" nl2="0"/>
        <tex:spec cat="esc" gr="0" nl2="1"/>
        <!--    <fo:table-row>
         <fo:table-cell>
            <fo:block>
               <xsl:call-template name="OutputFontAttributes">
                  <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
               </xsl:call-template>
               <xsl:apply-templates/>
               <xsl:text>&#160;</xsl:text>
            </fo:block>
         </fo:table-cell>
         </fo:table-row> -->
    </xsl:template>
    <!--
      iword/item[@type='gls']
      -->
    <xsl:template match="iword/item[@type='gls']">
        <!--      <tex:group>-->
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
        </xsl:call-template>
        <xsl:if test="string(.)">
            <xsl:apply-templates/>
            <xsl:text>&#160;</xsl:text>
        </xsl:if>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
        </xsl:call-template>
        <!--      </tex:group>-->
        <tex:spec cat="esc" gr="0" nl2="0"/>
        <tex:spec cat="esc" gr="0" nl2="1"/>
        <!--    <fo:table-row>
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
         </fo:table-row> -->
    </xsl:template>
    <!--
      iword/item[@type='pos']
      -->
    <xsl:template match="iword/item[@type='pos']">
        <!--      <tex:group>-->
        <xsl:if test="string(.)">
            <xsl:apply-templates/>
            <xsl:text>&#160;</xsl:text>
        </xsl:if>
        <!--      </tex:group>-->
        <tex:spec cat="esc" gr="0" nl2="0"/>
        <tex:spec cat="esc" gr="0" nl2="1"/>
        <!--       <fo:table-row>
         <fo:table-cell>
         <fo:block>
         <xsl:if test="string(.)">
         <xsl:apply-templates/>
         <xsl:text>&#160;</xsl:text>
         </xsl:if>
         </fo:block>
         </fo:table-cell>
         </fo:table-row>
      -->
    </xsl:template>
    <!--
      iword/item[@type='punct']
      -->
    <xsl:template match="iword/item[@type='punct']">
        <!--<tex:group>-->
        <xsl:if test="string(.)">
            <xsl:apply-templates/>
            <xsl:text>&#160;</xsl:text>
        </xsl:if>
        <!--               </tex:group>-->
        <tex:spec cat="esc" gr="0" nl2="0"/>
        <tex:spec cat="esc" gr="0" nl2="1"/>
        <!-- <fo:table-row>
         <fo:table-cell>
         <fo:block>
         <xsl:if test="string(.)">
         <xsl:apply-templates/>
         <xsl:text>&#160;</xsl:text>
         </xsl:if>
         </fo:block>
         </fo:table-cell>
         </fo:table-row> -->
    </xsl:template>
    <!--
      morphemes
      -->
    <xsl:template match="morphemes">
        <!--      <tex:group>-->
        <xsl:apply-templates/>
        <!--               </tex:group>-->
        <tex:spec cat="esc" gr="0" nl2="0"/>
        <tex:spec cat="esc" gr="0" nl2="1"/>
        <!--       <fo:table-row>
         <fo:table-cell>
         <fo:block>
         <xsl:apply-templates/>
         </fo:block>
         </fo:table-cell>
         </fo:table-row>
      -->
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
        <tex:env name="tabular">
            <tex:opt>t</tex:opt>
            <tex:parm>
                <xsl:text>@</xsl:text>
                <tex:spec cat="bg"/>
                <tex:spec cat="eg"/>
                <xsl:text>l@</xsl:text>
                <tex:spec cat="bg"/>
                <tex:spec cat="eg"/>
            </tex:parm>
            <xsl:apply-templates/>
        </tex:env>
        <!--       <fo:table>
         <fo:table-body>
            <xsl:apply-templates/>
         </fo:table-body>
         </fo:table>  -->
    </xsl:template>
    <!--
      morph/item
      -->
    <xsl:template match="morph/item[@type!='hn' and @type!='cf']">
        <!--<tex:group>-->
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:text>&#160;</xsl:text>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
        </xsl:call-template>
        <!--               </tex:group>-->
        <tex:spec cat="esc" gr="0" nl2="0"/>
        <tex:spec cat="esc" gr="0" nl2="1"/>
        <!--       <fo:table-row>
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
      -->
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
        <!--      <tex:group>-->
        <xsl:apply-templates/>
        <xsl:variable name="homographNumber" select="following-sibling::item[@type='hn']"/>
        <xsl:if test="$homographNumber">
            <tex:cmd name="textsubscript">
                <tex:parm>
                    <xsl:apply-templates select="$homographNumber" mode="hn"/>
                </tex:parm>
            </tex:cmd>
        </xsl:if>
        <xsl:text>&#160;</xsl:text>
        <!--      </tex:group>-->
        <tex:spec cat="esc" gr="0" nl2="0"/>
        <tex:spec cat="esc" gr="0" nl2="1"/>
        <!--       <fo:table-row>
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
      -->
    </xsl:template>
    <!-- ================================ -->
    <!--
        definition
    -->
    <xsl:template match="definition[not(parent::example)]">
        <!--      <fo:inline>-->
        <tex:group>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
            <xsl:call-template name="DoTypeEnd"/>
        </tex:group>
    </xsl:template>
    <!--
        chart
    -->
    <xsl:template match="chart">
        <!-- 
      <fo:block>
         <xsl:call-template name="DoType"/>
         <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@xsl-foSpecial"/>
         </xsl:call-template>
         <xsl:apply-templates/>
      </fo:block>
      -->
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      tree
      -->
    <xsl:template match="tree">
        <!-- 
      <fo:block keep-together="2">
         <xsl:call-template name="DoType"/>
         <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@xsl-foSpecial"/>
         </xsl:call-template>
         <xsl:apply-templates/>
      </fo:block>
      -->
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      table
      -->
    <xsl:template match="table">
        <!--  If this is in an example, an embedded table, or within a list, then there's no need to add extra space around it. -->
        <xsl:choose>
            <xsl:when test="not(parent::example) and not(ancestor::table) and not(ancestor::li)">
                <!-- longtable does this effectively anyway
            <tex:cmd name="vspace">
               <tex:parm><xsl:value-of select="$sBasicPointSize"/>
               <xsl:text>pt</xsl:text></tex:parm>
               </tex:cmd> -->
                <tex:cmd name="hspace*">
                    <tex:parm>
                        <xsl:value-of select="$sBlockQuoteIndent"/>
                    </tex:parm>
                </tex:cmd>
                <!-- Do we want this? 
            <xsl:attribute name="end-indent">
               <xsl:value-of select="$sBlockQuoteIndent"/>
            </xsl:attribute>
 -->
            </xsl:when>
            <!-- not needed
         <xsl:when test="ancestor::li">
            <xsl:attribute name="space-before">
               <xsl:value-of select="$sBasicPointSize div 2"/>pt</xsl:attribute>
         </xsl:when>
         -->
        </xsl:choose>
        <!-- try to get font stuff set before we do the table so it applies throughout the table -->
        <!-- 
      <xsl:if test="parent::example">
         <tex:cmd name="hspace*">
            <tex:parm><xsl:value-of select="$sBlockQuoteIndent"/></tex:parm>
         </tex:cmd>
         <tex:cmd name="hspace*">
            <tex:parm>1.5em</tex:parm>
         </tex:cmd>
         
         <tex:cmd name="parbox">
            <tex:opt>b</tex:opt>
            <tex:parm><xsl:value-of select="$iExampleWidth"/>
            <xsl:text>in</xsl:text>
            </tex:parm> 
         </tex:cmd>
      </xsl:if>
      -->
        <xsl:choose>
            <xsl:when test="parent::example">
                <tex:spec cat="align"/>
                <xsl:call-template name="SingleSpaceAdjust"/>
            </xsl:when>
            <xsl:otherwise>
                <tex:spec cat="bg"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- 
      <xsl:if test="parent::example">
         <tex:cmd name="vspace*">
            <tex:parm>-5.25ex</tex:parm>
         </tex:cmd>
      </xsl:if>
      -->
        <xsl:call-template name="DoType"/>
        <xsl:call-template name="OutputTable"/>
        <xsl:call-template name="DoTypeEnd"/>
        <xsl:if test="not(parent::example)">
            <tex:spec cat="eg"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="not(parent::example) and not(ancestor::table) and not(ancestor::li)">
                <!-- longtable does this effectively anyway
               <tex:cmd name="vspace" nl2="1">
               <tex:parm><xsl:value-of select="$sBasicPointSize"/>
                  <xsl:text>pt</xsl:text></tex:parm>
            </tex:cmd> -->
                <tex:spec cat="nl"/>
            </xsl:when>
            <!-- not needed 
         <xsl:when test="ancestor::li">
            <xsl:attribute name="space-after">
               <xsl:value-of select="$sBasicPointSize div 2"/>pt</xsl:attribute>
         </xsl:when>
         -->
        </xsl:choose>
        <!--      <fo:block>
         <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template> -->
        <!--  If this is in an example, an embedded table, or within a list, then there's no need to add extra space around it. -->
        <!-- 
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
     </fo:block>-->
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
    <xsl:template match="th | headerCol">
        <xsl:param name="iBorder" select="0"/>
        <xsl:variable name="bInARowSpan">
            <xsl:call-template name="DetermineIfInARowSpan"/>
        </xsl:variable>
        <xsl:if test="contains($bInARowSpan,'Y')">
            <tex:spec cat="align"/>
        </xsl:if>
        <xsl:call-template name="DoCellAttributes">
            <xsl:with-param name="iBorder" select="$iBorder"/>
            <xsl:with-param name="bInARowSpan" select="$bInARowSpan"/>
        </xsl:call-template>
        <xsl:if test="string-length(normalize-space(@width)) &gt; 0">
            <!-- the user has specifed a width, so chances are that justification of the header will look stretched out; 
               force ragged right
           -->
            <tex:spec cat="esc"/>
            <xsl:text>raggedright</xsl:text>
        </xsl:if>
        <!-- default formatting is bold -->
        <tex:spec cat="esc"/>
        <xsl:text>textbf</xsl:text>
        <tex:spec cat="bg"/>
        <xsl:for-each select="..">
            <!-- have to do the row's type processing here -->
            <xsl:call-template name="DoType"/>
        </xsl:for-each>
        <xsl:call-template name="DoType"/>
        <!--      <xsl:call-template name="OutputBackgroundColor"/>-->
        <xsl:apply-templates/>
        <xsl:call-template name="DoCellAttributesEnd"/>
        <tex:spec cat="eg"/>
        <xsl:if test="following-sibling::th | following-sibling::td | following-sibling::col">
            <xsl:text>&#xa0;</xsl:text>
            <tex:spec cat="align"/>
        </xsl:if>
        <!-- 
      <fo:table-cell border-collapse="collapse">
         <xsl:attribute name="padding">.2em</xsl:attribute>
         <xsl:call-template name="DoCellAttributes"/>
         <xsl:call-template name="DoType"/>
         <xsl:call-template name="OutputBackgroundColor"/>
         <fo:block font-weight="bold" start-indent="0pt" end-indent="0pt">
            <xsl:apply-templates/>
         </fo:block>
      </fo:table-cell>
      -->
    </xsl:template>
    <!--
          row for a table
      -->
    <xsl:template match="tr | row">
        <xsl:param name="iBorder" select="0"/>
        <!-- 
      <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@xsl-foSpecial"/>
         </xsl:call-template>
-->
        <xsl:call-template name="CreateHorizontalLine">
            <xsl:with-param name="iBorder" select="$iBorder"/>
        </xsl:call-template>
        <!--      <xsl:call-template name="DoType"/>-->
        <xsl:call-template name="DoRowBackgroundColor"/>
        <xsl:apply-templates>
            <xsl:with-param name="iBorder" select="$iBorder"/>
        </xsl:apply-templates>
        <tex:spec cat="esc"/>
        <tex:spec cat="esc"/>
        <xsl:if test="contains(ancestor::table/@TeXSpecial,'row-separation')">
            <xsl:text>[</xsl:text>
            <xsl:for-each select="ancestor::table[@TeXSpecial]">
                <xsl:call-template name="HandleTeXSpecialCommand">
                    <xsl:with-param name="sPattern" select="'row-separation='"/>
                    <xsl:with-param name="default" select="'0pt'"/>
                </xsl:call-template>
                <xsl:text>]</xsl:text>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="position()=last()">
            <xsl:call-template name="CreateHorizontalLine">
                <xsl:with-param name="iBorder" select="$iBorder"/>
                <xsl:with-param name="bIsLast" select="'Y'"/>
            </xsl:call-template>
        </xsl:if>
        <!--    <fo:table-row>
         <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@xsl-foSpecial"/>
         </xsl:call-template>
         <xsl:call-template name="DoType"/>
         <xsl:call-template name="OutputBackgroundColor"/>
         <xsl:apply-templates/>
         </fo:table-row>
      -->
    </xsl:template>
    <!--
        col for a table
    -->
    <xsl:template match="td | col">
        <xsl:param name="iBorder" select="0"/>
        <!-- 
            <xsl:choose>
            <xsl:when test="ancestor::table[1]/@border!='0' or count(ancestor::table)=1">
            <xsl:attribute name="padding">.2em</xsl:attribute>
            </xsl:when>
            <xsl:when test="position() &gt; 1">
            <xsl:attribute name="padding-left">.2em</xsl:attribute>
            </xsl:when>
            </xsl:choose>
        -->
        <xsl:variable name="bInARowSpan">
            <xsl:call-template name="DetermineIfInARowSpan"/>
        </xsl:variable>
        <xsl:if test="contains($bInARowSpan,'Y')">
            <xsl:call-template name="HandleFootnotesInTableHeader"/>
            <tex:spec cat="align"/>
        </xsl:if>
        <xsl:call-template name="DoCellAttributes">
            <xsl:with-param name="iBorder" select="$iBorder"/>
            <xsl:with-param name="bInARowSpan" select="$bInARowSpan"/>
        </xsl:call-template>
        <xsl:for-each select="..">
            <!-- have to do the row's type processing here -->
            <xsl:call-template name="DoType"/>
        </xsl:for-each>
        <xsl:call-template name="DoType"/>
        <!--      <xsl:call-template name="OutputBackgroundColor"/>-->
        <xsl:apply-templates/>
        <xsl:if test="not(contains($bInARowSpan,'Y'))">
            <xsl:call-template name="HandleFootnotesInTableHeader"/>
        </xsl:if>
        <xsl:call-template name="DoTypeEnd"/>
        <xsl:for-each select="..">
            <!-- have to do the row's type processing here -->
            <xsl:call-template name="DoTypeEnd"/>
        </xsl:for-each>
        <xsl:call-template name="DoCellAttributesEnd"/>
        <xsl:if test="following-sibling::td | following-sibling::col">
            <xsl:text>&#xa0;</xsl:text>
            <tex:spec cat="align"/>
        </xsl:if>
        <!--    <fo:table-cell border-collapse="collapse">
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
         </fo:table-cell> -->
    </xsl:template>
    <xsl:template name="HandleFootnotesInTableHeader">
        <xsl:if test="position()=1 or preceding-sibling::*[1][name()='th']">
            <xsl:variable name="headerRows" select="../preceding-sibling::tr[1][th[count(following-sibling::td)=0]]"/>
            <xsl:for-each select="$headerRows/th[descendant-or-self::endnote]">
                <xsl:for-each select="descendant-or-self::endnote">
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="sTeXFootnoteKind" select="'footnotetext'"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <!--
          caption for a table
      -->
    <xsl:template match="caption | endCaption">
        <xsl:param name="iNumCols" select="2"/>
        <tex:cmd name="multicolumn">
            <tex:parm>
                <xsl:value-of select="$iNumCols"/>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="CreateColumnSpec">
                    <xsl:with-param name="sAlignDefault" select="'c'"/>
                </xsl:call-template>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="DoType"/>
                <tex:cmd name="textbf">
                    <tex:parm>
                        <xsl:apply-templates/>
                    </tex:parm>
                </tex:cmd>
                <xsl:call-template name="DoTypeEnd"/>
            </tex:parm>
        </tex:cmd>
        <tex:spec cat="esc"/>
        <tex:spec cat="esc"/>
        <!-- 
      <fo:block font-weight="bold">
         <xsl:call-template name="DoCellAttributes"/>
         <xsl:if test="not(@align)">
            - default to centered -
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
      -->
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
        <!-- <fo:basic-link>
         <xsl:attribute name="internal-destination">
      -->
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName">
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
            </xsl:with-param>
        </xsl:call-template>
        <!--         </xsl:attribute>-->
        <xsl:call-template name="AddAnyLinkAttributes"/>
        <xsl:if test="not(@paren) or @paren='both' or @paren='initial'">(</xsl:if>
        <xsl:if test="@equal='yes'">=</xsl:if>
        <xsl:choose>
            <xsl:when test="@letter">
                <xsl:if test="not(@letterOnly='yes')">
                    <xsl:apply-templates select="id(@letter)" mode="example"/>
                </xsl:if>
                <xsl:apply-templates select="id(@letter)" mode="letter"/>
            </xsl:when>
            <xsl:when test="@num">
                <xsl:apply-templates select="id(@num)" mode="example"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="@punct">
            <xsl:value-of select="@punct"/>
        </xsl:if>
        <xsl:if test="not(@paren) or @paren='both' or @paren='final'">)</xsl:if>
        <!--      </fo:basic-link>-->
        <xsl:call-template name="DoExternalHyperRefEnd"/>
    </xsl:template>
    <!-- ===========================================================
      ENDNOTES and ENDNOTEREFS
      =========================================================== -->
    <!--
      endnotes
      -->
    <!--
      endnote (bookmarks)
   -->
    <xsl:template match="endnote" mode="bookmarks"/>
    <!--
      endnote in flow of text
      -->
    <xsl:template match="endnote">
        <xsl:param name="sTeXFootnoteKind" select="'footnote'"/>
        <!-- 
      <fo:footnote>
         <fo:inline baseline-shift="super" id="{@id}">
            <xsl:attribute name="font-size">
               <xsl:value-of select="$sFootnotePointSize - 2"/>
               <xsl:text>pt</xsl:text>
            </xsl:attribute>
            <xsl:choose>
               <xsl:when test="//chapter">
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
            <fo:block text-align="left" text-indent="1em" font-style="normal" font-weight="normal">
               <xsl:attribute name="font-size">
                  <xsl:value-of select="$sFootnotePointSize"/>
                  <xsl:text>pt</xsl:text>
               </xsl:attribute>
               <xsl:apply-templates/>
            </fo:block>
         </fo:footnote-body>
      </fo:footnote>
      -->
        <xsl:variable name="sFootnoteNumber">
            <xsl:choose>
                <xsl:when test="//chapter">
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
        </xsl:variable>
        <tex:cmd name="{$sTeXFootnoteKind}">
            <tex:opt>
                <xsl:value-of select="$sFootnoteNumber"/>
            </tex:opt>
            <tex:parm>
                <xsl:call-template name="DoInternalTargetBegin">
                    <xsl:with-param name="sName" select="@id"/>
                </xsl:call-template>
                <xsl:call-template name="DoInternalTargetEnd"/>
                <xsl:apply-templates/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--
      endnoteRef
      -->
    <xsl:template match="endnoteRef">
        <!-- 
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
                     <xsl:when test="//chapter">
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
      -->
        <!--
                                <xsl:for-each select="parent::endnote">
                                    <xsl:choose>
                                        <xsl:when test="//chapter">
                                            <xsl:number level="any" count="endnote" from="chapter"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:number level="any" count="endnote" format="1"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                        -->
        <!-- 
                     </fo:inline>
                     <xsl:text>See footnote </xsl:text>
                     <fo:basic-link internal-destination="{@note}">
                        <xsl:call-template name="AddAnyLinkAttributes"/>
                        <xsl:apply-templates select="id(@note)" mode="endnote"/>
                     </fo:basic-link>
                     <xsl:choose>
                        <xsl:when test="//chapter">
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
                  </fo:block>
               </fo:footnote-body>
            </fo:footnote>
         </xsl:otherwise>
         </xsl:choose>
      -->
        <xsl:choose>
            <xsl:when test="ancestor::endnote">
                <xsl:call-template name="DoInternalHyperlinkBegin">
                    <xsl:with-param name="sName" select="@note"/>
                </xsl:call-template>
                <xsl:call-template name="AddAnyLinkAttributes"/>
                <xsl:apply-templates select="id(@note)" mode="endnote"/>
                <xsl:call-template name="DoInternalTargetEnd"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="sFootnoteNumber">
                    <xsl:choose>
                        <xsl:when test="//chapter">
                            <xsl:number level="any" count="endnote | endnoteRef" from="chapter"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:number level="any" count="endnote | endnoteRef[not(ancestor::endnote)]" format="1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <tex:cmd name="footnote">
                    <tex:opt>
                        <xsl:value-of select="$sFootnoteNumber"/>
                    </tex:opt>
                    <tex:parm>
                        <xsl:text>See footnote </xsl:text>
                        <xsl:call-template name="DoInternalHyperlinkBegin">
                            <xsl:with-param name="sName" select="@note"/>
                        </xsl:call-template>
                        <xsl:call-template name="AddAnyLinkAttributes"/>
                        <xsl:apply-templates select="id(@note)" mode="endnote"/>
                        <xsl:call-template name="DoInternalTargetEnd"/>
                        <xsl:choose>
                            <xsl:when test="//chapter">
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
                        <xsl:apply-templates/>
                    </tex:parm>
                </tex:cmd>
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
        <!--      <fo:basic-link internal-destination="{@ref}">-->
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="@ref"/>
        </xsl:call-template>
        <xsl:call-template name="AddAnyLinkAttributes"/>
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
        <xsl:if test="@page">:<xsl:value-of select="@page"/>
        </xsl:if>
        <xsl:if test="not(@paren) or @paren='both' or @paren='final'">)</xsl:if>
        <xsl:call-template name="DoInternalTargetEnd"/>
        <!--      </fo:basic-link>-->
    </xsl:template>
    <!--
      glossary
      -->
    <xsl:template match="glossary">
        <xsl:choose>
            <xsl:when test="//chapter">
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
                            <xsl:call-template name="OutputGlossaryLabel"/>
                        </fo:marker>
                        <xsl:call-template name="DoGlossary"/>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoGlossary"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      index
      -->
    <xsl:template match="index">
        <xsl:choose>
            <xsl:when test="//chapter">
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
            <xsl:when test="//chapter">
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
                <!--            <fo:block orphans="2" widows="2">-->
                <xsl:call-template name="DoReferences"/>
                <!--            </fo:block>-->
            </xsl:otherwise>
        </xsl:choose>
        <!-- 
      <xsl:choose>
         <xsl:when test="//chapter">
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
      -->
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
        <!--      <fo:block/>-->
        <tex:spec cmd="esc"/>
        <tex:spec cmd="esc"/>
    </xsl:template>
    <!-- ===========================================================
      GLOSS
      =========================================================== -->
    <xsl:template match="gloss">
        <!--
      <fo:inline>
         <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
         </xsl:call-template>
         <xsl:apply-templates/>
      </fo:inline>
      -->
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
        </xsl:call-template>
        <!-- 
      <xsl:if test="not(parent::line)">
         <tex:spec cat="eg"/>
      </xsl:if>
      -->
        <!--      <tex:cmd name="Lang{@lang}Font">
         <tex:parm>
            <xsl:apply-templates/>
         </tex:parm>
         </tex:cmd>-->
    </xsl:template>
    <!-- ===========================================================
      ABBREVIATION
      =========================================================== -->
    <xsl:template match="abbrRef">
        <tex:group>
            <xsl:call-template name="DoInternalHyperlinkBegin">
                <xsl:with-param name="sName" select="@abbr"/>
            </xsl:call-template>
            <xsl:call-template name="AddAnyLinkAttributes"/>
            <xsl:call-template name="OutputAbbrTerm">
                <xsl:with-param name="abbr" select="id(@abbr)"/>
            </xsl:call-template>
            <xsl:call-template name="DoInternalTargetEnd"/>
        </tex:group>
        <!--       <fo:inline>
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
      -->
    </xsl:template>
    <!-- decided to use glossary instead
   <xsl:template match="backMatter/abbreviationsShownHere">
      <xsl:choose>
         <xsl:when test="//chapter">
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
        <tex:group>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
            <xsl:if test="not(@font-style)">
                <tex:spec cat="esc"/>
                <xsl:text>textit</xsl:text>
                <tex:spec cat="bg"/>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="not(@font-style)">
                <tex:spec cat="eg"/>
            </xsl:if>
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
        </tex:group>
        <!--       <fo:inline>
         <xsl:call-template name="OutputFontAttributes">
         <xsl:with-param name="language" select="."/>
         </xsl:call-template>
         <xsl:if test="not(@font-style)">
         <xsl:attribute name="font-style">
         <xsl:text>italic</xsl:text>
         </xsl:attribute>
         </xsl:if>
         <xsl:apply-templates/>
         </fo:inline>
      -->
    </xsl:template>
    <!-- ===========================================================
      LANGDATA
      =========================================================== -->
    <xsl:template match="langData">
        <!-- 
      <fo:inline>
         <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
         </xsl:call-template>
         <xsl:apply-templates/>
      </fo:inline>
-->
        <!--      <tex:cmd name="Lang{@lang}FontFamily">-->
        <!--         <tex:parm>-->
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
        </xsl:call-template>
        <!--         </tex:parm>-->
        <!--      </tex:cmd>-->
    </xsl:template>
    <!-- ===========================================================
      OBJECT
      =========================================================== -->
    <xsl:template match="object">
        <tex:spec cat="bg"/>
        <xsl:call-template name="DoType"/>
        <xsl:for-each select="key('TypeID',@type)">
            <xsl:value-of select="@before"/>
        </xsl:for-each>
        <xsl:apply-templates/>
        <xsl:for-each select="key('TypeID',@type)">
            <xsl:value-of select="@after"/>
            <!--  following looks wrong; why is it in the for-each loop? -->
            <xsl:call-template name="HandleSmallCapsEnd"/>
        </xsl:for-each>
        <xsl:call-template name="DoTypeEnd"/>
        <tex:spec cat="eg"/>
        <!--      </fo:inline>-->
    </xsl:template>
    <!-- ===========================================================
      IMG
      =========================================================== -->
    <xsl:template match="img">
        <!-- 
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
      -->
        <xsl:variable name="sImgFile" select="normalize-space(translate(@src,'\','/'))"/>
        <xsl:variable name="sExtension" select="substring($sImgFile,string-length($sImgFile)-3,4)"/>
        <xsl:choose>
            <xsl:when test="$sExtension='.gif'">
                <xsl:if test="not(ancestor::example)">
                    <tex:cmd name="par"/>
                </xsl:if>
                <xsl:call-template name="ReportTeXCannotHandleThisMessage">
                    <xsl:with-param name="sMessage">
                        <xsl:text>We're sorry, but the graphic file </xsl:text>
                        <xsl:value-of select="$sImgFile"/>
                        <xsl:text> is in GIF format and this processor cannot handle GIF format.  You will need to convert the file to a different format.  We suggest using PNG format or JPG format.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$sExtension='.svg'">
                <xsl:if test="not(ancestor::example)">
                    <tex:cmd name="par"/>
                </xsl:if>
                <xsl:call-template name="ReportTeXCannotHandleThisMessage">
                    <xsl:with-param name="sMessage">
                        <xsl:text>We're sorry, but the graphic file </xsl:text>
                        <xsl:value-of select="$sImgFile"/>
                        <xsl:text> is in SVG format and this processor cannot handle SVG format directly.  You, can however, convert this SVG file to PDF format and then use PDF format.  See </xsl:text>
                        <xsl:call-template name="DoExternalHyperRefBegin">
                            <xsl:with-param name="sName" select="'http://xmlgraphics.apache.org/batik/tools/rasterizer.html'"/>
                        </xsl:call-template>
                        <xsl:text>http://xmlgraphics.apache.org/batik/tools/rasterizer.html</xsl:text>
                        <xsl:call-template name="DoExternalHyperRefEnd"/>
                        <xsl:text> for a free tool that does this conversion.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
                <tex:cmd name="par" gr="0" nl2="1"/>
            </xsl:when>
            <xsl:when test="$sExtension='.pdf'">
                <xsl:call-template name="DoImageFile">
                    <xsl:with-param name="sXeTeXGraphicFile" select="'XeTeXpdffile'"/>
                    <xsl:with-param name="sImgFile" select="$sImgFile"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoImageFile">
                    <xsl:with-param name="sXeTeXGraphicFile" select="'XeTeXpicfile'"/>
                    <xsl:with-param name="sImgFile" select="$sImgFile"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="DoImageFile">
        <xsl:param name="sXeTeXGraphicFile"/>
        <xsl:param name="sImgFile"/>
        <xsl:if test="ancestor::example">
            <!-- apparently we normally need to adjust the vertical position of the image when in an example -->
            <tex:cmd name="vspace*">
                <tex:parm>
                    <xsl:variable name="default">
                        <xsl:text>-</xsl:text>
                        <tex:cmd name="baselineskip" gr="0" nl2="0"/>
                    </xsl:variable>
                    <xsl:variable name="sPattern" select="'vertical-adjustment='"/>
                    <xsl:call-template name="HandleTeXSpecialCommand">
                        <xsl:with-param name="sPattern" select="$sPattern"/>
                        <xsl:with-param name="default" select="$default"/>
                    </xsl:call-template>
                </tex:parm>
            </tex:cmd>
        </xsl:if>
        <tex:spec cat="bg"/>
        <tex:cmd name="{$sXeTeXGraphicFile}" gr="0" nl2="0"/>
        <xsl:text> "</xsl:text>
        <xsl:value-of select="$sImgFile"/>
        <!-- I'm not sure why, but it sure appears that all graphics need to be scaled down by 75% or so;  allow the user to fine tune this-->
        <xsl:text>" scaled </xsl:text>
        <xsl:variable name="default" select="750"/>
        <xsl:variable name="sPattern" select="'scaled='"/>
        <xsl:call-template name="HandleTeXSpecialCommand">
            <xsl:with-param name="sPattern" select="$sPattern"/>
            <xsl:with-param name="default" select="$default"/>
        </xsl:call-template>
        <tex:spec cat="eg"/>
    </xsl:template>
    <xsl:template name="ReportTeXCannotHandleThisMessage">
        <xsl:param name="sMessage"/>
        <tex:cmd name="colorbox">
            <tex:parm>yellow</tex:parm>
            <tex:parm>
                <tex:cmd name="parbox">
                    <tex:opt>t</tex:opt>
                    <tex:parm>
                        <tex:cmd name="textwidth" gr="0" nl2="0"/>
                        <xsl:text>-5em</xsl:text>
                    </tex:parm>
                    <tex:parm>
                        <tex:spec cat="esc"/>
                        <xsl:text>raggedright </xsl:text>
                        <xsl:copy-of select="$sMessage"/>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!-- ===========================================================
        INTERLINEAR TEXT
        =========================================================== -->
    <!--  
        interlinear-text
    -->
    <xsl:template match="interlinear-text">
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'LTpre'"/>
            <xsl:with-param name="sValue" select="'0pt'"/>
        </xsl:call-template>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'LTpost'"/>
            <xsl:with-param name="sValue" select="'0pt'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <!-- 
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
       -->
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
        <tex:env name="center">
            <tex:cmd name="large" gr="0"/>
            <!-- default formatting is bold -->
            <tex:spec cat="esc"/>
            <xsl:text>textbf</xsl:text>
            <tex:spec cat="bg"/>
            <xsl:apply-templates/>
            <tex:spec cat="eg"/>
        </tex:env>
        <!-- 
      <fo:block text-align="center" font-size="larger" font-weight="bold">
         <xsl:apply-templates/>
      </fo:block>
       -->
    </xsl:template>
    <!--  
        source
    -->
    <xsl:template match="source">
        <tex:env name="center">
            <!-- default formatting is italic -->
            <tex:spec cat="esc"/>
            <xsl:text>textit</xsl:text>
            <tex:spec cat="bg"/>
            <xsl:apply-templates/>
            <tex:spec cat="eg"/>
        </tex:env>
        <!-- 
      <fo:block text-align="center" font-style="italic">
         <xsl:apply-templates/>
      </fo:block>
       -->
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
        <xsl:if test="//chapter">
            <xsl:apply-templates select="." mode="numberChapter"/>.</xsl:if>
            -->
        <xsl:choose>
            <xsl:when test="count(//chapter)=0 and count(//section1)=1 and count(//section1/section2)=0">
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
            <xsl:when test="//chapter">
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
                  letter
-->
    <xsl:template mode="letter" match="*">
        <xsl:number level="single" count="listWord | listSingle | listInterlinear | lineSet" format="a"/>
    </xsl:template>
    <!--  
                  dateLetter
-->
    <xsl:template mode="dateLetter" match="*">
        <xsl:param name="date"/>
        <xsl:number level="single" count="refWork[@id=//citation/@ref][refDate=$date]" format="a"/>
    </xsl:template>
    <xsl:template match="shortTitle"/>
    <xsl:template match="shortTitle" mode="InMarker">
        <xsl:apply-templates/>
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
      CalculateColumnPosition
   -->
    <xsl:template name="CalculateColumnPosition">
        <xsl:param name="iColspan" select="0"/>
        <xsl:param name="iBorder" select="0"/>
        <xsl:param name="sAlignDefault" select="'j'"/>
        <xsl:call-template name="CreateVerticalLine">
            <xsl:with-param name="iBorder" select="$iBorder"/>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="@align='left'">l</xsl:when>
            <xsl:when test="@align='center'">c</xsl:when>
            <xsl:when test="@align='right'">r</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sAlignDefault"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$iColspan &gt; 0">
            <xsl:call-template name="CreateColumnSpec">
                <xsl:with-param name="iColspan" select="$iColspan - 1"/>
                <xsl:with-param name="iBorder" select="$iBorder"/>
            </xsl:call-template>
        </xsl:if>
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
      ConvertHexToDecimal
   -->
    <xsl:template name="ConvertHexToDecimal">
        <xsl:param name="sValue"/>
        <xsl:variable name="sLowerCase" select="translate($sValue,'ABCDEF','abcdef')"/>
        <xsl:choose>
            <xsl:when test="$sLowerCase='a'">10</xsl:when>
            <xsl:when test="$sLowerCase='b'">11</xsl:when>
            <xsl:when test="$sLowerCase='c'">12</xsl:when>
            <xsl:when test="$sLowerCase='d'">13</xsl:when>
            <xsl:when test="$sLowerCase='e'">14</xsl:when>
            <xsl:when test="$sLowerCase='f'">15</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      ConvertToPoints
   -->
    <xsl:template name="ConvertToPoints">
        <xsl:param name="sValue"/>
        <xsl:param name="iValue"/>
        <xsl:variable name="sUnit">
            <xsl:call-template name="GetUnitOfMeasure">
                <xsl:with-param name="sValue" select="$sValue"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$sUnit='in'">
                <xsl:value-of select="number($iValue * 72.27)"/>
            </xsl:when>
            <xsl:when test="$sUnit='mm'">
                <xsl:value-of select="number($iValue * 2.845275591)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- if it's not inches and not millimeters, punt -->
                <xsl:value-of select="$iValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      CreateAddToContents
   -->
    <xsl:template name="CreateAddToContents">
        <xsl:param name="id"/>
        <xsl:if test="$bHasContents='Y'">
            <tex:cmd name="XLingPaperaddtocontents">
                <tex:parm>
                    <xsl:value-of select="$id"/>
                </tex:parm>
                <!-- 
         <tex:parm>
            <tex:spec cat="lt"/>
            <xsl:text>tocline ref="</xsl:text>
            <xsl:value-of select="$id"/>
            <xsl:text>" page="</xsl:text>
            <tex:cmd name="thepage" gr="0" nl2="0"/>
            <xsl:text>"/</xsl:text>
            <tex:spec cat="gt"/>
         </tex:parm>
         -->
            </tex:cmd>
        </xsl:if>
    </xsl:template>
    <!--
      CreateColumnSpec
   -->
    <xsl:template name="CreateColumnSpec">
        <xsl:param name="iColspan" select="0"/>
        <xsl:param name="iBorder" select="0"/>
        <xsl:param name="sAlignDefault" select="'j'"/>
        <xsl:call-template name="CreateVerticalLine">
            <xsl:with-param name="iBorder" select="$iBorder"/>
        </xsl:call-template>
        <xsl:call-template name="CreateColumnSpecBackgroundColor"/>
        <xsl:choose>
            <xsl:when test="string-length(@width) &gt; 0">
                <xsl:text>p</xsl:text>
                <tex:spec cat="bg"/>
                <xsl:value-of select="@width"/>
                <tex:spec cat="eg"/>
            </xsl:when>
            <xsl:when test="@align='left'">l</xsl:when>
            <xsl:when test="@align='center'">c</xsl:when>
            <xsl:when test="@align='right'">r</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sAlignDefault"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$iColspan &gt; 0">
            <xsl:call-template name="CreateColumnSpec">
                <xsl:with-param name="iColspan" select="$iColspan - 1"/>
                <xsl:with-param name="iBorder" select="$iBorder"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--
      CreateColumnSpecBackgroundColor
   -->
    <xsl:template name="CreateColumnSpecBackgroundColor">
        <xsl:choose>
            <xsl:when test="string-length(@backgroundcolor) &gt; 0">
                <!-- use backgroundcolor attribute first -->
                <xsl:call-template name="OutputBackgroundColor"/>
            </xsl:when>
            <xsl:when test="string-length(key('TypeID', @type)/@backgroundcolor) &gt; 0">
                <!-- then try the type -->
                <xsl:for-each select="key('TypeID', @type)">
                    <xsl:call-template name="OutputBackgroundColor"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="string-length(../@backgroundcolor) &gt; 0 or string-length(key('TypeID', ../@type)/@backgroundcolor) &gt; 0">
                <!-- next use the row's background color -->
                <xsl:for-each select="..">
                    <xsl:call-template name="DoRowBackgroundColor">
                        <xsl:with-param name="bMarkAsRow" select="'N'"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- finally, try the table -->
                <xsl:for-each select="../..">
                    <xsl:call-template name="DoRowBackgroundColor">
                        <xsl:with-param name="bMarkAsRow" select="'N'"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      CreateColumnSpecDefaultAtExpression
   -->
    <xsl:template name="CreateColumnSpecDefaultAtExpression">
        <xsl:text>@</xsl:text>
        <tex:spec cat="bg"/>
        <tex:spec cat="eg"/>
    </xsl:template>
    <!--
      CreateGlossaryID
   -->
    <xsl:template name="CreateGlossaryID">
        <xsl:text>rXLingPapGlossary.</xsl:text>
        <xsl:value-of select="count(preceding-sibling::glossary)+1"/>
    </xsl:template>
    <!--
      CreateHorizontalLine
   -->
    <xsl:template name="CreateHorizontalLine">
        <xsl:param name="iBorder"/>
        <xsl:param name="bIsLast" select="'N'"/>
        <xsl:choose>
            <xsl:when test="$iBorder=1">
                <xsl:choose>
                    <xsl:when test="$bUseBookTabs='Y'">
                        <xsl:choose>
                            <xsl:when test="name()='tr' and count(preceding-sibling::tr)=0">
                                <xsl:call-template name="CreateTopRule"/>
                            </xsl:when>
                            <xsl:when test="name()='table' and tr[1]/th">
                                <xsl:call-template name="CreateTopRule"/>
                            </xsl:when>
                            <xsl:when test="$bIsLast='Y' and ancestor-or-self::table[1][@border &gt; 0]">
                                <tex:cmd name="bottomrule" gr="0"/>
                            </xsl:when>
                            <xsl:when test="not(th) and preceding-sibling::tr[1][th]">
                                <tex:cmd name="midrule" gr="0"/>
                                <xsl:if test="not(ancestor::example)">
                                    <tex:cmd name="endhead" gr="0" nl2="0"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="th[following-sibling::td] and preceding-sibling::tr[1][th[not(following-sibling::td)]]">
                                <tex:cmd name="midrule" gr="0"/>
                                <xsl:if test="not(ancestor::example)">
                                    <tex:cmd name="endhead" gr="0" nl2="0"/>
                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <tex:cmd name="hline" gr="0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$iBorder=2">
                <tex:cmd name="hline" gr="0"/>
                <tex:cmd name="hline" gr="0"/>
            </xsl:when>
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
      CreatePrefaceID
   -->
    <xsl:template name="CreatePrefaceID">
        <xsl:text>rXLingPapPreface.</xsl:text>
        <xsl:value-of select="count(preceding-sibling::preface)+1"/>
    </xsl:template>
    <!--
      CreateTopRule
   -->
    <xsl:template name="CreateTopRule">
        <xsl:if test="ancestor-or-self::table[1][@border &gt; 0]">
            <xsl:choose>
                <xsl:when test="ancestor::example and not(ancestor-or-self::table[caption])">
                    <tex:cmd name="specialrule">
                        <tex:parm>
                            <tex:cmd name="heavyrulewidth" gr="0" nl2="0"/>
                        </tex:parm>
                        <tex:parm>
                            <xsl:text>-4</xsl:text>
                            <tex:cmd name="aboverulesep" gr="0" nl2="0"/>
                        </tex:parm>
                        <tex:parm>
                            <tex:cmd name="belowrulesep" gr="0" nl2="0"/>
                        </tex:parm>
                    </tex:cmd>
                </xsl:when>
                <xsl:when test="ancestor::li">
                    <tex:cmd name="specialrule">
                        <tex:parm>
                            <tex:cmd name="heavyrulewidth" gr="0" nl2="0"/>
                        </tex:parm>
                        <tex:parm>
                            <xsl:text>4</xsl:text>
                            <tex:cmd name="aboverulesep" gr="0" nl2="0"/>
                        </tex:parm>
                        <tex:parm>
                            <tex:cmd name="belowrulesep" gr="0" nl2="0"/>
                        </tex:parm>
                    </tex:cmd>
                </xsl:when>
                <xsl:otherwise>
                    <tex:cmd name="toprule" gr="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
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
      CreateVerticalLine
   -->
    <xsl:template name="CreateVerticalLine">
        <xsl:param name="iBorder"/>
        <xsl:if test="$bUseBookTabs!='Y'">
            <xsl:choose>
                <xsl:when test="$iBorder=1">
                    <tex:spec cat="vert"/>
                </xsl:when>
                <xsl:when test="$iBorder=2">
                    <tex:spec cat="vert"/>
                    <tex:spec cat="vert"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
      DefineAFont
   -->
    <xsl:template name="DefineAFont">
        <xsl:param name="sFontName"/>
        <xsl:param name="sBaseFontName"/>
        <xsl:param name="sPointSize"/>
        <xsl:param name="bIsBold" select="'N'"/>
        <xsl:param name="bIsItalic" select="'N'"/>
        <xsl:param name="sColor" select="'default'"/>
        <tex:spec cat="esc"/>font<tex:spec cat="esc"/>
        <xsl:value-of select="$sFontName"/>
        <xsl:text>="</xsl:text>
        <xsl:value-of select="$sBaseFontName"/>
        <xsl:if test="$bIsBold='Y'">/B</xsl:if>
        <xsl:if test="$bIsItalic='Y'">/I</xsl:if>
        <xsl:if test="$sColor!='default'">
            <xsl:text>:color=</xsl:text>
            <xsl:call-template name="GetColorHexCode">
                <xsl:with-param name="sColor" select="$sColor"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:text>" at </xsl:text>
        <xsl:value-of select="$sPointSize"/>
        <xsl:text>pt
</xsl:text>
    </xsl:template>
    <!--  
      DefineAFontFamily
   -->
    <xsl:template name="DefineAFontFamily">
        <xsl:param name="sFontFamilyName"/>
        <xsl:param name="sBaseFontName"/>
        <tex:cmd name="newfontfamily" nl2="1">
            <tex:parm>
                <tex:spec cat="esc"/>
                <xsl:value-of select="$sFontFamilyName"/>
            </tex:parm>
            <tex:parm>
                <xsl:value-of select="$sBaseFontName"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
      DetermineIfInARowSpan
   -->
    <xsl:template name="DetermineIfInARowSpan">
        <xsl:variable name="myCell" select="."/>
        <xsl:variable name="iMyRowNumber" select="count(../preceding-sibling::tr)"/>
        <xsl:variable name="previousTdsWithRowSpans" select="../preceding-sibling::tr/td[@rowspan] | ../preceding-sibling::tr/th[@rowspan]"/>
        <xsl:for-each select="$previousTdsWithRowSpans">
            <xsl:variable name="iRowSpanRowNumber" select="count(../preceding-sibling::tr)"/>
            <xsl:if test="($iMyRowNumber - $iRowSpanRowNumber) + 1 &lt;= @rowspan">
                <!-- this implies that somewhere in this row, we need an empty cell; figure out if the current cell ($myCell) is the right one -->
                <xsl:variable name="precedingSiblings" select="preceding-sibling::td | preceding-sibling::th"/>
                <xsl:variable name="iColWithRowSpan" select="count($precedingSiblings[not(number(@colspan) &gt; 0)]) + sum($precedingSiblings[number(@colspan) &gt; 0]/@colspan)"/>
                <xsl:variable name="iPreviousRowSpansInMyRow" select="count($precedingSiblings[@rowspan][($iMyRowNumber - $iRowSpanRowNumber) + 1 &lt;= @rowspan])"/>
                <xsl:variable name="myPrecedingSiblings" select="$myCell/preceding-sibling::td | $myCell/preceding-sibling::th"/>
                <xsl:variable name="iMyColumn" select="count($myPrecedingSiblings[not(number(@colspan) &gt; 0)]) + sum($myPrecedingSiblings[number(@colspan) &gt; 0]/@colspan) + $iPreviousRowSpansInMyRow"/>
                <xsl:if test="$iMyColumn = $iColWithRowSpan">
                    <xsl:text>Y</xsl:text>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!--  
      DoAbbreviations
   -->
    <xsl:template name="DoAbbreviations">
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id" select="'rXLingPapAbbreviations'"/>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputAbbreviationsLabel"/>
            </xsl:with-param>
            <xsl:with-param name="bIsBook" select="'N'"/>
            <xsl:with-param name="bForcePageBreak" select="'N'"/>
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
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id">rXLingPapAcknowledgements</xsl:with-param>
                    <xsl:with-param name="sTitle">
                        <xsl:call-template name="OutputAcknowledgementsLabel"/>
                    </xsl:with-param>
                    <xsl:with-param name="bIsBook" select="$bIsBook"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id">
                        <xsl:call-template name="CreatePrefaceID"/>
                    </xsl:with-param>
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
      DoBeginExternalHyperRef
   -->
    <xsl:template name="DoExternalHyperRefBegin">
        <xsl:param name="sName"/>
        <!-- 
      <tex:spec cat="esc"/>special<tex:spec cat="bg"/>
      <xsl:text>html:</xsl:text>
      <tex:spec cat="lt"/>
      <xsl:text>a href="#</xsl:text>
      <xsl:value-of select="$sName"/>
      <xsl:text>"/</xsl:text>
      <tex:spec cat="gt"/>
      <tex:spec cat="eg"/>
-->
        <tex:spec cat="esc"/>
        <xsl:text>href</xsl:text>
        <tex:spec cat="bg"/>
        <xsl:value-of select="$sName"/>
        <tex:spec cat="eg"/>
        <tex:spec cat="bg"/>
    </xsl:template>
    <!--
      DoBeginInternalHyperlink
   -->
    <xsl:template name="DoInternalHyperlinkBegin">
        <xsl:param name="sName"/>
        <tex:spec cat="esc"/>
        <xsl:text>hyperlink</xsl:text>
        <tex:spec cat="bg"/>
        <xsl:value-of select="$sName"/>
        <tex:spec cat="eg"/>
        <tex:spec cat="bg"/>
    </xsl:template>
    <!--
      DoBeginInternalTarget
   -->
    <xsl:template name="DoInternalTargetBegin">
        <xsl:param name="sName"/>
        <tex:spec cat="esc"/>
        <xsl:text>hypertarget</xsl:text>
        <tex:spec cat="bg"/>
        <xsl:value-of select="$sName"/>
        <tex:spec cat="eg"/>
        <tex:spec cat="bg"/>
    </xsl:template>
    <!--
                  DoCellAttributes
  -->
    <xsl:template name="DoCellAttributes">
        <xsl:param name="iBorder" select="0"/>
        <xsl:param name="bInARowSpan"/>
        <xsl:choose>
            <xsl:when test="number(@colspan) &gt; 0">
                <tex:cmd name="multicolumn">
                    <tex:parm>
                        <xsl:value-of select="@colspan"/>
                    </tex:parm>
                    <tex:parm>
                        <xsl:if test="count(preceding-sibling::*) = 0 and not(contains($bInARowSpan,'Y'))">
                            <!--                     <xsl:if test="count(preceding-sibling::*) = 0">-->
                            <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
                        </xsl:if>
                        <xsl:call-template name="CreateColumnSpec">
                            <xsl:with-param name="iBorder" select="$iBorder"/>
                        </xsl:call-template>
                        <xsl:if test="count(following-sibling::*) = 0">
                            <xsl:call-template name="CreateVerticalLine">
                                <xsl:with-param name="iBorder" select="$iBorder"/>
                            </xsl:call-template>
                            <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
                        </xsl:if>
                    </tex:parm>
                </tex:cmd>
                <tex:spec cat="bg"/>
            </xsl:when>
            <xsl:when test="number(@rowspan) &gt; 0">
                <tex:cmd name="multirow">
                    <tex:parm>
                        <xsl:value-of select="@rowspan"/>
                    </tex:parm>
                    <tex:parm>
                        <xsl:text>*</xsl:text>
                    </tex:parm>
                    <xsl:if test="@valign">
                        <xsl:variable name="iAdjustFactor" select="(@rowspan - 1) * 1.25"/>
                        <xsl:choose>
                            <xsl:when test="@valign='top'">
                                <tex:opt>
                                    <xsl:value-of select="$iAdjustFactor"/>
                                    <xsl:text>ex</xsl:text>
                                </tex:opt>
                            </xsl:when>
                            <xsl:when test="@valign='bottom'">
                                <tex:opt>
                                    <xsl:text>-</xsl:text>
                                    <xsl:value-of select="$iAdjustFactor"/>
                                    <xsl:text>ex</xsl:text>
                                </tex:opt>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                </tex:cmd>
                <tex:spec cat="bg"/>
            </xsl:when>
            <xsl:when test="@align">
                <tex:cmd name="multicolumn">
                    <tex:parm>1</tex:parm>
                    <tex:parm>
                        <xsl:if test="count(preceding-sibling::*) = 0 and not(contains($bInARowSpan,'Y'))">
                            <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
                        </xsl:if>
                        <xsl:call-template name="CreateColumnSpec">
                            <xsl:with-param name="iBorder" select="$iBorder"/>
                        </xsl:call-template>
                        <xsl:if test="count(following-sibling::*) = 0">
                            <xsl:call-template name="CreateVerticalLine">
                                <xsl:with-param name="iBorder" select="$iBorder"/>
                            </xsl:call-template>
                            <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
                        </xsl:if>
                    </tex:parm>
                </tex:cmd>
                <tex:spec cat="bg"/>
            </xsl:when>
        </xsl:choose>
        <!--  later
      <xsl:if test="@valign">
         <xsl:attribute name="display-align">
            <xsl:choose>
               <xsl:when test="@valign='top'">before</xsl:when>
               <xsl:when test="@valign='middle'">center</xsl:when>
               <xsl:when test="@valign='bottom'">after</xsl:when>
               - I'm not sure what we should do with this one... -
               <xsl:when test="@valign='baseline'">center</xsl:when>
               <xsl:otherwise>auto</xsl:otherwise>
            </xsl:choose>
         </xsl:attribute>
      </xsl:if>
      <xsl:if test="@width">
         <xsl:attribute name="width">
            <xsl:value-of select="@width"/>
         </xsl:attribute>
      </xsl:if>
      -->
    </xsl:template>
    <!--
      DoCellAttributesEnd
   -->
    <xsl:template name="DoCellAttributesEnd">
        <xsl:choose>
            <xsl:when test="number(@colspan) &gt; 0">
                <tex:spec cat="eg"/>
            </xsl:when>
            <xsl:when test="number(@rowspan) &gt; 0">
                <tex:spec cat="eg"/>
            </xsl:when>
            <xsl:when test="@align">
                <tex:spec cat="eg"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
                  DoContents
                  -->
    <xsl:template name="DoContents">
        <xsl:param name="bIsBook" select="'Y'"/>
        <tex:cmd name="XLingPapertableofcontents" gr="0" nl2="0"/>
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
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id" select="'rXLingPapContents'"/>
                    <xsl:with-param name="sTitle">
                        <xsl:call-template name="OutputContentsLabel"/>
                    </xsl:with-param>
                    <xsl:with-param name="bIsBook" select="'N'"/>
                    <xsl:with-param name="bForcePageBreak" select="'N'"/>
                </xsl:call-template>
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
                    <xsl:with-param name="sLink">
                        <xsl:call-template name="CreatePrefaceID"/>
                    </xsl:with-param>
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
        <xsl:if test="not(//part) and //chapter">
            <xsl:for-each select="//chapter">
                <xsl:call-template name="OutputAllChapterTOC">
                    <xsl:with-param name="nLevel">
                        <xsl:value-of select="$nLevel"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
        <!-- section, no chapters -->
        <xsl:if test="not(//part) and not(//chapter)">
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
                <xsl:call-template name="OutputTOCLine">
                    <xsl:with-param name="sLink">
                        <xsl:call-template name="CreateGlossaryID"/>
                    </xsl:with-param>
                    <xsl:with-param name="sLabel">
                        <xsl:call-template name="OutputGlossaryLabel"/>
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
      DoEndInternalTarget
   -->
    <xsl:template name="DoInternalTargetEnd">
        <!-- 
      <tex:spec cat="esc"/>special<tex:spec cat="bg"/>
      <xsl:text>html:</xsl:text>
      <tex:spec cat="lt"/>
      <xsl:text>/a</xsl:text>
      <tex:spec cat="gt"/>
      <tex:spec cat="eg"/>
      -->
        <tex:spec cat="eg"/>
    </xsl:template>
    <!--  
      DoEndHyperRef
   -->
    <xsl:template name="DoExternalHyperRefEnd">
        <xsl:call-template name="DoInternalTargetEnd"/>
    </xsl:template>
    <!--  
                  DoGlossary
-->
    <xsl:template name="DoGlossary">
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id">
                <xsl:call-template name="CreateGlossaryID"/>
            </xsl:with-param>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputGlossaryLabel"/>
            </xsl:with-param>
            <xsl:with-param name="bIsBook" select="'N'"/>
            <xsl:with-param name="bForcePageBreak" select="'N'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <!--  
                  DoIndex
-->
    <xsl:template name="DoIndex">
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id">
                <xsl:call-template name="CreateIndexID"/>
            </xsl:with-param>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputIndexLabel"/>
            </xsl:with-param>
            <xsl:with-param name="bIsBook" select="'N'"/>
            <xsl:with-param name="bForcePageBreak" select="'N'"/>
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
            <xsl:with-param name="lang" select="//lingPaper/@indexlang"/>
            <xsl:with-param name="terms" select="//lingPaper/indexTerms"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
      DoInterlinearFree
   -->
    <xsl:template name="DoInterlinearFree">
        <xsl:param name="mode"/>
        <!--      <fo:block keep-with-previous.within-page="1">-->
        <tex:spec cat="align"/>
        <tex:cmd name="multicolumn">
            <tex:parm>
                <xsl:value-of select="$sInterlinearMaxNumberOfColumns"/>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="DoInterlinearInitialHorizontalOffset"/>
                <!--use a paragraph box whose width is the space currently available-->
                <xsl:text>p</xsl:text>
                <tex:spec cat="bg"/>
                <xsl:call-template name="GetFreeParboxWidth"/>
                <tex:spec cat="eg"/>
            </tex:parm>
            <tex:parm>
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
                <xsl:if test="preceding-sibling::free[@lang=$sCurrentLanguage][position()=1] or preceding-sibling::free[not(@lang)][position()=1] or name(../..)='interlinear' or name(../..)='listInterlinear' and name(..)='interlinear' and $iParentPosition!=1">
                    <!--            <xsl:attribute name="margin-left">-->
                    <tex:cmd name="hspace*">
                        <tex:parm>
                            <xsl:text>0.1in</xsl:text>
                        </tex:parm>
                    </tex:cmd>
                    <!--            </xsl:attribute>-->
                </xsl:if>
                <!-- 
            <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            </fo:inline>
         -->
                <xsl:choose>
                    <xsl:when test="@lang">
                        <tex:cmd name="Lang{@lang}FontFamily">
                            <tex:parm>
                                <xsl:apply-templates/>
                            </tex:parm>
                        </tex:cmd>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="$mode!='NoTextRef'">
                    
                <xsl:if test="$sInterlinearSourceStyle='AfterFree' and not(following-sibling::free) and not(following-sibling::interlinear[descendant::free])">
<!--                    <xsl:if test="name(../..)='example'  or name(../..)='listInterlinear'">-->
                        
                    <xsl:if test="ancestor::example  or ancestor::listInterlinear or ancestor::interlinear[@textref]">
                        <xsl:call-template name="OutputInterlinearTextReference">
                            <xsl:with-param name="sRef" select="ancestor::interlinear[@textref]/@textref"/>
                            <xsl:with-param name="sSource" select="../interlinearSource"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:if>
                </xsl:if>
            </tex:parm>
        </tex:cmd>
        <tex:spec cat="esc"/>
        <tex:spec cat="esc" nl2="1"/>
        <xsl:if test="$sInterlinearSourceStyle='UnderFree' and not(following-sibling::free)">
<!--            <xsl:if test="name(../..)='example' or name(../..)='listInterlinear'">-->
                
            <xsl:if test="ancestor::example or ancestor::listInterlinear">
                <!--            <fo:block keep-with-previous.within-page="1">-->
                <tex:group>
                    <xsl:call-template name="OutputInterlinearTextReference">
                        <xsl:with-param name="sRef" select="../@textref"/>
                        <xsl:with-param name="sSource" select="../interlinearSource"/>
                    </xsl:call-template>
                </tex:group>
                <!--            </fo:block>-->
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
      DoInterlinearInitialHorizontalOffset
   -->
    <xsl:template name="DoInterlinearInitialHorizontalOffset">
        <xsl:param name="sHorizontalOffset" select="$sInterlinearInitialHorizontalOffset"/>
        <xsl:text>@</xsl:text>
        <tex:spec cat="bg"/>
        <tex:spec cat="esc"/>
        <xsl:text>hspace*</xsl:text>
        <tex:spec cat="bg"/>
        <xsl:value-of select="$sHorizontalOffset"/>
        <tex:spec cat="eg"/>
        <tex:spec cat="eg"/>
    </xsl:template>
    <!--  
      DoInterlinearLine
   -->
    <xsl:template name="DoInterlinearLine">
        <xsl:param name="mode"/>
        <!--      <fo:table-row>-->
        <xsl:variable name="bRtl">
            <xsl:choose>
                <xsl:when test="id(parent::lineGroup/line[1]/wrd/langData[1]/@lang)/@rtl='yes'">Y</xsl:when>
                <xsl:otherwise>N</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="wrd">
                <xsl:for-each select="wrd">
                    <!-- 
                  <fo:table-cell xsl:use-attribute-sets="ExampleCell">
                     <xsl:if test="$bRtl='Y'">
                        <xsl:attribute name="text-align">right</xsl:attribute>
                     </xsl:if>
                     <xsl:call-template name="DoDebugExamples"/>
                     <fo:block>
                        <xsl:call-template name="OutputFontAttributes">
                           <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                        </xsl:call-template>
                  -->
                    <tex:spec cat="align"/>
                    <xsl:choose>
                        <xsl:when test="@lang">
                            <!-- using cmd and parm outputs an unwanted space when there is an initial object - SIGH - does not do any better.... need to try spec nil -->
                            <xsl:call-template name="OutputFontAttributes">
                                <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                            </xsl:call-template>
                            <!--                     <tex:cmd name="Lang{@lang}Font">-->
                            <!--                        <tex:parm>-->
                            <xsl:apply-templates/>
                            <!--                     <tex:spec cat="eg"/>-->
                            <!--                        </tex:parm>-->
                            <!--                     </tex:cmd>-->
                            <xsl:call-template name="OutputFontAttributesEnd">
                                <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!--  
                     </fo:block>
                  </fo:table-cell>
                       -->
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
                    <!--               <xsl:apply-templates/>  Why do we want to include all the parameters, etc. when what we really want is the text? -->
                    <xsl:value-of select="."/>
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
                <xsl:call-template name="OutputInterlinearLineAsTableCells">
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
                    <xsl:if test="string-length(normalize-space(../../@textref)) &gt; 0 or string-length(normalize-space(../../interlinearSource)) &gt; 0">
                        <!--                  <fo:table-cell text-align="start" xsl:use-attribute-sets="ExampleCell">-->
                        <tex:spec cat="align"/>
                        <xsl:call-template name="DoDebugExamples"/>
                        <xsl:call-template name="OutputInterlinearTextReference">
                            <xsl:with-param name="sRef" select="../../@textref"/>
                            <xsl:with-param name="sSource" select="../../interlinearSource"/>
                        </xsl:call-template>
                        <!--                  </fo:table-cell>-->
                    </xsl:if>
                </xsl:if>
            </xsl:if>
        </xsl:if>
        <tex:spec cat="esc"/>
        <tex:spec cat="esc"/>
        <xsl:text>*
</xsl:text>
        <!--      </fo:table-row>-->
    </xsl:template>
    <!--  
      DoInterlinearLineGroup
   -->
    <xsl:template name="DoInterlinearLineGroup">
        <xsl:param name="mode"/>
        <!-- 
      <fo:block>
         <! - add extra indent for when have an embedded interlinear; 
            be sure to allow for the case of when a listInterlinear begins with an interlinear - >
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
      -->
        <xsl:variable name="parent" select=".."/>
        <xsl:variable name="iParentPosition">
            <xsl:for-each select="../../*">
                <xsl:if test=".=$parent">
                    <xsl:value-of select="position()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="name(../..)='interlinear' or name(../..)='listInterlinear' and name(..)='interlinear' and $iParentPosition!=1">
                <xsl:text>[3pt]</xsl:text>
                <tex:spec cat="align"/>
                <tex:spec cat="esc"/>
                <xsl:text>multicolumn</xsl:text>
                <tex:spec cat="bg"/>
                <xsl:value-of select="$sInterlinearMaxNumberOfColumns"/>
                <tex:spec cat="eg"/>
                <tex:spec cat="bg"/>
                <xsl:text>l</xsl:text>
                <tex:spec cat="eg"/>
                <tex:spec cat="bg"/>
                <tex:env name="tabular">
                    <tex:opt>t</tex:opt>
                    <tex:parm>
                        <xsl:call-template name="DoInterlinearTabularMainPattern"/>
                    </tex:parm>
                    <xsl:call-template name="ApplyTemplatesPerTextRefMode">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                </tex:env>
                <tex:spec cat="eg"/>
                <tex:spec cat="esc"/>
                <tex:spec cat="esc"/>
                <xsl:text>*
</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="ApplyTemplatesPerTextRefMode">
                    <xsl:with-param name="mode" select="$mode"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      DoInterlinearTabularMainPattern
   -->
    <xsl:template name="DoInterlinearTabularMainPattern">
        <xsl:text>*</xsl:text>
        <tex:spec cat="bg"/>
        <xsl:value-of select="$sInterlinearMaxNumberOfColumns"/>
        <tex:spec cat="eg"/>
        <tex:spec cat="bg"/>
        <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
        <xsl:text>l@</xsl:text>
        <tex:spec cat="bg"/>
        <tex:spec cat="esc"/>
        <tex:spec cat="space"/>
        <tex:spec cat="eg"/>
        <tex:spec cat="eg"/>
        <xsl:text>l</xsl:text>
    </xsl:template>
    <!--  
      DoListLetter
   -->
    <xsl:template name="DoListLetter">
        <xsl:param name="sLetterWidth"/>
        <tex:spec cat="align"/>
        <tex:cmd name="parbox">
            <tex:opt>b</tex:opt>
            <tex:parm>
                <xsl:value-of select="$sLetterWidth"/>
                <xsl:text>em</xsl:text>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="DoInternalTargetBegin">
                    <xsl:with-param name="sName" select="@letter"/>
                </xsl:call-template>
                <xsl:apply-templates select="." mode="letter"/>
                <xsl:text>.</xsl:text>
                <xsl:call-template name="DoInternalTargetEnd"/>
            </tex:parm>
        </tex:cmd>
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
      DoNestedTypesEnd
   -->
    <xsl:template name="DoNestedTypesEnd">
        <xsl:param name="sList"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:if test="string-length($sFirst) &gt; 0">
            <xsl:call-template name="DoTypeEnd">
                <xsl:with-param name="type" select="$sFirst"/>
            </xsl:call-template>
            <xsl:if test="$sRest">
                <xsl:call-template name="DoNestedTypesEnd">
                    <xsl:with-param name="sList" select="$sRest"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
      DoNotBreakHere
   -->
    <xsl:template name="DoNotBreakHere">
        <tex:spec cat="esc"/>
        <xsl:text>penalty10000</xsl:text>
    </xsl:template>
    <!--  
                  DoReferences
-->
    <xsl:template name="DoReferences">
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id" select="'rXLingPapReferences'"/>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputReferencesLabel"/>
            </xsl:with-param>
            <xsl:with-param name="bIsBook" select="'N'"/>
            <xsl:with-param name="bForcePageBreak" select="'N'"/>
        </xsl:call-template>
        <tex:env name="description">
            <xsl:call-template name="SetTeXCommand">
                <xsl:with-param name="sTeXCommand" select="'setlength'"/>
                <xsl:with-param name="sCommandToSet" select="'itemsep'"/>
                <xsl:with-param name="sValue" select="'0pt'"/>
            </xsl:call-template>
            <xsl:call-template name="SetTeXCommand">
                <xsl:with-param name="sTeXCommand" select="'setlength'"/>
                <xsl:with-param name="sCommandToSet" select="'parsep'"/>
                <xsl:with-param name="sValue" select="'0pt'"/>
            </xsl:call-template>
            <xsl:call-template name="SetTeXCommand">
                <xsl:with-param name="sTeXCommand" select="'setlength'"/>
                <xsl:with-param name="sCommandToSet" select="'parskip'"/>
                <xsl:with-param name="sValue" select="'0pt'"/>
            </xsl:call-template>
            <tex:cmd name="raggedright" gr="0" nl2="1"/>
            <xsl:for-each select="//refAuthor[refWork/@id=//citation/@ref]">
                <xsl:variable name="works" select="refWork[@id=//citation/@ref]"/>
                <xsl:for-each select="$works">
                    <tex:cmd name="item" gr="0" nl2="1"/>
                    <xsl:call-template name="DoInternalTargetBegin">
                        <xsl:with-param name="sName" select="@id"/>
                    </xsl:call-template>
                    <xsl:variable name="author">
                        <xsl:value-of select="normalize-space(../@name)"/>
                    </xsl:variable>
                    <xsl:value-of select="$author"/>
                    <xsl:if test="substring($author,string-length($author),string-length($author))!='.'">.</xsl:if>
                    <xsl:call-template name="DoInternalTargetEnd"/>
                    <xsl:text>&#x20;  </xsl:text>
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
                        <tex:cmd name="textit">
                            <tex:parm>
                                <xsl:apply-templates select="refTitle"/>
                            </tex:parm>
                        </tex:cmd>
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
                            <xsl:call-template name="OutputPeriodIfNeeded">
                                <xsl:with-param name="sText" select="book/series"/>
                            </xsl:call-template>
                            <xsl:text>&#x20;</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(book/location)"/>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="normalize-space(book/publisher)"/>
                        <xsl:call-template name="OutputPeriodIfNeeded">
                            <xsl:with-param name="sText" select="book/publisher"/>
                        </xsl:call-template>
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
                        <xsl:value-of select="normalize-space(collection/collEd)"/>
                        <xsl:text>, ed</xsl:text>
                        <xsl:if test="collection/collEd/@plural='yes'">
                            <xsl:text>s</xsl:text>
                        </xsl:if>
                        <xsl:text>. </xsl:text>
                        <tex:cmd name="textit">
                            <tex:parm>
                                <xsl:value-of select="normalize-space(collection/collTitle)"/>
                            </tex:parm>
                        </tex:cmd>
                        <xsl:choose>
                            <xsl:when test="collection/collVol">
                                <xsl:text>&#x20;</xsl:text>
                                <xsl:value-of select="normalize-space(collection/collVol)"/>
                                <xsl:text>:</xsl:text>
                                <xsl:value-of select="normalize-space(collection/collPages)"/>
                                <xsl:text>. </xsl:text>
                            </xsl:when>
                            <xsl:when test="collection/collPages">
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="normalize-space(collection/collPages)"/>
                                <xsl:text>. </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>.</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
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
                        <xsl:value-of select="normalize-space(collection/publisher)"/>
                        <xsl:call-template name="OutputPeriodIfNeeded">
                            <xsl:with-param name="sText" select="collection/publisher"/>
                        </xsl:call-template>
                    </xsl:if>
                    <!--
                               dissertation
 -->
                    <xsl:if test="dissertation">
                        <tex:cmd name="textit">
                            <tex:parm>
                                <xsl:apply-templates select="refTitle"/>
                            </tex:parm>
                        </tex:cmd>
                        <xsl:text>.  </xsl:text>
                        <xsl:text> Ph.D. dissertation.</xsl:text>
                        <xsl:if test="dissertation/location">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="normalize-space(dissertation/location)"/>
                            <xsl:text>).  </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(dissertation/institution)"/>
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
                        <tex:cmd name="textit">
                            <tex:parm>
                                <xsl:value-of select="normalize-space(article/jTitle)"/>
                            </tex:parm>
                        </tex:cmd>
                        <xsl:text>&#x20;</xsl:text>
                        <xsl:value-of select="normalize-space(article/jVol)"/>
                        <xsl:choose>
                            <xsl:when test="article/jPages">
                                <xsl:text>:</xsl:text>
                                <xsl:value-of select="normalize-space(article/jPages)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="normalize-space(article/jArticleNumber)"/>
                            </xsl:otherwise>
                        </xsl:choose>
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
                            <xsl:when test="proceedings/procEd">
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
                        </xsl:choose>
                        <tex:cmd name="textit">
                            <tex:parm>
                                <xsl:value-of select="normalize-space(proceedings/procTitle)"/>
                            </tex:parm>
                        </tex:cmd>
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
                        <xsl:value-of select="normalize-space(proceedings/location)"/>
                        <xsl:if test="proceedings/publisher">
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="normalize-space(proceedings/publisher)"/>
                        </xsl:if>
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                    <!--
                               thesis
 -->
                    <xsl:if test="thesis">
                        <tex:cmd name="textit">
                            <tex:parm>
                                <xsl:apply-templates select="refTitle"/>
                            </tex:parm>
                        </tex:cmd>
                        <xsl:text>.  </xsl:text>
                        <xsl:if test="thesis/location">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="normalize-space(thesis/location)"/>
                            <xsl:text>).  </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(thesis/institution)"/>
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
                        <!--                  <fo:basic-link external-destination="url({normalize-space(webPage/url)})">-->
                        <xsl:call-template name="AddAnyLinkAttributes"/>
                        <xsl:call-template name="DoExternalHyperRefBegin">
                            <xsl:with-param name="sName" select="normalize-space(webPage/url)"/>
                        </xsl:call-template>
                        <xsl:value-of select="normalize-space(webPage/url)"/>
                        <xsl:call-template name="DoExternalHyperRefEnd"/>
                        <!--                  </fo:basic-link>-->
                        <xsl:text>).</xsl:text>
                    </xsl:if>
                    <xsl:if test="url">
                        <!--                  <fo:basic-link external-destination="url({normalize-space(url)})">-->
                        <xsl:call-template name="AddAnyLinkAttributes"/>
                        <xsl:text>&#x20;</xsl:text>
                        <xsl:call-template name="DoExternalHyperRefBegin">
                            <xsl:with-param name="sName" select="normalize-space(url)"/>
                        </xsl:call-template>
                        <xsl:value-of select="normalize-space(url)"/>
                        <xsl:call-template name="DoExternalHyperRefEnd"/>
                        <!--                  </fo:basic-link>-->
                        <xsl:if test="dateAccessed">
                            <xsl:text>  (accessed </xsl:text>
                            <xsl:value-of select="normalize-space(dateAccessed)"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                    <xsl:for-each select="iso639-3code">
                        <xsl:sort/>
                        <tex:cmd name="small">
                            <tex:parm>
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
                            </tex:parm>
                        </tex:cmd>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </tex:env>
    </xsl:template>
    <!--  
      DoSectionRefLabel
   -->
    <xsl:template name="DoSectionRefLabel">
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
      DoSectionLevelTitle
   -->
    <xsl:template name="DoSectionLevelTitle">
        <xsl:param name="bIsCentered" select="'N'"/>
        <xsl:param name="sFontFamily"/>
        <xsl:param name="sFontSize" select="'normalsize'"/>
        <xsl:param name="sBold"/>
        <xsl:param name="sItalic"/>
        <tex:cmd name="vspace" nl1="1" nl2="1">
            <tex:parm><xsl:value-of select="$sBasicPointSize"/>pt</tex:parm>
        </tex:cmd>
        <xsl:call-template name="OKToBreakHere"/>
        <tex:group nl1="1" nl2="1">
            <xsl:variable name="sOrientation">
                <xsl:choose>
                    <xsl:when test="$bIsCentered='Y'">
                        <xsl:text>centerline</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>noindent</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <tex:cmd name="{$sOrientation}" nl2="1">
                <tex:parm>
                    <xsl:call-template name="DoInternalTargetBegin">
                        <xsl:with-param name="sName" select="@id"/>
                    </xsl:call-template>
                    <tex:cmd name="{$sFontFamily}">
                        <tex:parm>
                            <tex:cmd name="{$sFontSize}">
                                <tex:parm>
                                    <!-- since we do not have a way to say 'normal' , we have to do the bold this way-->
                                    <xsl:if test="$sBold='textbf'">
                                        <tex:spec cat="esc"/>
                                        <xsl:text>textbf</xsl:text>
                                        <tex:spec cat="bg"/>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="$sItalic='textit'">
                                            <tex:cmd name="{$sItalic}">
                                                <tex:parm>
                                                    <xsl:call-template name="OutputSectionNumberAndTitle"/>
                                                </tex:parm>
                                            </tex:cmd>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="OutputSectionNumberAndTitle"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:if test="$sBold='textbf'">
                                        <tex:spec cat="eg"/>
                                    </xsl:if>
                                </tex:parm>
                            </tex:cmd>
                        </tex:parm>
                    </tex:cmd>
                    <xsl:call-template name="DoInternalTargetEnd"/>
                </tex:parm>
            </tex:cmd>
            <tex:cmd name="markright" nl2="1">
                <tex:parm>
                    <xsl:call-template name="DoSecTitleRunningHeader"/>
                </tex:parm>
            </tex:cmd>
            <tex:cmd name="pdfbookmark" nl1="1" nl2="1">
                <tex:opt>
                    <xsl:choose>
                        <xsl:when test="name()='section1' and ancestor::appendix">2</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring-after(name(),'section')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </tex:opt>
                <tex:parm>
                    <xsl:call-template name="OutputSectionNumberAndTitle">
                        <xsl:with-param name="bIsBookmark" select="'Y'"/>
                    </xsl:call-template>
                </tex:parm>
                <tex:parm>
                    <xsl:value-of select="@id"/>
                </tex:parm>
            </tex:cmd>
            <xsl:call-template name="CreateAddToContents">
                <xsl:with-param name="id" select="@id"/>
            </xsl:call-template>
        </tex:group>
        <tex:cmd name="par"/>
        <xsl:call-template name="DoNotBreakHere"/>
        <tex:cmd name="vspace" nl1="1" nl2="1">
            <tex:parm><xsl:value-of select="$sBasicPointSize"/>pt</tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
      DoRowBackgroundColor
   -->
    <xsl:template name="DoRowBackgroundColor">
        <xsl:param name="bMarkAsRow" select="'Y'"/>
        <xsl:call-template name="OutputBackgroundColor">
            <xsl:with-param name="bIsARow" select="$bMarkAsRow"/>
        </xsl:call-template>
        <xsl:for-each select="key('TypeID',@type)">
            <!-- note: this does not handle nested types -->
            <xsl:call-template name="OutputBackgroundColor">
                <xsl:with-param name="bIsARow" select="$bMarkAsRow"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--  
                  DoSecTitleRunningHeader
-->
    <xsl:template name="DoSecTitleRunningHeader">
        <xsl:choose>
            <xsl:when test="string-length(shortTitle) &gt; 0">
                <xsl:apply-templates select="shortTitle" mode="InMarker"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="secTitle"/>
            </xsl:otherwise>
        </xsl:choose>
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
      DoTypeEnd
   -->
    <xsl:template name="DoTypeEnd">
        <xsl:param name="type" select="@type"/>
        <xsl:for-each select="key('TypeID',$type)">
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
            <xsl:call-template name="DoNestedTypesEnd">
                <xsl:with-param name="sList" select="@types"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--  
      ExampleNumber
   -->
    <xsl:template name="ExampleNumber">
        <xsl:text>(</xsl:text>
        <xsl:choose>
            <xsl:when test="ancestor::endnote">
                <xsl:apply-templates select="." mode="exampleInEndnote"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="example"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>)</xsl:text>
    </xsl:template>
    <!--  
      GetColorDecimalCodeFromHexCode
   -->
    <xsl:template name="GetColorDecimalCodeFromHexCode">
        <xsl:param name="sColorHexCode"/>
        <xsl:variable name="s16" select="substring($sColorHexCode,1,1)"/>
        <xsl:variable name="s1" select="substring($sColorHexCode,2,1)"/>
        <xsl:variable name="i16">
            <xsl:call-template name="ConvertHexToDecimal">
                <xsl:with-param name="sValue" select="$s16"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="i1">
            <xsl:call-template name="ConvertHexToDecimal">
                <xsl:with-param name="sValue" select="$s1"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="($i16 * 16 + $i1) div 255"/>
    </xsl:template>
    <!--  
      GetColorDecimalCodesFromHexCode
   -->
    <xsl:template name="GetColorDecimalCodesFromHexCode">
        <xsl:param name="sColorHexCode"/>
        <!-- the color package wants the RGB values in a decimal triplet, each value is to be between 0 and 1 -->
        <xsl:call-template name="GetColorDecimalCodeFromHexCode">
            <xsl:with-param name="sColorHexCode" select="substring($sColorHexCode,1,2)"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="GetColorDecimalCodeFromHexCode">
            <xsl:with-param name="sColorHexCode" select="substring($sColorHexCode,3,2)"/>
        </xsl:call-template>
        <xsl:text>,</xsl:text>
        <xsl:call-template name="GetColorDecimalCodeFromHexCode">
            <xsl:with-param name="sColorHexCode" select="substring($sColorHexCode,5,2)"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
      GetColorHexCode
   -->
    <xsl:template name="GetColorHexCode">
        <xsl:param name="sColor"/>
        <xsl:choose>
            <xsl:when test="$sColor='AliceBlue'">F0F8FF</xsl:when>
            <xsl:when test="$sColor='aliceblue'">F0F8FF</xsl:when>
            <xsl:when test="$sColor='AntiqueWhite'">FAEBD7</xsl:when>
            <xsl:when test="$sColor='antiquewhite'">FAEBD7</xsl:when>
            <xsl:when test="$sColor='Aqua'">00FFFF</xsl:when>
            <xsl:when test="$sColor='aqua'">00FFFF</xsl:when>
            <xsl:when test="$sColor='Aquamarine'">7FFFD4</xsl:when>
            <xsl:when test="$sColor='aquamarine'">7FFFD4</xsl:when>
            <xsl:when test="$sColor='Azure'">F0FFFF</xsl:when>
            <xsl:when test="$sColor='azure'">F0FFFF</xsl:when>
            <xsl:when test="$sColor='Beige'">F5F5DC</xsl:when>
            <xsl:when test="$sColor='beige'">F5F5DC</xsl:when>
            <xsl:when test="$sColor='Bisque'">FFE4C4</xsl:when>
            <xsl:when test="$sColor='bisque'">FFE4C4</xsl:when>
            <xsl:when test="$sColor='Black'">000000</xsl:when>
            <xsl:when test="$sColor='black'">000000</xsl:when>
            <xsl:when test="$sColor='BlanchedAlmond'">FFEBCD</xsl:when>
            <xsl:when test="$sColor='blanchedalmond'">FFEBCD</xsl:when>
            <xsl:when test="$sColor='Blue'">0000FF</xsl:when>
            <xsl:when test="$sColor='blue'">0000FF</xsl:when>
            <xsl:when test="$sColor='BlueViolet'">8A2BE2</xsl:when>
            <xsl:when test="$sColor='blueviolet'">8A2BE2</xsl:when>
            <xsl:when test="$sColor='Brown'">A52A2A</xsl:when>
            <xsl:when test="$sColor='brown'">A52A2A</xsl:when>
            <xsl:when test="$sColor='BurlyWood'">DEB887</xsl:when>
            <xsl:when test="$sColor='burlywood'">DEB887</xsl:when>
            <xsl:when test="$sColor='CadetBlue'">5F9EA0</xsl:when>
            <xsl:when test="$sColor='cadetblue'">5F9EA0</xsl:when>
            <xsl:when test="$sColor='Chartreuse'">7FFF00</xsl:when>
            <xsl:when test="$sColor='chartreuse'">7FFF00</xsl:when>
            <xsl:when test="$sColor='Chocolate'">D2691E</xsl:when>
            <xsl:when test="$sColor='chocolate'">D2691E</xsl:when>
            <xsl:when test="$sColor='Coral'">FF7F50</xsl:when>
            <xsl:when test="$sColor='coral'">FF7F50</xsl:when>
            <xsl:when test="$sColor='CornflowerBlue'">6495ED</xsl:when>
            <xsl:when test="$sColor='cornflowerblue'">6495ED</xsl:when>
            <xsl:when test="$sColor='Cornsilk'">FFF8DC</xsl:when>
            <xsl:when test="$sColor='cornsilk'">FFF8DC</xsl:when>
            <xsl:when test="$sColor='Crimson'">DC143C</xsl:when>
            <xsl:when test="$sColor='crimson'">DC143C</xsl:when>
            <xsl:when test="$sColor='Cyan'">00FFFF</xsl:when>
            <xsl:when test="$sColor='cyan'">00FFFF</xsl:when>
            <xsl:when test="$sColor='DarkBlue'">00008B</xsl:when>
            <xsl:when test="$sColor='darkblue'">00008B</xsl:when>
            <xsl:when test="$sColor='DarkCyan'">008B8B</xsl:when>
            <xsl:when test="$sColor='darkcyan'">008B8B</xsl:when>
            <xsl:when test="$sColor='DarkGoldenRod'">B8860B</xsl:when>
            <xsl:when test="$sColor='darkgoldenrod'">B8860B</xsl:when>
            <xsl:when test="$sColor='DarkGray'">A9A9A9</xsl:when>
            <xsl:when test="$sColor='darkgray'">A9A9A9</xsl:when>
            <xsl:when test="$sColor='DarkGreen'">006400</xsl:when>
            <xsl:when test="$sColor='darkgreen'">006400</xsl:when>
            <xsl:when test="$sColor='DarkKhaki'">BDB76B</xsl:when>
            <xsl:when test="$sColor='darkkhaki'">BDB76B</xsl:when>
            <xsl:when test="$sColor='DarkMagenta'">8B008B</xsl:when>
            <xsl:when test="$sColor='darkmagenta'">8B008B</xsl:when>
            <xsl:when test="$sColor='DarkOliveGreen'">556B2F</xsl:when>
            <xsl:when test="$sColor='darkolivegreen'">556B2F</xsl:when>
            <xsl:when test="$sColor='Darkorange'">FF8C00</xsl:when>
            <xsl:when test="$sColor='darkorange'">FF8C00</xsl:when>
            <xsl:when test="$sColor='DarkOrchid'">9932CC</xsl:when>
            <xsl:when test="$sColor='darkorchid'">9932CC</xsl:when>
            <xsl:when test="$sColor='DarkRed'">8B0000</xsl:when>
            <xsl:when test="$sColor='darkred'">8B0000</xsl:when>
            <xsl:when test="$sColor='DarkSalmon'">E9967A</xsl:when>
            <xsl:when test="$sColor='darksalmon'">E9967A</xsl:when>
            <xsl:when test="$sColor='DarkSeaGreen'">8FBC8F</xsl:when>
            <xsl:when test="$sColor='darkseagreen'">8FBC8F</xsl:when>
            <xsl:when test="$sColor='DarkSlateBlue'">483D8B</xsl:when>
            <xsl:when test="$sColor='darkslateblue'">483D8B</xsl:when>
            <xsl:when test="$sColor='DarkSlateGray'">2F4F4F</xsl:when>
            <xsl:when test="$sColor='darkslategray'">2F4F4F</xsl:when>
            <xsl:when test="$sColor='DarkTurquoise'">00CED1</xsl:when>
            <xsl:when test="$sColor='darkturquoise'">00CED1</xsl:when>
            <xsl:when test="$sColor='DarkViolet'">9400D3</xsl:when>
            <xsl:when test="$sColor='darkviolet'">9400D3</xsl:when>
            <xsl:when test="$sColor='DeepPink'">FF1493</xsl:when>
            <xsl:when test="$sColor='deeppink'">FF1493</xsl:when>
            <xsl:when test="$sColor='DeepSkyBlue'">00BFFF</xsl:when>
            <xsl:when test="$sColor='deepskyblue'">00BFFF</xsl:when>
            <xsl:when test="$sColor='DimGray'">696969</xsl:when>
            <xsl:when test="$sColor='dimgray'">696969</xsl:when>
            <xsl:when test="$sColor='DodgerBlue'">1E90FF</xsl:when>
            <xsl:when test="$sColor='dodgerblue'">1E90FF</xsl:when>
            <xsl:when test="$sColor='FireBrick'">B22222</xsl:when>
            <xsl:when test="$sColor='firebrick'">B22222</xsl:when>
            <xsl:when test="$sColor='FloralWhite'">FFFAF0</xsl:when>
            <xsl:when test="$sColor='floralwhite'">FFFAF0</xsl:when>
            <xsl:when test="$sColor='ForestGreen'">228B22</xsl:when>
            <xsl:when test="$sColor='forestgreen'">228B22</xsl:when>
            <xsl:when test="$sColor='Fuchsia'">FF00FF</xsl:when>
            <xsl:when test="$sColor='fuchsia'">FF00FF</xsl:when>
            <xsl:when test="$sColor='Gainsboro'">DCDCDC</xsl:when>
            <xsl:when test="$sColor='gainsboro'">DCDCDC</xsl:when>
            <xsl:when test="$sColor='GhostWhite'">F8F8FF</xsl:when>
            <xsl:when test="$sColor='ghostwhite'">F8F8FF</xsl:when>
            <xsl:when test="$sColor='Gold'">FFD700</xsl:when>
            <xsl:when test="$sColor='gold'">FFD700</xsl:when>
            <xsl:when test="$sColor='GoldenRod'">DAA520</xsl:when>
            <xsl:when test="$sColor='goldenrod'">DAA520</xsl:when>
            <xsl:when test="$sColor='Gray'">808080</xsl:when>
            <xsl:when test="$sColor='gray'">808080</xsl:when>
            <xsl:when test="$sColor='Green'">008000</xsl:when>
            <xsl:when test="$sColor='green'">008000</xsl:when>
            <xsl:when test="$sColor='GreenYellow'">ADFF2F</xsl:when>
            <xsl:when test="$sColor='greenyellow'">ADFF2F</xsl:when>
            <xsl:when test="$sColor='HoneyDew'">F0FFF0</xsl:when>
            <xsl:when test="$sColor='honeydew'">F0FFF0</xsl:when>
            <xsl:when test="$sColor='HotPink'">FF69B4</xsl:when>
            <xsl:when test="$sColor='hotpink'">FF69B4</xsl:when>
            <xsl:when test="$sColor='IndianRed '">CD5C5C</xsl:when>
            <xsl:when test="$sColor='indianred '">CD5C5C</xsl:when>
            <xsl:when test="$sColor='Indigo '">4B0082</xsl:when>
            <xsl:when test="$sColor='indigo '">4B0082</xsl:when>
            <xsl:when test="$sColor='Ivory'">FFFFF0</xsl:when>
            <xsl:when test="$sColor='ivory'">FFFFF0</xsl:when>
            <xsl:when test="$sColor='Khaki'">F0E68C</xsl:when>
            <xsl:when test="$sColor='khaki'">F0E68C</xsl:when>
            <xsl:when test="$sColor='Lavender'">E6E6FA</xsl:when>
            <xsl:when test="$sColor='lavender'">E6E6FA</xsl:when>
            <xsl:when test="$sColor='LavenderBlush'">FFF0F5</xsl:when>
            <xsl:when test="$sColor='lavenderblush'">FFF0F5</xsl:when>
            <xsl:when test="$sColor='LawnGreen'">7CFC00</xsl:when>
            <xsl:when test="$sColor='lawngreen'">7CFC00</xsl:when>
            <xsl:when test="$sColor='LemonChiffon'">FFFACD</xsl:when>
            <xsl:when test="$sColor='lemonchiffon'">FFFACD</xsl:when>
            <xsl:when test="$sColor='LightBlue'">ADD8E6</xsl:when>
            <xsl:when test="$sColor='lightblue'">ADD8E6</xsl:when>
            <xsl:when test="$sColor='LightCoral'">F08080</xsl:when>
            <xsl:when test="$sColor='lightcoral'">F08080</xsl:when>
            <xsl:when test="$sColor='LightCyan'">E0FFFF</xsl:when>
            <xsl:when test="$sColor='lightcyan'">E0FFFF</xsl:when>
            <xsl:when test="$sColor='LightGoldenRodYellow'">FAFAD2</xsl:when>
            <xsl:when test="$sColor='lightgoldenrodyellow'">FAFAD2</xsl:when>
            <xsl:when test="$sColor='LightGrey'">D3D3D3</xsl:when>
            <xsl:when test="$sColor='lightgrey'">D3D3D3</xsl:when>
            <xsl:when test="$sColor='LightGreen'">90EE90</xsl:when>
            <xsl:when test="$sColor='lightgreen'">90EE90</xsl:when>
            <xsl:when test="$sColor='LightPink'">FFB6C1</xsl:when>
            <xsl:when test="$sColor='lightpink'">FFB6C1</xsl:when>
            <xsl:when test="$sColor='LightSalmon'">FFA07A</xsl:when>
            <xsl:when test="$sColor='lightsalmon'">FFA07A</xsl:when>
            <xsl:when test="$sColor='LightSeaGreen'">20B2AA</xsl:when>
            <xsl:when test="$sColor='lightseagreen'">20B2AA</xsl:when>
            <xsl:when test="$sColor='LightSkyBlue'">87CEFA</xsl:when>
            <xsl:when test="$sColor='lightskyblue'">87CEFA</xsl:when>
            <xsl:when test="$sColor='LightSlateGray'">778899</xsl:when>
            <xsl:when test="$sColor='lightslategray'">778899</xsl:when>
            <xsl:when test="$sColor='LightSteelBlue'">B0C4DE</xsl:when>
            <xsl:when test="$sColor='lightsteelblue'">B0C4DE</xsl:when>
            <xsl:when test="$sColor='LightYellow'">FFFFE0</xsl:when>
            <xsl:when test="$sColor='lightyellow'">FFFFE0</xsl:when>
            <xsl:when test="$sColor='Lime'">00FF00</xsl:when>
            <xsl:when test="$sColor='lime'">00FF00</xsl:when>
            <xsl:when test="$sColor='LimeGreen'">32CD32</xsl:when>
            <xsl:when test="$sColor='limegreen'">32CD32</xsl:when>
            <xsl:when test="$sColor='Linen'">FAF0E6</xsl:when>
            <xsl:when test="$sColor='linen'">FAF0E6</xsl:when>
            <xsl:when test="$sColor='Magenta'">FF00FF</xsl:when>
            <xsl:when test="$sColor='magenta'">FF00FF</xsl:when>
            <xsl:when test="$sColor='Maroon'">800000</xsl:when>
            <xsl:when test="$sColor='maroon'">800000</xsl:when>
            <xsl:when test="$sColor='MediumAquaMarine'">66CDAA</xsl:when>
            <xsl:when test="$sColor='mediumaquamarine'">66CDAA</xsl:when>
            <xsl:when test="$sColor='MediumBlue'">0000CD</xsl:when>
            <xsl:when test="$sColor='mediumblue'">0000CD</xsl:when>
            <xsl:when test="$sColor='MediumOrchid'">BA55D3</xsl:when>
            <xsl:when test="$sColor='mediumorchid'">BA55D3</xsl:when>
            <xsl:when test="$sColor='MediumPurple'">9370D8</xsl:when>
            <xsl:when test="$sColor='mediumpurple'">9370D8</xsl:when>
            <xsl:when test="$sColor='MediumSeaGreen'">3CB371</xsl:when>
            <xsl:when test="$sColor='mediumseagreen'">3CB371</xsl:when>
            <xsl:when test="$sColor='MediumSlateBlue'">7B68EE</xsl:when>
            <xsl:when test="$sColor='mediumslateblue'">7B68EE</xsl:when>
            <xsl:when test="$sColor='MediumSpringGreen'">00FA9A</xsl:when>
            <xsl:when test="$sColor='mediumspringgreen'">00FA9A</xsl:when>
            <xsl:when test="$sColor='MediumTurquoise'">48D1CC</xsl:when>
            <xsl:when test="$sColor='mediumturquoise'">48D1CC</xsl:when>
            <xsl:when test="$sColor='MediumVioletRed'">C71585</xsl:when>
            <xsl:when test="$sColor='mediumvioletred'">C71585</xsl:when>
            <xsl:when test="$sColor='MidnightBlue'">191970</xsl:when>
            <xsl:when test="$sColor='midnightblue'">191970</xsl:when>
            <xsl:when test="$sColor='MintCream'">F5FFFA</xsl:when>
            <xsl:when test="$sColor='mintcream'">F5FFFA</xsl:when>
            <xsl:when test="$sColor='MistyRose'">FFE4E1</xsl:when>
            <xsl:when test="$sColor='mistyrose'">FFE4E1</xsl:when>
            <xsl:when test="$sColor='Moccasin'">FFE4B5</xsl:when>
            <xsl:when test="$sColor='moccasin'">FFE4B5</xsl:when>
            <xsl:when test="$sColor='NavajoWhite'">FFDEAD</xsl:when>
            <xsl:when test="$sColor='navajowhite'">FFDEAD</xsl:when>
            <xsl:when test="$sColor='Navy'">000080</xsl:when>
            <xsl:when test="$sColor='navy'">000080</xsl:when>
            <xsl:when test="$sColor='OldLace'">FDF5E6</xsl:when>
            <xsl:when test="$sColor='oldlace'">FDF5E6</xsl:when>
            <xsl:when test="$sColor='Olive'">808000</xsl:when>
            <xsl:when test="$sColor='olive'">808000</xsl:when>
            <xsl:when test="$sColor='OliveDrab'">6B8E23</xsl:when>
            <xsl:when test="$sColor='olivedrab'">6B8E23</xsl:when>
            <xsl:when test="$sColor='Orange'">FFA500</xsl:when>
            <xsl:when test="$sColor='orange'">FFA500</xsl:when>
            <xsl:when test="$sColor='OrangeRed'">FF4500</xsl:when>
            <xsl:when test="$sColor='orangered'">FF4500</xsl:when>
            <xsl:when test="$sColor='Orchid'">DA70D6</xsl:when>
            <xsl:when test="$sColor='orchid'">DA70D6</xsl:when>
            <xsl:when test="$sColor='PaleGoldenRod'">EEE8AA</xsl:when>
            <xsl:when test="$sColor='palegoldenrod'">EEE8AA</xsl:when>
            <xsl:when test="$sColor='PaleGreen'">98FB98</xsl:when>
            <xsl:when test="$sColor='palegreen'">98FB98</xsl:when>
            <xsl:when test="$sColor='PaleTurquoise'">AFEEEE</xsl:when>
            <xsl:when test="$sColor='paleturquoise'">AFEEEE</xsl:when>
            <xsl:when test="$sColor='PaleVioletRed'">D87093</xsl:when>
            <xsl:when test="$sColor='palevioletred'">D87093</xsl:when>
            <xsl:when test="$sColor='PapayaWhip'">FFEFD5</xsl:when>
            <xsl:when test="$sColor='papayawhip'">FFEFD5</xsl:when>
            <xsl:when test="$sColor='PeachPuff'">FFDAB9</xsl:when>
            <xsl:when test="$sColor='peachpuff'">FFDAB9</xsl:when>
            <xsl:when test="$sColor='Peru'">CD853F</xsl:when>
            <xsl:when test="$sColor='peru'">CD853F</xsl:when>
            <xsl:when test="$sColor='Pink'">FFC0CB</xsl:when>
            <xsl:when test="$sColor='pink'">FFC0CB</xsl:when>
            <xsl:when test="$sColor='Plum'">DDA0DD</xsl:when>
            <xsl:when test="$sColor='plum'">DDA0DD</xsl:when>
            <xsl:when test="$sColor='PowderBlue'">B0E0E6</xsl:when>
            <xsl:when test="$sColor='powderblue'">B0E0E6</xsl:when>
            <xsl:when test="$sColor='Purple'">800080</xsl:when>
            <xsl:when test="$sColor='purple'">800080</xsl:when>
            <xsl:when test="$sColor='Red'">FF0000</xsl:when>
            <xsl:when test="$sColor='red'">FF0000</xsl:when>
            <xsl:when test="$sColor='RosyBrown'">BC8F8F</xsl:when>
            <xsl:when test="$sColor='rosybrown'">BC8F8F</xsl:when>
            <xsl:when test="$sColor='RoyalBlue'">4169E1</xsl:when>
            <xsl:when test="$sColor='royalblue'">4169E1</xsl:when>
            <xsl:when test="$sColor='SaddleBrown'">8B4513</xsl:when>
            <xsl:when test="$sColor='saddlebrown'">8B4513</xsl:when>
            <xsl:when test="$sColor='Salmon'">FA8072</xsl:when>
            <xsl:when test="$sColor='salmon'">FA8072</xsl:when>
            <xsl:when test="$sColor='SandyBrown'">F4A460</xsl:when>
            <xsl:when test="$sColor='sandybrown'">F4A460</xsl:when>
            <xsl:when test="$sColor='SeaGreen'">2E8B57</xsl:when>
            <xsl:when test="$sColor='seagreen'">2E8B57</xsl:when>
            <xsl:when test="$sColor='SeaShell'">FFF5EE</xsl:when>
            <xsl:when test="$sColor='seashell'">FFF5EE</xsl:when>
            <xsl:when test="$sColor='Sienna'">A0522D</xsl:when>
            <xsl:when test="$sColor='sienna'">A0522D</xsl:when>
            <xsl:when test="$sColor='Silver'">C0C0C0</xsl:when>
            <xsl:when test="$sColor='silver'">C0C0C0</xsl:when>
            <xsl:when test="$sColor='SkyBlue'">87CEEB</xsl:when>
            <xsl:when test="$sColor='skyblue'">87CEEB</xsl:when>
            <xsl:when test="$sColor='SlateBlue'">6A5ACD</xsl:when>
            <xsl:when test="$sColor='slateblue'">6A5ACD</xsl:when>
            <xsl:when test="$sColor='SlateGray'">708090</xsl:when>
            <xsl:when test="$sColor='slategray'">708090</xsl:when>
            <xsl:when test="$sColor='Snow'">FFFAFA</xsl:when>
            <xsl:when test="$sColor='snow'">FFFAFA</xsl:when>
            <xsl:when test="$sColor='SpringGreen'">00FF7F</xsl:when>
            <xsl:when test="$sColor='springgreen'">00FF7F</xsl:when>
            <xsl:when test="$sColor='SteelBlue'">4682B4</xsl:when>
            <xsl:when test="$sColor='steelblue'">4682B4</xsl:when>
            <xsl:when test="$sColor='Tan'">D2B48C</xsl:when>
            <xsl:when test="$sColor='tan'">D2B48C</xsl:when>
            <xsl:when test="$sColor='Teal'">008080</xsl:when>
            <xsl:when test="$sColor='teal'">008080</xsl:when>
            <xsl:when test="$sColor='Thistle'">D8BFD8</xsl:when>
            <xsl:when test="$sColor='thistle'">D8BFD8</xsl:when>
            <xsl:when test="$sColor='Tomato'">FF6347</xsl:when>
            <xsl:when test="$sColor='tomato'">FF6347</xsl:when>
            <xsl:when test="$sColor='Turquoise'">40E0D0</xsl:when>
            <xsl:when test="$sColor='turquoise'">40E0D0</xsl:when>
            <xsl:when test="$sColor='Violet'">EE82EE</xsl:when>
            <xsl:when test="$sColor='violet'">EE82EE</xsl:when>
            <xsl:when test="$sColor='Wheat'">F5DEB3</xsl:when>
            <xsl:when test="$sColor='wheat'">F5DEB3</xsl:when>
            <xsl:when test="$sColor='White'">FFFFFF</xsl:when>
            <xsl:when test="$sColor='white'">FFFFFF</xsl:when>
            <xsl:when test="$sColor='WhiteSmoke'">F5F5F5</xsl:when>
            <xsl:when test="$sColor='whitesmoke'">F5F5F5</xsl:when>
            <xsl:when test="$sColor='Yellow'">FFFF00</xsl:when>
            <xsl:when test="$sColor='yellow'">FFFF00</xsl:when>
            <xsl:when test="$sColor='YellowGreen'">9ACD32</xsl:when>
            <xsl:when test="$sColor='yellowgreen'">9ACD32</xsl:when>
            <xsl:otherwise>
                <!-- skip the initial # -->
                <xsl:value-of select="substring($sColor, 2)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      GetFontSize
   -->
    <xsl:template name="HandleFontSize">
        <xsl:param name="sSize"/>
        <xsl:param name="language"/>
        <xsl:choose>
            <!-- percentage -->
            <xsl:when test="contains($sSize, '%')">
                <xsl:choose>
                    <xsl:when test="starts-with($sSize, '100')">
                        <!-- do nothing; leave it -->
                    </xsl:when>
                    <xsl:otherwise>
                        <tex:cmd name="fontspec">
                            <tex:opt>
                                <xsl:text>Scale=</xsl:text>
                                <xsl:value-of select="number(substring-before($sSize,'%')) div 100"/>
                            </tex:opt>
                            <tex:parm>
                                <xsl:variable name="sFontFamily" select="normalize-space($language/@font-family)"/>
                                <xsl:choose>
                                    <xsl:when test="string-length($sFontFamily) &gt; 0">
                                        <xsl:value-of select="$sFontFamily"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$sDefaultFontFamily"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </tex:parm>
                        </tex:cmd>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- relative sizes -->
            <xsl:when test="$sSize='smaller'">
                <tex:cmd name="small" gr="0"/>
            </xsl:when>
            <xsl:when test="$sSize='larger'">
                <tex:cmd name="large" gr="0"/>
            </xsl:when>
            <!-- key term absolute values -->
            <xsl:when test="$sSize='large'">
                <tex:cmd name="large" gr="0"/>
            </xsl:when>
            <xsl:when test="$sSize='medium'">
                <tex:cmd name="normalsize" gr="0"/>
            </xsl:when>
            <xsl:when test="$sSize='small'">
                <tex:cmd name="small" gr="0"/>
            </xsl:when>
            <xsl:when test="$sSize='x-large'">
                <tex:cmd name="Large" gr="0"/>
            </xsl:when>
            <xsl:when test="$sSize='xx-large'">
                <tex:cmd name="LARGE" gr="0"/>
            </xsl:when>
            <xsl:when test="$sSize='x-small'">
                <tex:cmd name="footnotesize" gr="0"/>
            </xsl:when>
            <xsl:when test="$sSize='xx-small'">
                <tex:cmd name="scriptsize" gr="0"/>
            </xsl:when>
            <!-- assume is a number and probably in points -->
            <xsl:otherwise>
                <xsl:variable name="sSizeOnly" select="substring-before($sSize, 'pt')"/>
                <tex:cmd name="fontsize">
                    <tex:parm>
                        <xsl:value-of select="$sSizeOnly"/>
                    </tex:parm>
                    <tex:parm>
                        <xsl:value-of select="number($sSizeOnly) * 1.2"/>
                    </tex:parm>
                </tex:cmd>
                <tex:cmd name="selectfont" gr="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      GetFreeParboxWidth
   -->
    <xsl:template name="GetFreeParboxWidth">
        <!-- start with the text width and subtract the block quote indent at each end -->
        <tex:spec cat="esc"/>
        <xsl:text>textwidth - </xsl:text>
        <xsl:value-of select="$sBlockQuoteIndent"/>
        <xsl:text> - </xsl:text>
        <xsl:value-of select="$sBlockQuoteIndent"/>
        <!-- subtract the width of the number -->
        <xsl:text> - </xsl:text>
        <xsl:value-of select="$iNumberWidth"/>
        <xsl:text>em</xsl:text>
        <!-- if it is a listInterlinear, figure out how much to subtract for the letter -->
        <xsl:variable name="parentListInterlinear" select="ancestor::listInterlinear[last()]"/>
        <xsl:for-each select="$parentListInterlinear">
            <xsl:text> - </xsl:text>
            <xsl:call-template name="GetLetterWidth">
                <xsl:with-param name="iLetterCount" select="count(../listInterlinear)"/>
            </xsl:call-template>
            <xsl:text>em</xsl:text>
            <!-- there's an additional 2.5pt in a list interlinear so account for it, too -->
            <xsl:text>-2.5pt</xsl:text>
        </xsl:for-each>
        <!-- if it is embedded, make a further adjustment -->
        <xsl:variable name="parent" select=".."/>
        <xsl:variable name="iParentPosition">
            <xsl:for-each select="../../*">
                <xsl:if test=".=$parent">
                    <xsl:value-of select="position()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="sCurrentLanguage" select="@lang"/>
        <xsl:if test="preceding-sibling::free[@lang=$sCurrentLanguage][position()=1] or preceding-sibling::free[not(@lang)][position()=1] or name(../..)='interlinear' or name(../..)='listInterlinear' and name(..)='interlinear' and $iParentPosition!=1">
            <xsl:text> - 6pt</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--  
      GetLetterWidth
   -->
    <xsl:template name="GetLetterWidth">
        <xsl:param name="iLetterCount"/>
        <xsl:choose>
            <xsl:when test="$iLetterCount &lt; 27">1.5</xsl:when>
            <xsl:when test="$iLetterCount &lt; 53">2.5</xsl:when>
            <xsl:otherwise>3</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      GetMeasure
   -->
    <xsl:template name="GetMeasure">
        <xsl:param name="sValue"/>
        <xsl:value-of select="number(substring($sValue,1,string-length($sValue) - 2))"/>
    </xsl:template>
    <!--  
      GetTeXSpecialCommand
   -->
    <xsl:template name="GetTeXSpecialCommand">
        <xsl:param name="sAttr"/>
        <xsl:param name="sDefaultValue"/>
        <xsl:variable name="sCommandBeginning" select="substring-after(@TeXSpecial, $sAttr)"/>
        <xsl:variable name="sCommand" select="substring-before(substring($sCommandBeginning,2),$sSingleQuote)"/>
        <xsl:choose>
            <xsl:when test="string-length(normalize-space($sCommand)) &gt; 0">
                <xsl:value-of select="$sCommand"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$sDefaultValue"/>
                <!--            <xsl:value-of select="$sDefaultValue"/>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      GetUnitOfMeasure
   -->
    <xsl:template name="GetUnitOfMeasure">
        <xsl:param name="sValue"/>
        <xsl:value-of select="substring($sValue, string-length($sValue)-1)"/>
    </xsl:template>
    <!--  
      HandleSmallCapsBegin
   -->
    <xsl:template name="HandleSmallCapsBegin">
        <!-- HACK: "real" typesetting systems require a custom small caps font -->
        <!-- Use font-size:smaller and do a text-transform to uppercase -->
        <!--      <tex:cmd name="small" gr="0"/>-->
        <tex:spec cat="bg"/>
        <tex:cmd name="MakeUppercase" gr="0"/>
        <tex:spec cat="bg"/>
    </xsl:template>
    <!--  
      HandleSmallCapsEnd
   -->
    <xsl:template name="HandleSmallCapsEnd">
        <xsl:call-template name="HandleSmallCapsEndDoNestedTypes">
            <xsl:with-param name="sList" select="@types"/>
        </xsl:call-template>
        <xsl:if test="normalize-space(@font-variant)='small-caps'">
            <tex:spec cat="eg"/>
        </xsl:if>
    </xsl:template>
    <!--  
      HandleSmallCapsEndDoNestedTypes
   -->
    <xsl:template name="HandleSmallCapsEndDoNestedTypes">
        <xsl:param name="sList"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:if test="string-length($sFirst) &gt; 0">
            <xsl:for-each select="key('TypeID',$sFirst)">
                <xsl:call-template name="HandleSmallCapsEnd"/>
            </xsl:for-each>
            <xsl:if test="$sRest">
                <xsl:call-template name="HandleSmallCapsEndDoNestedTypes">
                    <xsl:with-param name="sList" select="$sRest"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--
      HandleTeXSpecialCommand
   -->
    <xsl:template name="HandleTeXSpecialCommand">
        <xsl:param name="sPattern"/>
        <xsl:param name="default"/>
        <xsl:choose>
            <xsl:when test="contains(@TeXSpecial,$sPattern)">
                <xsl:variable name="sValue">
                    <xsl:call-template name="GetTeXSpecialCommand">
                        <xsl:with-param name="sAttr" select="$sPattern"/>
                        <xsl:with-param name="sDefaultValue" select="$default"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:copy-of select="$sValue"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$default"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      OutputAbbreviationsInCommaSeparatedList
   -->
    <xsl:template name="OutputAbbreviationsInCommaSeparatedList">
        <xsl:for-each select="//abbreviation[//abbrRef/@abbr=@id]">
            <xsl:call-template name="DoInternalTargetBegin">
                <xsl:with-param name="sName" select="@id"/>
            </xsl:call-template>
            <!--         <fo:inline id="{@id}">-->
            <xsl:call-template name="OutputAbbrTerm">
                <xsl:with-param name="abbr" select="."/>
            </xsl:call-template>
            <xsl:text> = </xsl:text>
            <xsl:call-template name="OutputAbbrDefinition">
                <xsl:with-param name="abbr" select="."/>
            </xsl:call-template>
            <xsl:call-template name="DoInternalTargetEnd"/>
            <!--         </fo:inline>-->
            <xsl:choose>
                <xsl:when test="position() = last()">
                    <xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>, </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--
      OutputAbbreviationsInTable
   -->
    <xsl:template name="OutputAbbreviationsInTable">
        <tex:env name="tabular">
            <tex:opt>t</tex:opt>
            <tex:parm>
                <xsl:text>@</xsl:text>
                <tex:group>
                    <tex:cmd name="hspace*">
                        <tex:parm>
                            <tex:cmd name="parindent" gr="0" nl2="0"/>
                        </tex:parm>
                    </tex:cmd>
                </tex:group>
                <xsl:text>lcl</xsl:text>
            </tex:parm>
            <xsl:variable name="abbrsUsed" select="//abbreviation[//abbrRef/@abbr=@id]"/>
            <!--  I'm not happy with how this poor man's attempt at getting double column works when there are long definitions.
                       The table column widths may be long and short; if a cell in the second row needs to lap over a line, then the
                       corresponding cell in the other column may skip a row (as far as what one would expect).
                       So I'm going with just a single table here.
               <xsl:variable name="iHalfwayPoint" select="ceiling(count($abbrsUsed) div 2)"/>
               <xsl:for-each select="$abbrsUsed[position() &lt;= $iHalfwayPoint]">
               -->
            <xsl:for-each select="$abbrsUsed">
                <!--  Need to do something here... 
                  <xsl:if test="position() = last() -1 or position() = 1">
                        <xsl:attribute name="keep-with-next.within-page">1</xsl:attribute>
                     </xsl:if>
-->
                <xsl:call-template name="DoInternalTargetBegin">
                    <xsl:with-param name="sName" select="@id"/>
                </xsl:call-template>
                <xsl:call-template name="OutputAbbrTerm">
                    <xsl:with-param name="abbr" select="."/>
                </xsl:call-template>
                <xsl:call-template name="DoInternalTargetEnd"/>
                <tex:spec cat="align"/>
                <xsl:text> = </xsl:text>
                <tex:spec cat="align"/>
                <xsl:call-template name="OutputAbbrDefinition">
                    <xsl:with-param name="abbr" select="."/>
                </xsl:call-template>
                <tex:spec cat="esc"/>
                <tex:spec cat="esc" nl2="1"/>
            </xsl:for-each>
        </tex:env>
    </xsl:template>
    <!--
      OKToBreakHere
   -->
    <xsl:template name="OKToBreakHere">
        <tex:cmd name="needspace" nl2="1">
            <tex:parm>
                <xsl:text>5</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>baselineskip</xsl:text>
            </tex:parm>
        </tex:cmd>
        <tex:spec cat="esc" nl1="1" nl2="1"/>
        <xsl:text>penalty-3000</xsl:text>
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
        <tex:group>
            <xsl:if test="//abbreviations/@usesmallcaps='yes'">
                <tex:cmd name="fontspec">
                    <tex:opt>Scale=0.65</tex:opt>
                    <tex:parm>
                        <xsl:value-of select="$sDefaultFontFamily"/>
                    </tex:parm>
                </tex:cmd>
                <xsl:call-template name="HandleSmallCapsBegin"/>
            </xsl:if>
            <xsl:value-of select="$sAbbrTerm"/>
            <xsl:if test="//abbreviations/@usesmallcaps='yes'">
                <tex:spec cat="eg"/>
                <tex:spec cat="eg"/>
            </xsl:if>
        </tex:group>
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
      OutputAnyTextBeforeSectionRef
   -->
    <xsl:template name="OutputAnyTextBeforeSectionRef">
        <!-- output any canned text before the section reference -->
        <xsl:variable name="lingPaper" select="//lingPaper"/>
        <xsl:variable name="ssection" select="'section'"/>
        <xsl:variable name="ssections" select="'sections'"/>
        <xsl:variable name="sSection" select="'Section'"/>
        <xsl:variable name="sSections" select="'Sections'"/>
        <xsl:choose>
            <xsl:when test="@textBefore='useDefault'">
                <xsl:choose>
                    <xsl:when test="$lingPaper/@sectionRefDefault='none'">
                        <!-- do nothing -->
                    </xsl:when>
                    <xsl:when test="$lingPaper/@sectionRefDefault='singular'">
                        <xsl:call-template name="DoSectionRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefSingularLabel"/>
                            <xsl:with-param name="sDefault" select="$ssection"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@sectionRefDefault='capitalizedSingular'">
                        <xsl:call-template name="DoSectionRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedSingularLabel"/>
                            <xsl:with-param name="sDefault" select="$sSection"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@sectionRefDefault='plural'">
                        <xsl:call-template name="DoSectionRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$ssections"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$lingPaper/@sectionRefDefault='capitalizedPlural'">
                        <xsl:call-template name="DoSectionRefLabel">
                            <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedPluralLabel"/>
                            <xsl:with-param name="sDefault" select="$sSections"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@textBefore='singular'">
                <xsl:call-template name="DoSectionRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$ssection"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedSingular'">
                <xsl:call-template name="DoSectionRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedSingularLabel"/>
                    <xsl:with-param name="sDefault" select="$sSection"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='plural'">
                <xsl:call-template name="DoSectionRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$ssections"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedPlural'">
                <xsl:call-template name="DoSectionRefLabel">
                    <xsl:with-param name="sLabel" select="$lingPaper/@sectionRefCapitalizedPluralLabel"/>
                    <xsl:with-param name="sDefault" select="$sSections"/>
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
        <xsl:param name="bIsARow" select="'N'"/>
        <xsl:if test="string-length(@backgroundcolor) &gt; 0">
            <xsl:variable name="sKind">
                <xsl:choose>
                    <xsl:when test="$bIsARow='Y'">
                        <xsl:text>rowcolor</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>columncolor</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$bIsARow='N'">
                <tex:spec cat="gt"/>
                <tex:spec cat="bg"/>
            </xsl:if>
            <tex:cmd name="{$sKind}">
                <tex:opt>rgb</tex:opt>
                <tex:parm>
                    <xsl:call-template name="GetColorDecimalCodesFromHexCode">
                        <xsl:with-param name="sColorHexCode">
                            <xsl:call-template name="GetColorHexCode">
                                <xsl:with-param name="sColor" select="@backgroundcolor"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </tex:parm>
            </tex:cmd>
            <xsl:if test="$bIsARow='N'">
                <tex:spec cat="eg"/>
            </xsl:if>
        </xsl:if>
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
        <fo:static-content flow-name="ChapterFirstPage-after" display-align="after">
            <xsl:element name="fo:block" use-attribute-sets="HeaderFooterFontInfo">
                <xsl:attribute name="text-align">center</xsl:attribute>
                <xsl:attribute name="margin-top">6pt</xsl:attribute>
                <fo:page-number/>
            </xsl:element>
        </fo:static-content>
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
        <xsl:if test="string-length($sFirst) &gt; 0">
            <xsl:choose>
                <xsl:when test="$sFirst='superscript'">
                    <tex:spec cat="esc"/>
                    <xsl:text>textsuperscript</xsl:text>
                    <tex:spec cat="bg"/>
                </xsl:when>
                <xsl:when test="$sFirst='subscript'">
                    <tex:spec cat="esc"/>
                    <xsl:text>textsubscript</xsl:text>
                    <tex:spec cat="bg"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="$sRest">
                <xsl:call-template name="OutputTypeAttributes">
                    <xsl:with-param name="sList" select="$sRest"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
      OutputTypeAttributesEnd
   -->
    <xsl:template name="OutputTypeAttributesEnd">
        <xsl:param name="sList"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:if test="string-length($sFirst) &gt; 0">
            <xsl:choose>
                <xsl:when test="$sFirst='superscript'">
                    <tex:spec cat="eg"/>
                </xsl:when>
                <xsl:when test="$sFirst='subscript'">
                    <tex:spec cat="eg"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="$sRest">
                <xsl:call-template name="OutputTypeAttributesEnd">
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
            <xsl:call-template name="ExampleNumber"/>
        </xsl:element>
    </xsl:template>
    <!--  
                  OutputFontAttributes
-->
    <xsl:template name="OutputFontAttributes">
        <xsl:param name="language"/>
        <!-- unsuccessful attempt at dealing with "normal" to override inherited values 
         <xsl:param name="bCloseOffParent" select="'Y'"/>
      <xsl:if test="$bCloseOffParent='Y'">
         <xsl:variable name="myParent" select="parent::langData"/>
         <xsl:if test="$myParent">
            <xsl:call-template name="OutputFontAttributesEnd">
               <xsl:with-param name="language" select="key('LanguageID',$myParent/@lang)"/>
               <xsl:with-param name="bStartParent" select="'N'"/>
            </xsl:call-template>
         </xsl:if>
      </xsl:if>
      -->
        <xsl:variable name="sFontFamily" select="normalize-space($language/@font-family)"/>
        <xsl:if test="string-length($sFontFamily) &gt; 0">
            <tex:spec cat="esc"/>
            <xsl:text>Lang</xsl:text>
            <xsl:value-of select="$language/@id"/>
            <xsl:text>FontFamily</xsl:text>
            <tex:spec cat="bg"/>
        </xsl:if>
        <xsl:variable name="sFontSize" select="normalize-space($language/@font-size)"/>
        <xsl:if test="string-length($sFontSize) &gt; 0">
            <xsl:call-template name="HandleFontSize">
                <xsl:with-param name="sSize" select="$sFontSize"/>
                <xsl:with-param name="language" select="$language"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="sFontStyle" select="normalize-space($language/@font-style)"/>
        <xsl:if test="string-length($sFontStyle) &gt; 0">
            <xsl:choose>
                <xsl:when test="$sFontStyle='italic'">
                    <tex:spec cat="esc"/>
                    <xsl:text>textit</xsl:text>
                    <tex:spec cat="bg"/>
                </xsl:when>
                <xsl:when test="$sFontStyle='normal'">
                    <tex:spec cat="esc"/>
                    <xsl:text>textup</xsl:text>
                    <tex:spec cat="bg"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- use italic as default -->
                    <tex:spec cat="esc"/>
                    <xsl:text>textit</xsl:text>
                    <tex:spec cat="bg"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:variable name="sFontVariant" select="normalize-space($language/@font-variant)"/>
        <xsl:if test="string-length($sFontVariant) &gt; 0">
            <xsl:choose>
                <xsl:when test="$sFontVariant='small-caps'">
                    <xsl:call-template name="HandleSmallCapsBegin"/>
                </xsl:when>
                <xsl:when test="$sFontStyle='italic'">
                    <!-- do nothing; we do not want to turn off the italic by using a normal -->
                </xsl:when>
                <xsl:when test="$sFontStyle='normal'">
                    <tex:spec cat="esc"/>
                    <xsl:text>textup</xsl:text>
                    <tex:spec cat="bg"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- only allow small caps -->
                    <!-- following does more than use normal - it also uses the main font
               <tex:spec cat="esc"/>
               <xsl:text>textnormal</xsl:text>
               <tex:spec cat="bg"/> -->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:variable name="sFontWeight" select="normalize-space($language/@font-weight)"/>
        <xsl:if test="string-length($sFontWeight) &gt; 0">
            <xsl:choose>
                <xsl:when test="$sFontWeight='bold'">
                    <tex:spec cat="esc"/>
                    <xsl:text>textbf</xsl:text>
                    <tex:spec cat="bg"/>
                </xsl:when>
                <xsl:when test="$sFontStyle='italic'">
                    <!-- do nothing - we do *not* want to do a 'normal' or we'll cancel the italic -->
                </xsl:when>
                <xsl:when test="$sFontWeight='normal'">
                    <tex:spec cat="esc"/>
                    <xsl:text>textmd</xsl:text>
                    <tex:spec cat="bg"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- use bold as default -->
                    <tex:spec cat="esc"/>
                    <xsl:text>textbf</xsl:text>
                    <tex:spec cat="bg"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:variable name="sFontColor" select="normalize-space($language/@color)"/>
        <xsl:if test="string-length($sFontColor) &gt; 0">
            <tex:spec cat="esc"/>
            <xsl:text>textcolor[rgb]</xsl:text>
            <tex:spec cat="bg"/>
            <xsl:call-template name="GetColorDecimalCodesFromHexCode">
                <xsl:with-param name="sColorHexCode">
                    <xsl:call-template name="GetColorHexCode">
                        <xsl:with-param name="sColor" select="$sFontColor"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
            <tex:spec cat="eg"/>
            <tex:spec cat="bg"/>
            <!-- 
         <tex:cmd name="addfontfeature">
            <tex:parm>
               <xsl:text>Color=</xsl:text>
               <xsl:call-template name="GetColorHexCode">
                  <xsl:with-param name="sColor" select="$sFontColor"/>
               </xsl:call-template>
            </tex:parm>
         </tex:cmd>
         -->
        </xsl:if>
        <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="$language/@TeXSpecial"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
      OutputFontAttributesEnd
   -->
    <xsl:template name="OutputFontAttributesEnd">
        <xsl:param name="language"/>
        <!-- unsuccessful attempt at dealing with "normal" to override inherited values 
         <xsl:param name="bStartParent" select="'Y'"/>
         -->
        <xsl:call-template name="OutputTypeAttributesEnd">
            <xsl:with-param name="sList" select="$language/@TeXSpecial"/>
        </xsl:call-template>
        <xsl:variable name="sFontFamily" select="normalize-space($language/@font-family)"/>
        <xsl:if test="string-length($sFontFamily) &gt; 0">
            <tex:spec cat="eg"/>
        </xsl:if>
        <!-- font size does not end with an open brace 
      <xsl:variable name="sFontSize" select="normalize-space($language/@font-size)"/>
      <xsl:if test="string-length($sFontSize) &gt; 0">
         <tex:spec cat="eg"/>
      </xsl:if>
      -->
        <xsl:variable name="sFontStyle" select="normalize-space($language/@font-style)"/>
        <xsl:if test="string-length($sFontStyle) &gt; 0">
            <xsl:if test="$sFontStyle='italic' or $sFontStyle='normal'">
                <tex:spec cat="eg"/>
            </xsl:if>
        </xsl:if>
        <xsl:variable name="sFontVariant" select="normalize-space($language/@font-variant)"/>
        <xsl:if test="string-length($sFontVariant) &gt; 0">
            <xsl:choose>
                <xsl:when test="$sFontVariant='small-caps'">
                    <xsl:call-template name="HandleSmallCapsEnd"/>
                </xsl:when>
                <xsl:when test="$sFontStyle='italic'">
                    <!-- do nothing; we do not want to turn off the italic by using a normal -->
                </xsl:when>
                <xsl:when test="$sFontStyle='normal'">
                    <tex:spec cat="eg"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- doing nothing currenlty -->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:variable name="sFontWeight" select="normalize-space($language/@font-weight)"/>
        <xsl:if test="string-length($sFontWeight) &gt; 0">
            <xsl:choose>
                <xsl:when test="$sFontStyle='italic' and $sFontWeight!='bold'">
                    <!-- do nothing - we do *not* want to do a 'normal' or we'll cancel the italic -->
                </xsl:when>
                <xsl:when test="$sFontWeight='normal'">
                    <tex:spec cat="eg"/>
                </xsl:when>
                <xsl:otherwise>
                    <tex:spec cat="eg"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:variable name="sFontColor" select="normalize-space($language/@color)"/>
        <xsl:if test="string-length($sFontColor) &gt; 0">
            <tex:spec cat="eg"/>
        </xsl:if>
        <!-- unsuccessful attempt at dealing with "normal" to override inherited values 
         <xsl:if test="$bStartParent='Y'">
         <xsl:variable name="myParent" select="parent::langData"/>
         <xsl:if test="$myParent">
            <xsl:call-template name="OutputFontAttributes">
               <xsl:with-param name="language" select="key('LanguageID',$myParent/@lang)"/>
               <xsl:with-param name="bCloseOffParent" select="'N'"/>
            </xsl:call-template>
         </xsl:if>
      </xsl:if>
      -->
    </xsl:template>
    <!--  
                  OutputFrontOrBackMatterTitle
-->
    <xsl:template name="OutputFrontOrBackMatterTitle">
        <xsl:param name="id"/>
        <xsl:param name="sTitle"/>
        <xsl:param name="titlePart2"/>
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
                <xsl:choose>
                    <xsl:when test="$bForcePageBreak='Y'">
                        <tex:cmd name="pagebreak" gr="0" nl2="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <tex:cmd name="vspace" nl1="1" nl2="1">
                            <tex:parm><xsl:value-of select="$sBasicPointSize"/>pt</tex:parm>
                        </tex:cmd>
                        <xsl:call-template name="OKToBreakHere"/>
                    </xsl:otherwise>
                </xsl:choose>
                <tex:group nl1="1" nl2="1">
                    <tex:cmd name="centerline" nl2="1">
                        <tex:parm>
                            <xsl:call-template name="DoInternalTargetBegin">
                                <xsl:with-param name="sName" select="$id"/>
                            </xsl:call-template>
                            <tex:cmd name="large">
                                <tex:parm>
                                    <tex:cmd name="textbf">
                                        <tex:parm>
                                            <xsl:call-template name="DoType">
                                                <xsl:with-param name="type" select="@type"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="$sTitle"/>
                                            <xsl:if test="$titlePart2">
                                                <xsl:apply-templates select="$titlePart2"/>
                                            </xsl:if>
                                            <xsl:call-template name="DoTypeEnd"/>
                                        </tex:parm>
                                    </tex:cmd>
                                </tex:parm>
                            </tex:cmd>
                            <xsl:call-template name="DoInternalTargetEnd"/>
                        </tex:parm>
                    </tex:cmd>
                    <tex:cmd name="markright" nl2="1">
                        <tex:parm>
                            <xsl:call-template name="DoSecTitleRunningHeader"/>
                        </tex:parm>
                    </tex:cmd>
                    <tex:cmd name="pdfbookmark" nl1="1" nl2="1">
                        <tex:opt>
                            <xsl:text>1</xsl:text>
                        </tex:opt>
                        <tex:parm>
                            <xsl:value-of select="$sTitle"/>
                            <xsl:if test="$titlePart2">
                                <xsl:value-of select="$titlePart2"/>
                            </xsl:if>
                        </tex:parm>
                        <tex:parm>
                            <xsl:value-of select="$id"/>
                        </tex:parm>
                    </tex:cmd>
                    <xsl:call-template name="CreateAddToContents">
                        <xsl:with-param name="id" select="$id"/>
                    </xsl:call-template>
                </tex:group>
                <tex:cmd name="par"/>
                <xsl:call-template name="DoNotBreakHere"/>
                <tex:cmd name="vspace" nl1="1" nl2="1">
                    <tex:parm><xsl:value-of select="$sBasicPointSize"/>pt</tex:parm>
                </tex:cmd>
            </xsl:otherwise>
        </xsl:choose>
        <!-- 
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
   -->
    </xsl:template>
    <!--
                   OutputGlossaryLabel
-->
    <xsl:template name="OutputGlossaryLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Glossary</xsl:with-param>
            <xsl:with-param name="pLabel" select="@label"/>
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
                    <xsl:sort select="term[1]"/>
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
                                    <xsl:choose>
                                        <xsl:when test="$indexedItems">
                                            <xsl:text>.  See also </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>See </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <fo:inline>
                                        <fo:basic-link>
                                            <xsl:attribute name="internal-destination">
                                                <xsl:call-template name="CreateIndexTermID">
                                                    <xsl:with-param name="sTermId" select="@see"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:call-template name="AddAnyLinkAttributes"/>
                                            <xsl:apply-templates select="key('IndexTermID',@see)/term[1]" mode="InIndex"/>
                                        </fo:basic-link>
                                    </fo:inline>
                                    <xsl:text>.</xsl:text>
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
                                <xsl:apply-templates select="term[1]" mode="InIndex"/>
                                <xsl:text>&#x20;&#x20;See </xsl:text>
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
                  OutputIndexTermsTerm
-->
    <xsl:template name="OutputIndexTermsTerm">
        <xsl:param name="lang"/>
        <xsl:param name="indexTerm"/>
        <xsl:choose>
            <xsl:when test="$lang and $indexTerm/term[@lang=$lang]">
                <xsl:apply-templates select="$indexTerm/term[@lang=$lang]" mode="InIndex"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$indexTerm/term[1]" mode="InIndex"/>
            </xsl:otherwise>
        </xsl:choose>
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
      OutputInterlinearLineAsTableCells
   -->
    <xsl:template name="OutputInterlinearLineAsTableCells">
        <xsl:param name="sList"/>
        <xsl:param name="lang"/>
        <xsl:param name="sAlign"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <!--      <fo:table-cell text-align="{$sAlign}" xsl:use-attribute-sets="ExampleCell">-->
        <xsl:call-template name="DoDebugExamples"/>
        <!--         <fo:block>-->
        <tex:spec cat="align"/>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',$lang)"/>
        </xsl:call-template>
        <xsl:value-of select="$sFirst"/>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',$lang)"/>
        </xsl:call-template>
        <!--      <tex:spec cat="align"/>-->
        <!--         </fo:block>-->
        <!--      </fo:table-cell>-->
        <xsl:if test="$sRest">
            <xsl:call-template name="OutputInterlinearLineAsTableCells">
                <xsl:with-param name="sList" select="$sRest"/>
                <xsl:with-param name="lang" select="$lang"/>
                <xsl:with-param name="sAlign" select="$sAlign"/>
            </xsl:call-template>
        </xsl:if>
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
                    <!--               <fo:inline>-->
                    <tex:group>
                        <xsl:text disable-output-escaping="yes">&#xa0;&#xa0;</xsl:text>
                        <xsl:call-template name="OutputInterlinearTextReferenceContent">
                            <xsl:with-param name="sSource" select="$sSource"/>
                            <xsl:with-param name="sRef" select="$sRef"/>
                        </xsl:call-template>
                    </tex:group>
                    <!--               </fo:inline>-->
                </xsl:when>
                <xsl:otherwise>
                    <!--               <fo:block>-->
                    <tex:cmd name="hfil" gr="0" nl2="0"/>
                    <xsl:text disable-output-escaping="yes">&#xa0;&#xa0;</xsl:text>
                    <xsl:call-template name="OutputInterlinearTextReferenceContent">
                        <xsl:with-param name="sSource" select="$sSource"/>
                        <xsl:with-param name="sRef" select="$sRef"/>
                    </xsl:call-template>
                    <!--               </fo:block>-->
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
        <tex:cmd name="hfill" gr="0" nl2="0"/>
        <xsl:text>[</xsl:text>
        <xsl:choose>
            <xsl:when test="$sSource">
                <xsl:apply-templates select="$sSource" mode="contents"/>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($sRef)) &gt; 0">
                <tex:group>
                    <!--            <fo:inline>-->
                    <!--               <fo:basic-link>
                  <xsl:attribute name="internal-destination">
                     <xsl:value-of select="$sRef"/>
                  </xsl:attribute>-->
                    <xsl:call-template name="DoInternalHyperlinkBegin">
                        <xsl:with-param name="sName" select="$sRef"/>
                    </xsl:call-template>
                    <xsl:call-template name="AddAnyLinkAttributes"/>
                    <xsl:variable name="interlinear" select="key('InterlinearReferenceID',$sRef)"/>
                    <xsl:value-of select="$interlinear/../textInfo/shortTitle"/>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="count($interlinear/preceding-sibling::interlinear) + 1"/>
                    <xsl:call-template name="DoInternalTargetEnd"/>
                    <!--               </fo:basic-link>-->
                    <!--            </fo:inline>-->
                </tex:group>
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
        <xsl:variable name="sLetterWidth">
            <xsl:call-template name="GetLetterWidth">
                <xsl:with-param name="iLetterCount" select="count(parent::example/listWord | parent::example/listSingle | parent::example/listInterlinear)"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- 
      <fo:block>
         <fo:table space-before="0pt">
            <xsl:call-template name="DoDebugExamples"/>
            <fo:table-column column-number="1">
               <xsl:attribute name="column-width">
                  <xsl:value-of select="$sLetterWidth"/>em</xsl:attribute>
            </fo:table-column>
      
            <-  By not specifiying a width for the second column, it appears to use what is left over 
                        (which is what we want). -
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
                     <xsl:otherwise>
                        <xsl:call-template name="OutputWordOrSingle"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </fo:table-row>
               <xsl:for-each select="following-sibling::listWord | following-sibling::listSingle | following-sibling::listInterlinear">
                  <xsl:if test="name()='listInterlinear'">
                     <- output a fake row to add spacing between iterlinears -
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
                        <xsl:otherwise>
                           <xsl:call-template name="OutputWordOrSingle"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </fo:table-row>
               </xsl:for-each>
            </fo:table-body>
         </fo:table>
      </fo:block>
      -->
        <xsl:call-template name="DoListLetter">
            <xsl:with-param name="sLetterWidth" select="$sLetterWidth"/>
        </xsl:call-template>
        <!-- not sure if the following is the best... -->
        <tex:cmd name="hspace*">
            <tex:parm>-2.5pt</tex:parm>
        </tex:cmd>
        <!-- first row -->
        <xsl:choose>
            <xsl:when test="name()='listInterlinear'">
                <!--            <fo:table-cell keep-together.within-page="1">-->
                <!--               <xsl:call-template name="DoDebugExamples"/>-->
                <xsl:call-template name="DoListInterlinearEmbeddedTabular"/>
                <!--            </fo:table-cell>-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputWordOrSingle"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- remaining rows -->
        <xsl:for-each select="following-sibling::listWord | following-sibling::listSingle | following-sibling::listInterlinear">
            <!-- 
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
         -->
            <tex:spec cat="esc"/>
            <tex:spec cat="esc"/>
            <xsl:text>*
</xsl:text>
            <xsl:call-template name="DoListLetter">
                <xsl:with-param name="sLetterWidth" select="$sLetterWidth"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="name()='listInterlinear'">
                    <xsl:call-template name="DoListInterlinearEmbeddedTabular"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="OutputWordOrSingle"/>
                </xsl:otherwise>
            </xsl:choose>
            <!--         </fo:table-row>-->
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="DoListInterlinearEmbeddedTabular">
        <tex:spec cat="align"/>
        <tex:spec cat="esc"/>
        <xsl:text>multicolumn</xsl:text>
        <tex:spec cat="bg"/>
        <xsl:value-of select="$sInterlinearMaxNumberOfColumns"/>
        <tex:spec cat="eg"/>
        <tex:spec cat="bg"/>
        <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
        <xsl:text>l</xsl:text>
        <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
        <tex:spec cat="eg"/>
        <tex:spec cat="bg"/>
        <tex:env name="tabular">
            <tex:opt>t</tex:opt>
            <tex:parm>
                <xsl:call-template name="DoInterlinearTabularMainPattern"/>
            </tex:parm>
            <xsl:apply-templates select="child::node()[name()!='interlinearSource']"/>
        </tex:env>
        <tex:spec cat="eg"/>
        <tex:spec cat="esc"/>
        <tex:spec cat="esc"/>
        <xsl:text>*
</xsl:text>
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
            <xsl:when test="/lingPaper/@partlabel">
                <xsl:value-of select="/lingPaper/@partlabel"/>
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
        <!-- put title in marker so it can show up in running header -->
        <!-- 
      <fo:marker marker-class-name="section-title">
         <xsl:call-template name="DoSecTitleRunningHeader"/>
      </fo:marker>
      -->
        <tex:parm>
            <xsl:call-template name="OutputSectionNumberAndTitle"/>
        </tex:parm>
    </xsl:template>
    <!--  
                  OutputSectionNumberAndTitle
-->
    <xsl:template name="OutputSectionNumberAndTitle">
        <xsl:param name="bIsBookmark" select="'N'"/>
        <xsl:call-template name="OutputSectionNumber"/>
        <xsl:text disable-output-escaping="yes">&#x20;</xsl:text>
        <xsl:choose>
            <xsl:when test="$bIsBookmark='Y'">
                <xsl:apply-templates select="secTitle" mode="bookmarks"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="secTitle"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      OutputSectionNumber
   -->
    <xsl:template name="OutputSectionNumber">
        <xsl:choose>
            <xsl:when test="ancestor-or-self::appendix">
                <xsl:apply-templates select="." mode="numberAppendix"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="number"/>
            </xsl:otherwise>
        </xsl:choose>
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
        <!-- set level command name -->
        <xsl:variable name="sLevelName">
            <xsl:choose>
                <xsl:when test="$sLevel='1'">
                    <xsl:text>levelone</xsl:text>
                </xsl:when>
                <xsl:when test="$sLevel='2'">
                    <xsl:text>leveltwo</xsl:text>
                </xsl:when>
                <xsl:when test="$sLevel='3'">
                    <xsl:text>levelthree</xsl:text>
                </xsl:when>
                <xsl:when test="$sLevel='4'">
                    <xsl:text>levelfour</xsl:text>
                </xsl:when>
                <xsl:when test="$sLevel='5'">
                    <xsl:text>levelfive</xsl:text>
                </xsl:when>
                <xsl:when test="$sLevel='6'">
                    <xsl:text>levelsix</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- figure out what the new value of the indent based on the section number itself -->
        <xsl:variable name="sSectionNumberIndentFormula">
            <xsl:call-template name="CalculateSectionNumberIndent"/>
        </xsl:variable>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="concat($sLevelName,'indent')"/>
            <xsl:with-param name="sValue" select="$sSectionNumberIndentFormula"/>
        </xsl:call-template>
        <!-- figure out what the new value of the number width based on the section number itself -->
        <xsl:variable name="sSectionNumberWidthFormula">
            <xsl:call-template name="CalculateSectionNumberWidth"/>
        </xsl:variable>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="concat($sLevelName,'width')"/>
            <xsl:with-param name="sValue" select="$sSectionNumberWidthFormula"/>
        </xsl:call-template>
        <!-- output the toc line -->
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputSectionNumberAndTitle"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <tex:cmd name="{$sLevelName}indent" gr="0" nl2="0"/>
            </xsl:with-param>
            <xsl:with-param name="sNumWidth">
                <tex:cmd name="{$sLevelName}width" gr="0" nl2="0"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="CalculateSectionNumberIndent">
        <xsl:for-each select="ancestor::*[contains(name(),'section') or name()='appendix']">
            <xsl:call-template name="OutputSectionNumber"/>
            <tex:spec cat="esc"/>
            <xsl:text>&#x20;</xsl:text>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="CalculateSectionNumberWidth">
        <xsl:call-template name="OutputSectionNumber"/>
        <tex:spec cat="esc"/>
        <xsl:text>thinspace</xsl:text>
        <tex:spec cat="esc"/>
        <xsl:text>thinspace</xsl:text>
    </xsl:template>
    <!--  
                  OutputTable
-->
    <xsl:template name="OutputTable">
        <xsl:variable name="iBorder" select="ancestor-or-self::table/@border"/>
        <xsl:variable name="firstRowColumns" select="tr[1]/th | tr[1]/td"/>
        <xsl:variable name="iNumCols" select="count($firstRowColumns[not(number(@colspan) &gt; 0)]) + sum($firstRowColumns[number(@colspan) &gt; 0]/@colspan)"/>
        <xsl:variable name="sEnvName">
            <xsl:choose>
                <xsl:when test="parent::example or parent::td">
                    <xsl:text>tabular</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>longtable</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <tex:cmd name="vspace*">
            <tex:parm>
                <xsl:text>-</xsl:text>
                <tex:cmd name="baselineskip" gr="0"/>
            </tex:parm>
        </tex:cmd>
        <tex:env name="{$sEnvName}">
            <tex:opt>
                <xsl:choose>
                    <xsl:when test="parent::example or ancestor::table">t</xsl:when>
                    <xsl:otherwise>c</xsl:otherwise>
                </xsl:choose>
            </tex:opt>
            <tex:parm>
                <!--         <xsl:if test="@pagecontrol='keepAllOnSamePage'">
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
               <xsl:for-each select="$firstRowColumns">
                  <fo:table-column column-number="{position()}">
                     <xsl:attribute name="column-width">
                        <xsl:value-of select="number(100 div $iNumCols)"/>
                        <xsl:text>%</xsl:text>
                     </xsl:attribute>
                  </fo:table-column>
               </xsl:for-each>
            </xsl:if>
            -->
                <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
                <xsl:for-each select="tr[1]/td | tr[1]/th">
                    <xsl:choose>
                        <xsl:when test="number(@colspan) &gt; 0">
                            <xsl:call-template name="CreateColumnSpec">
                                <xsl:with-param name="iColspan" select="@colspan - 1"/>
                                <xsl:with-param name="iBorder" select="$iBorder"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="CreateColumnSpec">
                                <xsl:with-param name="iBorder" select="$iBorder"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:call-template name="CreateVerticalLine">
                    <xsl:with-param name="iBorder" select="$iBorder"/>
                </xsl:call-template>
                <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
            </tex:parm>
            <xsl:apply-templates select="caption">
                <xsl:with-param name="iNumCols" select="$iNumCols"/>
            </xsl:apply-templates>
            <xsl:if test="tr/th | headerRow">
                <!--             <fo:table-header>
               <xsl:call-template name="OutputTypeAttributes">
                  <xsl:with-param name="sList" select="tr[th]/@xsl-foSpecial"/>
               </xsl:call-template>
               <xsl:for-each select="tr[1] | headerRow">
                  <xsl:call-template name="DoType"/>
                  <xsl:call-template name="OutputBackgroundColor"/>
               </xsl:for-each>
-->
                <xsl:call-template name="CreateHorizontalLine">
                    <xsl:with-param name="iBorder" select="$iBorder"/>
                </xsl:call-template>
                <xsl:variable name="headerRows" select="tr[th[count(following-sibling::td)=0]]"/>
                <xsl:choose>
                    <xsl:when test="count($headerRows) != 1">
                        <xsl:for-each select="$headerRows">
                            <!--                        <fo:table-row>-->
                            <xsl:apply-templates select="th[count(following-sibling::td)=0] | headerRow">
                                <!--                        <xsl:with-param name="iBorder" select="$iBorder"/>-->
                            </xsl:apply-templates>
                            <tex:spec cat="esc"/>
                            <tex:spec cat="esc"/>
                            <!--                        </fo:table-row>-->
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--                  <xsl:call-template name="OutputBackgroundColor"/>-->
                        <xsl:apply-templates select="tr[th[count(following-sibling::td)=0]] | headerRow">
                            <!--                     <xsl:with-param name="iBorder" select="$iBorder"/>-->
                        </xsl:apply-templates>
                        <!--                  <xsl:apply-templates select="tr/th[count(following-sibling::td)=0] | headerRow"/>-->
                        <!--                  <tex:spec cat="esc"/>-->
                        <!--                  <tex:spec cat="esc"/>-->
                    </xsl:otherwise>
                </xsl:choose>
                <!--            </fo:table-header>-->
            </xsl:if>
            <xsl:variable name="rows" select="tr[not(th) or th[count(following-sibling::td)!=0]]"/>
            <xsl:choose>
                <xsl:when test="$rows">
                    <xsl:apply-templates select="$rows">
                        <xsl:with-param name="iBorder" select="$iBorder"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <!--                 <fo:table-row>
                  <fo:table-cell border-collapse="collapse">
                     <xsl:choose>
                        <xsl:when test="ancestor::table[1]/@border!='0' or count(ancestor::table)=1">
                           <xsl:attribute name="padding">.2em</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="position() &gt; 1">
                           <xsl:attribute name="padding-left">.2em</xsl:attribute>
                        </xsl:when>
                     </xsl:choose>
                     <fo:block> -->
                    <xsl:text>(This table does not have any contents!)</xsl:text>
                    <tex:spec cat="esc"/>
                    <tex:spec cat="esc"/>
                    <!--                      </fo:block>
                  </fo:table-cell>
                  </fo:table-row>  -->
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="endCaption">
                <xsl:with-param name="iNumCols" select="$iNumCols"/>
            </xsl:apply-templates>
        </tex:env>
        <!-- <fo:table space-before="0pt">
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
         <xsl:if test="tr/th | headerRow">
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
         </fo:table>  -->
    </xsl:template>
    <!--  
                  OutputTOCLine
-->
    <xsl:template name="OutputTOCLine">
        <xsl:param name="sLink"/>
        <xsl:param name="sLabel"/>
        <xsl:param name="sSpaceBefore" select="'0'"/>
        <xsl:param name="sIndent" select="'0pt'"/>
        <xsl:param name="sNumWidth" select="'0pt'"/>
        <xsl:if test="number($sSpaceBefore)>0">
            <tex:cmd name="vspace">
                <tex:parm>
                    <xsl:value-of select="$sBasicPointSize"/>
                    <xsl:text>pt</xsl:text>
                </tex:parm>
            </tex:cmd>
        </xsl:if>
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="$sLink"/>
        </xsl:call-template>
        <tex:cmd name="XLingPaperdottedtocline" nl2="1">
            <tex:parm>
                <xsl:copy-of select="$sIndent"/>
            </tex:parm>
            <tex:parm>
                <xsl:copy-of select="$sNumWidth"/>
            </tex:parm>
            <tex:parm>
                <xsl:copy-of select="$sLabel"/>
            </tex:parm>
            <tex:parm>
                <xsl:variable name="sPage" select="document($sTableOfContentsFile)/toc/tocline[@ref=$sLink]/@page"/>
                <xsl:choose>
                    <xsl:when test="$sPage">
                        <xsl:value-of select="$sPage"/>
                    </xsl:when>
                    <xsl:otherwise>??</xsl:otherwise>
                </xsl:choose>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="DoInternalTargetEnd"/>
        <!-- 
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
               <fo:leader leader-pattern="dots"/>
               <xsl:text>&#xa0;</xsl:text>
               <fo:page-number-citation ref-id="{$sLink}"/>
            </fo:inline>
         </fo:basic-link>
      </fo:block>
      -->
    </xsl:template>
    <!--
                OutputWordOrSingle
-->
    <xsl:template name="OutputWordOrSingle">
        <xsl:choose>
            <xsl:when test="name()='listWord' or name()='listSingle'">
                <xsl:for-each select="langData | gloss">
                    <!-- 
               <fo:table-cell xsl:use-attribute-sets="ExampleCell">
                  <xsl:call-template name="DoDebugExamples"/>
                  <fo:block>
-->
                    <tex:spec cat="align"/>
                    <xsl:apply-templates select="self::*"/>
                    <!-- 
                  </fo:block>
               </fo:table-cell>
               -->
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- adjust for a single space character; is there a better way? -->
                <xsl:call-template name="SingleSpaceAdjust"/>
                <xsl:for-each select="langData | gloss">
                    <tex:spec cat="align"/>
                    <xsl:apply-templates select="self::*"/>
                    <!-- 
               <xsl:if test="position()!=last()">
                  <xsl:text>&#xa0;&#xa0;</xsl:text>
               </xsl:if>
-->
                </xsl:for-each>
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
      SetFonts
   -->
    <xsl:template name="SetFonts">
        <tex:cmd name="setmainfont" nl2="1">
            <tex:parm>
                <xsl:value-of select="$sDefaultFontFamily"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="DefineAFont">
            <xsl:with-param name="sFontName" select="'MainFont'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
            <xsl:with-param name="sPointSize" select="$sBasicPointSize"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'HeaderFooterFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'TitleFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'SubtitleFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'AuthorFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'AffiliationFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'DateFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'SectionLevelOneFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'SectionLevelTwoFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'SectionLevelThreeFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'SectionLevelFourFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'SectionLevelFiveFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:call-template name="DefineAFontFamily">
            <xsl:with-param name="sFontFamilyName" select="'SectionLevelSixFontFamily'"/>
            <xsl:with-param name="sBaseFontName" select="$sDefaultFontFamily"/>
        </xsl:call-template>
        <xsl:for-each select="//language | //type[string-length(normalize-space(@font-family)) &gt; 0]">
            <xsl:call-template name="DefineAFontFamily">
                <xsl:with-param name="sFontFamilyName">
                    <xsl:text>Lang</xsl:text>
                    <xsl:value-of select="@id"/>
                    <xsl:text>FontFamily</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="sBaseFontName">
                    <xsl:variable name="sFontFamily" select="normalize-space(@font-family)"/>
                    <xsl:choose>
                        <xsl:when test="string-length($sFontFamily) &gt; 0">
                            <xsl:value-of select="$sFontFamily"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$sDefaultFontFamily"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--  
      SetHeaderFooter
   -->
    <xsl:template name="SetHeaderFooter">
        <tex:cmd name="pagestyle" nl2="1">
            <tex:parm>fancy</tex:parm>
        </tex:cmd>
        <tex:cmd name="fancyhf" nl2="1"/>
        <tex:cmd name="fancyhead" nl2="1">
            <tex:opt>RO,LE</tex:opt>
            <tex:parm>
                <tex:cmd name="HeaderFooterFontFamily">
                    <tex:parm>
                        <tex:cmd name="small">
                            <tex:parm>
                                <tex:cmd name="textit">
                                    <tex:parm>
                                        <tex:cmd name="thepage" gr="0"/>
                                    </tex:parm>
                                </tex:cmd>
                            </tex:parm>
                        </tex:cmd>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="fancyhead" nl2="1">
            <tex:opt>RE</tex:opt>
            <tex:parm>
                <tex:cmd name="HeaderFooterFontFamily">
                    <tex:parm>
                        <tex:cmd name="small">
                            <tex:parm>
                                <tex:cmd name="textit">
                                    <tex:parm>
                                        <tex:cmd name="leftmark" gr="0"/>
                                    </tex:parm>
                                </tex:cmd>
                            </tex:parm>
                        </tex:cmd>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="fancyhead" nl2="1">
            <tex:opt>LO</tex:opt>
            <tex:parm>
                <tex:cmd name="HeaderFooterFontFamily">
                    <tex:parm>
                        <tex:cmd name="small">
                            <tex:parm>
                                <tex:cmd name="textit">
                                    <tex:parm>
                                        <tex:cmd name="rightmark" gr="0"/>
                                    </tex:parm>
                                </tex:cmd>
                            </tex:parm>
                        </tex:cmd>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="renewcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="headrulewidth" gr="0"/>
            </tex:parm>
            <tex:parm>0pt</tex:parm>
        </tex:cmd>
        <tex:cmd name="renewcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="footrulewidth" gr="0"/>
            </tex:parm>
            <tex:parm>0pt</tex:parm>
        </tex:cmd>
        <tex:cmd name="fancypagestyle" nl2="1">
            <tex:parm>plain</tex:parm>
            <tex:parm>
                <tex:cmd name="fancyhf" nl2="1"/>
                <tex:cmd name="fancyfoot" nl2="1">
                    <tex:opt>C</tex:opt>
                    <tex:parm>
                        <tex:cmd name="HeaderFooterFontFamily">
                            <tex:parm>
                                <tex:cmd name="small">
                                    <tex:parm>
                                        <tex:cmd name="textit">
                                            <tex:parm>
                                                <tex:cmd name="thepage" gr="0"/>
                                            </tex:parm>
                                        </tex:cmd>
                                    </tex:parm>
                                </tex:cmd>
                            </tex:parm>
                        </tex:cmd>
                    </tex:parm>
                </tex:cmd>
                <tex:cmd name="renewcommand" nl2="1">
                    <tex:parm>
                        <tex:cmd name="headrulewidth" gr="0"/>
                    </tex:parm>
                    <tex:parm>0pt</tex:parm>
                </tex:cmd>
                <tex:cmd name="renewcommand" nl2="1">
                    <tex:parm>
                        <tex:cmd name="footrulewidth" gr="0"/>
                    </tex:parm>
                    <tex:parm>0pt</tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
      SetListLengths
   -->
    <xsl:template name="SetListLengths">
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'topsep'"/>
            <xsl:with-param name="sValue" select="'0pt'"/>
        </xsl:call-template>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'partopsep'"/>
            <xsl:with-param name="sValue" select="'0pt'"/>
        </xsl:call-template>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'itemsep'"/>
            <xsl:with-param name="sValue" select="'0pt'"/>
        </xsl:call-template>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'parsep'"/>
            <xsl:with-param name="sValue" select="'0pt'"/>
        </xsl:call-template>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'parskip'"/>
            <xsl:with-param name="sValue" select="'0pt'"/>
        </xsl:call-template>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'leftmargini'"/>
            <xsl:with-param name="sValue" select="'1em'"/>
        </xsl:call-template>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'leftmarginii'"/>
            <xsl:with-param name="sValue" select="'1em'"/>
        </xsl:call-template>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'leftmarginiii'"/>
            <xsl:with-param name="sValue" select="'1em'"/>
        </xsl:call-template>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'leftmarginiv'"/>
            <xsl:with-param name="sValue" select="'1em'"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
      SetPageLayoutParameters
   -->
    <xsl:template name="SetPageLayoutParameters">
        <tex:cmd name="setlength" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="paperheight" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:value-of select="$sPageHeight"/>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="paperwidth" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:value-of select="$sPageWidth"/>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="topmargin" gr="0"/>
            </tex:parm>
            <tex:parm>0pt</tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="voffset" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:variable name="iPageTopMargin">
                    <xsl:call-template name="GetMeasure">
                        <xsl:with-param name="sValue" select="$sPageTopMargin"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="SubtractOneInch">
                    <xsl:with-param name="sValue" select="$sPageTopMargin"/>
                    <!-- the .15in makes it match what we got with FO - I'm not sure why, though -->
                    <xsl:with-param name="iValue" select="$iPageTopMargin"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="evensidemargin" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="SubtractOneInch">
                    <xsl:with-param name="sValue" select="$sPageOutsideMargin"/>
                    <xsl:with-param name="iValue" select="$iPageOutsideMargin"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="oddsidemargin" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="SubtractOneInch">
                    <xsl:with-param name="sValue" select="$sPageInsideMargin"/>
                    <xsl:with-param name="iValue" select="$iPageInsideMargin"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="textwidth" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:value-of select="number($iPageWidth - $iPageInsideMargin - $iPageOutsideMargin)"/>
                <xsl:call-template name="GetUnitOfMeasure">
                    <xsl:with-param name="sValue" select="$sPageWidth"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="textheight" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:value-of select="number($iPageHeight - $iPageTopMargin - $iPageBottomMargin - $iHeaderMargin - $iFooterMargin)"/>
                <xsl:call-template name="GetUnitOfMeasure">
                    <xsl:with-param name="sValue" select="$sPageHeight"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="headheight" gr="0"/>
            </tex:parm>
            <tex:parm>
                <!-- head height needs to be about 2 points larger -->
                <xsl:value-of select="$sBasicPointSize + 2"/>
                <xsl:text>pt</xsl:text>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="headsep" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:variable name="iHeaderMarginAsPoints">
                    <xsl:call-template name="ConvertToPoints">
                        <xsl:with-param name="sValue" select="$sHeaderMargin"/>
                        <xsl:with-param name="iValue" select="$iHeaderMargin"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="number($iHeaderMarginAsPoints - $sBasicPointSize - 2)"/>
                <xsl:text>pt</xsl:text>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl1="1" nl2="1">
            <tex:parm>
                <tex:cmd name="footskip" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:value-of select="$sFooterMargin"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
      SetTeXCommand
   -->
    <xsl:template name="SetTeXCommand">
        <xsl:param name="sTeXCommand"/>
        <xsl:param name="sCommandToSet"/>
        <xsl:param name="sValue"/>
        <tex:cmd name="{$sTeXCommand}" nl2="1">
            <tex:parm>
                <tex:cmd name="{$sCommandToSet}" gr="0" nl2="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:copy-of select="$sValue"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
      SingleSpaceAdjust
   -->
    <xsl:template name="SingleSpaceAdjust">
        <tex:cmd name="hspace*">
            <tex:parm>-.25em</tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
      SubtractOneInch
   -->
    <xsl:template name="SubtractOneInch">
        <xsl:param name="sValue"/>
        <xsl:param name="iValue"/>
        <xsl:variable name="sUnit">
            <xsl:call-template name="GetUnitOfMeasure">
                <xsl:with-param name="sValue" select="$sValue"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$sUnit='in'">
                <xsl:value-of select="number($iValue - 1)"/>
                <xsl:text>in
</xsl:text>
            </xsl:when>
            <xsl:when test="$sUnit='mm'">
                <xsl:value-of select="number($iValue - 25.4)"/>
                <xsl:text>mm
</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$iValue"/>
                <xsl:value-of select="$sUnit"/>
            </xsl:otherwise>
        </xsl:choose>
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
    <xsl:template match="textInfo/shortTitle"/>
    <xsl:template match="styles"/>
    <xsl:template match="style"/>
    <xsl:template match="dd"/>
    <xsl:template match="term"/>
    <xsl:template match="type"/>
</xsl:stylesheet>
