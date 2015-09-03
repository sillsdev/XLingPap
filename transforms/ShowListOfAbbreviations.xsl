<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!-- (rough) way of showing list of abbreviations -->
    
    <!-- 
    Parameters
    -->
    <xsl:param name="sTitle" select="'List of Abbreviations'"/>
    <xsl:param name="sAbbreviation" select="'Abbreviation'"/>
    <xsl:param name="sDefinition" select="'Definition'"/>
    <xsl:param name="sByAbbreviation" select="'By abbreviation'"/>
    <xsl:param name="sByDefinition" select="'By definition'"/>
    
    <!-- 
    Main template
    -->
    <xsl:template match="/">
        <html>
            <body>
                <p align="center" style="font-weight:bold;font-size:200%">
                    <xsl:value-of select="$sTitle"/></p>
                <xsl:apply-templates select="//abbreviations"/>
            </body>
        </html>
    </xsl:template>
    
    <!-- 
    Abbreviations
    -->
    <xsl:template match="abbreviations">
        <xsl:call-template name="ByAbbreviation"/>
        <hr/>
        <xsl:call-template name="ByDefinition"/>
    </xsl:template>

    <!-- 
        ByAbbreviation
    -->
    <xsl:template name="ByAbbreviation">
        <p>
            <xsl:value-of select="$sByAbbreviation"/>
        </p>
        <table>
            <tr>
                <th>
                    <xsl:value-of select="$sAbbreviation"/>
                </th>
                <th align="left">
                    <xsl:value-of select="$sDefinition"/>
                </th>
                <th align="left">ID</th>
            </tr>
            <xsl:for-each select="abbreviation/abbrInLang[1]">
                <xsl:sort select="abbrTerm"/>
                <tr>
                    <td>
                        <xsl:value-of select="abbrTerm"/>
                    </td>
                    <td>
                        <xsl:value-of select="abbrDefinition"/>
                    </td>
                    <td>
                        <xsl:value-of select="ancestor::abbreviation/@id"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>
    <!-- 
        ByDefinition
    -->
    <xsl:template name="ByDefinition">
        <p>
            <xsl:value-of select="$sByDefinition"/>
        </p>
        <table>
            <tr>
                <th align="left">
                    <xsl:value-of select="$sDefinition"/>
                </th>
                <th>
                    <xsl:value-of select="$sAbbreviation"/>
                </th>
                <th align="left">ID</th>
            </tr>
            <xsl:for-each select="abbreviation/abbrInLang[1]">
                <xsl:sort select="abbrDefinition"/>
                <tr>
                    <td>
                        <xsl:value-of select="abbrDefinition"/>
                    </td>
                    <td>
                        <xsl:value-of select="abbrTerm"/>
                    </td>
                    <td>
                        <xsl:value-of select="ancestor::abbreviation/@id"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>
</xsl:stylesheet>
