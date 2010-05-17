<?xml version="1.0" encoding="UTF-8"?>
<!-- transform to produce handout from XLingPaper file
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
   <!-- 
   Main copy template
   -->
   <xsl:template match="@* |  node()">
      <xsl:copy>
         <xsl:apply-templates select="@*"/>
         <xsl:apply-templates />
      </xsl:copy>
   </xsl:template>
   <!-- 
      For sections, just copy the title and examples
   -->
   <xsl:template match=" //section1 | //section2 | //section3 | //section4 | //section5 | //section6">
      <xsl:copy>
         <xsl:apply-templates select="@*"/>
<!--      <xsl:copy-of select="secTitle"/>-->
<!--         <xsl:copy-of select="example"/>-->
         <xsl:apply-templates />
      </xsl:copy>
   </xsl:template>
   <!-- 
      elements to not copy
      the first set is from the front matter
      the second set is from the back matter
   -->
<!--   <xsl:template match="secTitle | example"/>-->
   <xsl:template match="p | acknowledgements | contents | preface | authorContactInfo | abstract"/>
   <xsl:template match="appendix | glossary | index"></xsl:template>
</xsl:stylesheet>
