<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="/">
       <xsl:apply-templates select="//annotatedBibliographyType"/>
    </xsl:template>
   <xsl:template match="annotatedBibliographyType">
         <xsl:text>"</xsl:text>
      <xsl:value-of select="."/>
        <xsl:text> {</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>}"
</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>
</xsl:text>
   </xsl:template>
</xsl:stylesheet>
