<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://icl.com/saxon">
    <!--
        abstract  (contents)
    -->
    <xsl:template match="abstract" mode="contents">
        <xsl:param name="iLayoutPosition" select="0"/>
        <xsl:param name="text-transform"/>
        <xsl:variable name="iPos" select="count(preceding-sibling::abstract) + 1"/>
        <xsl:variable name="fLayoutIsLastOfMany">
            <xsl:choose>
                <xsl:when test="$iLayoutPosition=0">
                    <xsl:text>N</xsl:text>
                </xsl:when>
                <xsl:when test="count($frontMatterLayoutInfo/abstractLayout[number($iLayoutPosition)]/following-sibling::abstractLayout)=0">
                    <xsl:text>Y</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>N</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$iLayoutPosition = 0">
                <!-- there's one and only one abstractLayout; use it -->
                <xsl:call-template name="OutputAbstractTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="text-transform" select="$text-transform"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$iLayoutPosition = $iPos">
                <!-- there are many anstractLayouts; use the one that matches in position -->
                <xsl:call-template name="OutputAbstractTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="text-transform" select="$text-transform"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
                <!-- there are many abstractLayouts and there are more preface elements than prefaceLayout elements; use the last layout -->
                <xsl:call-template name="OutputAbstractTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="text-transform" select="$text-transform"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        acknowledgements (contents)
    -->
    <xsl:template match="acknowledgements" mode="contents">
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:param name="text-transform"/>
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
                <xsl:call-template name="DoSpaceBeforeContentsLine">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"></xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">
                        <xsl:call-template name="GetFirstLevelContentsIdent"/>
                    </xsl:when>
                    <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="text-transform" select="$text-transform"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        appendix (contents)
    -->
    <xsl:template match="appendix[not(ancestor::chapterInCollection)]" mode="contents">
        <xsl:param name="text-transform"/>
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse" select="$frontMatterLayoutInfo/contentsLayout"/>
        <xsl:variable name="frontMatterLayout" select="$frontMatterLayoutInfo"/>
        <xsl:if test="$contentsLayoutToUse/@showappendices!='no'">
            <xsl:call-template name="OutputTOCLine">
                <xsl:with-param name="sLink" select="@id"/>
                <xsl:with-param name="sLabel">
                    <xsl:if test="$contentsLayoutToUse/@useappendixlabelbeforeappendixletter='yes'">
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
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        <xsl:with-param name="bDoingContents" select="'Y'"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="secTitle" mode="contents">
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:apply-templates>
                </xsl:with-param>
                <xsl:with-param name="sSpaceBefore">
                    <xsl:call-template name="DoSpaceBeforeContentsLine">
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="text-transform" select="$text-transform"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:call-template>
            <xsl:if test="$contentsLayoutToUse/@showsectionsinappendices!='no' and $nLevel!=0">
                <xsl:apply-templates select="section1 | section2" mode="contents">
                    <xsl:with-param name="nLevel" select="$nLevel"/>
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:apply-templates>
            </xsl:if>
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
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse" select="$contentsLayout"/>
        <xsl:if test="$contentsLayoutToUse/@usechapterlabelbeforechapters='yes'">
            <xsl:if test="name()='chapterBeforePart' or count(preceding-sibling::chapter)=0 and not(//chapterBeforePart)">
                <xsl:call-template name="DoChapterLabelInContents">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
        <xsl:variable name="precedingVolume" select="preceding-sibling::*[1][name()='volume']"/>
        <xsl:if test="$precedingVolume and name(.)!='chapterBeforePart'">
            <xsl:call-template name="OutputVolumeInContents">
                <xsl:with-param name="volume" select="$precedingVolume"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$volumes and $publishingInfo/@showVolumeInContents='yes'">
                <xsl:choose>
                    <xsl:when test="$publishingInfo/@whichVolumeToShowInContents='all'">
                        <xsl:call-template name="OutputContentsChapter">
                            <xsl:with-param name="nLevel" select="$nLevel"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$publishingInfo/@whichVolumeToShowInContents=count(preceding-sibling::volume)+1">
                        <xsl:call-template name="OutputContentsChapter">
                            <xsl:with-param name="nLevel" select="$nLevel"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="parent::part">
                        <xsl:call-template name="OutputContentsChapter">
                            <xsl:with-param name="nLevel" select="$nLevel"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputContentsChapter">
                    <xsl:with-param name="nLevel" select="$nLevel"/>
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="chapterInCollection" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse" select="saxon:node-set($contentsLayout)/contentsLayout"/>
        <xsl:if test="$contentsLayoutToUse/@usechapterlabelbeforechapters='yes'">
            <xsl:if test="name()='chapterBeforePart' or count(preceding-sibling::chapterInCollection)=0 and not(//chapterBeforePart)">
                <xsl:call-template name="DoChapterLabelInContents">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
        <xsl:variable name="precedingVolume" select="preceding-sibling::*[1][name()='volume']"/>
        <xsl:if test="$precedingVolume">
            <xsl:call-template name="OutputVolumeInContents">
                <xsl:with-param name="volume" select="$precedingVolume"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$volumes and $publishingInfo/@showVolumeInContents='yes'">
                <xsl:choose>
                    <xsl:when test="$publishingInfo/@whichVolumeToShowInContents='all'">
                        <xsl:call-template name="OutputContentsChapterInCollection">
                            <xsl:with-param name="nLevel" select="$nLevel"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$publishingInfo/@whichVolumeToShowInContents=count(preceding-sibling::volume)+1">
                        <xsl:call-template name="OutputContentsChapterInCollection">
                            <xsl:with-param name="nLevel" select="$nLevel"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputContentsChapterInCollection">
                    <xsl:with-param name="nLevel" select="$nLevel"/>
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        contents  (contents)
    -->
    <xsl:template match="contents" mode="contents">
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
                <xsl:call-template name="CreateContentsID">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputContentsLabel">
                    <xsl:with-param name="layoutInfo" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="text-transform" select="$text-transform"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
    </xsl:template>
    <!--
      endnotes (contents)
   -->
    <xsl:template match="endnotes" mode="contents">
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse"/>
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
                <xsl:call-template name="DoSpaceBeforeContentsLine">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">
                        <xsl:call-template name="GetFirstLevelContentsIdent"/>
                    </xsl:when>
                    <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="text-transform" select="$text-transform"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        glossary (contents)
    -->
    <xsl:template match="glossary" mode="contents">
        <xsl:param name="text-transform"/>
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
                    <xsl:with-param name="text-transform" select="$text-transform"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$iLayoutPosition = $iPos">
                <!-- there are many glossaryLayouts; use the one that matches in position -->
                <xsl:call-template name="OutputGlossaryTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="text-transform" select="$text-transform"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
                <!-- there are many glossaryLayouts and there are more glossary elements than glossaryLayout elements; use the last layout -->
                <xsl:call-template name="OutputGlossaryTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="text-transform" select="$text-transform"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        keywords (contents)
    -->
    <xsl:template match="keywordsShownHere[@showincontents='yes']" mode="contents">
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId">
                        <xsl:choose>
                            <xsl:when test="parent::frontMatter">
                                    <xsl:value-of select="$sKeywordsInFrontMatterID"/>
                            </xsl:when>
                            <xsl:otherwise>
                                    <xsl:value-of select="$sKeywordsInBackMatterID"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputKeywordsLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">
                        <xsl:call-template name="GetFirstLevelContentsIdent"/>
                    </xsl:when>
                    <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="text-transform" select="$text-transform"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        index  (contents)
    -->
    <xsl:template match="index" mode="contents">
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
                <xsl:call-template name="CreateIndexID"/>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputIndexLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="text-transform" select="$text-transform"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        part (contents) 
    -->
    <xsl:template match="part" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse" select="saxon:node-set($contentsLayout)/contentsLayout"/>
        <xsl:variable name="precedingVolume" select="preceding-sibling::*[1][name()='volume']"/>
        <xsl:if test="$precedingVolume">
            <xsl:call-template name="OutputVolumeInContents">
                <xsl:with-param name="volume" select="$precedingVolume"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$volumes and $publishingInfo/@showVolumeInContents='yes'">
                <xsl:choose>
                    <xsl:when test="$publishingInfo/@whichVolumeToShowInContents='all'">
                        <xsl:call-template name="OutputContentsPart">
                            <xsl:with-param name="nLevel" select="$nLevel"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$publishingInfo/@whichVolumeToShowInContents=count(preceding-sibling::volume)+1">
                        <xsl:call-template name="OutputContentsPart">
                            <xsl:with-param name="nLevel" select="$nLevel"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputContentsPart">
                    <xsl:with-param name="nLevel" select="$nLevel"/>
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        preface (contents)
    -->
    <xsl:template match="preface" mode="contents">
        <xsl:param name="iLayoutPosition" select="0"/>
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse" select="$frontMatterLayoutInfo/contentsLayout"/>
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
                    <xsl:with-param name="text-transform" select="$text-transform"/>
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$iLayoutPosition = $iPos">
                <!-- there are many prefaceLayouts; use the one that matches in position -->
                <xsl:call-template name="OutputPrefaceTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="text-transform" select="$text-transform"/>
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
                <!-- there are many prefaceLayouts and there are more preface elements than prefaceLayout elements; use the last layout -->
                <xsl:call-template name="OutputPrefaceTOCLine">
                    <xsl:with-param name="iPos" select="$iPos"/>
                    <xsl:with-param name="text-transform" select="$text-transform"/>
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        references (contents)
    -->
    <xsl:template match="references" mode="contents">
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse"/>
<!--        <xsl:variable name="authors" select="//refAuthor[refWork/@id=//citation[not(ancestor::comment)]/@ref]"/>-->
        <xsl:variable name="authors"
            select="//refAuthor[refWork[@id=$citations[not(ancestor::comment) and not(ancestor::referencedInterlinearText) and not(ancestor::glossaryTerm) and not(ancestor::abbrDefinition)][not(ancestor::refWork) or ancestor::annotation[@id=//annotationRef/@annotation] or ancestor::refWork[@id=$citations[not(ancestor::refWork)]/@ref]]/@ref]]"/>
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
                    <xsl:call-template name="DoSpaceBeforeContentsLine">
                        <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="sIndent">
                    <xsl:choose>
                        <xsl:when test="ancestor::chapterInCollection">
                            <xsl:call-template name="GetFirstLevelContentsIdent"/>
                        </xsl:when>
                        <xsl:otherwise>0pt</xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="text-transform" select="$text-transform"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!-- 
        section2 (contents) 
    -->
    <xsl:template match="section2" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:variable name="iLevel">
            <xsl:value-of select="count(ancestor::section1) + count(ancestor::chapter | ancestor::chapterInCollection) + count(ancestor::chapterBeforePart) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=3 and $bodyLayoutInfo/section3Layout/@ignore!='yes'">
            <xsl:apply-templates select="section3" mode="contents">
                <xsl:with-param name="nLevel" select="$nLevel"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    <!-- 
        section3 (contents) 
    -->
    <xsl:template match="section3" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:variable name="iLevel">
            <xsl:value-of select="1 + count(ancestor::section1) + count(ancestor::chapter | ancestor::chapterInCollection) + count(ancestor::chapterBeforePart) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=4 and $bodyLayoutInfo/section4Layout/@ignore!='yes'">
            <xsl:apply-templates select="section4" mode="contents">
                <xsl:with-param name="nLevel" select="$nLevel"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    <!-- 
        section4 (contents) 
    -->
    <xsl:template match="section4" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:variable name="iLevel">
            <xsl:value-of select="2 + count(ancestor::section1) + count(ancestor::chapter | ancestor::chapterInCollection) + count(ancestor::chapterBeforePart) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=5 and $bodyLayoutInfo/section5Layout/@ignore!='yes'">
            <xsl:apply-templates select="section5" mode="contents">
                <xsl:with-param name="nLevel" select="$nLevel"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    <!-- 
        section5 (contents) 
    -->
    <xsl:template match="section5" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:variable name="iLevel">
            <xsl:value-of select="3 + count(ancestor::section1) + count(ancestor::chapter | ancestor::chapterInCollection) + count(ancestor::chapterBeforePart) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
        <xsl:if test="$nLevel>=6 and $bodyLayoutInfo/section6Layout/@ignore!='yes'">
            <xsl:apply-templates select="section6" mode="contents">
                <xsl:with-param name="nLevel" select="$nLevel"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    <!-- 
        section6 (contents) 
    -->
    <xsl:template match="section6" mode="contents">
        <xsl:param name="nLevel" select="$nLevel"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:variable name="iLevel">
            <xsl:value-of select="4 + count(ancestor::section1) + count(ancestor::chapter | ancestor::chapterInCollection) + count(ancestor::chapterBeforePart) + count(ancestor::appendix)"/>
        </xsl:variable>
        <xsl:call-template name="OutputSectionTOC">
            <xsl:with-param name="sLevel" select="$iLevel"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
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
        <xsl:param name="contentsLayoutToUse" select="saxon:node-set($contentsLayout)/contentsLayout"/>
        <xsl:choose>
            <xsl:when test="name()='part' and $contentsLayoutToUse/@partSpaceBefore">
                <xsl:value-of select="$contentsLayoutToUse/@partSpaceBefore"/>
            </xsl:when>
            <xsl:when test="$contentsLayoutToUse/@spacebeforemainsection">
                <xsl:value-of select="$contentsLayoutToUse/@spacebeforemainsection"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>0</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        OutputAbstractTOCLine
    -->
    <xsl:template name="OutputAbstractTOCLine">
        <xsl:param name="iPos"/>
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse" select="saxon:node-set($contentsLayout)/contentsLayout"/>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink">
                <xsl:call-template name="GetIdToUse">
                    <xsl:with-param name="sBaseId" select="concat($sAbstractID,count(preceding-sibling::abstract))"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputAbstractLabel"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">
                        <xsl:call-template name="GetFirstLevelContentsIdent"/>
                    </xsl:when>
                    <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="text-transform" select="$text-transform"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        OutputContentsChapter
    -->
    <xsl:template name="OutputContentsChapter">
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:param name="nLevel"/>
        <xsl:variable name="sChapterLineIndent" select="normalize-space($contentsLayoutToUse/@chapterlineindent)"/>
        <xsl:if test="string-length($sChapterLineIndent)&gt;0">
            <xsl:call-template name="SetChapterNumberWidth">
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputChapterNumber">
                    <xsl:with-param name="fDoingContents" select="'Y'"/>
                </xsl:call-template>
                <xsl:if test="saxon:node-set($contentsLayoutToUse)/@useperiodafterchapternumber='yes'">
                    <xsl:text>.</xsl:text>
                </xsl:if>
                <xsl:text>&#xa0; </xsl:text>
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
                <xsl:call-template name="DoChapterNumberWidth">
                    <xsl:with-param name="sChapterLineIndent" select="$sChapterLineIndent"/>
                </xsl:call-template>
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
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
        <xsl:apply-templates select="shortTitle" mode="contents"/>
        <xsl:if test="$nLevel!=0">
            <xsl:apply-templates select="section1 | section2" mode="contents">
                <xsl:with-param name="nLevel" select="$nLevel"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    <!-- 
        OutputContentsChapterInCollection
    -->
    <xsl:template name="OutputContentsChapterInCollection">
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:param name="nLevel"/>
        <xsl:variable name="sChapterLineIndent" select="normalize-space($contentsLayoutToUse/@chapterlineindent)"/>
        <xsl:if test="string-length($sChapterLineIndent)&gt;0">
            <xsl:call-template name="SetChapterNumberWidth"/>
        </xsl:if>
        <xsl:call-template name="OutputTOCLine">
            <xsl:with-param name="sLink" select="@id"/>
            <xsl:with-param name="sLabel">
                <xsl:call-template name="OutputChapterNumber"/>
                <xsl:if test="$contentsLayoutToUse/@useperiodafterchapternumber='yes'">
                    <xsl:text>.</xsl:text>
                </xsl:if>
                <xsl:text>&#xa0;</xsl:text>
                <xsl:if test="string-length($sChapterLineIndent)&gt;0">
                    <xsl:call-template name="AddWordSpace"/>
                </xsl:if>
                <xsl:apply-templates select="frontMatter/title" mode="contents"/>
            </xsl:with-param>
            <xsl:with-param name="sSpaceBefore">
                <xsl:call-template name="DoSpaceBeforeContentsLine">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
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
                <xsl:call-template name="DoChapterNumberWidth">
                    <xsl:with-param name="sChapterLineIndent" select="$sChapterLineIndent"/>
                </xsl:call-template>
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
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
        <xsl:call-template name="DoAuthorOfChapterInCollectionInContents"/>
        <xsl:if test="$nLevel!=0">
            <xsl:call-template name="DoFrontMatterContentsPerLayout">
                <xsl:with-param name="frontMatter" select="frontMatter"/>
            </xsl:call-template>
            <xsl:apply-templates select="section1" mode="contents">
                <xsl:with-param name="nLevel" select="$nLevel"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:apply-templates>
            <xsl:call-template name="DoBackMatterContentsPerLayout">
                <xsl:with-param name="nLevel" select="$nLevel"/>
                <xsl:with-param name="backMatter" select="backMatter"/>
                <xsl:with-param name="backMatterLayout" select="$bodyLayoutInfo/chapterInCollectionBackMatterLayout"/>
                <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!-- 
        OutputGlossaryTOCLine
    -->
    <xsl:template name="OutputGlossaryTOCLine">
        <xsl:param name="iPos"/>
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse" select="saxon:node-set($contentsLayout)/contentsLayout"/>
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
                <xsl:call-template name="DoSpaceBeforeContentsLine">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">
                        <xsl:call-template name="GetFirstLevelContentsIdent"/>
                    </xsl:when>
                    <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="text-transform" select="$text-transform"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        OutputPartLabelNumberAndTitle
    -->
    <xsl:template name="OutputPartLabelNumberAndTitle">
        <xsl:param name="contentsLayoutToUse" select="saxon:node-set($contentsLayout)/contentsLayout"/>
        <xsl:param name="fInContents" select="'N'"/>
        <xsl:call-template name="OutputPartLabel"/>
        <xsl:choose>
            <xsl:when test="$contentsLayoutToUse/@partContentBetweenLabelAndNumber">
                <xsl:value-of select="$contentsLayoutToUse/@partContentBetweenLabelAndNumber"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#x20;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="." mode="numberPart"/>
        <xsl:choose>
            <xsl:when test="$contentsLayoutToUse/@partContentBetweenNumberAndTitle">
                <xsl:value-of select="$contentsLayoutToUse/@partContentBetweenNumberAndTitle"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#160;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$fInContents='Y'">
                <xsl:apply-templates select="secTitle" mode="contents"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="secTitle"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        OutputPrefaceTOCLine
    -->
    <xsl:template name="OutputPrefaceTOCLine">
        <xsl:param name="iPos"/>
        <xsl:param name="text-transform"/>
        <xsl:param name="contentsLayoutToUse" select="saxon:node-set($contentsLayout)/contentsLayout"/>
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
                <xsl:call-template name="DoSpaceBeforeContentsLine">
                    <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sIndent">
                <xsl:choose>
                    <xsl:when test="ancestor::chapterInCollection">
                        <xsl:call-template name="GetFirstLevelContentsIdent"/>
                    </xsl:when>
                    <xsl:otherwise>0pt</xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="text-transform" select="$text-transform"/>
            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        OutputVolumeInContents
    -->
    <xsl:template name="OutputVolumeInContents">
        <xsl:param name="volume"/>
        <xsl:param name="contentsLayoutToUse"/>
        <xsl:if test="$volumes and $publishingInfo/@showVolumeInContents='yes'">
            <xsl:choose>
                <xsl:when test="$publishingInfo/@whichVolumeToShowInContents='all'">
                    <xsl:for-each select="$volume">
                        <xsl:call-template name="OutputTOCVolumeLine">
                            <xsl:with-param name="volume" select="$volume"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$publishingInfo/@whichVolumeToShowInContents=count(preceding-sibling::volume[parent::lingPaper])+1">
                    <xsl:for-each select="$volume">
                        <xsl:call-template name="OutputTOCVolumeLine">
                            <xsl:with-param name="volume" select="$volume"/>
                            <xsl:with-param name="contentsLayoutToUse" select="$contentsLayoutToUse"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <!-- do nothing -->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
