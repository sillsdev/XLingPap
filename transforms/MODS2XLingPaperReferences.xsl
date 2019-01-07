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
                <xsl:sort lang="en"
                    select="concat(m:name[1][m:role/m:roleTerm='aut' or m:role/m:roleTerm='ctb']/m:namePart[@type='family'], ' ', m:name[1][m:role/m:roleTerm='aut']/m:namePart[@type='given'], m:name[2][m:role/m:roleTerm='aut']/m:namePart[@type='family'], ' ', m:name[2][m:role/m:roleTerm='aut']/m:namePart[@type='given'], m:name[3][m:role/m:roleTerm='aut']/m:namePart[@type='family'], ' ', m:name[3][m:role/m:roleTerm='aut']/m:namePart[@type='given'], m:name[4][m:role/m:roleTerm='aut']/m:namePart[@type='family'], ' ', m:name[4][m:role/m:roleTerm='aut']/m:namePart[@type='given'], m:name[5][m:role/m:roleTerm='aut']/m:namePart[@type='family'], ' ', m:name[5][m:role/m:roleTerm='aut']/m:namePart[@type='given'], m:name[6][m:role/m:roleTerm='aut']/m:namePart[@type='family'], ' ', m:name[6][m:role/m:roleTerm='aut']/m:namePart[@type='given'])"
                />
            </xsl:apply-templates>
        </references>
    </xsl:template>
    <!-- 
        mods
    -->
    <xsl:template match="m:mods">
        <refAuthor>
            <xsl:attribute name="name">
                <xsl:call-template name="DoAuthorName"/>
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
                        <xsl:variable name="sCiteName2">
                            <xsl:call-template name="GetCiteName">
                                <xsl:with-param name="sKind" select="'ctb'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="string-length($sCiteName2) &gt; 0">
                                <xsl:value-of select="$sCiteName2"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="sCiteName3">
                                    <xsl:call-template name="GetCiteName">
                                        <xsl:with-param name="sKind" select="'edt'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="string-length($sCiteName3) &gt; 0">
                                        <xsl:value-of select="$sCiteName3"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$sMissingAuthorsMessage"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <refWork>
                <xsl:attribute name="id">
                    <xsl:for-each select="m:genre[@authority='local']">
                        <xsl:call-template name="DoID"/>
                    </xsl:for-each>
                </xsl:attribute>
                <xsl:apply-templates/>
                <xsl:if test="m:abstract or m:note">
                    <annotations>
                        <xsl:for-each select="m:abstract">
                            <xsl:call-template name="abstract"/>
                        </xsl:for-each>
                        <xsl:for-each select="m:note">
                            <xsl:call-template name="note"/>
                        </xsl:for-each>
                    </annotations>
                </xsl:if>
                <xsl:if test="m:subject">
                    <keywords>
                        <xsl:for-each select="m:subject">
                            <keyword>
                                <xsl:value-of select="."/>
                            </keyword>
                        </xsl:for-each>
                    </keywords>
                </xsl:if>                
            </refWork>
        </refAuthor>
    </xsl:template>
    <!-- 
        book
    -->
    <xsl:template match="m:genre[@authority='local' and string(.)='book']">
        <xsl:call-template name="DoDateAndTitle"/>
        <book>
            <xsl:variable name="sBookVolume" select="../m:part/m:detail[@type='volume']/m:number"/>
            <xsl:variable name="sSeriesTitle" select="../m:relatedItem[@type='series']/m:titleInfo/m:title"/>
            <xsl:variable name="sSeriesVol" select="../m:relatedItem[@type='series']/m:part/m:detail[@type='volume']/m:number"/>
            <xsl:if test="$sSeriesTitle">
                <xsl:variable name="sSeriesEd" select="../m:relatedItem[@type='series']/m:name[@type='personal']"/>
                <xsl:if test="$sSeriesEd">
                    <xsl:variable name="sEditors">
                        <xsl:for-each select="../m:relatedItem[@type='series']">
                            <xsl:call-template name="GetEditorsNames">
                                <xsl:with-param name="sKind" select="'pbd'"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="string-length($sEditors) &gt; 0">
                        <seriesEd>
                            <xsl:attribute name="plural">
                                <xsl:for-each select="../m:relatedItem[@type='series']">
                                    <xsl:choose>
                                    <xsl:when test="count(m:name[m:role/m:roleTerm='pbd']) &gt; 1">
                                        <xsl:text>yes</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>no</xsl:text>
                                    </xsl:otherwise>
                                    </xsl:choose>
                                    </xsl:for-each>
                            </xsl:attribute>
                            <xsl:value-of select="$sEditors"/>
                        </seriesEd>
                    </xsl:if>
                </xsl:if>
                <series>
                    <xsl:value-of select="$sSeriesTitle"/>
                    <xsl:if test="$sSeriesVol and $sBookVolume">
                        <xsl:text>&#x20;</xsl:text>
                        <xsl:value-of select="$sSeriesVol"/>
                    </xsl:if>
                </series>
            </xsl:if>
            <xsl:if test="$sBookVolume or $sSeriesVol">
                <bVol>
                    <xsl:choose>
                        <xsl:when test="$sBookVolume">
                            <xsl:value-of select="$sBookVolume"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$sSeriesVol"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </bVol>
            </xsl:if>
            <xsl:call-template name="DoLocationAndPublisher"/>
            <xsl:variable name="sBookTotalPages" select="../m:physicalDescription/m:extent[@unit='pages']/m:total"/>
            <xsl:if test="$sBookTotalPages">
                <bookTotalPages>
                    <xsl:value-of select="$sBookTotalPages"/>
                </bookTotalPages>
            </xsl:if>
            <xsl:call-template name="DoAnyURL"/>
        </book>
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
                    <xsl:value-of select="$pages/m:start"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="$pages/m:end"/>
                </jPages>
            </xsl:if>
            <!-- location and publisher go here,if such exist -->
            <xsl:call-template name="DoAnyURL"/>
        </article>
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
        <thesis>
            <institution>
                <xsl:value-of select="../m:originInfo/m:publisher"/>
            </institution>
            <xsl:call-template name="DoAnyURL"/>
        </thesis>
    </xsl:template>
    <!--
        dissertation
    -->
    <xsl:template match="m:genre[@authority='local' and string(.)='thesis'][following-sibling::*[name()='genre' and .='Ph.D Dissertation']]" priority="1">
        <xsl:call-template name="DoDateAndTitle">
            <xsl:with-param name="mydate" select="../m:originInfo/m:dateCreated"/>
        </xsl:call-template>
        <dissertation>
            <institution>
                <xsl:value-of select="../m:originInfo/m:publisher"/>
            </institution>
            <xsl:call-template name="DoAnyURL"/>
        </dissertation>
    </xsl:template>
    <!-- 
        manuscript
    -->
    <xsl:template match="m:genre[@authority='local'][string(.)='manuscript' or string(.)='document']">
        <xsl:call-template name="DoDateAndTitle">
            <xsl:with-param name="mydate" select="../m:originInfo/m:dateCreated"/>
        </xsl:call-template>
        <ms>
            <xsl:call-template name="DoLocationAndPublisher">
                <xsl:with-param name="sPublisher" select="''"/>
            </xsl:call-template>
            <institution>
                <xsl:text>**No Institution**</xsl:text>
            </institution>
            <xsl:call-template name="DoAnyURL"/>
        </ms>
    </xsl:template>
    <!-- 
        videoRecording (which we will treat as a book for now)
    -->
    <xsl:template match="m:genre[@authority='local'and not(../m:location/m:url)][string(.)='videoRecording' or string(.)='audioRecording']">
        <xsl:call-template name="DoDateAndTitle"/>
        <book>
            <xsl:call-template name="DoLocationAndPublisher"/>
            <xsl:variable name="sBookTotalPages" select="../m:physicalDescription/m:extent[@unit='pages']/m:total"/>
            <xsl:if test="$sBookTotalPages">
                <bookTotalPages>
                    <xsl:value-of select="$sBookTotalPages"/>
                </bookTotalPages>
            </xsl:if>
            <xsl:call-template name="DoAnyURL"/>
        </book>
    </xsl:template>
    <!-- 
        webpage
    -->
    <xsl:template match="m:genre[@authority='local'][string(.)='webpage' or string(.)='blogPost' or string(.)='videoRecording' or string(.)='audioRecording' and ../m:location/m:url]">
        <xsl:call-template name="DoDateAndTitle">
            <xsl:with-param name="mydate" select="../m:originInfo/m:dateCreated"/>
        </xsl:call-template>
        <webPage>
            <xsl:call-template name="DoAnyURL"/>
        </webPage>
    </xsl:template>
    <!--
        abstract
    -->
    <xsl:template name="abstract">
		<annotation annotype="atAbstract">
                <xsl:attribute name="id">
                    <xsl:call-template name="DoIDAnnotation"/>
		          <xsl:text>Abstract</xsl:text>
                </xsl:attribute>
			<xsl:value-of select="."/>
		</annotation>
    </xsl:template>
    <!--
        note
    -->
    <xsl:template name="note">
		<annotation annotype="atNote">
                <xsl:attribute name="id">
                    <xsl:call-template name="DoIDAnnotation"/>
		          <xsl:text>Note</xsl:text><xsl:value-of select="position()"/>
                </xsl:attribute>
			<xsl:value-of select="."/>
		</annotation>
    </xsl:template>
    <!--
        doi
    -->
    <xsl:template match="m:identifier[@type='doi']" mode="afterURLEtc">
        <doi>
            <xsl:value-of select="."/>
        </doi>
    </xsl:template>
    <!-- 
        ignore these
    -->
    <!--    <xsl:template match="m:titleInfo | m:typeOfResource | m:genre | m:name | m:originInfo | m:location | m:subject | m:relatedItem | m:part | m:identifier | m:abstract | m:accessCondition | m:language | m:physicalDescription | m:classification"/>-->

    <xsl:template match="m:abstract"/>
    <xsl:template match="m:accessCondition"/>
    <xsl:template match="m:classification"/>
    <xsl:template match="m:extension"/>
    <xsl:template match="m:genre"/>
    <xsl:template match="m:identifier"/>
    <xsl:template match="m:language"/>
    <xsl:template match="m:location"/>
    <xsl:template match="m:name"/>
    <xsl:template match="m:note"/>
    <xsl:template match="m:originInfo"/>
    <xsl:template match="m:part"/>
    <xsl:template match="m:physicalDescription"/>
    <xsl:template match="m:recordInfo"/>
    <xsl:template match="m:relatedItem"/>
    <xsl:template match="m:subject"/>
    <xsl:template match="m:tableOfContents"/>
    <xsl:template match="m:targetAudience"/>
    <xsl:template match="m:titleInfo"/>
    <xsl:template match="m:typeOfResource"/>
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
        <xsl:apply-templates select="../m:identifier[@type='doi']" mode="afterURLEtc"/>
    </xsl:template>
    <!-- 
        DoAuthor
    -->
    <xsl:template name="DoAuthor">
        <xsl:variable name="sAuthorName">
            <xsl:call-template name="GetAuthorsNames"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$sAuthorName != ', '">
                <xsl:value-of select="$sAuthorName"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="sContributorName">
                    <xsl:call-template name="GetAuthorsNames">
                        <xsl:with-param name="sKind" select="'ctb'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$sContributorName != ', '">
                        <xsl:value-of select="$sContributorName"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="sEditorName">
                            <xsl:call-template name="GetAuthorsNames">
                                <xsl:with-param name="sKind" select="'edt'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$sEditorName != ', '">
                                <xsl:value-of select="$sEditorName"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$sMissingAuthorsMessage"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        DoAuthorName
    -->
    <xsl:template name="DoAuthorName">
        <xsl:choose>
            <xsl:when test="name()='mods'">
                <xsl:call-template name="DoAuthor"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="..">
                    <xsl:call-template name="DoAuthor"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        DoDate
    -->
    <xsl:template name="DoDate">
        <xsl:param name="mydate" select="../m:originInfo/m:copyrightDate"/>
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
            <xsl:when test="string-length(../m:originInfo/m:dateCreated) &gt; 0">
                <xsl:value-of select="../m:originInfo/m:dateCreated"/>
            </xsl:when>
            <xsl:when test="string-length(../m:relatedItem[@type='host']/m:originInfo/m:copyrightDate) &gt; 0">
                <xsl:value-of select="../m:relatedItem[@type='host']/m:originInfo/m:copyrightDate"/>
            </xsl:when>
            <xsl:when test="string-length(../m:relatedItem[@type='host']/m:originInfo/m:dateCreated) &gt; 0">
                <xsl:value-of select="../m:relatedItem[@type='host']/m:originInfo/m:dateCreated"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>**No Date**</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        DoDateAndTitle
    -->
    <xsl:template name="DoDateAndTitle">
        <xsl:param name="mydate" select="../m:originInfo/m:copyrightDate"/>
        <refDate>
            <xsl:call-template name="DoDate">
                <xsl:with-param name="mydate" select="$mydate"/>
            </xsl:call-template>
        </refDate>
        <refTitle>
            <xsl:call-template name="DoTitle"/>
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
                        <xsl:when test="count(../m:name[m:role/m:roleTerm='edt'] | ../m:relatedItem[@type='host']/m:name[m:role/m:roleTerm='edt']) &gt; 1">
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
        DoID
    -->
    <xsl:template name="DoID">
        <xsl:text>r</xsl:text>
        <xsl:variable name="sName">
            <xsl:call-template name="DoAuthorName"/>
        </xsl:variable>
        <xsl:value-of select="translate($sName,$sRemoveForID,'')"/>
        <xsl:variable name="sDate">
            <xsl:call-template name="DoDate"/>
        </xsl:variable>
        <xsl:value-of select="translate($sDate,$sRemoveForID,'')"/>
        <xsl:variable name="sTitle">
            <xsl:call-template name="DoTitle"/>
        </xsl:variable>
        <xsl:value-of select="substring(translate($sTitle,$sRemoveForID,''),1,5)"/>
    </xsl:template>
    <!-- 
        DoIDAnnotation
    -->
    <xsl:template name="DoIDAnnotation">
        <xsl:text>an</xsl:text>
        <xsl:variable name="sName">
            <xsl:call-template name="DoAuthorName"/>
        </xsl:variable>
        <xsl:value-of select="translate($sName,$sRemoveForID,'')"/>
        <xsl:variable name="sDate">
            <xsl:call-template name="DoDate"/>
        </xsl:variable>
        <xsl:value-of select="translate($sDate,$sRemoveForID,'')"/>
        <xsl:variable name="sTitle">
            <xsl:call-template name="DoTitle"/>
        </xsl:variable>
        <xsl:value-of select="substring(translate($sTitle,$sRemoveForID,''),1,5)"/>
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
        DoTitle
    -->
    <xsl:template name="DoTitle">
        <xsl:value-of select="../m:titleInfo/m:title"/>
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
                <xsl:value-of select="$pages/m:start"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$pages/m:end"/>
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
        <xsl:param name="sKind" select="'aut'"/>
        <xsl:for-each select="m:name[m:role/m:roleTerm=$sKind][m:namePart/@type='family']">
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
        <xsl:for-each select="m:name[m:role/m:roleTerm=$sKind] | m:relatedItem[@type='host']/m:name[m:role/m:roleTerm=$sKind]">
            <xsl:choose>
                <xsl:when test="position()=last() and count(preceding-sibling::m:name[m:role/m:roleTerm=$sKind]) &gt; 0">
                    <xsl:text> and </xsl:text>
                </xsl:when>
                <xsl:when test="count(preceding-sibling::m:name[m:role/m:roleTerm=$sKind]) &gt; 0">
                    <xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="m:namePart/@type">
                    <xsl:value-of select="m:namePart[@type='given']"/>
                    <xsl:text>&#x20;</xsl:text>
                    <xsl:value-of select="m:namePart[@type='family']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="m:namePart"/>
                </xsl:otherwise>
            </xsl:choose>
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
