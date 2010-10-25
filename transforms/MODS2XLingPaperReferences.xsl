<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:m="http://www.loc.gov/mods/v3">
    <xsl:output encoding="UTF-8" indent="no" method="xml" doctype-system="XLingPap" doctype-public="-//XMLmind//DTD XLingPap//EN"/>
    <xsl:include href="MODS2XLingPaperReferencesCommon.xsl"/>
    <xsl:variable name="sAllCaps" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="sAllLowers" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <!-- 
        A transform to convert (Zotero) MODS format to XLingPaper references pass 1 of 2
    -->
    <xsl:template match="/m:modsCollection">
        <references>
            <xsl:apply-templates>
                <xsl:sort lang="en" select="concat(m:name[1][m:role/m:roleTerm='aut']/m:namePart[@type='family'], ' ', m:name[1][m:role/m:roleTerm='aut']/m:namePart[@type='given'], m:name[2][m:role/m:roleTerm='aut']/m:namePart[@type='family'], ' ', m:name[2][m:role/m:roleTerm='aut']/m:namePart[@type='given'], m:name[3][m:role/m:roleTerm='aut']/m:namePart[@type='family'], ' ', m:name[3][m:role/m:roleTerm='aut']/m:namePart[@type='given'], m:name[4][m:role/m:roleTerm='aut']/m:namePart[@type='family'], ' ', m:name[4][m:role/m:roleTerm='aut']/m:namePart[@type='given'], m:name[5][m:role/m:roleTerm='aut']/m:namePart[@type='family'], ' ', m:name[5][m:role/m:roleTerm='aut']/m:namePart[@type='given'], m:name[6][m:role/m:roleTerm='aut']/m:namePart[@type='family'], ' ', m:name[6][m:role/m:roleTerm='aut']/m:namePart[@type='given'])"/>
            </xsl:apply-templates>
        </references>
    </xsl:template>
    <!-- 
        mods
    -->
    <xsl:template match="m:mods">
        <refAuthor>
            <xsl:attribute name="name">
                <xsl:variable name="sAuthorName">
                    <xsl:call-template name="GetAuthorsNames"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$sAuthorName != ', '">
                        <xsl:value-of select="$sAuthorName"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$sMissingAuthorsMessage"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="citename">
                <xsl:variable name="sCiteName">
                    <xsl:call-template name="GetCiteName"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="string-length($sCiteName) &gt; 0">
                        <xsl:value-of select="$sCiteName"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$sMissingAuthorsMessage"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <refWork id="r{generate-id()}">
                <xsl:apply-templates/>
            </refWork>
        </refAuthor>
    </xsl:template>
    <!-- 
        book
    -->
    <xsl:template match="m:genre[@authority='local' and string(.)='book']">
        <xsl:call-template name="DoDateAndTitle"/>
        <book>
            <xsl:call-template name="DoLocationAndPublisher"/>
        </book>
        <xsl:call-template name="DoAnyURL"/>
    </xsl:template>
    <!-- 
        bookSection
    -->
    <xsl:template match="m:genre[@authority='local' and string(.)='bookSection']">
        <xsl:call-template name="DoDateAndTitle"/>
        <xsl:variable name="sHostTitle" select="../m:relatedItem[@type='host']/m:titleInfo/m:title"/>
        <xsl:variable name="bIsProceedings">
            <xsl:call-template name="GetIsProceedings">
                <xsl:with-param name="sHostTitle" select="$sHostTitle"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$bIsProceedings='Y'">
                <proceedings>
                    <xsl:call-template name="DoEditors">
                        <xsl:with-param name="sElementPrefix" select="'proc'"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoTitleVolumePages">
                        <xsl:with-param name="sHostTitle" select="$sHostTitle"/>
                        <xsl:with-param name="sElementPrefix" select="'proc'"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoLocationAndPublisher">
                        <xsl:with-param name="sLocation" select="../m:relatedItem[@type='host']/m:originInfo/m:place/m:placeTerm"/>
                        <xsl:with-param name="sPublisher" select="../m:relatedItem[@type='host']/m:originInfo/m:publisher"/>
                    </xsl:call-template>
                </proceedings>
            </xsl:when>
            <xsl:otherwise>
                <collection>
                    <xsl:call-template name="DoEditors"/>
                    <xsl:call-template name="DoTitleVolumePages">
                        <xsl:with-param name="sHostTitle" select="$sHostTitle"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoLocationAndPublisher">
                        <xsl:with-param name="sLocation" select="../m:relatedItem[@type='host']/m:originInfo/m:place/m:placeTerm"/>
                        <xsl:with-param name="sPublisher" select="../m:relatedItem[@type='host']/m:originInfo/m:publisher"/>
                    </xsl:call-template>
                </collection>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        journalArticle
    -->
    <xsl:template match="m:genre[@authority='local' and string(.)='journalArticle']">
        <xsl:call-template name="DoDateAndTitle"/>
        <article>
            <jTitle>
                <xsl:variable name="sJournalTitle" select="../m:relatedItem[@type='host']/m:titleInfo/m:title"/>
                <xsl:choose>
                    <xsl:when test="string-length($sJournalTitle) &gt; 0">
                        <xsl:value-of select="$sJournalTitle"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>**No Journal Title**</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </jTitle>
            <jVol>
                <xsl:variable name="sVolume" select="../m:relatedItem[@type='host']/m:part/m:detail[@type='volume']/m:number"/>
                <xsl:choose>
                    <xsl:when test="string-length($sVolume) &gt; 0">
                        <xsl:value-of select="$sVolume"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>**No Volume Number**</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </jVol>
            <xsl:variable name="issue" select="../m:relatedItem[@type='host']/m:part/m:detail[@type='issue']/m:number"/>
            <xsl:if test="string-length($issue) &gt; 0">
                <jIssueNumber>
                    <xsl:value-of select="$issue"/>
                </jIssueNumber>
            </xsl:if>
            <xsl:variable name="pages" select="../m:relatedItem[@type='host']/m:part/m:extent[@unit='pages']"/>
            <xsl:if test="$pages">
                <jPages>
                    <xsl:value-of select="$pages/start"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="$pages/end"/>
                </jPages>
            </xsl:if>
            <!-- location and publisher go here,if such exist -->
        </article>
        <xsl:call-template name="DoAnyURL"/>
    </xsl:template>
    <!-- 
        conferencePaper
    -->
    <xsl:template match="m:genre[@authority='local' and string(.)='conferencePaper']">
        <xsl:call-template name="DoDateAndTitle"/>
        <xsl:variable name="sHostTitle" select="../m:relatedItem/m:titleInfo/m:title"/>
        <xsl:variable name="bIsProceedings">
            <xsl:call-template name="GetIsProceedings">
                <xsl:with-param name="sHostTitle" select="$sHostTitle"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$bIsProceedings='Y'">
                <proceedings>
                    <!-- procEd -->
                    <xsl:call-template name="DoTitleVolumePages">
                        <xsl:with-param name="sHostTitle" select="$sHostTitle"/>
                        <xsl:with-param name="sElementPrefix" select="'proc'"/>
                    </xsl:call-template>
                    <xsl:call-template name="DoLocationAndPublisher">
                        <xsl:with-param name="sLocation" select="../m:relatedItem[@type='host']/m:originInfo/m:place/m:placeTerm"/>
                        <xsl:with-param name="sPublisher" select="../m:relatedItem[@type='host']/m:originInfo/m:publisher"/>
                    </xsl:call-template>
                </proceedings>
            </xsl:when>
            <xsl:otherwise>
                <paper>
                    <conference>
                        <xsl:value-of select="../m:relatedItem/m:titleInfo/m:title"/>
                    </conference>
                    <xsl:call-template name="DoLocationAndPublisher">
                        <xsl:with-param name="sLocation" select="../m:relatedItem[@type='host']/m:originInfo/m:place/m:placeTerm"/>
                        <xsl:with-param name="sPublisher" select="../m:relatedItem[@type='host']/m:originInfo/m:publisher"/>
                    </xsl:call-template>
                </paper>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        thesis
    -->
    <xsl:template match="m:genre[@authority='local' and string(.)='thesis']">
        <xsl:call-template name="DoDateAndTitle">
            <xsl:with-param name="mydate" select="../m:originInfo/m:dateCreated"/>
        </xsl:call-template>
        <dissertation>
            <institution>
                <xsl:value-of select="../m:originInfo/m:publisher"/>
            </institution>
        </dissertation>
        <xsl:call-template name="DoAnyURL"/>
    </xsl:template>
    <!-- 
        manuscript
    -->
    <xsl:template match="m:genre[@authority='local' and string(.)='manuscript']">
        <xsl:call-template name="DoDateAndTitle">
            <xsl:with-param name="mydate" select="../m:originInfo/m:dateCreated"/>
        </xsl:call-template>
        <ms>
            <institution>
                <xsl:text>**No Institution**</xsl:text>
            </institution>
        </ms>
    </xsl:template>
    <!-- 
        webpage
    -->
    <xsl:template match="m:genre[@authority='local' and string(.)='webpage']">
        <xsl:call-template name="DoDateAndTitle">
            <xsl:with-param name="mydate" select="../m:originInfo/m:dateCreated"/>
        </xsl:call-template>
        <webPage>
            <xsl:call-template name="DoAnyURL"/>
        </webPage>
    </xsl:template>
    <!-- 
        ignore these
    -->
    <xsl:template match="m:titleInfo | m:typeOfResource | m:genre | m:name | m:originInfo | m:location | m:subject | m:relatedItem | m:part | m:identifier | m:abstract | m:accessCondition"/>
    <!-- 
        DoAnyURL
    -->
    <xsl:template name="DoAnyURL">
        <xsl:variable name="sURL" select="../m:location/m:url"/>
        <xsl:if test="string-length($sURL) &gt; 0 and not(contains(translate($sURL,$sAllCaps,$sAllLowers), 'myilibrary'))">
            <url>
                <xsl:value-of select="$sURL"/>
            </url>
        </xsl:if>
        <xsl:variable name="accessed" select="../m:originInfo/m:dateCaptured"/>
        <xsl:if test="string-length($accessed) &gt; 0">
            <dateAccessed>
                <xsl:value-of select="$accessed"/>
            </dateAccessed>
        </xsl:if>
    </xsl:template>
    <!-- 
        DoDateAndTitle
    -->
    <xsl:template name="DoDateAndTitle">
        <xsl:param name="mydate" select="../m:originInfo/m:copyrightDate"/>
        <refDate>
            <xsl:choose>
                <xsl:when test="string-length($mydate) &gt; 0">
                    <xsl:value-of select="$mydate"/>
                </xsl:when>
                <xsl:when test="string-length(../m:originInfo/m:issueDate) &gt; 0">
                    <xsl:value-of select="../m:originInfo/m:issueDate"/>
                </xsl:when>
                <xsl:when test="string-length(../m:relatedItem/m:originInfo/m:dateIssued) &gt; 0">
                    <xsl:value-of select="../m:relatedItem/m:originInfo/m:dateIssued"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>**No Date**</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </refDate>
        <refTitle>
            <xsl:value-of select="../m:titleInfo/m:title"/>
        </refTitle>
    </xsl:template>
    <!-- 
        DoEditors
    -->
    <xsl:template name="DoEditors">
        <xsl:param name="sElementPrefix" select="'coll'"/>
        <xsl:variable name="sEditors">
            <xsl:for-each select="..">
                <xsl:call-template name="GetEditorsNames">
                    <xsl:with-param name="sKind" select="'edt'"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="string-length($sEditors) &gt; 0">
            <xsl:element name="{$sElementPrefix}Ed">
                <xsl:attribute name="plural">
                    <xsl:choose>
                        <xsl:when test="count(../m:name[m:role/m:roleTerm='edt']) &gt; 1">
                            <xsl:text>yes</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>no</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="$sEditors"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <!-- 
        DoLocationAndPublisher
    -->
    <xsl:template name="DoLocationAndPublisher">
        <xsl:param name="sLocation" select="../m:originInfo/m:place/m:placeTerm"/>
        <xsl:param name="sPublisher" select="../m:originInfo/m:publisher"/>
        <xsl:if test="string-length($sLocation) &gt; 0">
            <location>
                <xsl:value-of select="$sLocation"/>
            </location>
        </xsl:if>
        <xsl:if test="string-length($sPublisher) &gt; 0">
            <publisher>
                <xsl:value-of select="$sPublisher"/>
            </publisher>
        </xsl:if>
    </xsl:template>
    <!-- 
        DoTitleVolumePages
    -->
    <xsl:template name="DoTitleVolumePages">
        <xsl:param name="sHostTitle"/>
        <xsl:param name="sElementPrefix" select="'coll'"/>
        <xsl:param name="sVolume" select="../m:relatedItem[@type='series']/m:titleInfo/m:partNumber"/>
        <xsl:param name="pages" select="../m:relatedItem[@type='host']/m:part/m:extent[@unit='pages']"/>
        <xsl:element name="{$sElementPrefix}Title">
            <xsl:choose>
                <xsl:when test="string-length($sHostTitle) &gt; 0">
                    <xsl:value-of select="$sHostTitle"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>**No Title**</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        <xsl:if test="string-length($sVolume) &gt; 0">
            <xsl:element name="{$sElementPrefix}Vol">
                <xsl:value-of select="$sVolume"/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="$pages">
            <xsl:element name="{$sElementPrefix}Pages">
                <xsl:value-of select="$pages/start"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$pages/end"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <!-- 
        GetAuthorsNames
    -->
    <xsl:template name="GetAuthorsNames">
        <xsl:param name="sKind" select="'aut'"/>
        <xsl:value-of select="m:name[1][m:role/m:roleTerm=$sKind]/m:namePart[@type='family']"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="m:name[1][m:role/m:roleTerm=$sKind]/m:namePart[@type='given']"/>
        <xsl:for-each select="m:name[position() &gt; 1][m:role/m:roleTerm=$sKind]">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="m:namePart[@type='given']"/>
            <xsl:text>&#x20;</xsl:text>
            <xsl:value-of select="m:namePart[@type='family']"/>
        </xsl:for-each>
    </xsl:template>
    <!-- 
        GetCiteName
    -->
    <xsl:template name="GetCiteName">
        <xsl:for-each select="m:name[m:role/m:roleTerm='aut'][m:namePart/@type='family']">
            <xsl:choose>
                <xsl:when test="position()=last() and count(preceding-sibling::m:name) &gt; 0">
                    <xsl:text> and </xsl:text>
                </xsl:when>
                <xsl:when test="count(preceding-sibling::m:name) &gt; 0">
                    <xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:value-of select="m:namePart"/>
        </xsl:for-each>
    </xsl:template>
    <!-- 
        GetEditorsNames
    -->
    <xsl:template name="GetEditorsNames">
        <xsl:param name="sKind" select="'edt'"/>
        <xsl:for-each select="m:name[m:role/m:roleTerm=$sKind]">
            <xsl:choose>
                <xsl:when test="position()=last() and count(preceding-sibling::m:name[m:role/m:roleTerm=$sKind]) &gt; 0">
                    <xsl:text> and </xsl:text>
                </xsl:when>
                <xsl:when test="count(preceding-sibling::m:name[m:role/m:roleTerm=$sKind]) &gt; 0">
                    <xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:value-of select="m:namePart[@type='given']"/>
            <xsl:text>&#x20;</xsl:text>
            <xsl:value-of select="m:namePart[@type='family']"/>
        </xsl:for-each>
    </xsl:template>
    <!-- 
        GetIsProceedings
    -->
    <xsl:template name="GetIsProceedings">
        <xsl:param name="sHostTitle"/>
        <xsl:choose>
            <xsl:when test="contains(translate($sHostTitle, $sAllCaps, $sAllLowers), 'proceedings')">
                <xsl:text>Y</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>N</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
