<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://icl.com/saxon" version="1.1">

    <!--  
        BoxUpWrdsInAllLinesInLineGroup
    -->
    <xsl:template name="BoxUpWrdsInAllLinesInLineGroup">
        <xsl:param name="originalContext"/>
        <xsl:variable name="iPos" select="count(preceding-sibling::wrd) + 1"/>
        <div class="itxitem">
            <xsl:for-each select="../preceding-sibling::line">
                <xsl:for-each select="wrd[position()=$iPos]">
                    <xsl:call-template name="DoWrdWrap">
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
            <xsl:call-template name="DoWrdWrap">
                <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
            <xsl:for-each select="../following-sibling::line">
                <xsl:for-each select="wrd[position()=$iPos]">
                    <xsl:call-template name="DoWrdWrap">
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>
        </div>
        <!--        <xsl:if test="not($originalContext)">
            <xsl:for-each select="../preceding-sibling::line/wrd[position()=$iPos]">
            <xsl:call-template name="DoFootnoteTextWithinWrappableWrd">
            <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
            </xsl:for-each>
            <xsl:call-template name="DoFootnoteTextWithinWrappableWrd">
            <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
            <xsl:for-each select="../following-sibling::line/wrd[position()=$iPos]">
            <xsl:call-template name="DoFootnoteTextWithinWrappableWrd">
            <xsl:with-param name="originalContext" select="$originalContext"/>
            </xsl:call-template>
            </xsl:for-each>
            </xsl:if>-->
        <!--        <xsl:if test="position()!=last()">
            <xsl:choose>
            <xsl:when test="count(../../line) &gt; 1">
            <!-\-<tex:cmd name="XLingPaperintspace"/>-\->
            <span>&#x20;</span>
            </xsl:when>
            <xsl:otherwise>
            <xsl:text>&#x20;</xsl:text>
            </xsl:otherwise>
            </xsl:choose>
            </xsl:if>-->
    </xsl:template>
    <!--  
        CalculateColumnsInInterlinearLine
    -->
    <xsl:template name="CalculateColumnsInInterlinearLine">
        <xsl:param name="sList"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:text>x</xsl:text>
        <xsl:if test="$sRest">
            <xsl:call-template name="CalculateColumnsInInterlinearLine">
                <xsl:with-param name="sList" select="$sRest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
        DoIthCellInNonWrdInterlinearLineAsWrappable
    -->
    <xsl:template name="DoIthCellInNonWrdInterlinearLineAsWrappable">
        <xsl:param name="sList"/>
        <xsl:param name="lang"/>
        <xsl:param name="iPositionToUse"/>
        <xsl:param name="iCurrentPosition"/>
        <xsl:param name="iMaxColumns"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:choose>
            <xsl:when test="$iCurrentPosition = $iPositionToUse">
                <xsl:call-template name="OutputInterlinearLineTableCellContent">
                    <xsl:with-param name="lang" select="$lang"/>
                    <xsl:with-param name="sFirst" select="$sFirst"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
                <xsl:if test="$sRest or $iCurrentPosition &lt; $iMaxColumns">
                    <xsl:call-template name="DoIthCellInNonWrdInterlinearLineAsWrappable">
                        <xsl:with-param name="sList" select="$sRest"/>
                        <xsl:with-param name="lang" select="$lang"/>
                        <xsl:with-param name="iPositionToUse" select="$iPositionToUse"/>
                        <xsl:with-param name="iCurrentPosition" select="$iCurrentPosition + 1"/>
                        <xsl:with-param name="iMaxColumns" select="$iMaxColumns"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoNonWrdInterlinearLineAsWrappable
    -->
    <xsl:template name="DoNonWrdInterlinearLineAsWrappable">
        <xsl:param name="sList"/>
        <xsl:param name="lang"/>
        <xsl:param name="bFlip"/>
        <xsl:param name="iPosition"/>
        <xsl:param name="iMaxColumns"/>
        <xsl:variable name="sNewList" select="concat(normalize-space($sList),' ')"/>
        <xsl:variable name="sFirst" select="substring-before($sNewList,' ')"/>
        <xsl:variable name="sRest" select="substring-after($sNewList,' ')"/>
        <xsl:variable name="iLineCountInLineGroup" select="count(../line)"/>
        <div class="itxitem">
            <div>
                <xsl:call-template name="OutputInterlinearLineTableCellContent">
                    <xsl:with-param name="lang" select="$lang"/>
                    <xsl:with-param name="sFirst" select="$sFirst"/>
                </xsl:call-template>
            </div>
            <xsl:for-each select="following-sibling::line">
                <xsl:variable name="langOfNewLine">
                    <xsl:call-template name="GetLangInNonWrdLine"/>
                </xsl:variable>
                <xsl:variable name="sOrientedContents">
                    <xsl:call-template name="GetOrientedContents">
                        <xsl:with-param name="bFlip" select="$bFlip"/>
                    </xsl:call-template>
                </xsl:variable>
                <div>
                    <xsl:call-template name="DoIthCellInNonWrdInterlinearLineAsWrappable">
                        <xsl:with-param name="sList" select="$sOrientedContents"/>
                        <xsl:with-param name="lang" select="$langOfNewLine"/>
                        <xsl:with-param name="iPositionToUse" select="$iPosition"/>
                        <xsl:with-param name="iCurrentPosition" select="1"/>
                        <xsl:with-param name="iMaxColumns" select="$iMaxColumns"/>
                    </xsl:call-template>
                </div>
            </xsl:for-each>
            <!--                <xsl:if test="$iLineCountInLineGroup &gt; 1 or not($sRest or $iPosition &lt; $iMaxColumns)">
                <tr>
                <td>
                <xsl:value-of select="$sBasicPointSize"/>
                <xsl:text>pt</xsl:text>
                </td>
                </tr>
                </xsl:if>-->
        </div>
        <xsl:if test="$sRest or $iPosition &lt; $iMaxColumns">
            <!--<xsl:choose>
                <xsl:when test="$iLineCountInLineGroup &gt; 1">
                <tex:cmd name="XLingPaperintspace"/>
                </xsl:when>
                <xsl:otherwise>
                <!-\-  if there is only one line we might as well just use spaces -\->-->
            <xsl:text>&#x20;</xsl:text>
            <!--                </xsl:otherwise>
                </xsl:choose>-->
            <xsl:call-template name="DoNonWrdInterlinearLineAsWrappable">
                <xsl:with-param name="sList" select="$sRest"/>
                <xsl:with-param name="lang" select="$lang"/>
                <xsl:with-param name="bFlip" select="$bFlip"/>
                <xsl:with-param name="iPosition" select="$iPosition + 1"/>
                <xsl:with-param name="iMaxColumns" select="$iMaxColumns"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--  
        DoWrdWrap
    -->
    <xsl:template name="DoWrdWrap">
        <xsl:param name="originalContext"/>
        <div>
            <xsl:choose>
                <xsl:when test="@lang">
                    <span>
                        <xsl:call-template name="OutputFontAttributes">
                            <xsl:with-param name="language" select="key('LanguageID',@lang)"/>
                            <xsl:with-param name="originalContext" select="."/>
                        </xsl:call-template>
                        <xsl:apply-templates>
                            <xsl:with-param name="originalContext" select="$originalContext"/>
                        </xsl:apply-templates>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates>
                        <xsl:with-param name="originalContext" select="$originalContext"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <!--  
        GetLangInNonWrdLine
    -->
    <xsl:template name="GetLangInNonWrdLine">
        <xsl:choose>
            <xsl:when test="langData">
                <xsl:value-of select="langData/@lang"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="gloss/@lang"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        GetMaxColumnCountForLineGroup
    -->
    <xsl:template name="GetMaxColumnCountForLineGroup">
        <xsl:param name="bListsShareSameCode"/>
        <xsl:variable name="iTempCount">
            <xsl:for-each select="line | ../listWord">
                <xsl:sort select="count(wrd) + count(langData) + count(gloss)" order="descending" data-type="number"/>
                <xsl:if test="position()=1">
                    <xsl:value-of select="count(wrd) + count(langData) + count(gloss)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test=" name()!='listWord' and $iTempCount=1 or name()!='listWord' and count(descendant::wrd)=0">
                <!-- have space-delimited langData and/or gloss line(s) -->
                <xsl:variable name="sMaxColCount">
                    <xsl:call-template name="GetMaxColumnCountForPCDATALines"/>
                </xsl:variable>
                <xsl:variable name="sIsoCode">
                    <xsl:for-each select="parent::listInterlinear">
                        <xsl:call-template name="GetISOCode"/>
                    </xsl:for-each>
                </xsl:variable>
                <!--  2011.11.16              <xsl:choose>
                    <xsl:when test="string-length($sIsoCode) = 3">-->
                <xsl:choose>
                    <xsl:when test="contains($bListsShareSameCode,'N')">
                        <xsl:value-of select="string-length($sMaxColCount)+1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="string-length($sMaxColCount)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- 2011.11.16                   </xsl:when>
                    <xsl:otherwise>
                    <xsl:value-of select="string-length($sMaxColCount)"/>
                    </xsl:otherwise>
                    </xsl:choose>
                -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="sIsoCode">
                    <xsl:for-each select="parent::listInterlinear">
                        <xsl:call-template name="GetISOCode"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains($bListsShareSameCode,'N')">
                        <xsl:value-of select="number($iTempCount + 1)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$iTempCount"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        GetMaxColumnCountForPCDATALines
    -->
    <xsl:template name="GetMaxColumnCountForPCDATALines">
        <!-- We need to figure out the maximum number of items in the line elements.
            The maximum could be in any line since the user just keys data in them.
            We use a bit of a trick.  We put XML into a variable, with a root of <lines> and each line as <line>.
            Each line contains one x for each item in the line.  We then sort these and get the longest one.
            We use the longest one to figure out how many columns we will need.
            Note that with XSLT version 1.0, we have to use something like the Saxon extension function node-set().
        -->
        <xsl:variable name="lines">
            <lines>
                <xsl:for-each select="line | ../listWord">
                    <line>
                        <xsl:call-template name="CalculateColumnsInInterlinearLine">
                            <xsl:with-param name="sList" select="langData | gloss"/>
                        </xsl:call-template>
                    </line>
                </xsl:for-each>
            </lines>
        </xsl:variable>
        <xsl:for-each select="saxon:node-set($lines)/descendant::*">
            <xsl:for-each select="line">
                <xsl:sort select="." order="descending"/>
                <xsl:if test="position()=1">
                    <xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <!-- 
        GetOrientedContents
    -->
    <xsl:template name="GetOrientedContents">
        <xsl:param name="bFlip"/>
        <xsl:variable name="sContents">
            <!--               <xsl:apply-templates/>  Why do we want to include all the parameters, etc. when what we really want is the text? -->
            <!--                    <xsl:value-of select="."/>-->
            <xsl:value-of select="self::*[not(descendant-or-self::endnote)]"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$bFlip='Y'">
                <!-- flip order, left to right -->
                <xsl:call-template name="ReverseContents">
                    <xsl:with-param name="sList" select="$sContents"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="langData and id(langData/@lang)/@rtl='yes'">
                <!-- flip order, left to right -->
                <xsl:call-template name="ReverseContents">
                    <xsl:with-param name="sList" select="$sContents"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sContents"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
