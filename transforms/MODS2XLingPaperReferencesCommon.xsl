<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output encoding="UTF-8" indent="no" method="xml"/>
    <xsl:variable name="sMissingAuthorsMessage" select="'** There was no author for this work! **'"/>
    <xsl:variable name="sRemoveForID">
        <xsl:text> *!‐˙+-=:¸,¸/&gt;&lt;()[]{}&#x22;&#x60;&#xb4;&#x201c;&#x201d;&#x2018;&#x2019;'?·&#xa0;¯</xsl:text>
    </xsl:variable>
</xsl:stylesheet>
