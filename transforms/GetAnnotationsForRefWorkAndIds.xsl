<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
   <xsl:param name="refWorkId"/>
    <xsl:template match="/">
       <xsl:apply-templates select="//refWork[@id=$refWorkId]/annotations"/>
    </xsl:template>
   <xsl:template match="annotation">
         <xsl:text>"</xsl:text>
      <xsl:value-of select="substring(.,1,50)"/>
      <xsl:text> [</xsl:text>
      <xsl:value-of select="@annotype"/>
      <xsl:text> ]{</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>}"
</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>
</xsl:text>
   </xsl:template>
</xsl:stylesheet>
