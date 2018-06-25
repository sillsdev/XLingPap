<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>
   <!-- 
   Transform to promote sections.
   -->
   <xsl:template match="/">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="section1">
      <chapter xmlns:xi="http://www.w3.org/2001/XInclude">
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates/>
      </chapter>
   </xsl:template>
   <xsl:template match="section2">
      <section1 xmlns:xi="http://www.w3.org/2001/XInclude">
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates/>
      </section1>
   </xsl:template>
   <xsl:template match="section3">
      <section2 xmlns:xi="http://www.w3.org/2001/XInclude">
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates/>
      </section2>
   </xsl:template>
   <xsl:template match="section4">
      <section3 xmlns:xi="http://www.w3.org/2001/XInclude">
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates/>
      </section3>
   </xsl:template>
   <xsl:template match="section5">
      <section4 xmlns:xi="http://www.w3.org/2001/XInclude">
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates/>
      </section4>
   </xsl:template>
   <xsl:template match="section6">
      <section5 xmlns:xi="http://www.w3.org/2001/XInclude">
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates/>
      </section5>
   </xsl:template>
   <xsl:template match="processing-instruction('xxe-sn')">
      <!-- remove -->
   </xsl:template>
   <xsl:template match="processing-instruction('xxe-revisions')">
      <!-- remove -->
   </xsl:template>
   <xsl:template match="@*|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>
