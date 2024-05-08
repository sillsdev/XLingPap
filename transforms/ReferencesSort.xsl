<?xml version="1.0" encoding="UTF-8"?>
<!-- based on Kent Rasumussen's work at https://kent.atoznback.org/scripts-and-stuff/ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:preserve-space elements="*"/>
  <xsl:output encoding="UTF-8" indent="no" method="xml" doctype-system="XLingPap.dtd" doctype-public="-//XMLmind//DTD XLingPap//EN"/>
  <xsl:param name="useUnifiedStyleSheet" select="'N'"/>

  <xsl:template match="/references">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="$useUnifiedStyleSheet='Y'">
          <xsl:apply-templates select="refAuthor">
            <!-- sort without initial "van (der)", "dela", "del" and "de" in author names, to follow Unified style sheet for linguistics -->
            <xsl:sort
              select="concat(substring-after(concat('#^',@name), '#^van der '),substring-after(concat('#^',@name), '#^van '),substring-after(concat('#^',@name), '#^dela '),substring-after(concat('#^',@name), '#^del '),substring-after(concat('#^',@name), '#^de '),@name)"
              data-type="text"/>
          </xsl:apply-templates>
          <xsl:apply-templates select="annotatedBibliographyTypes"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="refAuthor">
            <!-- sort without initial "van (der)", "dela", "del" and "de" in author names, to follow Unified style sheet for linguistics -->
            <xsl:sort select="@name" data-type="text"/>
          </xsl:apply-templates>
          <xsl:apply-templates select="annotatedBibliographyTypes"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="refAuthor">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!-- convert " and " to " & " within author citenames, to follow Unified style sheet for linguistics -->
      <xsl:if test="$useUnifiedStyleSheet='Y' and contains(@citename, ' and ')">
        <xsl:attribute name="citename">
          <xsl:value-of select="concat(substring-before(@citename, ' and '),' &amp; ',substring-after(@citename, ' and '))"/>
        </xsl:attribute>
      </xsl:if>
      <!-- convert " & " to " and " within author names, to follow Unified style sheet for linguistics -->
      <xsl:if test="$useUnifiedStyleSheet='Y' and contains(@name, ' &amp; ')">
        <xsl:attribute name="name">
          <xsl:value-of select="concat(substring-before(@name, ' &amp; '),' and ',substring-after(@name, ' &amp; '))"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="refWork">
        <!-- sort works by date for each author, at least implied by Unified style sheet for linguistics -->
        <xsl:sort select="refDate" data-type="number"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="refWork">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
