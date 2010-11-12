<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:tex="http://getfo.sourceforge.net/texml/ns1" xmlns:saxon="http://icl.com/saxon">
    <xsl:output method="xml" version="1.0" encoding="utf-8" indent="no"/>
    <!-- ===========================================================
      Keys
      =========================================================== -->
    <xsl:key name="IndexTermID" match="//indexTerm" use="@id"/>
    <xsl:key name="InterlinearReferenceID" match="//interlinear" use="@text"/>
    <xsl:key name="LanguageID" match="//language" use="@id"/>
    <xsl:key name="RefWorkID" match="//refWork" use="@id"/>
    <xsl:key name="TypeID" match="//type" use="@id"/>
    <!-- ===========================================================
      Parameterized Variables
      =========================================================== -->
    <!-- the following is actually  the main source file path and name without extension -->
    <xsl:param name="sMainSourcePath" select="'C:/Documents and Settings/Andy Black/My Documents/XLingPap/XeTeX'"/>
    <xsl:param name="sMainSourceFile" select="'TestTeXPaperTeXML'"/>
    <xsl:param name="sDirectorySlash" select="'/'"/>
    <xsl:param name="sTableOfContentsFile" select="concat($sMainSourcePath, $sDirectorySlash, 'XLingPaperPDFTemp', $sDirectorySlash, $sMainSourceFile,'.toc')"/>
    <xsl:param name="sIndexFile" select="concat($sMainSourcePath, $sDirectorySlash, 'XLingPaperPDFTemp', $sDirectorySlash, $sMainSourceFile,'.idx')"/>
    <xsl:param name="sFOProcessor">XEP</xsl:param>
    <xsl:param name="bUseBookTabs" select="'Y'"/>
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
    <xsl:variable name="sBasicPointSize" select="string($pageLayoutInfo/basicPointSize)"/>
    <xsl:variable name="sFootnotePointSize" select="string($pageLayoutInfo/footnotePointSize)"/>
    <xsl:variable name="publisherStyleSheet" select="//publisherStyleSheet"/>
    <xsl:variable name="frontMatterLayoutInfo" select="$publisherStyleSheet/frontMatterLayout"/>
    <xsl:variable name="bodyLayoutInfo" select="$publisherStyleSheet/bodyLayout"/>
    <xsl:variable name="backMatterLayoutInfo" select="$publisherStyleSheet/backMatterLayout"/>
    <xsl:variable name="contentLayoutInfo" select="$publisherStyleSheet/contentLayout"/>
    <xsl:variable name="iAffiliationLayouts" select="count($frontMatterLayoutInfo/affiliationLayout)"/>
    <xsl:variable name="iAuthorLayouts" select="count($frontMatterLayoutInfo/authorLayout)"/>
    <xsl:variable name="iEmailAddressLayouts" select="count($frontMatterLayoutInfo/emailAddressLayout)"/>
    <xsl:variable name="sExampleIndentBefore" select="string($contentLayoutInfo/exampleLayout/@indent-before)"/>
    <xsl:variable name="sExampleIndentAfter" select="string($contentLayoutInfo/exampleLayout/@indent-after)"/>
    <xsl:variable name="lineSpacing" select="$pageLayoutInfo/lineSpacing"/>
    <xsl:variable name="sLineSpacing" select="$lineSpacing/@linespacing"/>
    <xsl:variable name="nLevel">
        <xsl:choose>
            <xsl:when test="//contents/@showLevel">
                <xsl:value-of select="number(//contents/@showLevel)"/>
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
    <xsl:variable name="iMagnificationFactor">
        <xsl:variable name="sAdjustedFactor" select="normalize-space($contentLayoutInfo/magnificationFactor)"/>
        <xsl:choose>
            <xsl:when test="string-length($sAdjustedFactor) &gt; 0 and $sAdjustedFactor!='1' and number($sAdjustedFactor)!='NaN'">
                <xsl:value-of select="$sAdjustedFactor"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- ===========================================================
      Variables
      =========================================================== -->
    <xsl:variable name="bIsBook" select="//chapter"/>
    <xsl:variable name="references" select="//references"/>
    <!-- ===========================================================
      MAIN BODY
      =========================================================== -->
    <xsl:template match="//lingPaper">
        <tex:TeXML>
            <xsl:comment> generated by XLingPapPublisherStylesheetXeLaTeX.xsl Version <xsl:value-of select="$sVersion"/>&#x20;</xsl:comment>
            <xsl:if test="$iMagnificationFactor!=1">
                <tex:spec cat="esc"/>
                <xsl:text>mag </xsl:text>
                <xsl:value-of select="$iMagnificationFactor * 1000"/>
                <xsl:text>&#x0a;</xsl:text>
            </xsl:if>
            <tex:cmd name="documentclass" nl2="1">
                <!--            <tex:opt>a4paper</tex:opt>-->
                <tex:opt>
                    <xsl:choose>
                        <xsl:when test="$sBasicPointSize='10'">10</xsl:when>
                        <xsl:when test="$sBasicPointSize='11'">11</xsl:when>
                        <xsl:when test="$sBasicPointSize='12'">12</xsl:when>
                        <xsl:when test="$chapters">10</xsl:when>
                        <xsl:otherwise>12</xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>pt</xsl:text>
                    <xsl:if test="$bHasChapter!='Y'">
                        <xsl:text>,twoside</xsl:text>
                    </xsl:if>
                </tex:opt>
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
            <xsl:call-template name="SetUsePackages"/>
            <xsl:call-template name="SetHeaderFooter"/>
            <xsl:call-template name="SetFonts"/>
            <xsl:call-template name="SetFootnoteRule"/>
            <tex:cmd name="setlength" nl2="1">
                <tex:parm>
                    <tex:cmd name="parindent" gr="0"/>
                </tex:parm>
                <tex:parm>
                    <xsl:value-of select="$sParagraphIndent"/>
                </tex:parm>
            </tex:cmd>
            <xsl:call-template name="SetSpecialTextSymbols"/>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single'">
                <xsl:choose>
                    <xsl:when test="$sLineSpacing='double'">
                        <tex:cmd name="doublespacing" gr="0" nl2="1"/>
                    </xsl:when>
                    <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                        <tex:cmd name="onehalfspacing" gr="0" nl2="1"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
            <xsl:call-template name="SetZeroWidthSpaceHandling"/>
            <xsl:call-template name="CreateClearEmptyDoublePageCommand"/>
            <tex:env name="document">
                <xsl:call-template name="CreateAllNumberingLevelIndentAndWidthCommands"/>
                <tex:spec cat="esc"/>
                <xsl:text>newdimen</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>XLingPapertempdim
</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>newdimen</xsl:text>
                <tex:spec cat="esc"/>
                <xsl:text>XLingPapertempdimletter
</xsl:text>
                <xsl:call-template name="SetTOCMacros"/>
                <xsl:call-template name="SetTOClengths"/>
                <xsl:if test="$bHasIndex='Y'">
                    <xsl:call-template name="SetXLingPaperIndexMacro"/>
                    <xsl:call-template name="SetXLingPaperAddToIndexMacro"/>
                    <xsl:call-template name="SetXLingPaperIndexItemMacro"/>
                    <xsl:call-template name="SetXLingPaperEndIndexMacro"/>
                    <tex:cmd name="XLingPaperindex" gr="0" nl2="0"/>
                </xsl:if>
                <xsl:call-template name="SetListLengthWidths"/>
                <xsl:call-template name="SetXLingPaperListItemMacro"/>
                <xsl:call-template name="SetXLingPaperExampleMacro"/>
                <xsl:call-template name="SetXLingPaperExampleInTableMacro"/>
                <xsl:call-template name="SetXLingPaperFreeMacro"/>
                <xsl:call-template name="SetXLingPaperListInterlinearMacro"/>
                <xsl:call-template name="SetXLingPaperListInterlinearInTableMacro"/>
                <xsl:call-template name="SetXLingPaperExampleFreeIndent"/>
                <tex:cmd name="raggedbottom" gr="0" nl2="1"/>
                <tex:cmd name="pagestyle">
                    <tex:parm>fancy</tex:parm>
                </tex:cmd>
                <tex:env name="MainFont">
                    <xsl:choose>
                        <xsl:when test="$chapters">
                            <!--                            <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@showbookmarks!='no'">
                                <xsl:call-template name="DoBookmarksForPaper"/>
                            </xsl:if>
-->
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--                            <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@showbookmarks!='no'">
                                <xsl:call-template name="DoBookmarksForPaper"/>
                            </xsl:if>
-->
                            <xsl:apply-templates select="frontMatter"/>
                            <xsl:apply-templates select="//section1[not(parent::appendix)]"/>
                            <xsl:apply-templates select="//backMatter"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- somewhere there's an opening bracket... -->
                    <!--                    <tex:spec cat="eg"/>-->
                </tex:env>
                <xsl:if test="$bHasContents='Y'">
                    <tex:cmd name="XLingPaperendtableofcontents" gr="0" nl2="1"/>
                </xsl:if>
                <xsl:if test="$bHasIndex='Y'">
                    <tex:cmd name="XLingPaperendindex" gr="0" nl2="1"/>
                </xsl:if>
            </tex:env>
        </tex:TeXML>
    </xsl:template>
    <xsl:template name="CreateClearEmptyDoublePageCommand">
        <tex:cmd name="let" gr="0" nl1="1"/>
        <tex:cmd name="origdoublepage" gr="0"/>
        <tex:cmd name="cleardoublepage" gr="0" nl2="1"/>
        <tex:cmd name="newcommand">
            <tex:parm>
                <tex:cmd name="clearemptydoublepage" gr="0"/>
            </tex:parm>
            <tex:parm>
                <tex:cmd name="clearpage">
                    <tex:parm>
                        <tex:cmd name="pagestyle">
                            <tex:parm>empty</tex:parm>
                        </tex:cmd>
                        <tex:cmd name="origdoublepage" gr="0"/>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
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
                <xsl:if test="$frontMatterLayoutInfo/headerFooterPageStyles">
                    <tex:cmd name="pagestyle">
                        <tex:parm>frontmatter</tex:parm>
                    </tex:cmd>
                </xsl:if>
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
        <xsl:if test="$frontMatterLayoutInfo/titleHeaderFooterPageStyles">
            <tex:cmd name="pagestyle">
                <tex:parm>frontmattertitle</tex:parm>
            </tex:cmd>
        </xsl:if>
        <xsl:if test="$bIsBook">
            <tex:group>
                <xsl:call-template name="DoTitleFormatInfo">
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
                </xsl:call-template>
                <xsl:apply-templates/>
                <xsl:variable name="contentForThisElement">
                    <xsl:apply-templates/>
                </xsl:variable>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
                </xsl:call-template>
                <xsl:call-template name="DoTitleFormatInfoEnd">
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
                    <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
                </xsl:call-template>
            </tex:group>
            <tex:cmd name="par" nl2="1"/>
            <xsl:call-template name="DoSpaceAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
            </xsl:call-template>
            <xsl:apply-templates select="following-sibling::subtitle"/>
        </xsl:if>
        <tex:group>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:variable name="contentForThisElement">
                <xsl:apply-templates/>
            </xsl:variable>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
            </xsl:call-template>
            <xsl:call-template name="DoTitleFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleLayout"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="title" mode="contentOnly">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      subtitle
      -->
    <xsl:template match="subtitle">
        <tex:group>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/subtitleLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:variable name="contentForThisElement">
                <xsl:apply-templates/>
            </xsl:variable>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/subtitleLayout"/>
            </xsl:call-template>
            <xsl:call-template name="DoTitleFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/subtitleLayout"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
    </xsl:template>
    <!--
      author
      -->
    <xsl:template match="author">
        <xsl:variable name="iPos" select="count(preceding-sibling::author) + 1"/>
        <xsl:variable name="iPosToUse">
            <xsl:call-template name="GetBestLayout">
                <xsl:with-param name="iPos" select="$iPos"/>
                <xsl:with-param name="iLayouts" select="$iAuthorLayouts"/>
            </xsl:call-template>
        </xsl:variable>
        <tex:group>
            <xsl:call-template name="DoFrontMatterFormatInfoBegin">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/authorLayout[$iPosToUse]"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:variable name="contentForThisElement">
                <xsl:apply-templates/>
            </xsl:variable>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/authorLayout[$iPosToUse]"/>
            </xsl:call-template>
            <xsl:call-template name="DoFrontMatterFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/authorLayout[$iPosToUse]"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/authorLayout[$iPosToUse]"/>
        </xsl:call-template>
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
        <xsl:variable name="iPos" select="count(preceding-sibling::affiliation) + 1"/>
        <xsl:variable name="iPosToUse">
            <xsl:call-template name="GetBestLayout">
                <xsl:with-param name="iPos" select="$iPos"/>
                <xsl:with-param name="iLayouts" select="$iAffiliationLayouts"/>
            </xsl:call-template>
        </xsl:variable>
        <tex:group>
            <xsl:call-template name="DoFrontMatterFormatInfoBegin">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/affiliationLayout[$iPosToUse]"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:variable name="contentForThisElement">
                <xsl:apply-templates/>
            </xsl:variable>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/affiliationLayout[$iPosToUse]"/>
            </xsl:call-template>
            <xsl:call-template name="DoFrontMatterFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/affiliationLayout[$iPosToUse]"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/affiliationLayout[$iPos]"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        emailAddress
    -->
    <xsl:template match="emailAddress">
        <xsl:variable name="iPos" select="count(preceding-sibling::emailAddress) + 1"/>
        <xsl:variable name="iPosToUse">
            <xsl:call-template name="GetBestLayout">
                <xsl:with-param name="iPos" select="$iPos"/>
                <xsl:with-param name="iLayouts" select="$iEmailAddressLayouts"/>
            </xsl:call-template>
        </xsl:variable>
        <tex:group>
            <xsl:call-template name="DoFrontMatterFormatInfoBegin">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/emailAddressLayout[$iPosToUse]"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:variable name="contentForThisElement">
                <xsl:apply-templates/>
            </xsl:variable>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/emailAddressLayout[$iPosToUse]"/>
            </xsl:call-template>
            <xsl:call-template name="DoFrontMatterFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/emailAddressLayout[$iPosToUse]"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/emailAddressLayout[$iPos]"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        date
    -->
    <xsl:template match="date">
        <tex:group>
            <xsl:call-template name="DoFrontMatterFormatInfoBegin">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/dateLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:variable name="contentForThisElement">
                <xsl:apply-templates/>
            </xsl:variable>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/dateLayout"/>
            </xsl:call-template>
            <xsl:call-template name="DoFrontMatterFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/dateLayout"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/dateLayout"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        presentedAt
    -->
    <xsl:template match="presentedAt">
        <tex:group>
            <xsl:call-template name="DoFrontMatterFormatInfoBegin">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/presentedAtLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:variable name="contentForThisElement">
                <xsl:apply-templates/>
            </xsl:variable>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/presentedAtLayout"/>
            </xsl:call-template>
            <xsl:call-template name="DoFrontMatterFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/presentedAtLayout"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/presentedAtLayout"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      version
      -->
    <xsl:template match="version">
        <tex:group>
            <xsl:call-template name="DoFrontMatterFormatInfoBegin">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/versionLayout"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:variable name="contentForThisElement">
                <xsl:apply-templates/>
            </xsl:variable>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/versionLayout"/>
            </xsl:call-template>
            <xsl:call-template name="DoFrontMatterFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/versionLayout"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/versionLayout"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      contents (for book)
      -->
    <xsl:template match="contents" mode="book">
        <xsl:call-template name="DoPageBreakFormatInfo">
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/contentsLayout"/>
        </xsl:call-template>
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
            <xsl:with-param name="id" select="'rXLingPapAbstract'"/>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputAbstractLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/abstractLayout"/>
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
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="$frontMatterLayoutInfo/abstractTextFontInfo">
                <tex:group>
                    <!-- Note: I do not know yet if these work well with RTL scripts or if they need to be flipped -->
                    <xsl:if test="string-length(normalize-space($abstractTextLayoutInfo/@start-indent)) &gt; 0">
                        <tex:spec cat="esc"/>
                        <xsl:text>leftskip</xsl:text>
                        <xsl:value-of select="normalize-space($abstractTextLayoutInfo/@start-indent)"/>
                        <xsl:text>&#x20;</xsl:text>
                    </xsl:if>
                    <xsl:if test="string-length(normalize-space($abstractTextLayoutInfo/@end-indent)) &gt; 0">
                        <tex:spec cat="esc"/>
                        <xsl:text>rightskip</xsl:text>
                        <xsl:value-of select="normalize-space($abstractTextLayoutInfo/@end-indent)"/>
                        <xsl:text>&#x20;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$abstractTextLayoutInfo/@textalign='start' or $abstractTextLayoutInfo/@textalign='left'">
                        <tex:cmd name="noindent" gr="0" nl2="1"/>
                    </xsl:if>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="$abstractTextLayoutInfo"/>
                        <xsl:with-param name="originalContext" select="."/>
                    </xsl:call-template>
                    <xsl:if test="$abstractTextLayoutInfo/@textalign">
                        <xsl:call-template name="DoTextAlign">
                            <xsl:with-param name="layoutInfo" select="$abstractTextLayoutInfo"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:apply-templates/>
                    <xsl:variable name="contentForThisElement">
                        <xsl:apply-templates/>
                    </xsl:variable>
                    <xsl:if test="$abstractTextLayoutInfo/@textalign">
                        <xsl:call-template name="DoTextAlignEnd">
                            <xsl:with-param name="layoutInfo" select="$abstractTextLayoutInfo"/>
                            <xsl:with-param name="contentForThisElement" select="$contentForThisElement"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:call-template name="OutputFontAttributesEnd">
                        <xsl:with-param name="language" select="$abstractTextLayoutInfo"/>
                        <xsl:with-param name="originalContext" select="."/>
                    </xsl:call-template>
                </tex:group>
                <xsl:call-template name="DoSpaceAfter">
                    <xsl:with-param name="layoutInfo" select="$abstractLayoutInfo"/>
                </xsl:call-template>
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
            <xsl:with-param name="id" select="'rXLingPapAcknowledgements'"/>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputAcknowledgementsLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/acknowledgementsLayout"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      aknowledgements (backmatter-book)
   -->
    <xsl:template match="acknowledgements" mode="backmatter-book">
        <xsl:call-template name="DoBackMatterItemNewPage">
            <xsl:with-param name="id" select="'rXLingPapAcknowledgements'"/>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputAcknowledgementsLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/acknowledgementsLayout"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        acknowledgements (paper)
    -->
    <xsl:template match="acknowledgements" mode="paper">
        <xsl:choose>
            <xsl:when test="ancestor::frontMatter">
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id">rXLingPapAcknowledgements</xsl:with-param>
                    <xsl:with-param name="sTitle">
                        <xsl:call-template name="OutputAcknowledgementsLabel"/>
                    </xsl:with-param>
                    <xsl:with-param name="bIsBook" select="'N'"/>
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/acknowledgementsLayout"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id">rXLingPapAcknowledgements</xsl:with-param>
                    <xsl:with-param name="sTitle">
                        <xsl:call-template name="OutputAcknowledgementsLabel"/>
                    </xsl:with-param>
                    <xsl:with-param name="bIsBook" select="'N'"/>
                    <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/acknowledgementsLayout"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      preface (book)
   -->
    <xsl:template match="preface" mode="book">
        <xsl:call-template name="DoFrontMatterItemNewPage">
            <xsl:with-param name="id" select="concat('rXLingPapPreface',position())"/>
            <xsl:with-param name="sTitle">
                <xsl:call-template name="OutputPrefaceLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/prefaceLayout"/>
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
        <xsl:call-template name="DoPageBreakFormatInfo">
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/partTitleLayout"/>
        </xsl:call-template>
        <xsl:if test="not(preceding-sibling::part) and not(//chapterBeforePart)">
            <xsl:if test="$bodyLayoutInfo/titleHeaderFooterPageStyles">
                <tex:cmd name="pagestyle">
                    <tex:parm>body</tex:parm>
                </tex:cmd>
            </xsl:if>
            <!-- start using arabic page numbers -->
            <tex:cmd name="pagenumbering">
                <tex:parm>arabic</tex:parm>
            </tex:cmd>
        </xsl:if>
        <tex:group>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/numberLayout"/>
            </xsl:call-template>
            <tex:cmd name="thispagestyle">
                <tex:parm>empty</tex:parm>
            </tex:cmd>
            <xsl:call-template name="DoBookMark"/>
            <xsl:call-template name="DoInternalTargetBegin">
                <xsl:with-param name="sName" select="@id"/>
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
            <xsl:variable name="contentForThisElement">
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
            </xsl:variable>
            <xsl:call-template name="DoTitleFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/numberLayout"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
            <xsl:call-template name="DoInternalTargetEnd"/>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/numberLayout"/>
        </xsl:call-template>
        <tex:group>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/partTitleLayout"/>
            </xsl:call-template>
            <xsl:apply-templates select="secTitle"/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/partTitleLayout"/>
            </xsl:call-template>
            <xsl:variable name="contentForThisElement">
                <xsl:apply-templates select="secTitle"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/partTitleLayout"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="DoTitleFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/partTitleLayout"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/partLayout/partTitleLayout"/>
        </xsl:call-template>
        <xsl:apply-templates select="child::node()[name()!='secTitle' and name()!='chapter']"/>
        <xsl:apply-templates select="child::node()[name()='chapter']"/>
    </xsl:template>
    <!--
      Chapter or appendix (in book with chapters)
      -->
    <xsl:template match="chapter | appendix[//chapter]  | chapterBeforePart">
        <xsl:call-template name="DoPageBreakFormatInfo">
            <xsl:with-param name="layoutInfo">
                <xsl:choose>
                    <xsl:when test="name()='appendix'">
                        <xsl:choose>
                            <xsl:when test="name($backMatterLayoutInfo/appendixLayout/*[1])='appendixTitleLayout'">
                                <xsl:copy-of select="$backMatterLayoutInfo/appendixLayout/appendixTitleLayout"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="$backMatterLayoutInfo/appendixLayout/numberLayout"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="name($bodyLayoutInfo/chapterLayout/*[1])='chapterTitleLayout'">
                                <xsl:copy-of select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="$bodyLayoutInfo/chapterLayout/numberLayout"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="bUseClearEmptyDoublePage">
                <xsl:choose>
                    <xsl:when test="parent::part">Y</xsl:when>
                    <xsl:otherwise>N</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="name()='chapter' and not(parent::part) and position()=1 or preceding-sibling::*[1][name(.)='frontMatter']">
            <xsl:if test="$bodyLayoutInfo/headerFooterPageStyles">
                <tex:cmd name="pagestyle">
                    <tex:parm>body</tex:parm>
                </tex:cmd>
            </xsl:if>
            <!-- start using arabic page numbers -->
            <tex:cmd name="pagenumbering">
                <tex:parm>arabic</tex:parm>
            </tex:cmd>
        </xsl:if>
        <xsl:if test="$bodyLayoutInfo/headerFooterPageStyles">
            <tex:cmd name="thispagestyle">
                <tex:parm>bodyfirstpage</tex:parm>
            </tex:cmd>
        </xsl:if>
        <!-- put title in marker so it can show up in running header -->
        <tex:cmd name="markboth" nl2="1">
            <tex:parm>
                <xsl:call-template name="DoSecTitleRunningHeader"/>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="DoSecTitleRunningHeader"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="CreateAddToContents">
            <xsl:with-param name="id" select="@id"/>
        </xsl:call-template>
        <xsl:call-template name="DoBookMark"/>
        <xsl:call-template name="DoInternalTargetBegin">
            <xsl:with-param name="sName" select="@id"/>
        </xsl:call-template>
        <tex:group>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/numberLayout"/>
            </xsl:call-template>
            <xsl:call-template name="OutputChapTitle">
                <xsl:with-param name="sTitle">
                    <xsl:call-template name="OutputChapterNumber"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/numberLayout"/>
            </xsl:call-template>
            <xsl:variable name="contentForThisElement">
                <xsl:call-template name="OutputChapTitle">
                    <xsl:with-param name="sTitle">
                        <xsl:call-template name="OutputChapterNumber"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/numberLayout"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="DoTitleFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/numberLayout"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
        </tex:group>
        <xsl:call-template name="DoInternalTargetEnd"/>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/numberLayout"/>
        </xsl:call-template>
        <tex:group>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout"/>
            </xsl:call-template>
            <xsl:apply-templates select="secTitle"/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout"/>
            </xsl:call-template>
            <xsl:variable name="contentForThisElement2">
                <xsl:apply-templates select="secTitle"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="DoTitleFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement2"/>
            </xsl:call-template>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/chapterLayout/chapterTitleLayout"/>
        </xsl:call-template>
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
        <!-- put title in marker so it can show up in running header -->
        <tex:cmd name="markboth" nl2="1">
            <tex:parm>
                <xsl:call-template name="DoSecTitleRunningHeader"/>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="DoSecTitleRunningHeader"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="CreateAddToContents">
            <xsl:with-param name="id" select="@id"/>
        </xsl:call-template>
        <xsl:call-template name="DoBookMark"/>
        <xsl:call-template name="DoInternalTargetBegin">
            <xsl:with-param name="sName" select="@id"/>
        </xsl:call-template>
        <xsl:call-template name="DoTitleNeedsSpace"/>
        <xsl:call-template name="DoType">
            <xsl:with-param name="type" select="@type"/>
        </xsl:call-template>
        <xsl:call-template name="DoTitleFormatInfo">
            <xsl:with-param name="layoutInfo" select="$appLayout"/>
            <xsl:with-param name="originalContext" select="secTitle"/>
        </xsl:call-template>
        <xsl:if test="$appLayout/@showletter!='no'">
            <xsl:apply-templates select="." mode="numberAppendix"/>
            <xsl:value-of select="$appLayout/@textafterletter"/>
        </xsl:if>
        <xsl:apply-templates select="secTitle"/>
        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
            <xsl:with-param name="layoutInfo" select="$appLayout"/>
        </xsl:call-template>
        <xsl:variable name="contentForThisElement">
            <xsl:apply-templates select="secTitle"/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$appLayout"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="DoTitleFormatInfoEnd">
            <xsl:with-param name="layoutInfo" select="$appLayout"/>
            <xsl:with-param name="originalContext" select="secTitle"/>
            <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
        </xsl:call-template>
        <xsl:call-template name="DoTypeEnd">
            <xsl:with-param name="type" select="@type"/>
        </xsl:call-template>
        <xsl:call-template name="DoInternalTargetEnd"/>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$appLayout"/>
        </xsl:call-template>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <!--
      secTitle
      -->
    <xsl:template match="secTitle" mode="InMarker">
        <!--        <xsl:apply-templates select="child::node()[name()!='endnote']"/>-->
        <xsl:apply-templates mode="InMarker"/>
    </xsl:template>
    <xsl:template match="secTitle">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
      sectionRef
      -->
    <xsl:template match="sectionRef">
        <xsl:call-template name="OutputAnyTextBeforeSectionRef"/>
        <xsl:variable name="secRefToUse">
            <!-- adjust reference to a section that is actually present per the style sheet -->
            <xsl:call-template name="GetSectionRefToUse">
                <xsl:with-param name="section" select="id(@sec)"/>
                <xsl:with-param name="bodyLayoutInfo" select="$bodyLayoutInfo"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="$secRefToUse"/>
        </xsl:call-template>
        <xsl:if test="$contentLayoutInfo/sectionRefLayout">
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$contentLayoutInfo/sectionRefLayout"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="LinkAttributesBegin">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/sectionRefLinkLayout"/>
        </xsl:call-template>
        <xsl:variable name="sNum">
            <xsl:apply-templates select="id($secRefToUse)" mode="number"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$contentLayoutInfo/exampleLayout/@AddPeriodAfterFinalDigit='yes'">
                <xsl:value-of select="substring($sNum,1,string-length($sNum)- 2)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sNum"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="LinkAttributesEnd">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/sectionRefLinkLayout"/>
        </xsl:call-template>
        <xsl:if test="$contentLayoutInfo/sectionRefLayout">
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="$contentLayoutInfo/sectionRefLayout"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="DoExternalHyperRefEnd"/>
    </xsl:template>
    <!--
      appendixRef
      -->
    <xsl:template match="appendixRef">
        <xsl:call-template name="OutputAnyTextBeforeSectionRef"/>
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="@app"/>
        </xsl:call-template>
        <xsl:call-template name="LinkAttributesBegin">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/appendixRefLinkLayout"/>
        </xsl:call-template>
        <xsl:apply-templates select="id(@app)" mode="numberAppendix"/>
        <xsl:call-template name="LinkAttributesEnd">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/appendixRefLinkLayout"/>
        </xsl:call-template>
        <xsl:call-template name="DoExternalHyperRefEnd"/>
    </xsl:template>
    <!--
      genericRef
      -->
    <xsl:template match="genericRef">
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="@gref"/>
        </xsl:call-template>
        <xsl:call-template name="LinkAttributesBegin">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/genericRefLinkLayout"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="LinkAttributesEnd">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/genericRefLinkLayout"/>
        </xsl:call-template>
        <xsl:call-template name="DoInternalHyperlinkEnd"/>
    </xsl:template>
    <!--
      link
      -->
    <xsl:template match="link">
        <xsl:call-template name="DoBreakBeforeLink"/>
        <xsl:call-template name="DoExternalHyperRefBegin">
            <xsl:with-param name="sName" select="@href"/>
        </xsl:call-template>
        <xsl:call-template name="LinkAttributesBegin">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/linkLinkLayout"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="LinkAttributesEnd">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/linkLinkLayout"/>
        </xsl:call-template>
        <xsl:call-template name="DoExternalHyperRefEnd"/>
    </xsl:template>
    <!-- ===========================================================
      PARAGRAPH
      =========================================================== -->
    <xsl:template match="p | pc" mode="endnote-content">
        <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
        </xsl:call-template>
        <xsl:for-each select="parent::endnote">
            <xsl:if test="not($backMatterLayoutInfo/useEndNotesLayout)">
                <tex:spec cat="esc"/>
                <xsl:text>footnotesize</xsl:text>
            </xsl:if>
            <tex:spec cat="bg"/>
            <tex:spec cat="esc"/>
            <xsl:text>textsuperscript</xsl:text>
            <tex:spec cat="bg"/>
            <xsl:call-template name="DoFootnoteNumberInTextValue"/>
            <tex:spec cat="eg"/>
            <tex:spec cat="eg"/>
        </xsl:for-each>
        <xsl:call-template name="OutputTypeAttributesEnd">
            <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="p | pc" mode="contentOnly">
        <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="OutputTypeAttributesEnd">
            <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="p | pc">
        <xsl:choose>
            <xsl:when test="string-length(.)=0 and count(*)=0">
                <!-- this paragraph is empty; do nothing -->
            </xsl:when>
            <xsl:when test="parent::endnote and name()='p' and not(preceding-sibling::p)">
                <!--  and position()='1'" -->
                <xsl:call-template name="OutputTypeAttributes">
                    <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
                </xsl:call-template>
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
                <!-- I do not understand why this should make any differemce, but it does.  See Larry Lyman's ZapPron paper, footnote 4 -->
                <xsl:if test="following-sibling::table and ancestor::table">
                    <tex:spec cat="esc"/>
                    <tex:spec cat="esc"/>
                    <!--                    <tex:cmd name="par" nl2="1"/> this causes TeX to halt for the XLingPaper user doc-->
                </xsl:if>
                <xsl:if test="ancestor::li">
                    <!-- we're in a list, so we need to be sure we have a \par to force the preceding material to use the \leftskip and \parindent of a p in a footnote -->
                    <tex:cmd name="par"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="parent::endnote and name()='p' and preceding-sibling::table[1]">
                <tex:cmd name="par"/>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="parent::endnote and name()='p' and preceding-sibling::p">
                <xsl:choose>
                    <xsl:when test="ancestor::table">
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:when>
                    <xsl:when test="ancestor::secTitle or ancestor::title">
                        <tex:spec cat="esc"/>
                        <tex:spec cat="esc"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <tex:cmd name="par"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="name()='pc'">
                        <xsl:if test="contains(@XeLaTeXSpecial,'pagebreak')">
                            <tex:cmd name="pagebreak" gr="0" nl2="0"/>
                        </xsl:if>
                        <tex:cmd name="noindent" gr="0" nl2="0" sp="1"/>
                    </xsl:when>
                    <xsl:when test="parent::blockquote and count(preceding-sibling::p)=0">
                        <xsl:if test="contains(@XeLaTeXSpecial,'pagebreak')">
                            <tex:cmd name="pagebreak" gr="0" nl2="0"/>
                        </xsl:if>
                        <tex:cmd name="noindent" gr="0" nl2="0" sp="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="preceding-sibling::*[1][name()='example']">
                            <!-- lose paragraph indent unless we do this when an example precedes; adding \par to the example macro does not work -->
                            <tex:cmd name="par" gr="0" nl2="0"/>
                        </xsl:if>
                        <xsl:if test="contains(@XeLaTeXSpecial,'pagebreak')">
                            <tex:cmd name="pagebreak" gr="0" nl2="0"/>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="count(preceding-sibling::*[name()!='secTitle'])=0">
                                <!-- is the first item -->
                                <xsl:choose>
                                    <xsl:when test="parent::section1 and $bodyLayoutInfo/section1Layout/@firstParagraphHasIndent='no'">
                                        <tex:cmd name="noindent" gr="0" nl2="0" sp="1"/>
                                    </xsl:when>
                                    <xsl:when test="parent::section2 and $bodyLayoutInfo/section2Layout/@firstParagraphHasIndent='no'">
                                        <tex:cmd name="noindent" gr="0" nl2="0" sp="1"/>
                                    </xsl:when>
                                    <xsl:when test="parent::section3 and $bodyLayoutInfo/section3Layout/@firstParagraphHasIndent='no'">
                                        <tex:cmd name="noindent" gr="0" nl2="0" sp="1"/>
                                    </xsl:when>
                                    <xsl:when test="parent::section4 and $bodyLayoutInfo/section4Layout/@firstParagraphHasIndent='no'">
                                        <tex:cmd name="noindent" gr="0" nl2="0" sp="1"/>
                                    </xsl:when>
                                    <xsl:when test="parent::section5 and $bodyLayoutInfo/section5Layout/@firstParagraphHasIndent='no'">
                                        <tex:cmd name="noindent" gr="0" nl2="0" sp="1"/>
                                    </xsl:when>
                                    <xsl:when test="parent::section6 and $bodyLayoutInfo/section6Layout/@firstParagraphHasIndent='no'">
                                        <tex:cmd name="noindent" gr="0" nl2="0" sp="1"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <tex:cmd name="indent" gr="0" nl2="0" sp="1"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <tex:cmd name="indent" gr="0" nl2="0" sp="1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="OutputTypeAttributes">
                    <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
                </xsl:call-template>
                <xsl:if test="parent::blockquote">
                    <!-- want to do this in blockquote, but type kinds of things cannot cross paragraph boundaries, so have to do here -->
                    <xsl:call-template name="DoType">
                        <xsl:with-param name="type" select="parent::blockquote/@type"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="parent::prose-text">
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',parent::prose-text/@lang)"/>
                    </xsl:call-template>
                    <!-- want to do this in prose-text, but type kinds of things cannot cross paragraph boundaries, so have to do here -->
                    <xsl:call-template name="DoType">
                        <xsl:with-param name="type" select="parent::prose-text/@type"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:apply-templates/>
                <xsl:if test="parent::prose-text">
                    <xsl:call-template name="DoTypeEnd">
                        <xsl:with-param name="type" select="parent::prose-text/@type"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputFontAttributesEnd">
                        <xsl:with-param name="language" select="key('LanguageID',parent::prose-text/@lang)"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="parent::blockquote">
                    <xsl:call-template name="DoTypeEnd">
                        <xsl:with-param name="type" select="parent::blockquote/@type"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="OutputTypeAttributesEnd">
                    <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="ancestor::td">
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:when>
                    <xsl:when test="parent::li and count(preceding-sibling::*)=0"/>
                    <xsl:otherwise>
                        <tex:cmd name="par"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ===========================================================
      LISTS
      =========================================================== -->
    <!--  What about type attributes?
    
    
    <xsl:template match="ol">
        <fo:list-block>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
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
                <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
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
                <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
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
-->
    <!-- ===========================================================
      EXAMPLES
      =========================================================== -->
    <xsl:template match="example">
        <xsl:variable name="myEndnote" select="ancestor::endnote"/>
        <xsl:variable name="myAncestorLists" select="ancestor::ol | ancestor::ul"/>
        <xsl:if test="parent::li">
            <!-- we need to close the li group and force a paragraph end to maintain the proper indent of this li -->
            <xsl:call-template name="DoTypeForLI">
                <xsl:with-param name="myAncestorLists" select="$myAncestorLists"/>
                <xsl:with-param name="myEndnote" select="$myEndnote"/>
                <xsl:with-param name="bIsEnd" select="'Y'"/>
            </xsl:call-template>
            <tex:spec cat="eg"/>
            <tex:cmd name="par"/>
        </xsl:if>
        <tex:group>
            <xsl:variable name="precedingSibling" select="preceding-sibling::*[1]"/>
            <xsl:if test="name($precedingSibling)='p' or name($precedingSibling)='pc' or name($precedingSibling)='example' or name($precedingSibling)='table' or name($precedingSibling)='chart' or name($precedingSibling)='tree' or name($precedingSibling)='interlinear-text'">
                <tex:cmd name="vspace">
                    <tex:parm>
                        <xsl:value-of select="$sBasicPointSize"/>
                        <xsl:text>pt</xsl:text>
                    </tex:parm>
                </tex:cmd>
            </xsl:if>
            <xsl:if test="parent::li and name($precedingSibling)!='example' and name($precedingSibling)!='p' and name($precedingSibling)!='pc' ">
                <tex:cmd name="vspace">
                    <tex:parm>
                        <xsl:value-of select="$sBasicPointSize"/>
                        <xsl:text>pt</xsl:text>
                    </tex:parm>
                </tex:cmd>
            </xsl:if>
            <xsl:variable name="sXLingPaperExample">
                <xsl:choose>
                    <xsl:when test="parent::td">
                        <xsl:text>XLingPaperexampleintable</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>XLingPaperexample</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$sXLingPaperExample='XLingPaperexample'">
                <tex:cmd name="raggedright"/>
                <xsl:call-template name="SetExampleKeepWithNext"/>
            </xsl:if>
            <xsl:if test="contains(@XeLaTeXSpecial,'pagebreak')">
                <tex:cmd name="pagebreak" gr="0" nl2="0"/>
            </xsl:if>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespaceexamples='yes'">
                <tex:spec cat="bg"/>
                <tex:cmd name="singlespacing" gr="0" nl2="1"/>
            </xsl:if>
            <tex:cmd name="{$sXLingPaperExample}" nl1="0" nl2="1">
                <tex:parm>
                    <xsl:value-of select="$contentLayoutInfo/exampleLayout/@indent-before"/>
                </tex:parm>
                <tex:parm>
                    <xsl:value-of select="$contentLayoutInfo/exampleLayout/@indent-after"/>
                </tex:parm>
                <tex:parm>
                    <xsl:value-of select="$iNumberWidth"/>
                    <xsl:text>em</xsl:text>
                </tex:parm>
                <tex:parm>
                    <xsl:call-template name="DoExampleNumber"/>
                </tex:parm>
                <tex:parm>
                    <xsl:call-template name="OutputTypeAttributes">
                        <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                    <xsl:call-template name="OutputTypeAttributesEnd">
                        <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
                    </xsl:call-template>
                </tex:parm>
            </tex:cmd>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacecontents='yes'">
                <tex:spec cat="eg"/>
            </xsl:if>
            <!--        </tex:env>-->
            <!--<tex:spec cat="esc"/>
            <tex:spec cat="esc"/>-->
            <!--            <tex:cmd name="vspace">
                <tex:parm><tex:cmd name="baselineskip"/></tex:parm>
            </tex:cmd>
-->
            <xsl:variable name="followingSibling" select="following-sibling::*[1]"/>
            <xsl:if test="name($followingSibling)='p' or name($followingSibling)='pc' or name($followingSibling)='table' or name($followingSibling)='chart' or name($followingSibling)='tree' or name($followingSibling)='interlinear-text' or parent::li and not(name($followingSibling)='example')">
                <tex:cmd name="vspace">
                    <tex:parm>
                        <xsl:value-of select="$sBasicPointSize"/>
                        <xsl:text>pt</xsl:text>
                    </tex:parm>
                </tex:cmd>
            </xsl:if>
        </tex:group>
        <xsl:if test="parent::li">
            <!-- need to reopen the li group we closed above before this example -->
            <xsl:call-template name="DoTypeForLI">
                <xsl:with-param name="myAncestorLists" select="$myAncestorLists"/>
                <xsl:with-param name="myEndnote" select="$myEndnote"/>
                <xsl:with-param name="bBracketsOnly" select="'Y'"/>
            </xsl:call-template>
            <tex:spec cat="bg"/>
        </xsl:if>
        <!--        <xsl:if test="not(following-sibling::example)">
            <tex:cmd name="vspace">
                <tex:parm>.5<tex:spec cat="esc"/>baselineskip</tex:parm>
            </tex:cmd>
        </xsl:if>
-->
    </xsl:template>
    <!--
      interlinearSource
   -->
    <xsl:template match="interlinearSource" mode="contents">
        <xsl:variable name="interlinearSourceStyleLayout" select="$contentLayoutInfo/interlinearSourceStyle"/>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="$interlinearSourceStyleLayout"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
            <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
            <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="$interlinearSourceStyleLayout"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!--
        definition
    -->
    <!--
    Not needed??
    <xsl:template match="example/definition">
        <fo:block>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
-->
    <!--
      exampleRef
    -->
    <xsl:template match="exampleRef">
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
        <xsl:call-template name="LinkAttributesBegin">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/exampleRefLinkLayout"/>
        </xsl:call-template>
        <xsl:if test="$contentLayoutInfo/exampleLayout/@referencesUseParens!='no'">
            <xsl:if test="not(@paren) or @paren='both' or @paren='initial'">(</xsl:if>
        </xsl:if>
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
        <xsl:if test="$contentLayoutInfo/exampleLayout/@referencesUseParens!='no'">
            <xsl:if test="not(@paren) or @paren='both' or @paren='final'">)</xsl:if>
        </xsl:if>
        <xsl:call-template name="LinkAttributesEnd">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/exampleRefLinkLayout"/>
        </xsl:call-template>
        <xsl:call-template name="DoExternalHyperRefEnd"/>
    </xsl:template>
    <!--
        figure
    -->
    <xsl:template match="figure">
        <xsl:choose>
            <xsl:when test="descendant::endnote">
                <!--  cannot have endnotes in floats... -->
                <tex:cmd name="vspace">
                    <tex:parm>
                        <xsl:value-of select="$sBasicPointSize"/>
                        <xsl:text>pt</xsl:text>
                    </tex:parm>
                </tex:cmd>
                <xsl:call-template name="DoFigure"/>
                <tex:cmd name="vspace">
                    <tex:parm>
                        <xsl:value-of select="$sBasicPointSize"/>
                        <xsl:text>pt</xsl:text>
                    </tex:parm>
                </tex:cmd>
            </xsl:when>
            <xsl:otherwise>
                <tex:spec cat="esc" nl1="1"/>
                <xsl:text>begin</xsl:text>
                <tex:spec cat="bg"/>
                <xsl:text>figure</xsl:text>
                <tex:spec cat="eg"/>
                <tex:spec cat="lsb"/>
                <xsl:choose>
                    <xsl:when test="@location='here'">htbp</xsl:when>
                    <xsl:when test="@location='bottomOfPage'">b</xsl:when>
                    <xsl:when test="@location='topOfPage'">t</xsl:when>
                </xsl:choose>
                <tex:spec cat="rsb" nl2="1"/>
                <xsl:call-template name="DoFigure"/>
                <tex:spec cat="esc" nl1="1"/>
                <xsl:text>end</xsl:text>
                <tex:spec cat="bg"/>
                <xsl:text>figure</xsl:text>
                <tex:spec cat="eg" nl2="1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        figureRef
    -->
    <xsl:template match="figureRef">
        <xsl:call-template name="LinkAttributesBegin">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/figureRefLinkLayout"/>
        </xsl:call-template>
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="@figure"/>
        </xsl:call-template>
        <xsl:call-template name="OutputAnyTextBeforeFigureRef"/>
        <xsl:apply-templates select="id(@figure)" mode="figure"/>
        <xsl:call-template name="DoInternalHyperlinkEnd"/>
        <xsl:call-template name="LinkAttributesEnd">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/figureRefLinkLayout"/>
        </xsl:call-template>
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
        <xsl:choose>
            <xsl:when test="descendant::endnote">
                <!--  cannot have endnotes in floats... -->
                <tex:cmd name="vspace">
                    <tex:parm>
                        <xsl:value-of select="$sBasicPointSize"/>
                        <xsl:text>pt</xsl:text>
                    </tex:parm>
                </tex:cmd>
                <xsl:call-template name="DoTableNumbered"/>
                <tex:cmd name="vspace">
                    <tex:parm>
                        <xsl:value-of select="$sBasicPointSize"/>
                        <xsl:text>pt</xsl:text>
                    </tex:parm>
                </tex:cmd>
            </xsl:when>
            <xsl:otherwise>
                <tex:spec cat="esc" nl1="1"/>
                <xsl:text>begin</xsl:text>
                <tex:spec cat="bg"/>
                <xsl:text>table</xsl:text>
                <tex:spec cat="eg"/>
                <tex:spec cat="lsb"/>
                <xsl:choose>
                    <xsl:when test="@location='here'">htbp</xsl:when>
                    <xsl:when test="@location='bottomOfPage'">bhp</xsl:when>
                    <xsl:when test="@location='topOfPage'">thp</xsl:when>
                </xsl:choose>
                <tex:spec cat="rsb" nl2="1"/>
                <xsl:call-template name="DoTableNumbered"/>
                <tex:spec cat="esc" nl1="1"/>
                <xsl:text>end</xsl:text>
                <tex:spec cat="bg"/>
                <xsl:text>table</xsl:text>
                <tex:spec cat="eg" nl2="1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        tablenumberedRef
    -->
    <xsl:template match="tablenumberedRef">
        <xsl:call-template name="LinkAttributesBegin">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/tablenumberedRefLinkLayout"/>
        </xsl:call-template>
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="@table"/>
        </xsl:call-template>
        <xsl:call-template name="OutputAnyTextBeforeTablenumberedRef"/>
        <xsl:apply-templates select="id(@table)" mode="tablenumbered"/>
        <xsl:call-template name="DoInternalHyperlinkEnd"/>
        <xsl:call-template name="LinkAttributesEnd">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/tablenumberedRefLinkLayout"/>
        </xsl:call-template>
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
        GLOSS
        =========================================================== -->
    <xsl:template match="gloss" mode="InMarker">
        <xsl:apply-templates select="self::*"/>
    </xsl:template>
    <xsl:template match="gloss">
        <!--        <tex:spec cat="bg"/>-->
        <xsl:variable name="language" select="key('LanguageID',@lang)"/>
        <xsl:variable name="sGlossContext">
            <xsl:call-template name="GetContextOfItem"/>
        </xsl:variable>
        <xsl:variable name="glossLayout" select="$contentLayoutInfo/glossLayout"/>
        <xsl:call-template name="HandleGlossTextBeforeOutside">
            <xsl:with-param name="glossLayout" select="$glossLayout"/>
            <xsl:with-param name="sGlossContext" select="$sGlossContext"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="$language"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:call-template name="HandleGlossTextBeforeAndFontOverrides">
            <xsl:with-param name="glossLayout" select="$glossLayout"/>
            <xsl:with-param name="sGlossContext" select="$sGlossContext"/>
        </xsl:call-template>
        <xsl:variable name="iCountBr" select="count(child::br)"/>
        <xsl:call-template name="DoEmbeddedBrBegin">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="DoEmbeddedBrEnd">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:call-template name="HandleGlossTextAfterAndFontOverrides">
            <xsl:with-param name="glossLayout" select="$glossLayout"/>
            <xsl:with-param name="sGlossContext" select="$sGlossContext"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="$language"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:call-template name="HandleGlossTextAfterOutside">
            <xsl:with-param name="glossLayout" select="$glossLayout"/>
            <xsl:with-param name="sGlossContext" select="$sGlossContext"/>
        </xsl:call-template>
        <!--        <tex:spec cat="eg"/>-->
    </xsl:template>
    <!-- ===========================================================
        LANGDATA
        =========================================================== -->
    <xsl:template match="langData" mode="InMarker">
        <xsl:apply-templates select="self::*"/>
    </xsl:template>
    <xsl:template match="langData">
        <tex:spec cat="bg"/>
        <xsl:variable name="language" select="key('LanguageID',@lang)"/>
        <xsl:variable name="sLangDataContext">
            <xsl:call-template name="GetContextOfItem"/>
        </xsl:variable>
        <xsl:variable name="langDataLayout" select="$contentLayoutInfo/langDataLayout"/>
        <xsl:call-template name="HandleLangDataTextBeforeOutside">
            <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
            <xsl:with-param name="sLangDataContext" select="$sLangDataContext"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="$language"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:call-template name="HandleLangDataTextBeforeAndFontOverrides">
            <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
            <xsl:with-param name="sLangDataContext" select="$sLangDataContext"/>
        </xsl:call-template>
        <xsl:variable name="iCountBr" select="count(child::br)"/>
        <xsl:call-template name="DoEmbeddedBrBegin">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="DoEmbeddedBrEnd">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:call-template name="HandleLangDataTextAfterAndFontOverrides">
            <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
            <xsl:with-param name="sLangDataContext" select="$sLangDataContext"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="$language"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:call-template name="HandleLangDataTextAfterOutside">
            <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
            <xsl:with-param name="sLangDataContext" select="$sLangDataContext"/>
        </xsl:call-template>
        <tex:spec cat="eg"/>
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
        <xsl:param name="sTeXFootnoteKind" select="'footnote'"/>
        <xsl:call-template name="DoEndnote">
            <xsl:with-param name="sTeXFootnoteKind" select="$sTeXFootnoteKind"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      endnoteRef
      -->
    <xsl:template match="endnoteRef">
        <xsl:choose>
            <xsl:when test="ancestor::endnote">
                <xsl:call-template name="DoInternalHyperlinkBegin">
                    <xsl:with-param name="sName" select="@note"/>
                </xsl:call-template>
                <xsl:call-template name="LinkAttributesBegin">
                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/endnoteRefLinkLayout"/>
                </xsl:call-template>
                <xsl:apply-templates select="id(@note)" mode="endnote"/>
                <xsl:call-template name="LinkAttributesEnd">
                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/endnoteRefLinkLayout"/>
                </xsl:call-template>
                <xsl:call-template name="DoInternalHyperlinkEnd"/>
            </xsl:when>
            <xsl:otherwise>
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
                <tex:cmd name="footnote">
                    <tex:opt>
                        <xsl:value-of select="$sFootnoteNumber"/>
                    </tex:opt>
                    <tex:parm>
                        <xsl:variable name="endnoteRefLayout" select="$contentLayoutInfo/endnoteRefLayout"/>
                        <tex:group>
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
                            <xsl:call-template name="OutputFontAttributesEnd">
                                <xsl:with-param name="language" select="$endnoteRefLayout"/>
                            </xsl:call-template>
                        </tex:group>
                        <xsl:call-template name="DoInternalHyperlinkBegin">
                            <xsl:with-param name="sName" select="@note"/>
                        </xsl:call-template>
                        <xsl:call-template name="LinkAttributesBegin">
                            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/endnoteRefLinkLayout"/>
                        </xsl:call-template>
                        <xsl:apply-templates select="id(@note)" mode="endnote"/>
                        <xsl:call-template name="LinkAttributesEnd">
                            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/endnoteRefLinkLayout"/>
                        </xsl:call-template>
                        <xsl:call-template name="DoInternalHyperlinkEnd"/>
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
                        <xsl:if test="string-length($endnoteRefLayout/@textafter) &gt; 0">
                            <tex:group>
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="$endnoteRefLayout"/>
                                </xsl:call-template>
                                <xsl:value-of select="$endnoteRefLayout/@textafter"/>
                                <xsl:call-template name="OutputFontAttributesEnd">
                                    <xsl:with-param name="language" select="$endnoteRefLayout"/>
                                </xsl:call-template>
                            </tex:group>
                        </xsl:if>
                    </tex:parm>
                </tex:cmd>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
      endnotes
   -->
    <xsl:template match="endnotes">
        <xsl:if test="$backMatterLayoutInfo/useEndNotesLayout">
            <xsl:choose>
                <xsl:when test="$chapters">
                    <xsl:call-template name="DoPageBreakFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/useEndNotesLayout"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoEndnotes"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="DoEndnotes"/>
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
    <xsl:template match="citation">
        <xsl:variable name="refer" select="id(@ref)"/>
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="@ref"/>
        </xsl:call-template>
        <xsl:call-template name="LinkAttributesBegin">
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
        <xsl:call-template name="LinkAttributesEnd">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/citationLinkLayout"/>
        </xsl:call-template>
        <xsl:call-template name="DoInternalHyperlinkEnd"/>
    </xsl:template>
    <!--
      glossary
      -->
    <xsl:template match="glossary">
        <xsl:variable name="iPos" select="count(preceding-sibling::glossary) + 1"/>
        <xsl:choose>
            <xsl:when test="$bIsBook">
                <xsl:call-template name="DoPageBreakFormatInfo">
                    <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/glossaryLayout"/>
                </xsl:call-template>
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
                <xsl:call-template name="DoPageBreakFormatInfo">
                    <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/indexLayout"/>
                </xsl:call-template>
                <xsl:call-template name="DoIndex"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoIndex"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        interlinearRefCitation
    -->
    <xsl:template match="interlinearRefCitation">
        <xsl:variable name="interlinearSourceStyleLayout" select="$contentLayoutInfo/interlinearSourceStyle"/>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="$interlinearSourceStyleLayout"/>
        </xsl:call-template>
        <xsl:if test="not(@bracket) or @bracket='both' or @bracket='initial'">
            <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="LinkAttributesBegin">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/interlinearRefLinkLayout"/>
        </xsl:call-template>
        <xsl:call-template name="DoInterlinearRefCitation">
            <xsl:with-param name="sRef" select="@textref"/>
        </xsl:call-template>
        <xsl:call-template name="LinkAttributesEnd">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/interlinearRefLinkLayout"/>
        </xsl:call-template>
        <xsl:if test="not(@bracket) or @bracket='both' or @bracket='final'">
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$interlinearSourceStyleLayout"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="$interlinearSourceStyleLayout"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        backMatter
    -->
    <xsl:template match="backMatter">
        <xsl:if test="$backMatterLayoutInfo/titleHeaderFooterPageStyles">
            <tex:cmd name="pagestyle">
                <tex:parm>backmattertitle</tex:parm>
            </tex:cmd>
        </xsl:if>
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
                <xsl:call-template name="DoPageBreakFormatInfo">
                    <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/referencesTitleLayout"/>
                </xsl:call-template>
                <xsl:call-template name="DoReferences"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoReferences"/>
            </xsl:otherwise>
        </xsl:choose>
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
                <tex:group>
                    <xsl:call-template name="DoInternalHyperlinkBegin">
                        <xsl:with-param name="sName" select="@abbr"/>
                    </xsl:call-template>
                    <xsl:call-template name="LinkAttributesBegin">
                        <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/sectionRefLinkLayout"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',../@lang)"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputAbbrTerm">
                        <xsl:with-param name="abbr" select="id(@abbr)"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputFontAttributesEnd">
                        <xsl:with-param name="language" select="key('LanguageID',../@lang)"/>
                    </xsl:call-template>
                    <xsl:call-template name="LinkAttributesEnd">
                        <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/sectionRefLinkLayout"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoInternalHyperlinkEnd"/>
                </tex:group>
            </xsl:otherwise>
        </xsl:choose>
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
            <xsl:when test="count(//chapter)=0 and count(//section1)=1 and count(//section1/section2)=0">
                <!-- if there are no chapters and there is but one section1 (with no subsections), there's no need to have a number so don't  -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="multiple" count="section1 | section2 | section3 | section4 | section5 | section6" format="1.1"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$contentLayoutInfo/exampleLayout/@AddPeriodAfterFinalDigit='yes' and name()!='sectionRef'">
            <xsl:text>. </xsl:text>
        </xsl:if>
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
            <xsl:when test="$bIsBook">
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
            <xsl:when test="$bIsBook and $styleSheetFigureNumberLayout/@showchapternumber='yes'">
                <xsl:for-each select="ancestor::chapter | ancestor::appendix | ancestor::chapterBeforePart">
                    <xsl:call-template name="OutputChapterNumber">
                        <xsl:with-param name="fIgnoreTextAfterLetter" select="'Y'"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:value-of select="$styleSheetFigureNumberLayout/@textbetweenchapterandnumber"/>
                <xsl:number level="any" count="figure" from="chapter | appendix | chapterBeforePart" format="{$styleSheetFigureNumberLayout/@format}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="any" count="figure" format="{$styleSheetFigureNumberLayout/@format}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        tablenumbered
    -->
    <xsl:template mode="tablenumbered" match="*">
        <xsl:choose>
            <xsl:when test="$bIsBook and $styleSheetTableNumberedNumberLayout/@showchapternumber='yes'">
                <xsl:for-each select="ancestor::chapter | ancestor::appendix | ancestor::chapterBeforePart">
                    <xsl:call-template name="OutputChapterNumber">
                        <xsl:with-param name="fIgnoreTextAfterLetter" select="'Y'"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:value-of select="$styleSheetTableNumberedNumberLayout/@textbetweenchapterandnumber"/>
                <xsl:number level="any" count="tablenumbered" from="chapter | appendix | chapterBeforePart" format="{$styleSheetTableNumberedNumberLayout/@format}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="any" count="tablenumbered" format="{$styleSheetTableNumberedNumberLayout/@format}"/>
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
        <xsl:number level="single" count="refWork[@id=//citation/@ref][refDate=$date]" format="a"/>
    </xsl:template>
    <!--  ignore these -->
    <xsl:template match="publisherStyleSheetName | publisherStyleSheetReferencesName | publisherStyleSheetVersion | publisherStyleSheetReferencesVersion |   pageWidth | pageHeight | pageTopMargin | pageBottomMargin | pageInsideMargin | pageOutsideMargin | headerMargin | footerMargin | paragraphIndent | blockQuoteIndent | defaultFontFamily | basicPointSize |  footnotePointSize | magnificationFactor"/>
    <xsl:template match="interlinearSource"/>
    <!-- ===========================================================
      NAMED TEMPLATES
      =========================================================== -->
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
        <xsl:if test="$bodyLayoutInfo/headerFooterPageStyles">
            <tex:cmd name="pagestyle">
                <tex:parm>
                    <xsl:choose>
                        <xsl:when test="$backMatterLayoutInfo/headerFooterPageStyles">backmatter</xsl:when>
                        <xsl:otherwise>body</xsl:otherwise>
                    </xsl:choose>
                </tex:parm>
            </tex:cmd>
        </xsl:if>
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
                <xsl:when test="name(.)='useEndNotesLayout'">
                    <xsl:apply-templates select="$backMatter/endnotes"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--
                  DoContents
                  -->
    <xsl:template name="DoContents">
        <xsl:param name="bIsBook" select="'Y'"/>
        <tex:cmd name="XLingPapertableofcontents" gr="0" nl2="0"/>
        <xsl:choose>
            <xsl:when test="$bIsBook='Y'">
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id" select="'rXLingPapContents'"/>
                    <xsl:with-param name="sTitle">
                        <xsl:call-template name="OutputContentsLabel"/>
                    </xsl:with-param>
                    <xsl:with-param name="bIsBook" select="'Y'"/>
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/contentsLayout"/>
                    <xsl:with-param name="sFirstPageStyle" select="'frontmatterfirstpage'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputFrontOrBackMatterTitle">
                    <xsl:with-param name="id" select="'rXLingPapContents'"/>
                    <xsl:with-param name="sTitle">
                        <xsl:call-template name="OutputContentsLabel"/>
                    </xsl:with-param>
                    <xsl:with-param name="bIsBook" select="'N'"/>
                    <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/contentsLayout"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacecontents='yes'">
            <tex:spec cat="bg"/>
            <tex:cmd name="singlespacing" gr="0" nl2="1"/>
        </xsl:if>
        <xsl:call-template name="DoFrontMatterContentsPerLayout"/>
        <!-- part -->
        <xsl:apply-templates select="//lingPaper/part" mode="contents"/>
        <!--                 chapter, no parts -->
        <xsl:apply-templates select="//lingPaper/chapter" mode="contents"/>
        <!-- section, no chapters -->
        <xsl:apply-templates select="//lingPaper/section1" mode="contents"/>
        <xsl:call-template name="DoBackMatterContentsPerLayout"/>
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacecontents='yes'">
            <tex:spec cat="eg"/>
        </xsl:if>
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
        DoEndnotes
    -->
    <xsl:template name="DoEndnote">
        <xsl:param name="sTeXFootnoteKind"/>
        <xsl:choose>
            <xsl:when test="$backMatterLayoutInfo/useEndNotesLayout">
                <xsl:call-template name="DoFootnoteNumberInText"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="ancestor::td[@rowspan &gt; 0] and $sTeXFootnoteKind!='footnotetext'">
                        <tex:cmd name="footnotemark">
                            <tex:opt>
                                <xsl:call-template name="DoFootnoteNumberInText"/>
                            </tex:opt>
                        </tex:cmd>
                    </xsl:when>
                    <xsl:when test="ancestor::lineGroup and $sTeXFootnoteKind!='footnotetext'">
                        <tex:cmd name="footnotemark">
                            <tex:opt>
                                <xsl:call-template name="DoFootnoteNumberInText"/>
                            </tex:opt>
                        </tex:cmd>
                    </xsl:when>
                    <xsl:when test="ancestor::free and $sTeXFootnoteKind!='footnotetext'">
                        <tex:cmd name="footnotemark">
                            <tex:opt>
                                <xsl:call-template name="DoFootnoteNumberInText"/>
                            </tex:opt>
                        </tex:cmd>
                    </xsl:when>
                    <xsl:otherwise>
                        <tex:cmd name="{$sTeXFootnoteKind}">
                            <tex:opt>
                                <xsl:call-template name="DoFootnoteNumberInText"/>
                            </tex:opt>
                            <tex:parm>
                                <tex:group>
                                    <tex:spec cat="esc"/>
                                    <xsl:text>leftskip0pt</xsl:text>
                                    <tex:spec cat="esc"/>
                                    <xsl:text>parindent1em</xsl:text>
                                    <xsl:call-template name="DoInternalTargetBegin">
                                        <xsl:with-param name="sName" select="@id"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="DoInternalTargetEnd"/>
                                    <xsl:apply-templates/>
                                </tex:group>
                            </tex:parm>
                        </tex:cmd>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      DoEndnotes
   -->
    <xsl:template name="DoEndnotes">
        <xsl:call-template name="OutputBackMatterItemTitle">
            <xsl:with-param name="sId" select="'rXLingPapEndnotes'"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputEndnotesLabel"/>
            </xsl:with-param>
            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/useEndNotesLayout"/>
        </xsl:call-template>
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single'">
            <xsl:choose>
                <xsl:when test="$lineSpacing/@singlespaceendnotes='yes'">
                    <tex:cmd name="singlespacing" gr="0" nl2="1"/>
                </xsl:when>
                <xsl:when test="$sLineSpacing='double'">
                    <tex:cmd name="doublespacing" gr="0" nl2="1"/>
                </xsl:when>
                <xsl:when test="$sLineSpacing='spaceAndAHalf'">
                    <tex:cmd name="onehalfspacing" gr="0" nl2="1"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:for-each select="//endnote">
            <tex:cmd name="indent" gr="0" sp="1"/>
            <xsl:if test="$backMatterLayoutInfo/useEndNotesLayout">
                <xsl:call-template name="DoInternalTargetBegin">
                    <xsl:with-param name="sName" select="@id"/>
                </xsl:call-template>
                <xsl:call-template name="DoInternalTargetEnd"/>
            </xsl:if>
            <!--            <tex:spec cat="esc"/>-->
            <!--       <xsl:text>footnotesize</xsl:text>
            <tex:spec cat="bg"/>
            <tex:spec cat="esc"/>
            <xsl:text>textsuperscript</xsl:text> -->
            <tex:spec cat="bg"/>
            <xsl:apply-templates select="*[1]" mode="endnote-content"/>
            <tex:spec cat="eg"/>
            <xsl:apply-templates select="*[position() &gt; 1]"/>
            <tex:cmd name="par" nl2="1"/>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoExampleNumber
    -->
    <xsl:template name="DoExampleNumber">
        <xsl:variable name="sIsoCode">
            <xsl:call-template name="GetISOCode"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($sIsoCode) &gt; 0">
                <tex:cmd name="raisebox">
                    <tex:parm>
                        <xsl:text>-.9</xsl:text>
                        <tex:cmd name="baselineskip" gr="0" nl2="0"/>
                    </tex:parm>
                    <tex:parm>
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
                                <xsl:text>(</xsl:text>
                                <xsl:call-template name="GetExampleNumber">
                                    <xsl:with-param name="example" select="."/>
                                </xsl:call-template>
                                <xsl:text>)</xsl:text>
                                <xsl:call-template name="DoInternalTargetEnd"/>
                                <tex:spec cat="esc"/>
                                <tex:spec cat="esc"/>
                                <tex:cmd name="small">
                                    <tex:parm>
                                        <xsl:text>[</xsl:text>
                                        <xsl:value-of select="$sIsoCode"/>
                                        <xsl:text>]</xsl:text>
                                    </tex:parm>
                                </tex:cmd>
                            </tex:parm>
                        </tex:cmd>
                    </tex:parm>
                </tex:cmd>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoInternalTargetBegin">
                    <xsl:with-param name="sName" select="@num"/>
                </xsl:call-template>
                <xsl:text>(</xsl:text>
                <xsl:call-template name="GetExampleNumber">
                    <xsl:with-param name="example" select="."/>
                </xsl:call-template>
                <xsl:text>)</xsl:text>
                <xsl:call-template name="DoInternalTargetEnd"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoFigure
    -->
    <xsl:template name="DoFigure">
        <xsl:call-template name="DoInternalTargetBegin">
            <xsl:with-param name="sName" select="@id"/>
        </xsl:call-template>
        <xsl:call-template name="DoInternalTargetEnd"/>
        <xsl:call-template name="CreateAddToContents">
            <xsl:with-param name="id" select="@id"/>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="@align='center'">
                <tex:spec cat="esc"/>
                <xsl:text>centering </xsl:text>
            </xsl:when>
            <xsl:when test="@align='right'">
                <tex:spec cat="esc"/>
                <xsl:text>raggedleft</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="DoType">
            <xsl:with-param name="type" select="@type"/>
        </xsl:call-template>
        <xsl:if test="$contentLayoutInfo/figureLayout/@captionLocation='before' or not($contentLayoutInfo/figureLayout) and $lingPaper/@figureLabelAndCaptionLocation='before'">
            <xsl:call-template name="OutputFigureLabelAndCaption"/>
            <tex:spec cat="esc"/>
            <tex:spec cat="esc"/>
            <tex:spec cat="lsb"/>
            <xsl:choose>
                <xsl:when test="string-length($sSpaceBetweenFigureAndCaption) &gt; 0">
                    <xsl:value-of select="$sSpaceBetweenFigureAndCaption"/>
                </xsl:when>
                <xsl:otherwise>0pt</xsl:otherwise>
            </xsl:choose>
            <tex:spec cat="rsb"/>
        </xsl:if>
        <tex:cmd name="leavevmode" gr="0" nl2="1"/>
        <xsl:apply-templates select="*[name()!='caption' and name()!='shortCaption']"/>
        <xsl:call-template name="DoTypeEnd">
            <xsl:with-param name="type" select="@type"/>
        </xsl:call-template>
        <xsl:if test="$contentLayoutInfo/figureLayout/@captionLocation='after' or not($contentLayoutInfo/figureLayout) and $lingPaper/@figureLabelAndCaptionLocation='after'">
            <xsl:for-each select="chart/*">
                <xsl:if test="position()=last() and name()='img'">
                    <tex:spec cat="esc"/>
                    <tex:spec cat="esc"/>
                </xsl:if>
            </xsl:for-each>
            <tex:spec cat="lsb"/>
            <xsl:choose>
                <xsl:when test="string-length($sSpaceBetweenFigureAndCaption) &gt; 0">
                    <xsl:value-of select="$sSpaceBetweenFigureAndCaption"/>
                </xsl:when>
                <xsl:otherwise>0pt</xsl:otherwise>
            </xsl:choose>
            <tex:spec cat="rsb"/>
            <xsl:call-template name="OutputFigureLabelAndCaption"/>
            <tex:spec cat="esc"/>
            <tex:spec cat="esc"/>
        </xsl:if>
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
      DoFootnoteNumberInText
   -->
    <xsl:template name="DoFootnoteNumberInText">
        <xsl:choose>
            <xsl:when test="$backMatterLayoutInfo/useEndNotesLayout">
                <xsl:call-template name="DoInternalHyperlinkBegin">
                    <xsl:with-param name="sName" select="@id"/>
                </xsl:call-template>
                <xsl:call-template name="LinkAttributesBegin">
                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/endnoteRefLinkLayout"/>
                </xsl:call-template>
                <tex:spec cat="esc"/>
                <xsl:text>footnotesize</xsl:text>
                <tex:spec cat="bg"/>
                <tex:spec cat="esc"/>
                <xsl:text>textsuperscript</xsl:text>
                <tex:spec cat="bg"/>
                <xsl:call-template name="DoFootnoteNumberInTextValue"/>
                <tex:spec cat="eg"/>
                <tex:spec cat="eg"/>
                <xsl:call-template name="LinkAttributesEnd">
                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/endnoteRefLinkLayout"/>
                </xsl:call-template>
                <xsl:call-template name="DoInternalHyperlinkEnd"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoFootnoteNumberInTextValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
      DoFootnoteNumberInTextValue
   -->
    <xsl:template name="DoFootnoteNumberInTextValue">
        <xsl:choose>
            <xsl:when test="$bIsBook">
                <xsl:number level="any" count="endnote[not(ancestor::author)] | endnoteRef[not(ancestor::endnote)]" from="chapter"/>
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
        <xsl:if test="string-length($layoutInfo/@textbefore) &gt; 0">
            <xsl:value-of select="$layoutInfo/@textbefore"/>
        </xsl:if>
    </xsl:template>
    <!--  
        DoFrontMatterFormatInfoBegin
    -->
    <xsl:template name="DoFrontMatterFormatInfoBegin">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="originalContext"/>
        <xsl:if test="not($layoutInfo/../@beginsparagraph='yes')">
            <xsl:call-template name="DoSpaceBefore">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$layoutInfo/@textalign='start' or $layoutInfo/@textalign='left'">
            <tex:cmd name="noindent" gr="0" nl2="1"/>
        </xsl:if>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="$layoutInfo"/>
            <xsl:with-param name="originalContext" select="$originalContext"/>
        </xsl:call-template>
        <xsl:if test="string-length($layoutInfo/@textalign) &gt; 0">
            <xsl:call-template name="DoTextAlign">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        DoFrontMatterFormatInfoEnd
    -->
    <xsl:template name="DoFrontMatterFormatInfoEnd">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="originalContext"/>
        <xsl:param name="contentOfThisElement"/>
        <xsl:if test="string-length($layoutInfo/@textalign) &gt; 0">
            <xsl:call-template name="DoTextAlignEnd">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                <xsl:with-param name="contentForThisElement" select="$contentOfThisElement"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="$layoutInfo"/>
            <xsl:with-param name="originalContext" select="$originalContext"/>
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
        <tex:cmd name="pagenumbering" nl2="1">
            <tex:parm>roman</tex:parm>
        </tex:cmd>
        <xsl:if test="$frontMatterLayoutInfo/headerFooterPageStyles">
            <tex:cmd name="pagestyle">
                <tex:parm>frontmattertitle</tex:parm>
            </tex:cmd>
        </xsl:if>
        <xsl:for-each select="$frontMatterLayoutInfo/*">
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
    </xsl:template>
    <!--  
        DoBookFrontMatterPagedStuffPerLayout
    -->
    <xsl:template name="DoBookFrontMatterPagedStuffPerLayout">
        <xsl:param name="frontMatter"/>
        <xsl:if test="$frontMatterLayoutInfo/headerFooterPageStyles">
            <tex:cmd name="cleardoublepage" gr="0" nl2="1"/>
            <tex:cmd name="pagestyle">
                <tex:parm>frontmatter</tex:parm>
            </tex:cmd>
            <tex:cmd name="thispagestyle">
                <tex:parm>frontmatterfirstpage</tex:parm>
            </tex:cmd>
        </xsl:if>
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
        DoBookMark
    -->
    <xsl:template name="DoBookMark">
        <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@showbookmarks!='no'">
            <xsl:apply-templates select="." mode="bookmarks"/>
        </xsl:if>
    </xsl:template>
    <!--  
      DoBackMatterItemNewPage
   -->
    <xsl:template name="DoBackMatterItemNewPage">
        <xsl:param name="id"/>
        <xsl:param name="sTitle"/>
        <xsl:param name="layoutInfo"/>
        <xsl:call-template name="DoPageBreakFormatInfo">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="sTitle" select="$sTitle"/>
            <xsl:with-param name="bIsBook" select="'Y'"/>
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            <xsl:with-param name="sFirstPageStyle" select="'backmatterfirstpage'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <!--  
      DoFrontMatterItemNewPage
   -->
    <xsl:template name="DoFrontMatterItemNewPage">
        <xsl:param name="id"/>
        <xsl:param name="sTitle"/>
        <xsl:param name="layoutInfo"/>
        <xsl:call-template name="DoPageBreakFormatInfo">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFrontOrBackMatterTitle">
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="sTitle" select="$sTitle"/>
            <xsl:with-param name="bIsBook" select="'Y'"/>
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            <xsl:with-param name="sFirstPageStyle" select="'frontmatterfirstpage'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <!--  
        DoFrontMatterPerLayout
    -->
    <xsl:template name="DoFrontMatterPerLayout">
        <xsl:param name="frontMatter"/>
        <tex:cmd name="thispagestyle" nl2="1">
            <tex:parm>fancyfirstpage</tex:parm>
        </tex:cmd>
        <xsl:for-each select="$frontMatterLayoutInfo/*">
            <xsl:choose>
                <xsl:when test="name(.)='titleLayout'">
                    <xsl:apply-templates select="$frontMatter/title"/>
                </xsl:when>
                <xsl:when test="name(.)='subtitleLayout'">
                    <xsl:apply-templates select="$frontMatter/subtitle"/>
                </xsl:when>
                <xsl:when test="name(.)='authorLayout'">
                    <xsl:variable name="iPos" select="count(preceding-sibling::authorLayout) + 1"/>
                    <xsl:apply-templates select="$frontMatter/author[$iPos]"/>
                </xsl:when>
                <xsl:when test="name(.)='affiliationLayout'">
                    <xsl:variable name="iPos" select="count(preceding-sibling::affiliationLayout) + 1"/>
                    <xsl:apply-templates select="$frontMatter/affiliation[$iPos]"/>
                </xsl:when>
                <xsl:when test="name(.)='emailAddressLayout'">
                    <xsl:variable name="iPos" select="count(preceding-sibling::emailAddressLayout) + 1"/>
                    <xsl:apply-templates select="$frontMatter/emailAddress[$iPos]"/>
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
                <xsl:when test="name(.)='contentsLayout'">
                    <xsl:apply-templates select="$frontMatter/contents" mode="paper"/>
                </xsl:when>
                <xsl:when test="name(.)='acknowledgementsLayout'">
                    <xsl:apply-templates select="$frontMatter/acknowledgements" mode="paper"/>
                </xsl:when>
                <xsl:when test="name(.)='abstractLayout'">
                    <xsl:apply-templates select="$frontMatter/abstract" mode="paper"/>
                </xsl:when>
                <xsl:when test="name(.)='prefaceLayout'">
                    <xsl:apply-templates select="$frontMatter/preface" mode="paper"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
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
      DoHeaderFooterItem
   -->
    <xsl:template name="DoHeaderFooterItem">
        <xsl:param name="item"/>
        <xsl:param name="originalContext"/>
        <xsl:param name="sOddEven"/>
        <tex:cmd nl2="1">
            <xsl:attribute name="name">
                <xsl:text>fancy</xsl:text>
                <xsl:choose>
                    <xsl:when test="parent::header">head</xsl:when>
                    <xsl:otherwise>foot</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <tex:opt>
                <xsl:choose>
                    <xsl:when test="name()='leftHeaderFooterItem'">L</xsl:when>
                    <xsl:when test="name()='rightHeaderFooterItem'">R</xsl:when>
                    <xsl:otherwise>C</xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$sOddEven"/>
            </tex:opt>
            <tex:parm>
                <!-- the content of this part of the header/footer -->
                <tex:parm>
                    <xsl:for-each select="*">
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="."/>
                            <xsl:with-param name="originalContext" select="."/>
                        </xsl:call-template>
                        <xsl:call-template name="DoFormatLayoutInfoTextBefore">
                            <xsl:with-param name="layoutInfo" select="."/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="name()='chapterTitle'">
                                <tex:cmd name="leftmark" gr="0"/>
                            </xsl:when>
                            <xsl:when test="name()='pageNumber'">
                                <tex:cmd name="thepage" gr="0"/>
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
                                        <!--                              <xsl:apply-templates select="//frontMatter//title/child::node()[name()!='endnote']" mode="contentOnly"/>-->
                                        <xsl:apply-templates select="//frontMatter//title/child::node()[name()!='endnote']"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="name()='sectionTitle'">
                                <tex:cmd name="rightmark" gr="0"/>
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
                        <xsl:call-template name="OutputFontAttributesEnd">
                            <xsl:with-param name="language" select="."/>
                            <xsl:with-param name="originalContext" select="."/>
                        </xsl:call-template>
                    </xsl:for-each>
                </tex:parm>
            </tex:parm>
        </tex:cmd>
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
        <!-- Need to check on two column mode; looks like we allow it via a parameter in OutputFrontOrBackMatterTitle but not in OutputBackMatterItemTitle
            do we want to add two column as a choice in indexLayout??
    <xsl:if test="$chapters">
            <!-\- close off all non-two column initial material; the \twocolumn[span stuff] command needs to end here -\->
            <tex:spec cat="rsb"/>
        </xsl:if>
-->
        <!-- now process the contents of this index -->
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespaceindexes='yes'">
            <tex:spec cat="bg"/>
            <tex:cmd name="singlespacing" gr="0" nl2="1"/>
        </xsl:if>
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
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespaceindexes='yes'">
            <tex:spec cat="eg"/>
        </xsl:if>
    </xsl:template>
    <!--  
        DoInterlinearRefCitation
    -->
    <xsl:template name="DoInterlinearRefCitation">
        <xsl:param name="sRef"/>
        <tex:group>
            <xsl:call-template name="DoInternalHyperlinkBegin">
                <xsl:with-param name="sName" select="$sRef"/>
            </xsl:call-template>
            <xsl:call-template name="LinkAttributesBegin">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/interlinearRefLinkLayout"/>
            </xsl:call-template>
            <xsl:variable name="interlinear" select="key('InterlinearReferenceID',$sRef)"/>
            <xsl:if test="not(@lineNumberOnly) or @lineNumberOnly!='yes'">
                <xsl:value-of select="$interlinear/../textInfo/shortTitle"/>
                <xsl:text>:</xsl:text>
            </xsl:if>
            <xsl:value-of select="count($interlinear/preceding-sibling::interlinear) + 1"/>
            <xsl:call-template name="LinkAttributesEnd">
                <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/interlinearRefLinkLayout"/>
            </xsl:call-template>
            <xsl:call-template name="DoInternalHyperlinkEnd"/>
        </tex:group>
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
        <xsl:param name="bUseClearEmptyDoublePage" select="'N'"/>
        <xsl:choose>
            <xsl:when test="$layoutInfo/descendant-or-self::*/@startonoddpage='yes'">
                <xsl:choose>
                    <xsl:when test="$bUseClearEmptyDoublePage='Y'">
                        <tex:cmd name="clearemptydoublepage" gr="0" nl2="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <tex:cmd name="cleardoublepage" gr="0" nl2="1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$layoutInfo/descendant-or-self::*/@pagebreakbefore='yes'">
                <tex:cmd name="clearpage" gr="0" nl2="1"/>
            </xsl:when>
        </xsl:choose>
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
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacereferences='yes'">
                <tex:spec cat="bg"/>
                <tex:cmd name="singlespacing" gr="0" nl2="1"/>
            </xsl:if>
            <tex:cmd name="raggedright" gr="0" nl2="1"/>
            <!--            <xsl:for-each select="$authors">
                <xsl:variable name="works" select="refWork[@id=//citation[not(ancestor::comment)]/@ref]"/>
                <xsl:for-each select="$works">
            -->
            <xsl:call-template name="DoRefAuthors"/>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacereferences='yes'">
                <tex:spec cat="eg"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        DoRefWorks
    -->
    <xsl:template name="DoRefWorks">
        <xsl:variable name="thisAuthor" select="."/>
        <xsl:variable name="works" select="refWork[@id=$citations[not(ancestor::comment)][not(ancestor::refWork) or ancestor::refWork[@id=$citations[not(ancestor::refWork)]/@ref]]/@ref] | $refWorks[@id=saxon:node-set($collOrProcVolumesToInclude)/refWork/@id][parent::refAuthor=$thisAuthor]"/>
        <xsl:for-each select="$works">
            <tex:cmd name="hangindent" gr="0"/>
            <xsl:value-of select="$referencesLayoutInfo/@hangingindentsize"/>
            <tex:cmd name="relax" gr="0" nl2="1"/>
            <tex:cmd name="hangafter" gr="0"/>
            <xsl:text>1</xsl:text>
            <tex:cmd name="relax" gr="0" nl2="1"/>
            <xsl:variable name="work" select="."/>
            <xsl:if test="$referencesLayoutInfo/@defaultfontsize">
                <xsl:call-template name="HandleFontSize">
                    <xsl:with-param name="sSize" select="$referencesLayoutInfo/@defaultfontsize"/>
                    <xsl:with-param name="language" select="''"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="DoAuthorLayout">
                <xsl:with-param name="referencesLayoutInfo" select="$referencesLayoutInfo"/>
                <xsl:with-param name="work" select="$work"/>
                <xsl:with-param name="works" select="$works"/>
                <xsl:with-param name="iPos" select="position()"/>
            </xsl:call-template>
            <xsl:apply-templates select="book | collection | dissertation | article | fieldNotes | ms | paper | proceedings | thesis | webPage"/>
            <tex:cmd name="par" gr="0" nl2="1"/>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacereferencesbetween='no'">
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
                <tex:cmd name="vspace">
                    <tex:parm>
                        <xsl:value-of select="$sExtraSpace"/>
                        <xsl:text>pt</xsl:text>
                    </tex:parm>
                </tex:cmd>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoSection
    -->
    <xsl:template name="DoSection">
        <xsl:param name="layoutInfo"/>
        <xsl:variable name="formatTitleLayoutInfo" select="$layoutInfo/*[name()!='numberLayout'][1]"/>
        <xsl:variable name="numberLayoutInfo" select="$layoutInfo/numberLayout"/>
        <xsl:call-template name="DoType"/>
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
        <xsl:call-template name="DoTypeEnd"/>
    </xsl:template>
    <!--  
      DoSectionAsTitle
   -->
    <xsl:template name="DoSectionAsTitle">
        <xsl:param name="formatTitleLayoutInfo"/>
        <xsl:param name="numberLayoutInfo"/>
        <tex:group>
            <xsl:if test="contains(key('TypeID',@type)/@XeLaTeXSpecial,'pagebreak')">
                <tex:cmd name="pagebreak" gr="0" nl2="0"/>
            </xsl:if>
            <xsl:call-template name="DoTitleNeedsSpace"/>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
            </xsl:call-template>
            <xsl:call-template name="DoInternalTargetBegin">
                <xsl:with-param name="sName" select="@id"/>
            </xsl:call-template>
            <xsl:call-template name="OutputSectionNumber">
                <xsl:with-param name="layoutInfo" select="$numberLayoutInfo"/>
            </xsl:call-template>
            <xsl:call-template name="OutputSectionTitle"/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
            </xsl:call-template>
            <xsl:call-template name="DoInternalTargetEnd"/>
            <xsl:variable name="contentForThisElement">
                <xsl:call-template name="OutputSectionNumber">
                    <xsl:with-param name="layoutInfo" select="$numberLayoutInfo"/>
                </xsl:call-template>
                <xsl:call-template name="OutputSectionTitle"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="DoTitleFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
            <!-- put title in marker so it can show up in running header -->
            <tex:cmd name="markright" nl2="1">
                <tex:parm>
                    <xsl:call-template name="DoSecTitleRunningHeader"/>
                </tex:parm>
            </tex:cmd>
            <xsl:call-template name="CreateAddToContents">
                <xsl:with-param name="id" select="@id"/>
            </xsl:call-template>
            <xsl:call-template name="DoBookMark"/>
        </tex:group>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoNotBreakHere"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
        </xsl:call-template>
        <xsl:call-template name="DoNotBreakHere"/>
        <xsl:apply-templates select="child::node()[name()!='secTitle']"/>
    </xsl:template>
    <!--  
      DoSectionBeginsParagraph
   -->
    <xsl:template name="DoSectionBeginsParagraph">
        <xsl:param name="formatTitleLayoutInfo"/>
        <xsl:param name="numberLayoutInfo"/>
        <xsl:call-template name="DoSpaceBefore">
            <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
        </xsl:call-template>
        <xsl:call-template name="DoSpaceBefore">
            <xsl:with-param name="layoutInfo" select="$numberLayoutInfo"/>
        </xsl:call-template>
        <tex:cmd name="indent" gr="0"/>
        <xsl:call-template name="DoInternalTargetBegin">
            <xsl:with-param name="sName" select="@id"/>
        </xsl:call-template>
        <xsl:call-template name="OutputSectionNumber">
            <xsl:with-param name="layoutInfo" select="$numberLayoutInfo"/>
        </xsl:call-template>
        <xsl:call-template name="DoInternalTargetEnd"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$numberLayoutInfo"/>
        </xsl:call-template>
        <tex:group>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
            </xsl:call-template>
            <xsl:call-template name="OutputSectionTitle"/>
            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
            </xsl:call-template>
            <xsl:variable name="contentOfThisElement">
                <xsl:call-template name="OutputSectionTitle"/>
                <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                    <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="DoTitleFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
                <xsl:with-param name="contentOfThisElement" select="$contentOfThisElement"/>
            </xsl:call-template>
        </tex:group>
        <!-- put title in marker so it can show up in running header -->
        <tex:cmd name="markright" nl2="1">
            <tex:parm>
                <xsl:call-template name="DoSecTitleRunningHeader"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="CreateAddToContents">
            <xsl:with-param name="id" select="@id"/>
        </xsl:call-template>
        <xsl:call-template name="DoBookMark"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$formatTitleLayoutInfo"/>
        </xsl:call-template>
        <xsl:apply-templates select="child::node()[name()!='secTitle'][1][name()='p']" mode="contentOnly"/>
        <tex:cmd name="par"/>
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
      DoSpaceAfter
   -->
    <xsl:template name="DoSpaceAfter">
        <xsl:param name="layoutInfo"/>
        <xsl:choose>
            <xsl:when test="$layoutInfo/@verticalfillafter!='0'">
                <xsl:call-template name="DoVerticalFill">
                    <xsl:with-param name="iLevel" select="$layoutInfo/@verticalfillafter"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="string-length(normalize-space($layoutInfo/@spaceafter)) &gt; 0">
                    <tex:cmd name="vspace">
                        <tex:parm>
                            <xsl:value-of select="normalize-space($layoutInfo/@spaceafter)"/>
                        </tex:parm>
                    </tex:cmd>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoSpaceBefore
    -->
    <xsl:template name="DoSpaceBefore">
        <xsl:param name="layoutInfo"/>
        <xsl:choose>
            <xsl:when test="$layoutInfo/@verticalfillbefore!='0'">
                <xsl:call-template name="DoVerticalFill">
                    <xsl:with-param name="iLevel" select="$layoutInfo/@verticalfillbefore"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="string-length(normalize-space($layoutInfo/@spacebefore)) &gt; 0">
                    <xsl:variable name="sVSpace">
                        <xsl:text>vspace</xsl:text>
                        <xsl:if test="$layoutInfo/@pagebreakbefore='yes' or $layoutInfo/@startonoddpage='yes'">
                            <xsl:text>*</xsl:text>
                        </xsl:if>
                    </xsl:variable>
                    <tex:cmd name="{$sVSpace}">
                        <tex:parm>
                            <xsl:value-of select="normalize-space($layoutInfo/@spacebefore)"/>
                        </tex:parm>
                    </tex:cmd>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoTableNumbered
    -->
    <xsl:template name="DoTableNumbered">
        <tex:cmd name="vspace">
            <tex:parm>
                <xsl:value-of select="$sBasicPointSize"/>
                <xsl:text>pt</xsl:text>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="DoInternalTargetBegin">
            <xsl:with-param name="sName" select="@id"/>
        </xsl:call-template>
        <xsl:call-template name="DoInternalTargetEnd"/>
        <xsl:call-template name="CreateAddToContents">
            <xsl:with-param name="id" select="@id"/>
        </xsl:call-template>
        <xsl:call-template name="DoType">
            <xsl:with-param name="type" select="@type"/>
        </xsl:call-template>
        <xsl:if test="$contentLayoutInfo/tablenumberedLayout/@captionLocation='before' or not($contentLayoutInfo/tablenumberedLayout) and $lingPaper/@tablenumberedLabelAndCaptionLocation='before'">
            <xsl:call-template name="OutputTableNumberedLabelAndCaption"/>
            <tex:spec cat="esc"/>
            <tex:spec cat="esc"/>
            <tex:spec cat="lsb"/>
            <xsl:choose>
                <xsl:when test="string-length($sSpaceBetweenTableAndCaption) &gt; 0">
                    <xsl:value-of select="$sSpaceBetweenTableAndCaption"/>
                </xsl:when>
                <xsl:otherwise>0pt</xsl:otherwise>
            </xsl:choose>
            <tex:spec cat="rsb"/>
        </xsl:if>
        <!--        <tex:cmd name="leavevmode" gr="0" nl2="1"/>-->
        <xsl:apply-templates select="*[name()!='shortCaption']"/>
        <xsl:call-template name="DoTypeEnd">
            <xsl:with-param name="type" select="@type"/>
        </xsl:call-template>
        <xsl:if test="$contentLayoutInfo/tablenumberedLayout/@captionLocation='after' or not($contentLayoutInfo/tablenumberedLayout) and $lingPaper/@tablenumberedLabelAndCaptionLocation='after'">
            <tex:cmd name="vspace*">
                <tex:parm>
                    <xsl:text>-</xsl:text>
                    <tex:cmd name="baselineskip" gr="0"/>
                </tex:parm>
            </tex:cmd>
            <tex:cmd name="vspace">
                <tex:parm>
                    <xsl:choose>
                        <xsl:when test="string-length($sSpaceBetweenTableAndCaption) &gt; 0">
                            <xsl:value-of select="$sSpaceBetweenTableAndCaption"/>
                        </xsl:when>
                        <xsl:otherwise>0pt</xsl:otherwise>
                    </xsl:choose>
                </tex:parm>
            </tex:cmd>
            <xsl:call-template name="OutputTableNumberedLabelAndCaption"/>
            <tex:cmd name="vspace">
                <tex:parm>.3em</tex:parm>
            </tex:cmd>
        </xsl:if>
    </xsl:template>
    <!--  
        DoTextAlign
    -->
    <xsl:template name="DoTextAlign">
        <xsl:param name="layoutInfo"/>
        <!-- Note: need to be sure to enclose this in a group or it will become the case from now until the next text align -->
        <xsl:choose>
            <xsl:when test="$layoutInfo/@textalign='start' or $layoutInfo/@textalign='left'">
                <tex:spec cat="bg"/>
                <xsl:if test="string-length($layoutInfo/@text-transform) &gt; 0">
                    <!-- \MakeUppercase and \MakeLowercase will break the \centering unless we \protect it.-->
                    <tex:cmd name="protect" gr="0"/>
                </xsl:if>
                <tex:cmd name="noindent" gr="0" nl2="1"/>
            </xsl:when>
            <xsl:when test="$layoutInfo/@textalign='end' or $layoutInfo/@textalign='right'">
                <tex:spec cat="bg"/>
                <xsl:if test="string-length($layoutInfo/@text-transform) &gt; 0">
                    <!-- \MakeUppercase and \MakeLowercase will break the \centering unless we \protect it.-->
                    <tex:cmd name="protect" gr="0"/>
                </xsl:if>
                <tex:cmd name="raggedleft" gr="0" nl2="1"/>
            </xsl:when>
            <xsl:when test="$layoutInfo/@textalign='center'">
                <!-- adjust for center environment -->
                <!--                <tex:cmd name="vspace*">
                    <tex:parm>
                        <xsl:text>-2</xsl:text>
                        <tex:cmd name="topsep" gr="0"/>
                    </tex:parm>
                </tex:cmd>
-->
                <!--                <tex:spec cat="esc"/>
                <xsl:text>begin</xsl:text>
                <tex:spec cat="bg"/>
                <xsl:text>center</xsl:text>
                <tex:spec cat="eg"/>
-->
                <tex:spec cat="bg"/>
                <xsl:if test="string-length($layoutInfo/@text-transform) &gt; 0">
                    <!-- \MakeUppercase and \MakeLowercase will break the \centering unless we \protect it.-->
                    <tex:cmd name="protect" gr="0"/>
                </xsl:if>
                <tex:cmd name="centering" gr="0" nl2="1"/>
                <!--                <tex:cmd name="centerline" gr="0" nl2="1"/>
                <tex:spec cat="bg"/>
-->
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoTextAlignEnd
    -->
    <xsl:template name="DoTextAlignEnd">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="contentForThisElement"/>
        <!-- Note: need to be sure to enclose this in a group or it will become the case from now until the next text align -->
        <xsl:choose>
            <xsl:when test="$layoutInfo/@textalign='center' or $layoutInfo/@textalign='right' or $layoutInfo/@textalign='end'">
                <!-- must have \\ at end or it will not actually center -->
                <xsl:if test="string-length($contentForThisElement) &gt; 0">
                    <xsl:if test="child::*[position()=last()][name()='br'][not(following-sibling::text())]">
                        <!-- cannot have two \\ in a row, so need to insert something; we'll use a non-breaking space -->
                        <xsl:text>&#xa0;</xsl:text>
                    </xsl:if>
                    <tex:spec cat="esc"/>
                    <tex:spec cat="esc"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <tex:spec cat="eg"/>
    </xsl:template>
    <!--  
        DoTextDecoration
    -->
    <xsl:template name="DoTextDecoration">
        <xsl:param name="sDecoration"/>
        <xsl:choose>
            <xsl:when test="$sDecoration='underline'">
                <tex:spec cat="esc"/>
                <xsl:text>uline</xsl:text>
                <tex:spec cat="bg"/>
            </xsl:when>
            <xsl:when test="$sDecoration='line-through'">
                <tex:spec cat="esc"/>
                <xsl:text>sout</xsl:text>
                <tex:spec cat="bg"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- not using overline and blink; but see umoline package if we need overline-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoTextDecorationEnd
    -->
    <xsl:template name="DoTextDecorationEnd">
        <xsl:param name="sDecoration"/>
        <xsl:choose>
            <xsl:when test="$sDecoration='underline'">
                <tex:spec cat="eg"/>
            </xsl:when>
            <xsl:when test="$sDecoration='line-through'">
                <tex:spec cat="eg"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- not using overline and blink; but see umoline package if we need overline-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoTitleFormatInfo
    -->
    <xsl:template name="DoTitleFormatInfo">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="originalContext"/>
        <xsl:call-template name="DoPageBreakFormatInfo">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
        <xsl:call-template name="DoFrontMatterFormatInfoBegin">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            <xsl:with-param name="originalContext" select="$originalContext"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        DoTitleFormatInfoEnd
    -->
    <xsl:template name="DoTitleFormatInfoEnd">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="originalContext"/>
        <xsl:param name="contentOfThisElement"/>
        <xsl:call-template name="DoFrontMatterFormatInfoEnd">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
            <xsl:with-param name="originalContext" select="$originalContext"/>
            <xsl:with-param name="contentOfThisElement" select="$contentOfThisElement"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        DoTitleNeedsSpace
    -->
    <xsl:template name="DoTitleNeedsSpace">
        <tex:cmd name="needspace" nl2="1">
            <tex:parm>
                <xsl:text>3</xsl:text>
                <tex:cmd name="baselineskip" gr="0"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        DoVerticalFill
    -->
    <xsl:template name="DoVerticalFill">
        <xsl:param name="iLevel"/>
        <xsl:choose>
            <xsl:when test="$iLevel='1'">
                <tex:cmd name="vfil" gr="0" nl2="1"/>
            </xsl:when>
            <xsl:when test="$iLevel='2'">
                <tex:cmd name="vfill" gr="0" nl2="1"/>
            </xsl:when>
        </xsl:choose>
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
      GetSectionRefToUse
   -->
    <xsl:template name="GetSectionRefToUse">
        <xsl:param name="section"/>
        <xsl:choose>
            <xsl:when test="name($section)='section1' or name($section)='chapter'">
                <!-- just use section1 and chapter;   if section1 is being ignored, that's the style sheet's problem... -->
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
        GetStylesheetFontFamily
    -->
    <xsl:template name="GetStylesheetFontFamily">
        <xsl:param name="layoutInfo"/>
        <xsl:variable name="sFontFamily" select="$layoutInfo/@font-family"/>
        <xsl:choose>
            <xsl:when test="string-length($sFontFamily) &gt; 0">
                <xsl:value-of select="$sFontFamily"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sDefaultFontFamily"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        GetFontFamilyName
    -->
    <xsl:template name="GetFontFamilyName">
        <!-- set the font family name to 
            'XLingPaper' plus 
            the font name (being careful to convert any digits to letters and changing any spaces to Z so TeX won't complain) plus
            'FontFamily'.
            This should guarantee a unique name. -->
        <xsl:value-of select="concat(concat('XLingPaper',translate(.,$sDigits,$sLetters)),'FontFamily')"/>
    </xsl:template>
    <!--  
        HandleFreeTextAfterAndFontOverrides
    -->
    <xsl:template name="HandleFreeTextAfterAndFontOverrides">
        <xsl:param name="freeLayout"/>
        <xsl:if test="$freeLayout">
            <xsl:call-template name="HandleFreeTextAfterInside">
                <xsl:with-param name="freeLayout" select="$freeLayout"/>
            </xsl:call-template>
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="$freeLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleFreeLanguageFontInfo
    -->
    <xsl:template name="HandleFreeLanguageFontInfo">
        <xsl:variable name="language" select="key('LanguageID',@lang)"/>
        <xsl:variable name="sFontFamily" select="normalize-space($language/@font-family)"/>
        <xsl:variable name="freeLayout" select="$contentLayoutInfo/freeLayout"/>
        <xsl:choose>
            <xsl:when test="string-length($sFontFamily) &gt; 0">
                <xsl:call-template name="HandleFreeTextBeforeOutside">
                    <xsl:with-param name="freeLayout" select="$freeLayout"/>
                </xsl:call-template>
                <xsl:call-template name="HandleFontFamily">
                    <xsl:with-param name="sFontFamily" select="$sFontFamily"/>
                </xsl:call-template>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$language"/>
                </xsl:call-template>
                <xsl:call-template name="HandleFreeTextBeforeAndFontOverrides">
                    <xsl:with-param name="freeLayout" select="$freeLayout"/>
                </xsl:call-template>
                <xsl:apply-templates/>
                <xsl:call-template name="HandleFreeTextAfterAndFontOverrides">
                    <xsl:with-param name="freeLayout" select="$freeLayout"/>
                </xsl:call-template>
                <xsl:call-template name="OutputFontAttributesEnd">
                    <xsl:with-param name="language" select="$language"/>
                </xsl:call-template>
                <xsl:call-template name="HandleFreeTextAfterOutside">
                    <xsl:with-param name="freeLayout" select="$freeLayout"/>
                </xsl:call-template>
                <tex:spec cat="eg"/>
            </xsl:when>
            <xsl:otherwise>
                <!--                <tex:group>-->
                <xsl:call-template name="HandleFreeTextBeforeOutside">
                    <xsl:with-param name="freeLayout" select="$freeLayout"/>
                </xsl:call-template>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$language"/>
                </xsl:call-template>
                <xsl:call-template name="HandleFreeTextBeforeAndFontOverrides">
                    <xsl:with-param name="freeLayout" select="$freeLayout"/>
                </xsl:call-template>
                <xsl:apply-templates/>
                <xsl:call-template name="HandleFreeTextAfterAndFontOverrides">
                    <xsl:with-param name="freeLayout" select="$freeLayout"/>
                </xsl:call-template>
                <xsl:call-template name="OutputFontAttributesEnd">
                    <xsl:with-param name="language" select="$language"/>
                </xsl:call-template>
                <xsl:call-template name="HandleFreeTextAfterOutside">
                    <xsl:with-param name="freeLayout" select="$freeLayout"/>
                </xsl:call-template>
                <!--                </tex:group>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        HandleFreeNoLanguageFontInfo
    -->
    <xsl:template name="HandleFreeNoLanguageFontInfo">
        <xsl:variable name="freeLayout" select="$contentLayoutInfo/freeLayout"/>
        <!--        <tex:group>-->
        <xsl:call-template name="HandleFreeTextBeforeOutside">
            <xsl:with-param name="freeLayout" select="$freeLayout"/>
        </xsl:call-template>
        <xsl:call-template name="HandleFreeTextBeforeAndFontOverrides">
            <xsl:with-param name="freeLayout" select="$freeLayout"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="HandleFreeTextAfterAndFontOverrides">
            <xsl:with-param name="freeLayout" select="$freeLayout"/>
        </xsl:call-template>
        <xsl:call-template name="HandleFreeTextAfterOutside">
            <xsl:with-param name="freeLayout" select="$freeLayout"/>
        </xsl:call-template>
        <!--        </tex:group>-->
    </xsl:template>
    <!--  
        HandleFontFamily
    -->
    <xsl:template name="HandleFontFamily">
        <xsl:param name="language"/>
        <xsl:param name="sFontFamily"/>
        <tex:spec cat="esc"/>
        <xsl:text>XLingPaper</xsl:text>
        <xsl:value-of select="translate($sFontFamily,$sDigits, $sLetters)"/>
        <xsl:text>FontFamily</xsl:text>
        <tex:spec cat="bg"/>
    </xsl:template>
    <!--  
        HandleGlossTextAfterAndFontOverrides
    -->
    <xsl:template name="HandleGlossTextAfterAndFontOverrides">
        <xsl:param name="glossLayout"/>
        <xsl:param name="sGlossContext"/>
        <xsl:if test="$glossLayout">
            <xsl:call-template name="HandleGlossTextAfterInside">
                <xsl:with-param name="glossLayout" select="$glossLayout"/>
                <xsl:with-param name="sGlossContext" select="$sGlossContext"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="$sGlossContext='example'">
                    <xsl:call-template name="OutputFontAttributesEnd">
                        <xsl:with-param name="language" select="$glossLayout/glossInExampleLayout"/>
                        <xsl:with-param name="originalContext" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$sGlossContext='table'">
                    <xsl:call-template name="OutputFontAttributesEnd">
                        <xsl:with-param name="language" select="$glossLayout/glossInTableLayout"/>
                        <xsl:with-param name="originalContext" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$sGlossContext='prose'">
                    <xsl:call-template name="OutputFontAttributesEnd">
                        <xsl:with-param name="language" select="$glossLayout/glossInProseLayout"/>
                        <xsl:with-param name="originalContext" select="."/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--  
        HandleLangDataTextAfterAndFontOverrides
    -->
    <xsl:template name="HandleLangDataTextAfterAndFontOverrides">
        <xsl:param name="langDataLayout"/>
        <xsl:param name="sLangDataContext"/>
        <xsl:if test="$langDataLayout">
            <xsl:call-template name="HandleLangDataTextAfterInside">
                <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
                <xsl:with-param name="sLangDataContext" select="$sLangDataContext"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="$sLangDataContext='example'">
                    <xsl:call-template name="OutputFontAttributesEnd">
                        <xsl:with-param name="language" select="$langDataLayout/langDataInExampleLayout"/>
                        <xsl:with-param name="originalContext" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$sLangDataContext='table'">
                    <xsl:call-template name="OutputFontAttributesEnd">
                        <xsl:with-param name="language" select="$langDataLayout/langDataInTableLayout"/>
                        <xsl:with-param name="originalContext" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$sLangDataContext='prose'">
                    <xsl:call-template name="OutputFontAttributesEnd">
                        <xsl:with-param name="language" select="$langDataLayout/langDataInProseLayout"/>
                        <xsl:with-param name="originalContext" select="."/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
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
        LinkAttributesBegin
    -->
    <xsl:template name="LinkAttributesBegin">
        <xsl:param name="override"/>
        <xsl:if test="$override/@showmarking='yes'">
            <xsl:variable name="sOverrideColor" select="$override/@color"/>
            <xsl:variable name="sOverrideDecoration" select="$override/@decoration"/>
            <xsl:choose>
                <xsl:when test="$sOverrideColor != 'default'">
                    <xsl:call-template name="DoColor">
                        <xsl:with-param name="sFontColor" select="$sOverrideColor"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="string-length($sLinkColor) &gt; 0">
                        <xsl:call-template name="DoColor">
                            <xsl:with-param name="sFontColor" select="$sLinkColor"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$sOverrideDecoration != 'default'">
                    <xsl:call-template name="DoTextDecoration">
                        <xsl:with-param name="sDecoration" select="$sOverrideDecoration"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$sLinkTextDecoration != 'none'">
                        <xsl:call-template name="DoTextDecoration">
                            <xsl:with-param name="sDecoration" select="$sLinkTextDecoration"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--
        LinkAttributesEnd
    -->
    <xsl:template name="LinkAttributesEnd">
        <xsl:param name="override"/>
        <xsl:if test="$override/@showmarking='yes'">
            <xsl:variable name="sOverrideColor" select="$override/@color"/>
            <xsl:variable name="sOverrideDecoration" select="$override/@decoration"/>
            <xsl:choose>
                <xsl:when test="$sOverrideColor != 'default'">
                    <tex:spec cat="eg"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="string-length($sLinkColor) &gt; 0">
                        <tex:spec cat="eg"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$sOverrideDecoration != 'default'">
                    <xsl:call-template name="DoTextDecorationEnd">
                        <xsl:with-param name="sDecoration" select="$sOverrideDecoration"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$sLinkTextDecoration != 'none'">
                        <tex:spec cat="eg"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
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
                   OutputBackMatterItemTitle
-->
    <xsl:template name="OutputBackMatterItemTitle">
        <xsl:param name="sId"/>
        <xsl:param name="sLabel"/>
        <xsl:param name="layoutInfo"/>
        <xsl:choose>
            <xsl:when test="$bIsBook">
                <tex:group>
                    <xsl:call-template name="DoTitleFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        <xsl:with-param name="originalContext" select="$sLabel"/>
                    </xsl:call-template>
                    <tex:cmd name="thispagestyle">
                        <tex:parm>
                            <xsl:choose>
                                <xsl:when test="$backMatterLayoutInfo/headerFooterPageStyles">backmatterfirstpage</xsl:when>
                                <xsl:otherwise>bodyfirstpage</xsl:otherwise>
                            </xsl:choose>
                        </tex:parm>
                    </tex:cmd>
                    <xsl:call-template name="DoInternalTargetBegin">
                        <xsl:with-param name="sName" select="$sId"/>
                    </xsl:call-template>
                    <xsl:call-template name="OutputChapTitle">
                        <xsl:with-param name="sTitle" select="$sLabel"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoInternalTargetEnd"/>
                    <xsl:variable name="contentForThisElement">
                        <xsl:call-template name="OutputChapTitle">
                            <xsl:with-param name="sTitle" select="$sLabel"/>
                        </xsl:call-template>
                        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:call-template name="DoTitleFormatInfoEnd">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        <xsl:with-param name="originalContext" select="$sLabel"/>
                        <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
                    </xsl:call-template>
                    <tex:cmd name="markboth">
                        <tex:parm>
                            <xsl:copy-of select="$sLabel"/>
                        </tex:parm>
                        <tex:parm>
                            <xsl:copy-of select="$sLabel"/>
                        </tex:parm>
                    </tex:cmd>
                    <xsl:call-template name="CreateAddToContents">
                        <xsl:with-param name="id" select="$sId"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoBookMark"/>
                </tex:group>
                <tex:cmd name="par" nl2="1"/>
                <xsl:call-template name="DoSpaceAfter">
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <tex:group>
                    <xsl:call-template name="DoTitleNeedsSpace"/>
                    <xsl:call-template name="DoInternalTargetBegin">
                        <xsl:with-param name="sName" select="$sId"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoType"/>
                    <xsl:call-template name="DoTitleFormatInfo">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        <xsl:with-param name="originalContext" select="$sLabel"/>
                    </xsl:call-template>
                    <!--<xsl:call-template name="DoInternalTargetBegin">
                        <xsl:with-param name="sName" select="$sId"/>
                    </xsl:call-template>-->
                    <xsl:value-of select="$sLabel"/>
                    <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    </xsl:call-template>
                    <xsl:variable name="contentForThisElement">
                        <xsl:value-of select="$sLabel"/>
                        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:call-template name="DoTitleFormatInfoEnd">
                        <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        <xsl:with-param name="originalContext" select="$sLabel"/>
                        <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoTypeEnd"/>
                    <xsl:call-template name="DoInternalTargetEnd"/>
                    <tex:cmd name="markboth">
                        <tex:parm>
                            <xsl:copy-of select="$sLabel"/>
                        </tex:parm>
                        <tex:parm>
                            <xsl:copy-of select="$sLabel"/>
                        </tex:parm>
                    </tex:cmd>
                    <xsl:call-template name="CreateAddToContents">
                        <xsl:with-param name="id" select="$sId"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoBookMark"/>
                </tex:group>
                <tex:cmd name="par" nl2="1"/>
                <xsl:call-template name="DoSpaceAfter">
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputChapterNumber
-->
    <xsl:template name="OutputChapterNumber">
        <xsl:param name="fDoTextAfterLetter" select="'Y'"/>
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
                  OutputChapTitle
-->
    <xsl:template name="OutputChapTitle">
        <xsl:param name="sTitle"/>
        <!--        <xsl:attribute name="span">all</xsl:attribute>-->
        <!--      <fo:block span="all">-->
        <xsl:value-of select="$sTitle"/>
        <!--      </fo:block>-->
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
        <xsl:variable name="styleSheetLabelLayout" select="$styleSheetFigureLabelLayout"/>
        <xsl:variable name="styleSheetLabelLayoutLabel" select="$styleSheetLabelLayout/@label"/>
        <xsl:variable name="label" select="$lingPaper/@figureLabel"/>
        <tex:spec cat="bg"/>
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
        <tex:spec cat="eg"/>
    </xsl:template>
    <!--  
        OutputFigureLabelAndCaption
    -->
    <xsl:template name="OutputFigureLabelAndCaption">
        <xsl:param name="bDoStyles" select="'Y'"/>
        <xsl:if test="$bDoStyles='Y'">
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$styleSheetFigureLabelLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="OutputFigureLabel"/>
        <xsl:if test="$bDoStyles='Y'">
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="$styleSheetFigureLabelLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$styleSheetFigureNumberLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
        </xsl:if>
        <tex:spec cat="bg"/>
        <xsl:value-of select="$styleSheetFigureNumberLayout/@textbefore"/>
        <xsl:apply-templates select="." mode="figure"/>
        <xsl:value-of select="$styleSheetFigureNumberLayout/@textafter"/>
        <tex:spec cat="eg"/>
        <xsl:if test="$bDoStyles='Y'">
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="$styleSheetFigureNumberLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$styleSheetFigureCaptionLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
        </xsl:if>
        <tex:spec cat="bg"/>
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
        <tex:spec cat="eg"/>
        <xsl:if test="$bDoStyles='Y'">
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="$styleSheetFigureCaptionLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template match="caption | endCaption" mode="show">
        <xsl:variable name="styleSheetLabelLayout" select="$contentLayoutInfo/figureLabelLayout"/>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="."/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="$styleSheetLabelLayout"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:call-template name="DoType"/>
        <xsl:apply-templates/>
        <xsl:call-template name="DoTypeEnd"/>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="$styleSheetLabelLayout"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="."/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
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
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
                  OutputFrontOrBackMatterTitle
    -->
    <xsl:template name="OutputFrontOrBackMatterTitle">
        <xsl:param name="id"/>
        <xsl:param name="sTitle"/>
        <xsl:param name="titlePart2"/>
        <xsl:param name="bIsBook" select="'Y'"/>
        <xsl:param name="bDoTwoColumns" select="'N'"/>
        <xsl:param name="layoutInfo"/>
        <xsl:param name="sFirstPageStyle" select="'fancyfirstpage'"/>
        <xsl:choose>
            <xsl:when test="$bIsBook='Y'">
                <xsl:if test="$bDoTwoColumns = 'Y'">
                    <tex:spec cat="esc" nl1="1"/>
                    <xsl:text>twocolumn</xsl:text>
                    <tex:spec cat="lsb"/>
                </xsl:if>
                <tex:cmd name="thispagestyle">
                    <tex:parm>
                        <xsl:value-of select="$sFirstPageStyle"/>
                    </tex:parm>
                </tex:cmd>
            </xsl:when>
        </xsl:choose>
        <tex:group nl1="1" nl2="1">
            <xsl:call-template name="DoTitleNeedsSpace"/>
            <xsl:call-template name="DoInternalTargetBegin">
                <xsl:with-param name="sName" select="$id"/>
            </xsl:call-template>
            <xsl:call-template name="DoTitleFormatInfo">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                <xsl:with-param name="originalContext" select="$sTitle"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="$bIsBook='Y'">
                    <xsl:call-template name="OutputChapTitle">
                        <xsl:with-param name="sTitle" select="$sTitle"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="not($layoutInfo/@useLabel) or $layoutInfo/@useLabel='yes'">
                        <xsl:value-of select="$sTitle"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="contentForThisElement">
                <xsl:choose>
                    <xsl:when test="$bIsBook='Y'">
                        <xsl:call-template name="OutputChapTitle">
                            <xsl:with-param name="sTitle" select="$sTitle"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="not($layoutInfo/@useLabel) or $layoutInfo/@useLabel='yes'">
                            <xsl:value-of select="$sTitle"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="DoTitleFormatInfoEnd">
                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                <xsl:with-param name="originalContext" select="$sTitle"/>
                <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
            </xsl:call-template>
            <xsl:call-template name="DoInternalTargetEnd"/>
            <xsl:if test="$titlePart2">
                <xsl:apply-templates select="$titlePart2"/>
            </xsl:if>
            <tex:cmd name="markboth" nl2="1">
                <tex:parm>
                    <xsl:value-of select="$sTitle"/>
                </tex:parm>
                <tex:parm>
                    <xsl:value-of select="$sTitle"/>
                </tex:parm>
            </tex:cmd>
            <xsl:call-template name="CreateAddToContents">
                <xsl:with-param name="id" select="$id"/>
            </xsl:call-template>
            <xsl:call-template name="DoBookMark"/>
        </tex:group>
        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
        <xsl:call-template name="DoNotBreakHere"/>
        <tex:cmd name="par" nl2="1"/>
        <xsl:call-template name="DoSpaceAfter">
            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
        </xsl:call-template>
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
        <xsl:call-template name="DoInternalHyperlinkBegin">
            <xsl:with-param name="sName" select="$sIndexedItemID"/>
        </xsl:call-template>
        <xsl:call-template name="LinkAttributesBegin">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/indexLinkLayout"/>
        </xsl:call-template>
        <xsl:variable name="sPage" select="document($sIndexFile)/idx/indexitem[@ref=$sIndexedItemID]/@page"/>
        <xsl:choose>
            <xsl:when test="$sPage">
                <xsl:value-of select="$sPage"/>
            </xsl:when>
            <xsl:otherwise>??</xsl:otherwise>
        </xsl:choose>
        <xsl:if test="ancestor::endnote">
            <xsl:text>n</xsl:text>
        </xsl:if>
        <xsl:call-template name="LinkAttributesEnd">
            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/indexLinkLayout"/>
        </xsl:call-template>
        <xsl:call-template name="DoInternalHyperlinkEnd"/>
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
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',$lang)"/>
            <xsl:with-param name="originalContext" select="$sFirst"/>
        </xsl:call-template>
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
                <xsl:call-template name="HandleLangDataTextAfterAndFontOverrides">
                    <xsl:with-param name="langDataLayout" select="$langDataLayout"/>
                    <xsl:with-param name="sLangDataContext" select="$sContext"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="HandleGlossTextAfterAndFontOverrides">
                    <xsl:with-param name="glossLayout" select="$glossLayout"/>
                    <xsl:with-param name="sGlossContext" select="$sContext"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',$lang)"/>
            <xsl:with-param name="originalContext" select="$sFirst"/>
        </xsl:call-template>
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
        <tex:spec cat="align"/>
        <xsl:if test="$sRest">
            <xsl:call-template name="OutputInterlinearLineAsTableCells">
                <xsl:with-param name="sList" select="$sRest"/>
                <xsl:with-param name="lang" select="$lang"/>
                <xsl:with-param name="sAlign" select="$sAlign"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputInterlinearTextReferenceContent
    -->
    <xsl:template name="OutputInterlinearTextReferenceContent">
        <xsl:param name="sSource"/>
        <xsl:param name="sRef"/>
        <tex:cmd name="hfill" nl2="0"/>
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
                <xsl:call-template name="OutputSectionNumberProper">
                    <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                    <xsl:with-param name="bAppendix" select="$bAppendix"/>
                </xsl:call-template>
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
        OutputSectionNumberProper
    -->
    <xsl:template name="OutputSectionNumberProper">
        <xsl:param name="layoutInfo"/>
        <xsl:param name="bAppendix"/>
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
            <tex:group>
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
                <xsl:choose>
                    <xsl:when test="$layoutInfo">
                        <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        </xsl:call-template>
                        <xsl:variable name="contentForThisElement">
                            <xsl:call-template name="DoFormatLayoutInfoTextAfter">
                                <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="DoTitleFormatInfoEnd">
                            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                            <xsl:with-param name="contentOfThisElement" select="$contentForThisElement"/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="$layoutInfo/../@beginsparagraph!='yes' and string-length($layoutInfo/@spaceafter) &gt; 0">
                                <tex:cmd name="par" nl2="1"/>
                            </xsl:when>
                            <xsl:when test="$layoutInfo/../@beginsparagraph='yes'">
                                <!-- do nothing; all handled by other information -->
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- insert a non-breaking space -->
                                <xsl:text>&#xa0;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:call-template name="DoSpaceAfter">
                            <xsl:with-param name="layoutInfo" select="$layoutInfo"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- make sure there's a (non-breaking) space between the number and the title -->
                        <xsl:text>&#xa0;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </tex:group>
        </xsl:if>
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
        <!--        <xsl:text disable-output-escaping="yes">&#x20;</xsl:text>-->
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
        OutputTableNumberedLabel
    -->
    <xsl:template name="OutputTableNumberedLabel">
        <xsl:variable name="styleSheetLabelLayout" select="$styleSheetTableNumberedLabelLayout"/>
        <xsl:variable name="styleSheetLabelLayoutLabel" select="$styleSheetLabelLayout/@label"/>
        <xsl:variable name="label" select="$lingPaper/@tablenumberedLabel"/>
        <tex:spec cat="bg"/>
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
        <tex:spec cat="eg"/>
    </xsl:template>
    <!--  
        OutputTableNumberedLabelAndCaption
    -->
    <xsl:template name="OutputTableNumberedLabelAndCaption">
        <xsl:param name="bDoStyles" select="'Y'"/>
        <xsl:if test="$bDoStyles='Y'">
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$styleSheetTableNumberedLabelLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="OutputTableNumberedLabel"/>
        <xsl:if test="$bDoStyles='Y'">
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="$styleSheetTableNumberedLabelLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$styleSheetTableNumberedNumberLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
        </xsl:if>
        <tex:spec cat="bg"/>
        <xsl:value-of select="$styleSheetTableNumberedNumberLayout/@textbefore"/>
        <xsl:apply-templates select="." mode="tablenumbered"/>
        <xsl:value-of select="$styleSheetTableNumberedNumberLayout/@textafter"/>
        <tex:spec cat="eg"/>
        <xsl:if test="$bDoStyles='Y'">
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="$styleSheetTableNumberedNumberLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$styleSheetTableNumberedCaptionLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
        </xsl:if>
        <tex:spec cat="bg"/>
        <xsl:value-of select="$styleSheetTableNumberedCaptionLayout/@textbefore"/>
        <xsl:choose>
            <xsl:when test="$bDoStyles='Y'">
                <xsl:apply-templates select="table/caption | table/endCaption" mode="show"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="table/caption | table/endCaption" mode="contents"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$styleSheetTableNumberedCaptionLayout/@textafter"/>
        <tex:spec cat="eg"/>
        <xsl:if test="$bDoStyles='Y'">
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="$styleSheetTableNumberedCaptionLayout"/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
        SetFootnoteRule
    -->
    <xsl:template name="SetFootnoteRule">
        <xsl:variable name="layoutInfo" select="$pageLayoutInfo/footnoteLine"/>
        <xsl:if test="$layoutInfo">
            <!-- the only thing I could find that did anything but hang xelatex was this:
            \makeatletter\renewcommand\footnoterule{\kern-3\p@\hrule\@width4in\kern2.6\p@}\makeatother
            
            Note that the width is some special value;  we can change the length and that works (the 4in above).
            -->
            <!--<xsl:if test="$layoutInfo/@leaderpattern and $layoutInfo/@leaderpattern!='none'">
                <!-\-                        <fo:leader>-\->
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
                <!-\-                        </fo:leader>-\->
            </xsl:if>-->
        </xsl:if>
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
        <xsl:variable name="fontFamilies" select="//@font-family[string-length(normalize-space(.)) &gt; 0]"/>
        <xsl:for-each select="$fontFamilies">
            <xsl:variable name="iPos" select="position()"/>
            <xsl:variable name="thisOne">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:variable>
            <xsl:variable name="seenBefore" select="$fontFamilies[position() &lt; $iPos]/. = $thisOne"/>
            <xsl:if test="not($seenBefore)">
                <xsl:call-template name="DefineAFontFamily">
                    <xsl:with-param name="sFontFamilyName">
                        <xsl:call-template name="GetFontFamilyName"/>
                    </xsl:with-param>
                    <xsl:with-param name="sBaseFontName" select="."/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!--  
        SetHeaderFooter
    -->
    <xsl:template name="SetHeaderFooter">
        <!-- general style -->
        <xsl:call-template name="SetHeaderFooterStyle">
            <xsl:with-param name="sStyleName" select="'fancyfirstpage'"/>
            <xsl:with-param name="layoutInfo" select="$pageLayoutInfo/headerFooterPageStyles/headerFooterFirstPage"/>
        </xsl:call-template>
        <xsl:call-template name="SetHeaderFooterStyle">
            <xsl:with-param name="sStyleName" select="'fancy'"/>
            <xsl:with-param name="layoutInfo" select="$pageLayoutInfo/headerFooterPageStyles/*[not(name()='headerFooterFirstPage')]"/>
            <xsl:with-param name="sPageStyle" select="'pagestyle'"/>
        </xsl:call-template>
        <!-- front matter title -->
        <xsl:call-template name="SetHeaderFooterStyle">
            <xsl:with-param name="sStyleName" select="'frontmattertitle'"/>
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/titleHeaderFooterPageStyles"/>
        </xsl:call-template>
        <!-- front matter-->
        <xsl:call-template name="SetHeaderFooterStyle">
            <xsl:with-param name="sStyleName" select="'frontmatterfirstpage'"/>
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/headerFooterPageStyles/headerFooterFirstPage"/>
        </xsl:call-template>
        <xsl:call-template name="SetHeaderFooterStyle">
            <xsl:with-param name="sStyleName" select="'frontmatter'"/>
            <xsl:with-param name="layoutInfo" select="$frontMatterLayoutInfo/headerFooterPageStyles/*[not(name()='headerFooterFirstPage')]"/>
        </xsl:call-template>
        <!-- body-->
        <xsl:call-template name="SetHeaderFooterStyle">
            <xsl:with-param name="sStyleName" select="'bodyfirstpage'"/>
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/headerFooterPageStyles/headerFooterFirstPage"/>
        </xsl:call-template>
        <xsl:call-template name="SetHeaderFooterStyle">
            <xsl:with-param name="sStyleName" select="'body'"/>
            <xsl:with-param name="layoutInfo" select="$bodyLayoutInfo/headerFooterPageStyles/*[not(name()='headerFooterFirstPage')]"/>
        </xsl:call-template>
        <!-- back matter-->
        <xsl:call-template name="SetHeaderFooterStyle">
            <xsl:with-param name="sStyleName" select="'backmatterfirstpage'"/>
            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/headerFooterPageStyles/headerFooterFirstPage"/>
        </xsl:call-template>
        <xsl:call-template name="SetHeaderFooterStyle">
            <xsl:with-param name="sStyleName" select="'backmatter'"/>
            <xsl:with-param name="layoutInfo" select="$backMatterLayoutInfo/headerFooterPageStyles/*[not(name()='headerFooterFirstPage')]"/>
        </xsl:call-template>
        <!-- the first page exception -->
        <!--   doing above now
    <tex:cmd name="fancypagestyle" nl2="1">
            <tex:parm>plain</tex:parm>
            <tex:parm>
                <tex:cmd name="fancyhf" nl2="1"/>
                <xsl:for-each select="$pageLayoutInfo/headerFooterPageStyles/headerFooterFirstPage">
                    <!-\- uses the same layout for all pages -\->
                    <xsl:for-each select="*[not(nothing)]">
                        <!-\- for each left, center, right item -\->
                        <xsl:call-template name="DoHeaderFooterItem">
                            <xsl:with-param name="item" select="."/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:call-template name="SetHeaderFooterRuleWidths"/>
            </tex:parm>
        </tex:cmd>
-->
    </xsl:template>
    <!--  
        SetHeaderFooterStyle
    -->
    <xsl:template name="SetHeaderFooterStyle">
        <xsl:param name="sStyleName"/>
        <xsl:param name="layoutInfo"/>
        <xsl:param name="sPageStyle" select="'fancypagestyle'"/>
        <xsl:if test="$layoutInfo">
            <tex:cmd name="{$sPageStyle}" nl2="1">
                <tex:parm>
                    <xsl:value-of select="$sStyleName"/>
                </tex:parm>
            </tex:cmd>
            <xsl:if test="$sPageStyle='fancypagestyle'">
                <tex:spec cat="bg"/>
            </xsl:if>
            <tex:cmd name="fancyhf" nl2="1"/>
            <xsl:variable name="originalContext" select="."/>
            <xsl:for-each select="$layoutInfo[name()='headerFooterPage' or name()='headerFooterFirstPage']/*">
                <!-- uses the same layout for all pages -->
                <xsl:for-each select="*[not(descendant::nothing)]">
                    <!-- for each left, center, right item -->
                    <xsl:call-template name="DoHeaderFooterItem">
                        <xsl:with-param name="item" select="."/>
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$layoutInfo[name()='headerFooterOddEvenPages']/*">
                <!-- uses odd/even page layout -->
                <xsl:for-each select="*/*[not(descendant::nothing)]">
                    <!-- for each left, center, right item -->
                    <xsl:call-template name="DoHeaderFooterItem">
                        <xsl:with-param name="item" select="."/>
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                        <xsl:with-param name="sOddEven">
                            <xsl:choose>
                                <xsl:when test="ancestor::headerFooterEvenPage">E</xsl:when>
                                <xsl:otherwise>O</xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
            <xsl:call-template name="SetHeaderFooterRuleWidths"/>
            <xsl:if test="$sPageStyle='fancypagestyle'">
                <tex:spec cat="eg"/>
            </xsl:if>
        </xsl:if>
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
    <!-- ===========================================================
      ELEMENTS TO IGNORE
      =========================================================== -->
    <xsl:template match="language"/>
    <xsl:template match="comment"/>
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
    <!-- ===========================================================
        TRANSFORMS TO INCLUDE
        =========================================================== -->
    <xsl:include href="XLingPapPublisherStylesheetXeLaTeXBookmarks.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetXeLaTeXContents.xsl"/>
    <xsl:include href="XLingPapPublisherStylesheetXeLaTeXReferences.xsl"/>
    <xsl:include href="XLingPapCommon.xsl"/>
    <xsl:include href="XLingPapXeLaTeXCommon.xsl"/>
</xsl:stylesheet>
