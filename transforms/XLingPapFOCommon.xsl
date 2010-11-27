<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format">
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
                    </xsl:call-template>
                </fo:table-body>
            </fo:table>
        </fo:block>
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
</xsl:stylesheet>
