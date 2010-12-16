<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!-- 
        A transform to convert XLingPaper references  to Endnote XML format
    -->
    <!-- 
        main template
    -->
    <xsl:template match="//references">
        <xml>
            <records>
                <xsl:variable name="iNumberOfEntries" select="count(descendant::refWork)"/>
                <xsl:choose>
                    <xsl:when test="$iNumberOfEntries &gt; 0">
                        <xsl:apply-templates select="descendant::refWork"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- The Endnote DTD says that there has to be at least one record element -->
                        <record/>
                    </xsl:otherwise>
                </xsl:choose>
            </records>
        </xml>
    </xsl:template>
    <!--
        article
    -->
    <xsl:template match="article" mode="ref-type">
        <ref-type name="Journal Article">17</ref-type>
    </xsl:template>
    <!--
        book
    -->
    <xsl:template match="book" mode="ref-type">
        <ref-type name="Book">6</ref-type>
    </xsl:template>
    <!--
        book/seriesEd
    -->
    <xsl:template match="book/seriesEd">
        <secondary-authors>
            <author>
                <xsl:value-of select="."/>
            </author>
        </secondary-authors>
    </xsl:template>
    <!--
        bVol
    -->
    <xsl:template match="bVol">
        <volume>
            <xsl:value-of select="."/>
        </volume>
    </xsl:template>
    <!--
        collection
    -->
    <xsl:template match="collection" mode="ref-type">
        <ref-type name="Book Section">5</ref-type>
    </xsl:template>
    <!--
        collEd
    -->
    <xsl:template match="collEd">
        <secondary-authors>
            <author>
                <xsl:value-of select="."/>
            </author>
        </secondary-authors>
    </xsl:template>
    <!--
        collection/seriesEd
    -->
    <xsl:template match="collection/seriesEd">
        <tertiary-authors>
            <author>
                <xsl:value-of select="."/>
            </author>
        </tertiary-authors>
    </xsl:template>
    <!--
        collPages
    -->
    <xsl:template match="collPages">
        <pages>
            <xsl:value-of select="."/>
        </pages>
    </xsl:template>
    <!--
        collTitle
    -->
    <xsl:template match="collTitle">
        <secondary-title>
            <xsl:value-of select="."/>
        </secondary-title>
    </xsl:template>
    <!--
        collVol
    -->
    <xsl:template match="collVol">
        <volume>
            <xsl:value-of select="."/>
        </volume>
    </xsl:template>
    <!--
        comment
    -->
    <xsl:template match="comment">
        <notes>
            <xsl:value-of select="."/>
        </notes>
    </xsl:template>
    <!--
        conference
    -->
    <xsl:template match="conference">
        <secondary-title>
            <xsl:value-of select="."/>
        </secondary-title>
    </xsl:template>
    <!--
        dateAccessed
    -->
    <xsl:template match="dateAccessed">
        <access-date>
            <xsl:value-of select="."/>
        </access-date>
    </xsl:template>
    <!--
        dissertation
    -->
    <xsl:template match="dissertation" mode="ref-type">
        <ref-type name="Thesis">32</ref-type>
    </xsl:template>
    <!--
        edition
    -->
    <xsl:template match="edition">
        <edition>
            <xsl:value-of select="."/>
        </edition>
    </xsl:template>
    <!--
        fieldNotes
    -->
    <xsl:template match="fieldNotes" mode="ref-type">
        <ref-type name="Manuscript">36</ref-type>
    </xsl:template>
    <!--
        jIssueNumber
    -->
    <xsl:template match="jIssueNumber">
        <issue>
            <xsl:value-of select="."/>
        </issue>
    </xsl:template>
    <!--
        jPages
    -->
    <xsl:template match="jPages">
        <pages>
            <xsl:value-of select="."/>
        </pages>
    </xsl:template>
    <!--
        jTitle
    -->
    <xsl:template match="jTitle">
        <periodical>
            <full-title>
                <xsl:value-of select="."/>
            </full-title>
        </periodical>
    </xsl:template>
    <!--
        jVol
    -->
    <xsl:template match="jVol">
        <volume>
            <xsl:value-of select="."/>
        </volume>
    </xsl:template>
    <!--
        location
    -->
    <xsl:template match="location">
        <pub-location>
            <xsl:value-of select="."/>
        </pub-location>
    </xsl:template>
    <!--
        ms
    -->
    <xsl:template match="ms" mode="ref-type">
        <ref-type name="Manuscript">36</ref-type>
    </xsl:template>
    <!--
        paper
    -->
    <xsl:template match="paper" mode="ref-type">
        <ref-type name="Conference Paper">47</ref-type>
    </xsl:template>
    <!--
        procEd
    -->
    <xsl:template match="procEd">
        <secondary-authors>
            <author>
                <xsl:value-of select="."/>
            </author>
        </secondary-authors>
    </xsl:template>
    <!--
        proceedings
    -->
    <xsl:template match="proceedings" mode="ref-type">
        <ref-type name="Conference Proceedings">10</ref-type>
    </xsl:template>
    <!--
        procPages
    -->
    <xsl:template match="procPages">
        <pages>
            <xsl:value-of select="."/>
        </pages>
    </xsl:template>
    <!--
        procTitle
    -->
    <xsl:template match="procTitle">
        <secondary-title>
            <xsl:value-of select="."/>
        </secondary-title>
    </xsl:template>
    <!--
        procVol
    -->
    <xsl:template match="procVol">
        <volume>
            <xsl:value-of select="."/>
        </volume>
    </xsl:template>
    <!--
        publisher
    -->
    <xsl:template match="publisher">
        <publisher>
            <xsl:value-of select="."/>
        </publisher>
    </xsl:template>
    <!-- 
        refAuthor
    -->
    <xsl:template match="refAuthor">
        <contributors>
            <authors>
                <author>
                    <xsl:value-of select="@name"/>
                </author>
            </authors>
            <xsl:apply-templates select="book/seriesEd"/>
            <xsl:apply-templates select="collection/collEd"/>
            <xsl:apply-templates select="collection/seriesEd"/>
            <xsl:apply-templates select="proceedings/procEd"/>
            <xsl:apply-templates select="book/translatedBy"/>
        </contributors>
    </xsl:template>
    <!-- 
        refDate
    -->
    <xsl:template match="refDate">
        <dates>
            <year>
                <xsl:value-of select="."/>
            </year>
        </dates>
    </xsl:template>
    <!-- 
        refTitle
    -->
    <xsl:template match="refTitle">
        <titles>
            <title>
                <xsl:value-of select="."/>
            </title>
            <xsl:apply-templates select="book/series"/>
            <xsl:apply-templates select="collection/collTitle"/>
            <xsl:apply-templates select="paper/conference"/>
            <xsl:apply-templates select="proceedings/procTitle"/>
        </titles>
    </xsl:template>
    <!-- 
        refWork
    -->
    <xsl:template match="refWork">
        <record>
            <xsl:apply-templates select="article | book | collection | dissertation | fieldNotes | ms | paper | proceedings | thesis | webPage" mode="ref-type"/>
            <!--  get author and other contributors-->
            <xsl:apply-templates select=".."/>
            <!-- periodical -->
            <xsl:apply-templates select="refTitle"/>
            <xsl:apply-templates select="article/jTitle"/>
            <xsl:call-template name="DoPages"/>
            <xsl:call-template name="DoVolume"/>
<!--            <xsl:apply-templates select="book/bVol"/>-->
            <xsl:apply-templates select="article/jIssueNumber"/>
            <xsl:call-template name="DoEdition"/>
            <xsl:apply-templates select="refDate"/>
            <xsl:apply-templates select="descendant-or-self::location"/>
            <xsl:apply-templates select="descendant-or-self::publisher"/>
            <xsl:apply-templates select="descendant-or-self::comment"/>
            <xsl:apply-templates select="descendant-or-self::url"/>
            <xsl:apply-templates select="descendant-or-self::dateAccessed"/>
        </record>
    </xsl:template>
    <!--
        thesis
    -->
    <xsl:template match="thesis" mode="ref-type">
        <ref-type name="Thesis">32</ref-type>
    </xsl:template>
    <!--
        translatedBy
    -->
    <xsl:template match="translatedBy">
        <translated-authors>
            <author>
                <xsl:value-of select="."/>
            </author>
        </translated-authors>
    </xsl:template>
    <!--
        url
    -->
    <xsl:template match="url">
        <urls>
            <related-urls>
                <url>
                    <xsl:value-of select="."/>
                </url>
            </related-urls>
        </urls>
    </xsl:template>
    <!--
        webPage
    -->
    <xsl:template match="webPage" mode="ref-type">
        <ref-type name="Web Page">12</ref-type>
    </xsl:template>
    <!-- 
        DoEdition
    -->
    <xsl:template name="DoEdition">
        <xsl:apply-templates select="book/edition"/>
        <xsl:apply-templates select="webPage/edition"/>
    </xsl:template>
    <!-- 
        DoPages
    -->
    <xsl:template name="DoPages">
        <xsl:apply-templates select="article/jPages"/>
        <xsl:apply-templates select="collection/collPages"/>
        <xsl:apply-templates select="proceedings/procPages"/>
    </xsl:template>
    <!-- 
        DoVolume
    -->
    <xsl:template name="DoVolume">
        <xsl:apply-templates select="book/bVol"/>
        <xsl:apply-templates select="article/jVol"/>
        <xsl:apply-templates select="collection/collVol"/>
        <xsl:apply-templates select="proceedings/procVol"/>
    </xsl:template>
</xsl:stylesheet>
