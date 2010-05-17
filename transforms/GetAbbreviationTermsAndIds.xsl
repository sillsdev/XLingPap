<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="no"/>
    <xsl:template match="/">
       <xsl:apply-templates select="//abbreviation"/>
    </xsl:template>
   <xsl:template match="//abbreviation">
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
