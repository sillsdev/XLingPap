<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tex="http://getfo.sourceforge.net/texml/ns1" xmlns:saxon="http://icl.com/saxon" version="1.0">
    <!-- 
    XLingPapXeLaTeXCommon.xsl
    Contains called templates common to many of the XeLaTeX-oriented transforms.
    -->
    <!-- ===========================================================
        Variables
        =========================================================== -->
    <xsl:variable name="lingPaper" select="//lingPaper"/>
    <xsl:variable name="abbrLang" select="//lingPaper/@abbreviationlang"/>
    <xsl:variable name="abbreviations" select="//abbreviations"/>
    <xsl:variable name="chapters" select="//chapter"/>
    <!-- following is here to get thesis submission style to get correct margins -->
    <xsl:variable name="pageLayoutInfo" select="//publisherStyleSheet/pageLayout"/>
    <xsl:variable name="sDigits" select="'1234567890 _-'"/>
    <xsl:variable name="sLetters" select="'ABCDEFGHIJZYX'"/>
    <xsl:variable name="sIDcharsToMap" select="'_'"/>
    <xsl:variable name="sIDcharsMapped" select="';'"/>
    <xsl:variable name="sPercent20" select="'%20'"/>
    <xsl:variable name="sBulletPoint" select="'&#x2022;'"/>
    <xsl:variable name="sInterlinearMaxNumberOfColumns" select="'50'"/>
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
    <xsl:variable name="bHasIndex">
        <xsl:choose>
            <xsl:when test="//index">
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
            <xsl:when test="$sFOProcessor='TeX' or $sFOProcessor='XEP'">
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
    <xsl:variable name="sUppercaseAtoZ" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="sLowercaseAtoZ" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="sYs" select="'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY'"/>
    <!--
        citation (InMarker)
    -->
    <xsl:template match="citation" mode="InMarker">
        <xsl:variable name="refer" select="id(@ref)"/>
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
    </xsl:template>
    <!--
        genericRef (InMarker)
    -->
    <xsl:template match="genericRef" mode="InMarker">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
        genericTarget
    -->
    <xsl:template match="genericTarget">
        <xsl:call-template name="DoInternalTargetBegin">
            <xsl:with-param name="sName" select="@id"/>
        </xsl:call-template>
        <xsl:call-template name="DoInternalTargetEnd"/>
    </xsl:template>
    <!-- ===========================================================
        QUOTES
        =========================================================== -->
    <xsl:template match="q">
        <xsl:value-of select="$sLdquo"/>
        <xsl:call-template name="DoType"/>
        <xsl:apply-templates/>
        <xsl:call-template name="DoTypeEnd"/>
        <xsl:value-of select="$sRdquo"/>
    </xsl:template>
    <xsl:template match="blockquote">
        <!--  following did not work      <tex:group>
            <tex:cmd name="leftskip" gr="0" nl1="1"/>
            <xsl:value-of select="normalize-space($sBlockQuoteIndent)"/>
            <tex:cmd name="relax" gr="0" nl2="1"/>
            <tex:cmd name="rightskip" gr="0"/>
            <xsl:value-of select="normalize-space($sBlockQuoteIndent)"/>
            <tex:cmd name="relax" gr="0" nl2="1"/>
            <tex:cmd name="vspace" nl2="1">
                <tex:parm>
                    <xsl:value-of select="$sBasicPointSize"/>
                    <xsl:text>pt</xsl:text>
                </tex:parm>
            </tex:cmd>
            <tex:cmd name="small">
                <tex:parm>
-->
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespaceblockquotes='yes'">
            <tex:spec cat="bg"/>
            <tex:cmd name="singlespacing" gr="0" nl2="1"/>
        </xsl:if>
        <tex:env name="quotation">
            <!--                    <xsl:call-template name="DoType"/>  this kind cannot cross paragraph boundaries, so have to do it in p-->
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="OutputTypeAttributesEnd">
                <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
            </xsl:call-template>
            <!--                    <xsl:call-template name="DoTypeEnd"/>-->
        </tex:env>
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespaceblockquotes='yes'">
            <tex:spec cat="eg"/>
        </xsl:if>
        <!--</tex:parm>
            </tex:cmd>
            <tex:cmd name="vspace" nl2="1">
                <tex:parm>
                    <xsl:value-of select="$sBasicPointSize"/>
                    <xsl:text>pt</xsl:text>
                </tex:parm>
            </tex:cmd>
        </tex:group>-->
    </xsl:template>
    <!-- ===========================================================
        PROSE TEXT
        =========================================================== -->
    <xsl:template match="prose-text">
        <tex:env name="quotation">
            <!--                    <xsl:call-template name="DoType"/>  this kind cannot cross paragraph boundaries, so have to do it in p-->
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="OutputTypeAttributesEnd">
                <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
            </xsl:call-template>
            <!--                    <xsl:call-template name="DoTypeEnd"/>-->
        </tex:env>
    </xsl:template>
    <!-- ===========================================================
      LISTS
      =========================================================== -->
    <xsl:template match="ol">
        <xsl:variable name="sThisItemWidth">
            <xsl:call-template name="GetItemWidth"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="count(ancestor::ul | ancestor::ol) = 0 or parent::endnote">
                <xsl:if test="parent::definition">
                    <xsl:call-template name="DoTypeEnd">
                        <xsl:with-param name="type" select="../@type"/>
                    </xsl:call-template>
                </xsl:if>
                <tex:group>
                    <tex:spec cat="esc"/>
                    <xsl:text>parskip .5pt plus 1pt minus 1pt
</xsl:text>
                    <xsl:choose>
                        <xsl:when test="parent::definition and ancestor::p">
                            <xsl:text>&#x0a;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <tex:cmd name="vspace" nl1="1" nl2="1">
                                <tex:parm>
                                    <xsl:call-template name="VerticalSkipAroundList"/>
                                </tex:parm>
                            </tex:cmd>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="parent::definition">
                        <xsl:call-template name="DoType">
                            <xsl:with-param name="type" select="../@type"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:apply-templates>
                        <xsl:with-param name="sListItemWidth">
                            <tex:spec cat="esc"/>
                            <xsl:value-of select="$sThisItemWidth"/>
                        </xsl:with-param>
                        <xsl:with-param name="sListItemIndent">
                            <tex:spec cat="esc"/>
                            <xsl:choose>
                                <xsl:when test="ancestor::example">
                                    <xsl:text>XLingPaperlistinexampleindent</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$sThisItemWidth"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:apply-templates>
                    <xsl:if test="parent::definition">
                        <xsl:call-template name="DoTypeEnd">
                            <xsl:with-param name="type" select="../@type"/>
                        </xsl:call-template>
                    </xsl:if>
                    <tex:cmd name="vspace" nl1="1" nl2="1">
                        <tex:parm>
                            <xsl:call-template name="VerticalSkipAroundList"/>
                        </tex:parm>
                    </tex:cmd>
                </tex:group>
                <xsl:if test="parent::definition">
                    <xsl:call-template name="DoType">
                        <xsl:with-param name="type" select="../@type"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="HandleEmbeddedListItem">
                    <xsl:with-param name="sThisItemWidth" select="$sThisItemWidth"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="HandleEmbeddedListItem">
        <xsl:param name="sThisItemWidth"/>
        <xsl:variable name="myEndnote" select="ancestor::endnote"/>
        <xsl:variable name="myAncestorLists" select="ancestor::ol | ancestor::ul"/>
        <xsl:call-template name="DoTypeForLI">
            <xsl:with-param name="myAncestorLists" select="$myAncestorLists"/>
            <xsl:with-param name="myEndnote" select="$myEndnote"/>
            <xsl:with-param name="bIsEnd" select="'Y'"/>
        </xsl:call-template>
        <tex:spec cat="eg"/>
        <!--        <tex:cmd name="par" nl2="1"/>-->
        <tex:spec cat="bg"/>
        <xsl:call-template name="DoTypeForLI">
            <xsl:with-param name="myAncestorLists" select="$myAncestorLists"/>
            <xsl:with-param name="myEndnote" select="$myEndnote"/>
            <xsl:with-param name="bBracketsOnly" select="'Y'"/>
        </xsl:call-template>
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
                        <xsl:choose>
                            <xsl:when test="ancestor::example">
                                <xsl:text>XLingPaperlistinexampleindent</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="GetItemWidth"/>
                            </xsl:otherwise>
                        </xsl:choose>
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
    <xsl:template name="DoTypeForLI">
        <xsl:param name="myAncestorLists"/>
        <xsl:param name="myEndnote"/>
        <xsl:param name="bIsEnd" select="'N'"/>
        <xsl:param name="bBracketsOnly" select="'N'"/>
        <xsl:for-each select="$myAncestorLists">
            <xsl:sort order="descending"/>
            <xsl:choose>
                <xsl:when test="$myEndnote">
                    <xsl:variable name="current" select="."/>
                    <xsl:if test="$myEndnote/descendant::* = $current">
                        <xsl:call-template name="DoTypeForLiGivenList">
                            <xsl:with-param name="bIsEnd" select="$bIsEnd"/>
                            <xsl:with-param name="bBracketsOnly" select="$bBracketsOnly"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="DoTypeForLiGivenList">
                        <xsl:with-param name="bIsEnd" select="$bIsEnd"/>
                        <xsl:with-param name="bBracketsOnly" select="$bBracketsOnly"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="DoTypeForLiGivenList">
        <xsl:param name="bIsEnd"/>
        <xsl:param name="bBracketsOnly" select="'N'"/>
        <xsl:choose>
            <xsl:when test="$bIsEnd='Y'">
                <xsl:call-template name="DoTypeEnd">
                    <xsl:with-param name="type" select="@type"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$bBracketsOnly='Y'">
                <xsl:call-template name="DoTypeBracketsOnly">
                    <xsl:with-param name="type" select="@type"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="DoType">
                    <xsl:with-param name="type" select="@type"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="ul">
        <xsl:choose>
            <xsl:when test="count(ancestor::ul | ancestor::ol) = 0">
                <xsl:if test="parent::definition">
                    <xsl:call-template name="DoTypeEnd">
                        <xsl:with-param name="type" select="../@type"/>
                    </xsl:call-template>
                </xsl:if>
                <tex:group>
                    <tex:spec cat="esc"/>
                    <xsl:text>parskip .5pt plus 1pt minus 1pt
</xsl:text>
                    <tex:cmd name="vspace" nl1="1" nl2="1">
                        <tex:parm>
                            <xsl:call-template name="VerticalSkipAroundList"/>
                        </tex:parm>
                    </tex:cmd>
                    <xsl:if test="parent::definition">
                        <xsl:call-template name="DoType">
                            <xsl:with-param name="type" select="../@type"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:apply-templates>
                        <xsl:with-param name="sListItemIndent">
                            <tex:spec cat="esc"/>
                            <xsl:choose>
                                <xsl:when test="ancestor::example">
                                    <xsl:text>XLingPaperlistinexampleindent</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>XLingPaperbulletlistitemwidth</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:apply-templates>
                    <xsl:if test="parent::definition">
                        <xsl:call-template name="DoTypeEnd">
                            <xsl:with-param name="type" select="../@type"/>
                        </xsl:call-template>
                    </xsl:if>
                    <tex:cmd name="vspace" nl1="1" nl2="1">
                        <tex:parm>
                            <xsl:call-template name="VerticalSkipAroundList"/>
                        </tex:parm>
                    </tex:cmd>
                    <xsl:if test="parent::definition">
                        <xsl:call-template name="DoType">
                            <xsl:with-param name="type" select="../@type"/>
                        </xsl:call-template>
                    </xsl:if>
                </tex:group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="HandleEmbeddedListItem">
                    <xsl:with-param name="sThisItemWidth" select="'XLingPaperbulletlistitemwidth'"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="VerticalSkipAroundList">
        <xsl:if test="ancestor::example">
            <xsl:text>-</xsl:text>
        </xsl:if>
        <tex:cmd name="baselineskip" gr="0" nl2="0"/>
    </xsl:template>
    <xsl:template match="li">
        <xsl:param name="sListItemWidth">
            <tex:spec cat="esc"/>
            <xsl:text>XLingPaperbulletlistitemwidth</xsl:text>
        </xsl:param>
        <xsl:param name="sListItemIndent" select="'1em'"/>
        <!--<tex:spec cat="bg"/>
        <!-\- use hanging indent so all material within the li starts out indented (e.g. p elements and text) -\->
        <tex:spec cat="esc"/>
        <xsl:text>hangindent</xsl:text>
        <tex:spec cat="esc"/>
        <xsl:value-of select="$sListItemIndent"/>
        <tex:cmd name="relax" gr="0" nl2="1"/>
        <tex:spec cat="esc"/>
        <xsl:text>hangafter0</xsl:text>
        <tex:cmd name="relax" gr="0" nl2="1"/>-->
        <tex:spec cat="bg" nl1="1"/>
        <!--        <tex:spec cat="esc"/>
        <xsl:text>newdimen</xsl:text>
        <tex:spec cat="esc"/>
        <xsl:text>XLingPapertempdim</xsl:text>
-->
        <tex:cmd name="setlength">
            <tex:parm>
                <tex:spec cat="esc"/>
                <xsl:text>XLingPapertempdim</xsl:text>
            </tex:parm>
            <tex:parm>
                <xsl:copy-of select="$sListItemWidth"/>
                <xsl:text>+</xsl:text>
                <xsl:copy-of select="$sListItemIndent"/>
            </tex:parm>
        </tex:cmd>
        <tex:spec cat="esc"/>
        <xsl:text>leftskip</xsl:text>
        <tex:spec cat="esc"/>
        <xsl:text>XLingPapertempdim</xsl:text>
        <!--        <xsl:copy-of select="$sListItemIndent"/>-->
        <tex:cmd name="relax" gr="0" nl2="1"/>
        <!--        <tex:spec cat="esc"/>
        <xsl:text>parindent</xsl:text>
        <tex:spec cat="esc"/>
        <xsl:text>XLingPapertempdim</xsl:text>
<!-\-        <xsl:copy-of select="$sListItemIndent"/>-\->
        <tex:cmd name="relax" gr="0" nl2="1"/>
-->
        <tex:spec cat="esc"/>
        <xsl:text>interlinepenalty10000</xsl:text>
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
                <xsl:call-template name="HandleTypesForLi"/>
            </tex:parm>
        </tex:cmd>
        <tex:spec cat="eg"/>
    </xsl:template>
    <xsl:template name="HandleTypesForLi">
        <xsl:variable name="myEndnote" select="ancestor::endnote"/>
        <xsl:variable name="myAncestorLists" select="ancestor::ol | ancestor::ul"/>
        <xsl:call-template name="DoTypeForLI">
            <xsl:with-param name="myAncestorLists" select="$myAncestorLists"/>
            <xsl:with-param name="myEndnote" select="$myEndnote"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="DoTypeForLI">
            <xsl:with-param name="myAncestorLists" select="$myAncestorLists"/>
            <xsl:with-param name="myEndnote" select="$myEndnote"/>
            <xsl:with-param name="bIsEnd" select="'Y'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="text()[parent::li and count(preceding-sibling::*) &gt; 0]">
        <!--        <xsl:call-template name="HandleTypesForLi"/>-->
        <xsl:variable name="myEndnote" select="ancestor::endnote"/>
        <xsl:variable name="myAncestorLists" select="ancestor::ol | ancestor::ul"/>
        <xsl:call-template name="DoTypeForLI">
            <xsl:with-param name="myAncestorLists" select="$myAncestorLists"/>
            <xsl:with-param name="myEndnote" select="$myEndnote"/>
        </xsl:call-template>
        <xsl:value-of select="."/>
        <xsl:call-template name="DoTypeForLI">
            <xsl:with-param name="myAncestorLists" select="$myAncestorLists"/>
            <xsl:with-param name="myEndnote" select="$myEndnote"/>
            <xsl:with-param name="bIsEnd" select="'Y'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="dl">
        <xsl:if test="count(dt) &gt; 0">
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
        </xsl:if>
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
    </xsl:template>
    <xsl:template match="dd" mode="dt">
        <xsl:apply-templates/>
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
        <xsl:if test="parent::example and count(preceding-sibling::listWord) = 0">
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
        <xsl:if test="parent::example and count(preceding-sibling::listSingle) = 0">
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
                <!--                <tex:cmd name="leftskip" gr="0" nl2="0"/>-->
                <!--                <tex:spec cat="esc"/>-->
                <!--                <tex:spec cat="esc"/>-->
                <tex:cmd name="hangindent" gr="0" nl2="0"/>
                <xsl:value-of select="$sParagraphIndent"/>
                <tex:cmd name="noindent" gr="0" nl2="0"/>
                <tex:cmd name="hspace*" nl2="0">
                    <tex:parm>
                        <xsl:value-of select="$sParagraphIndent"/>
                    </tex:parm>
                </tex:cmd>
                <!-- this keeps the entire interlinear on the same page, even if parts of it could easily fit
                    <tex:cmd name="nopagebreak" gr="0" nl2="0"/>-->
                <xsl:call-template name="OutputInterlinear">
                    <xsl:with-param name="mode" select="'NoTextRef'"/>
                </xsl:call-template>
                <tex:cmd name="par" gr="0" nl2="1"/>
            </xsl:when>
            <xsl:when test="parent::td">
                <!-- when we are in a table, any attempt to insert a new row for a free translation 
                    causes a Missing \endgroup message. By embedding the interlinear within
                    a tabular, we avoid that problem (although, the interlienar may be indented a
                    bit more than we'd like). -->
                <tex:env name="tabular">
                    <tex:opt>t</tex:opt>
                    <tex:spec cat="bg"/>
                    <xsl:text>@</xsl:text>
                    <tex:spec cat="bg"/>
                    <tex:spec cat="eg"/>
                    <xsl:text>l@</xsl:text>
                    <tex:spec cat="bg"/>
                    <tex:spec cat="eg"/>
                    <tex:spec cat="eg"/>
                    <xsl:call-template name="OutputInterlinear"/>
                </tex:env>
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
                <tex:cmd name="par" gr="0" nl2="1"/>
                <xsl:apply-templates/>
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
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    <xsl:with-param name="originalContext" select="."/>
                </xsl:call-template>
                <xsl:apply-templates/>
                <xsl:call-template name="OutputFontAttributesEnd">
                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    <xsl:with-param name="originalContext" select="."/>
                </xsl:call-template>
                <tex:cmd name="par" gr="0" nl2="1"/>
            </xsl:when>
            <xsl:when test="@type='gls'">
                <xsl:choose>
                    <xsl:when test="count(../preceding-sibling::phrase) &gt; 0">
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                            <xsl:with-param name="originalContext" select="."/>
                        </xsl:call-template>
                        <xsl:apply-templates/>
                        <xsl:call-template name="OutputFontAttributesEnd">
                            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                            <xsl:with-param name="originalContext" select="."/>
                        </xsl:call-template>
                        <tex:cmd name="par" gr="0" nl2="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                            <xsl:with-param name="originalContext" select="."/>
                        </xsl:call-template>
                        <xsl:apply-templates/>
                        <xsl:call-template name="OutputFontAttributesEnd">
                            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                            <xsl:with-param name="originalContext" select="."/>
                        </xsl:call-template>
                        <tex:cmd name="par" gr="0" nl2="1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@type='note'">
                <xsl:text>Note: </xsl:text>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    <xsl:with-param name="originalContext" select="."/>
                </xsl:call-template>
                <xsl:apply-templates/>
                <xsl:call-template name="OutputFontAttributesEnd">
                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    <xsl:with-param name="originalContext" select="."/>
                </xsl:call-template>
                <tex:cmd name="par" gr="0" nl2="1"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        words
    -->
    <xsl:template match="words">
        <xsl:apply-templates/>
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
    </xsl:template>
    <!--
        iword/item[@type='txt']
    -->
    <xsl:template match="iword/item[@type='txt']">
        <!--<tex:group>-->
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:text>&#160;</xsl:text>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <!--</tex:group>-->
        <tex:spec cat="esc" gr="0" nl2="0"/>
        <tex:spec cat="esc" gr="0" nl2="1"/>
    </xsl:template>
    <!--
        iword/item[@type='gls']
    -->
    <xsl:template match="iword/item[@type='gls']">
        <!--      <tex:group>-->
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:if test="string(.)">
            <xsl:apply-templates/>
            <xsl:text>&#160;</xsl:text>
        </xsl:if>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <!--      </tex:group>-->
        <tex:spec cat="esc" gr="0" nl2="0"/>
        <tex:spec cat="esc" gr="0" nl2="1"/>
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
    </xsl:template>
    <!--
        morph/item
    -->
    <xsl:template match="morph/item[@type!='hn' and @type!='cf']">
        <!--<tex:group>-->
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:text>&#160;</xsl:text>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <!--               </tex:group>-->
        <tex:spec cat="esc" gr="0" nl2="0"/>
        <tex:spec cat="esc" gr="0" nl2="1"/>
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
    </xsl:template>
    <!-- ================================ -->
    <!--
        definition
    -->
    <xsl:template match="definition">
        <!--        <xsl:template match="definition[not(parent::example)]">-->
        <tex:group>
            <xsl:call-template name="DoType"/>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="OutputTypeAttributesEnd">
                <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
            </xsl:call-template>
            <xsl:call-template name="DoTypeEnd"/>
        </tex:group>
    </xsl:template>
    <!--
        listDefinition
    -->
    <xsl:template match="listDefinition">
        <xsl:if test="parent::example and count(preceding-sibling::listDefinition) = 0">
            <xsl:call-template name="OutputList"/>
        </xsl:if>
    </xsl:template>
    <!--
        chart
    -->
    <xsl:template match="chart">
        <xsl:if test="not(ancestor::figure or ancestor::tablenumbered or ancestor::example)">
            <tex:cmd name="vspace" nl1="1">
                <tex:parm>
                    <xsl:value-of select="$sBasicPointSize"/>
                    <xsl:text>pt</xsl:text>
                </tex:parm>
            </tex:cmd>
        </xsl:if>
        <xsl:call-template name="DoType"/>
        <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="OutputTypeAttributesEnd">
            <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
        </xsl:call-template>
        <xsl:call-template name="DoTypeEnd"/>
        <xsl:if test="not(ancestor::example) and not(child::img) and string-length(.) &gt; 0">
            <tex:spec cat="esc"/>
            <tex:spec cat="esc"/>
        </xsl:if>
    </xsl:template>
    <!--
        tree
    -->
    <xsl:template match="tree">
        <xsl:call-template name="DoType"/>
        <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="OutputTypeAttributesEnd">
            <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
        </xsl:call-template>
        <xsl:call-template name="DoTypeEnd"/>
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
                <xsl:if test="contains(@XeLaTeXSpecial,'pagebreak')">
                    <tex:cmd name="pagebreak" gr="0" nl2="0"/>
                </xsl:if>
                <tex:cmd name="hspace*">
                    <tex:parm>
                        <xsl:value-of select="$sBlockQuoteIndent"/>
                    </tex:parm>
                </tex:cmd>
                <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacetables='yes'">
                    <tex:spec cat="bg"/>
                    <tex:cmd name="singlespacing" gr="0" nl2="1"/>
                </xsl:if>
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
        <!-- new example handling: trying without all this 
            <xsl:choose>
            <xsl:when test="parent::example">
            <tex:spec cat="align"/>
            <xsl:call-template name="SingleSpaceAdjust"/>
            </xsl:when>
            <xsl:otherwise>
        -->
        <tex:spec cat="bg"/>
        <!-- 
            </xsl:otherwise>
            </xsl:choose>
        -->
        <!-- 
            <xsl:if test="parent::example">
            <tex:cmd name="vspace*">
            <tex:parm>-5.25ex</tex:parm>
            </tex:cmd>
            </xsl:if>
        -->
        <xsl:call-template name="DoType"/>
        <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
        </xsl:call-template>
        <xsl:call-template name="OutputTable"/>
        <xsl:call-template name="OutputTypeAttributesEnd">
            <xsl:with-param name="sList" select="@XeLaTeXSpecial"/>
        </xsl:call-template>
        <xsl:call-template name="DoTypeEnd"/>
        <!--   with new ay of handling examples, trying without this     <xsl:if test="not(parent::example)">-->
        <tex:spec cat="eg"/>
        <!--        </xsl:if>-->
        <xsl:choose>
            <xsl:when test="not(parent::example) and not(ancestor::table) and not(ancestor::li)">
                <!-- longtable does this effectively anyway
                    <tex:cmd name="vspace" nl2="1">
                    <tex:parm><xsl:value-of select="$sBasicPointSize"/>
                    <xsl:text>pt</xsl:text></tex:parm>
                    </tex:cmd> -->
                <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespacetables='yes'">
                    <tex:spec cat="eg"/>
                </xsl:if>
                <tex:spec cat="nl"/>
            </xsl:when>
            <!-- not needed 
                <xsl:when test="ancestor::li">
                <xsl:attribute name="space-after">
                <xsl:value-of select="$sBasicPointSize div 2"/>pt</xsl:attribute>
                </xsl:when>
            -->
        </xsl:choose>
    </xsl:template>
    <!--
        headerRow for a table
    -->
    <xsl:template match="headerRow">
        <!--
            not using
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
            <xsl:call-template name="DoRowSpanAdjust">
                <xsl:with-param name="sList" select="$bInARowSpan"/>
            </xsl:call-template>
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
        <xsl:variable name="iCountBr" select="count(child::br)"/>
        <xsl:call-template name="DoEmbeddedBrBegin">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <!--        <xsl:if test="following-sibling::th | following-sibling::td | following-sibling::col">
            <xsl:text>&#xa0;</xsl:text>  Not sure why we have this 2010.07.10; it's not there for td's
        </xsl:if>
-->
        <xsl:call-template name="DoEmbeddedBrEnd">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:call-template name="DoTypeEnd"/>
        <xsl:for-each select="..">
            <!-- have to do the row's type processing here -->
            <xsl:call-template name="DoTypeEnd"/>
        </xsl:for-each>
        <xsl:call-template name="DoCellAttributesEnd"/>
        <tex:spec cat="eg"/>
        <xsl:if test="following-sibling::th | following-sibling::td | following-sibling::col">
            <tex:spec cat="align"/>
        </xsl:if>
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
        <xsl:if test="contains(@XeLaTeXSpecial,'line-before')">
            <tex:cmd name="midrule" gr="0"/>
        </xsl:if>
        <!--      <xsl:call-template name="DoType"/>-->
        <xsl:call-template name="DoRowBackgroundColor"/>
        <xsl:apply-templates>
            <xsl:with-param name="iBorder" select="$iBorder"/>
        </xsl:apply-templates>
        <tex:spec cat="esc"/>
        <tex:spec cat="esc"/>
        <xsl:if test="contains(ancestor::table/@XeLaTeXSpecial,'row-separation')">
            <tex:spec cat="lsb"/>
            <xsl:for-each select="ancestor::table[@XeLaTeXSpecial]">
                <xsl:call-template name="HandleXeLaTeXSpecialCommand">
                    <xsl:with-param name="sPattern" select="'row-separation='"/>
                    <xsl:with-param name="default" select="'0pt'"/>
                </xsl:call-template>
                <tex:spec cat="rsb"/>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="contains(@XeLaTeXSpecial,'line-after')">
            <tex:cmd name="midrule" gr="0"/>
        </xsl:if>
        <xsl:if test="position()=last()">
            <xsl:call-template name="CreateHorizontalLine">
                <xsl:with-param name="iBorder" select="$iBorder"/>
                <xsl:with-param name="bIsLast" select="'Y'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--
        col for a table
    -->
    <xsl:template match="td | col">
        <xsl:param name="iBorder" select="0"/>
        <xsl:variable name="bInARowSpan">
            <xsl:call-template name="DetermineIfInARowSpan"/>
        </xsl:variable>
        <xsl:if test="contains($bInARowSpan,'Y')">
            <xsl:call-template name="HandleFootnotesInTableHeader"/>
            <xsl:call-template name="DoRowSpanAdjust">
                <xsl:with-param name="sList" select="$bInARowSpan"/>
            </xsl:call-template>
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
            <xsl:text>raggedright </xsl:text>
        </xsl:if>
        <xsl:for-each select="..">
            <!-- have to do the row's type processing here -->
            <xsl:call-template name="DoType"/>
        </xsl:for-each>
        <xsl:call-template name="DoType"/>
        <!--      <xsl:call-template name="OutputBackgroundColor"/>-->
        <xsl:variable name="iCountBr" select="count(child::br)"/>
        <xsl:call-template name="DoEmbeddedBrBegin">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="DoEmbeddedBrEnd">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:if test="not(contains($bInARowSpan,'Y'))">
            <xsl:call-template name="HandleFootnotesInTableHeader"/>
        </xsl:if>
        <xsl:call-template name="DoTypeEnd"/>
        <xsl:for-each select="..">
            <!-- have to do the row's type processing here -->
            <xsl:call-template name="DoTypeEnd"/>
        </xsl:for-each>
        <xsl:call-template name="DoCellAttributesEnd"/>
        <!-- if this td has a rowspan, any endnotes in it will not have their text appear at the bottom of the page; make it happen -->
        <xsl:if test="@rowspan &gt; 0 and descendant-or-self::endnote">
            <xsl:for-each select="descendant-or-self::endnote">
                <xsl:apply-templates select=".">
                    <xsl:with-param name="sTeXFootnoteKind" select="'footnotetext'"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="following-sibling::td | following-sibling::col">
            <!--  What was this for???  2009.12.04            <xsl:text>&#xa0;</xsl:text>-->
            <tex:spec cat="align"/>
        </xsl:if>
    </xsl:template>
    <!--
        caption for a table
    -->
    <xsl:template match="caption | endCaption">
        <xsl:param name="iNumCols" select="2"/>
        <xsl:if test="not(ancestor::tablenumbered)">
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
        </xsl:if>
    </xsl:template>
    <!--
        exampleHeading
    -->
    <xsl:template match="exampleHeading">
        <xsl:apply-templates/>
        <xsl:call-template name="CreateBreakAfter">
            <xsl:with-param name="example" select="parent::excample"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        endnote in langData or gloss
    -->
    <xsl:template match="endnote[parent::langData or parent::gloss]">
        <xsl:param name="sTeXFootnoteKind" select="'footnote'"/>
        <!-- need to end any font attributes in effect, do the endnote, and then re-start any font attributes-->
        <xsl:variable name="language" select="key('LanguageID',../@lang)"/>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="$language"/>
        </xsl:call-template>
        <xsl:call-template name="DoEndnote">
            <xsl:with-param name="sTeXFootnoteKind" select="$sTeXFootnoteKind"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="$language"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        endnote in li
    -->
    <xsl:template match="endnote[parent::li]">
        <xsl:param name="sTeXFootnoteKind" select="'footnote'"/>
        <!-- need to end any type attributes in effect, do the endnote, and then re-start any type attributes-->
        <xsl:call-template name="DoTypeEnd">
            <xsl:with-param name="type" select="../../@type"/>
        </xsl:call-template>
        <xsl:call-template name="DoEndnote">
            <xsl:with-param name="sTeXFootnoteKind" select="$sTeXFootnoteKind"/>
        </xsl:call-template>
        <xsl:call-template name="DoType">
            <xsl:with-param name="type" select="../../@type"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        ...Ref (InMarker)
    -->
    <xsl:template match="appendixRef" mode="InMarker"/>
    <xsl:template match="comment" mode="InMarker"/>
    <xsl:template match="endnote" mode="InMarker"/>
    <xsl:template match="endnoteRef" mode="InMarker"/>
    <xsl:template match="exampleRef" mode="InMarker"/>
    <xsl:template match="genericTarget" mode="InMarker"/>
    <xsl:template match="indexedItem" mode="InMarker"/>
    <xsl:template match="indexedRangeBegin" mode="InMarker"/>
    <xsl:template match="link" mode="InMarker"/>
    <xsl:template match="q" mode="InMarker"/>
    <xsl:template match="sectionRef" mode="InMarker"/>
    <!--
        indexedItem or indexedRangeBegin
    -->
    <xsl:template match="indexedItem | indexedRangeBegin">
        <xsl:call-template name="CreateAddToIndex">
            <xsl:with-param name="id">
                <xsl:call-template name="CreateIndexedItemID">
                    <xsl:with-param name="sTermId" select="@term"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        indexedRangeEnd
    -->
    <xsl:template match="indexedRangeEnd">
        <xsl:call-template name="CreateAddToIndex">
            <xsl:with-param name="id">
                <xsl:call-template name="CreateIndexedItemID">
                    <xsl:with-param name="sTermId" select="@begin"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        term
    -->
    <xsl:template match="term" mode="InIndex">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- ===========================================================
        BR
        =========================================================== -->
    <xsl:template match="br">
        <xsl:choose>
            <xsl:when test="ancestor::langData or ancestor::td or ancestor::th or ancestor::gloss">
                <!-- these all are using the \vbox{\hbox{}\hbox{}} approach -->
                <tex:spec cat="eg"/>
                <tex:spec cat="esc"/>
                <xsl:text>hbox</xsl:text>
                <tex:spec cat="bg"/>
                <tex:cmd name="strut"/>
            </xsl:when>
            <xsl:when test="not(ancestor-or-self::td) and not(ancestor-or-self::th) and not(preceding-sibling::*[1][name()='table'])">
                <xsl:variable name="previousTextOrBr" select="preceding-sibling::text()[1] | preceding-sibling::*[1][name()='br']"/>
                <xsl:if test="name($previousTextOrBr[2])='br'">
                    <!-- two <br/>s in a row need some content; use a non-breaking space -->
                    <xsl:text>&#xa0;</xsl:text>
                </xsl:if>
                <tex:spec cat="esc"/>
                <tex:spec cat="esc"/>
            </xsl:when>
            <xsl:when test="ancestor::th[1][string-length(@width) &gt; 0]">
                <tex:spec cat="esc"/>
                <tex:spec cat="esc"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <!-- ===========================================================
        GLOSS
        =========================================================== -->
    <xsl:template match="gloss" mode="InMarker">
        <xsl:apply-templates select="self::*"/>
    </xsl:template>
    <xsl:template match="gloss">
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:variable name="iCountBr" select="count(child::br)"/>
        <xsl:call-template name="DoEmbeddedBrBegin">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="DoEmbeddedBrEnd">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="abbreviationsShownHere">
        <xsl:choose>
            <xsl:when test="ancestor::endnote">
                <xsl:choose>
                    <xsl:when test="parent::p">
                        <xsl:call-template name="OutputAbbreviationsInCommaSeparatedList"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="OutputAbbreviationsInCommaSeparatedList"/>
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
            <xsl:call-template name="DoType"/>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="."/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
            <xsl:if test="not(@font-style) and not(key('TypeID',@type)/@font-style)">
                <tex:spec cat="esc"/>
                <xsl:text>textit</xsl:text>
                <tex:spec cat="bg"/>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="not(@font-style) and not(key('TypeID',@type)/@font-style)">
                <tex:spec cat="eg"/>
            </xsl:if>
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="."/>
                <xsl:with-param name="originalContext" select="."/>
            </xsl:call-template>
            <xsl:call-template name="DoTypeEnd"/>
        </tex:group>
    </xsl:template>
    <!-- ===========================================================
        LANDSCAPE
        =========================================================== -->
    <xsl:template match="landscape">
        <tex:cmd name="landscape" gr="0" nl2="1"/>
        <xsl:apply-templates/>
        <tex:cmd name="endlandscape" gr="0" nl2="1"/>
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
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="$language"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:variable name="iCountBr" select="count(child::br)"/>
        <xsl:call-template name="DoEmbeddedBrBegin">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="DoEmbeddedBrEnd">
            <xsl:with-param name="iCountBr" select="$iCountBr"/>
        </xsl:call-template>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="$language"/>
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <tex:spec cat="eg"/>
    </xsl:template>
    <!-- ===========================================================
        OBJECT
        =========================================================== -->
    <xsl:template match="object" mode="InMarker">
        <xsl:apply-templates select="self::*"/>
    </xsl:template>
    <xsl:template match="object">
        <tex:spec cat="bg"/>
        <xsl:call-template name="DoType">
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <xsl:for-each select="key('TypeID',@type)">
            <xsl:value-of select="@before"/>
        </xsl:for-each>
        <xsl:apply-templates/>
        <xsl:for-each select="key('TypeID',@type)">
            <xsl:value-of select="@after"/>
        </xsl:for-each>
        <xsl:call-template name="DoTypeEnd">
            <xsl:with-param name="originalContext" select="."/>
        </xsl:call-template>
        <tex:spec cat="eg"/>
    </xsl:template>
    <!-- ===========================================================
        IMG
        =========================================================== -->
    <xsl:template match="img" mode="InMarker">
        <xsl:apply-templates select="self::*"/>
    </xsl:template>
    <xsl:template match="img">
        <xsl:variable name="sImgFile" select="normalize-space(translate(@src,'\','/'))"/>
        <xsl:variable name="sExtension" select="substring($sImgFile,string-length($sImgFile)-3,4)"/>
        <xsl:choose>
            <xsl:when test="translate($sExtension,'GIF','gif')='.gif'">
                <xsl:if test="not(ancestor::example)">
                    <tex:cmd name="par"/>
                </xsl:if>
                <xsl:call-template name="ReportTeXCannotHandleThisMessage">
                    <xsl:with-param name="sMessage">
                        <xsl:text>We're sorry, but the graphic file </xsl:text>
                        <xsl:value-of select="$sImgFile"/>
                        <xsl:text> is in GIF format and this processor cannot handle GIF format.  You will need to convert the file to a different format.  We suggest using PNG format or JPG format.  Also see section 11.17.1.1 in the XLingPaper user documentation.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$sExtension='.svg'">
                <xsl:if test="not(ancestor::example)">
                    <tex:cmd name="par"/>
                </xsl:if>
       <!--   <xsl:variable name="sPDFFile" select="concat(substring-before($sImgFile,$sExtension),'.pdf')"/>
                
<!-\-                <xsl:variable name="absoluteURI" select="resolve-uri($sPDFFile, base-uri(.))" as="xs:anyURI"/>-\->
                <xsl:if test="file:exists(file:new($sPDFFile))" xmlns:file="java.io.File">
                    <xsl:text>SPLAT!!</xsl:text>
</xsl:if>                    
                
                <xsl:variable name="bPDFExists" select="boolean(document($sPDFFile))"/>
               <!-\-  tries to read the pdf file as if it were XML and still fails.  It also takes a long time. -\->  
                <xsl:choose>
                    <xsl:when test="$bPDFExists">SPLAT!!!</xsl:when>
                    <xsl:otherwise>
                        
                    </xsl:otherwise>
                </xsl:choose>-->


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
                        <xsl:text> for a free tool that does this conversion.  Also see section 11.17.1.1 in the XLingPaper user documentation.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
                <tex:cmd name="par" gr="0" nl2="1"/>
            </xsl:when>
            <xsl:when test="$sExtension='.pdf'">
                <xsl:choose>
                    <xsl:when test="ancestor::example">
                        <tex:cmd name="parbox">
                            <tex:opt>t</tex:opt>
                            <tex:parm>
                                <tex:cmd name="textwidth" gr="0" nl2="0"/>
                                <xsl:text> - </xsl:text>
                                <xsl:value-of select="$sBlockQuoteIndent"/>
                                <xsl:text> - </xsl:text>
                                <xsl:value-of select="$iExampleWidth"/>
                                <xsl:text>em</xsl:text>
                            </tex:parm>
                            <tex:parm>
                                <xsl:call-template name="DoImageFile">
                                    <xsl:with-param name="sXeTeXGraphicFile" select="'XeTeXpdffile'"/>
                                    <xsl:with-param name="sImgFile" select="$sImgFile"/>
                                </xsl:call-template>
                            </tex:parm>
                        </tex:cmd>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="DoImageFile">
                            <xsl:with-param name="sXeTeXGraphicFile" select="'XeTeXpdffile'"/>
                            <xsl:with-param name="sImgFile" select="$sImgFile"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="ancestor::example">
                        <tex:cmd name="parbox">
                            <tex:opt>t</tex:opt>
                            <tex:parm>
                                <tex:cmd name="textwidth" gr="0" nl2="0"/>
                                <xsl:text> - </xsl:text>
                                <xsl:value-of select="$sBlockQuoteIndent"/>
                                <xsl:text> - </xsl:text>
                                <xsl:value-of select="$iExampleWidth"/>
                                <xsl:text>em</xsl:text>
                            </tex:parm>
                            <tex:parm>
                                <xsl:call-template name="DoImageFile">
                                    <xsl:with-param name="sXeTeXGraphicFile" select="'XeTeXpicfile'"/>
                                    <xsl:with-param name="sImgFile" select="$sImgFile"/>
                                </xsl:call-template>
                            </tex:parm>
                        </tex:cmd>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="DoImageFile">
                            <xsl:with-param name="sXeTeXGraphicFile" select="'XeTeXpicfile'"/>
                            <xsl:with-param name="sImgFile" select="$sImgFile"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ===========================================================
        INTERLINEAR TEXT
        =========================================================== -->
    <!--  
        interlinear-text
    -->
    <xsl:template match="interlinear-text">
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single'">
            <tex:spec cat="bg"/>
            <tex:cmd name="singlespacing" gr="0" nl2="1"/>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="$sLineSpacing and $sLineSpacing!='single'">
            <tex:spec cat="eg"/>
        </xsl:if>
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
        <tex:group>
            <tex:cmd name="centering">
                <tex:parm>
                    <!--            <xsl:call-template name="AdjustForBeginOfLaTeXEnvironment"/>-->
                    <tex:cmd name="large" gr="0"/>
                    <!-- default formatting is bold -->
                    <tex:spec cat="esc"/>
                    <xsl:text>textbf</xsl:text>
                    <tex:spec cat="bg"/>
                    <xsl:apply-templates/>
                    <xsl:variable name="contentOfThisElement">
                        <xsl:apply-templates/>
                    </xsl:variable>
                    <tex:spec cat="esc"/>
                    <tex:spec cat="esc"/>
                    <tex:spec cat="eg"/>
                </tex:parm>
            </tex:cmd>
        </tex:group>
    </xsl:template>
    <!--  
        source
    -->
    <xsl:template match="source">
        <tex:group>
            <tex:cmd name="centering">
                <tex:parm>
                    <!--            <xsl:call-template name="AdjustForBeginOfLaTeXEnvironment"/>-->
                    <!-- default formatting is italic -->
                    <tex:spec cat="esc"/>
                    <xsl:text>textit</xsl:text>
                    <tex:spec cat="bg"/>
                    <xsl:apply-templates/>
                    <tex:spec cat="esc"/>
                    <tex:spec cat="esc"/>
                    <tex:spec cat="eg"/>
                </tex:parm>
            </tex:cmd>
        </tex:group>
    </xsl:template>
    <!--  
        AdjustLayoutParameterUnitName
    -->
    <xsl:template name="AdjustLayoutParameterUnitName">
        <xsl:param name="sLayoutParam"/>
        <xsl:choose>
            <xsl:when test="$iMagnificationFactor!=1">
                <xsl:variable name="iLength" select="string-length(normalize-space($sLayoutParam))"/>
                <xsl:value-of select="substring($sLayoutParam,1, $iLength - 2)"/>
                <xsl:text>true</xsl:text>
                <xsl:value-of select="substring($sLayoutParam, $iLength - 1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sLayoutParam"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        CalculateColumnsInInterlinearLine
    -->
    <xsl:template name="CalculateColumnsInInterlinearLine">
        <xsl:param name="sList"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:text>x</xsl:text>
        <xsl:if test="$sRest">
            <xsl:call-template name="CalculateColumnsInInterlinearLine">
                <xsl:with-param name="sList" select="$sRest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
        CalculateSectionNumberIndent
    -->
    <xsl:template name="CalculateSectionNumberIndent">
        <xsl:for-each select="ancestor::*[contains(name(),'section') or name()='appendix' or name()='chapter' or name()='chapterBeforePart']">
            <xsl:call-template name="OutputSectionNumber"/>
            <tex:spec cat="esc"/>
            <xsl:text>&#x20;</xsl:text>
        </xsl:for-each>
    </xsl:template>
    <!--  
        CalculateSectionNumberWidth
    -->
    <xsl:template name="CalculateSectionNumberWidth">
        <xsl:call-template name="OutputSectionNumber"/>
        <tex:spec cat="esc"/>
        <xsl:text>thinspace</xsl:text>
        <tex:spec cat="esc"/>
        <xsl:text>thinspace</xsl:text>
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
        ConvertPercent20ToSpace
    -->
    <xsl:template name="ConvertPercent20ToSpace">
        <xsl:param name="sImageFile"/>
        <xsl:choose>
            <xsl:when test="contains($sImageFile,$sPercent20)">
                <xsl:value-of select="substring-before($sImageFile,'%20')"/>
                <xsl:text>&#x20;</xsl:text>
                <xsl:call-template name="ConvertPercent20ToSpace">
                    <xsl:with-param name="sImageFile" select="substring-after($sImageFile,$sPercent20)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sImageFile"/>
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
        CountPreviousRowspansInMyRow
    -->
    <xsl:template name="CountPreviousRowspansInMyRow">
        <xsl:param name="previousCellsWithRowspansSpanningMyRow"/>
        <xsl:param name="iPosition"/>
        <xsl:param name="iMyInSituColumnNumber"/>
        <xsl:variable name="sOneYForEachColumn">
            <xsl:for-each select="$previousCellsWithRowspansSpanningMyRow">
                <!-- sorting is crucial here; we need the previous ones to go from left to right -->
                <xsl:sort select="count(preceding-sibling::td) +count(preceding-sibling::th)"/>
                <xsl:if test="position() = $iPosition">
                    <xsl:variable name="iRowNumberOfMyCell" select="count(../preceding-sibling::tr) + 1"/>
                    <xsl:variable name="iRealColumnNumberOfCell">
                        <xsl:call-template name="GetRealColumnNumberOfCell">
                            <xsl:with-param name="iRowNumberOfMyCell" select="$iRowNumberOfMyCell"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:if test="$iRealColumnNumberOfCell &lt;= ($iMyInSituColumnNumber + $iPosition)">
                        <!-- the real column is before or at the adjusted cell's column number -->
                        <xsl:choose>
                            <xsl:when test="@colspan &gt; 1">
                                <xsl:value-of select="substring($sYs,1,@colspan)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>Y</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$sOneYForEachColumn"/>
        <xsl:if test="$iPosition &lt; count($previousCellsWithRowspansSpanningMyRow)">
            <xsl:call-template name="CountPreviousRowspansInMyRow">
                <xsl:with-param name="previousCellsWithRowspansSpanningMyRow" select="$previousCellsWithRowspansSpanningMyRow"/>
                <xsl:with-param name="iPosition" select="$iPosition + 1"/>
                <xsl:with-param name="iMyInSituColumnNumber" select="$iMyInSituColumnNumber + string-length($sOneYForEachColumn)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--
        CreateAddToContents
    -->
    <xsl:template name="CreateAddToContents">
        <xsl:param name="id"/>
        <xsl:if test="$bHasContents='Y'">
            <tex:cmd name="XLingPaperaddtocontents">
                <tex:parm>
                    <xsl:value-of select="translate($id,$sIDcharsToMap, $sIDcharsMapped)"/>
                </tex:parm>
            </tex:cmd>
        </xsl:if>
    </xsl:template>
    <!--
        CreateAddToIndex
    -->
    <xsl:template name="CreateAddToIndex">
        <xsl:param name="id"/>
        <xsl:if test="$bHasIndex='Y'">
            <tex:cmd name="XLingPaperaddtoindex">
                <tex:parm>
                    <xsl:value-of select="$id"/>
                </tex:parm>
            </tex:cmd>
            <xsl:call-template name="DoInternalTargetBegin">
                <xsl:with-param name="sName" select="$id"/>
            </xsl:call-template>
            <xsl:call-template name="DoInternalTargetEnd"/>
        </xsl:if>
    </xsl:template>
    <!--
        CreateAllNumberingLevelIndentAndWidthCommands
    -->
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
    <!--
        CreateBreakAfter
    -->
    <xsl:template name="CreateBreakAfter">
        <xsl:param name="example"/>
        <!--          <xsl:for-each select="$example">
        <xsl:choose>
            <xsl:when test="parent::td">
                <tex:cmd name="vspace*">
                    <tex:parm>
                        <tex:cmd name="baselineskip"/>
                    </tex:parm>
                </tex:cmd>
            </xsl:when>
            <xsl:otherwise> -->
        <tex:spec cat="esc"/>
        <tex:spec cat="esc"/>
        <xsl:text>*
</xsl:text>
        <!--            </xsl:otherwise>
        </xsl:choose>
        </xsl:for-each>
-->
    </xsl:template>
    <!--
        CreateColumnSpec
    -->
    <xsl:template name="CreateColumnSpec">
        <xsl:param name="iColspan" select="0"/>
        <xsl:param name="iBorder" select="0"/>
        <xsl:param name="sAlignDefault" select="'j'"/>
        <xsl:param name="bUseWidth" select="'Y'"/>
        <xsl:call-template name="CreateVerticalLine">
            <xsl:with-param name="iBorder" select="$iBorder"/>
        </xsl:call-template>
        <xsl:call-template name="CreateColumnSpecBackgroundColor"/>
        <xsl:choose>
            <xsl:when test="string-length(@width) &gt; 0 and $bUseWidth='Y'">
                <xsl:text>p</xsl:text>
                <tex:spec cat="bg"/>
                <xsl:choose>
                    <xsl:when test="contains(@width,'%')">
                        <xsl:call-template name="GetColumnWidthBasedOnPercentage">
                            <xsl:with-param name="iPercentage" select="substring-before(normalize-space(@width),'%')"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@width"/>
                    </xsl:otherwise>
                </xsl:choose>
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
                <xsl:with-param name="bUseWidth" select="$bUseWidth"/>
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
        CreateHorizontalLine
    -->
    <xsl:template name="CreateHorizontalLine">
        <xsl:param name="iBorder"/>
        <xsl:param name="bIsLast" select="'N'"/>
        <xsl:variable name="iCountAncestorEndnotes" select="count(ancestor::endnote)"/>
        <xsl:choose>
            <xsl:when test="$iBorder=1">
                <xsl:choose>
                    <xsl:when test="$bUseBookTabs='Y'">
                        <xsl:choose>
                            <xsl:when test="name()='tr' and count(preceding-sibling::tr)=0">
                                <xsl:call-template name="CreateTopRule">
                                    <xsl:with-param name="iCountAncestorEndnotes" select="$iCountAncestorEndnotes"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="name()='table' and tr[1]/th">
                                <xsl:call-template name="CreateTopRule">
                                    <xsl:with-param name="iCountAncestorEndnotes" select="$iCountAncestorEndnotes"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="$bIsLast='Y' and ancestor-or-self::table[1][@border &gt; 0]">
                                <xsl:if test="count(ancestor::table[@border &gt; 0][count(ancestor::endnote)=$iCountAncestorEndnotes])=1">
                                    <tex:cmd name="bottomrule" gr="0"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="not(th) and preceding-sibling::tr[1][th]">
                                <tex:cmd name="midrule" gr="0"/>
                                <xsl:if test="not(ancestor::example) and not(../ancestor::table) and count(ancestor::table[@border &gt; 0])=1">
                                    <tex:cmd name="endhead" gr="0" sp="1" nl2="0"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="th[following-sibling::td] and preceding-sibling::tr[1][th[not(following-sibling::td)]]">
                                <tex:cmd name="midrule" gr="0"/>
                                <xsl:if test="not(ancestor::example) and not(../ancestor::table) and not(preceding-sibling::tr[position() &gt; 1][th[not(following-sibling::td)]])">
                                    <tex:cmd name="endhead" gr="0" sp="1" nl2="0"/>
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
        CreateIndexTermID
    -->
    <xsl:template name="CreateIndexTermID">
        <xsl:param name="sTermId"/>
        <xsl:text>rXLingPapIndexTerm.</xsl:text>
        <xsl:value-of select="$sTermId"/>
    </xsl:template>
    <!--
        CreateNumberingLevelIndentAndWidthCommands
    -->
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
        <xsl:param name="iCountAncestorEndnotes"/>
        <xsl:if test="ancestor-or-self::table[1][@border &gt; 0] and count(ancestor-or-self::table[@border &gt; 0][count(ancestor::endnote)=$iCountAncestorEndnotes])=1">
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
        CreateVerticalLine
    -->
    <xsl:template name="CreateVerticalLine">
        <xsl:param name="iBorder"/>
        <xsl:param name="bDisallowVerticalLines" select="$bUseBookTabs"/>
        <xsl:if test="$bDisallowVerticalLines!='Y'">
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
            <xsl:variable name="bIsGraphite">
                <xsl:choose>
                    <xsl:when test="contains(@XeLaTeXSpecial, 'graphite')">Y</xsl:when>
                    <xsl:when test="contains(../@XeLaTeXSpecial, 'graphite')">Y</xsl:when>
                    <xsl:otherwise>N</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$bIsGraphite='Y'">
                <tex:opt>
                    <xsl:text>Renderer=Graphite</xsl:text>
                </tex:opt>
            </xsl:if>
            <tex:parm>
                <xsl:choose>
                    <!-- try to map some "default" fonts to potential real fonts -->
                    <xsl:when test="$sBaseFontName='Monospaced'">Courier New</xsl:when>
                    <xsl:when test="$sBaseFontName='SansSerif'">Arial</xsl:when>
                    <xsl:when test="$sBaseFontName='Serif'">Times New Roman</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$sBaseFontName"/>
                    </xsl:otherwise>
                </xsl:choose>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        DetermineIfInARowSpan
        (Returns a string of 'Y's, one for each column covered by a previous rowspan)
    -->
    <xsl:template name="DetermineIfInARowSpan">
        <xsl:variable name="myCell" select="."/>
        <xsl:variable name="iRowNumberOfMyCell" select="count(../preceding-sibling::tr) + 1"/>
        <xsl:variable name="previousCellsWithRowspansSpanningMyRow" select="../preceding-sibling::tr/th[@rowspan][($iRowNumberOfMyCell - (count(../preceding-sibling::tr) + 1)) + 1 &lt;= @rowspan] | ../preceding-sibling::tr/td[@rowspan][($iRowNumberOfMyCell - (count(../preceding-sibling::tr) + 1)) + 1 &lt;= @rowspan]"/>
        <xsl:if test="count($previousCellsWithRowspansSpanningMyRow) &gt; 0">
            <!-- We now know that the current cell is in a row that is included by some previous cell's rowspan. -->
            <xsl:for-each select="$previousCellsWithRowspansSpanningMyRow">
                <!-- sorting is crucial here; we need the previous ones to go from left to right -->
                <xsl:sort select="count(preceding-sibling::td) +count(preceding-sibling::th)"/>
                <!-- Figure out if the current cell is just after such a rowspan (or sequence of contiguous rowspans) by
                    getting the real (absolute) column number of  the preceding cell and comparing it to the adjusted 
                    in situ column number of the current cell. 
                -->
                <xsl:variable name="iRealColumnNumberOfCell">
                    <xsl:call-template name="GetRealColumnNumberOfCell">
                        <xsl:with-param name="iRowNumberOfCell" select="count(../preceding-sibling::tr) + 1"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="myPrecedingSiblings" select="$myCell/preceding-sibling::td | $myCell/preceding-sibling::th"/>
                <xsl:variable name="iMyInSituColumnNumber" select="count($myPrecedingSiblings[not(number(@colspan) &gt; 0)]) + sum($myPrecedingSiblings[number(@colspan) &gt; 0]/@colspan)"/>
                <xsl:if test="$iRealColumnNumberOfCell = ($iMyInSituColumnNumber + position()) - 1">
                    <xsl:choose>
                        <xsl:when test="@colspan &gt; 1">
                            <!-- if this previous cell has a colspan, we need to account for it -->
                            <xsl:value-of select="substring($sYs,1,@colspan)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>Y</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <!--
        DoBreakBeforeLink
    -->
    <xsl:template name="DoBreakBeforeLink">
        <xsl:if test="contains(@XeLaTeXSpecial,'break-before')">
            <!-- since \\ will fail in some table cells, only do in paragraphs for now -->
            <xsl:if test=" ancestor::p or ancestor::pc">
                <tex:spec cat="esc"/>
                <tex:spec cat="esc"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--
        DoCellAttributes
    -->
    <xsl:template name="DoCellAttributes">
        <xsl:param name="iBorder" select="0"/>
        <xsl:param name="bInARowSpan"/>
        <xsl:variable name="valignFixup">
            <xsl:call-template name="HandleXeLaTeXSpecialCommand">
                <xsl:with-param name="sPattern" select="'valign-fixup='"/>
                <xsl:with-param name="default" select="'0pt'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="number(@rowspan) &gt; 0 and number(@colspan) &gt; 0 or $valignFixup!='0pt' and number(@colspan) &gt; 0">
                <xsl:call-template name="HandleMulticolumnInCell">
                    <xsl:with-param name="bInARowSpan" select="$bInARowSpan"/>
                    <xsl:with-param name="iBorder" select="$iBorder"/>
                    <xsl:with-param name="iColSpan" select="@colspan"/>
                </xsl:call-template>
                <xsl:call-template name="HandleMultirowInCell">
                    <xsl:with-param name="valignFixup" select="$valignFixup"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="number(@colspan) &gt; 0">
                <xsl:call-template name="HandleMulticolumnInCell">
                    <xsl:with-param name="bInARowSpan" select="$bInARowSpan"/>
                    <xsl:with-param name="iBorder" select="$iBorder"/>
                    <xsl:with-param name="iColSpan" select="@colspan"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="number(@rowspan) &gt; 0 or $valignFixup!='0pt'">
                <xsl:call-template name="HandleMulticolumnInCell">
                    <xsl:with-param name="bInARowSpan" select="$bInARowSpan"/>
                    <xsl:with-param name="iBorder" select="$iBorder"/>
                    <xsl:with-param name="iColSpan" select="'1'"/>
                </xsl:call-template>
                <xsl:call-template name="HandleMultirowInCell">
                    <xsl:with-param name="valignFixup" select="$valignFixup"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@align">
                <xsl:call-template name="HandleMulticolumnInCell">
                    <xsl:with-param name="bInARowSpan" select="$bInARowSpan"/>
                    <xsl:with-param name="iBorder" select="$iBorder"/>
                    <xsl:with-param name="iColSpan" select="'1'"/>
                </xsl:call-template>
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
        <xsl:variable name="valignFixup">
            <xsl:call-template name="HandleXeLaTeXSpecialCommand">
                <xsl:with-param name="sPattern" select="'valign-fixup='"/>
                <xsl:with-param name="default" select="'0pt'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="number(@rowspan) &gt; 0 and number(@colspan) &gt; 0">
                <tex:spec cat="eg"/>
                <tex:spec cat="eg"/>
            </xsl:when>
            <xsl:when test="number(@colspan) &gt; 0">
                <tex:spec cat="eg"/>
            </xsl:when>
            <xsl:when test="number(@rowspan) &gt; 0 or $valignFixup!='0pt'">
                <tex:spec cat="eg"/>
                <tex:spec cat="eg"/>
            </xsl:when>
            <xsl:when test="@align">
                <tex:spec cat="eg"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        DoColor
    -->
    <xsl:template name="DoColor">
        <xsl:param name="sFontColor"/>
        <tex:cmd name="textcolor">
            <tex:opt>rgb</tex:opt>
            <tex:parm>
                <xsl:choose>
                    <xsl:when test="string-length($sFontColor) &gt; 2">
                        <xsl:call-template name="GetColorDecimalCodesFromHexCode">
                            <xsl:with-param name="sColorHexCode">
                                <xsl:call-template name="GetColorHexCode">
                                    <xsl:with-param name="sColor" select="$sFontColor"/>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- use black -->
                        <xsl:text>0,0,0</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </tex:parm>
        </tex:cmd>
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
    </xsl:template>
    <!--
        DoEmbeddedBrBegin
    -->
    <xsl:template name="DoEmbeddedBrBegin">
        <xsl:param name="iCountBr"/>
        <xsl:if test="$iCountBr!=0">
            <!--<tex:spec cat="esc"/>
                <xsl:text>raise</xsl:text>
                <xsl:choose>
                <xsl:when test="$iCountBr=1">.5</xsl:when>
                <xsl:when test="$iCountBr=2">1</xsl:when>
                <xsl:when test="$iCountBr=3">1.5</xsl:when>
                <xsl:when test="$iCountBr=4">2</xsl:when>
                <xsl:when test="$iCountBr=5">2.5</xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>-->
            <!--            <tex:spec cat="esc"/>
                <xsl:text>multiply1by</xsl:text>
                <xsl:value-of select="$iCountBr"/> -->
            <!--            <tex:cmd name="baselineskip" gr="0"/>-->
            <tex:spec cat="esc"/>
            <xsl:text>vbox</xsl:text>
            <tex:spec cat="bg"/>
            <tex:spec cat="esc"/>
            <xsl:text>hbox</xsl:text>
            <tex:spec cat="bg"/>
            <tex:cmd name="strut"/>
        </xsl:if>
    </xsl:template>
    <!--
        DoEmbeddedBrEnd
    -->
    <xsl:template name="DoEmbeddedBrEnd">
        <xsl:param name="iCountBr"/>
        <xsl:if test="$iCountBr!=0">
            <tex:spec cat="eg"/>
            <tex:spec cat="eg"/>
        </xsl:if>
    </xsl:template>
    <!--
        DoExternalHyperRefBegin
    -->
    <xsl:template name="DoExternalHyperRefBegin">
        <xsl:param name="sName"/>
        <tex:spec cat="esc"/>
        <xsl:text>href</xsl:text>
        <tex:spec cat="bg"/>
        <xsl:value-of select="$sName"/>
        <tex:spec cat="eg"/>
        <tex:spec cat="bg"/>
    </xsl:template>
    <!--  
        DoExternalHyperRefEnd
    -->
    <xsl:template name="DoExternalHyperRefEnd">
        <xsl:call-template name="DoInternalTargetEnd"/>
    </xsl:template>
    <!--  
        DoImageFile
    -->
    <xsl:template name="DoImageFile">
        <xsl:param name="sXeTeXGraphicFile"/>
        <xsl:param name="sImgFile"/>
        <xsl:variable name="sImageFileLocationAdjustment">
            <xsl:choose>
                <xsl:when test="not(contains($sImgFile, ':'))">
                    <xsl:text>../</xsl:text>
                    <xsl:value-of select="$sImgFile"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$sImgFile"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sAdjustedImageFile">
            <xsl:call-template name="ConvertPercent20ToSpace">
                <xsl:with-param name="sImageFile" select="$sImageFileLocationAdjustment"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="sPatternVA" select="'vertical-adjustment='"/>
        <xsl:choose>
            <xsl:when test="ancestor::example">
                <!-- apparently we normally need to adjust the vertical position of the image when in an example -->
                <tex:cmd name="vspace*">
                    <tex:parm>
                        <xsl:variable name="default">
                            <xsl:text>-</xsl:text>
                            <tex:cmd name="baselineskip" gr="0" nl2="0"/>
                        </xsl:variable>
                        <xsl:call-template name="HandleXeLaTeXSpecialCommand">
                            <xsl:with-param name="sPattern" select="$sPatternVA"/>
                            <xsl:with-param name="default" select="$default"/>
                        </xsl:call-template>
                    </tex:parm>
                </tex:cmd>
            </xsl:when>
            <xsl:otherwise>
                <tex:cmd name="vspace*">
                    <tex:parm>
                        <xsl:call-template name="HandleXeLaTeXSpecialCommand">
                            <xsl:with-param name="sPattern" select="$sPatternVA"/>
                            <xsl:with-param name="default" select="'0pt'"/>
                        </xsl:call-template>
                    </tex:parm>
                </tex:cmd>
            </xsl:otherwise>
        </xsl:choose>
        <tex:spec cat="bg"/>
        <tex:cmd name="{$sXeTeXGraphicFile}" gr="0" nl2="0">
            <xsl:text> "</xsl:text>
            <xsl:value-of select="$sAdjustedImageFile"/>
            <xsl:text>" </xsl:text>
        </tex:cmd>
        <!-- I'm not sure why, but it sure appears that all graphics need to be scaled down by 75% or so;  allow the user to fine tune this-->
        <xsl:text>scaled </xsl:text>
        <xsl:variable name="default" select="750"/>
        <xsl:variable name="sPattern" select="'scaled='"/>
        <xsl:call-template name="HandleXeLaTeXSpecialCommand">
            <xsl:with-param name="sPattern" select="$sPattern"/>
            <xsl:with-param name="default" select="$default"/>
        </xsl:call-template>
        <tex:spec cat="eg"/>
    </xsl:template>
    <!--  
        DoInterlinearFree
    -->
    <xsl:template name="DoInterlinearFree">
        <xsl:param name="mode"/>
        <xsl:if test="preceding-sibling::*[1][name()='free']">
            <tex:spec cat="esc"/>
            <tex:spec cat="esc"/>
            <xsl:text>*</xsl:text>
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
            <!--            <xsl:if test="preceding-sibling::free[@lang=$sCurrentLanguage][position()=1] or preceding-sibling::free[not(@lang)][position()=1] or name(../..)='interlinear' or name(../..)='listInterlinear' and name(..)='interlinear' and $iParentPosition!=1">-->
            <tex:cmd name="hspace*">
                <tex:parm>
                    <xsl:text>0.1in</xsl:text>
                </tex:parm>
            </tex:cmd>
        </xsl:if>
        <xsl:if test="ancestor::listInterlinear and not(ancestor::table)">
            <!-- need to compensate for the extra space after the letter -->
            <tex:cmd name="hspace*">
                <tex:parm>
                    <tex:cmd name="XLingPaperspacewidth" gr="0" nl2="0"/>
                </tex:parm>
            </tex:cmd>
            <tex:cmd name="hspace*">
                <tex:parm>
                    <tex:cmd name="XLingPaperexamplefreeindent" gr="0"/>
                    <!--                    <xsl:text>-.3 em+</xsl:text>
                    <xsl:value-of select="$sExampleIndentBefore"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="$sBlockQuoteIndent"/>
-->
                </tex:parm>
            </tex:cmd>
            <tex:cmd name="parbox">
                <tex:opt>t</tex:opt>
                <tex:parm>
                    <tex:cmd name="textwidth" gr="0" nl2="0"/>
                    <xsl:text> - </xsl:text>
                    <xsl:value-of select="$sExampleIndentBefore"/>
                    <xsl:text> - </xsl:text>
                    <xsl:value-of select="$iNumberWidth"/>
                    <xsl:text>em - </xsl:text>
                    <xsl:call-template name="GetLetterWidth">
                        <xsl:with-param name="iLetterCount" select="count(ancestor::listInterlinear[1])"/>
                    </xsl:call-template>
                    <xsl:text>em - </xsl:text>
                    <tex:cmd name="XLingPaperspacewidth" gr="0" nl2="0"/>
                </tex:parm>
            </tex:cmd>
            <tex:spec cat="bg"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="@lang">
                <xsl:call-template name="HandleFreeFontFamily"/>
            </xsl:when>
            <xsl:otherwise>
                <!--                <tex:cmd name="raggedright" gr="0" nl2="0"/>-->
                <tex:group>
                    <xsl:apply-templates/>
                </tex:group>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$mode!='NoTextRef'">
            <xsl:if test="$sInterlinearSourceStyle='AfterFree' and not(following-sibling::free) and not(following-sibling::interlinear[descendant::free])">
                <xsl:if test="ancestor::example  or ancestor::listInterlinear or ancestor::interlinear[@textref]">
                    <xsl:call-template name="OutputInterlinearTextReference">
                        <xsl:with-param name="sRef" select="ancestor::interlinear[@textref]/@textref"/>
                        <xsl:with-param name="sSource" select="../interlinearSource"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
        </xsl:if>
        <xsl:if test="$sInterlinearSourceStyle='UnderFree' and not(following-sibling::free) and ../interlinearSource">
            <xsl:if test="ancestor::example or ancestor::listInterlinear">
                <tex:spec cat="esc"/>
                <tex:spec cat="esc" nl2="1"/>
                <tex:group>
                    <xsl:call-template name="OutputInterlinearTextReference">
                        <xsl:with-param name="sRef" select="../@textref"/>
                        <xsl:with-param name="sSource" select="../interlinearSource"/>
                    </xsl:call-template>
                </tex:group>
            </xsl:if>
        </xsl:if>
        <xsl:if test="ancestor::listInterlinear and not(ancestor::table)">
            <tex:spec cat="eg"/>
        </xsl:if>
        <xsl:if test="descendant-or-self::endnote">
            <xsl:for-each select="descendant-or-self::endnote">
                <xsl:apply-templates select=".">
                    <xsl:with-param name="sTeXFootnoteKind" select="'footnotetext'"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <!--  
        DoInterlinearLine
    -->
    <xsl:template name="DoInterlinearLine">
        <xsl:param name="mode"/>
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
                    <xsl:if test="position() &gt; 1">
                        <tex:spec cat="align"/>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="@lang">
                            <!-- using cmd and parm outputs an unwanted space when there is an initial object - SIGH - does not do any better.... need to try spec nil -->
                            <xsl:call-template name="OutputFontAttributes">
                                <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                                <xsl:with-param name="originalContext" select="."/>
                            </xsl:call-template>
                            <xsl:apply-templates/>
                            <xsl:call-template name="OutputFontAttributesEnd">
                                <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                                <xsl:with-param name="originalContext" select="."/>
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
                    <!--                    <xsl:value-of select="."/>-->
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
                        <tex:spec cat="align"/>
                        <xsl:call-template name="DoDebugExamples"/>
                        <xsl:call-template name="OutputInterlinearTextReference">
                            <xsl:with-param name="sRef" select="../../@textref"/>
                            <xsl:with-param name="sSource" select="../../interlinearSource"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:if>
            </xsl:if>
        </xsl:if>
        <tex:spec cat="esc"/>
        <tex:spec cat="esc"/>
        <xsl:text>*
</xsl:text>
    </xsl:template>
    <!--  
        DoInterlinearLineGroup
    -->
    <xsl:template name="DoInterlinearLineGroup">
        <xsl:param name="mode"/>
        <xsl:choose>
            <xsl:when test="parent::interlinear[preceding-sibling::*]">
                <xsl:variable name="previous" select="parent::interlinear/preceding-sibling::*[1]"/>
                <xsl:choose>
                    <xsl:when test="$previous=exampleHeading">
                        <!--                    <tex:cmd name="par" gr="0" nl2="1"/>-->
                        <tex:spec cat="esc"/>
                        <tex:spec cat="esc"/>
                        <xsl:text>*
</xsl:text>
                    </xsl:when>
                    <xsl:when test="name($previous)='free' or name($previous)='lineGroup' or name($previous)='interlinear' and $previous[parent::interlinear or parent::listInterlinear]">
                        <tex:spec cat="esc"/>
                        <tex:spec cat="esc"/>
                        <tex:spec cat="lsb"/>
                        <!--                        <xsl:text>3pt</xsl:text>-->
                        <tex:cmd name="baselineskip"/>
                        <tex:spec cat="rsb"/>
                        <tex:cmd name="hspace*" nl1="1">
                            <tex:parm>.1in</tex:parm>
                        </tex:cmd>
                    </xsl:when>
                    <xsl:when test="preceding-sibling::*[1][name()='lineGroup' or name()='free']">
                        <xsl:call-template name="HandleImmediatelyPrecedingLineGroupOrFree"/>
                    </xsl:when>
                    <xsl:otherwise> </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="preceding-sibling::*[1][name()='lineGroup' or name()='free']">
                <xsl:call-template name="HandleImmediatelyPrecedingLineGroupOrFree"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <tex:env name="tabular" nlb1="0" nlb2="0">
            <tex:opt>t</tex:opt>
            <tex:parm>
                <xsl:call-template name="DoInterlinearTabularMainPattern"/>
            </tex:parm>
            <xsl:call-template name="ApplyTemplatesPerTextRefMode">
                <xsl:with-param name="mode" select="$mode"/>
            </xsl:call-template>
        </tex:env>
        <xsl:choose>
            <!--            <xsl:when test="ancestor::table">
                <!-\- do nothing because the \\* causes LaTeX to give an error message "Missing \endgroup inserted" at the end of the table -\->
                </xsl:when>
            -->
            <xsl:when test="following-sibling::*[1][name()='lineGroup']">
                <!-- do nothing; otherwise we get an error -->
            </xsl:when>
            <xsl:when test="following-sibling::*[1][name()='free'] or parent::interlinear/following-sibling::*[1][name()='free']">
                <xsl:call-template name="CreateBreakAfter">
                    <xsl:with-param name="example" select="ancestor::example[1]"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!--                <tex:cmd name="par" gr="0" nl2="1"/>-->
            </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="descendant-or-self::endnote">
            <xsl:apply-templates select=".">
                <xsl:with-param name="sTeXFootnoteKind" select="'footnotetext'"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoInterlinearTabularMainPattern
    -->
    <xsl:template name="DoInterlinearTabularMainPattern">
        <!-- apparently \begin{tabular}{@{}...} still adds about 3pt; so we need to backtrack 3pt;
            no, it was just that there was a newline between the beginning of the argument to XLingPaperexample
            and the \begin{tabular}; removing that newline made it all align properly
            <xsl:text>@</xsl:text>
            <tex:spec cat="bg"/>
            <tex:cmd name="hspace*">
            <tex:parm>
            <xsl:text>-3pt</xsl:text>
            </tex:parm>
            </tex:cmd>
            <tex:spec cat="eg"/> -->
        <xsl:text>*</xsl:text>
        <tex:spec cat="bg"/>
        <!--        <xsl:value-of select="$sInterlinearMaxNumberOfColumns"/>-->
        <xsl:variable name="iColCount">
            <!--       <xsl:choose>
         -->
            <!--          <xsl:when test="line">-->
            <xsl:variable name="iTempCount">
                <xsl:for-each select="line | ../listWord">
                    <xsl:sort select="count(wrd) + count(langData) + count(gloss)" order="descending" data-type="number"/>
                    <xsl:if test="position()=1">
                        <xsl:value-of select="count(wrd) + count(langData) + count(gloss)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test=" name()!='listWord' and $iTempCount=1 or name()!='listWord' and count(descendant::wrd)=0">
                    <!-- have space-delimited langData and/or gloss line(s) -->
                    <!-- We need to figure out the maximum number of items in the line elements.
                                   The maximum could be in any line since the user just keys data in them.
                                   We use a bit of a trick.  We put XML into a variable, with a root of <lines> and each line as <line>.
                                   Each line contains one x for each item in the line.  We then sort these and get the longest one.
                                   We use the longest one to figure out how many columns we will need.
                                   Note that with XSLT version 1.0, we have to use something like the Saxon extension function node-set().
                            -->
                    <xsl:variable name="lines">
                        <lines>
                            <xsl:for-each select="line | ../listWord">
                                <line>
                                    <xsl:call-template name="CalculateColumnsInInterlinearLine">
                                        <xsl:with-param name="sList" select="langData | gloss"/>
                                    </xsl:call-template>
                                </line>
                            </xsl:for-each>
                        </lines>
                    </xsl:variable>
                    <xsl:variable name="sMaxColCount">
                        <xsl:for-each select="saxon:node-set($lines)/descendant::*">
                            <xsl:for-each select="line">
                                <xsl:sort select="." order="descending"/>
                                <xsl:if test="position()=1">
                                    <xsl:value-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="string-length($sMaxColCount)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$iTempCount"/>
                </xsl:otherwise>
            </xsl:choose>
            <!--                </xsl:when>-->
            <!--                <xsl:otherwise>
                    <xsl:value-of select="count(langData) + count(gloss)"/>
                </xsl:otherwise>
            </xsl:choose>
-->
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$sInterlinearSourceStyle='AfterFirstLine'">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(ancestor-or-self::*/@textref)) &gt; 0 or string-length(normalize-space(following-sibling::interlinearSource)) &gt; 0">
                        <!-- we have an extra column so include it -->
                        <xsl:value-of select="$iColCount + 1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$iColCount"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$iColCount"/>
            </xsl:otherwise>
        </xsl:choose>
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
        DoInternalHyperlinkBegin
    -->
    <xsl:template name="DoInternalHyperlinkBegin">
        <xsl:param name="sName"/>
        <tex:spec cat="esc"/>
        <xsl:text>hyperlink</xsl:text>
        <tex:spec cat="bg"/>
        <xsl:value-of select="translate($sName,$sIDcharsToMap, $sIDcharsMapped)"/>
        <tex:spec cat="eg"/>
        <tex:spec cat="bg"/>
    </xsl:template>
    <!--  
        DoInternalHyperlinkEnd
    -->
    <xsl:template name="DoInternalHyperlinkEnd">
        <tex:spec cat="eg"/>
    </xsl:template>
    <!--
        DoInternalTargetBegin
    -->
    <xsl:template name="DoInternalTargetBegin">
        <xsl:param name="sName"/>
        <tex:spec cat="esc"/>
        <xsl:text>hypertarget</xsl:text>
        <tex:spec cat="bg"/>
        <xsl:value-of select="translate($sName,$sIDcharsToMap, $sIDcharsMapped)"/>
        <tex:spec cat="eg"/>
        <tex:spec cat="bg"/>
    </xsl:template>
    <!--  
        DoInternalTargetEnd
    -->
    <xsl:template name="DoInternalTargetEnd">
        <tex:spec cat="eg"/>
    </xsl:template>
    <!--  
        DoListInterlinearEmbeddedTabular
    -->
    <xsl:template name="DoListInterlinearEmbeddedTabular">
        <tex:spec cat="bg"/>
        <xsl:apply-templates select="child::node()[name()!='interlinearSource']"/>
        <tex:spec cat="eg"/>
    </xsl:template>
    <!--  
        DoListLetter
    -->
    <xsl:template name="DoListLetter">
        <xsl:param name="sLetterWidth"/>
        <xsl:call-template name="OutputLetter"/>
    </xsl:template>
    <!--  
        DoNestedTypes
    -->
    <xsl:template name="DoNestedTypes">
        <xsl:param name="sList"/>
        <xsl:param name="originalContext"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:if test="string-length($sFirst) &gt; 0">
            <xsl:call-template name="DoType">
                <xsl:with-param name="type" select="$sFirst"/>
                <xsl:with-param name="bDoingNestedTypes" select="'y'"/>
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
            <xsl:if test="$sRest">
                <xsl:call-template name="DoNestedTypes">
                    <xsl:with-param name="sList" select="$sRest"/>
                    <xsl:with-param name="originalContext" select="$originalContext"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        DoNestedTypesBracketsOnly
    -->
    <xsl:template name="DoNestedTypesBracketsOnly">
        <xsl:param name="sList"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:if test="string-length($sFirst) &gt; 0">
            <xsl:call-template name="DoTypeBracketsOnly">
                <xsl:with-param name="type" select="$sFirst"/>
            </xsl:call-template>
            <xsl:if test="$sRest">
                <xsl:call-template name="DoNestedTypesBracketsOnly">
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
        <xsl:param name="originalContext"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:if test="string-length($sFirst) &gt; 0">
            <xsl:call-template name="DoTypeEnd">
                <xsl:with-param name="type" select="$sFirst"/>
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
            <xsl:if test="$sRest">
                <xsl:call-template name="DoNestedTypesEnd">
                    <xsl:with-param name="sList" select="$sRest"/>
                    <xsl:with-param name="originalContext" select="$originalContext"/>
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
        DoRowSpanAdjust
    -->
    <xsl:template name="DoRowSpanAdjust">
        <xsl:param name="sList"/>
        <xsl:variable name="sRest" select="substring-after($sList,'Y')"/>
        <tex:spec cat="align"/>
        <xsl:if test="contains($sRest ,'Y')">
            <xsl:call-template name="DoRowSpanAdjust">
                <xsl:with-param name="sList" select="$sRest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
        DoType
    -->
    <xsl:template name="DoType">
        <xsl:param name="type" select="@type"/>
        <xsl:param name="bDoingNestedTypes" select="'n'"/>
        <xsl:param name="originalContext"/>
        <xsl:for-each select="key('TypeID',$type)">
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="."/>
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
            <xsl:call-template name="DoNestedTypes">
                <xsl:with-param name="sList" select="@types"/>
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
            <xsl:if test="$bDoingNestedTypes!='y'">
                <xsl:value-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoTypeBracketsOnly
    -->
    <xsl:template name="DoTypeBracketsOnly">
        <xsl:param name="type" select="@type"/>
        <xsl:for-each select="key('TypeID',$type)">
            <xsl:call-template name="OutputFontAttributesBracketsOnly">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
            <xsl:call-template name="DoNestedTypesBracketsOnly">
                <xsl:with-param name="sList" select="@types"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--  
        DoTypeEnd
    -->
    <xsl:template name="DoTypeEnd">
        <xsl:param name="type" select="@type"/>
        <xsl:param name="originalContext"/>
        <xsl:for-each select="key('TypeID',$type)">
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="."/>
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
            <xsl:call-template name="DoNestedTypesEnd">
                <xsl:with-param name="sList" select="@types"/>
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
        </xsl:for-each>
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
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='aliceblue'">F0F8FF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='antiquewhite'">FAEBD7</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='aqua'">00FFFF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='aquamarine'">7FFFD4</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='azure'">F0FFFF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='beige'">F5F5DC</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='bisque'">FFE4C4</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='black'">000000</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='blanchedalmond'">FFEBCD</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='blue'">0000FF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='blueviolet'">8A2BE2</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='brown'">A52A2A</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='burlywood'">DEB887</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='cadetblue'">5F9EA0</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='chartreuse'">7FFF00</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='chocolate'">D2691E</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='coral'">FF7F50</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='cornflowerblue'">6495ED</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='cornsilk'">FFF8DC</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='crimson'">DC143C</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='cyan'">00FFFF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkblue'">00008B</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkcyan'">008B8B</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkgoldenrod'">B8860B</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkgray'">A9A9A9</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkgreen'">006400</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkkhaki'">BDB76B</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkmagenta'">8B008B</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkolivegreen'">556B2F</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkorange'">FF8C00</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkorchid'">9932CC</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkred'">8B0000</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darksalmon'">E9967A</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkseagreen'">8FBC8F</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkslateblue'">483D8B</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkslategray'">2F4F4F</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkturquoise'">00CED1</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='darkviolet'">9400D3</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='deeppink'">FF1493</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='deepskyblue'">00BFFF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='dimgray'">696969</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='dodgerblue'">1E90FF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='firebrick'">B22222</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='floralwhite'">FFFAF0</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='forestgreen'">228B22</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='fuchsia'">FF00FF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='gainsboro'">DCDCDC</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='ghostwhite'">F8F8FF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='gold'">FFD700</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='goldenrod'">DAA520</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='gray'">808080</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='green'">008000</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='greenyellow'">ADFF2F</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='honeydew'">F0FFF0</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='hotpink'">FF69B4</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='indianred '">CD5C5C</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='indigo '">4B0082</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='ivory'">FFFFF0</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='khaki'">F0E68C</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lavender'">E6E6FA</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lavenderblush'">FFF0F5</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lawngreen'">7CFC00</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lemonchiffon'">FFFACD</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightblue'">ADD8E6</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightcoral'">F08080</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightcyan'">E0FFFF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightgoldenrodyellow'">FAFAD2</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightgrey'">D3D3D3</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightgreen'">90EE90</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightpink'">FFB6C1</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightsalmon'">FFA07A</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightseagreen'">20B2AA</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightskyblue'">87CEFA</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightslategray'">778899</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightsteelblue'">B0C4DE</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lightyellow'">FFFFE0</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='lime'">00FF00</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='limegreen'">32CD32</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='linen'">FAF0E6</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='magenta'">FF00FF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='maroon'">800000</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='mediumaquamarine'">66CDAA</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='mediumblue'">0000CD</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='mediumorchid'">BA55D3</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='mediumpurple'">9370D8</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='mediumseagreen'">3CB371</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='mediumslateblue'">7B68EE</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='mediumspringgreen'">00FA9A</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='mediumturquoise'">48D1CC</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='mediumvioletred'">C71585</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='midnightblue'">191970</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='mintcream'">F5FFFA</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='mistyrose'">FFE4E1</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='moccasin'">FFE4B5</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='navajowhite'">FFDEAD</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='navy'">000080</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='oldlace'">FDF5E6</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='olive'">808000</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='olivedrab'">6B8E23</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='orange'">FFA500</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='orangered'">FF4500</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='orchid'">DA70D6</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='palegoldenrod'">EEE8AA</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='palegreen'">98FB98</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='paleturquoise'">AFEEEE</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='palevioletred'">D87093</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='papayawhip'">FFEFD5</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='peachpuff'">FFDAB9</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='peru'">CD853F</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='pink'">FFC0CB</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='plum'">DDA0DD</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='powderblue'">B0E0E6</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='purple'">800080</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='red'">FF0000</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='rosybrown'">BC8F8F</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='royalblue'">4169E1</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='saddlebrown'">8B4513</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='salmon'">FA8072</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='sandybrown'">F4A460</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='seagreen'">2E8B57</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='seashell'">FFF5EE</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='sienna'">A0522D</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='silver'">C0C0C0</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='skyblue'">87CEEB</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='slateblue'">6A5ACD</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='slategray'">708090</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='snow'">FFFAFA</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='springgreen'">00FF7F</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='steelblue'">4682B4</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='tan'">D2B48C</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='teal'">008080</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='thistle'">D8BFD8</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='tomato'">FF6347</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='turquoise'">40E0D0</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='violet'">EE82EE</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='wheat'">F5DEB3</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='white'">FFFFFF</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='whitesmoke'">F5F5F5</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='yellow'">FFFF00</xsl:when>
            <xsl:when test="translate($sColor,$sUppercaseAtoZ, $sLowercaseAtoZ)='yellowgreen'">9ACD32</xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($sColor) = 7">
                        <!-- skip the initial # -->
                        <xsl:value-of select="substring($sColor, 2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- somehow it came through as an invalid number; use black -->
                        <xsl:text>000000</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        GetColumnWidthBasedOnPercentage
    -->
    <xsl:template name="GetColumnWidthBasedOnPercentage">
        <xsl:param name="iPercentage"/>
        <xsl:variable name="iTableWidth">
            <xsl:choose>
                <xsl:when test="$iPercentage&gt;=100">
                    <!-- do nothing; leave it -->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="ancestor::example">
                            <xsl:value-of select="$iExampleWidth*$iPercentage div 100"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="number($iPageWidth - $iPageOutsideMargin - $iPageInsideMargin)*$iPercentage div 100"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$iTableWidth"/>
        <xsl:call-template name="GetUnitOfMeasure">
            <xsl:with-param name="sValue" select="$sPageWidth"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        GetExampleNumber
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
        GetISOCode
    -->
    <xsl:template name="GetISOCode">
        <xsl:if test="//lingPaper/@showiso639-3codeininterlinear='yes'">
            <xsl:variable name="firstLangData" select="descendant::langData[1]"/>
            <xsl:if test="$firstLangData">
                <xsl:value-of select="key('LanguageID',$firstLangData/@lang)/@ISO639-3Code"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        GetItemWidth
    -->
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
        GetNumberedItemWidth
    -->
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
                        <xsl:text>XLingPaperromanxviiilistitemwidth</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- hope for the best...  -->
                        <xsl:text>XLingPaperdoubleletterlistitemwidth</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- 
        GetRealColumnNumberOfCell
    -->
    <xsl:template name="GetRealColumnNumberOfCell">
        <xsl:param name="iRowNumberOfCell"/>
        <xsl:variable name="precedingSiblingsOfPreviousCellWithRowspan" select="preceding-sibling::td | preceding-sibling::th"/>
        <xsl:variable name="iInSituColumnNumberOfPreviousCellWithRowspan" select="count($precedingSiblingsOfPreviousCellWithRowspan[not(number(@colspan) &gt; 0)]) + sum($precedingSiblingsOfPreviousCellWithRowspan[number(@colspan) &gt; 0]/@colspan)"/>
        <xsl:variable name="iPreviousRowspansInRowOfCell">
            <xsl:variable name="sOneYForEachColumn">
                <xsl:call-template name="CountPreviousRowspansInMyRow">
                    <xsl:with-param name="previousCellsWithRowspansSpanningMyRow" select="../preceding-sibling::tr/th[@rowspan][($iRowNumberOfCell - (count(../preceding-sibling::tr) + 1)) + 1 &lt;= @rowspan] | ../preceding-sibling::tr/td[@rowspan][($iRowNumberOfCell - (count(../preceding-sibling::tr) + 1)) + 1 &lt;= @rowspan]"/>
                    <xsl:with-param name="iPosition">1</xsl:with-param>
                    <xsl:with-param name="iMyInSituColumnNumber" select="$iInSituColumnNumberOfPreviousCellWithRowspan"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="string-length($sOneYForEachColumn)"/>
        </xsl:variable>
        <xsl:value-of select="$iInSituColumnNumberOfPreviousCellWithRowspan + $iPreviousRowspansInRowOfCell"/>
    </xsl:template>
    <!--  
        GetUnitOfMeasure
    -->
    <xsl:template name="GetUnitOfMeasure">
        <xsl:param name="sValue"/>
        <xsl:value-of select="substring($sValue, string-length($sValue)-1)"/>
    </xsl:template>
    <!--  
        GetXeLaTeXSpecialCommand
    -->
    <xsl:template name="GetXeLaTeXSpecialCommand">
        <xsl:param name="sAttr"/>
        <xsl:param name="sDefaultValue"/>
        <xsl:variable name="sCommandBeginning" select="substring-after(@XeLaTeXSpecial, $sAttr)"/>
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
        HandleFontSize
    -->
    <xsl:template name="HandleFontSize">
        <xsl:param name="sSize"/>
        <xsl:param name="sFontFamily"/>
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
                                <xsl:variable name="sNormFontFamily" select="normalize-space($sFontFamily)"/>
                                <xsl:choose>
                                    <xsl:when test="string-length($sNormFontFamily) &gt; 0">
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
                <tex:cmd name="selectfont" gr="0" sp="1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        HandleFootnotesInTableHeader
    -->
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
        HandleImmediatelyPrecedingLineGroupOrFree
    -->
    <xsl:template name="HandleImmediatelyPrecedingLineGroupOrFree">
        <tex:spec cat="esc"/>
        <tex:spec cat="esc"/>
        <tex:spec cat="lsb"/>
        <xsl:text>3pt</xsl:text>
        <tex:spec cat="rsb"/>
        <xsl:text>&#x0a;</xsl:text>
    </xsl:template>
    <!--  
        HandleMulticolumnInCell
    -->
    <xsl:template name="HandleMulticolumnInCell">
        <xsl:param name="bInARowSpan"/>
        <xsl:param name="iBorder"/>
        <xsl:param name="iColSpan" select="'1'"/>
        <tex:cmd name="multicolumn">
            <tex:parm>
                <xsl:value-of select="$iColSpan"/>
            </tex:parm>
            <tex:parm>
                <xsl:if test="count(preceding-sibling::*) = 0 and not(contains($bInARowSpan,'Y'))">
                    <!--                     <xsl:if test="count(preceding-sibling::*) = 0">-->
                    <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
                </xsl:if>
                <xsl:if test="$iBorder=0 and contains(@XeLaTeXSpecial,'border-left=') or contains(key('TypeID',@type)/@XeLaTeXSpecial,'border-left=')">
                    <xsl:variable name="sValue">
                        <xsl:choose>
                            <xsl:when test="contains(key('TypeID',@type)/@XeLaTeXSpecial,'border-left=')">
                                <xsl:for-each select="key('TypeID',@type)">
                                    <xsl:call-template name="HandleXeLaTeXSpecialCommand">
                                        <xsl:with-param name="sPattern" select="'border-left='"/>
                                        <xsl:with-param name="default" select="'0'"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="HandleXeLaTeXSpecialCommand">
                                    <xsl:with-param name="sPattern" select="'border-left='"/>
                                    <xsl:with-param name="default" select="'0'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:call-template name="CreateVerticalLine">
                        <xsl:with-param name="iBorder" select="number($sValue)"/> 
                        <xsl:with-param name="bDisallowVerticalLines" select="'N'"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="CreateColumnSpec">
                    <xsl:with-param name="iBorder" select="$iBorder"/>
                </xsl:call-template>
                <xsl:if test="$iBorder=0 and contains(@XeLaTeXSpecial,'border-right=') or contains(key('TypeID',@type)/@XeLaTeXSpecial,'border-right=')">
                    <xsl:variable name="sValue">
                        <xsl:choose>
                            <xsl:when test="contains(key('TypeID',@type)/@XeLaTeXSpecial,'border-right=')">
                                <xsl:for-each select="key('TypeID',@type)">
                                    <xsl:call-template name="HandleXeLaTeXSpecialCommand">
                                        <xsl:with-param name="sPattern" select="'border-right='"/>
                                        <xsl:with-param name="default" select="'0'"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="HandleXeLaTeXSpecialCommand">
                                    <xsl:with-param name="sPattern" select="'border-right='"/>
                                    <xsl:with-param name="default" select="'0'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:call-template name="CreateVerticalLine">
                        <xsl:with-param name="iBorder" select="number($sValue)"/> 
                        <xsl:with-param name="bDisallowVerticalLines" select="'N'"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="count(following-sibling::*) = 0">
                    <xsl:call-template name="CreateVerticalLine">
                        <xsl:with-param name="iBorder" select="$iBorder"/>
                    </xsl:call-template>
                    <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
                </xsl:if>
            </tex:parm>
        </tex:cmd>
        <tex:spec cat="bg"/>
    </xsl:template>
    <!--  
        HandleMultirowInCell
    -->
    <xsl:template name="HandleMultirowInCell">
        <xsl:param name="valignFixup"/>
        <tex:cmd name="multirow">
            <tex:parm>
                <xsl:variable name="sRowSpan" select="normalize-space(@rowspan)"/>
                <xsl:choose>
                    <xsl:when test="string-length($sRowSpan) &gt; 0">
                        <xsl:value-of select="$sRowSpan"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>1</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </tex:parm>
            <tex:parm>
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(@width)) &gt; 0">
                        <xsl:value-of select="@width"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>*</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </tex:parm>
            <xsl:if test="@valign">
                <xsl:choose>
                    <xsl:when test="$valignFixup!='0pt'">
                        <tex:opt>
                            <xsl:value-of select="$valignFixup"/>
                        </tex:opt>
                    </xsl:when>
                    <xsl:otherwise>
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
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </tex:cmd>
        <tex:spec cat="bg"/>
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
        HandleSmallCapsBracketsOnly
    -->
    <xsl:template name="HandleSmallCapsBracketsOnly">
        <tex:spec cat="bg"/>
        <tex:spec cat="bg"/>
        <!--        <xsl:call-template name="HandleSmallCapsEndDoNestedTypes">
            <xsl:with-param name="sList" select="@types"/>
            </xsl:call-template>
        -->
    </xsl:template>
    <!--  
        HandleSmallCapsEnd
    -->
    <xsl:template name="HandleSmallCapsEnd">
        <tex:spec cat="eg"/>
        <tex:spec cat="eg"/>
        <!--        <xsl:call-template name="HandleSmallCapsEndDoNestedTypes">
            <xsl:with-param name="sList" select="@types"/>
        </xsl:call-template>
-->
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
        HandleXeLaTeXSpecialCommand
    -->
    <xsl:template name="HandleXeLaTeXSpecialCommand">
        <xsl:param name="sPattern"/>
        <xsl:param name="default"/>
        <xsl:choose>
            <xsl:when test="contains(@XeLaTeXSpecial,$sPattern)">
                <xsl:variable name="sValue">
                    <xsl:call-template name="GetXeLaTeXSpecialCommand">
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
        <tex:spec cat="esc" nl1="1" nl2="0"/>
        <xsl:text>penalty-3000</xsl:text>
    </xsl:template>
    <!--
        OutputAbbreviationsInCommaSeparatedList
    -->
    <xsl:template name="OutputAbbreviationsInCommaSeparatedList">
        <xsl:for-each select="//abbreviation[//abbrRef/@abbr=@id]">
            <xsl:call-template name="DoInternalTargetBegin">
                <xsl:with-param name="sName" select="@id"/>
            </xsl:call-template>
            <xsl:call-template name="OutputAbbrTerm">
                <xsl:with-param name="abbr" select="."/>
            </xsl:call-template>
            <xsl:text> = </xsl:text>
            <xsl:call-template name="OutputAbbrDefinition">
                <xsl:with-param name="abbr" select="."/>
            </xsl:call-template>
            <xsl:call-template name="DoInternalTargetEnd"/>
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
        <tex:env name="longtable">
            <tex:opt>l</tex:opt>
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
            <xsl:if test="$abbreviations/@usesmallcaps='yes'">
                <tex:cmd name="fontspec">
                    <tex:opt>Scale=0.65</tex:opt>
                    <tex:parm>
                        <xsl:variable name="closestGlossOrObjectWithAFontFamily">
                            <xsl:for-each select="ancestor::object">
                                <xsl:sort order="descending"/>
                                <xsl:for-each select="key('TypeID',@type)">
                                    <xsl:if test="string-length(@font-family) &gt; 0">
                                        <xsl:value-of select="@font-family"/>
                                        <xsl:text>|</xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:for-each>
                            <xsl:for-each select="ancestor::gloss">
                                <xsl:sort order="descending"/>
                                <xsl:for-each select="key('LanguageID',@lang)">
                                    <xsl:if test="string-length(@font-family) &gt; 0">
                                        <xsl:value-of select="@font-family"/>
                                        <xsl:text>|</xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="string-length($closestGlossOrObjectWithAFontFamily) &gt; 0">
                                <xsl:value-of select="substring-before($closestGlossOrObjectWithAFontFamily,'|')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$sDefaultFontFamily"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </tex:parm>
                </tex:cmd>
                <xsl:call-template name="HandleSmallCapsBegin"/>
            </xsl:if>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$abbreviations"/>
            </xsl:call-template>
            <xsl:value-of select="$sAbbrTerm"/>
            <xsl:call-template name="OutputFontAttributesEnd">
                <xsl:with-param name="language" select="$abbreviations"/>
            </xsl:call-template>
            <xsl:if test="$abbreviations/@usesmallcaps='yes'">
                <xsl:call-template name="HandleSmallCapsEnd"/>
            </xsl:if>
        </tex:group>
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
        OutputFontAttributes
    -->
    <xsl:template name="OutputFontAttributes">
        <xsl:param name="language"/>
        <xsl:param name="originalContext"/>
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
            <xsl:call-template name="HandleFontFamily">
                <xsl:with-param name="language" select="$language"/>
                <xsl:with-param name="sFontFamily" select="$sFontFamily"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="sFontSize" select="normalize-space($language/@font-size)"/>
        <xsl:if test="string-length($sFontSize) &gt; 0">
            <xsl:call-template name="HandleFontSize">
                <xsl:with-param name="sSize" select="$sFontSize"/>
                <xsl:with-param name="sFontFamily" select="$language/@font-family"/>
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
                    <xsl:if test="not($originalContext and $originalContext[descendant::abbrRef])">
                        <xsl:if test="string-length($sFontSize)=0">
                            <xsl:call-template name="HandleFontSize">
                                <xsl:with-param name="sSize" select="'65%'"/>
                                <xsl:with-param name="sFontFamily" select="$sFontFamily"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:call-template name="HandleSmallCapsBegin"/>
                    </xsl:if>
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
            <xsl:call-template name="DoColor">
                <xsl:with-param name="sFontColor" select="$sFontColor"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:variable name="sTextTransform" select="normalize-space($language/@text-transform)"/>
        <xsl:if test="string-length($sTextTransform) &gt; 0 and $originalContext and name($originalContext/*)=''">
            <xsl:choose>
                <xsl:when test="$sTextTransform='uppercase'">
                    <tex:spec cat="bg"/>
                    <tex:cmd name="MakeUppercase" gr="0"/>
                    <tex:spec cat="bg"/>
                </xsl:when>
                <xsl:when test="$sTextTransform='lowercase'">
                    <tex:spec cat="bg"/>
                    <tex:cmd name="MakeLowercase" gr="0"/>
                    <tex:spec cat="bg"/>
                </xsl:when>
                <!-- we ignore 'captialize' and 'none' -->
            </xsl:choose>
        </xsl:if>
        <xsl:call-template name="OutputTypeAttributes">
            <xsl:with-param name="sList" select="$language/@XeLaTeXSpecial"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        OutputFontAttributesBracketsOnly
    -->
    <xsl:template name="OutputFontAttributesBracketsOnly">
        <xsl:param name="language"/>
        <xsl:call-template name="OutputTypeAttributesEnd">
            <xsl:with-param name="sList" select="$language/@XeLaTeXSpecial"/>
        </xsl:call-template>
        <xsl:variable name="sFontFamily" select="normalize-space($language/@font-family)"/>
        <xsl:if test="string-length($sFontFamily) &gt; 0">
            <tex:spec cat="bg"/>
        </xsl:if>
        <xsl:variable name="sFontStyle" select="normalize-space($language/@font-style)"/>
        <xsl:if test="string-length($sFontStyle) &gt; 0">
            <xsl:if test="$sFontStyle='italic' or $sFontStyle='normal'">
                <tex:spec cat="bg"/>
            </xsl:if>
        </xsl:if>
        <xsl:variable name="sFontVariant" select="normalize-space($language/@font-variant)"/>
        <xsl:if test="string-length($sFontVariant) &gt; 0">
            <xsl:choose>
                <xsl:when test="$sFontVariant='small-caps'">
                    <xsl:call-template name="HandleSmallCapsBracketsOnly"/>
                </xsl:when>
                <xsl:when test="$sFontStyle='italic'">
                    <!-- do nothing; we do not want to turn off the italic by using a normal -->
                </xsl:when>
                <xsl:when test="$sFontStyle='normal'">
                    <tex:spec cat="bg"/>
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
                    <tex:spec cat="bg"/>
                </xsl:when>
                <xsl:otherwise>
                    <tex:spec cat="bg"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:variable name="sFontColor" select="normalize-space($language/@color)"/>
        <xsl:if test="string-length($sFontColor) &gt; 0">
            <tex:spec cat="bg"/>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputFontAttributesEnd
    -->
    <xsl:template name="OutputFontAttributesEnd">
        <xsl:param name="language"/>
        <xsl:param name="originalContext"/>
        <!-- unsuccessful attempt at dealing with "normal" to override inherited values 
            <xsl:param name="bStartParent" select="'Y'"/>
        -->
        <xsl:call-template name="OutputTypeAttributesEnd">
            <xsl:with-param name="sList" select="$language/@XeLaTeXSpecial"/>
        </xsl:call-template>
        <xsl:variable name="sTextTransform" select="normalize-space($language/@text-transform)"/>
        <xsl:if test="string-length($sTextTransform) &gt; 0 and $originalContext and name($originalContext/*)=''">
            <xsl:choose>
                <xsl:when test="$sTextTransform='uppercase'">
                    <tex:spec cat="eg"/>
                    <tex:spec cat="eg"/>
                </xsl:when>
                <xsl:when test="$sTextTransform='lowercase'">
                    <tex:spec cat="eg"/>
                    <tex:spec cat="eg"/>
                </xsl:when>
                <!-- we ignore 'captialize' and 'none' -->
            </xsl:choose>
        </xsl:if>
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
                    <xsl:if test="not($originalContext  and $originalContext[descendant::abbrRef])">
                        <xsl:call-template name="HandleSmallCapsEnd"/>
                    </xsl:if>
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
        <xsl:call-template name="DoDebugExamples"/>
        <xsl:call-template name="OutputFontAttributes">
            <xsl:with-param name="language" select="key('LanguageID',$lang)"/>
            <xsl:with-param name="originalContext" select="$sFirst"/>
        </xsl:call-template>
        <xsl:value-of select="$sFirst"/>
        <xsl:call-template name="OutputFontAttributesEnd">
            <xsl:with-param name="language" select="key('LanguageID',$lang)"/>
            <xsl:with-param name="originalContext" select="$sFirst"/>
        </xsl:call-template>
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
        OutputInterlinearTextReference
    -->
    <xsl:template name="OutputInterlinearTextReference">
        <xsl:param name="sRef"/>
        <xsl:param name="sSource"/>
        <xsl:if test="string-length(normalize-space($sRef)) &gt; 0 or $sSource">
            <xsl:choose>
                <xsl:when test="$sInterlinearSourceStyle='AfterFree'">
                    <tex:group>
                        <xsl:text disable-output-escaping="yes">&#xa0;&#xa0;</xsl:text>
                        <xsl:call-template name="OutputInterlinearTextReferenceContent">
                            <xsl:with-param name="sSource" select="$sSource"/>
                            <xsl:with-param name="sRef" select="$sRef"/>
                        </xsl:call-template>
                    </tex:group>
                </xsl:when>
                <xsl:otherwise>
                    <tex:cmd name="hfil" gr="0" nl2="0"/>
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
        OutputLetter
    -->
    <xsl:template name="OutputLetter">
        <xsl:call-template name="DoInternalTargetBegin">
            <xsl:with-param name="sName" select="@letter"/>
        </xsl:call-template>
        <xsl:apply-templates select="." mode="letter"/>
        <xsl:text>.</xsl:text>
        <xsl:call-template name="DoInternalTargetEnd"/>
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
        <xsl:variable name="sIsoCode">
            <xsl:call-template name="GetISOCode"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="name()='listInterlinear'">
                <xsl:variable name="toDoList" select=". | following-sibling::listInterlinear"/>
                <xsl:for-each select=". | following-sibling::listInterlinear">
                    <xsl:if test="position() = 1 and not(preceding-sibling::exampleHeading)">
                        <xsl:if test="not(parent::example[parent::td])">
                            <tex:cmd name="vspace*" nl2="1">
                                <tex:parm>
                                    <xsl:text>-</xsl:text>
                                    <xsl:if test="string-length($sIsoCode) &gt; 0">
                                        <xsl:text>1.9</xsl:text>
                                    </xsl:if>
                                    <!-- if there is no ISO code, we just use a factor of 1 so we do not need to output anything -->
                                    <tex:cmd name="baselineskip" gr="0" nl2="0"/>
                                </tex:parm>
                            </tex:cmd>
                        </xsl:if>
                    </xsl:if>
                    <xsl:variable name="sXLingPaperListInterlinear">
                        <xsl:choose>
                            <xsl:when test="parent::example[parent::td]">
                                <xsl:text>XLingPaperlistinterlinearintable</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>XLingPaperlistinterlinear</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <tex:cmd name="{$sXLingPaperListInterlinear}" nl1="1" nl2="1">
                        <tex:parm>
                            <xsl:value-of select="$sExampleIndentBefore"/>
                        </tex:parm>
                        <tex:parm>
                            <xsl:value-of select="$iNumberWidth"/>
                            <xsl:text>em</xsl:text>
                        </tex:parm>
                        <tex:parm>
                            <xsl:call-template name="GetLetterWidth">
                                <xsl:with-param name="iLetterCount" select="count(listInterlinear)"/>
                            </xsl:call-template>
                            <xsl:text>em</xsl:text>
                        </tex:parm>
                        <tex:parm>
                            <xsl:call-template name="OutputLetter"/>
                        </tex:parm>
                        <tex:parm>
                            <xsl:apply-templates/>
                        </tex:parm>
                    </tex:cmd>
                    <xsl:if test="position() != last()">
                        <xsl:choose>
                            <xsl:when test="parent::example[parent::td]">
                                <tex:spec cat="esc"/>
                                <tex:spec cat="esc"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <tex:cmd name="vspace">
                                    <tex:parm>
                                        <tex:cmd name="baselineskip" gr="0"/>
                                    </tex:parm>
                                </tex:cmd>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <tex:group nl2="1">
                    <xsl:variable name="sTableType">
                        <xsl:choose>
                            <xsl:when test="parent::example[parent::td]">tabular</xsl:when>
                            <xsl:otherwise>longtable</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:if test="$sTableType='longtable'">
                        <xsl:call-template name="SetTeXCommand">
                            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
                            <xsl:with-param name="sCommandToSet" select="'LTpre'"/>
                            <xsl:with-param name="sValue">
                                <xsl:choose>
                                    <xsl:when test="string-length($sIsoCode) &gt; 0">
                                        <xsl:text>-1.725</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="preceding-sibling::exampleHeading">
                                        <xsl:text>.1</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>-.875</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <tex:cmd name="baselineskip" gr="0" nl2="0"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <!--                    </xsl:if>-->
                        <xsl:call-template name="SetTeXCommand">
                            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
                            <xsl:with-param name="sCommandToSet" select="'LTleft'"/>
                            <xsl:with-param name="sValue">
                                <xsl:value-of select="$sExampleIndentBefore"/>
                                <xsl:text> + </xsl:text>
                                <xsl:value-of select="$iNumberWidth - .5"/>
                                <xsl:text>em</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                    <tex:env name="{$sTableType}" nl1="1">
                        <xsl:if test="$sTableType='tabular'">
                            <tex:opt>t</tex:opt>
                        </xsl:if>
                        <tex:parm>
                            <xsl:text>p</xsl:text>
                            <tex:spec cat="bg"/>
                            <xsl:value-of select="$sLetterWidth"/>
                            <xsl:text>em</xsl:text>
                            <tex:spec cat="eg"/>
                            <xsl:choose>
                                <xsl:when test="name()='listDefinition' or name()='listSingle'">
                                    <xsl:text>@</xsl:text>
                                    <tex:spec cat="bg"/>
                                    <tex:spec cat="eg"/>
                                    <xsl:text>p</xsl:text>
                                    <tex:spec cat="bg"/>
                                    <xsl:value-of select="$sExampleWidth"/>
                                    <xsl:text>-</xsl:text>
                                    <xsl:value-of select="$sExampleIndentBefore"/>
                                    <xsl:text>-</xsl:text>
                                    <xsl:value-of select="$sExampleIndentAfter"/>
                                    <xsl:text>-</xsl:text>
                                    <xsl:value-of select="$sLetterWidth"/>
                                    <xsl:text>em</xsl:text>
                                    <xsl:text>-</xsl:text>
                                    <xsl:value-of select="$iNumberWidth"/>
                                    <xsl:text>em</xsl:text>
                                    <tex:spec cat="eg"/>
                                    <xsl:text>l</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="DoInterlinearTabularMainPattern"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </tex:parm>
                        <xsl:call-template name="DoListLetter">
                            <xsl:with-param name="sLetterWidth" select="$sLetterWidth"/>
                        </xsl:call-template>
                        <tex:spec cat="align"/>
                        <!-- not sure if the following is the best or even needed...
                            <tex:cmd name="hspace*">
                            <tex:parm>-2.5pt</tex:parm>
                            </tex:cmd>  -->
                        <xsl:call-template name="OutputWordOrSingle"/>
                        <!-- remaining rows -->
                        <xsl:for-each select="following-sibling::listWord | following-sibling::listSingle | following-sibling::listDefinition">
                            <tex:spec cat="esc"/>
                            <tex:spec cat="esc" nl2="1"/>
                            <xsl:call-template name="DoListLetter">
                                <xsl:with-param name="sLetterWidth" select="$sLetterWidth"/>
                            </xsl:call-template>
                            <tex:spec cat="align"/>
                            <xsl:call-template name="OutputWordOrSingle"/>
                        </xsl:for-each>
                    </tex:env>
                </tex:group>
            </xsl:otherwise>
        </xsl:choose>
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
        OutputTable
    -->
    <xsl:template name="OutputTable">
        <xsl:variable name="iBorder" select="ancestor-or-self::table/@border"/>
        <xsl:variable name="firstRowColumns" select="tr[1]/th | tr[1]/td"/>
        <xsl:variable name="iNumCols" select="count($firstRowColumns[not(number(@colspan) &gt; 0)]) + sum($firstRowColumns[number(@colspan) &gt; 0]/@colspan)"/>
        <!-- attempt to calculate the number of columns, but we need to also set up colspans, so this won't always work... sigh.
    
    <xsl:variable name="rows">
            <rows>
                <xsl:for-each select="tr">
                    <rowcount>
                        <xsl:value-of select="count(*[not(number(@colspan) &gt; 0)]) + sum(*[number(@colspan) &gt; 0]/@colspan)"/>
                    </rowcount>
                </xsl:for-each>
            </rows>
        </xsl:variable>
        <xsl:variable name="iNumCols">
            <xsl:for-each select="saxon:node-set($rows)/descendant::*">
                <xsl:for-each select="row">
                    <xsl:sort select="." order="descending" data-type="number"/>
                    <xsl:if test="position()=1">
                        <xsl:value-of select="."/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
-->
        <xsl:variable name="sEnvName">
            <xsl:choose>
                <xsl:when test="ancestor::td or ancestor::th">
                    <!--                    <xsl:when test="parent::example or parent::td">-->
                    <xsl:text>tabular</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>longtable</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="parent::example">
                <xsl:call-template name="SetTeXCommand">
                    <xsl:with-param name="sTeXCommand" select="'setlength'"/>
                    <xsl:with-param name="sCommandToSet" select="'LTpre'"/>
                    <xsl:with-param name="sValue">
                        <xsl:choose>
                            <xsl:when test="preceding-sibling::exampleHeading">
                                <xsl:choose>
                                    <xsl:when test="caption">.25</xsl:when>
                                    <xsl:when test="$iBorder &gt;= 1">1</xsl:when>
                                    <xsl:otherwise>.25</xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="caption">-.9</xsl:when>
                            <xsl:when test="$iBorder &gt;= 1">-.5</xsl:when>
                            <xsl:otherwise>-.9</xsl:otherwise>
                        </xsl:choose>
                        <tex:cmd name="baselineskip" gr="0" nl2="0"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="SetTeXCommand">
                    <xsl:with-param name="sTeXCommand" select="'setlength'"/>
                    <xsl:with-param name="sCommandToSet" select="'LTleft'"/>
                    <xsl:with-param name="sValue">
                        <xsl:value-of select="$sExampleIndentBefore"/>
                        <xsl:text> + </xsl:text>
                        <xsl:value-of select="$iNumberWidth"/>
                        <xsl:text>em</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="not(ancestor::endnote)">
                <tex:cmd name="vspace*">
                    <tex:parm>
                        <xsl:text>-</xsl:text>
                        <tex:cmd name="baselineskip" gr="0"/>
                    </tex:parm>
                </tex:cmd>
            </xsl:when>
            <!--            <xsl:otherwise> </xsl:otherwise>-->
        </xsl:choose>
        <tex:env name="{$sEnvName}" nl1="0">
            <tex:opt>
                <xsl:choose>
                    <xsl:when test="parent::example or ancestor::table">t</xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="sAlign" select="normalize-space(@align)"/>
                        <xsl:choose>
                            <xsl:when test="string-length($sAlign) &gt; 0">
                                <xsl:choose>
                                    <xsl:when test="$sAlign='center'">c</xsl:when>
                                    <xsl:when test="$sAlign='right'">r</xsl:when>
                                    <xsl:otherwise>l</xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>l</xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </tex:opt>
            <tex:parm>
                <xsl:choose>
                    <xsl:when test="contains(@XeLaTeXSpecial,'column-formatting=')">
                        <xsl:call-template name="HandleXeLaTeXSpecialCommand">
                            <xsl:with-param name="sPattern" select="'column-formatting='"/>
                            <xsl:with-param name="default" select="'@{}l@{}'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
                        <xsl:variable name="columns" select="tr[1]/td | tr[1]/th"/>
                        <xsl:for-each select="$columns">
                            <xsl:choose>
                                <xsl:when test="number(@colspan) &gt; 0">
                                    <xsl:call-template name="CreateColumnSpec">
                                        <xsl:with-param name="iColspan" select="@colspan - 1"/>
                                        <xsl:with-param name="iBorder" select="$iBorder"/>
                                        <xsl:with-param name="bUseWidth" select="'N'"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="CreateColumnSpec">
                                        <xsl:with-param name="iBorder" select="$iBorder"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:if test="not($columns)">
                            <!-- the table is empty!  We still need something, though or TeX will complain. -->
                            <xsl:text>l</xsl:text>
                        </xsl:if>
                        <xsl:call-template name="CreateVerticalLine">
                            <xsl:with-param name="iBorder" select="$iBorder"/>
                        </xsl:call-template>
                        <xsl:call-template name="CreateColumnSpecDefaultAtExpression"/>
                    </xsl:otherwise>
                </xsl:choose>
            </tex:parm>
            <xsl:apply-templates select="caption">
                <xsl:with-param name="iNumCols" select="$iNumCols"/>
            </xsl:apply-templates>
            <xsl:if test="tr/th | headerRow">
                <xsl:call-template name="CreateHorizontalLine">
                    <xsl:with-param name="iBorder" select="$iBorder"/>
                </xsl:call-template>
                <xsl:variable name="headerRows" select="tr[th[count(following-sibling::td)=0]]"/>
                <xsl:choose>
                    <xsl:when test="count($headerRows) != 1">
                        <xsl:for-each select="$headerRows">
                            <xsl:apply-templates select="th[count(following-sibling::td)=0] | headerRow">
                                <!--                        <xsl:with-param name="iBorder" select="$iBorder"/>-->
                            </xsl:apply-templates>
                            <tex:spec cat="esc"/>
                            <tex:spec cat="esc"/>
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
            </xsl:if>
            <xsl:variable name="rows" select="tr[not(th) or th[count(following-sibling::td)!=0]]"/>
            <xsl:choose>
                <xsl:when test="$rows">
                    <xsl:apply-templates select="$rows">
                        <xsl:with-param name="iBorder" select="$iBorder"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>(This table does not have any contents!)</xsl:text>
                    <tex:spec cat="esc"/>
                    <tex:spec cat="esc"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="endCaption">
                <xsl:with-param name="iNumCols" select="$iNumCols"/>
            </xsl:apply-templates>
        </tex:env>
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
                <xsl:when test="$sFirst='underline'">
                    <tex:spec cat="esc"/>
                    <xsl:text>uline</xsl:text>
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
                <xsl:when test="$sFirst='underline'">
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
        OutputWordOrSingle
    -->
    <xsl:template name="OutputWordOrSingle">
        <xsl:choose>
            <xsl:when test="name()='listWord'">
                <xsl:for-each select="langData | gloss">
                    <xsl:apply-templates select="self::*"/>
                    <xsl:if test="position()!=last()">
                        <tex:spec cat="align"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="name()='listDefinition'">
                <xsl:for-each select="definition">
                    <xsl:apply-templates select="self::*"/>
                    <xsl:if test="position()!=last()">
                        <tex:spec cat="align"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- adjust for a single space character; is there a better way? -->
                <!-- tyring without this                <xsl:call-template name="SingleSpaceAdjust"/>-->
                <xsl:for-each select="langData | gloss">
                    <xsl:apply-templates select="self::*"/>
                    <tex:spec cat="esc"/>
                    <xsl:text>&#x20;</xsl:text>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        ReportTeXCannotHandleThisMessage
    -->
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
    <!--  
        ReverseContents
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
        SetExampleKeepWithNext
    -->
    <xsl:template name="SetExampleKeepWithNext">
        <!-- we need to make sure the example number stays on the same page as the table or list -->
        <xsl:choose>
            <xsl:when test="listWord or listSingle">
                <tex:cmd name="needspace">
                    <tex:parm>
                        <xsl:variable name="iLines" select="count(listWord | listSingle)"/>
                        <xsl:choose>
                            <xsl:when test="$iLines &gt; 3">
                                <!-- try to guarantee at least 2 lines on this page -->
                                <xsl:text>3</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- try to keep it all on same page -->
                                <xsl:value-of select="$iLines + 1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <tex:spec cat="esc"/>baselineskip</tex:parm>
                </tex:cmd>
            </xsl:when>
            <xsl:when test="table">
                <tex:cmd name="needspace">
                    <tex:parm>
                        <xsl:variable name="iMinRows" select="count(table/descendant-or-self::tr) + count(table/caption)"/>
                        <xsl:variable name="iLines">
                            <xsl:choose>
                                <xsl:when test="table/@border=1">
                                    <xsl:choose>
                                        <xsl:when test="table/descendant::th">2</xsl:when>
                                        <xsl:otherwise>1</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>0</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="iInterlinearLines" select="count(table/descendant-or-self::tr/td[1]/descendant::line)"/>
                        <xsl:variable name="iInterlinearFrees" select="count(table/descendant-or-self::tr/td[1]/descendant::free)"/>
                        <xsl:variable name="iMinLines" select="$iMinRows + $iLines + $iInterlinearLines + $iInterlinearFrees"/>
                        <xsl:choose>
                            <!-- assume if it is greater than 10, then we will get a page break somewhere within the example -->
                            <xsl:when test="$iMinLines &gt; 10">10</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$iMinLines"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <tex:spec cat="esc"/>baselineskip</tex:parm>
                </tex:cmd>
            </xsl:when>
            <xsl:when test="chart/ul or chart/ol">
                <tex:cmd name="needspace">
                    <tex:parm>
                        <xsl:variable name="iLines" select="count(descendant::li)"/>
                        <xsl:choose>
                            <xsl:when test="$iLines &gt; 3">
                                <!-- try to guarantee at least 2 lines on this page -->
                                <xsl:text>3</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- try to keep it all on same page -->
                                <xsl:value-of select="$iLines + 1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <tex:spec cat="esc"/>baselineskip</tex:parm>
                </tex:cmd>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--  
        SetHeaderFooterRuleWidths
    -->
    <xsl:template name="SetHeaderFooterRuleWidths">
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
        SetListLengthWidths
    -->
    <xsl:template name="SetListLengthWidths">
        <tex:cmd name="newlength" nl1="1">
            <tex:parm>
                <tex:cmd name="XLingPaperlistinexampleindent" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPaperlistinexampleindent'"/>
            <xsl:with-param name="sValue">
                <xsl:choose>
                    <xsl:when test="string-length($sExampleIndentBefore) &gt; 0">
                        <xsl:value-of select="$sExampleIndentBefore"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>.125in</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>+ 2.75em</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <tex:cmd name="newlength" nl1="1">
            <tex:parm>
                <tex:cmd name="XLingPaperlistitemindent" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="newlength" nl1="1">
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
        <tex:cmd name="newlength" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperspacewidth" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'settowidth'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPaperspacewidth'"/>
            <xsl:with-param name="sValue">
                <tex:spec cat="esc"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--  
        SetPageLayoutParameters
    -->
    <xsl:template name="SetPageLayoutParameters">
        <tex:cmd name="setlength" nl2="1">
            <tex:parm>
                <tex:cmd name="paperheight" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="AdjustLayoutParameterUnitName">
                    <xsl:with-param name="sLayoutParam" select="$sPageHeight"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl2="1">
            <tex:parm>
                <tex:cmd name="paperwidth" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="AdjustLayoutParameterUnitName">
                    <xsl:with-param name="sLayoutParam" select="$sPageWidth"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl2="1">
            <tex:parm>
                <tex:cmd name="topmargin" gr="0"/>
            </tex:parm>
            <tex:parm>0pt</tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl2="1">
            <tex:parm>
                <tex:cmd name="voffset" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:variable name="sPageTopMarginToAdjust">
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
                </xsl:variable>
                <xsl:call-template name="AdjustLayoutParameterUnitName">
                    <xsl:with-param name="sLayoutParam" select="$sPageTopMarginToAdjust"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl2="1">
            <tex:parm>
                <tex:cmd name="evensidemargin" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:variable name="sEvenSideMarginToAdjust">
                    <xsl:choose>
                        <xsl:when test="$pageLayoutInfo/useThesisSubmissionStyle/@singlesided='yes'">
                            <xsl:call-template name="SubtractOneInch">
                                <xsl:with-param name="sValue" select="$sPageInsideMargin"/>
                                <xsl:with-param name="iValue" select="$iPageInsideMargin"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="SubtractOneInch">
                                <xsl:with-param name="sValue" select="$sPageOutsideMargin"/>
                                <xsl:with-param name="iValue" select="$iPageOutsideMargin"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="AdjustLayoutParameterUnitName">
                    <xsl:with-param name="sLayoutParam" select="$sEvenSideMarginToAdjust"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl2="1">
            <tex:parm>
                <tex:cmd name="oddsidemargin" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:variable name="sOddSideMarginToAdjust">
                    <xsl:call-template name="SubtractOneInch">
                        <xsl:with-param name="sValue" select="$sPageInsideMargin"/>
                        <xsl:with-param name="iValue" select="$iPageInsideMargin"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="AdjustLayoutParameterUnitName">
                    <xsl:with-param name="sLayoutParam" select="$sOddSideMarginToAdjust"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl2="1">
            <tex:parm>
                <tex:cmd name="textwidth" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:variable name="sTextWidthToAdjust">
                    <xsl:value-of select="number($iPageWidth - $iPageInsideMargin - $iPageOutsideMargin)"/>
                    <xsl:call-template name="GetUnitOfMeasure">
                        <xsl:with-param name="sValue" select="$sPageWidth"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="AdjustLayoutParameterUnitName">
                    <xsl:with-param name="sLayoutParam" select="$sTextWidthToAdjust"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl2="1">
            <tex:parm>
                <tex:cmd name="textheight" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:variable name="sTextHeightToAdjust">
                    <xsl:value-of select="number($iPageHeight - $iPageTopMargin - $iPageBottomMargin - $iHeaderMargin - $iFooterMargin)"/>
                    <xsl:call-template name="GetUnitOfMeasure">
                        <xsl:with-param name="sValue" select="$sPageHeight"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="AdjustLayoutParameterUnitName">
                    <xsl:with-param name="sLayoutParam" select="$sTextHeightToAdjust"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl2="1">
            <tex:parm>
                <tex:cmd name="headheight" gr="0"/>
            </tex:parm>
            <tex:parm>
                <!-- head height needs to be about 2 points larger -->
                <xsl:value-of select="$sBasicPointSize + 2.5"/>
                <xsl:text>pt</xsl:text>
            </tex:parm>
        </tex:cmd>
        <tex:cmd name="setlength" nl2="1">
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
        <tex:cmd name="setlength" nl2="1">
            <tex:parm>
                <tex:cmd name="footskip" gr="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:call-template name="AdjustLayoutParameterUnitName">
                    <xsl:with-param name="sLayoutParam" select="$sFooterMargin"/>
                </xsl:call-template>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetSpecialTextSymbols
    -->
    <xsl:template name="SetSpecialTextSymbols">
        <tex:cmd name="DeclareTextSymbol" nl2="1">
            <tex:parm>
                <tex:cmd name="textsquarebracketleft" gr="0"/>
            </tex:parm>
            <tex:parm>EU1</tex:parm>
            <tex:parm>91</tex:parm>
        </tex:cmd>
        <tex:cmd name="DeclareTextSymbol" nl2="1">
            <tex:parm>
                <tex:cmd name="textsquarebracketright" gr="0"/>
            </tex:parm>
            <tex:parm>EU1</tex:parm>
            <tex:parm>93</tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetTeXCommand
    -->
    <xsl:template name="SetTeXCommand">
        <xsl:param name="sTeXCommand"/>
        <xsl:param name="sCommandToSet"/>
        <xsl:param name="sValue"/>
        <tex:cmd name="{$sTeXCommand}">
            <tex:parm>
                <tex:cmd name="{$sCommandToSet}" gr="0" nl2="0"/>
            </tex:parm>
            <tex:parm>
                <xsl:copy-of select="$sValue"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetTOClengths
    -->
    <xsl:template name="SetTOClengths">
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
    </xsl:template>
    <!--  
        SetUsePackages
    -->
    <xsl:template name="SetUsePackages">
        <tex:cmd name="usepackage" nl2="1">
            <tex:parm>needspace</tex:parm>
        </tex:cmd>
        <tex:cmd name="usepackage" nl2="1">
            <tex:parm>xltxtra</tex:parm>
        </tex:cmd>
        <tex:cmd name="usepackage" nl2="1">
            <tex:parm>setspace</tex:parm>
        </tex:cmd>
        <tex:cmd name="usepackage" nl2="1">
            <tex:opt>normalem</tex:opt>
            <tex:parm>ulem</tex:parm>
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
        <xsl:if test="//landscape">
            <tex:cmd name="usepackage" nl2="1">
                <tex:parm>lscape</tex:parm>
            </tex:cmd>
        </xsl:if>
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
                <xsl:text>in</xsl:text>
            </xsl:when>
            <xsl:when test="$sUnit='mm'">
                <xsl:value-of select="number($iValue - 25.4)"/>
                <xsl:text>mm</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$iValue"/>
                <xsl:value-of select="$sUnit"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
====================================
What might go in a TeX package file
====================================
-->
    <!--  
        SetTOCMacros
    -->
    <xsl:template name="SetTOCMacros">
        <xsl:call-template name="SetXLingPaperTableOfContentsMacro"/>
        <xsl:call-template name="SetXLingPaperAddToContentsMacro"/>
        <xsl:call-template name="SetXLingPaperEndTableOfContentsMacro"/>
        <xsl:call-template name="SetXLingPaperDotFillMacro"/>
        <xsl:call-template name="SetXLingPaperDottedTOCLineMacro"/>
    </xsl:template>
    <!--  
        SetXLingPaperFreeMacro
    -->
    <xsl:template name="SetXLingPaperFreeMacro">
        <!--  
            #1 is the indent
            #2 is the content of the free
        -->
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperfree" gr="0" nl2="0"/>
            </tex:parm>
            <tex:opt>2</tex:opt>
            <tex:parm>
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
                    <tex:spec cat="bg"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>2</xsl:text>
                    <tex:spec cat="eg"/>
                    <tex:cmd name="nobreak" gr="0" nl2="1"/>
                    <tex:cmd name="par" gr="0"/>
                </tex:group>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetXLingPaperExampleFreeIndent
    -->
    <xsl:template name="SetXLingPaperExampleFreeIndent">
        <tex:cmd name="newlength" nl1="1">
            <tex:parm>
                <tex:cmd name="XLingPaperexamplefreeindent" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
        <xsl:call-template name="SetTeXCommand">
            <xsl:with-param name="sTeXCommand" select="'setlength'"/>
            <xsl:with-param name="sCommandToSet" select="'XLingPaperexamplefreeindent'"/>
            <xsl:with-param name="sValue">
                <xsl:text>-.3 em</xsl:text>
                <!-- 2010.03.31  I think all this was a work-around for a bug I had where I used  $sBlockQuoteIndent instead of  $sExampleIndentBefore in examples.
    <xsl:text>-.3 em+</xsl:text>
                <xsl:variable name="iBlockQuoteIndent" select="substring($sBlockQuoteIndent,1,string-length($sBlockQuoteIndent)-2)"/>
                <xsl:variable name="iExampleIndentBefore" select="substring($sExampleIndentBefore,1,string-length($sExampleIndentBefore)-2)"/>
                <xsl:choose>
                    <xsl:when test="number($iBlockQuoteIndent) &gt; number($iExampleIndentBefore)">
                        <xsl:value-of select="$sBlockQuoteIndent"/>
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="$sExampleIndentBefore"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$sExampleIndentBefore"/>
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="$sBlockQuoteIndent"/>
                    </xsl:otherwise>
                </xsl:choose>
-->
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--  
        SetXLingPaperExampleMacro
    -->
    <xsl:template name="SetXLingPaperExampleMacro">
        <!-- based on the borrowed set toc macro from LaTeX's latex.ltx file 
            #1 is the left indent
            #2 is the right indent
            #3 is the width of the example number
            #4 is the example number
            #5 is the content of the list item
        -->
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperexample" gr="0" nl2="0"/>
            </tex:parm>
            <tex:opt>5</tex:opt>
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
                    <tex:cmd name="hspace*" nl1="1" nl2="0">
                        <tex:parm>
                            <tex:spec cat="parm"/>
                            <xsl:text>1</xsl:text>
                        </tex:parm>
                    </tex:cmd>
                    <tex:cmd name="relax" gr="0" nl2="0"/>
                    <tex:cmd name="rightskip" gr="0" nl1="1" nl2="0"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>2</xsl:text>
                    <tex:cmd name="relax" gr="0" nl2="0"/>
                    <tex:spec cat="comment"/>
                    <xsl:text> right glue for indent</xsl:text>
                    <tex:cmd name="interlinepenalty10000" gr="0" nl1="1" nl2="0"/>
                    <tex:cmd name="leavevmode" gr="0" nl1="1" nl2="0"/>
                    <tex:cmd name="XLingPapertempdim" gr="0" nl1="1" nl2="0"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>3</xsl:text>
                    <tex:cmd name="relax" gr="0" nl2="0"/>
                    <tex:spec cat="comment"/>
                    <xsl:text> example number width</xsl:text>
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
                            <tex:cmd name="normalfont" gr="0" nl2="0"/>
                            <tex:cmd name="normalcolor" gr="0" nl2="0"/>
                            <tex:spec cat="parm"/>
                            <xsl:text>4</xsl:text>
                            <tex:cmd name="hfil" gr="0" nl2="0"/>
                        </tex:parm>
                    </tex:cmd>
                    <tex:spec cat="bg"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>5</xsl:text>
                    <tex:spec cat="eg"/>
                    <tex:cmd name="nobreak" gr="0" nl2="1"/>
                    <tex:cmd name="par" gr="0"/>
                </tex:group>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!-- 
        \newcommand{\XLingPaperexampleintable}[5]{
        \newdimen\XLingPapertempdim
        %%%\vskip0pt plus .2pt{
        \leftskip#1\relax% left glue for indent
        \hspace*{#1}\relax
        \rightskip#2\relax% right glue for indent
        \interlinepenalty10000
        \leavevmode
        \XLingPapertempdim#3\relax% example number width
        %%%\advance\leftskip\XLingPapertempdim\null\nobreak\hskip-\leftskip
        \hbox to\XLingPapertempdim{\normalfont\normalcolor#4\hfil}{#5}\nobreak
        %%%\par}
        }
    -->
    <!--  
        SetXLingPaperExampleInTableMacro
    -->
    <xsl:template name="SetXLingPaperExampleInTableMacro">
        <!-- based on the borrowed set toc macro from LaTeX's latex.ltx file 
            #1 is the left indent
            #2 is the right indent
            #3 is the width of the example number
            #4 is the example number
            #5 is the content of the list item
        -->
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperexampleintable" gr="0" nl2="0"/>
            </tex:parm>
            <tex:opt>5</tex:opt>
            <tex:parm>
                <tex:cmd name="newdimen" gr="0" nl1="1" nl2="0"/>
                <tex:cmd name="XLingPapertempdim" gr="0" nl2="0"/>
                <tex:cmd name="leftskip" gr="0" nl1="1" nl2="0"/>
                <tex:spec cat="parm"/>
                <xsl:text>1</xsl:text>
                <tex:cmd name="relax" gr="0" nl2="0"/>
                <tex:spec cat="comment"/>
                <xsl:text> left glue for indent</xsl:text>
                <tex:cmd name="hspace*" nl1="1" nl2="0">
                    <tex:parm>
                        <tex:spec cat="parm"/>
                        <xsl:text>1</xsl:text>
                    </tex:parm>
                </tex:cmd>
                <tex:cmd name="relax" gr="0" nl2="0"/>
                <tex:cmd name="rightskip" gr="0" nl1="1" nl2="0"/>
                <tex:spec cat="parm"/>
                <xsl:text>2</xsl:text>
                <tex:cmd name="relax" gr="0" nl2="0"/>
                <tex:spec cat="comment"/>
                <xsl:text> right glue for indent</xsl:text>
                <tex:cmd name="interlinepenalty10000" gr="0" nl1="1" nl2="0"/>
                <tex:cmd name="leavevmode" gr="0" nl1="1" nl2="0"/>
                <tex:cmd name="XLingPapertempdim" gr="0" nl1="1" nl2="0"/>
                <tex:spec cat="parm"/>
                <xsl:text>3</xsl:text>
                <tex:cmd name="relax" gr="0" nl2="0"/>
                <tex:spec cat="comment"/>
                <xsl:text> example number width</xsl:text>
                <tex:cmd name="hbox to" gr="0" nl1="1"/>
                <tex:cmd name="XLingPapertempdim" gr="0" nl2="0">
                    <tex:parm>
                        <tex:cmd name="normalfont" gr="0" nl2="0"/>
                        <tex:cmd name="normalcolor" gr="0" nl2="0"/>
                        <tex:spec cat="parm"/>
                        <xsl:text>4</xsl:text>
                        <tex:cmd name="hfil" gr="0" nl2="0"/>
                    </tex:parm>
                </tex:cmd>
                <tex:spec cat="bg"/>
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
                    <tex:spec cat="parm"/>
                    <xsl:text>5</xsl:text>
                </tex:env>
                <tex:spec cat="eg"/>
                <tex:cmd name="nobreak" gr="0" nl2="1"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetXLingPaperIndexMacro
    -->
    <xsl:template name="SetXLingPaperIndexMacro">
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperindex" gr="0" nl2="0"/>
            </tex:parm>
            <tex:parm>
                <tex:cmd name="immediate" gr="0" nl2="0"/>
                <tex:cmd name="openout7" gr="0" nl2="0"/>
                <xsl:text> = </xsl:text>
                <tex:cmd name="jobname.idx" gr="0" nl2="0"/>
                <tex:cmd name="relax" gr="0" nl2="1"/>
                <tex:cmd name="write7">
                    <tex:parm>
                        <tex:spec cat="lt"/>
                        <xsl:text>idx</xsl:text>
                        <tex:spec cat="gt"/>
                    </tex:parm>
                </tex:cmd>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetXLingPaperIndexItemMacro
    -->
    <xsl:template name="SetXLingPaperIndexItemMacro">
        <!-- based on the borrowed set toc macro from LaTeX's latex.ltx file 
            #1 is the indent
            #4 is the content of the index item
        -->
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperindexitem" gr="0" nl2="0"/>
            </tex:parm>
            <tex:opt>2</tex:opt>
            <tex:parm>
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
                    <tex:cmd name="advance" gr="0" nl1="1" nl2="0"/>
                    <tex:cmd name="leftskip" gr="0" nl2="0"/>
                    <xsl:text>.25in</xsl:text>
                    <tex:cmd name="null" gr="0" nl2="0"/>
                    <tex:cmd name="nobreak" gr="0" nl2="0"/>
                    <tex:cmd name="hskip" gr="0" nl2="0"/>
                    <xsl:text>-</xsl:text>
                    <tex:cmd name="leftskip" gr="0" nl2="0"/>
                    <tex:spec cat="bg"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>2</xsl:text>
                    <tex:spec cat="eg"/>
                    <tex:cmd name="nobreak" gr="0" nl2="1"/>
                    <tex:cmd name="par" gr="0"/>
                </tex:group>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetXLingPaperListItemMacro
    -->
    <xsl:template name="SetXLingPaperListItemMacro">
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
                    <tex:cmd name="par" gr="0"/>
                </tex:group>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetXLingPaperListInterlinearMacro
    -->
    <xsl:template name="SetXLingPaperListInterlinearMacro">
        <!-- based on the borrowed set toc macro from LaTeX's latex.ltx file 
            #1 is the indent
            #2 is the width of the example number
            #3 is the width of the letter
            #4 is the letter
            #5 is the content 
        -->
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperlistinterlinear" gr="0" nl2="0"/>
            </tex:parm>
            <tex:opt>5</tex:opt>
            <tex:parm>
                <!--                <tex:cmd name="newdimen" gr="0" nl1="1" nl2="0"/>
                <tex:cmd name="XLingPapertempdimletter" gr="0" nl2="1"/>
-->
                <tex:cmd name="vskip" gr="0" nl2="0"/>
                <xsl:text>0pt plus .2pt</xsl:text>
                <tex:group>
                    <tex:cmd name="hspace*">
                        <tex:parm>
                            <tex:spec cat="parm"/>
                            <xsl:text>1</xsl:text>
                        </tex:parm>
                    </tex:cmd>
                    <tex:cmd name="hspace*">
                        <tex:parm>
                            <tex:spec cat="parm"/>
                            <xsl:text>2</xsl:text>
                        </tex:parm>
                    </tex:cmd>
                    <tex:cmd name="XLingPapertempdimletter" gr="0" nl1="1" nl2="0"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>3</xsl:text>
                    <tex:cmd name="relax" gr="0" nl2="0"/>
                    <tex:spec cat="comment"/>
                    <xsl:text> letter width</xsl:text>
                    <tex:cmd name="advance" gr="0" nl1="1" nl2="0"/>
                    <tex:cmd name="leftskip" gr="0" nl2="0"/>
                    <tex:cmd name="XLingPapertempdimletter" gr="0" nl2="0"/>
                    <tex:cmd name="null" gr="0" nl2="0"/>
                    <tex:cmd name="nobreak" gr="0" nl2="0"/>
                    <tex:cmd name="hskip" gr="0" nl2="0"/>
                    <xsl:text>-</xsl:text>
                    <tex:cmd name="leftskip" gr="0" nl2="0"/>
                    <tex:cmd name="hspace*" nl2="0">
                        <tex:parm>-.3em</tex:parm>
                    </tex:cmd>
                    <tex:cmd name="hbox to" gr="0" nl2="0"/>
                    <tex:cmd name="XLingPapertempdimletter" gr="0" nl2="0">
                        <tex:parm>
                            <tex:cmd name="normalfont" gr="0" nl2="0"/>
                            <tex:cmd name="normalcolor" gr="0" nl2="0"/>
                            <tex:spec cat="parm"/>
                            <xsl:text>4</xsl:text>
                            <tex:spec cat="esc"/>
                            <xsl:text>&#x20;</xsl:text>
                            <tex:cmd name="hfil" gr="0" nl2="0"/>
                        </tex:parm>
                    </tex:cmd>
                    <tex:spec cat="bg"/>
                    <tex:spec cat="parm"/>
                    <xsl:text>5</xsl:text>
                    <tex:spec cat="eg"/>
                    <tex:cmd name="nobreak" gr="0" nl2="1"/>
                    <tex:cmd name="par" gr="0"/>
                </tex:group>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetXLingPaperListInterlinearInTableMacro
    -->
    <xsl:template name="SetXLingPaperListInterlinearInTableMacro">
        <!-- based on the borrowed set toc macro from LaTeX's latex.ltx file 
            #1 is the indent
            #2 is the width of the example number
            #3 is the width of the letter
            #4 is the letter
            #5 is the content 
        -->
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperlistinterlinearintable" gr="0" nl2="0"/>
            </tex:parm>
            <tex:opt>5</tex:opt>
            <tex:parm>
                <!--     following is too much
    <tex:cmd name="hspace*">
                    <tex:parm>
                        <tex:spec cat="parm"/>
                        <xsl:text>1</xsl:text>
                    </tex:parm>
                </tex:cmd>
                <tex:cmd name="hspace*">
                    <tex:parm>
                        <tex:spec cat="parm"/>
                        <xsl:text>2</xsl:text>
                    </tex:parm>
                </tex:cmd>
-->
                <tex:cmd name="XLingPapertempdimletter" gr="0" nl1="1" nl2="0"/>
                <tex:spec cat="parm"/>
                <xsl:text>3</xsl:text>
                <tex:cmd name="relax" gr="0" nl2="0"/>
                <tex:spec cat="comment"/>
                <xsl:text> letter width</xsl:text>
                <tex:cmd name="hspace*" nl1="1">
                    <tex:parm>-.3em</tex:parm>
                </tex:cmd>
                <tex:cmd name="hbox to" gr="0" nl2="0"/>
                <tex:cmd name="XLingPapertempdimletter" gr="0" nl2="0">
                    <tex:parm>
                        <tex:cmd name="normalfont" gr="0" nl2="0"/>
                        <tex:cmd name="normalcolor" gr="0" nl2="0"/>
                        <tex:spec cat="parm"/>
                        <xsl:text>4</xsl:text>
                        <tex:spec cat="esc"/>
                        <xsl:text>&#x20;</xsl:text>
                        <tex:cmd name="hfil" gr="0" nl2="0"/>
                    </tex:parm>
                </tex:cmd>
                <tex:spec cat="bg"/>
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
                    <tex:spec cat="parm"/>
                    <xsl:text>5</xsl:text>
                </tex:env>
                <tex:spec cat="eg"/>
                <tex:cmd name="nobreak" gr="0" nl2="1"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetXLingPaperDottedTOCLineMacro
    -->
    <xsl:template name="SetXLingPaperDottedTOCLineMacro">
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
    <!--  
        SetXLingPaperDotFillMacro
    -->
    <xsl:template name="SetXLingPaperDotFillMacro">
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
                        <xsl:text> 0pt</xsl:text>
                        <tex:cmd name="mkern" gr="0" nl2="0"/>
                        <xsl:text> 4.5 mu</xsl:text>
                        <tex:cmd name="hbox">
                            <tex:parm>.</tex:parm>
                        </tex:cmd>
                        <tex:cmd name="mkern" gr="0" nl2="0"/>
                        <xsl:text> 4.5 mu</xsl:text>
                        <tex:spec cat="mshift"/>
                    </tex:parm>
                </tex:cmd>
                <tex:cmd name="hfill" gr="0" nl2="0"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetXLingPaperEndTableOfContentsMacro
    -->
    <xsl:template name="SetXLingPaperEndTableOfContentsMacro">
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
    <!--  
        SetXLingPaperEndIndexMacro
    -->
    <xsl:template name="SetXLingPaperEndIndexMacro">
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="XLingPaperendindex" gr="0" nl2="0"/>
            </tex:parm>
            <tex:parm>
                <tex:cmd name="write7">
                    <tex:parm>
                        <tex:spec cat="lt"/>
                        <xsl:text>/idx</xsl:text>
                        <tex:spec cat="gt"/>
                    </tex:parm>
                </tex:cmd>
                <tex:cmd name="closeout7" gr="0" nl2="0"/>
                <tex:cmd name="relax" gr="0" nl2="1"/>
            </tex:parm>
        </tex:cmd>
    </xsl:template>
    <!--  
        SetXLingPaperAddToContentsMacro
    -->
    <xsl:template name="SetXLingPaperAddToContentsMacro">
        <xsl:call-template name="SetXLingPaperAddElementToTocFile">
            <xsl:with-param name="sCommandName" select="'XLingPaperaddtocontents'"/>
            <xsl:with-param name="sElementName" select="'tocline'"/>
            <xsl:with-param name="sWriteNumber" select="'write8'"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        SetXLingPaperAddToIndexMacro
    -->
    <xsl:template name="SetXLingPaperAddToIndexMacro">
        <xsl:call-template name="SetXLingPaperAddElementToTocFile">
            <xsl:with-param name="sCommandName" select="'XLingPaperaddtoindex'"/>
            <xsl:with-param name="sElementName" select="'indexitem'"/>
            <xsl:with-param name="sWriteNumber" select="'write7'"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        SetXLingPaperAddElementToTocFile
    -->
    <xsl:template name="SetXLingPaperAddElementToTocFile">
        <xsl:param name="sElementName"/>
        <xsl:param name="sCommandName"/>
        <xsl:param name="sWriteNumber"/>
        <tex:cmd name="newcommand" nl2="1">
            <tex:parm>
                <tex:cmd name="{$sCommandName}" gr="0" nl2="0"/>
            </tex:parm>
            <tex:opt>1</tex:opt>
            <tex:parm>
                <tex:cmd name="{$sWriteNumber}">
                    <tex:parm>
                        <tex:spec cat="lt"/>
                        <xsl:value-of select="$sElementName"/>
                        <xsl:text> ref="</xsl:text>
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
    <!--  
        SetXLingPaperTableOfContentsMacro
    -->
    <xsl:template name="SetXLingPaperTableOfContentsMacro">
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
    <!--  
        SetXLingPaperTableOfContentsMacro
    -->
    <xsl:template name="SetZeroWidthSpaceHandling">
        <tex:spec cat="esc"/>
        <xsl:text>catcode`</xsl:text>
        <tex:spec cat="sup"/>
        <tex:spec cat="sup"/>
        <tex:spec cat="sup"/>
        <tex:spec cat="sup"/>
        <xsl:text>200b=</xsl:text>
        <tex:spec cat="esc"/>
        <xsl:text>active
</xsl:text>
        <tex:spec cat="esc"/>
        <xsl:text>def</xsl:text>
        <tex:spec cat="sup"/>
        <tex:spec cat="sup"/>
        <tex:spec cat="sup"/>
        <tex:spec cat="sup"/>
        <xsl:text>200b</xsl:text>
        <tex:spec cat="bg"/>
        <tex:spec cat="esc"/>
        <xsl:text>hskip0pt</xsl:text>
        <tex:spec cat="eg"/>
    </xsl:template>
</xsl:stylesheet>
