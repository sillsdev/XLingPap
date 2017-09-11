<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
   <xsl:output method="text" encoding="UTF-8" indent="no"/>
   <xsl:template match="/">
      <xsl:apply-templates select="//lingPaper/descendant::example"/>
   </xsl:template>
   <!-- 
   example
   -->
   <xsl:template match="example">
      <xsl:if test="not(ancestor::framedUnit)">
      <xsl:text>"</xsl:text>
      <xsl:call-template name="GetExampleNumber"/>
      <xsl:text> {</xsl:text>
      <xsl:value-of select="@num"/>
      <xsl:text>}"
</xsl:text>
      <xsl:value-of select="@num"/>
      <xsl:text>
</xsl:text>
      <xsl:text>"</xsl:text>
      <xsl:value-of select="@num"/>
      <xsl:text> {</xsl:text>
      <xsl:value-of select="@num"/>
      <xsl:text>}"
      </xsl:text>
      <xsl:value-of select="@num"/>
      <xsl:text>
</xsl:text>
      <xsl:apply-templates select="listWord | listSingle | listInterlinear | listDefinition | lineSet"/>
      </xsl:if>
   </xsl:template>
   <!-- 
      list items
   -->
   <xsl:template match="listWord | listSingle | listInterlinear | listDefinition | lineSet">
      <xsl:text>"</xsl:text>
      <xsl:for-each select="parent::example">
         <xsl:call-template name="GetExampleNumber"/>
      </xsl:for-each>
      <xsl:choose>
         <xsl:when test="name()='listWord'">
            <xsl:number level="single" count="listWord" format="a"/>
         </xsl:when>
         <xsl:when test="name()='listSingle'">
            <xsl:number level="single" count="listSingle" format="a"/>
         </xsl:when>
         <xsl:when test="name()='listInterlinear'">
            <xsl:number level="single" count="listInterlinear" format="a"/>
         </xsl:when>
         <xsl:when test="name()='listDefinition'">
            <xsl:number level="single" count="listDefinition" format="a"/>
         </xsl:when>
         <xsl:when test="name()='lineSet'">
            <xsl:number level="single" count="lineSet" format="a"/>
         </xsl:when>
      </xsl:choose>
      <xsl:text> {</xsl:text>
      <xsl:value-of select="@letter"/>
      <xsl:text>}"
      </xsl:text>
      <xsl:value-of select="@letter"/>
      <xsl:text>
</xsl:text>
      <xsl:text>"</xsl:text>
      <xsl:value-of select="@letter"/>
      <xsl:text> {</xsl:text>
      <xsl:value-of select="@letter"/>
      <xsl:text>}"
      </xsl:text>
      <xsl:value-of select="@letter"/>
      <xsl:text>
</xsl:text>
   </xsl:template>
   <!-- 
      GetExampleNumber
   -->
   <xsl:template name="GetExampleNumber">
      <xsl:choose>
         <xsl:when test="ancestor::endnote">
            <xsl:number level="single" count="example" format="i"/>
         </xsl:when>
<!--         <xsl:when test="ancestor::framedUnit">
            <xsl:variable name="initialExampleNumber" select="normalize-space(ancestor::framedUnit/@initialexamplenumber)"/>
            <xsl:variable name="iStart">
               <xsl:choose>
                  <xsl:when test="string-length($initialExampleNumber) &gt; 0 and number($initialExampleNumber)!='NaN'">
                     <xsl:value-of select="$initialExampleNumber - 1"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>0</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="iThis">
               <xsl:number level="single" count="example" format="1"/>
            </xsl:variable>
            <xsl:value-of select="$iStart + $iThis"/>
         </xsl:when>-->
         <xsl:when test="/xlingpaper/styledPaper/publisherStyleSheet[1]/contentLayout/exampleLayout/@startNumberingOverAtEachChapter='yes'">
            <xsl:number level="any" from="chapter | chapterInCollection | appendix" count="example[not(ancestor::endnote or ancestor::framedUnit)]" format="1"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:number level="any" count="example[not(ancestor::endnote or ancestor::framedUnit)]" format="1"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>
