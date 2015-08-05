<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
   <xsl:param name="chapterInCollectionId"/>
    <xsl:template match="/">
       <xsl:choose>
          <xsl:when test="string-length($chapterInCollectionId) &gt;0 and id($chapterInCollectionId)/backMatter/glossaryTerms">
             <xsl:apply-templates select="id($chapterInCollectionId)/backMatter/descendant::glossaryTerm"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:apply-templates select="//lingPaper/backMatter/descendant::glossaryTerm"/>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
   <xsl:template match="glossaryTerm">
         <xsl:text>"</xsl:text>
      <xsl:apply-templates select="glossaryTermInLang[1]/glossaryTermTerm"/>
      <xsl:text> = </xsl:text>
      <xsl:apply-templates select="glossaryTermInLang[1]/glossaryTermDefinition" mode="InTitle"/>
        <xsl:text> {</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>}"
</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>
</xsl:text>
   </xsl:template>
    <xsl:template match="object" mode="InTitle">
        <xsl:variable name="type" select="id(@type)"/>
        <xsl:value-of select="$type/@before"/>
        <xsl:value-of select="."/>
        <xsl:value-of select="$type/@after"/>
    </xsl:template>
   <xsl:template match="glossaryTermRef" mode="InTitle">
      <xsl:call-template name="OutputGlossaryTerm"/>
<!--      <xsl:apply-templates select="self::*"/>-->
   </xsl:template>
   <xsl:template name="OutputGlossaryTerm">
      <xsl:param name="glossaryTerm" select="id(@glossaryTerm)"/>
      <xsl:choose>
         <xsl:when test="string-length(.) &gt; 0">
            <xsl:value-of select="."/>
         </xsl:when>
         <xsl:otherwise>
            <!--  no language specified; just use the first one -->
            <xsl:apply-templates select="$glossaryTerm/glossaryTermInLang[1]/glossaryTermTerm" mode="Use"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

</xsl:stylesheet>
