<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tex="http://getfo.sourceforge.net/texml/ns1" xmlns:saxon="http://icl.com/saxon" version="1.0">
    <!-- 
        XLingPapCommon.xsl
        Contains called templates common to many of the XLingPaper output transforms.
    -->
    <!--
        ConvertLastNameFirstNameToFirstNameLastName
    -->
    <xsl:template name="ConvertLastNameFirstNameToFirstNameLastName">
        <xsl:param name="sCitedWorkAuthor"/>
        <xsl:variable name="sFirstAuthorLastName" select="substring-before($sCitedWorkAuthor,',')"/>
        <xsl:variable name="sFirstAuthorFirstName">
            <xsl:variable name="sTryOne" select="normalize-space(substring-before(substring-after($sCitedWorkAuthor,','),','))"/>
            <xsl:choose>
                <xsl:when test="string-length($sTryOne) &gt; 0">
                    <!-- there are three or more names (we assume), so what comes before the second comma should be the first name -->
                    <xsl:value-of select="$sTryOne"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- assume it is only one or two authors -->
                    <xsl:choose>
                        <xsl:when test="contains($sCitedWorkAuthor,' &amp; ')">
                            <!-- there is an ampersand, so assume there are two authors and the first name is what comes between the first comma and the ampersand -->
                            <xsl:value-of select="normalize-space(substring-before(substring-after($sCitedWorkAuthor,','),' &amp; '))"/>
                        </xsl:when>
                        <xsl:when test="contains($sCitedWorkAuthor,' and ')">
                            <!-- there is an 'and', so assume there are two authors and the first name is what comes between the first comma and the 'and' -->
                            <xsl:value-of select="normalize-space(substring-before(substring-after($sCitedWorkAuthor,','),' and '))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- it must be only one author -->
                            <xsl:value-of select="normalize-space(substring-after($sCitedWorkAuthor,','))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sSecondAuthorEtc">
            <xsl:variable name="sTryOne" select="substring-after(substring-after($sCitedWorkAuthor,','),',')"/>
            <xsl:choose>
                <xsl:when test="string-length($sTryOne) &gt; 0">
                    <!-- there are three or more names (we assume), so what comes before the second comma should be the rest -->
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$sTryOne"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- assume it is only one or two authors -->
                    <xsl:choose>
                        <xsl:when test="contains($sCitedWorkAuthor,' &amp; ')">
                            <!-- there is an ampersand, so assume there are two authors and the rest is what comes after the ampersand -->
                            <xsl:text> &amp; </xsl:text>
                            <xsl:value-of select="normalize-space(substring-after(substring-after($sCitedWorkAuthor,','),' &amp; '))"/>
                        </xsl:when>
                        <xsl:when test="contains($sCitedWorkAuthor,' and ')">
                            <!-- there is an 'and', so assume there are two authors and the rest is what comes after the 'and' -->
                            <xsl:text> and </xsl:text>
                            <xsl:value-of select="normalize-space(substring-after(substring-after($sCitedWorkAuthor,','),' and '))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- it must be only one author -->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$sFirstAuthorFirstName"/>
        <xsl:text>&#x20;</xsl:text>
        <xsl:value-of select="$sFirstAuthorLastName"/>
        <xsl:if test="string-length($sSecondAuthorEtc) &gt; 0">
            <xsl:value-of select="$sSecondAuthorEtc"/>
        </xsl:if>
    </xsl:template>
    <!--
        GetCollOrProcVolumesToInclude
    -->
    <xsl:template name="GetCollOrProcVolumesToInclude">
        <xsl:variable name="directlyCitedWorks" select="$refWorks[@id=//citation[not(ancestor::comment)]/@ref]"/>
        <xsl:variable name="citedCollOrProcWithCitation">
            <xsl:for-each select="$directlyCitedWorks/collection/collCitation | $directlyCitedWorks/proceedings/procCitation">
                <xsl:sort select="@refToBook"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="saxon:node-set($citedCollOrProcWithCitation)/collCitation | saxon:node-set($citedCollOrProcWithCitation)/procCitation">
            <xsl:variable name="thisRefToBook" select="@refToBook"/>
            <xsl:variable name="precedingSibling" select="preceding-sibling::*"/>
            <!-- to set the required number, use count of preceding is greater than or equal to threshold minus 1 -->
            <xsl:if test="preceding-sibling::*/@refToBook=$thisRefToBook">
                <xsl:copy-of select="$refWorks[@id=$thisRefToBook]"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
