<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"><xsl:preserve-space  elements="*"/>
    <xsl:output encoding="UTF-8" indent="no" method="xml" doctype-system="XLingPap.dtd" doctype-public="-//XMLmind//DTD XLingPap//EN"/>
<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" /> 
<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
<xsl:variable name="delimiter" select="string('|')"/> 
<!--references
refAuthor - @citename
refWork - refDate
-->
<xsl:template match="/references">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates select="refAuthor">
<!-- sort without initial "van (der)", "dela", "del" and "de" in author names, to follow Unified style sheet for linguistics -->
	<xsl:sort lang="en" select="concat(substring-after(concat('#^',@name), '#^van der '),substring-after(concat('#^',@name), '#^van '),substring-after(concat('#^',@name), '#^dela '),substring-after(concat('#^',@name), '#^del '),substring-after(concat('#^',@name), '#^de '),@name)" data-type="text"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="annotatedBibliographyTypes"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="refAuthor">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
<!-- convert " and " to " & " within author citenames, to follow Unified style sheet for linguistics -->
	<xsl:if test="contains(@citename, ' and ')">
		<xsl:attribute name="citename"><xsl:value-of select="concat(substring-before(@citename, ' and '),' &amp; ',substring-after(@citename, ' and '))"/>
		</xsl:attribute>
	</xsl:if>
<!-- convert " & " to " and " within author names, to follow Unified style sheet for linguistics -->
	<xsl:if test="contains(@name, ' &amp; ')">
		<xsl:attribute name="name"><xsl:value-of select="concat(substring-before(@name, ' &amp; '),' and ',substring-after(@name, ' &amp; '))"/>
		</xsl:attribute>
	</xsl:if>
	<xsl:apply-templates select="refWork">
<!-- sort works by date for each author, at least implied by Unified style sheet for linguistics -->
		<xsl:sort lang="en" select="refDate" data-type="number"/>
    	</xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<xsl:template match="refWork">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
<!--This is to convert from an old comment format, from before annotation nodes were brought into XLP
	<xsl:if test="comment[not(@type='keyword')]">
<annotations>
	<xsl:for-each select="comment[@type='value']">
		<annotation id="an{../@id}{@type}{position()}" annotype="atValue"><xsl:value-of select="."/></annotation>
	</xsl:for-each>
	<xsl:for-each select="comment[@type='abstract']">
		<annotation id="an{../@id}{@type}{position()}" annotype="atAbstract"><xsl:value-of select="."/></annotation>
	</xsl:for-each>
	<xsl:for-each select="comment[@type='evaluation']">
		<annotation id="an{../@id}{@type}{position()}" annotype="atEvaluation"><xsl:value-of select="."/></annotation>
	</xsl:for-each>
	<xsl:for-each select="comment[not(@type)]">
		<annotation id="an{../@id}{@type}{position()}" annotype="atComment"><xsl:value-of select="."/></annotation>
	</xsl:for-each>
	<xsl:for-each select="comment[@type='note']">
		<annotation id="an{../@id}{@type}{position()}" annotype="atNote"><xsl:value-of select="."/></annotation>
	</xsl:for-each>
</annotations>
	</xsl:if>
	<xsl:if test="comment[@type='keyword']">
<keywords>
	<xsl:for-each select="comment[@type='keyword']">
		<keyword><xsl:value-of select="."/></keyword>
	</xsl:for-each>
</keywords>
	</xsl:if>
-->
  </xsl:copy>
</xsl:template>

<!--This is to convert from an old comment format, from before annotation nodes were brought into XLP
<xsl:template match="comment[@type='abstract']"/>
<xsl:template match="comment[@type='note']"/>
<xsl:template match="comment[@type='keyword']"/>
<xsl:template match="comment[@type='value']"/>
<xsl:template match="comment[@type='evaluation']"/>
<xsl:template match="comment[not(@type)]"/>
-->

<xsl:template match="*">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>
</xsl:stylesheet>
