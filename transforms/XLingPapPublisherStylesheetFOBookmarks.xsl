<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
   <!--
        abstract  (bookmarks)
    -->
   <xsl:template match="abstract" mode="bookmarks">
      <xsl:call-template name="OutputBookmark">
         <xsl:with-param name="sLink">
            <xsl:call-template name="GetIdToUse">
               <xsl:with-param name="sBaseId" select="$sAbstractID"/>
            </xsl:call-template>
         </xsl:with-param>
         <xsl:with-param name="sLabel">
            <xsl:call-template name="OutputAbstractLabel"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!--
        acknowledgements (bookmarks)
    -->
   <xsl:template match="acknowledgements" mode="bookmarks">
      <xsl:call-template name="OutputBookmark">
         <xsl:with-param name="sLink">
            <xsl:call-template name="GetIdToUse">
               <xsl:with-param name="sBaseId" select="$sAcknowledgementsID"/>
            </xsl:call-template>
         </xsl:with-param>
         <xsl:with-param name="sLabel">
            <xsl:call-template name="OutputAcknowledgementsLabel"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!--
        appendix (bookmarks)
    -->
   <xsl:template match="appendix" mode="bookmarks">
      <fo:bookmark internal-destination="{@id}" starting-state="show">
         <fo:bookmark-title>
            <xsl:call-template name="OutputChapterNumber">
               <xsl:with-param name="fDoTextAfterLetter" select="'N'"/>
            </xsl:call-template>
            <!--            <xsl:apply-templates select="secTitle"/>-->
            <xsl:apply-templates select="secTitle/text() | secTitle/*[name()!='comment']" mode="bookmarks"/>
         </fo:bookmark-title>
         <xsl:apply-templates select="section1 | section2" mode="bookmarks"/>
      </fo:bookmark>
   </xsl:template>
   <!-- 
        chapter (bookmarks) 
    -->
   <xsl:template match="chapter | chapterBeforePart" mode="bookmarks">
      <fo:bookmark internal-destination="{@id}">
         <fo:bookmark-title>
            <xsl:call-template name="OutputChapterNumber"/>
            <xsl:text>&#xa0;</xsl:text>
            <xsl:apply-templates select="secTitle/text() | secTitle/*[name()!='comment'] | frontMatter/title" mode="bookmarks"/>
         </fo:bookmark-title>
         <xsl:apply-templates select="section1 | section2" mode="bookmarks"/>
      </fo:bookmark>
   </xsl:template>
   <!-- 
      chapterInCollection (bookmarks) 
   -->
   <xsl:template match="chapterInCollection" mode="bookmarks">
      <fo:bookmark internal-destination="{@id}">
         <fo:bookmark-title>
            <xsl:call-template name="OutputChapterNumber"/>
            <xsl:text>&#xa0;</xsl:text>
            <xsl:apply-templates select="frontMatter/title" mode="bookmarks"/>
         </fo:bookmark-title>
         <xsl:call-template name="DoFrontMatterBookmarksPerLayout">
            <xsl:with-param name="frontMatter" select="frontMatter"/>
            <xsl:with-param name="frontMatterLayout" select="$bodyLayoutInfo/chapterInCollectionFrontMatterLayout"/>
         </xsl:call-template>
         <xsl:apply-templates select="section1 | section2" mode="bookmarks"/>
         <xsl:call-template name="DoBackMatterBookmarksPerLayout">
            <xsl:with-param name="backMatter" select="backMatter"/>
            <xsl:with-param name="backMatterLayout" select="$bodyLayoutInfo/chapterInCollectionBackMatterLayout"/>
         </xsl:call-template>
      </fo:bookmark>
   </xsl:template>
   <!--
      contents (bookmarks)
   -->
   <xsl:template match="contents" mode="bookmarks">
      <xsl:call-template name="OutputBookmark">
         <xsl:with-param name="sLink">
            <xsl:call-template name="GetIdToUse">
               <xsl:with-param name="sBaseId" select="$sContentsID"/>
            </xsl:call-template>
         </xsl:with-param>
         <xsl:with-param name="sLabel">
            <xsl:call-template name="OutputContentsLabel"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!--
      endnote (bookmarks)
   -->
   <xsl:template match="endnote" mode="bookmarks"/>
   <!--
      endnotes (bookmarks)
   -->
   <xsl:template match="endnotes" mode="bookmarks">
      <xsl:call-template name="OutputBookmark">
         <xsl:with-param name="sLink">
            <xsl:call-template name="GetIdToUse">
               <xsl:with-param name="sBaseId" select="$sEndnotesID"/>
            </xsl:call-template>
         </xsl:with-param>
         <xsl:with-param name="sLabel">
            <xsl:call-template name="OutputEndnotesLabel"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!--
        glossary (bookmarks)
    -->
   <xsl:template match="glossary" mode="bookmarks">
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
            <!-- there's one and only one prefaceLayout; use it -->
            <xsl:call-template name="OutputBookmark">
               <xsl:with-param name="sLink">
                  <xsl:call-template name="GetIdToUse">
                     <xsl:with-param name="sBaseId" select="concat($sGlossaryID,position())"/>
                  </xsl:call-template>
               </xsl:with-param>
               <xsl:with-param name="sLabel">
                  <xsl:call-template name="OutputGlossaryLabel"/>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="$iLayoutPosition = $iPos">
            <!-- there are many prefaceLayouts; use the one that matches in position -->
            <xsl:call-template name="OutputBookmark">
               <xsl:with-param name="sLink">
                  <xsl:call-template name="GetIdToUse">
                     <xsl:with-param name="sBaseId" select="concat($sGlossaryID,position())"/>
                  </xsl:call-template>
               </xsl:with-param>
               <xsl:with-param name="sLabel">
                  <xsl:call-template name="OutputGlossaryLabel"/>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
            <!-- there are many prefaceLayouts and there are more preface elements than prefaceLayout elements; use the last layout -->
            <xsl:call-template name="OutputBookmark">
               <xsl:with-param name="sLink">
                  <xsl:call-template name="GetIdToUse">
                     <xsl:with-param name="sBaseId" select="concat($sGlossaryID,position())"/>
                  </xsl:call-template>
               </xsl:with-param>
               <xsl:with-param name="sLabel">
                  <xsl:call-template name="OutputGlossaryLabel"/>
               </xsl:with-param>
            </xsl:call-template>            
         </xsl:when>
      </xsl:choose>
<!--      
      
      <xsl:if test="$iLayoutPosition = 0 or $iLayoutPosition = $iPos">
         <xsl:call-template name="OutputBookmark">
            <xsl:with-param name="sLink">
               <xsl:call-template name="GetIdToUse">
                  <xsl:with-param name="sBaseId" select="concat($sGlossaryID,$iPos)"/>
               </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="sLabel">
               <xsl:call-template name="OutputGlossaryLabel"/>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>-->
   </xsl:template>
   <!--
        index  (bookmarks)
    -->
   <xsl:template match="index" mode="bookmarks">
      <xsl:call-template name="OutputBookmark">
         <xsl:with-param name="sLink">
            <xsl:call-template name="CreateIndexID"/>
         </xsl:with-param>
         <xsl:with-param name="sLabel">
            <xsl:call-template name="OutputIndexLabel"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!--
      keywords (bookmarks)
   -->
   <xsl:template match="keywordsShownHere[@showincontents='yes']" mode="bookmarks">
      <xsl:call-template name="OutputBookmark">
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
      </xsl:call-template>
   </xsl:template>
   <!-- 
        part (bookmarks) 
    -->
   <xsl:template match="part" mode="bookmarks">
      <!--        <xsl:param name="nLevel"/>-->
      <xsl:if test="position()=1">
         <xsl:for-each select="preceding-sibling::*[name()='chapterBeforePart']">
            <xsl:apply-templates select="." mode="bookmarks">
               <!--                    <xsl:with-param name="nLevel" select="$nLevel"/>-->
            </xsl:apply-templates>
         </xsl:for-each>
      </xsl:if>
      <fo:bookmark internal-destination="{@id}" starting-state="show">
         <fo:bookmark-title>
            <xsl:call-template name="OutputPartLabel"/>
            <xsl:text>&#x20;</xsl:text>
            <xsl:apply-templates select="." mode="numberPart"/>
            <xsl:text>&#xa0;</xsl:text>
            <!--            <xsl:apply-templates select="secTitle"/>-->
            <xsl:apply-templates select="secTitle/text() | secTitle/*[name()!='comment']" mode="bookmarks"/>
         </fo:bookmark-title>
      </fo:bookmark>
      <!--<xsl:apply-templates select="child::node()[name()!='secTitle']" mode="bookmarks">
            <!-\-                <xsl:with-param name="nLevel" select="$nLevel"/>-\->
       </xsl:apply-templates>-->
      <xsl:apply-templates select="chapter | chapterInCollection" mode="bookmarks"/>
   </xsl:template>
   <!--
        preface (bookmarks)
    -->
   <xsl:template match="preface" mode="bookmarks">
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
            <xsl:call-template name="OutputBookmark">
               <xsl:with-param name="sLink">
                  <xsl:call-template name="GetIdToUse">
                     <xsl:with-param name="sBaseId" select="concat($sPrefaceID,position())"/>
                  </xsl:call-template>
               </xsl:with-param>
               <xsl:with-param name="sLabel">
                  <xsl:call-template name="OutputPrefaceLabel"/>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="$iLayoutPosition = $iPos">
            <!-- there are many prefaceLayouts; use the one that matches in position -->
            <xsl:call-template name="OutputBookmark">
               <xsl:with-param name="sLink">
                  <xsl:call-template name="GetIdToUse">
                     <xsl:with-param name="sBaseId" select="concat($sPrefaceID,position())"/>
                  </xsl:call-template>
               </xsl:with-param>
               <xsl:with-param name="sLabel">
                  <xsl:call-template name="OutputPrefaceLabel"/>
               </xsl:with-param>
            </xsl:call-template>
            </xsl:when>
         <xsl:when test="$fLayoutIsLastOfMany='Y' and $iPos &gt; $iLayoutPosition">
            <!-- there are many prefaceLayouts and there are more preface elements than prefaceLayout elements; use the last layout -->
            <xsl:call-template name="OutputBookmark">
               <xsl:with-param name="sLink">
                  <xsl:call-template name="GetIdToUse">
                     <xsl:with-param name="sBaseId" select="concat($sPrefaceID,position())"/>
                  </xsl:call-template>
               </xsl:with-param>
               <xsl:with-param name="sLabel">
                  <xsl:call-template name="OutputPrefaceLabel"/>
               </xsl:with-param>
            </xsl:call-template>            
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <!--
        references (bookmarks)
    -->
   <xsl:template match="references" mode="bookmarks">
      <xsl:call-template name="OutputBookmark">
         <xsl:with-param name="sLink">
            <xsl:call-template name="GetIdToUse">
               <xsl:with-param name="sBaseId" select="$sReferencesID"/>
            </xsl:call-template>
         </xsl:with-param>
         <xsl:with-param name="sLabel">
            <xsl:call-template name="OutputReferencesLabel"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!-- 
        section1 (bookmarks) 
    -->
   <xsl:template match="section1" mode="bookmarks">
      <fo:bookmark internal-destination="{@id}" starting-state="show">
         <xsl:call-template name="OutputSectionBookmark"/>
         <xsl:if test="$nLevel>=2 and $bodyLayoutInfo/section2Layout/@ignore!='yes'">
            <xsl:apply-templates select="section2" mode="bookmarks"/>
         </xsl:if>
      </fo:bookmark>
   </xsl:template>
   <!-- 
        section2 (bookmarks) 
    -->
   <xsl:template match="section2" mode="bookmarks">
      <fo:bookmark internal-destination="{@id}" starting-state="show">
         <xsl:call-template name="OutputSectionBookmark"/>
         <xsl:if test="$nLevel>=3 and $bodyLayoutInfo/section3Layout/@ignore!='yes'">
            <xsl:apply-templates select="section3" mode="bookmarks"/>
         </xsl:if>
      </fo:bookmark>
   </xsl:template>
   <!-- 
        section3 (bookmarks) 
    -->
   <xsl:template match="section3" mode="bookmarks">
      <fo:bookmark internal-destination="{@id}" starting-state="show">
         <xsl:call-template name="OutputSectionBookmark"/>
         <xsl:if test="$nLevel>=4 and $bodyLayoutInfo/section4Layout/@ignore!='yes'">
            <xsl:apply-templates select="section4" mode="bookmarks"/>
         </xsl:if>
      </fo:bookmark>
   </xsl:template>
   <!-- 
        section4 (bookmarks) 
    -->
   <xsl:template match="section4" mode="bookmarks">
      <fo:bookmark internal-destination="{@id}" starting-state="show">
         <xsl:call-template name="OutputSectionBookmark"/>
         <xsl:if test="$nLevel>=5 and $bodyLayoutInfo/section5Layout/@ignore!='yes'">
            <xsl:apply-templates select="section5" mode="bookmarks"/>
         </xsl:if>
      </fo:bookmark>
   </xsl:template>
   <!-- 
        section5 (bookmarks) 
    -->
   <xsl:template match="section5" mode="bookmarks">
      <fo:bookmark internal-destination="{@id}" starting-state="show">
         <xsl:call-template name="OutputSectionBookmark"/>
         <xsl:if test="$nLevel>=6 and $bodyLayoutInfo/section6Layout/@ignore!='yes'">
            <xsl:apply-templates select="section6" mode="bookmarks"/>
         </xsl:if>
      </fo:bookmark>
   </xsl:template>
   <!-- 
        section6 (bookmarks) 
    -->
   <xsl:template match="section6" mode="bookmarks">
      <fo:bookmark internal-destination="{@id}" starting-state="show">
         <xsl:call-template name="OutputSectionBookmark"/>
      </fo:bookmark>
   </xsl:template>
   <!--  
      OutputBookmark
   -->
   <xsl:template name="OutputBookmark">
      <xsl:param name="sLink"/>
      <xsl:param name="sLabel"/>
      <!-- insert a new line so we don't get everything all on one line -->
      <xsl:text>&#xa;</xsl:text>
      <fo:bookmark internal-destination="{$sLink}">
         <fo:bookmark-title>
            <xsl:value-of select="$sLabel"/>
         </fo:bookmark-title>
      </fo:bookmark>
   </xsl:template>
   <!--  
        OutputSectionBookmark
    -->
   <xsl:template name="OutputSectionBookmark">
      <!-- insert a new line so we don't get everything all on one line -->
      <xsl:text>&#xa;</xsl:text>
      <fo:bookmark-title>
         <xsl:call-template name="OutputSectionNumber">
            <xsl:with-param name="bIsForBookmark" select="'Y'"/>
            <xsl:with-param name="sContentsPeriod">
               <xsl:choose>
                  <xsl:when test="name()='section1'">
                     <xsl:if test="not($bodyLayoutInfo/section1Layout/numberLayoutInfo) and $bodyLayoutInfo/section1Layout/sectionTitleLayout/@useperiodafternumber='yes'">
                        <xsl:text>.</xsl:text>
                     </xsl:if>
                  </xsl:when>
                  <xsl:when test="name()='section2'">
                     <xsl:if test="not($bodyLayoutInfo/section2Layout/numberLayoutInfo) and $bodyLayoutInfo/section2Layout/sectionTitleLayout/@useperiodafternumber='yes'">
                        <xsl:text>.</xsl:text>
                     </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:if test="not($bodyLayoutInfo/section3Layout/numberLayoutInfo) and $bodyLayoutInfo/section3Layout/sectionTitleLayout/@useperiodafternumber='yes'">
                        <xsl:text>.</xsl:text>
                     </xsl:if>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:with-param>
         </xsl:call-template>
         <xsl:if test="not(count(//section1)=1 and count(//section2)=0)">
            <xsl:text>&#xa0;</xsl:text>
         </xsl:if>
         <xsl:apply-templates select="secTitle/text() | secTitle/*[name()!='comment']" mode="bookmarks"/>
      </fo:bookmark-title>
   </xsl:template>
</xsl:stylesheet>
