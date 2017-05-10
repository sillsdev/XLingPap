<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:a="http://www.xmlmind.com/xmleditor/schema/addon">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
    <xsl:template match="a:addon">
        <html>
            <head>
                <script language="JavaScript" id="clientEventHandlersJS">
                    <xsl:text>
    function ButtonShowDetails()
    {
    if (RevisionHistory.style.display == 'none')
    {
      RevisionHistory.style.display = 'block';
      ShowDetailsButton.value = "Hide Details";
    }
    else
    {
      RevisionHistory.style.display = 'none';
      ShowDetailsButton.value = "Show Details";
    }
    }
                    </xsl:text>
                    </script>
                <title>About XLingPaper</title>
            </head>
            <body>
                <h1 align="center"><img src="resources/XLingPaper.ico" alt="icon"/>&#xa0;&#xa0;XLingPaper&#xa0;&#xa0;<img src="resources/XLingPaper.ico" alt="icon"/></h1>
                <h3 align="center">for use with the XMLmind XML Editor</h3>
                <xsl:apply-templates select="a:version | a:date"/>
                <xsl:apply-templates select="a:name | a:abstract"/>
                <hr/>
                <p style="margin-left:.5in">
                    <input type="button" value="Show Details" name="BDetails" id="ShowDetailsButton" onclick="ButtonShowDetails()" style="width: 88px; height: 24px"/>
                </p>
                <div id="RevisionHistory" style="display:none">
                    <xsl:copy-of select="a:documentation"/>
                </div>
                <hr/>
                <div align="center">
                    <p>For more information, including contact email address, see:  
                        <a href="http://software.sil.org/xlingpaper/">http://software.sil.org/xlingpaper/</a>
                    </p>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="a:abstract">
        <p align="center" style="font-style:italic;">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="a:name">
        <p align="center">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="a:version">
        <p align="center">
            <xsl:text>Version: </xsl:text>
            <span style="font-size:larger; font-weight:bold">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>
    <xsl:template match="a:date">
        <p align="center">
            <xsl:text>Date: </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
</xsl:stylesheet>
