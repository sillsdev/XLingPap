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
       <xsl:variable name="sTextTitle" select="normalize-space(textInfo/textTitle)"/>
       <xsl:variable name="sTitle">
         <xsl:choose>
            <xsl:when test="string-length($sShortTitle) &gt; 0">
               <xsl:value-of select="$sShortTitle"/>
            </xsl:when>
             <xsl:when test="string-length($sTextTitle) &gt; 0">
                 <xsl:value-of select="$sTextTitle"/>
             </xsl:when>
             <xsl:otherwise>
               <xsl:text>unnamed</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
       <xsl:if test="string-length(@text)!=0">
           <xsl:text>"</xsl:text>
           <xsl:value-of select="$sTitle"/>
           <xsl:text> (entire text) </xsl:text>
           <xsl:text> {</xsl:text>
           <xsl:value-of select="@text"/>
           <xsl:text>}"
</xsl:text>
           <xsl:value-of select="@text"/>
           <xsl:text>
</xsl:text>
       </xsl:if>
       <xsl:for-each select="interlinear">
          <xsl:if test="string-length(@text)!=0">
         <xsl:text>"</xsl:text>
         <xsl:value-of select="$sTitle"/>
         <xsl:text>:</xsl:text>
              <xsl:variable name="sTextID">
              <xsl:choose>
                  <xsl:when test="substring(@text,1,4)='T-ID'">
                      <xsl:value-of select="substring-after(substring-after(@text,'-'),'-')"/>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="position()"/>
                  </xsl:otherwise>
              </xsl:choose>
              </xsl:variable>
<!--         <xsl:variable name="sNum">
<!-\-            <xsl:number format="001.001" value="$sTextID"/>-\->
             <xsl:value-of select="format-number($sTextID, '000.###')"/>
         </xsl:variable>-->
         <xsl:value-of select="$sTextID"/>
         <xsl:text> </xsl:text>
         <xsl:for-each select="lineGroup/line[1]">
         <xsl:for-each select="descendant-or-self::langData">
            <xsl:apply-templates select="node()[name() != 'endnote']"/>
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
