<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tex="http://getfo.sourceforge.net/texml/ns1" xmlns:saxon="http://icl.com/saxon" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="1.0" exclude-result-prefixes="saxon xhtml">
    <!-- 
        XLingPapCommon.xsl
        Contains common global variables and common templates common to many of the XLingPaper output transforms.
    -->
    <!-- ===========================================================
        Keys
        =========================================================== -->
    <xsl:key name="EndnoteID" match="//endnote" use="@id"/>
    <xsl:key name="IndexTermID" match="//indexTerm" use="@id"/>
    <xsl:key name="InterlinearReferenceID" match="//interlinear | //interlinear-text" use="@text"/>
    <xsl:key name="InterlinearRef" match="//interlinearRef" use="@textref"/>
    <xsl:key name="LanguageID" match="//language" use="@id"/>
    <xsl:key name="RefWorkID" match="//refWork" use="@id"/>
    <xsl:key name="TypeID" match="//type" use="@id"/>
    <xsl:key name="AuthorContactID" match="//authorContact" use="@id"/>
    <!-- ===========================================================
        Version of this stylesheet
        =========================================================== -->
    <xsl:variable name="sVersion">2.14.0</xsl:variable>
    <xsl:variable name="lingPaper" select="//lingPaper"/>
    <xsl:variable name="documentLang" select="normalize-space($lingPaper/@xml:lang)"/>
    <xsl:variable name="abbrLang">
        <xsl:variable name="abbrLangTemp" select="normalize-space($lingPaper/@abbreviationlang) "/>
        <xsl:choose>
            <xsl:when test="string-length($abbrLangTemp) &gt; 0">
                <xsl:value-of select="$abbrLangTemp"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$documentLang"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="indexLang">
        <xsl:variable name="indexLangTemp" select="normalize-space($lingPaper/@indexlang) "/>
        <xsl:choose>
            <xsl:when test="string-length($indexLangTemp) &gt; 0">
                <xsl:value-of select="$indexLangTemp"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$documentLang"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="indexSeeDefinition" select="$lingPaper/indexTerms/seeDefinitions/seeDefinition[@lang=$indexLang]"/>
    <xsl:variable name="abbreviations" select="//abbreviations"/>
    <xsl:variable name="refWorks" select="//refWork"/>
    <xsl:variable name="citations" select="//citation"/>
    <xsl:variable name="collOrProcVolumesToInclude">
        <xsl:call-template name="GetCollOrProcVolumesToInclude"/>
    </xsl:variable>
    <xsl:variable name="referencesLayoutInfo" select="//publisherStyleSheet/backMatterLayout/referencesLayout"/>
    <xsl:variable name="sMAThesisDefaultLabel" select="'M.A. thesis'"/>
    <xsl:variable name="sPhDDissertationDefaultLabel" select="'Ph.D. dissertation'"/>
    <xsl:variable name="sAcknowledgementsID" select="'rXLingPapAcknowledgements'"/>
    <xsl:variable name="endnotesToShow">
        <xsl:for-each select="//endnote[not(ancestor::referencedInterlinearText)]">
            <xsl:text>X</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="//interlinearRef">
            <xsl:for-each select="key('InterlinearReferenceID',@textref)[1]">
                <xsl:if test="descendant::endnote">
                    <xsl:text>X</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="bIsBook" select="//chapter"/>
    <xsl:variable name="sYs" select="'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY'"/>
    <!--
        exampleHeading in NotTextRef mode
    -->
    <xsl:template match="exampleHeading" mode="NoTextRef">
        <xsl:apply-templates select="."/>
    </xsl:template>
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
        DetermineIfListsShareSameISOCode
    -->
    <xsl:template name="DetermineIfListsShareSameISOCode">
        <xsl:choose>
            <xsl:when test="$lingPaper/@showiso639-3codeininterlinear='yes'">
                <xsl:choose>
                    <xsl:when test="listInterlinear or listWord or listSingle">
                        <xsl:variable name="sIsoCodeOfFirst" select="key('LanguageID',(descendant::langData[1] | key('InterlinearReferenceID',child::*[substring(name(),1,4)='list'][1]/interlinearRef/@textref)[1]/descendant::langData[1])/@lang)/@ISO639-3Code"/>
                        <xsl:for-each select="*/following-sibling::*">
                            <xsl:variable name="sIsoCodeOfFollowingFirst" select="key('LanguageID',(descendant::langData[1] | key('InterlinearReferenceID',interlinearRef/@textref)[1]/descendant::langData[1])/@lang)/@ISO639-3Code"/>
                            <xsl:if test="$sIsoCodeOfFollowingFirst != $sIsoCodeOfFirst">
                                <xsl:text>N</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Y</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Y</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoInterlinearRefCitationContent
    -->
    <xsl:template name="DoInterlinearRefCitationContent">
        <xsl:param name="sRef"/>
        <xsl:variable name="interlinear" select="key('InterlinearReferenceID',$sRef)"/>
        <xsl:if test="not(@lineNumberOnly) or @lineNumberOnly!='yes'">
            <xsl:choose>
                <xsl:when test="$interlinear/../textInfo/shortTitle and string-length($interlinear/../textInfo/shortTitle) &gt; 0">
                    <xsl:apply-templates select="$interlinear/../textInfo/shortTitle/child::node()[name()!='endnote']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$interlinear/../textInfo/textTitle/child::node()[name()!='endnote']"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>:</xsl:text>
        </xsl:if>
        <xsl:call-template name="DoInterlinearTextNumber">
            <xsl:with-param name="sRef" select="$sRef"/>
            <xsl:with-param name="interlinear" select="$interlinear"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        DoInterlinearTextNumber
    -->
    <xsl:template name="DoInterlinearTextNumber">
        <xsl:param name="sRef"/>
        <xsl:param name="interlinear"/>
        <xsl:choose>
            <xsl:when test="substring($sRef,1,4)='T-ID'">
                <xsl:value-of select="substring-after(substring-after($sRef,'-'),'-')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count($interlinear/preceding-sibling::interlinear) + 1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoInterlinearTextReferenceLink
    -->
    <xsl:template name="DoInterlinearTextReferenceLink">
        <xsl:param name="sRef" select="@textref"/>
        <xsl:param name="sAttrName" select="'href'"/>
        <xsl:param name="sExtension" select="'pdf'"/>
        <xsl:attribute name="{$sAttrName}">
            <xsl:variable name="referencedInterlinear" select="key('InterlinearReferenceID',$sRef)"/>
            <xsl:choose>
                <xsl:when test="$referencedInterlinear[ancestor::referencedInterlinearTexts]">
                    <xsl:value-of select="$referencedInterlinear/ancestor::referencedInterlinearText/@url"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="$sExtension"/>
                    <xsl:text>#</xsl:text>
                    <xsl:value-of select="$sRef"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$sAttrName='href'">
                        <xsl:text>#</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="$sRef"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <!--
        DoRefAuthors
    -->
    <xsl:template name="DoRefAuthors">
        <xsl:variable name="refAuthors" select="//refAuthor"/>
        <!--        <xsl:variable name="directlyCitedAuthors" select="$refAuthors[refWork/@id=//citation[not(ancestor::comment)]/@ref]"/>-->
        <!--        <xsl:variable name="directlyCitedAuthors" select="$refAuthors[refWork[@id=$citations[not(ancestor::comment) and not(ancestor::refWork[@id!=$citations/@ref])]/@ref]]"/>-->
        <xsl:variable name="directlyCitedAuthors" select="$refAuthors[refWork[@id=$citations[not(ancestor::comment) and not(ancestor::referencedInterlinearText)][not(ancestor::refWork) or ancestor::refWork[@id=$citations[not(ancestor::refWork)]/@ref]]/@ref]]"/>
        <!--        //refWork[@id=//citation[not(ancestor::comment)][not(ancestor::refWork) or ancestor::refWork[@id=//citation[not(ancestor::refWork)]/@ref]]/@ref]-->
        <xsl:variable name="impliedAuthors" select="$refWorks[@id=saxon:node-set($collOrProcVolumesToInclude)/refWork/@id]/parent::refAuthor"/>
        <xsl:choose>
            <xsl:when test="$lingPaper/@sortRefsAbbrsByDocumentLanguage='yes'">
                <xsl:variable name="sLang">
                    <xsl:variable name="sLangCode" select="normalize-space($lingPaper/@xml:lang)"/>
                    <xsl:choose>
                        <xsl:when test="string-length($sLangCode) &gt; 0">
                            <xsl:value-of select="$sLangCode"/>
                        </xsl:when>
                        <xsl:otherwise>en</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:for-each select="$directlyCitedAuthors | $impliedAuthors">
                    <xsl:sort lang="{$sLang}" select="@name"/>
                    <xsl:call-template name="DoRefWorks"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$directlyCitedAuthors | $impliedAuthors">
                    <xsl:call-template name="DoRefWorks"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        GetAbbreviationLanguageCode
    -->
    <xsl:template name="GetAbbreviationLanguageCode">
        <xsl:variable name="sLangCode">
            <xsl:choose>
                <xsl:when test="string-length($abbrLang) &gt; 0">
                    <xsl:value-of select="$abbrLang"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$documentLang"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($sLangCode) &gt; 0">
                <xsl:value-of select="$sLangCode"/>
            </xsl:when>
            <xsl:otherwise>en</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        GetCollOrProcVolumesToInclude
    -->
    <xsl:template name="GetCollOrProcVolumesToInclude">
        <xsl:choose>
            <xsl:when test="$referencesLayoutInfo/@usecitationformatwhennumbereofsharedpaperis=0">
                <!-- do nothing -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="iSharedPapers">
                    <xsl:choose>
                        <xsl:when test="string(number($referencesLayoutInfo/@usecitationformatwhennumbereofsharedpaperis))='NaN'">
                            <xsl:text>1</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$referencesLayoutInfo/@usecitationformatwhennumbereofsharedpaperis - 1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="directlyCitedWorks" select="$refWorks[@id=//citation[not(ancestor::comment)]/@ref]"/>
                <xsl:variable name="citedCollOrProcWithCitation">
                    <xsl:for-each select="$directlyCitedWorks/collection/collCitation | $directlyCitedWorks/proceedings/procCitation">
                        <xsl:sort select="@refToBook"/>
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:for-each select="saxon:node-set($citedCollOrProcWithCitation)/collCitation | saxon:node-set($citedCollOrProcWithCitation)/procCitation">
                    <xsl:variable name="thisRefToBook" select="@refToBook"/>
                    <xsl:variable name="precedingSiblings" select="preceding-sibling::*[@refToBook=$thisRefToBook]"/>
                    <!-- to set the required number, use count of preceding is greater than or equal to threshold minus 1 -->
                    <xsl:if test="$precedingSiblings and count($precedingSiblings) &gt;= $iSharedPapers">
                        <xsl:copy-of select="$refWorks[@id=$thisRefToBook]"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        GetCountOfEndnotesIncludingAnyInInterlinearRefs
    -->
    <xsl:template name="GetCountOfEndnotesIncludingAnyInInterlinearRefs">
        <xsl:param name="iAdjust"/>
        <xsl:param name="iPreviousEndnotesInCurrentInterlinearRef" select="0"/>
        <xsl:variable name="iPreviousEndnotes">
            <xsl:variable name="iPreviousEndnotesPass1">
                <xsl:choose>
                    <xsl:when test="$bEndnoteRefIsDirectLinkToEndnote='Y'">
                        <xsl:number level="any" count="endnote[not(parent::author)]" format="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:number level="any" count="endnote[not(parent::author)] | endnoteRef[not(ancestor::endnote)][not(@showNumberOnly='yes')]" format="1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$iPreviousEndnotesPass1!=''">
                    <xsl:value-of select="$iPreviousEndnotesPass1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="iIncludeCurrentInterlinearRef">
            <xsl:choose>
                <xsl:when test="name()='interlinearRef'">
                    <xsl:value-of select="$iAdjust"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="endnotesInPrecedingInterlinearRefs" select="(descendant::interlinearRef | preceding::interlinearRef)[key('InterlinearReferenceID',@textref)/descendant::endnote]"/>
        <xsl:variable name="sCount">
            <xsl:for-each select="$endnotesInPrecedingInterlinearRefs">
                <xsl:variable name="iCountOfEndnotes" select="count(key('InterlinearReferenceID',@textref)/descendant::endnote)"/>
                <xsl:value-of select="substring($sYs,1,$iCountOfEndnotes)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="iCountOfEndnotesInPrecedingInterlinearRefs" select="string-length($sCount)"/>
        <!--        <xsl:variable name="iCountOfEndnotesInPrecedingInterlinearRefs" select="count((descendant::interlinearRef | preceding::interlinearRef)[key('InterlinearReferenceID',@textref)/descendant::endnote])"/>-->
        <!--        <xsl:variable name="i2CountOfEndnotesInPrecedingInterlinearRefs" select="count((descendant::interlinearRef | preceding::interlinearRef)[key('InterlinearReferenceID',@textref)/descendant::endnote])"/>-->
        <xsl:value-of select="$iPreviousEndnotes + $iCountOfEndnotesInPrecedingInterlinearRefs + $iIncludeCurrentInterlinearRef + $iPreviousEndnotesInCurrentInterlinearRef"/>
    </xsl:template>
    <!--  
        GetCountOfEndnotesIncludingAnyInInterlinearRefsBook
    -->
    <xsl:template name="GetCountOfEndnotesIncludingAnyInInterlinearRefsBook">
        <xsl:param name="iAdjust"/>
        <xsl:variable name="iPreviousEndnotes">
            <xsl:variable name="iPreviousEndnotesPass1">
                <xsl:choose>
                    <xsl:when test="$bEndnoteRefIsDirectLinkToEndnote='Y'">
                        <xsl:number level="any" count="endnote[not(parent::author)]" format="1" from="chapter | appendix | glossary | acknowledgements | preface | abstract"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:number level="any" count="endnote[not(ancestor::author)] | endnoteRef[not(ancestor::endnote)][not(@showNumberOnly='yes')]" format="1" from="chapter | appendix | glossary | acknowledgements | preface | abstract"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$iPreviousEndnotesPass1!=''">
                    <xsl:value-of select="$iPreviousEndnotesPass1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="iIncludeCurrentInterlinearRef">
            <xsl:choose>
                <xsl:when test="name()='interlinearRef'">
                    <xsl:value-of select="$iAdjust"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- we use the following for efficiency sake even though we treat some elments the same (i.e. they do not have an @id) -->
        <xsl:variable name="sCurrentAncestorId" select="ancestor::chapter/@id | ancestor::appendix/@id | ancestor::glossary/@id | ancestor::acknowledgements/@id | ancestor::preface/@id | ancestor::abstract/@id"/>
        <xsl:variable name="endnotesInPrecedingInterlinearRefs" select="(descendant::interlinearRef | preceding::interlinearRef)[ancestor::*[@id=$sCurrentAncestorId]][key('InterlinearReferenceID',@textref)/descendant::endnote]"/>
        <xsl:variable name="sCount">
            <xsl:for-each select="$endnotesInPrecedingInterlinearRefs">
                <xsl:variable name="iCountOfEndnotes" select="count(key('InterlinearReferenceID',@textref)/descendant::endnote)"/>
                <xsl:value-of select="substring($sYs,1,$iCountOfEndnotes)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="iCountOfEndnotesInPrecedingInterlinearRefs" select="string-length($sCount)"/>
        <xsl:value-of select="$iPreviousEndnotes + $iCountOfEndnotesInPrecedingInterlinearRefs + $iIncludeCurrentInterlinearRef"/>
    </xsl:template>
    <!--  
        GetExampleNumber
    -->
    <xsl:template name="GetExampleNumber">
        <xsl:param name="example"/>
        <xsl:for-each select="$example">
            <xsl:choose>
                <xsl:when test="ancestor::endnote">
                    <xsl:apply-templates select="." mode="exampleInEndnote"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="example"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!--
        GetFootnoteNumber
    -->
    <xsl:template name="GetFootnoteNumber">
        <xsl:param name="originalContext"/>
        <xsl:param name="iAdjust" select="1"/>
        <xsl:choose>
            <xsl:when test="parent::author">
                <xsl:call-template name="DoAuthorFootnoteNumber"/>
            </xsl:when>
            <xsl:when test="$bIsBook">
                <xsl:choose>
                    <xsl:when test="$originalContext">
                        <xsl:for-each select="$originalContext">
                            <xsl:call-template name="GetCountOfEndnotesIncludingAnyInInterlinearRefsBook">
                                <xsl:with-param name="iAdjust" select="$iAdjust"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="GetCountOfEndnotesIncludingAnyInInterlinearRefsBook">
                            <xsl:with-param name="iAdjust" select="$iAdjust"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <!--                <xsl:choose>
                    <xsl:when test="$originalContext">
                        <xsl:for-each select="$originalContext">
                            <xsl:number level="any" count="endnote[not(ancestor::author)] | endnoteRef[not(ancestor::endnote)][not(@showNumberOnly='yes')]" from="chapter | appendix | glossary | acknowledgements | preface | abstract" format="1"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:number level="any" count="endnote[not(ancestor::author)] | endnoteRef[not(ancestor::endnote)][not(@showNumberOnly='yes')]" from="chapter | appendix | glossary | acknowledgements | preface | abstract" format="1"/>
                    </xsl:otherwise>
                </xsl:choose>
-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$originalContext and ancestor::interlinear-text">
                        <xsl:variable name="iPreviousEndnotesInCurrentInterlinearRef">
                            <xsl:variable name="iIncludingCurrentEndnote">
                                <xsl:number level="any" count="endnote" format="1" from="interlinear[string-length(@text) &gt; 0]"/>
                            </xsl:variable>
                            <xsl:value-of select="number($iIncludingCurrentEndnote) - 1"/>
                        </xsl:variable>
                        <xsl:for-each select="$originalContext">
                            <xsl:call-template name="GetCountOfEndnotesIncludingAnyInInterlinearRefs">
                                <xsl:with-param name="iAdjust" select="$iAdjust"/>
                                <xsl:with-param name="iPreviousEndnotesInCurrentInterlinearRef" select="$iPreviousEndnotesInCurrentInterlinearRef"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--                        <xsl:number level="any" count="endnote[not(parent::author)] | endnoteRef[not(ancestor::endnote)]" format="1"/>-->
                        <xsl:call-template name="GetCountOfEndnotesIncludingAnyInInterlinearRefs">
                            <xsl:with-param name="iAdjust" select="$iAdjust"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        InsertCommaBetweenConsecutiveEndnotes
    -->
    <xsl:template name="InsertCommaBetweenConsecutiveEndnotes">
        <xsl:if test="preceding-sibling::node()[1][name()='endnote' or name()='endnoteRef']">
            <!-- the immediately preceding element is also an endnote; separate the numbers by a comma and non-breaking space -->
            <xsl:text>,&#xa0;</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--
        OutputAbbreviationsInCommaSeparatedList
    -->
    <xsl:template name="OutputAbbreviationsInCommaSeparatedList">
        <xsl:choose>
            <xsl:when test="$lingPaper/@sortRefsAbbrsByDocumentLanguage='yes'">
                <xsl:variable name="sLang">
                    <xsl:call-template name="GetAbbreviationLanguageCode"/>
                </xsl:variable>
                <xsl:for-each select="//abbreviation[//abbrRef[not(ancestor::referencedInterlinearText)]/@abbr=@id]">
                    <xsl:sort lang="{$sLang}" select="abbrInLang[@lang=$sLang or position()=1 and not (following-sibling::abbrInLang[@lang=$sLang])]/abbrTerm"/>
                    <xsl:call-template name="OutputAbbreviationInCommaSeparatedList"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="//abbreviation[//abbrRef[not(ancestor::referencedInterlinearText) or ancestor::interlinear[key('InterlinearRef',@text)]]/@abbr=@id]">
                    <xsl:call-template name="OutputAbbreviationInCommaSeparatedList"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        OutputAbbreviationsLabel
    -->
    <xsl:template name="OutputAbbreviationsLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Abbreviations</xsl:with-param>
            <xsl:with-param name="pLabel" select="//abbreviations/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputAbstractLabel
    -->
    <xsl:template name="OutputAbstractLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Abstract</xsl:with-param>
            <xsl:with-param name="pLabel" select="//abstract/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputAcknowledgementsLabel
    -->
    <xsl:template name="OutputAcknowledgementsLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Acknowledgements</xsl:with-param>
            <xsl:with-param name="pLabel" select="//acknowledgements/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputAuthorFootnoteSymbol
    -->
    <xsl:template name="OutputAuthorFootnoteSymbol">
        <xsl:param name="iAuthorPosition"/>
        <xsl:choose>
            <xsl:when test="$iAuthorPosition &lt; 10">
                <xsl:call-template name="OutputAuthorFootnoteSymbol1-9">
                    <xsl:with-param name="iPos" select="$iAuthorPosition"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="iPos" select="floor($iAuthorPosition div 9)"/>
                <xsl:call-template name="OutputAuthorFootnoteSymbol1-9">
                    <xsl:with-param name="iPos" select="$iPos"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        OutputAuthorFootnoteSymbol1-9
    -->
    <xsl:template name="OutputAuthorFootnoteSymbol1-9">
        <xsl:param name="iPos"/>
        <xsl:choose>
            <xsl:when test="$iPos=1">
                <xsl:text>*</xsl:text>
            </xsl:when>
            <xsl:when test="$iPos=2">
                <xsl:text>†</xsl:text>
            </xsl:when>
            <xsl:when test="$iPos=3">
                <xsl:text>‡</xsl:text>
            </xsl:when>
            <xsl:when test="$iPos=4">
                <xsl:text>§</xsl:text>
            </xsl:when>
            <xsl:when test="$iPos=5">
                <xsl:text>¶</xsl:text>
            </xsl:when>
            <xsl:when test="$iPos=6">
                <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:when test="$iPos=7">
                <xsl:text>**</xsl:text>
            </xsl:when>
            <xsl:when test="$iPos=8">
                <xsl:text>††</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>‡‡</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        OutputContentsLabel
    -->
    <xsl:template name="OutputContentsLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Contents</xsl:with-param>
            <xsl:with-param name="pLabel" select="//contents/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputEndnotesLabel
    -->
    <xsl:template name="OutputEndnotesLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Endnotes</xsl:with-param>
            <xsl:with-param name="pLabel" select="//endnotes/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputExampleLevelISOCode
    -->
    <xsl:template name="OutputExampleLevelISOCode">
        <xsl:param name="bListsShareSameCode"/>
        <xsl:param name="sIsoCode"/>
        <xsl:if test="$lingPaper/@showiso639-3codeininterlinear='yes'">
            <xsl:choose>
                <xsl:when test="listInterlinear or listWord or listSingle">
                    <xsl:if test="not(contains($bListsShareSameCode,'N'))">
                        <xsl:call-template name="OutputISOCodeInExample">
                            <xsl:with-param name="sIsoCode" select="$sIsoCode"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="OutputISOCodeInExample">
                        <xsl:with-param name="sIsoCode" select="$sIsoCode"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!--
        OutputGlossaryLabel
    -->
    <xsl:template name="OutputGlossaryLabel">
        <xsl:param name="iPos" select="'1'"/>
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Glossary</xsl:with-param>
            <xsl:with-param name="pLabel" select="//glossary[$iPos]/@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputIndexLabel
    -->
    <xsl:template name="OutputIndexLabel">
        <xsl:variable name="sDefaultIndexLabel">
            <xsl:choose>
                <xsl:when test="@kind='name'">
                    <xsl:text>Name Index</xsl:text>
                </xsl:when>
                <xsl:when test="@kind='language'">
                    <xsl:text>Language Index</xsl:text>
                </xsl:when>
                <xsl:when test="@kind='subject'">
                    <xsl:text>Subject Index</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Index</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault" select="$sDefaultIndexLabel"/>
            <xsl:with-param name="pLabel" select="@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        OutputIndexTermSeeAloneAfter
    -->
    <xsl:template name="OutputIndexTermSeeAloneAfter">
        <xsl:if test="$indexSeeDefinition">
            <xsl:value-of select="$indexSeeDefinition/seeTerm/afterTerm"/>
        </xsl:if>
        <xsl:text>.</xsl:text>
    </xsl:template>
    <!--  
        OutputIndexTermSeeAloneBefore
    -->
    <xsl:template name="OutputIndexTermSeeAloneBefore">
        <xsl:text>&#xa0;&#xa0;</xsl:text>
        <xsl:choose>
            <xsl:when test="$indexSeeDefinition">
                <xsl:value-of select="$indexSeeDefinition/seeTerm/beforeTerm"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>See</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#x20;</xsl:text>
    </xsl:template>
    <!--  
        OutputIndexTermSeeAfter
    -->
    <xsl:template name="OutputIndexTermSeeAfter">
        <xsl:param name="indexedItems"/>
        <xsl:choose>
            <xsl:when test="$indexedItems">
                <xsl:if test="$indexSeeDefinition">
                    <xsl:value-of select="$indexSeeDefinition/seeAlsoTerm/afterTerm"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$indexSeeDefinition">
                    <xsl:value-of select="$indexSeeDefinition/seeTerm/afterTerm"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>.</xsl:text>
    </xsl:template>
    <!--  
        OutputIndexTermSeeBefore
    -->
    <xsl:template name="OutputIndexTermSeeBefore">
        <xsl:param name="indexedItems"/>
        <xsl:choose>
            <xsl:when test="$indexedItems">
                <xsl:text>.  </xsl:text>
                <xsl:choose>
                    <xsl:when test="$indexSeeDefinition">
                        <xsl:value-of select="$indexSeeDefinition/seeAlsoTerm/beforeTerm"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>See also</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&#x20;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$indexSeeDefinition">
                        <xsl:value-of select="$indexSeeDefinition/seeTerm/beforeTerm"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>See</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&#x20;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputIndexTermsTerm
    -->
    <xsl:template name="OutputIndexTermsTerm">
        <xsl:param name="lang"/>
        <xsl:param name="indexTerm"/>
        <xsl:choose>
            <xsl:when test="$lang and $indexTerm/term[@lang=$lang]">
                <xsl:apply-templates select="$indexTerm/term[@lang=$lang]" mode="InIndex"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$indexTerm/term[1]" mode="InIndex"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputLabel
    -->
    <xsl:template name="OutputLabel">
        <xsl:param name="sDefault"/>
        <xsl:param name="pLabel"/>
        <xsl:choose>
            <xsl:when test="$pLabel">
                <xsl:value-of select="$pLabel"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sDefault"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        OutputPartLabel
    -->
    <xsl:template name="OutputPartLabel">
        <xsl:choose>
            <xsl:when test="$lingPaper/@partlabel">
                <xsl:value-of select="$lingPaper/@partlabel"/>
            </xsl:when>
            <xsl:otherwise>Part</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputPeriodIfNeeded
    -->
    <xsl:template name="OutputPeriodIfNeeded">
        <xsl:param name="sText"/>
        <xsl:variable name="sString">
            <xsl:value-of select="normalize-space($sText)"/>
        </xsl:variable>
        <xsl:if test="substring($sString, string-length($sString))!='.'">
            <xsl:text>.</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--
        OutputPrefaceLabel
    -->
    <xsl:template name="OutputPrefaceLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault">Preface</xsl:with-param>
            <xsl:with-param name="pLabel" select="@label"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputReferencesLabel
    -->
    <xsl:template name="OutputReferencesLabel">
        <xsl:variable name="selectedBibliography" select="//selectedBibliography"/>
        <xsl:choose>
            <xsl:when test="$selectedBibliography">
                <xsl:call-template name="OutputLabel">
                    <xsl:with-param name="sDefault">Selected Bibliography</xsl:with-param>
                    <xsl:with-param name="pLabel" select="$selectedBibliography/@label"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="OutputLabel">
                    <xsl:with-param name="sDefault">References</xsl:with-param>
                    <xsl:with-param name="pLabel" select="//references/@label"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        SortAbbreviationsInTable
    -->
    <xsl:template name="SortAbbreviationsInTable">
        <xsl:param name="abbrsUsed"/>
        <xsl:choose>
            <xsl:when test="$lingPaper/@sortRefsAbbrsByDocumentLanguage='yes'">
                <xsl:variable name="sLang">
                    <xsl:call-template name="GetAbbreviationLanguageCode"/>
                </xsl:variable>
                <xsl:for-each select="$abbrsUsed">
                    <xsl:sort lang="{$sLang}" select="abbrInLang[@lang=$sLang or position()=1 and not (following-sibling::abbrInLang[@lang=$sLang])]/abbrTerm"/>
                    <xsl:call-template name="OutputAbbreviationInTable"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$abbrsUsed">
                    <xsl:call-template name="OutputAbbreviationInTable"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
