<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml" doctype-system="XLingPap.dtd" doctype-public="-//XMLmind//DTD XLingPap//EN"/>
    <xsl:include href="MODS2XLingPaperReferencesCommon.xsl"/>
    <!-- 
        A transform to convert non-XLingPaper format to XLingPaper references pass 2 of 2:
        merge refworks for common authors.
    -->
    <xsl:template match="/references">
        <references>
            <xsl:for-each select="refAuthor">
                <xsl:variable name="sThisAuthor" select="@name"/>
                <xsl:choose>
                    <xsl:when test="$sThisAuthor=$sMissingAuthorsMessage">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="preceding-sibling::refAuthor[1]/@name!=$sThisAuthor">
                        <refAuthor name="{@name}" citename="{@citename}">
                            <xsl:copy-of select="refWork"/>
                            <xsl:for-each select="following-sibling::refAuthor[@name=$sThisAuthor]">
                                <xsl:copy-of select="refWork"/>
                            </xsl:for-each>
                        </refAuthor>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="position()=1">
                                <xsl:copy-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- do nothing -->
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </references>
    </xsl:template>
</xsl:stylesheet>
