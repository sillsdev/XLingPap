<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" doctype-system="XLingPap" doctype-public="-//XMLmind//DTD XLingPap//EN"/>
    <xsl:include href="MODS2XLingPaperReferencesCommon.xsl"/>
    <!-- 
        A transform to convert Endnote XML format to XLingPaper references pass 1 of 2
    -->
    <xsl:template match="//records">
        <references>
            <xsl:for-each
                select="record[ref-type[@name='Audiovisual Material' or @name='Book' or @name='Dictionary' or @name='Book Section' or @name='Conference Paper' or @name='Conference Proceedings' or @name='Edited Book' or @name='Electronic Article' or @name='Government Document' or @name='Journal Article' or @name='Manuscript' or @name='Online Multimedia' or @name='Report' or @name='Standard' or @name='Thesis' or @name='Unpublished Work' or @name='Web Page' or @name='Electronic Book' or @name='Artwork' or @name='Computer Program' or @name='Electronic Book Section' or @name='Grant' or @name='Newspaper Article']]">
                <xsl:sort lang="en"
                    select="concat(contributors/authors/author[1],contributors/authors/author[2],contributors/authors/author[3],contributors/authors/author[4],contributors/authors/author[5],contributors/authors/author[6],contributors/authors/author[7],contributors/authors/author[8],contributors/authors/author[9],contributors/authors/author[10])"/>
                <xsl:sort select="dates/year"/>
                <refAuthor>
                    <xsl:call-template name="DoAuthorItems"/>
                    <refWork>
                        <xsl:attribute name="id">
                            <xsl:call-template name="DoID"/>
                        </xsl:attribute>
                        <xsl:call-template name="DoAuthorRole"/>
                        <xsl:apply-templates select="dates"/>
                        <xsl:call-template name="DoRefTitle"/>
                        <xsl:apply-templates select="ref-type"/>
                    </refWork>
                </refAuthor>
            </xsl:for-each>
        </references>
    </xsl:template>
    <!-- 
        dates
    -->
    <xsl:template match="dates">
        <refDate>
            <xsl:call-template name="DoDate"/>
        </refDate>
    </xsl:template>
    <!-- 
        access-date
    -->
    <xsl:template match="access-date">
        <dateAccessed>
            <xsl:value-of select="normalize-space(year)"/>
        </dateAccessed>
    </xsl:template>
    <!-- 
        custom7 (Hugh Patterson III uses this for iso codes
    -->
    <xsl:template match="custom7">
        <xsl:call-template name="GetISOCodes">
            <xsl:with-param name="sCodes">
                <xsl:value-of select="."/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- 
        electronic-resource-num (DOI)
    -->
    <xsl:template match="electronic-resource-num">
        <doi>
            <xsl:value-of select="."/>
        </doi>
    </xsl:template>
    <!-- 
        publisher
    -->
    <xsl:template match="publisher">
        <publisher>
            <xsl:value-of select="normalize-space(.)"/>
        </publisher>
    </xsl:template>
    <!-- 
        pub-location
    -->
    <xsl:template match="pub-location">
        <location>
            <xsl:value-of select="normalize-space(.)"/>
        </location>
    </xsl:template>
    <!-- 
        ref-type default
    -->
    <xsl:template match="ref-type">
        <!-- ignore all others -->
    </xsl:template>
    <!--
        ref-type Artwork
    -->
    <xsl:template match="ref-type[@name='Artwork']">
        <xsl:call-template name="DoWebPage"/>
    </xsl:template>
    <!--
        ref-type Audiovisual Material
    -->
    <xsl:template match="ref-type[@name='Audiovisual Material']">
        <xsl:call-template name="DoBook"/>
    </xsl:template>
    <!-- 
        ref-type Book
    -->
    <xsl:template match="ref-type[@name='Book' or @name='Dictionary' or @name='Electronic Book' or @name='Computer Program' or @name='Grant']">
        <xsl:call-template name="DoBook"/>
    </xsl:template>
    <!-- 
        ref-type Book Section
    -->
    <xsl:template match="ref-type[@name='Book Section' or @name='Electronic Book Section']">
        <collection>
            <!--        ((((collEd, collEdInitials?)?, collTitle, collTitleLowerCase?, edition?, collVol?, collPages?, (seriesEd?, seriesEdInitials?, series)?, bVol?, location?, publisher?) | collCitation), url?, dateAccessed?, iso639-3code*, comment?)-->
            <xsl:if test="../contributors/secondary-authors">
                <collEd>
                    <xsl:for-each select="../contributors/secondary-authors">
                        <xsl:call-template name="GetAuthorsNames"/>
                    </xsl:for-each>
                </collEd>
            </xsl:if>
            <collTitle>
                <xsl:value-of select="normalize-space(../titles/secondary-title)"/>
            </collTitle>
            <xsl:if test="../edition">
                <edition>
                    <xsl:value-of select="normalize-space(../edition)"/>
                </edition>
            </xsl:if>
            <xsl:if test="../volume">
                <collVol>
                    <xsl:value-of select="normalize-space(../volume)"/>
                </collVol>
            </xsl:if>
            <xsl:if test="../pages">
                <collPages>
                    <xsl:value-of select="normalize-space(../pages)"/>
                </collPages>
            </xsl:if>
            <xsl:if test="../contributors/tertiary-authors">
                <seriesEd>
                    <xsl:for-each select="../contributors/tertiary-authors">
                        <xsl:call-template name="GetAuthorsNames"/>
                    </xsl:for-each>
                </seriesEd>
                <xsl:if test="not(../titles/tertiary-title)">
                    <series/>
                </xsl:if>
            </xsl:if>
            <xsl:if test="../titles/tertiary-title">
                <series>
                    <xsl:value-of select="normalize-space(../titles/tertiary-title)"/>
                </series>
            </xsl:if>
            <xsl:if test="../number">
                <bVol>
                    <xsl:value-of select="normalize-space(../number)"/>
                </bVol>
            </xsl:if>
            <xsl:apply-templates select="../pub-location"/>
            <xsl:apply-templates select="../publisher"/>
            <xsl:apply-templates select="../urls/related-urls"/>
            <xsl:apply-templates select="../dates/access-date"/>
            <xsl:apply-templates select="../electronic-resource-num"/>
            <xsl:apply-templates select="../custom7"/>
        </collection>
    </xsl:template>
    <!-- 
        ref-type Conference Paper
    -->
    <xsl:template match="ref-type[@name='Conference Paper']">
        <paper>
            <!-- (conference, location?, url?, dateAccessed?, iso639-3code*, comment?) -->
            <conference>
                <xsl:value-of select="normalize-space(../titles/secondary-title)"/>
            </conference>
            <xsl:apply-templates select="../pub-location"/>
            <xsl:apply-templates select="../urls/related-urls"/>
            <xsl:apply-templates select="../dates/access-date"/>
            <xsl:apply-templates select="../electronic-resource-num"/>
            <xsl:apply-templates select="../custom7"/>
        </paper>
    </xsl:template>
    <!-- 
        ref-type Conference Proceedings
    -->
    <xsl:template match="ref-type[@name='Conference Proceedings']">
        <proceedings>
            <!-- ((((procEd, procEdInitials?)?, procTitle, procTitleLowerCase?, procVol?, procPages?, location?, publisher?) | procCitation), url?, dateAccessed?, iso639-3code*, comment?) -->
            <xsl:if test="../contributors/secondary-authors">
                <procEd>
                    <xsl:for-each select="../contributors/secondary-authors">
                        <xsl:call-template name="GetAuthorsNames"/>
                    </xsl:for-each>
                </procEd>
            </xsl:if>
            <procTitle>
                <xsl:value-of select="normalize-space(../titles/secondary-title)"/>
            </procTitle>
            <xsl:if test="../volume">
                <procVol>
                    <xsl:value-of select="normalize-space(../volume)"/>
                </procVol>
            </xsl:if>
            <xsl:if test="../pages">
                <procPages>
                    <xsl:value-of select="normalize-space(../pages)"/>
                </procPages>
            </xsl:if>
            <xsl:apply-templates select="../pub-location"/>
            <xsl:apply-templates select="../publisher"/>
            <xsl:apply-templates select="../urls/related-urls"/>
            <xsl:apply-templates select="../dates/access-date"/>
            <xsl:apply-templates select="../electronic-resource-num"/>
            <xsl:apply-templates select="../custom7"/>
        </proceedings>
    </xsl:template>
    <!-- 
        ref-type Edited Book
    -->
    <xsl:template match="ref-type[@name='Edited Book']">
        <xsl:call-template name="DoBook"/>
    </xsl:template>
    <!-- 
        ref-type Electronic Article
    -->
    <xsl:template match="ref-type[@name='Electronic Article']">
        <xsl:call-template name="DoArticle"/>
    </xsl:template>
    <!-- 
        ref-type Government Document
    -->
    <xsl:template match="ref-type[@name='Government Document']">
        <!-- at least the one example I saw appeared to be a book element -->
        <xsl:call-template name="DoBook"/>
    </xsl:template>
    <!-- 
        ref-type Journal Article
    -->
    <xsl:template match="ref-type[@name='Journal Article']">
        <xsl:call-template name="DoArticle"/>
    </xsl:template>
    <!-- 
        ref-type Manuscript
    -->
    <xsl:template match="ref-type[@name='Manuscript']">
        <xsl:call-template name="DoMs"/>
    </xsl:template>
    <!--
        ref-type Newspaper Article
    -->
    <xsl:template match="ref-type[@name='Newspaper Article']">
        <xsl:call-template name="DoWebPage"/>
    </xsl:template>
    <!-- 
        ref-type Online Multimedia
    -->
    <xsl:template match="ref-type[@name='Online Multimedia']">
        <xsl:call-template name="DoWebPage"/>
    </xsl:template>
    <!-- 
        ref-type Report
    -->
    <xsl:template match="ref-type[@name='Report']">
        <xsl:call-template name="DoBook"/>
    </xsl:template>
    <!-- 
        ref-type Standard
    -->
    <xsl:template match="ref-type[@name='Standard']">
        <xsl:call-template name="DoBook"/>
    </xsl:template>
    <!-- 
        ref-type Thesis
    -->
    <xsl:template match="ref-type[@name='Thesis']">
        <xsl:choose>
            <xsl:when test="contains(../work-type,'Ph.D.') or contains(../volume,'Ph.D.')">
                <dissertation>
                    <xsl:call-template name="DoDissertationOrThesis"/>
                </dissertation>
            </xsl:when>
            <xsl:otherwise>
                <thesis>
                    <xsl:call-template name="DoDissertationOrThesis"/>
                </thesis>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        ref-type Unpublished Work
    -->
    <xsl:template match="ref-type[@name='Unpublished Work']">
        <xsl:call-template name="DoMs"/>
    </xsl:template>
    <!-- 
        ref-type Web Page
    -->
    <xsl:template match="ref-type[@name='Web Page']">
        <xsl:call-template name="DoWebPage"/>
    </xsl:template>
    <!-- 
        related-urls
    -->
    <xsl:template match="related-urls">
        <url>
            <xsl:value-of select="normalize-space(url)"/>
        </url>
    </xsl:template>
    <!-- 
        title
    -->
    <xsl:template match="title">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <!-- 
        DoArticle
    -->
    <xsl:template name="DoArticle">
        <article>
            <!-- (jTitle, jVol, jIssueNumber?, (jPages | jArticleNumber)?, location?, publisher?, url?, dateAccessed?, iso639-3code*, comment?)> -->
            <xsl:choose>
                <xsl:when test="../periodical">
                    <jTitle>
                        <xsl:value-of select="normalize-space(../periodical/full-title)"/>
                    </jTitle>
                    <jVol>
                        <xsl:value-of select="normalize-space(../volume)"/>
                    </jVol>
                    <xsl:if test="../number">
                        <jIssueNumber>
                            <xsl:value-of select="normalize-space(../number)"/>
                            <xsl:value-of select="normalize-space(../issue)"/>
                        </jIssueNumber>
                    </xsl:if>
                    <xsl:if test="../pages">
                        <jPages>
                            <xsl:value-of select="normalize-space(../pages)"/>
                        </jPages>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <jTitle>Unknown Journal Title</jTitle>
                    <jVol>Unkown Journal Volume</jVol>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="../pub-location"/>
            <xsl:apply-templates select="../publisher"/>
            <xsl:apply-templates select="../urls/related-urls"/>
            <xsl:apply-templates select="../dates/access-date"/>
            <xsl:apply-templates select="../electronic-resource-num"/>
            <xsl:apply-templates select="../custom7"/>
        </article>
    </xsl:template>
    <!-- 
        DoAuthorItems
    -->
    <xsl:template name="DoAuthorItems">
        <xsl:attribute name="name">
            <xsl:call-template name="DoAuthorName"/>
        </xsl:attribute>
        <xsl:attribute name="citename">
            <xsl:variable name="sCiteName">
                <xsl:call-template name="GetCiteName"/>
            </xsl:variable>
            <xsl:variable name="sNormalizedCiteName" select="normalize-space($sCiteName)"/>
            <xsl:choose>
                <xsl:when test="string-length($sNormalizedCiteName) &gt; 0">
                    <xsl:choose>
                        <xsl:when test="contains($sNormalizedCiteName,',')">
                            <xsl:value-of select="$sNormalizedCiteName"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="contains($sNormalizedCiteName,' ')">
                                    <xsl:call-template name="GetLastNameFirst">
                                        <xsl:with-param name="sName" select="$sNormalizedCiteName"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="GetNonLastNames">
                                        <xsl:with-param name="sName" select="$sNormalizedCiteName"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$sNormalizedCiteName"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$sMissingAuthorsMessage"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <!-- 
        DoAuthorName
    -->
    <xsl:template name="DoAuthorName">
        <xsl:variable name="sAuthorName">
            <xsl:for-each select="contributors/authors">
                <xsl:call-template name="GetAuthorsNames"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="sNormalizedAuthorName">
            <xsl:value-of select="normalize-space($sAuthorName)"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($sNormalizedAuthorName) &gt; 0 and $sAuthorName != ', '">
                <xsl:choose>
                    <xsl:when test="contains($sNormalizedAuthorName,',')">
                        <xsl:value-of select="$sNormalizedAuthorName"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="contains($sNormalizedAuthorName,' ')">
                                <xsl:call-template name="GetLastNameFirst">
                                    <xsl:with-param name="sName" select="$sNormalizedAuthorName"/>
                                </xsl:call-template>
                                <xsl:call-template name="GetNonLastNames">
                                    <xsl:with-param name="sName" select="$sNormalizedAuthorName"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$sNormalizedAuthorName"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sMissingAuthorsMessage"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        DoAuthorRole
    -->
    <xsl:template name="DoAuthorRole">
        <xsl:if test="ref-type[@name='Edited Book']">
            <authorRole>
                <xsl:text>Editor</xsl:text>
                <xsl:if test="count(contributors/authors/author) &gt; 1">
                    <xsl:text>s</xsl:text>
                </xsl:if>
            </authorRole>
        </xsl:if>
    </xsl:template>
    <!-- 
        DoBook
    -->
    <xsl:template name="DoBook">
        <book>
            <!-- translatedBy?, edition?, (seriesEd?, seriesEdInitials?, series)?, bVol?, location?, publisher?, bookTotalPages?, url?, dateAccessed?, iso639-3code*, comment? -->
            <xsl:if test="../contributors/translated-authors">
                <translatedBy>
                    <xsl:for-each select="../contributors/translated-authors">
                        <xsl:call-template name="GetAuthorsNames"/>
                    </xsl:for-each>
                </translatedBy>
            </xsl:if>
            <xsl:if test="../edition">
                <edition>
                    <xsl:value-of select="normalize-space(../edition)"/>
                </edition>
            </xsl:if>
            <xsl:if test="@name='Report' and ../number">
                <edition>
                    <xsl:value-of select="normalize-space(../number)"/>
                </edition>
            </xsl:if>
            <xsl:if test="../contributors/secondary-authors">
                <seriesEd>
                    <xsl:for-each select="../contributors/secondary-authors">
                        <xsl:call-template name="GetAuthorsNames"/>
                    </xsl:for-each>
                </seriesEd>
                <xsl:if test="not(../titles/secondary-title)">
                    <series/>
                </xsl:if>
            </xsl:if>
            <xsl:if test="../titles/secondary-title">
                <series>
                    <xsl:value-of select="normalize-space(../titles/secondary-title)"/>
                </series>
            </xsl:if>
            <xsl:if test="../volume">
                <bVol>
                    <xsl:value-of select="normalize-space(../volume)"/>
                </bVol>
            </xsl:if>
            <xsl:apply-templates select="../pub-location"/>
            <xsl:apply-templates select="../publisher"/>
            <xsl:apply-templates select="../urls/related-urls"/>
            <xsl:apply-templates select="../dates/access-date"/>
            <xsl:apply-templates select="../electronic-resource-num"/>
            <xsl:apply-templates select="../custom7"/>
        </book>
    </xsl:template>
    <!-- 
        DoDate
    -->
    <xsl:template name="DoDate">
        <xsl:choose>
            <xsl:when test="year">
                <xsl:value-of select="normalize-space(year)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>n.d.</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        DoDissertationOrThesis
    -->
    <xsl:template name="DoDissertationOrThesis">
        <!-- (location?, institution, published?, url?, dateAccessed?, iso639-3code*, comment?) -->
        <xsl:apply-templates select="../pub-location"/>
        <institution>
            <xsl:value-of select="normalize-space(../publisher)"/>
        </institution>
        <xsl:apply-templates select="../urls/related-urls"/>
        <xsl:apply-templates select="../dates/access-date"/>
        <xsl:apply-templates select="../electronic-resource-num"/>
        <xsl:apply-templates select="../custom7"/>
    </xsl:template>
    <!-- 
        DoID
    -->
    <xsl:template name="DoID">
        <xsl:choose>
            <xsl:when test="custom6">
                <xsl:for-each select="custom6">
                    <xsl:variable name="scustom6" select="translate(.,$sRemoveForID,'')"/>
                    <xsl:choose>
                        <xsl:when test="starts-with(.,'r')">
                            <xsl:value-of select="$scustom6"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>r</xsl:text>
                            <xsl:value-of select="$scustom6"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>r</xsl:text>
                <xsl:variable name="sName">
                    <xsl:call-template name="DoAuthorName"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains($sName,',')">
                        <xsl:value-of select="translate(substring-before($sName,','),$sRemoveForID,'')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="translate($sName,$sRemoveForID,'')"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:variable name="sDate">
                    <xsl:for-each select="dates">
                        <xsl:call-template name="DoDate"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="translate($sDate,$sRemoveForID,'')"/>
                <xsl:variable name="sTitle">
                    <xsl:call-template name="DoTitle"/>
                </xsl:variable>
                <xsl:value-of select="substring(translate($sTitle,$sRemoveForID,''),1,5)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        DoMs
    -->
    <xsl:template name="DoMs">
        <ms>
            <!-- (location?, institution, url?, dateAccessed?, iso639-3code*, comment?) -->
            <xsl:apply-templates select="../pub-location"/>
            <institution>
                <xsl:text>Unknown institution</xsl:text>
            </institution>
            <xsl:apply-templates select="../urls/related-urls"/>
            <xsl:apply-templates select="../dates/access-date"/>
            <xsl:apply-templates select="../electronic-resource-num"/>
            <xsl:apply-templates select="../custom7"/>
        </ms>
    </xsl:template>
    <!-- 
        DoRefTitle
    -->
    <xsl:template name="DoRefTitle">
        <refTitle>
            <xsl:call-template name="DoTitle"/>
        </refTitle>
    </xsl:template>
    <!-- 
        DoTitle
    -->
    <xsl:template name="DoTitle">
        <xsl:choose>
            <xsl:when test="titles/title">
                <xsl:apply-templates select="titles/title"/>
                <xsl:if test="titles/tertiary-title">
                    <xsl:text> (</xsl:text>
                    <xsl:apply-templates select="titles/tertiary-title"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>** There was no title for this work! **</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        DoWebPage
    -->
    <xsl:template name="DoWebPage">
        <webPage>
            <!-- (edition?, location?, (institution | publisher)?, url, dateAccessed?, iso639-3code*, comment?) -->
            <xsl:choose>
                <xsl:when test="../edition">
                    <edition>
                        <xsl:value-of select="normalize-space(../edition)"/>
                    </edition>
                </xsl:when>
                <xsl:when test="../number">
                    <edition>
                        <xsl:value-of select="normalize-space(../number)"/>
                    </edition>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="../pub-location"/>
            <xsl:apply-templates select="../publisher"/>
            <xsl:choose>
                <xsl:when test="not(../urls/related-urls)">
                    <url/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="../urls/related-urls"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="../dates/access-date"/>
            <xsl:apply-templates select="../electronic-resource-num"/>
            <xsl:apply-templates select="../custom7"/>
        </webPage>
    </xsl:template>
    <!-- 
        GetAuthorsNames
    -->
    <xsl:template name="GetAuthorsNames">
        <xsl:for-each select="author">
            <xsl:if test="position()!= 1">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:for-each>
    </xsl:template>
    <!-- 
        GetCiteName
    -->
    <xsl:template name="GetCiteName">
        <xsl:for-each select="contributors/authors/author">
            <xsl:choose>
                <xsl:when test="position()=last() and count(preceding-sibling::author) &gt; 0">
                    <xsl:text> and </xsl:text>
                </xsl:when>
                <xsl:when test="count(preceding-sibling::author) &gt; 0">
                    <xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:for-each>
    </xsl:template>
    <!-- 
        GetISOCodes
    -->
    <xsl:template name="GetISOCodes">
        <xsl:param name="sCodes"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sCodes),' ')"/>
        <xsl:variable name="sFirst" select="substring-before(substring-after($sNewList,'['),']')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,']')"/>
        <xsl:if test="string-length($sFirst) &gt; 0">
            <iso639-3code>
                <xsl:value-of select="$sFirst"/>
            </iso639-3code>
            <xsl:if test="$sRest">
                <xsl:call-template name="GetISOCodes">
                    <xsl:with-param name="sCodes" select="$sRest"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!-- 
        GetLastNameFirst
    -->
    <xsl:template name="GetLastNameFirst">
        <xsl:param name="sName"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sName),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:choose>
            <xsl:when test="$sRest">
                <xsl:call-template name="GetLastNameFirst">
                    <xsl:with-param name="sName" select="$sRest"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sFirst"/>
                <xsl:text>, </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        GetNonLastNames
    -->
    <xsl:template name="GetNonLastNames">
        <xsl:param name="sName"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sName),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:if test="$sRest">
            <xsl:value-of select="$sFirst"/>
            <xsl:text>&#x20;</xsl:text>
            <xsl:call-template name="GetNonLastNames">
                <xsl:with-param name="sName" select="$sRest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
