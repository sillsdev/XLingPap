<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">
    <!-- variables -->
    <xsl:variable name="bEndnoteRefIsDirectLinkToEndnote" select="'N'"/>
    <xsl:variable name="iIndent">
        <xsl:call-template name="ConvertToPoints">
            <xsl:with-param name="sValue" select="$sBlockQuoteIndent"/>
            <xsl:with-param name="iValue" select="number(substring($sBlockQuoteIndent,1,string-length($sBlockQuoteIndent) - 2))"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="iExampleWidth">
        <xsl:value-of select="number($iPageWidth - 2 * $iIndent - $iPageOutsideMargin - $iPageInsideMargin)"/>
    </xsl:variable>
    <xsl:variable name="sExampleWidth">
        <xsl:value-of select="$iExampleWidth"/>
        <xsl:text>pt</xsl:text>
    </xsl:variable>
    <xsl:variable name="imgBorderSeparation">
        <xsl:call-template name="GetBorderAroundImageSeparation"/>
    </xsl:variable>
    <xsl:variable name="imgBorderWidth">
        <xsl:call-template name="GetBorderAroundImageWidth"/>
    </xsl:variable>
    <!-- ===========================================================
        dd
        =========================================================== -->
    <xsl:template match="dd" mode="dt">
        <fo:list-item-body start-indent="body-start()">
            <xsl:if test="example">
                <fo:block>&#xa0;</fo:block>
            </xsl:if>
            <fo:block>
                <xsl:apply-templates/>
            </fo:block>
        </fo:list-item-body>
    </xsl:template>
    <!-- ===========================================================
        IMG
        =========================================================== -->
    <xsl:template match="img[not(ancestor::headerFooterPageStyles) or parent::fixedText]">
        <xsl:call-template name="HandleImg"/>
    </xsl:template>
    <!-- ===========================================================
        INTERLINEAR TEXT
        =========================================================== -->
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
        interlinear-text
    -->
    <xsl:template match="interlinear-text">
        <fo:block>
            <xsl:if test="preceding-sibling::p[1] or preceding-sibling::pc[1]">
                <xsl:attribute name="space-before">
                    <xsl:value-of select="$sBasicPointSize"/>
                    <xsl:text>pt</xsl:text>
                </xsl:attribute>
                <xsl:if test="string-length(@text) &gt; 0">
                    <xsl:attribute name="id">
                        <xsl:value-of select="@text"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@xsl-foSpecial">
                    <xsl:call-template name="OutputTypeAttributes">
                        <xsl:with-param name="sList" select="@xsl-foSpecial"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
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
        title
    -->
    <xsl:template match="title[ancestor::chapterInCollection]">
        <xsl:apply-templates/>
    </xsl:template>
    <!--  
        source
    -->
    <xsl:template match="source">
        <fo:block text-align="center" font-style="italic">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <!--
        free
    -->
    <xsl:template match="free">
        <xsl:param name="originalContext"/>
        <xsl:call-template name="DoInterlinearFree">
            <xsl:with-param name="originalContext" select="$originalContext"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="free" mode="NoTextRef">
        <xsl:call-template name="DoInterlinearFree">
            <xsl:with-param name="mode" select="'NoTextRef'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        literal
    -->
    <xsl:template match="literal">
        <xsl:param name="originalContext"/>
        <xsl:call-template name="DoInterlinearFree">
            <xsl:with-param name="originalContext" select="$originalContext"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="literal" mode="NoTextRef">
        <xsl:call-template name="DoInterlinearFree"/>
    </xsl:template>
    <!--
        lineGroup
    -->
    <xsl:template match="lineGroup">
        <xsl:param name="originalContext"/>
        <xsl:call-template name="DoInterlinearLineGroup">
            <xsl:with-param name="originalContext" select="$originalContext"/>
        </xsl:call-template>
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
        <xsl:param name="originalContext"/>
        <xsl:call-template name="DoInterlinearLine">
            <xsl:with-param name="originalContext" select="$originalContext"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="line" mode="NoTextRef">
        <xsl:call-template name="DoInterlinearLine">
            <xsl:with-param name="mode" select="'NoTextRef'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- ===========================================================
        FRAMEDUNIT
        =========================================================== -->
    <xsl:template match="framedUnit">
        <fo:block>
            <xsl:variable name="framedtype" select="key('FramedTypeID',@framedtype)"/>
            <xsl:attribute name="background-color">
                <xsl:call-template name="SetFramedTypeItem">
                    <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@backgroundcolor)"/>
                    <xsl:with-param name="sDefaultValue" select="'white'"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="margin-top">
                <xsl:call-template name="SetFramedTypeItem">
                    <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@spacebefore)"/>
                    <xsl:with-param name="sDefaultValue" select="'.125in'"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="margin-bottom">
                <xsl:call-template name="SetFramedTypeItem">
                    <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@spaceafter)"/>
                    <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="margin-left">
                <xsl:call-template name="SetFramedTypeItem">
                    <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@indent-before)"/>
                    <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="margin-right">
                <xsl:call-template name="SetFramedTypeItem">
                    <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@indent-after)"/>
                    <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="padding-top">
                <xsl:call-template name="SetFramedTypeItem">
                    <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@innertopmargin)"/>
                    <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="padding-bottom">
                <xsl:call-template name="SetFramedTypeItem">
                    <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@innerbottommargin)"/>
                    <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="padding-left">
                <xsl:call-template name="SetFramedTypeItem">
                    <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@innerleftmargin)"/>
                    <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="padding-right">
                <xsl:call-template name="SetFramedTypeItem">
                    <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@innerrightmargin)"/>
                    <xsl:with-param name="sDefaultValue">.125in</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="text-align">
                <xsl:call-template name="SetFramedTypeItem">
                    <xsl:with-param name="sAttributeValue" select="normalize-space($framedtype/@align)"/>
                    <xsl:with-param name="sDefaultValue">left</xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="border-width">.5pt</xsl:attribute>
            <xsl:attribute name="border-style">solid</xsl:attribute>
            <xsl:attribute name="border-color">black</xsl:attribute>
            <xsl:if test="$sLineSpacing and $sLineSpacing!='single' and $lineSpacing/@singlespaceframedunits='yes'">
                <xsl:attribute name="line-height">
                    <xsl:value-of select="$sSinglespacingLineHeight"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </fo:block>
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
        DetermineInternalOrExternalDestination
    -->
    <xsl:template name="DetermineInternalOrExternalDestination">
        <xsl:param name="sRef" select="@textref"/>
        <xsl:variable name="referencedInterlinear" select="key('InterlinearReferenceID',$sRef)"/>
        <xsl:choose>
            <xsl:when test="$referencedInterlinear[ancestor::referencedInterlinearTexts]">
                <xsl:text>external-destination</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>internal-destination</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        DoAuthorFootnoteNumber
    -->
    <xsl:template name="DoAuthorFootnoteNumber">
        <xsl:variable name="iTitleEndnote">
            <xsl:call-template name="GetCountOfEndnoteInTitleUsingSymbol"/>
        </xsl:variable>
        <xsl:variable name="iAuthorPosition" select="count(parent::author/preceding-sibling::author[endnote]) + $iTitleEndnote + 1"/>
        <xsl:call-template name="OutputAuthorFootnoteSymbol">
            <xsl:with-param name="iAuthorPosition" select="$iAuthorPosition"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        DoHorizontalRule
    -->
    <xsl:template name="DoHorizontalRule">
        <xsl:param name="line-weight"/>
        <xsl:param name="sFOProcessor"/>
        <xsl:choose>
            <xsl:when test="$sFOProcessor = 'XEP'">
                <!-- XEP correctly processes the borderbefore -->
                <xsl:choose>
                    <xsl:when test="$line-weight">
                        <fo:block keep-with-next.within-page="always">
                            <xsl:attribute name="border-after-width">
                                <xsl:value-of select="$line-weight"/>
                            </xsl:attribute>
                            <xsl:attribute name="border-after-style">
                                <xsl:text>solid</xsl:text>
                            </xsl:attribute>
                        </fo:block>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:block border-after-width="0.4pt" border-after-style="solid"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- Word 2003/ODT ignores or filters my borderafter (not sure which), using a rule instead -->
                <fo:block keep-with-next.within-page="always">
                    <xsl:choose>
                        <xsl:when test="$line-weight">
                            <fo:leader leader-pattern="rule" leader-length="100%">
                                <xsl:attribute name="rule-thickness">
                                    <xsl:value-of select="$line-weight"/>
                                </xsl:attribute>
                                <xsl:attribute name="rule-style">
                                    <xsl:text>solid</xsl:text>
                                </xsl:attribute>
                            </fo:leader>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:leader leader-pattern="rule" leader-length="100%" rule-style="solid" rule-thickness="0.4pt"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoInterlinearLineGroup
    -->
    <xsl:template name="DoInterlinearLineGroup">
        <xsl:param name="mode"/>
        <xsl:param name="originalContext"/>
        <!-- insert a new line so we don't get everything all on one line -->
        <xsl:text>&#xa;</xsl:text>
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
                    <xsl:choose>
                        <xsl:when test="string-length($sIndentOfNonInitialGroup) &gt; 0">
                            <xsl:value-of select="$sIndentOfNonInitialGroup"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>0.1in</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:if test="count(../../lineGroup[last()]/line) &gt; 1 or count(line) &gt; 1">
                    <xsl:attribute name="space-before">
                        <xsl:choose>
                            <xsl:when test="string-length($sSpaceBetweenGroups) &gt; 0">
                                <xsl:value-of select="$sSpaceBetweenGroups"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$sBasicPointSize div 2"/>
                                <xsl:text>pt</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <fo:table space-before="0pt">
                <xsl:call-template name="DoDebugExamples"/>
                <fo:table-body start-indent="0pt" end-indent="0pt" keep-together.within-page="1">
                    <xsl:call-template name="ApplyTemplatesPerTextRefMode">
                        <xsl:with-param name="mode" select="$mode"/>
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                    </xsl:call-template>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>
    <!--
        DoOl
    -->
    <xsl:template name="DoOl">
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
                <xsl:attribute name="start-indent">
                    <xsl:choose>
                        <xsl:when test="$sListInitialHorizontalOffset!='0pt'">
                            <xsl:value-of select="$sListInitialHorizontalOffset"/>
                        </xsl:when>
                        <xsl:otherwise>1em</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="provisional-distance-between-starts">1em</xsl:attribute>
            </xsl:if>
            <xsl:if test="ancestor::endnote">
                <xsl:attribute name="provisional-label-separation">0em</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </fo:list-block>
    </xsl:template>
    <!--
        DoUl
    -->
    <xsl:template name="DoUl">
        <fo:list-block>
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:if test="not(ancestor::ul)">
                <xsl:attribute name="start-indent">
                    <xsl:choose>
                        <xsl:when test="$sListInitialHorizontalOffset!='0pt'">
                            <xsl:value-of select="$sListInitialHorizontalOffset"/>
                        </xsl:when>
                        <xsl:otherwise>1em</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="provisional-distance-between-starts">1em</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="DoType"/>
            <xsl:apply-templates/>
        </fo:list-block>
    </xsl:template>
    <!--  
        ForceItalicsInContentsTitle
    -->
    <xsl:template name="ForceItalicsInContentsTitle">
        <fo:inline font-style="italic">
            <xsl:value-of select="."/>
        </fo:inline>
    </xsl:template>
    <!--
        HandleColumnWidth
    -->
    <xsl:template name="HandleColumnWidth">
        <xsl:param name="sWidth"/>
        <xsl:if test="string-length($sWidth) &gt; 0">
            <xsl:attribute name="width">
                <xsl:value-of select="$sWidth"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!--
        HandleFramedUnitEndIndent
    -->
    <xsl:template name="HandleFramedUnitEndIndent">
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
    </xsl:template>
    <!--
        HandleFramedUnitStartIndent
    -->
    <xsl:template name="HandleFramedUnitStartIndent">
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
    </xsl:template>
    <!--  
        HandleImg
    -->
    <xsl:template name="HandleImg">
        <fo:external-graphic scaling="uniform">
            <xsl:call-template name="OutputTypeAttributes">
                <xsl:with-param name="sList" select="@xsl-foSpecial"/>
            </xsl:call-template>
            <xsl:attribute name="src">
                <xsl:text>url(</xsl:text>
                <xsl:variable name="sSrc" select="normalize-space(@src)"/>
                <xsl:choose>
                    <xsl:when test="substring($sSrc,string-length($sSrc)-3) ='.mml'">
                        <xsl:variable name="sSvg" select="concat(substring($sSrc,0,string-length($sSrc)-3),'.svg')"/>
                        <xsl:value-of select="concat(substring($sSrc,0,string-length($sSrc)-3),'.svg')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@src"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
            <xsl:if test="@borderaround='yes'">
                <xsl:call-template name="InsertImageBorderAttributes"/>
            </xsl:if>
        </fo:external-graphic>
    </xsl:template>
    <!--  
        HandleLangDataGlossInWordOrListWord
    -->
    <xsl:template name="HandleLangDataGlossInWordOrListWord">
        <xsl:for-each select="langData | gloss">
            <fo:table-cell xsl:use-attribute-sets="ExampleCell">
                <xsl:call-template name="DoDebugExamples"/>
                <fo:block>
                    <xsl:apply-templates select="self::*"/>
                </fo:block>
            </fo:table-cell>
        </xsl:for-each>
    </xsl:template>
    <!--
        InsertEndnoteWarningMessage
    -->
    <xsl:template name="InsertEndnoteWarningMessage">
        <xsl:param name="sKind"/>
        <xsl:param name="sId" select="''"/>
        <fo:inline background-color="yellow">
            <xsl:text>NOTE: </xsl:text>
            <xsl:choose>
                <xsl:when test="string-length($sId)&gt;0">
                    <xsl:text>the </xsl:text>
                    <xsl:value-of select="$sKind"/>
                    <xsl:text> with id='</xsl:text>
                    <xsl:value-of select="$sId"/>
                    <xsl:text>'</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>a </xsl:text>
                    <xsl:value-of select="$sKind"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text> is missing here.  You will need to add it manually.</xsl:text>
        </fo:inline>
    </xsl:template>
    <!--  
        InsertImageBorderAttributes
    -->
    <xsl:template name="InsertImageBorderAttributes">
        <xsl:attribute name="border-left-style">
            <xsl:text>solid</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="border-top-style">
            <xsl:text>solid</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="border-right-style">
            <xsl:text>solid</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="border-bottom-style">
            <xsl:text>solid</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="padding-left">
            <xsl:value-of select="$imgBorderSeparation"/>
        </xsl:attribute>
        <xsl:attribute name="padding-top">
            <xsl:value-of select="$imgBorderSeparation"/>
        </xsl:attribute>
        <xsl:attribute name="padding-right">
            <xsl:value-of select="$imgBorderSeparation"/>
        </xsl:attribute>
        <xsl:attribute name="padding-bottom">
            <xsl:value-of select="$imgBorderSeparation"/>
        </xsl:attribute>
        <xsl:attribute name="border-left-width">
            <xsl:value-of select="$imgBorderWidth"/>
        </xsl:attribute>
        <xsl:attribute name="border-top-width">
            <xsl:value-of select="$imgBorderWidth"/>
        </xsl:attribute>
        <xsl:attribute name="border-right-width">
            <xsl:value-of select="$imgBorderWidth"/>
        </xsl:attribute>
        <xsl:attribute name="border-bottom-width">
            <xsl:value-of select="$imgBorderWidth"/>
        </xsl:attribute>
    </xsl:template>
    <!--
        OutputAbbreviationInTable
    -->
    <xsl:template name="OutputAbbreviationInTable">
        <xsl:param name="abbrsShownHere"/>
        <xsl:param name="abbrInSecondColumn"/>
        <fo:table-row>
            <xsl:if test="position() = last() -1 or position() = 1">
                <xsl:attribute name="keep-with-next.within-page">1</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputAbbreviationItemInTable">
                <xsl:with-param name="abbrsShownHere" select="$abbrsShownHere"/>
            </xsl:call-template>
            <xsl:if test="$contentLayoutInfo/abbreviationsInTableLayout/@useDoubleColumns='yes'">
                <xsl:for-each select="$abbrInSecondColumn">
                    <fo:table-cell>
                        <xsl:variable name="sSep" select="normalize-space($contentLayoutInfo/abbreviationsInTableLayout/@doubleColumnSeparation)"/>
                        <xsl:if test="string-length($sSep)&gt;0">
                            <xsl:attribute name="padding-left">
                                <xsl:value-of select="$sSep"/>
                            </xsl:attribute>
                        </xsl:if>
                    </fo:table-cell>
                    <xsl:call-template name="OutputAbbreviationItemInTable">
                        <xsl:with-param name="abbrsShownHere" select="$abbrsShownHere"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
        </fo:table-row>
    </xsl:template>
    <!--
        OutputAbbreviationItemInTable
    -->
    <xsl:template name="OutputAbbreviationItemInTable">
        <xsl:param name="abbrsShownHere"/>
        <fo:table-cell border-collapse="collapse" padding=".2em" padding-top=".01em">
            <xsl:call-template name="HandleColumnWidth">
                <xsl:with-param name="sWidth" select="normalize-space($abbrsShownHere/@abbrWidth)"/>
            </xsl:call-template>
            <fo:block>
                <fo:inline id="{@id}">
                    <xsl:call-template name="OutputAbbrTerm">
                        <xsl:with-param name="abbr" select="."/>
                    </xsl:call-template>
                </fo:inline>
            </fo:block>
        </fo:table-cell>
        <xsl:if test="not($contentLayoutInfo/abbreviationsInTableLayout/@useEqualSignsColumn) or $contentLayoutInfo/abbreviationsInTableLayout/@useEqualSignsColumn!='no'">
            <fo:table-cell border-collapse="collapse">
                <xsl:attribute name="padding-left">.2em</xsl:attribute>
                <xsl:call-template name="HandleColumnWidth">
                    <xsl:with-param name="sWidth" select="normalize-space($abbrsShownHere/@equalsWidth)"/>
                </xsl:call-template>
                <fo:block>
                    <xsl:text> = </xsl:text>
                </fo:block>
            </fo:table-cell>
        </xsl:if>
        <fo:table-cell border-collapse="collapse">
            <xsl:attribute name="padding-left">.2em</xsl:attribute>
            <xsl:call-template name="HandleColumnWidth">
                <xsl:with-param name="sWidth" select="normalize-space($abbrsShownHere/@definitionWidth)"/>
            </xsl:call-template>
            <fo:block>
                <xsl:call-template name="OutputAbbrDefinition">
                    <xsl:with-param name="abbr" select="."/>
                </xsl:call-template>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    <!--
        OutputAbbreviationsInTable
    -->
    <xsl:template name="OutputAbbreviationsInTable">
        <xsl:param name="abbrsUsed"
            select="//abbreviation[not(ancestor::chapterInCollection/backMatter/abbreviations)][//abbrRef[not(ancestor::chapterInCollection/backMatter/abbreviations) and not(ancestor::comment)]/@abbr=@id]"/>
        <fo:block>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$contentLayoutInfo/abbreviationsInTableLayout"/>
            </xsl:call-template>
            <xsl:variable name="sStartIndent" select="normalize-space($contentLayoutInfo/abbreviationsInTableLayout/@start-indent)"/>
            <xsl:if test="string-length($sStartIndent)&gt;0">
                <xsl:attribute name="margin-left">
                    <xsl:value-of select="$sStartIndent"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="count($abbrsUsed) &gt; 0">
                <fo:table space-before="12pt">
                    <fo:table-body start-indent="0pt" end-indent="0pt">
                        <!--  I'm not happy with how this poor man's attempt at getting double column works when there are long definitions.
                            The table column widths may be long and short; if a cell in the second row needs to lap over a line, then the
                            corresponding cell in the other column may skip a row (as far as what one would expect).
                            So I'm going with just a single table here.
                            <xsl:variable name="iHalfwayPoint" select="ceiling(count($abbrsUsed) div 2)"/>
                            <xsl:for-each select="$abbrsUsed[position() &lt;= $iHalfwayPoint]">
                        -->
                        <xsl:call-template name="SortAbbreviationsInTable">
                            <xsl:with-param name="abbrsUsed" select="$abbrsUsed"/>
                        </xsl:call-template>
                    </fo:table-body>
                </fo:table>
            </xsl:if>
        </fo:block>
    </xsl:template>
    <!--  
        OutputAllChapterTOC
    -->
    <xsl:template name="OutputAllChapterTOC">
        <xsl:param name="nLevel" select="3"/>
        <xsl:variable name="precedingVolume" select="preceding-sibling::*[1][name()='volume']"/>
        <xsl:if test="$precedingVolume">
            <xsl:call-template name="OutputVolumeInContents">
                <xsl:with-param name="volume" select="$precedingVolume"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputChapterNumber"/>
                <xsl:text>&#xa0;</xsl:text>
                <xsl:apply-templates select="secTitle | frontMatter/title" mode="contents"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="name()='appendix' and ancestor::chapterInCollection">1</xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="name()='chapterInCollection'">
            <fo:block text-align-last="justify" text-indent="-2em" start-indent="3em">
                <fo:inline font-style="italic">
                    <xsl:call-template name="GetAuthorsAsCommaSeparatedList"/>
                    <xsl:text>&#xa0;</xsl:text>
                    <fo:leader leader-pattern="use-content">
                        <xsl:text>&#xa0;</xsl:text>
                    </fo:leader>
                </fo:inline>
            </fo:block>
        </xsl:if>
        <xsl:apply-templates select="frontMatter/abstract | frontMatter/acknowledgements | frontMatter/preface" mode="contents"/>
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
        <xsl:call-template name="OutputChapterInCollectionBackMatterContents">
            <xsl:with-param name="nLevel" select="$nLevel"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        OutputAllSectionTOC
    -->
    <xsl:template name="OutputAllSectionTOC">
        <xsl:param name="nLevel" select="3"/>
        <xsl:param name="nodesSection1"/>
        <xsl:if test="$nLevel!=0">
            <xsl:for-each select="$nodesSection1">
                <xsl:call-template name="OutputSectionTOC">
                    <xsl:with-param name="sLevel" select="'1'"/>
                </xsl:call-template>
                <xsl:if test="section2 and $nLevel>=2">
                    <xsl:for-each select="section2">
                        <xsl:if test="parent::*[@subsectionsAreShort!='yes' or @excludeShortSubsectionsFromContents!='yes']">
                            <xsl:call-template name="OutputSectionTOC">
                                <xsl:with-param name="sLevel" select="'2'"/>
                            </xsl:call-template>
                            <xsl:if test="section3 and $nLevel>=3">
                                <xsl:for-each select="section3">
                                    <xsl:if test="parent::*[@subsectionsAreShort!='yes' or @excludeShortSubsectionsFromContents!='yes']">
                                        <xsl:call-template name="OutputSectionTOC">
                                            <xsl:with-param name="sLevel" select="'3'"/>
                                        </xsl:call-template>
                                        <xsl:if test="section4 and $nLevel>=4">
                                            <xsl:for-each select="section4">
                                                <xsl:if test="parent::*[@subsectionsAreShort!='yes' or @excludeShortSubsectionsFromContents!='yes']">
                                                    <xsl:call-template name="OutputSectionTOC">
                                                        <xsl:with-param name="sLevel" select="'4'"/>
                                                    </xsl:call-template>
                                                    <xsl:if test="section5 and $nLevel>=5">
                                                        <xsl:for-each select="section5">
                                                            <xsl:if test="parent::*[@subsectionsAreShort!='yes' or @excludeShortSubsectionsFromContents!='yes']">
                                                                <xsl:call-template name="OutputSectionTOC">
                                                                    <xsl:with-param name="sLevel" select="'5'"/>
                                                                </xsl:call-template>
                                                                <xsl:if test="section6 and $nLevel>=6">
                                                                    <xsl:for-each select="section6">
                                                                        <xsl:if test="parent::*[@subsectionsAreShort!='yes' or @excludeShortSubsectionsFromContents!='yes']">
                                                                            <xsl:call-template name="OutputSectionTOC">
                                                                                <xsl:with-param name="sLevel" select="'6'"/>
                                                                            </xsl:call-template>
                                                                        </xsl:if>
                                                                    </xsl:for-each>
                                                                </xsl:if>
                                                            </xsl:if>
                                                        </xsl:for-each>
                                                    </xsl:if>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputAppendixTOC
    -->
    <xsl:template name="OutputAppendixTOC">
        <xsl:param name="nLevel"/>
        <xsl:call-template name="OutputAllChapterTOC">
            <xsl:with-param name="nLevel">
                <xsl:value-of select="$nLevel"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--  
        OutputChapterInCollectionBackMatterContents
    -->
    <xsl:template name="OutputChapterInCollectionBackMatterContents">
        <xsl:param name="nLevel"/>
        <xsl:variable name="sChapterInCollectionID" select="ancestor-or-self::chapterInCollection/@id"/>
        <xsl:for-each select="backMatter/acknowledgements">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink">
                    <xsl:value-of select="$sAcknowledgementsID"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="$sChapterInCollectionID"/>
                </xsl:with-param>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputAcknowledgementsLabel"/>
                </xsl:with-param>
                <xsl:with-param name="sIndent" select="1"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="backMatter/appendix">
            <xsl:call-template name="OutputAppendixTOC">
                <xsl:with-param name="nLevel" select="$nLevel"/>
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="backMatter/glossary">
            <xsl:variable name="iPos" select="position()"/>
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink">
                    <xsl:value-of select="$sGlossaryID"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="$iPos"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="$sChapterInCollectionID"/>
                </xsl:with-param>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputGlossaryLabel"/>
                </xsl:with-param>
                <xsl:with-param name="sIndent" select="1"/>
            </xsl:call-template>
        </xsl:for-each>
        <!--        <xsl:for-each select="backMatter/endnotes">
            <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
            <xsl:value-of select="$sEndnotesID"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="$sChapterInCollectionID"/>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
            <xsl:call-template name="OutputEndnotesLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
            <tex:cmd name="leveloneindent" gr="0" nl2="0"/>
            </xsl:with-param>
            </xsl:call-template>
            </xsl:for-each>-->
        <xsl:for-each select="backMatter/references">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink">
                    <xsl:value-of select="$sReferencesID"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="$sChapterInCollectionID"/>
                </xsl:with-param>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputReferencesLabel"/>
                </xsl:with-param>
                <xsl:with-param name="sIndent" select="1"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--  
        OutputComment
    -->
    <xsl:template name="OutputComment">
        <fo:inline background-color="yellow">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <!--
        OutputGlossaryTerm
    -->
    <xsl:template name="OutputGlossaryTerm">
        <xsl:param name="glossaryTerm"/>
        <xsl:param name="bIsRef" select="'Y'"/>
        <xsl:param name="glossaryTermRef"/>
        <xsl:param name="kind" select="'Table'"/>
        <fo:inline>
            <xsl:variable name="fontInfoToUse">
                <xsl:choose>
                    <xsl:when test="$kind='DefinitionList'">
                        <xsl:variable name="stylesheetInfo" select="$contentLayoutInfo/glossaryTermsInDefinitionListLayout/glossaryTermTermInDefinitionListLayout"/>
                        <xsl:choose>
                            <xsl:when test="$stylesheetInfo">
                                <xsl:copy-of select="$stylesheetInfo"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="$glossaryTerms"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$glossaryTerms"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$fontInfoToUse/*"/>
                <xsl:with-param name="ignoreFontFamily">
                    <xsl:choose>
                        <xsl:when test="$glossaryTerm/@ignoreglossarytermsfontfamily='yes'">
                            <xsl:text>Y</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>N</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="OutputGlossaryTermContentInContext">
                <xsl:with-param name="glossaryTerm" select="$glossaryTerm"/>
                <xsl:with-param name="bIsRef" select="$bIsRef"/>
                <xsl:with-param name="glossaryTermRef" select="$glossaryTermRef"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>
    <!--
        OutputGlossaryTermInDefinitionList
    -->
    <xsl:template name="OutputGlossaryTermInDefinitionList">
        <xsl:param name="glossaryTermsShownHere"/>
        <xsl:variable name="defnListLayout" select="$contentLayoutInfo/glossaryTermsInDefinitionListLayout"/>
        <xsl:variable name="sThisHangingIndent" select="normalize-space($defnListLayout/@hangingIndentNormalIndent)"/>
        <xsl:variable name="sThisInitialIndent" select="normalize-space($defnListLayout/@hangingIndentInitialIndent)"/>
        <fo:block>
            <xsl:attribute name="start-indent">
                <xsl:choose>
                    <xsl:when test="string-length($sThisHangingIndent) &gt; 0">
                        <xsl:value-of select="$sThisHangingIndent"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>1em</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="text-indent">
                <xsl:text>-</xsl:text>
                <xsl:choose>
                    <xsl:when test="string-length($sThisInitialIndent) &gt; 0">
                        <xsl:variable name="iValue" select="substring($sThisInitialIndent,1, string-length($sThisInitialIndent)-2)"/>
                        <xsl:choose>
                            <xsl:when test="$iValue=0">
                                <xsl:value-of select="$sThisHangingIndent"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$sThisInitialIndent"/>
                            </xsl:otherwise>
                        </xsl:choose>
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
            <xsl:variable name="sSpaceBetween" select="normalize-space($defnListLayout/@spaceBetweenParagraphs)"/>
            <xsl:if test="string-length($sSpaceBetween) &gt; 0">
                <xsl:attribute name="space-after">
                    <xsl:value-of select="$sSpaceBetween"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$defnListLayout/@useSingleSpacing='yes'">
                <xsl:attribute name="line-height">100%</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputGlossaryTermItemAsDefinitionList">
                <xsl:with-param name="glossaryTermsShownHere" select="$glossaryTermsShownHere"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    <!--
        OutputGlossaryTermInTable
    -->
    <xsl:template name="OutputGlossaryTermInTable">
        <xsl:param name="glossaryTermsShownHere"/>
        <xsl:param name="glossaryTermInSecondColumn"/>
        <fo:table-row>
            <xsl:if test="position() = last() -1 or position() = 1">
                <xsl:attribute name="keep-with-next.within-page">1</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputGlossaryTermItemInTable">
                <xsl:with-param name="glossaryTermsShownHere" select="$glossaryTermsShownHere"/>
            </xsl:call-template>
            <xsl:if test="$contentLayoutInfo/glossaryTermsInTableLayout/@useDoubleColumns='yes'">
                <xsl:for-each select="$glossaryTermInSecondColumn">
                    <fo:table-cell>
                        <xsl:variable name="sSep" select="normalize-space($contentLayoutInfo/glossaryTermsInTableLayout/@doubleColumnSeparation)"/>
                        <xsl:if test="string-length($sSep)&gt;0">
                            <xsl:attribute name="padding-left">
                                <xsl:value-of select="$sSep"/>
                            </xsl:attribute>
                        </xsl:if>
                    </fo:table-cell>
                    <xsl:call-template name="OutputGlossaryTermItemInTable">
                        <xsl:with-param name="glossaryTermsShownHere" select="$glossaryTermsShownHere"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
        </fo:table-row>
    </xsl:template>
    <!--
        OutputGlossaryTermItemAsDefinitionList
    -->
    <xsl:template name="OutputGlossaryTermItemAsDefinitionList">
        <xsl:param name="glossaryTermsShownHere"/>
        <xsl:variable name="defnListLayout" select="$contentLayoutInfo/glossaryTermsInDefinitionListLayout"/>
        <fo:inline id="{@id}">
            <xsl:variable name="sBefore" select="$defnListLayout/glossaryTermTermInDefinitionListLayout/@textbefore"/>
            <xsl:if test="string-length($sBefore) &gt; 0">
                <xsl:value-of select="$sBefore"/>
            </xsl:if>
            <xsl:call-template name="OutputGlossaryTerm">
                <xsl:with-param name="glossaryTerm" select="."/>
                <xsl:with-param name="bIsRef" select="'N'"/>
                <xsl:with-param name="kind" select="'DefinitionList'"/>
            </xsl:call-template>
            <xsl:variable name="sAfter" select="$defnListLayout/glossaryTermTermInDefinitionListLayout/@textafter"/>
            <xsl:choose>
                <xsl:when test="string-length($sAfter) &gt; 0">
                    <xsl:value-of select="$sAfter"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>: </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </fo:inline>
        <fo:inline>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$defnListLayout/glossaryTermDefinitionInDefinitionListLayout"/>
            </xsl:call-template>
            <xsl:variable name="sBefore" select="$defnListLayout/glossaryTermDefinitionInDefinitionListLayout/@textbefore"/>
            <xsl:if test="string-length($sBefore) &gt; 0">
                <xsl:value-of select="$sBefore"/>
            </xsl:if>
            <xsl:call-template name="OutputGlossaryTermDefinition">
                <xsl:with-param name="glossaryTerm" select="."/>
            </xsl:call-template>
            <xsl:variable name="sAfter" select="$defnListLayout/glossaryTermDefinitionInDefinitionListLayout/@textafter"/>
            <xsl:if test="string-length($sAfter) &gt; 0">
                <xsl:value-of select="$sAfter"/>
            </xsl:if>
        </fo:inline>
    </xsl:template>
    <!--
        OutputGlossaryTermItemInTable
    -->
    <xsl:template name="OutputGlossaryTermItemInTable">
        <xsl:param name="glossaryTermsShownHere"/>
        <fo:table-cell border-collapse="collapse" padding=".2em" padding-top=".01em">
            <xsl:call-template name="HandleColumnWidth">
                <xsl:with-param name="sWidth" select="normalize-space($glossaryTermsShownHere/@glossaryTermWidth)"/>
            </xsl:call-template>
            <fo:block>
                <fo:inline id="{@id}">
                    <xsl:call-template name="OutputGlossaryTerm">
                        <xsl:with-param name="glossaryTerm" select="."/>
                        <xsl:with-param name="bIsRef" select="'N'"/>
                    </xsl:call-template>
                </fo:inline>
            </fo:block>
        </fo:table-cell>
        <xsl:if test="not($contentLayoutInfo/glossaryTermsInTableLayout/@useEqualSignsColumn) or $contentLayoutInfo/glossaryTermsInTableLayout/@useEqualSignsColumn!='no'">
            <fo:table-cell border-collapse="collapse">
                <xsl:attribute name="padding-left">.2em</xsl:attribute>
                <xsl:call-template name="HandleColumnWidth">
                    <xsl:with-param name="sWidth" select="normalize-space($glossaryTermsShownHere/@equalsWidth)"/>
                </xsl:call-template>
                <fo:block>
                    <xsl:text> = </xsl:text>
                </fo:block>
            </fo:table-cell>
        </xsl:if>
        <fo:table-cell border-collapse="collapse">
            <xsl:attribute name="padding-left">.2em</xsl:attribute>
            <xsl:call-template name="HandleColumnWidth">
                <xsl:with-param name="sWidth" select="normalize-space($glossaryTermsShownHere/@definitionWidth)"/>
            </xsl:call-template>
            <fo:block>
                <xsl:call-template name="OutputGlossaryTermDefinition">
                    <xsl:with-param name="glossaryTerm" select="."/>
                </xsl:call-template>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    <!--
        OutputGlossaryTermsAsDefinitionList
    -->
    <xsl:template name="OutputGlossaryTermsAsDefinitionList">
        <xsl:param name="glossaryTermsUsed"
            select="//glossaryTerm[not(ancestor::chapterInCollection/backMatter/glossaryTerms)][//glossaryTermRef[not(ancestor::chapterInCollection/backMatter/glossaryTerms)]/@glossaryTerm=@id]"/>
        <fo:block>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$contentLayoutInfo/glossaryTermsAsDefinitionLayout"/>
            </xsl:call-template>
            <xsl:variable name="sStartIndent" select="normalize-space($contentLayoutInfo/glossaryTermsAsDefinitionLayout/@start-indent)"/>
            <xsl:if test="string-length($sStartIndent)&gt;0">
                <xsl:attribute name="margin-left">
                    <xsl:value-of select="$sStartIndent"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="count($glossaryTermsUsed) &gt; 0">
                <xsl:call-template name="SortGlossaryTermsAsDefinitionList">
                    <xsl:with-param name="glossaryTermsUsed" select="$glossaryTermsUsed"/>
                </xsl:call-template>
            </xsl:if>
        </fo:block>
    </xsl:template>
    <!--
        OutputGlossaryTermsInTable
    -->
    <xsl:template name="OutputGlossaryTermsInTable">
        <xsl:param name="glossaryTermsUsed"
            select="//glossaryTerm[not(ancestor::chapterInCollection/backMatter/glossaryTerms)][//glossaryTermRef[not(ancestor::chapterInCollection/backMatter/glossaryTerms)]/@glossaryTerm=@id]"/>
        <fo:block>
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="$contentLayoutInfo/glossaryTermsInTableLayout"/>
            </xsl:call-template>
            <xsl:variable name="sStartIndent" select="normalize-space($contentLayoutInfo/glossaryTermsInTableLayout/@start-indent)"/>
            <xsl:if test="string-length($sStartIndent)&gt;0">
                <xsl:attribute name="margin-left">
                    <xsl:value-of select="$sStartIndent"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="count($glossaryTermsUsed) &gt; 0">
                <fo:table space-before="12pt">
                    <fo:table-body start-indent="0pt" end-indent="0pt">
                        <!--  I'm not happy with how this poor man's attempt at getting double column works when there are long definitions.
                            The table column widths may be long and short; if a cell in the second row needs to lap over a line, then the
                            corresponding cell in the other column may skip a row (as far as what one would expect).
                            So I'm going with just a single table here.
                            <xsl:variable name="iHalfwayPoint" select="ceiling(count($abbrsUsed) div 2)"/>
                            <xsl:for-each select="$abbrsUsed[position() &lt;= $iHalfwayPoint]">
                        -->
                        <xsl:call-template name="SortGlossaryTermsInTable">
                            <xsl:with-param name="glossaryTermsUsed" select="$glossaryTermsUsed"/>
                        </xsl:call-template>
                    </fo:table-body>
                </fo:table>
            </xsl:if>
        </fo:block>
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
                    <fo:leader/>
                    <fo:inline>
                        <!--                        <xsl:text disable-output-escaping="yes">&#xa0;&#xa0;</xsl:text>
                        -->
                        <xsl:call-template name="OutputInterlinearTextReferenceContent">
                            <xsl:with-param name="sSource" select="$sSource"/>
                            <xsl:with-param name="sRef" select="$sRef"/>
                        </xsl:call-template>
                    </fo:inline>
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
        OutputISO639-3CodeInCommaSeparatedList
    -->
    <xsl:template name="OutputISO639-3CodeInCommaSeparatedList">
        <fo:inline id="{@id}">
            <xsl:value-of select="@ISO639-3Code"/>
            <xsl:text> = </xsl:text>
            <xsl:call-template name="OutputISO639-3CodeLanguageName">
                <xsl:with-param name="language" select="."/>
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
        OutputISO639-3CodeInTable
    -->
    <xsl:template name="OutputISO639-3CodeInTable">
        <xsl:param name="codesShownHere"/>
        <xsl:param name="codeInSecondColumn"/>
        <fo:table-row>
            <xsl:if test="position() = last() -1 or position() = 1">
                <xsl:attribute name="keep-with-next.within-page">1</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="OutputISO639-3CodeItemInTable">
                <xsl:with-param name="codesShownHere" select="$codesShownHere"/>
            </xsl:call-template>
            <xsl:if test="$contentLayoutInfo/iso639-3CodesInTableLayout/@useDoubleColumns='yes'">
                <xsl:for-each select="$codeInSecondColumn">
                    <fo:table-cell>
                        <xsl:variable name="sSep" select="normalize-space($contentLayoutInfo/iso639-3CodesInTableLayout/@doubleColumnSeparation)"/>
                        <xsl:if test="string-length($sSep)&gt;0">
                            <xsl:attribute name="padding-left">
                                <xsl:value-of select="$sSep"/>
                            </xsl:attribute>
                        </xsl:if>
                    </fo:table-cell>
                    <xsl:call-template name="OutputISO639-3CodeItemInTable">
                        <xsl:with-param name="codesShownHere" select="$codesShownHere"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
        </fo:table-row>
    </xsl:template>
    <!--
        OutputISO639-3CodeItemInTable
    -->
    <xsl:template name="OutputISO639-3CodeItemInTable">
        <xsl:param name="codesShownHere"/>
        <fo:table-cell border-collapse="collapse" padding=".2em" padding-top=".01em">
            <xsl:call-template name="HandleColumnWidth">
                <xsl:with-param name="sWidth" select="normalize-space($codesShownHere/@codeWidth)"/>
            </xsl:call-template>
            <fo:block>
                <fo:inline id="{@id}">
                    <xsl:value-of select="@ISO639-3Code"/>
                </fo:inline>
            </fo:block>
        </fo:table-cell>
        <xsl:if test="not($contentLayoutInfo/iso639-3CodesInTableLayout/@useEqualSignsColumn) or $contentLayoutInfo/iso639-3CodesInTableLayout/@useEqualSignsColumn!='no'">
            <fo:table-cell border-collapse="collapse">
                <xsl:attribute name="padding-left">.2em</xsl:attribute>
                <xsl:call-template name="HandleColumnWidth">
                    <xsl:with-param name="sWidth" select="normalize-space($codesShownHere/@equalsWidth)"/>
                </xsl:call-template>
                <fo:block>
                    <xsl:text> = </xsl:text>
                </fo:block>
            </fo:table-cell>
        </xsl:if>
        <fo:table-cell border-collapse="collapse">
            <xsl:attribute name="padding-left">.2em</xsl:attribute>
            <xsl:call-template name="HandleColumnWidth">
                <xsl:with-param name="sWidth" select="normalize-space($codesShownHere/@languageNameWidth)"/>
            </xsl:call-template>
            <fo:block>
                <xsl:call-template name="OutputISO639-3CodeLanguageName">
                    <xsl:with-param name="language" select="."/>
                </xsl:call-template>
            </fo:block>
        </fo:table-cell>
    </xsl:template>
    <!--
        OutputISO639-3CodesInTable
    -->
    <xsl:template name="OutputISO639-3CodesInTable">
        <xsl:param name="codesUsed"
            select="//language[//iso639-3codeRef[not(ancestor::chapterInCollection)]/@lang=@id or //lineGroup/line[1]/descendant::langData[1][not(ancestor::chapterInCollection)]/@lang=@id or //word/langData[1][not(ancestor::chapterInCollection)]/@lang=@id or //listWord/langData[1][not(ancestor::chapterInCollection)]/@lang=@id]"/>
        <xsl:if test="count($codesUsed) &gt; 0">
            <fo:block>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$contentLayoutInfo/iso639-3CodesInTableLayout"/>
                </xsl:call-template>
                <xsl:variable name="sStartIndent" select="normalize-space($contentLayoutInfo/iso639-3CodesInTableLayout/@start-indent)"/>
                <xsl:if test="string-length($sStartIndent)&gt;0">
                    <xsl:attribute name="margin-left">
                        <xsl:value-of select="$sStartIndent"/>
                    </xsl:attribute>
                </xsl:if>
                <fo:table space-before="12pt">
                    <fo:table-body start-indent="0pt" end-indent="0pt">
                        <!--  I'm not happy with how this poor man's attempt at getting double column works when there are long definitions.
                                The table column widths may be long and short; if a cell in the second row needs to lap over a line, then the
                                corresponding cell in the other column may skip a row (as far as what one would expect).
                                So I'm going with just a single table here.
                                <xsl:variable name="iHalfwayPoint" select="ceiling(count($abbrsUsed) div 2)"/>
                                <xsl:for-each select="$abbrsUsed[position() &lt;= $iHalfwayPoint]">
                            -->
                        <xsl:call-template name="SortISO639-3CodesInTable">
                            <xsl:with-param name="codesUsed" select="$codesUsed"/>
                        </xsl:call-template>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </xsl:if>
    </xsl:template>
    <!--
        OutputISOCodeInExample
    -->
    <xsl:template name="OutputISOCodeInExample">
        <xsl:param name="sIsoCode"/>
        <xsl:param name="bOutputBreak" select="'Y'"/>
        <xsl:choose>
            <xsl:when test="string-length($sIsoCode) &gt; 0">
                <xsl:if test="$bOutputBreak='Y'">
                    <fo:block/>
                </xsl:if>
                <fo:inline font-size="smaller">
                    <xsl:text>[</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$bShowISO639-3Codes='Y'">
                            <fo:basic-link internal-destination="{$languages[@ISO639-3Code=$sIsoCode]/@id}">
                                <xsl:call-template name="AddAnyLinkAttributes">
                                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/iso639-3CodesLinkLayout"/>
                                </xsl:call-template>
                                <xsl:value-of select="$sIsoCode"/>
                            </fo:basic-link>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$sIsoCode"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>]</xsl:text>
                </fo:inline>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="firstLangData" select="descendant::langData[1] | key('InterlinearReferenceID',interlinearRef/@textref)[1]/descendant::langData[1]"/>
                <xsl:if test="$firstLangData">
                    <xsl:variable name="sIsoCode2" select="key('LanguageID',$firstLangData/@lang)/@ISO639-3Code"/>
                    <xsl:if test="string-length($sIsoCode2) &gt; 0">
                        <xsl:if test="$bOutputBreak='Y'">
                            <fo:block/>
                        </xsl:if>
                        <fo:inline font-size="smaller">
                            <xsl:text>[</xsl:text>
                            <xsl:choose>
                                <xsl:when test="$bShowISO639-3Codes='Y'">
                                    <fo:basic-link internal-destination="{$languages[@ISO639-3Code=$sIsoCode2]/@id}">
                                        <xsl:call-template name="AddAnyLinkAttributes">
                                            <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/iso639-3CodesLinkLayout"/>
                                        </xsl:call-template>
                                        <xsl:value-of select="$sIsoCode2"/>
                                    </fo:basic-link>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$sIsoCode2"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>]</xsl:text>
                        </fo:inline>
                    </xsl:if>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        OutputListLevelISOCode
    -->
    <xsl:template name="OutputListLevelISOCode">
        <xsl:param name="bListsShareSameCode"/>
        <xsl:if test="$lingPaper/@showiso639-3codeininterlinear='yes' or ancestor-or-self::example/@showiso639-3codes='yes'">
            <xsl:if test="contains($bListsShareSameCode,'N')">
                <fo:table-cell padding-end=".5em">
                    <fo:block>
                        <xsl:call-template name="OutputISOCodeInExample">
                            <xsl:with-param name="bOutputBreak" select="'N'"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:table-cell>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputSpaceAfter
    -->
    <xsl:template name="OutputSpaceAfter">
        <xsl:param name="spacing"/>
        <xsl:variable name="sSpacing" select="normalize-space($spacing)"/>
        <xsl:if test="string-length($sSpacing)&gt; 2">
            <xsl:attribute name="space-after">
                <xsl:value-of select="$sSpacing"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputSpaceBefore
    -->
    <xsl:template name="OutputSpaceBefore">
        <xsl:param name="spacing"/>
        <xsl:variable name="sSpacing" select="normalize-space($spacing)"/>
        <xsl:if test="string-length($sSpacing)&gt; 2">
            <xsl:attribute name="space-before">
                <xsl:value-of select="$sSpacing"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- 
        SetChapterNumberWidth
    -->
    <xsl:template name="SetChapterNumberWidth"/>
    <!--  
        SetFramedTypeItem
    -->
    <xsl:template name="SetFramedTypeItem">
        <xsl:param name="sAttributeValue"/>
        <xsl:param name="sDefaultValue"/>
        <xsl:choose>
            <xsl:when test="string-length($sAttributeValue) &gt; 0">
                <xsl:value-of select="$sAttributeValue"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sDefaultValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        SetMetadata
    -->
    <xsl:template name="SetMetadata">
        <rx:meta-info>
            <rx:meta-field name="author">
                <xsl:attribute name="value">
                    <xsl:call-template name="SetMetadataAuthor"/>
                </xsl:attribute>
            </rx:meta-field>
            <xsl:if test="$lingPaper/frontMatter/title != ''">
                <rx:meta-field name="title">
                    <xsl:attribute name="value">
                        <xsl:call-template name="SetMetadataTitle"/>
                    </xsl:attribute>
                </rx:meta-field>
            </xsl:if>
            <xsl:if test="string-length($lingPaper/publishingInfo/keywords) &gt; 0">
                <rx:meta-field name="keywords">
                    <xsl:attribute name="value">
                        <xsl:call-template name="SetMetadataKeywords"/>
                    </xsl:attribute>
                </rx:meta-field>
            </xsl:if>
            <rx:meta-field name="creator">
                <xsl:attribute name="value">
                    <xsl:call-template name="SetMetadataCreator"/>
                </xsl:attribute>
            </rx:meta-field>
        </rx:meta-info>
    </xsl:template>
</xsl:stylesheet>
