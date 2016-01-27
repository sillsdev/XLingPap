<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!-- ===========================================================
        Global variables
        =========================================================== -->
    <xsl:variable name="sExampleCellPadding">padding-left: .25em</xsl:variable>
    <xsl:variable name="sListLayoutSpaceBetween" select="normalize-space($contentLayoutInfo/listLayout/@spacebetween)"/>
    <!-- ===========================================================
        Attribute sets
        =========================================================== -->
    <xsl:attribute-set name="TablePaddingSpacing">
        <xsl:attribute name="style">
            <xsl:text>border-collapse:collapse</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="cellpadding">
            <xsl:call-template name="DefaultCellPaddingSpacing"/>
        </xsl:attribute>
        <xsl:attribute name="cellspacing">
            <xsl:call-template name="DefaultCellPaddingSpacing"/>
        </xsl:attribute>
    </xsl:attribute-set>
    <!--
        caption for a table
    -->
    <xsl:template match="caption"/>
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
        endCaption for a table
    -->
    <xsl:template match="endCaption"/>
    <!-- ===========================================================
        ENDNOTES and ENDNOTEREFS
        =========================================================== -->
    <!--
        endnote in flow of text
    -->
    <xsl:template match="endnote">
        <xsl:param name="originalContext"/>
        <xsl:call-template name="OutputEndnoteNumber">
            <xsl:with-param name="attr" select="@id"/>
            <xsl:with-param name="originalContext" select="$originalContext"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        endnote in back matter
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
    <!-- ===========================================================
        LISTS
        =========================================================== -->
    <xsl:template match="ol">
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
        <ol>
            <xsl:attribute name="style">
                <xsl:text>list-style-type:</xsl:text>
                <xsl:variable name="sNumberFormat" select="@numberFormat"/>
                <xsl:choose>
                    <xsl:when test="string-length($sNumberFormat) &gt; 0">
                        <xsl:choose>
                            <xsl:when test="$sNumberFormat='1'">
                                <xsl:text>decimal</xsl:text>
                            </xsl:when>
                            <xsl:when test="$sNumberFormat='A'">
                                <xsl:text>upper-alpha</xsl:text>
                            </xsl:when>
                            <xsl:when test="$sNumberFormat='a'">
                                <xsl:text>lower-alpha</xsl:text>
                            </xsl:when>
                            <xsl:when test="$sNumberFormat='I'">
                                <xsl:text>upper-roman</xsl:text>
                            </xsl:when>
                            <xsl:when test="$sNumberFormat='i'">
                                <xsl:text>lower-roman</xsl:text>
                            </xsl:when>
                            <xsl:when test="$sNumberFormat='01'">
                                <xsl:text>decimal-leading-zero</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>decimal</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="($NestingLevel mod 3)=0">
                                <xsl:text>decimal</xsl:text>
                            </xsl:when>
                            <xsl:when test="($NestingLevel mod 3)=1">
                                <xsl:text>lower-alpha</xsl:text>
                            </xsl:when>
                            <xsl:when test="($NestingLevel mod 3)=2">
                                <xsl:text>lower-roman</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>; </xsl:text>
                <xsl:call-template name="DoType"/>
                <xsl:call-template name="OutputCssSpecial">
                    <xsl:with-param name="fDoStyleAttribute" select="'N'"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>
        </ol>
    </xsl:template>
    <xsl:template match="ul">
        <ul>
            <xsl:attribute name="style">
                <xsl:text>list-style-type:disc; </xsl:text>
                <xsl:call-template name="DoType"/>
                <xsl:call-template name="OutputCssSpecial">
                    <xsl:with-param name="fDoStyleAttribute" select="'N'"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="li">
        <li>
            <xsl:if test="@id">
                <a name="{@id}"/>
            </xsl:if>
            <xsl:if test="following-sibling::*[1][name()='li'] and string-length($sListLayoutSpaceBetween) &gt; 0">
                <xsl:attribute name="style">
                    <xsl:text>padding-bottom:</xsl:text>
                    <xsl:value-of select="$sListLayoutSpaceBetween"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="dl">
        <dl>
            <xsl:call-template name="OutputCssSpecial">
                <xsl:with-param name="fDoStyleAttribute" select="'Y'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </dl>
    </xsl:template>
    <xsl:template match="dt">
        <dt class="dt">
            <xsl:apply-templates/>
        </dt>
    </xsl:template>
    <xsl:template match="dd">
        <dd>
            <xsl:apply-templates/>
        </dd>
    </xsl:template>
    <!--
        definition
    -->
    <xsl:template match="example/definition">
        <xsl:element name="table" use-attribute-sets="TablePaddingSpacing">
            <tr>
                <xsl:call-template name="DoDefinition"/>
            </tr>
        </xsl:element>
    </xsl:template>
    <xsl:template match="definition[not(parent::example)]">
        <!-- the parent is a paragraph -->
        <!--        <xsl:choose>
            <xsl:when test="child::ol | child::ul | child::dl">
-->
        <!-- Ideally, we would figure out how to deal with embedded lists;
                    But we're punting for now.
                    now we have to output what goes in the paragraph before the list, end the paragrpah, start the list, and then input any other material at the end -->
        <!--           <span>
                    <xsl:choose>
                        <xsl:when test="@type">
                            <xsl:element name="span">
                                <xsl:attribute name="style">
                                    <xsl:call-template name="DoType"/>
                                </xsl:attribute>
                                <xsl:choose>
                                    <xsl:when test="child::ol | child::ul | child::dl | child::img | child::object | child::br">
                                        <xsl:apply-templates/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="." disable-output-escaping="yes"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates/>
                            <!-\-                <xsl:value-of select="." disable-output-escaping="yes"/> -\->
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:when>
            <xsl:otherwise>
     -->
        <span>
            <xsl:choose>
                <xsl:when test="@type">
                    <xsl:element name="span">
                        <xsl:attribute name="style">
                            <xsl:call-template name="DoType"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="child::ol | child::ul | child::dl | child::img | child::object | child::br">
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="." disable-output-escaping="yes"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                    <!--                <xsl:value-of select="." disable-output-escaping="yes"/> -->
                </xsl:otherwise>
            </xsl:choose>
        </span>
        <!--            </xsl:otherwise>
        </xsl:choose>
-->
    </xsl:template>
    <!-- ===========================================================
        keyTerm
        =========================================================== -->
    <xsl:template match="keyTerm">
        <xsl:element name="span">
            <xsl:attribute name="style">
                <xsl:call-template name="DoType"/>
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="."/>
                </xsl:call-template>
                <xsl:if test="not(@font-style) and not(key('TypeID',@type)/@font-style)">
                    <xsl:text>font-style:italic;</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <!--
        headerRow for a table
    -->
    <xsl:template match="headerRow">
        <tr>
            <xsl:attribute name="style">
                <xsl:call-template name="DoType"/>
                <xsl:call-template name="OutputCssSpecial">
                    <xsl:with-param name="fDoStyleAttribute">N</xsl:with-param>
                </xsl:call-template>
                <xsl:if test="@direction">
                    <xsl:text>direction:</xsl:text>
                    <xsl:value-of select="@direction"/>
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:call-template name="OutputBackgroundColor"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    <!--
        headerCol for a table
    -->
    <xsl:template match="th | headerCol">
        <xsl:element name="th">
            <xsl:call-template name="DoCellAttributes"/>
            <xsl:if test="not(@align)">
                <xsl:attribute name="align">left</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@valign)">
                <xsl:attribute name="valign">top</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="style">
                <xsl:call-template name="DoType"/>
                <xsl:text>padding-left:.2em; </xsl:text>
                <xsl:call-template name="OutputBackgroundColor"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <!--
        row for a table
    -->
    <xsl:template match="tr | row">
        <tr>
            <xsl:attribute name="style">
                <xsl:call-template name="DoType"/>
                <xsl:call-template name="OutputCssSpecial">
                    <xsl:with-param name="fDoStyleAttribute">N</xsl:with-param>
                </xsl:call-template>
                <xsl:if test="@direction">
                    <xsl:text>direction:</xsl:text>
                    <xsl:value-of select="@direction"/>
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:call-template name="OutputBackgroundColor"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    <!--
        col for a table
    -->
    <xsl:template match="td | col">
        <xsl:element name="td">
            <xsl:call-template name="DoCellAttributes"/>
            <xsl:attribute name="style">
                <xsl:call-template name="DoType"/>
                <xsl:text>padding-left:.2em</xsl:text>
                <xsl:call-template name="OutputCssSpecial">
                    <xsl:with-param name="fDoStyleAttribute" select="'N'"/>
                </xsl:call-template>
                <xsl:call-template name="OutputDirection"/>
                <!--                <xsl:call-template name="OutputBackgroundColor"/>-->
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <!-- ===========================================================
        IMG
        =========================================================== -->
    <xsl:template match="img">
        <xsl:variable name="sSrc" select="normalize-space(@src)"/>
        <xsl:variable name="sDescription" select="normalize-space(@description)"/>
        <xsl:choose>
            <xsl:when test="substring($sSrc,string-length($sSrc)-3) ='.svg'">
                <xsl:choose>
                    <xsl:when test="$bEBook='Y'">
                        <xsl:copy-of select="document(concat($sMainSourcePath, '/', $sSrc))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <embed src="{$sSrc}" type="image/svg+xml" pluginspage="http://www.adobe.com/svg/viewer/install/">
                            <xsl:call-template name="OutputCssSpecial"/>
                            <xsl:call-template name="DoImgDescription">
                                <xsl:with-param name="sDescription" select="$sDescription"/>
                            </xsl:call-template>
                        </embed>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="img">
                    <xsl:call-template name="OutputCssSpecial"/>
                    <xsl:attribute name="src">
                        <xsl:value-of select="@src"/>
                    </xsl:attribute>
                    <xsl:call-template name="DoImgDescription">
                        <xsl:with-param name="sDescription" select="$sDescription"/>
                    </xsl:call-template>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        chart
    -->
    <xsl:template match="chart">
        <xsl:choose>
            <xsl:when test="name(..)='example'">
                <table>
                    <tr>
                        <td>
                            <xsl:choose>
                                <xsl:when test="@type">
                                    <xsl:element name="div">
                                        <xsl:attribute name="style">
                                            <xsl:call-template name="DoType"/>
                                        </xsl:attribute>
                                        <xsl:choose>
                                            <xsl:when test="child::ol | child::ul | child::dl | child::img | child::object | child::br | child::hangingIndent">
                                                <xsl:apply-templates/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="." disable-output-escaping="yes"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates/>
                                    <!--                <xsl:value-of select="." disable-output-escaping="yes"/> -->
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::endnote and not(position()=1)">
                        <table>
                            <tr>
                                <tr>
                                    <td/>
                                    <td>
                                        <div>
                                            <xsl:choose>
                                                <xsl:when test="child::ol | child::ul | child::dl | child::img | child::object | child::br">
                                                    <xsl:apply-templates/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="." disable-output-escaping="yes"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </div>
                                    </td>
                                </tr>
                            </tr>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <div>
                            <xsl:call-template name="OutputCssSpecial">
                                <xsl:with-param name="fDoStyleAttribute" select="'Y'"/>
                            </xsl:call-template>
                            <xsl:attribute name="style">
                                <xsl:call-template name="DoType"/>
                            </xsl:attribute>
                            <xsl:apply-templates/>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        tree
    -->
    <xsl:template match="tree">
        <xsl:choose>
            <xsl:when test="img">
                <xsl:choose>
                    <xsl:when test="name(..)='example'">
                        <table>
                            <tr>
                                <td style="vertical-align:top">
                                    <xsl:apply-templates/>
                                </td>
                            </tr>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <p style="margin-left: 0.25in">
                            <xsl:apply-templates/>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:call-template name="OutputCssSpecial">
                        <xsl:with-param name="fDoStyleAttribute" select="'Y'"/>
                    </xsl:call-template>
                    <xsl:value-of select="." disable-output-escaping="yes"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        interlinear
    -->
    <xsl:template match="interlinear">
        <xsl:param name="originalContext"/>
        <xsl:choose>
            <xsl:when test="parent::interlinear-text">
                <xsl:variable name="sSpaceBetweenUnits">
                    <xsl:value-of select="normalize-space($documentLayoutInfo/interlinearTextLayout/@spaceBetweenUnits)"/>
                </xsl:variable>
                <xsl:if test="string-length($sSpaceBetweenUnits) &gt; 0 and count(preceding-sibling::interlinear) &gt; 0">
                    <div>
                        <xsl:attribute name="style">
                            <xsl:text>margin-top:</xsl:text>
                            <xsl:value-of select="$sSpaceBetweenUnits"/>
                        </xsl:attribute>
                    </div>
                </xsl:if>
                <div class="interlinearLineTitle">
                    <xsl:if test="string-length(@text) &gt; 0">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@text"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="GetInterlinearTextShortTitleAndNumber"/>
                </div>
                <div style="margin-left:0.125in">
                    <xsl:call-template name="OutputInterlinear">
                        <xsl:with-param name="mode" select="'NoTextRef'"/>
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                    </xsl:call-template>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputInterlinear">
                    <xsl:with-param name="originalContext" select="$originalContext"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        listInterlinear
    -->
    <xsl:template match="listInterlinear">
        <xsl:param name="bListsShareSameCode"/>
        <xsl:if test="preceding-sibling::listInterlinear">
            <tr>
                <td>&#xa0;</td>
            </tr>
        </xsl:if>
        <tr>
            <td>
                <xsl:element name="table" use-attribute-sets="TablePaddingSpacing">
                    <tr>
                        <td style="vertical-align:top">
                            <xsl:element name="a">
                                <xsl:attribute name="name">
                                    <xsl:value-of select="@letter"/>
                                </xsl:attribute>
                                <xsl:apply-templates select="." mode="letter"/>
                                <xsl:text>.</xsl:text>
                            </xsl:element>
                        </td>
                        <xsl:if test="$lingPaper/@showiso639-3codeininterlinear='yes'">
                            <xsl:if test="contains($bListsShareSameCode,'N')">
                                <td style="vertical-align:top">
                                    <xsl:call-template name="OutputISOCodeInExample">
                                        <xsl:with-param name="bOutputBreak" select="'N'"/>
                                    </xsl:call-template>
                                </td>
                            </xsl:if>
                        </xsl:if>
                        <td>
                            <xsl:apply-templates/>
                        </td>
                    </tr>
                </xsl:element>
            </td>
        </tr>
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
        conflatedLine
    -->
    <xsl:template match="conflatedLine">
        <tr style="line-height:87.5%">
            <td style="vertical-align:top">
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
                        <td style="vertical-align:top">
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
        <xsl:call-template name="DoInterlinearFree">
            <xsl:with-param name="mode" select="'NoTextRef'"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        word
    -->
    <xsl:template match="word">
        <xsl:element name="table" use-attribute-sets="TablePaddingSpacing">
            <tr>
                <xsl:for-each select="(langData | gloss)">
                    <td>
                        <xsl:apply-templates select="."/>
                    </td>
                </xsl:for-each>
            </tr>
            <xsl:apply-templates select="word"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="word[ancestor::listWord]">
        <xsl:param name="bListsShareSameCode"/>
        <tr>
            <td>
                <!-- letter column -->
            </td>
            <xsl:if test="contains($bListsShareSameCode,'N')">
                <td>
                    <!-- ISO code -->
                </td>
            </xsl:if>
            <xsl:call-template name="HandleListWordLangDataOrGloss"/>
        </tr>
        <xsl:apply-templates select="word">
            <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="word[parent::word and not(ancestor::listWord)]">
        <tr>
            <xsl:for-each select="(langData | gloss)">
                <td>
                    <xsl:apply-templates select="."/>
                </td>
            </xsl:for-each>
        </tr>
        <xsl:apply-templates select="word"/>
    </xsl:template>
    <!--
        listWord
    -->
    <xsl:template match="listWord">
        <xsl:param name="bListsShareSameCode"/>
        <!--    <table> -->
        <tr style="vertical-align:top">
            <td>
                <xsl:element name="a">
                    <xsl:attribute name="name">
                        <xsl:value-of select="@letter"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="." mode="letter"/>.</xsl:element>
            </td>
            <xsl:call-template name="OutputListLevelISOCode">
                <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
            </xsl:call-template>
            <xsl:for-each select="(langData | gloss)">
                <td>
                    <xsl:attribute name="style">
                        <xsl:value-of select="$sExampleCellPadding"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="."/>
                </td>
            </xsl:for-each>
        </tr>
        <xsl:apply-templates select="word">
            <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
        </xsl:apply-templates>
        <!--    </table> -->
    </xsl:template>
    <!--
        single
    -->
    <xsl:template match="single">
        <xsl:element name="table" use-attribute-sets="TablePaddingSpacing">
            <tr>
                <td>
                    <xsl:apply-templates/>
                </td>
            </tr>
        </xsl:element>
    </xsl:template>
    <!--
        listSingle
    -->
    <xsl:template match="listSingle">
        <xsl:param name="bListsShareSameCode"/>
        <!--        <table cellpadding="0pt" cellspacing="0pt"> -->
        <tr>
            <td style="vertical-align:top">
                <xsl:element name="a">
                    <xsl:attribute name="name">
                        <xsl:value-of select="@letter"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="." mode="letter"/>.</xsl:element>
            </td>
            <xsl:if test="$lingPaper/@showiso639-3codeininterlinear='yes'">
                <xsl:if test="contains($bListsShareSameCode,'N')">
                    <td>
                        <xsl:call-template name="OutputISOCodeInExample">
                            <xsl:with-param name="bOutputBreak" select="'N'"/>
                        </xsl:call-template>
                    </td>
                </xsl:if>
            </xsl:if>
            <td>
                <xsl:attribute name="style">
                    <xsl:value-of select="$sExampleCellPadding"/>
                </xsl:attribute>
                <xsl:for-each select="(langData | gloss | interlinearSource)">
                    <xsl:apply-templates select="."/>
                    <xsl:if test="position()!=last()">
                        <xsl:text>&#xa0;&#xa0;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
        <!--        </table> -->
    </xsl:template>
    <!-- ===========================================================
        INTERLINEAR TEXT
        =========================================================== -->
    <!--  
        interlinear-text
    -->
    <!--  
        interlinear-text
    -->
    <xsl:template match="interlinear-text">
        <div>
            <xsl:if test="string-length(@text) &gt; 0">
                <xsl:attribute name="id">
                    <xsl:value-of select="@text"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="preceding-sibling::p[1] or preceding-sibling::pc[1]">
                <xsl:attribute name="style">
                    <xsl:text>padding-top:12pt</xsl:text>
                    <xsl:if test="@cssSpecial">
                        <xsl:call-template name="OutputCssSpecial">
                            <xsl:with-param name="fDoStyleAttribute" select="'N'"/>
                        </xsl:call-template>
                        <xsl:apply-templates/>
                    </xsl:if>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
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
        <div class="textTitle">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <!--  
        source
    -->
    <xsl:template match="source">
        <div class="source">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <!-- following borrowed and modified from work by John Thomson -->
    <!--
        phrase
    -->
    <xsl:template match="phrase">
        <xsl:call-template name="DoPhrase"/>
    </xsl:template>
    <xsl:template match="phrase" mode="NoTextRef">
        <xsl:call-template name="DoPhrase"/>
    </xsl:template>
    <xsl:template name="DoPhrase">
        <xsl:choose>
            <xsl:when test="position() != 1">
                <br/>
                <!--                <span style="margin-left=.125in">  Should we indent here? -->
                <xsl:apply-templates/>
                <!--                </span>-->
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
                <span>
                    <xsl:attribute name="style">
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
                <br/>
            </xsl:when>
            <xsl:when test="@type='gls'">
                <br/>
                <xsl:choose>
                    <xsl:when test="count(../preceding-sibling::phrase) &gt; 0">
                        <!--                        <span style="margin-left=.125in"> Should we indent here? -->
                        <span>
                            <xsl:attribute name="style">
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                                </xsl:call-template>
                            </xsl:attribute>
                            <xsl:apply-templates/>
                        </span>
                        <!--                        </span>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <span>
                            <xsl:attribute name="style">
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                                </xsl:call-template>
                            </xsl:attribute>
                            <xsl:apply-templates/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@type='note'">
                <div>
                    <xsl:text>Note: </xsl:text>
                    <span>
                        <xsl:attribute name="style">
                            <xsl:call-template name="OutputFontAttributes">
                                <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </span>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        words
    -->
    <xsl:template match="words">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
        iword
    -->
    <xsl:template match="iword">
        <!--        <span class="interblock">-->
        <xsl:element name="table" use-attribute-sets="TablePaddingSpacing">
            <xsl:attribute name="class">interblock</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
        <!--        </span>-->
    </xsl:template>
    <!--
        iword/item[@type='punct']
    -->
    <xsl:template match="iword/item[@type='punct']">
        <tr>
            <td>
                <xsl:attribute name="style">
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:apply-templates/>
                <xsl:text>&#160;</xsl:text>
            </td>
        </tr>
    </xsl:template>
    <!--
        iword/item[@type='txt']
    -->
    <xsl:template match="iword/item[@type='txt']">
        <tr>
            <td>
                <xsl:attribute name="style">
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:apply-templates/>
                <xsl:text>&#160;</xsl:text>
            </td>
        </tr>
    </xsl:template>
    <!--
        iword/item[@type='gls']
    -->
    <xsl:template match="iword/item[@type='gls']">
        <tr>
            <td>
                <xsl:attribute name="style">
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:if test="string(.)">
                    <xsl:apply-templates/>
                    <xsl:text>&#160;</xsl:text>
                </xsl:if>
                <br/>
            </td>
        </tr>
    </xsl:template>
    <!--
        iword/item[@type='pos']
    -->
    <xsl:template match="iword/item[@type='pos']">
        <tr>
            <td>
                <xsl:if test="string(.)">
                    <xsl:apply-templates/>
                    <xsl:text>&#160;</xsl:text>
                </xsl:if>
                <br/>
            </td>
        </tr>
    </xsl:template>
    <!--
        morphemes
    -->
    <xsl:template match="morphemes">
        <tr>
            <td>
                <xsl:apply-templates/>
            </td>
        </tr>
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
        <!--        <span class="interblock">-->
        <xsl:element name="table" use-attribute-sets="TablePaddingSpacing">
            <xsl:attribute name="class">interblock</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
        <!--        </span>-->
    </xsl:template>
    <!--
        morph/item
    -->
    <xsl:template match="morph/item[@type!='hn' and @type!='cf']">
        <tr>
            <td>
                <xsl:attribute name="style">
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:apply-templates/>
                <xsl:text>&#160;</xsl:text>
            </td>
        </tr>
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
        <tr>
            <td>
                <xsl:apply-templates/>
                <xsl:variable name="homographNumber" select="following-sibling::item[@type='hn']"/>
                <xsl:if test="$homographNumber">
                    <sub>
                        <xsl:apply-templates select="$homographNumber" mode="hn"/>
                    </sub>
                </xsl:if>
                <xsl:text>&#160;</xsl:text>
            </td>
        </tr>
    </xsl:template>
    <!--  
        DefaultCellPaddingSpacing
    -->
    <xsl:template name="DefaultCellPaddingSpacing">
        <xsl:text>0</xsl:text>
        <xsl:choose>
            <xsl:when test="$bEBook='Y'">%</xsl:when>
            <xsl:otherwise>pt</xsl:otherwise>
        </xsl:choose>
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
        <xsl:if test="$sFootnoteNumber='1'">
            <tr>
                <td colspan="2" style="font-style:italic; font-size:larger; font-weight:bold">
                    <xsl:call-template name="DoBookEndnotesLabelingContent">
                        <xsl:with-param name="chapterOrAppendixUnit" select="$chapterOrAppendixUnit"/>
                    </xsl:call-template>
                    <xsl:text>&#x20;</xsl:text>
                    <xsl:for-each select="$chapterOrAppendixUnit">
                        <xsl:call-template name="OutputChapterNumber"/>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    <!--  
        DoDefinition
    -->
    <xsl:template name="DoDefinition">
        <td style="padding-left: .25em">
            <xsl:choose>
                <xsl:when test="@type">
                    <xsl:element name="span">
                        <xsl:attribute name="style">
                            <xsl:call-template name="DoType"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                        <!--                        <xsl:choose>
                            <xsl:when test="child::ol | child::ul | child::dl | child::img | child::object | child::br">
                            <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:otherwise>
                            <xsl:value-of select="." disable-output-escaping="yes"/>
                            </xsl:otherwise>
                            </xsl:choose>
                        -->
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                    <!--                <xsl:value-of select="." disable-output-escaping="yes"/> -->
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <!-- preceding borrowed and modified from work by John Thomson -->
    </xsl:template>
    <!--  
        DoExample
    -->
    <xsl:template name="DoExample">
        <xsl:param name="bUseClass" select="'N'"/>
        <xsl:choose>
            <xsl:when test="ancestor::table[@border &gt; 0]">
                <xsl:attribute name="style">
                    <xsl:text>margin-left: 0.175in; margin-right: 0.175in</xsl:text>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="ancestor::table">
                <xsl:attribute name="style">
                    <xsl:text>margin-left: 0.2in; margin-right: 0.175in</xsl:text>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$bUseClass='Y'">
                        <xsl:attribute name="class">
                            <xsl:text>example</xsl:text>
                        </xsl:attribute>
                        <xsl:if test="preceding-sibling::*[1][name()='example']">
                            <!-- add extra space between this example and the previous one -->
                            <xsl:attribute name="style">
                                <xsl:text>margin-top:.2in;</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="style">
                            <xsl:text>margin-left: 0.25in; margin-right: 0.25in</xsl:text>
                            <xsl:if test="preceding-sibling::*[1][name()='example']">
                                <!-- add extra space between this example and the previous one -->
                                <xsl:text>; margin-top:.2in</xsl:text>
                            </xsl:if>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="OutputCssSpecial">
            <xsl:with-param name="fDoStyleAttribute" select="'Y'"/>
        </xsl:call-template>
        <table>
            <tr>
                <xsl:variable name="bListsShareSameCode">
                    <xsl:call-template name="DetermineIfListsShareSameISOCode"/>
                </xsl:variable>
                <td style="vertical-align:top">
                    <xsl:element name="a">
                        <xsl:attribute name="name">
                            <xsl:value-of select="@num"/>
                        </xsl:attribute>
                        <xsl:call-template name="GetAndFormatExampleNumber"/>
                        <xsl:if test="not(listDefinition) and not(definition)">
                            <xsl:call-template name="OutputExampleLevelISOCode">
                                <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:element>
                </td>
                <td>
                    <xsl:variable name="myFirstChild" select="child::*[position()=1]"/>
                    <xsl:choose>
                        <xsl:when test="name($myFirstChild) = 'exampleHeading' and substring(name(child::*[position()=2]), 1, 4)='list'">
                            <xsl:apply-templates select="exampleHeading" mode="NoTextRef"/>
                            <xsl:element name="table" use-attribute-sets="TablePaddingSpacing">
                                <xsl:apply-templates select="listInterlinear | listWord | listSingle">
                                    <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
                                </xsl:apply-templates>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="name($myFirstChild) = 'exampleHeading' and name(child::*[position()=2])='table'">
                            <xsl:apply-templates select="exampleHeading"/>
                            <xsl:apply-templates select="table"/>
                        </xsl:when>
                        <xsl:when test="substring(name($myFirstChild), 1, 4)='list'">
                            <xsl:element name="table" use-attribute-sets="TablePaddingSpacing">
                                <xsl:apply-templates>
                                    <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
                                </xsl:apply-templates>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </table>
    </xsl:template>
    <!--  
        DoInterlinearLine
    -->
    <xsl:template name="DoInterlinearLine">
        <xsl:param name="originalContext"/>
        <xsl:param name="bUseClass" select="'N'"/>
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
                    <xsl:element name="td">
                        <xsl:if test="$bRtl='Y'">
                            <xsl:attribute name="align">right</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="$bUseClass='Y'">
                            <xsl:attribute name="class">
                                <xsl:text>language</xsl:text>
                                <xsl:value-of select="@lang"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:attribute name="style">
                            <xsl:if test="$bUseClass='N'">
                                <xsl:call-template name="OutputFontAttributes">
                                    <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:value-of select="$sExampleCellPadding"/>
                        </xsl:attribute>
                        <!-- Internet Explorer has a bug whereby small-caps is not always rendered on the same horizontal line as surrounding cells.
                            If we have space at the beginning and at the end of the <td>, it renders correctly.-->
                        <xsl:text>&#x20;</xsl:text>
                        <xsl:apply-templates>
                            <xsl:with-param name="originalContext" select="$originalContext"/>
                        </xsl:apply-templates>
                        <xsl:text>&#x20;</xsl:text>
                    </xsl:element>
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
                    <xsl:attribute name="align">right</xsl:attribute>
                </xsl:if>
                <xsl:variable name="language">
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
                        <xsl:otherwise>
                            <xsl:value-of select="$sContents"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="OutputTableCells">
                    <xsl:with-param name="sList" select="$sOrientedContents"/>
                    <xsl:with-param name="lang" select="$language"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$mode!='NoTextRef'">
            <xsl:if test="count(preceding-sibling::line) = 0">
                <xsl:if test="$sInterlinearSourceStyle='AfterFirstLine'">
                    <xsl:if test="string-length(normalize-space(../../@textref)) &gt; 0 or ../../interlinearSource">
                        <td xsl:use-attribute-sets="ExampleCell">
                            <xsl:call-template name="OutputInterlinearTextReference">
                                <xsl:with-param name="sRef" select="../../@textref"/>
                                <xsl:with-param name="sSource" select="../../interlinearSource"/>
                            </xsl:call-template>
                        </td>
                    </xsl:if>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        DoImgDescription
    -->
    <xsl:template name="DoImgDescription">
        <xsl:param name="sDescription"/>
        <xsl:attribute name="alt">
            <xsl:choose>
                <xsl:when test="string-length($sDescription) &gt; 0">
                    <xsl:value-of select="$sDescription"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Missing image file: </xsl:text>
                    <xsl:value-of select="@src"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <!--  
        DoInterlinearLineGroup
    -->
    <xsl:template name="DoInterlinearLineGroup">
        <xsl:param name="originalContext"/>
        <xsl:param name="mode"/>
        <xsl:element name="table" use-attribute-sets="TablePaddingSpacing">
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
                <xsl:attribute name="style">
                    <xsl:text>margin-left: </xsl:text>
                    <xsl:choose>
                        <xsl:when test="string-length($sIndentOfNonInitialGroup) &gt; 0">
                            <xsl:value-of select="$sIndentOfNonInitialGroup"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>0.1in</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>;border-collapse:collapse</xsl:text>
                </xsl:attribute>
                <xsl:if test="count(../../lineGroup[last()]/line) &gt; 1 or count(line) &gt; 1">
                    <tr>
                        <td>
                            <!-- Following does not work 
                                <xsl:if test="string-length($sSpaceBetweenGroups) &gt; 0">
                                <xsl:attribute name="style">
                                <xsl:text>padding-top:</xsl:text>
                                <xsl:value-of select="$sSpaceBetweenGroups"/>
                                </xsl:attribute>
                                </xsl:if>-->
                            <xsl:text>&#xa0;</xsl:text>
                        </td>
                    </tr>
                </xsl:if>
            </xsl:if>
            <xsl:call-template name="ApplyTemplatesPerTextRefMode">
                <xsl:with-param name="mode" select="$mode"/>
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
    <!--
        OutputAbbreviationInTable
    -->
    <xsl:template name="OutputAbbreviationInTable">
        <xsl:param name="abbrsShownHere"/>
        <xsl:param name="abbrInSecondColumn"/>
        <tr>
            <xsl:call-template name="OutputAbbreviationItemInTable">
                <xsl:with-param name="abbrsShownHere" select="$abbrsShownHere"/>
            </xsl:call-template>
            <xsl:if test="$contentLayoutInfo/abbreviationsInTableLayout/@useDoubleColumns='yes'">
                <xsl:for-each select="$abbrInSecondColumn">
                    <td>
                        <xsl:variable name="sSep" select="normalize-space($contentLayoutInfo/abbreviationsInTableLayout/@doubleColumnSeparation)"/>
                        <xsl:if test="string-length($sSep)&gt;0">
                            <xsl:attribute name="style">
                                <xsl:text>padding-left:</xsl:text>
                                <xsl:value-of select="$sSep"/>
                            </xsl:attribute>
                        </xsl:if>
                    </td>
                    <xsl:call-template name="OutputAbbreviationItemInTable">
                        <xsl:with-param name="abbrsShownHere" select="$abbrsShownHere"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
        </tr>
    </xsl:template>
    <!--
        OutputAbbreviationItemInTable
    -->
    <xsl:template name="OutputAbbreviationItemInTable">
        <xsl:param name="abbrsShownHere"/>
        <td valign="top">
            <xsl:call-template name="HandleColumnWidth">
                <xsl:with-param name="sWidth" select="normalize-space($abbrsShownHere/@abbrWidth)"/>
            </xsl:call-template>
            <a id="{@id}">
                <xsl:call-template name="OutputAbbrTerm">
                    <xsl:with-param name="abbr" select="."/>
                </xsl:call-template>
            </a>
        </td>
        <xsl:if test="not($contentLayoutInfo/abbreviationsInTableLayout/@useEqualSignsColumn) or $contentLayoutInfo/abbreviationsInTableLayout/@useEqualSignsColumn!='no'">
            <td valign="top">
                <xsl:call-template name="HandleColumnWidth">
                    <xsl:with-param name="sWidth" select="normalize-space($abbrsShownHere/@equalsWidth)"/>
                </xsl:call-template>
                <xsl:text> = </xsl:text>
            </td>
        </xsl:if>
        <td valign="top">
            <xsl:call-template name="HandleColumnWidth">
                <xsl:with-param name="sWidth" select="normalize-space($abbrsShownHere/@definitionWidth)"/>
            </xsl:call-template>
            <xsl:call-template name="OutputAbbrDefinition">
                <xsl:with-param name="abbr" select="."/>
            </xsl:call-template>
        </td>
    </xsl:template>
    <!--
        OutputAbbreviationsInTable
    -->
    <xsl:template name="OutputAbbreviationsInTable">
        <xsl:param name="abbrsUsed"
            select="//abbreviation[not(ancestor::chapterInCollection/backMatter/abbreviations)][//abbrRef[not(ancestor::chapterInCollection/backMatter/abbreviations)]/@abbr=@id]"/>
        <xsl:if test="count($abbrsUsed) &gt; 0">
            <table>
                <xsl:attribute name="style">
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="$contentLayoutInfo/abbreviationsInTableLayout"/>
                    </xsl:call-template>
                    <xsl:variable name="sStartIndent" select="normalize-space($contentLayoutInfo/abbreviationsInTableLayout/@start-indent)"/>
                    <xsl:if test="string-length($sStartIndent)&gt;0">
                        <xsl:text>margin-left:</xsl:text>
                        <xsl:value-of select="$sStartIndent"/>
                        <xsl:text>;</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                <xsl:call-template name="SortAbbreviationsInTable">
                    <xsl:with-param name="abbrsUsed" select="$abbrsUsed"/>
                </xsl:call-template>
            </table>
        </xsl:if>
    </xsl:template>
    <!--
        HandleColumnWidth
    -->
    <xsl:template name="HandleColumnWidth">
        <xsl:param name="sWidth"/>
        <xsl:if test="string-length($sWidth) &gt; 0">
            <xsl:attribute name="style">
                <xsl:text>width:</xsl:text>
                <xsl:value-of select="$sWidth"/>
            </xsl:attribute>
        </xsl:if>
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
        <tr>
            <td style="vertical-align:baseline">
                <a>
                    <xsl:attribute name="name">
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                    <xsl:text>[</xsl:text>
                    <xsl:call-template name="GetFootnoteNumber">
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                        <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
                    </xsl:call-template>
                    <xsl:text>]</xsl:text>
                </a>
            </td>
            <td style="vertical-align:baseline">
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>
    <!--  
        HandleListWordLangDataOrGloss
    -->
    <xsl:template name="HandleListWordLangDataOrGloss">
        <xsl:param name="bListsShareSameCode"/>
        <xsl:call-template name="OutputListLevelISOCode">
            <xsl:with-param name="bListsShareSameCode" select="$bListsShareSameCode"/>
        </xsl:call-template>
        <xsl:for-each select="(langData | gloss)">
            <td>
                <xsl:attribute name="style">
                    <xsl:value-of select="$sExampleCellPadding"/>
                </xsl:attribute>
                <xsl:apply-templates select="."/>
            </td>
        </xsl:for-each>
    </xsl:template>
    <!--
        HandleLiteralLabelLayoutInfo
    -->
    <xsl:template name="HandleLiteralLabelLayoutInfo">
        <xsl:param name="layoutInfo"/>
        <span>
            <xsl:attribute name="style">
                <xsl:call-template name="OutputFontAttributes">
                    <xsl:with-param name="language" select="$layoutInfo"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:value-of select="$layoutInfo/../literalLabelLayout"/>
        </span>
    </xsl:template>
    <!--  
        OutputBackgroundColor
    -->
    <xsl:template name="OutputBackgroundColor">
        <xsl:if test="string-length(@backgroundcolor) &gt; 0">
            <xsl:text>; background-color:</xsl:text>
            <xsl:value-of select="@backgroundcolor"/>
            <xsl:text>; </xsl:text>
        </xsl:if>
    </xsl:template>
    <!--
        OutputCssSpecial
    -->
    <xsl:template name="OutputCssSpecial">
        <xsl:param name="fDoStyleAttribute" select="'Y'"/>
        <xsl:choose>
            <xsl:when test="string-length(normalize-space(@cssSpecial)) &gt; 0">
                <xsl:choose>
                    <xsl:when test="$fDoStyleAttribute='Y'">
                        <xsl:attribute name="style">
                            <xsl:value-of select="@cssSpecial"/>
                            <xsl:call-template name="OutputBackgroundColor"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>; </xsl:text>
                        <xsl:value-of select="@cssSpecial"/>
                        <xsl:call-template name="OutputBackgroundColor"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputBackgroundColor"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputDirection
    -->
    <xsl:template name="OutputDirection">
        <xsl:if test="@direction">
            <xsl:text>;direction:</xsl:text>
            <xsl:value-of select="@direction"/>
        </xsl:if>
    </xsl:template>
    <!--
        OutputEndnoteNumber
    -->
    <xsl:template name="OutputEndnoteNumber">
        <xsl:param name="attr" select="@id"/>
        <xsl:param name="node" select="."/>
        <xsl:param name="sFootnoteNumberOverride"/>
        <xsl:param name="originalContext"/>
        <span style="font-size:65%; vertical-align:super; color:black">
            <xsl:call-template name="InsertCommaBetweenConsecutiveEndnotes"/>
            <xsl:text>[</xsl:text>
            <a>
                <xsl:attribute name="href">
                    <xsl:text>#</xsl:text>
                    <xsl:value-of select="$attr"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length($sFootnoteNumberOverride) &gt; 0">
                        <xsl:value-of select="$sFootnoteNumberOverride"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="iTablenumberedAdjust">
                            <xsl:choose>
                                <xsl:when test="ancestor::tablenumbered ">
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
                        <xsl:call-template name="GetFootnoteNumber">
                            <xsl:with-param name="originalContext" select="$originalContext"/>
                            <xsl:with-param name="iTablenumberedAdjust" select="$iTablenumberedAdjust"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
            <xsl:text>]</xsl:text>
        </span>
    </xsl:template>
    <!--  
        OutputFontAttributes
    -->
    <xsl:template name="OutputFontAttributes">
        <xsl:param name="language"/>
        <xsl:param name="bIsOverride" select="'N'"/>
        <xsl:choose>
            <xsl:when test="$bIsOverride='Y'">
                <xsl:attribute name="class">
                    <xsl:value-of select="name($language)"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="string-length(normalize-space($language/@font-family)) &gt; 0">
                    <xsl:text>font-family:</xsl:text>
                    <xsl:value-of select="$language/@font-family"/>
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:if test="string-length(normalize-space($language/@font-size)) &gt; 0">
                    <xsl:text>font-size:</xsl:text>
                    <xsl:value-of select="$language/@font-size"/>
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:if test="string-length(normalize-space($language/@font-style)) &gt; 0">
                    <xsl:text>font-style:</xsl:text>
                    <xsl:value-of select="$language/@font-style"/>
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:if test="string-length(normalize-space($language/@font-variant)) &gt; 0">
                    <xsl:text>font-variant:</xsl:text>
                    <xsl:value-of select="$language/@font-variant"/>
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:if test="string-length(normalize-space($language/@font-weight)) &gt; 0">
                    <xsl:text>font-weight:</xsl:text>
                    <xsl:value-of select="$language/@font-weight"/>
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:if test="string-length(normalize-space($language/@color)) &gt; 0">
                    <xsl:text>color:</xsl:text>
                    <xsl:value-of select="$language/@color"/>
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:if test="string-length(normalize-space($language/@backgroundcolor)) &gt; 0">
                    <xsl:text>; background-color:</xsl:text>
                    <xsl:value-of select="$language/@backgroundcolor"/>
                    <xsl:text>; </xsl:text>
                </xsl:if>
                <xsl:variable name="sCssSpecial" select="normalize-space(@cssSpecial)"/>
                <xsl:if test="string-length($sCssSpecial) &gt; 0">
                    <xsl:value-of select="$sCssSpecial"/>
                    <xsl:if test="substring($sCssSpecial,string-length($sCssSpecial)) != ';'">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
        OutputGlossaryTermInTable
    -->
    <xsl:template name="OutputGlossaryTermInTable">
        <xsl:param name="glossaryTermsShownHere"/>
        <xsl:param name="glossaryTermInSecondColumn"/>
        <tr>
            <xsl:call-template name="OutputGlossaryTermItemInTable">
                <xsl:with-param name="glossaryTermsShownHere" select="$glossaryTermsShownHere"/>
            </xsl:call-template>
            <xsl:if test="$contentLayoutInfo/glossaryTermsInTableLayout/@useDoubleColumns='yes'">
                <xsl:for-each select="$glossaryTermInSecondColumn">
                    <td>
                        <xsl:variable name="sSep" select="normalize-space($contentLayoutInfo/glossaryTermsInTableLayout/@doubleColumnSeparation)"/>
                        <xsl:if test="string-length($sSep)&gt;0">
                            <xsl:attribute name="style">
                                <xsl:text>padding-left:</xsl:text>
                                <xsl:value-of select="$sSep"/>
                            </xsl:attribute>
                        </xsl:if>
                    </td>
                    <xsl:call-template name="OutputGlossaryTermItemInTable">
                        <xsl:with-param name="glossaryTermsShownHere" select="$glossaryTermsShownHere"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
        </tr>
    </xsl:template>
    <!--
        OutputGlossaryTermItemInTable
    -->
    <xsl:template name="OutputGlossaryTermItemInTable">
        <xsl:param name="glossaryTermsShownHere"/>
        <td valign="top">
            <xsl:call-template name="HandleColumnWidth">
                <xsl:with-param name="sWidth" select="normalize-space($glossaryTermsShownHere/@glossaryTermWidth)"/>
            </xsl:call-template>
            <a id="{@id}">
                <xsl:call-template name="OutputGlossaryTerm">
                    <xsl:with-param name="glossaryTerm" select="."/>
                    <xsl:with-param name="bIsRef" select="'N'"/>
                </xsl:call-template>
            </a>
        </td>
        <xsl:if test="not($contentLayoutInfo/glossaryTermsInTableLayout/@useEqualSignsColumn) or $contentLayoutInfo/glossaryTermsInTableLayout/@useEqualSignsColumn!='no'">
            <td valign="top">
                <xsl:call-template name="HandleColumnWidth">
                    <xsl:with-param name="sWidth" select="normalize-space($glossaryTermsShownHere/@equalsWidth)"/>
                </xsl:call-template>
                <xsl:text> = </xsl:text>
            </td>
        </xsl:if>
        <td valign="top">
            <xsl:call-template name="HandleColumnWidth">
                <xsl:with-param name="sWidth" select="normalize-space($glossaryTermsShownHere/@definitionWidth)"/>
            </xsl:call-template>
            <xsl:call-template name="OutputGlossaryTermDefinition">
                <xsl:with-param name="glossaryTerm" select="."/>
            </xsl:call-template>
        </td>
    </xsl:template>
    <!--
        OutputGlossaryTermsInTable
    -->
    <xsl:template name="OutputGlossaryTermsInTable">
        <xsl:param name="glossaryTermsUsed"
            select="//glossaryTerm[not(ancestor::chapterInCollection/backMatter/glossaryTerms)][//glossaryTermRef[not(ancestor::chapterInCollection/backMatter/glossaryTerms)]/@glossaryTerm=@id]"/>
        <xsl:if test="count($glossaryTermsUsed) &gt; 0">
            <table>
                <xsl:attribute name="style">
                    <xsl:call-template name="OutputFontAttributes">
                        <xsl:with-param name="language" select="$contentLayoutInfo/glossaryTermsInTableLayout"/>
                    </xsl:call-template>
                    <xsl:variable name="sStartIndent" select="normalize-space($contentLayoutInfo/glossaryTermsInTableLayout/@start-indent)"/>
                    <xsl:if test="string-length($sStartIndent)&gt;0">
                        <xsl:text>margin-left:</xsl:text>
                        <xsl:value-of select="$sStartIndent"/>
                        <xsl:text>;</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                <xsl:call-template name="SortGlossaryTermsInTable">
                    <xsl:with-param name="glossaryTermsUsed" select="$glossaryTermsUsed"/>
                </xsl:call-template>
            </table>
        </xsl:if>
    </xsl:template>


    <!--  
        OutputInterlinear
    -->
    <xsl:template name="OutputInterlinear">
        <xsl:param name="mode"/>
        <xsl:param name="originalContext"/>
        <xsl:choose>
            <xsl:when test="lineSet">
                <xsl:for-each select="lineSet | conflation">
                    <xsl:call-template name="ApplyTemplatesPerTextRefMode">
                        <xsl:with-param name="mode" select="$mode"/>
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="ApplyTemplatesPerTextRefMode">
                    <xsl:with-param name="mode" select="$mode"/>
                    <xsl:with-param name="originalContext" select="$originalContext"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
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
                    <br/>
                </xsl:if>
                <span style="font-size:smaller">
                    <xsl:text>[</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$bShowISO639-3Codes='Y'">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:text>#</xsl:text>
                                    <xsl:value-of select="$firstLangData/@lang"/>
                                </xsl:attribute>
                                <xsl:call-template name="AddAnyLinkAttributes">
                                    <xsl:with-param name="override" select="$pageLayoutInfo/linkLayout/iso639-3CodesLinkLayout"/>
                                </xsl:call-template>
                                <xsl:value-of select="$sIsoCode"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$sIsoCode"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>]</xsl:text>
                </span>
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
                <td>
                    <xsl:call-template name="OutputISOCodeInExample">
                        <xsl:with-param name="bOutputBreak" select="'N'"/>
                    </xsl:call-template>
                </td>
            </xsl:if>
        </xsl:if>
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
            </xsl:call-template>
            <xsl:if test="$sRest">
                <xsl:call-template name="DoNestedTypes">
                    <xsl:with-param name="sList" select="$sRest"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--  
        DoType
    -->
    <xsl:template name="DoType">
        <xsl:param name="type" select="@type"/>
        <xsl:for-each select="key('TypeID',$type)">
            <xsl:call-template name="OutputFontAttributes">
                <xsl:with-param name="language" select="."/>
            </xsl:call-template>
            <xsl:call-template name="DoNestedTypes">
                <xsl:with-param name="sList" select="@types"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--  
        OutputTable
    -->
    <xsl:template name="OutputTable">
        <xsl:element name="table">
            <xsl:attribute name="style">
                <xsl:call-template name="DoType"/>
                <xsl:call-template name="OutputCssSpecial">
                    <xsl:with-param name="fDoStyleAttribute">N</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="OutputBackgroundColor"/>
            </xsl:attribute>
            <!--  this is deprecated now and does not do what we want,, anyway
    <xsl:if test="@align">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
-->
            <xsl:if test="@border">
                <xsl:attribute name="border">
                    <xsl:value-of select="@border"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@cellpadding">
                <xsl:attribute name="cellpadding">
                    <xsl:value-of select="@cellpadding"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@cellspacing">
                <xsl:attribute name="cellspacing">
                    <xsl:value-of select="@cellspacing"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="caption and not(ancestor::tablenumbered)">
                <xsl:apply-templates select="caption" mode="show"/>
            </xsl:if>
            <!--  Note: we may want something like the following to enable running table headers...
            <xsl:if test="tr/th[count(following-sibling::td)=0] | headerRow">
                <thead>
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
                                <tr>
                                    <xsl:apply-templates select="th[count(following-sibling::td)=0] | headerRow"/>
                                </tr>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="tr/th[count(following-sibling::td)=0] | headerRow"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </thead>
            </xsl:if>
            <tbody start-indent="0pt" end-indent="0pt">
                <xsl:variable name="rows" select="tr[not(th) or th[count(following-sibling::td)!=0]]"/>
                <xsl:choose>
                    <xsl:when test="$rows">
                        <xsl:apply-templates select="$rows"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td border-collapse="collapse">
                                <xsl:choose>
                                    <xsl:when test="ancestor::table[1]/@border!='0' or count(ancestor::table)=1">
                                        <xsl:attribute name="padding">.2em</xsl:attribute>
                                    </xsl:when>
                                    <xsl:when test="position() &gt; 1">
                                        <xsl:attribute name="padding-left">.2em</xsl:attribute>
                                    </xsl:when>
                                </xsl:choose>
                                <div>
                                    <xsl:text>(This table does not have any contents!)</xsl:text>
                                </div>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
            -->
            <xsl:apply-templates/>
            <xsl:if test="endCaption and not(ancestor::tablenumbered)">
                <xsl:apply-templates select="endCaption" mode="show"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
