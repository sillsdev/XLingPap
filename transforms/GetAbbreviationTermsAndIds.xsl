<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
   <xsl:param name="chapterInCollectionId"/>
    <xsl:template match="/">
       <xsl:choose>
          <xsl:when test="string-length($chapterInCollectionId) &gt;0 and id($chapterInCollectionId)/backMatter/abbreviations">
             <xsl:apply-templates select="id($chapterInCollectionId)/backMatter/descendant::abbreviation"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:apply-templates select="//lingPaper/backMatter/descendant::abbreviation"/>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
   <xsl:template match="abbreviation">
         <xsl:text>"</xsl:text>
      <xsl:apply-templates select="abbrInLang[1]/abbrTerm"/>
      <xsl:text> = </xsl:text>
      <xsl:apply-templates select="abbrInLang[1]/abbrDefinition" mode="InTitle"/>
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
</xsl:stylesheet>
