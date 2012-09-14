<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format">
    <!-- variables -->
    <xsl:variable name="bEndnoteRefIsDirectLinkToEndnote" select="'N'"/>
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
        <xsl:variable name="iAuthorPosition" select="count(parent::author/preceding-sibling::author[endnote]) + 1"/>
        <xsl:call-template name="OutputAuthorFootnoteSymbol">
            <xsl:with-param name="iAuthorPosition" select="$iAuthorPosition"/>
        </xsl:call-template>
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
                    <xsl:text>0.1in</xsl:text>
                </xsl:attribute>
                <xsl:if test="count(../../lineGroup[last()]/line) &gt; 1 or count(line) &gt; 1">
                    <xsl:attribute name="space-before">
                        <xsl:value-of select="$sBasicPointSize div 2"/>
                        <xsl:text>pt</xsl:text>
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
        OutputAbbreviationInTable
    -->
    <xsl:template name="OutputAbbreviationInTable">
        <fo:table-row>
            <xsl:if test="position() = last() -1 or position() = 1">
                <xsl:attribute name="keep-with-next.within-page">1</xsl:attribute>
            </xsl:if>
            <fo:table-cell border-collapse="collapse" padding=".2em" padding-top=".01em">
                <fo:block>
                    <fo:inline id="{@id}">
                        <xsl:call-template name="OutputAbbrTerm">
                            <xsl:with-param name="abbr" select="."/>
                        </xsl:call-template>
                    </fo:inline>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-collapse="collapse">
                <xsl:attribute name="padding-left">.2em</xsl:attribute>
                <fo:block>
                    <xsl:text> = </xsl:text>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-collapse="collapse">
                <xsl:attribute name="padding-left">.2em</xsl:attribute>
                <fo:block>
                    <xsl:call-template name="OutputAbbrDefinition">
                        <xsl:with-param name="abbr" select="."/>
                    </xsl:call-template>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    <!--
        OutputAbbreviationsInTable
    -->
    <xsl:template name="OutputAbbreviationsInTable">
        <fo:block>
            <xsl:variable name="abbrsUsed" select="//abbreviation[//abbrRef/@abbr=@id]"/>
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
        OutputISOCodeInExample
    -->
    <xsl:template name="OutputISOCodeInExample">
        <xsl:param name="bOutputBreak" select="'Y'"/>
        <xsl:variable name="firstLangData" select="descendant::langData[1] | key('InterlinearReferenceID',interlinearRef/@textref)[1]/descendant::langData[1]"/>
        <xsl:if test="$firstLangData">
            <xsl:variable name="sIsoCode" select="key('LanguageID',$firstLangData/@lang)/@ISO639-3Code"/>
            <xsl:if test="string-length($sIsoCode) &gt; 0">
                <xsl:if test="$bOutputBreak='Y'">
                    <fo:block/>
                </xsl:if>
                <fo:inline font-size="smaller">
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="$sIsoCode"/>
                    <xsl:text>]</xsl:text>
                </fo:inline>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--
        OutputListLevelISOCode
    -->
    <xsl:template name="OutputListLevelISOCode">
        <xsl:param name="bListsShareSameCode"/>
        <xsl:if test="$lingPaper/@showiso639-3codeininterlinear='yes'">
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
</xsl:stylesheet>
