<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!--
        abstract  (contents)
    -->
    <xsl:template match="abstract" mode="contents">
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="$sAbstractID"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputAbstractLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">
                        <xsl:call-template name="GetFirstLevelContentsIdent"/>
                    </xsl:when>
                    <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        acknowledgements (contents)
    -->
    <xsl:template match="acknowledgements" mode="contents">
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="$sAcknowledgementsID"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputAcknowledgementsLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">
                        <xsl:call-template name="GetFirstLevelContentsIdent"/>
                    </xsl:when>
                    <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        appendix (contents)
    -->
    <xsl:template match="appendix[not(ancestor::chapterInCollection)]" mode="contents">
        <xsl:variable name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <xsl:if test="$frontMatterLayout/contentsLayout/@showappendices!='no'">
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
                    <xsl:call-template name="DoSpaceBeforeContentsLine"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="section1 | section2" mode="contents"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="appendix[ancestor::chapterInCollection]" mode="contents">
        <xsl:variable name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <xsl:if test="$frontMatterLayout/contentsLayout/@showappendices!='no'">
            <xsl:call-template name="OutputAppendixInChapterInCollectionTOC">
                <xsl:with-param name="frontMatterLayout" select="$frontMatterLayout"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!-- 
        chapter (contents) 
    -->
    <xsl:template match="chapter | chapterBeforePart" mode="contents">
        <!--            <xsl:param name="nLevel"/>-->
        <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@usechapterlabelbeforechapters='yes'">
            <xsl:if test="name()='chapterBeforePart' or count(preceding-sibling::chapter)=0 and not(//chapterBeforePart)">
                <xsl:call-template name="DoChapterLabelInContents"/>
            </xsl:if>
        </xsl:if>
        <xsl:if test="string-length($sChapterLineIndent)&gt;0">
            <xsl:call-template name="SetChapterNumberWidth"/>
        </xsl:if>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputChapterNumber">
                    <xsl:with-param name="fDoingContents" select="'Y'"/>
                </xsl:call-template>
                <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@useperiodafterchapternumber='yes'">
                    <xsl:text>.</xsl:text>
                </xsl:if>
                <xsl:text>&#xa0;</xsl:text>
                <xsl:if test="string-length($sChapterLineIndent)&gt;0">
                    <xsl:call-template name="AddWordSpace"/>
                </xsl:if>
                <xsl:apply-templates select="secTitle" mode="contents"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="string-length($sChapterLineIndent)&gt;0">
                        <xsl:value-of select="$sChapterLineIndent"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>0pt</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="sNumWidth">
                <xsl:call-template name="DoChapterNumberWidth"/>
            </xsl:with-param>
            <xsl:with-param name="fUseHalfSpacing">
                <xsl:choose>
                    <xsl:when test="position()=1">
                        <xsl:text>Y</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>N</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="shortTitle" mode="contents"/>
        <xsl:if test="$nLevel!=0">
            <xsl:apply-templates select="section1 | section2" mode="contents">
                <!--            <xsl:with-param name="nLevel" select="$nLevel"/>-->
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    <xsl:template match="chapterInCollection" mode="contents">
        <!--            <xsl:param name="nLevel"/>-->
        <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@usechapterlabelbeforechapters='yes'">
            <xsl:if test="name()='chapterBeforePart' or count(preceding-sibling::chapterInCollection)=0 and not(//chapterBeforePart)">
                <xsl:call-template name="DoChapterLabelInContents"/>
            </xsl:if>
        </xsl:if>
        <xsl:if test="string-length($sChapterLineIndent)&gt;0">
            <xsl:call-template name="SetChapterNumberWidth"/>
        </xsl:if>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputChapterNumber"/>
                <xsl:if test="$frontMatterLayoutInfo/contentsLayout/@useperiodafterchapternumber='yes'">
                    <xsl:text>.</xsl:text>
                </xsl:if>
                <xsl:text>&#xa0;</xsl:text>
                <xsl:if test="string-length($sChapterLineIndent)&gt;0">
                    <xsl:call-template name="AddWordSpace"/>
                </xsl:if>
                <xsl:apply-templates select="frontMatter/title" mode="contents"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="string-length($sChapterLineIndent)&gt;0">
                        <xsl:value-of select="$sChapterLineIndent"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>0pt</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="sNumWidth">
                <xsl:call-template name="DoChapterNumberWidth"/>
            </xsl:with-param>
            <xsl:with-param name="fUseHalfSpacing">
                <xsl:choose>
                    <xsl:when test="position()=1">
                        <xsl:text>Y</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>N</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="DoAuthorOfChapterInCollectionInContents"/>
        <xsl:if test="$nLevel!=0">
            <xsl:call-template name="DoFrontMatterContentsPerLayout">
                <xsl:with-param name="frontMatter" select="frontMatter"/>
            </xsl:call-template>
            <xsl:apply-templates select="section1" mode="contents">
                <!--            <xsl:with-param name="nLevel" select="$nLevel"/>-->
            </xsl:apply-templates>
            <xsl:call-template name="DoBackMatterContentsPerLayout">
                <xsl:with-param name="nLevel" select="$nLevel"/>
                <xsl:with-param name="backMatter" select="backMatter"/>
                <xsl:with-param name="backMatterLayout" select="$bodyLayoutInfo/chapterInCollectionBackMatterLayout"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--
      endnotes (contents)
   -->
    <xsl:template match="endnotes" mode="contents">
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="$sEndnotesID"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputEndnotesLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">
                        <xsl:call-template name="GetFirstLevelContentsIdent"/>
                    </xsl:when>
                    <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        glossary (contents)
    -->
    <xsl:template match="glossary" mode="contents">
        <xsl:param name="iLayoutPosition" select="0"/>
        <xsl:variable name="iPos" select="count(preceding-sibling::glossary) + 1"/>
        <xsl:variable name="fLayoutIsLastOfMany">
            <xsl:choose>
                <xsl:when test="$iLayoutPosition=0">
                    <xsl:text>N</xsl:text>
                </xsl:when>
                <xsl:when test="count($backMatterLayoutInfo/glossaryLayout[number($iLayoutPosition)]/following-sibling::glossaryLayout)=0">
                    <xsl:text>Y</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>N</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$iLayoutPosition = 0">
                <!-- there's one and only one glossaryLayout; use it -->
                <xsl:call-template name="OutputGlossaryTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$iLayoutPosition = $iPos">
                <!-- there are many glossaryLayouts; use the one that matches in position -->
                <xsl:call-template name="OutputGlossaryTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
                <!-- there are many glossaryLayouts and there are more glossary elements than glossaryLayout elements; use the last layout -->
                <xsl:call-template name="OutputGlossaryTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        index  (contents)
    -->
    <xsl:template match="index" mode="contents">
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
                <xsl:call-template name="CreateIndexID"/>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputIndexLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!--
        preface (contents)
    -->
    <xsl:template match="preface" mode="contents">
        <xsl:param name="iLayoutPosition" select="0"/>
        <xsl:variable name="iPos" select="count(preceding-sibling::preface) + 1"/>
        <xsl:variable name="fLayoutIsLastOfMany">
            <xsl:choose>
                <xsl:when test="$iLayoutPosition=0">
                    <xsl:text>N</xsl:text>
                </xsl:when>
                <xsl:when test="count($frontMatterLayoutInfo/prefaceLayout[number($iLayoutPosition)]/following-sibling::prefaceLayout)=0">
                    <xsl:text>Y</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>N</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$iLayoutPosition = 0">
                <!-- there's one and only one prefaceLayout; use it -->
                <xsl:call-template name="OutputPrefaceTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$iLayoutPosition = $iPos">
                <!-- there are many prefaceLayouts; use the one that matches in position -->
                <xsl:call-template name="OutputPrefaceTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
                <!-- there are many prefaceLayouts and there are more preface elements than prefaceLayout elements; use the last layout -->
                <xsl:call-template name="OutputPrefaceTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        references (contents)
    -->
    <xsl:template match="references" mode="contents">
        <xsl:variable name="authors" select="//refAuthor[refWork/@id=//citation[not(ancestor::comment)]/@ref]"/>
        <xsl:if test="$authors">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink">
                    <xsl:call-template name="GetIdToUse">
                        <xsl:with-param name="sBaseId" select="$sReferencesID"/>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="sLabel">
                    <xsl:call-template name="OutputReferencesLabel"/>
                </xsl:with-param>
                <xsl:with-param name="sSpaceBefore">
                    <xsl:call-template name="DoSpaceBeforeContentsLine"/>
                </xsl:with-param>
                <xsl:with-param name="sIndent">
                    <xsl:choose>
                        <xsl:when test="ancestor::chapterInCollection">
                            <xsl:call-template name="GetFirstLevelContentsIdent"/>
                        </xsl:when>
                        <xsl:otherwise>0pt</xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!-- 
        section2 (contents) 
    -->
    <xsl:template match="section2" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="count(ancestor::section1) + count(ancestor::chapter | ancestor::chapterInCollection) + count(ancestor::chapterBeforePart) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=3 and $bodyLayoutInfo/section3Layout/@ignore!='yes'">
            <xsl:apply-templates select="section3" mode="contents"/>
        </xsl:if>
    </xsl:template>
    <!-- 
        section3 (contents) 
    -->
    <xsl:template match="section3" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="1 + count(ancestor::section1) + count(ancestor::chapter | ancestor::chapterInCollection) + count(ancestor::chapterBeforePart) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=4 and $bodyLayoutInfo/section4Layout/@ignore!='yes'">
            <xsl:apply-templates select="section4" mode="contents"/>
        </xsl:if>
    </xsl:template>
    <!-- 
        section4 (contents) 
    -->
    <xsl:template match="section4" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="2 + count(ancestor::section1) + count(ancestor::chapter | ancestor::chapterInCollection) + count(ancestor::chapterBeforePart) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=5 and $bodyLayoutInfo/section5Layout/@ignore!='yes'">
            <xsl:apply-templates select="section5" mode="contents"/>
        </xsl:if>
    </xsl:template>
    <!-- 
        section5 (contents) 
    -->
    <xsl:template match="section5" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="3 + count(ancestor::section1) + count(ancestor::chapter | ancestor::chapterInCollection) + count(ancestor::chapterBeforePart) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=6 and $bodyLayoutInfo/section6Layout/@ignore!='yes'">
            <xsl:apply-templates select="section6" mode="contents"/>
        </xsl:if>
    </xsl:template>
    <!-- 
        section6 (contents) 
    -->
    <xsl:template match="section6" mode="contents">
        <xsl:variable name="iLevel">
            <xsl:value-of select="4 + count(ancestor::section1) + count(ancestor::chapter | ancestor::chapterInCollection) + count(ancestor::chapterBeforePart) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        shortTitle (contents) 
    -->
    <xsl:template match="shortTitle" mode="contents"/>
    <!-- 
      DoSpaceBeforeContentsLine
   -->
    <xsl:template name="DoSpaceBeforeContentsLine">
        <xsl:choose>
            <xsl:when test="$frontMatterLayoutInfo/contentsLayout/@spacebeforemainsection">
                <xsl:value-of select="$frontMatterLayoutInfo/contentsLayout/@spacebeforemainsection"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>0</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        OutputGlossaryTOCLine
    -->
    <xsl:template name="OutputGlossaryTOCLine">
        <xsl:param name="iPos"/>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="concat($sGlossaryID,$iPos)"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputGlossaryLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">
                        <xsl:call-template name="GetFirstLevelContentsIdent"/>
                    </xsl:when>
                    <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        OutputPrefaceTOCLine
    -->
    <xsl:template name="OutputPrefaceTOCLine">
        <xsl:param name="iPos"/>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
                <xsl:variable name="sPos" select="$iPos"/>
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="concat($sPrefaceID,$sPos)"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputPrefaceLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine"/>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">
                        <xsl:call-template name="GetFirstLevelContentsIdent"/>
                    </xsl:when>
                    <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
