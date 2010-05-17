<?xml version="1.0" encoding="UTF-8"?>
<!-- N.B. DO NOT REFORMAT AUTOMATICALLY - WE WILL LOSE THE FINAL RETURN NEEDED -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
   <xsl:output method="text" encoding="UTF-8" indent="no"/>
   <xsl:template match="/">
      <xsl:apply-templates select="//interlinear-text">
         <xsl:sort select="textInfo/shortTitle"/>
         <xsl:sort select="position()"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="//interlinear-text">
      <xsl:variable name="sShortTitle" select="normalize-space(textInfo/shortTitle)"/>
      <xsl:variable name="sTitle">
         <xsl:choose>
            <xsl:when test="string-length($sShortTitle) &gt; 0">
               <xsl:value-of select="$sShortTitle"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>unnamed</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:for-each select="interlinear">
          <xsl:if test="string-length(@text)!=0">
         <xsl:text>"</xsl:text>
         <xsl:value-of select="$sShortTitle"/>
         <xsl:text>:</xsl:text>
         <xsl:variable name="sNum">
            <xsl:number format="001" value="position()"/>
         </xsl:variable>
         <xsl:value-of select="$sNum"/>
         <xsl:text> </xsl:text>
         <xsl:for-each select="lineGroup/line[1]">
         <xsl:for-each select="descendant-or-self::langData">
            <xsl:value-of select="."/>
            <xsl:text> </xsl:text>
         </xsl:for-each>   
         </xsl:for-each>
         <xsl:text> {</xsl:text>
         <xsl:value-of select="@text"/>
         <xsl:text>}"
</xsl:text>
         <xsl:value-of select="@text"/>
         <xsl:text>
</xsl:text>
          </xsl:if>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="object" mode="InTitle">
      <xsl:variable name="type" select="id(@type)"/>
      <xsl:value-of select="$type/@before"/>
      <xsl:value-of select="."/>
      <xsl:value-of select="$type/@after"/>
   </xsl:template>
</xsl:stylesheet>
