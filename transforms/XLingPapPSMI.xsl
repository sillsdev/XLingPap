<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 psmi.xsl

 Interpret the Page Sequence Master Interleave formatting semantic described
 at http://www.CraneSoftwrights.com/resources/psmi for interleaving page
 geometries in XSLFO flows.

 $Id: psmi.xsl,v 1.6 2002/11/01 18:11:28 G. Ken Holman Exp $

This semantic, its stylesheet file, and the information contained herein is
provided on an "AS IS" basis and CRANE SOFTWRIGHTS LTD. DISCLAIMS
ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
ANY WARRANTY THAT THE USE OF THE INFORMATION HEREIN WILL NOT INFRINGE
ANY RIGHTS OR ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS 
FOR A PARTICULAR PURPOSE.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi" exclude-result-prefixes="psmi" version="1.0">
    <!--==========================================================================
  Handle a sequence of pages, only if it has the expected psmi:page-sequence
  children in the flow.
-->
    <xsl:template match="fo:page-sequence">
        <xsl:choose>
            <xsl:when test="fo:flow/psmi:page-sequence">
                <!--accommodate new semantic-->
                <xsl:if test="@force-page-count = 'even' or
                    @force-page-count = 'odd'">
                    <xsl:message>
                        <xsl:text>Unable to support a 'force-page-count=' </xsl:text>
                        <xsl:text>value of: </xsl:text>
                        <xsl:value-of select="@force-page-count"/>
                    </xsl:message>
                </xsl:if>
                <xsl:apply-templates select="fo:flow/*[1]" mode="psmi:do-flow-children"/>
            </xsl:when>
            <xsl:when test="descendant::psmi:*">
                <!--unexpected location for semantic-->
                <xsl:call-template name="psmi:preserve"/>
                <!-- this will catch each-->
            </xsl:when>
            <xsl:otherwise>
                <!--no need to do special processing; faster to just copy-->
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--==========================================================================
  Create a page sequence from the flow.
-->
    <xsl:template match="*" mode="psmi:do-flow-children">
        <xsl:param name="bUseFirstPage" select="'Y'"/>
        <xsl:param name="sChapterTitle"/>
        <xsl:param name="sSectionTitle"/>
        <fo:page-sequence>
            <!--page-sequence attributes-->
            <xsl:choose>
                <xsl:when test="$bUseFirstPage='N'">
                    <xsl:attribute name="master-reference">
                        <xsl:value-of select="../../@master-reference"/>
                        <xsl:text>Continuation</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="../../@*[not(name(.)='initial-page-number') and not(name(.)='master-reference')]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="../../@*[not(name(.)='initial-page-number')]"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="self::psmi:page-sequence">
                <xsl:copy-of select="@master-reference"/>
                <xsl:if test="@*[name(.)!='master-reference']">
                    <xsl:message>
                        <xsl:text>Only the 'master-reference=' attribute is </xsl:text>
                        <xsl:text>allowed for </xsl:text>
                        <xsl:call-template name="psmi:name-this"/>
                    </xsl:message>
                </xsl:if>
            </xsl:if>
            <!--only preserve specified initial-page-number= on first page sequence-->
            <xsl:if test="not(preceding-sibling::*)">
                <xsl:copy-of select="../../@initial-page-number"/>
            </xsl:if>
            <!--only preserve specified force-page-count= on last page sequence-->
            <xsl:if test="following-sibling::psmi:page-sequence or
                 self::psmi:page-sequence/following-sibling::*">
                <!--not last-->
                <xsl:attribute name="force-page-count">no-force</xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="self::psmi:page-sequence">
                    <!--psmi:page-sequence title has precedence-->
                    <xsl:copy-of select="(../../fo:title|fo:title)[last()]"/>
                    <!--psmi:page-sequence static-content has precedence-->
                    <xsl:copy-of select="fo:static-content"/>
                    <!--get other static-content not already in psmi:page-sequence-->
                    <xsl:variable name="static-content-flow-names" select="fo:static-content/@flow-name"/>
                    <xsl:for-each select="../../fo:static-content">
                        <xsl:if test="not( @flow-name = $static-content-flow-names )">
                            <xsl:copy-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                    <!--do the psmi:page-sequence flow-->
                    <fo:flow>
                        <xsl:if test="not(fo:flow)">
                            <xsl:message>
                                <xsl:call-template name="psmi:name-this"/>
                                <xsl:text> requires a </xsl:text>
                                <xsl:text>&lt;{http://www.w3.org/1999/XSL/Format}flow&gt;</xsl:text>
                                <xsl:text> child</xsl:text>
                            </xsl:message>
                        </xsl:if>
                        <xsl:for-each select="fo:flow">
                            <xsl:copy-of select="@*"/>
                            <xsl:if test="not(@flow-name)">
                                <xsl:message>
                                    <xsl:text>&lt;{http://www.w3.org/1999/XSL/Format}flow&gt;</xsl:text>
                                    <xsl:text> requires the "flow-name=" attribute.</xsl:text>
                                </xsl:message>
                            </xsl:if>
                            <!--all flow contents belong in sequence-->
                            <xsl:apply-templates select="*"/>
                        </xsl:for-each>
                    </fo:flow>
                </xsl:when>
                <xsl:otherwise>
                    <!--only following siblings up to psmi:page-sequence-->
                    <!--use all of the fo:page-sequence's non-flow children-->
                    <xsl:choose>
                        <xsl:when test="$bUseFirstPage='N'">
                            <xsl:copy-of select="../../fo:title|../../fo:static-content[not(contains(@flow-name,'FirstPage'))]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="../../fo:title|../../fo:static-content"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!--use all of the fo:page-sequence's flow attributes-->
                    <fo:flow>
                        <xsl:copy-of select="../@*"/>
                        <xsl:if test="$bUseFirstPage='N'">
                            <xsl:choose>
                                <xsl:when test="preceding-sibling::fo:marker[@marker-class-name='preface-title']">
                                    <fo:marker marker-class-name="preface-title">
                                        <xsl:value-of select="$sChapterTitle"/>
                                    </fo:marker>
                                </xsl:when>
                                <xsl:otherwise>
                                    <fo:marker marker-class-name="chap-title">
                                        <xsl:value-of select="$sChapterTitle"/>
                                    </fo:marker>
                                    <fo:marker marker-class-name="section-title">
                                        <xsl:value-of select="$sSectionTitle"/>
                                    </fo:marker>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                        <!--only use as much flow as up to the next psmi:page-sequence-->
                        <xsl:call-template name="copy-until-psmi"/>
                    </fo:flow>
                </xsl:otherwise>
            </xsl:choose>
        </fo:page-sequence>
        <!--move to the next need for a page sequence-->
        <xsl:choose>
            <xsl:when test="self::psmi:page-sequence">
                <xsl:apply-templates select="following-sibling::*[1]" mode="psmi:do-flow-children">
                    <xsl:with-param name="bUseFirstPage" select="'N'"/>
                    <xsl:with-param name="sChapterTitle" select="fo:flow/fo:marker[@marker-class-name='chap-title'][last()] | fo:flow/fo:marker[@marker-class-name='preface-title'][last()]"/>
                    <xsl:with-param name="sSectionTitle" select="fo:flow/fo:marker[@marker-class-name='section-title'][last()]"/>
                </xsl:apply-templates>
            </xsl:when>
            <!--      <xsl:when test="preceding-sibling::*[1][name()='psmi:page-sequence']">
          <xsl:if test="$bUseFirstPage='Y'">
          <xsl:apply-templates select="."
              mode="psmi:do-flow-children">
              <xsl:with-param name="bUseFirstPage" select="'N'"/>
          </xsl:apply-templates>
          </xsl:if>
      </xsl:when>
-->
            <xsl:otherwise>
                <xsl:apply-templates select="following-sibling::psmi:page-sequence[1]" mode="psmi:do-flow-children"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="copy-until-psmi" mode="copy-until-psmi" match="*">
        <xsl:if test="not(self::psmi:page-sequence)">
            <xsl:call-template name="psmi:preserve"/>
            <!--copy this element-->
            <xsl:apply-templates select="following-sibling::*[1]" mode="copy-until-psmi"/>
        </xsl:if>
    </xsl:template>
    <!--==========================================================================
  Handle the new semantic when found in the wrong context by reporting error.
-->
    <xsl:template match="psmi:page-sequence" name="unexpected-psmi">
        <xsl:message terminate="yes">
            <xsl:text>Unexpected parent </xsl:text>
            <xsl:for-each select="..">
                <xsl:call-template name="psmi:name-this"/>
            </xsl:for-each>
            <xsl:text> for </xsl:text>
            <xsl:call-template name="psmi:name-this"/>
        </xsl:message>
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <!--==========================================================================
  Default handlers for other constructs.
-->
    <xsl:template match="psmi:*">
        <!--no other PSMI construct is defined-->
        <xsl:message>
            <xsl:text>Unrecognized construct ignored: </xsl:text>
            <xsl:call-template name="psmi:name-this"/>
        </xsl:message>
    </xsl:template>
    <xsl:template match="*" name="psmi:preserve">
        <!--other constructs preserved-->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template name="psmi:name-this">
        <xsl:value-of disable-output-escaping="yes" select="concat('&lt;{',namespace-uri(),'}',local-name(),'&gt;')"/>
    </xsl:template>
</xsl:stylesheet>
