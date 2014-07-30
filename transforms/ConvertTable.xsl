<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:x="http://www.w3.org/1999/xhtml" exclude-result-prefixes="x">
 <xsl:output encoding="UTF-8" method="xml"/>

 <xsl:template match="/">
  <xsl:apply-templates/>
 </xsl:template>

 <xsl:template match="x:table">
  <table>
   <xsl:apply-templates select="@*"/>
   <xsl:apply-templates/>
  </table>
 </xsl:template>

 <xsl:template match="x:p[parent::x:td or parent::x:th]">
   <xsl:apply-templates/>
  </xsl:template>

 <xsl:template match="x:tbody[parent::x:table]">
  <xsl:apply-templates/>
 </xsl:template>
 
 <xsl:template match="x:thead[parent::x:table]">
  <xsl:apply-templates/>
 </xsl:template>
 
 <xsl:template match="x:tfoot[parent::x:table]">
  <xsl:apply-templates/>
 </xsl:template>
 
 <xsl:template match="x:tr">
  <tr>
   <xsl:apply-templates select="@*"/>
   <xsl:apply-templates/>
  </tr>
 </xsl:template>
 
 <xsl:template match="x:th">
  <th>
   <xsl:apply-templates select="@*"/>
   <xsl:apply-templates/>
  </th>
 </xsl:template>

 <xsl:template match="x:td">
  <td>
   <xsl:apply-templates select="@*"/>
   <xsl:apply-templates/>
  </td>
 </xsl:template>

 <xsl:template match="@align[parent::x:table] | @align[parent::x:td] | @align[parent::x:th]">
  <xsl:copy-of select="."/>
 </xsl:template>

 <xsl:template match="@backgroundcolor[parent::x:table] | @backgroundcolor[parent::x:td] | @backgroundcolor[parent::x:tr] | @backgroundcolor[parent::x:th]">
  <xsl:copy-of select="."/>
 </xsl:template>

 <xsl:template match="@border[parent::x:table]">
  <xsl:copy-of select="."/>
 </xsl:template>

 <xsl:template match="@cellpadding[parent::x:table]">
  <xsl:copy-of select="."/>
 </xsl:template>

 <xsl:template match="@cellspacing[parent::x:table]">
  <xsl:copy-of select="."/>
 </xsl:template>

 <xsl:template match="@colspan[parent::x:td] | @colspan[parent::x:th]">
  <xsl:copy-of select="."/>
 </xsl:template>

 <xsl:template match="@direction[parent::x:tr] | @direction[parent::x:td] | @direction[parent::x:th]">
  <xsl:copy-of select="."/>
 </xsl:template>

 <xsl:template match="@rowspan[parent::x:td] | @rowspan[parent::x:th]">
  <xsl:copy-of select="."/>
 </xsl:template>

 <xsl:template match="@valign[parent::x:td] | @valign[parent::th]">
  <xsl:copy-of select="."/>
 </xsl:template>

 <xsl:template match="@width[parent::x:td] | @width[parent::x:th]">
  <xsl:variable name="sContent" select="normalize-space(.)"/>
  <xsl:variable name="iLen" select="string-length($sContent)"/>
  <xsl:if test="$iLen &gt; 1">
   <xsl:choose>
    <xsl:when test="substring($sContent, $iLen) = '%'">
     <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:when test="substring($sContent, $iLen - 1) = 'pt'">
     <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:when test="substring($sContent, $iLen -1) = 'in'">
     <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:when test="substring($sContent, $iLen -1) = 'cm'">
     <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:when test="substring($sContent, $iLen -1) = 'mm'">
     <xsl:copy-of select="."/>
    </xsl:when>
   </xsl:choose>
  </xsl:if>
 </xsl:template>

 <xsl:template match="@*"/>
<xsl:template match="x:p | x:div[not(descendant::x:table)]"/>
</xsl:stylesheet>
