<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="1.0" exclude-result-prefixes="xhtml">
    <!-- 
        Variables and templates common to all "canned" style sheets.
    -->
    <xsl:variable name="gtAuthors" select="//refAuthor[refWork/@id=//citation[ancestor::glossaryTerm[key('GlossaryTermRefs',@id)]]/@ref]"/>
    <xsl:variable name="otherAuthors" select="//refAuthor[refWork[@id=$citations[not(ancestor::comment) and not(ancestor::referencedInterlinearText) and not(ancestor::glossaryTerm) and not(ancestor::abbrDefinition)][not(ancestor::refWork) or ancestor::annotation[@id=//annotationRef/@annotation] or ancestor::refWork[@id=$citations[not(ancestor::refWork)]/@ref]]/@ref]]"/>
    <!--  
        dateLetter
    -->
    <xsl:template mode="dateLetter" match="*">
        <xsl:param name="date"/>
        <xsl:number level="single" count="refWork[@id=//citation/@ref][refDate=$date or refDate/@citedate=$date]" format="a"/>
    </xsl:template>
    <!--
        DoAppendixRef
    -->
    <xsl:template name="DoAppendixRef">
        <xsl:variable name="appendix" select="id(@app)"/>
        <xsl:choose>
            <xsl:when test="@showTitle='short'">
                <xsl:choose>
                    <xsl:when test="$appendix/shortTitle and string-length($appendix/shortTitle) &gt; 0">
                        <xsl:apply-templates select="$appendix/shortTitle/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$appendix/secTitle/child::node()[name()!='endnote']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@showTitle='full'">
                <xsl:apply-templates select="$appendix/secTitle/child::node()[name()!='endnote']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$appendix" mode="numberAppendix"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoCollectionEdition
    -->
    <xsl:template name="DoCollectionEdition">
        <xsl:if test="collection/edition">
            <xsl:text>&#x20;</xsl:text>
            <xsl:apply-templates select="collection/edition"/>
            <xsl:call-template name="OutputPeriodIfNeeded">
                <xsl:with-param name="sText" select="collection/edition"/>
            </xsl:call-template>
            <xsl:text>&#x20;</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--  
        DoExampleRefContent
    -->
    <xsl:template name="DoExampleRefContent">
        <xsl:if test="not(@paren) or @paren='both' or @paren='initial'">(</xsl:if>
        <xsl:if test="@equal='yes'">=</xsl:if>
        <xsl:choose>
            <xsl:when test="@letter and name(id(@letter))!='example'">
                <xsl:if test="not(@letterOnly='yes')">
                    <!--                        <xsl:apply-templates select="id(@letter)" mode="example"/>-->
                    <xsl:call-template name="GetExampleNumber">
                        <xsl:with-param name="example" select="id(@letter)"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:apply-templates select="id(@letter)" mode="letter"/>
            </xsl:when>
            <xsl:when test="@num">
                <!--                    <xsl:apply-templates select="id(@num)" mode="example"/>-->
                <xsl:call-template name="GetExampleNumber">
                    <xsl:with-param name="example" select="id(@num)"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="@punct">
            <xsl:value-of select="@punct"/>
        </xsl:if>
        <xsl:if test="not(@paren) or @paren='both' or @paren='final'">)</xsl:if>
    </xsl:template>
    <!--  
        DoFigureRef
    -->
    <xsl:template name="DoFigureRef">
        <xsl:variable name="figure" select="id(@figure)"/>
        <xsl:choose>
            <xsl:when test="@showCaption='short'">
                <xsl:choose>
                    <xsl:when test="$figure/shortCaption and string-length($figure/shortCaption) &gt; 0">
                        <xsl:apply-templates select="$figure/shortCaption/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$figure/caption/child::node()[name()!='endnote']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@showCaption='full'">
                <xsl:apply-templates select="$figure/caption/child::node()[name()!='endnote']"/>
            </xsl:when>
            <xsl:otherwise>
                <!--                <xsl:apply-templates select="$figure" mode="figure"/>-->
                <xsl:call-template name="GetFigureNumber">
                    <xsl:with-param name="figure" select="$figure"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoInterlinearRefCitationShowTitleOnly
    -->
    <xsl:template name="DoInterlinearRefCitationShowTitleOnly">
        <xsl:variable name="interlinear" select="key('InterlinearReferenceID',@textref)"/>
        <xsl:choose>
            <xsl:when test="@showTitleOnly='short'">
                <!-- only one of these will work -->
                <xsl:apply-templates select="$interlinear/textInfo/shortTitle/child::node()[name()!='endnote']"/>
                <xsl:apply-templates select="$interlinear/../textInfo/shortTitle/child::node()[name()!='endnote']"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- only one of these will work -->
                <xsl:apply-templates select="$interlinear/textInfo/textTitle/child::node()[name()!='endnote']"/>
                <xsl:apply-templates select="$interlinear/../textInfo/textTitle/child::node()[name()!='endnote']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoItemRefLabel
    -->
    <xsl:template name="DoItemRefLabel">
        <xsl:param name="sLabel"/>
        <xsl:param name="sDefault"/>
        <xsl:choose>
            <xsl:when test="string-length($sLabel) &gt; 0">
                <xsl:value-of select="$sLabel"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$sDefault"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoReferenceShowTitleAfter
    -->
    <xsl:template name="DoReferenceShowTitleAfter">
        <xsl:param name="showTitle"/>
        <xsl:if test="$showTitle='short' or $showTitle='full'">
            <xsl:text>”</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--  
        DoReferenceShowTitleBefore
    -->
    <xsl:template name="DoReferenceShowTitleBefore">
        <xsl:param name="showTitle"/>
        <xsl:if test="$showTitle='short' or $showTitle='full'">
            <xsl:text>“</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--  
        DoReprintInfo
    -->
    <xsl:template name="DoReprintInfo">
        <xsl:param name="reprintInfo"/>
        <xsl:if test="$reprintInfo">
            <xsl:text>&#x20;</xsl:text>
            <xsl:apply-templates select="$reprintInfo"/>
            <xsl:text>.</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--  
        DoSectionRef
    -->
    <xsl:template name="DoSectionRef">
        <xsl:variable name="section" select="id(@sec)"/>
        <xsl:choose>
            <xsl:when test="@showTitle='short'">
                <xsl:choose>
                    <xsl:when test="$section/shortTitle and string-length($section/shortTitle) &gt; 0">
                        <xsl:apply-templates select="$section/shortTitle/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:when test="$section/frontMatter/shortTitle and string-length($section/frontMatter/shortTitle) &gt; 0">
                        <xsl:apply-templates select="$section/frontMatter/shortTitle/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:when test="name($section)='chapterInCollection'">
                        <xsl:apply-templates select="$section/frontMatter/title/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$section/secTitle/child::node()[name()!='endnote']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@showTitle='full'">
                <xsl:choose>
                    <xsl:when test="name($section)='chapterInCollection'">
                        <xsl:apply-templates select="$section/frontMatter/title/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$section/secTitle/child::node()[name()!='endnote']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="name($section)='part'">
                <xsl:apply-templates select="$section" mode="numberPart"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$section" mode="number"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        DoTablenumberedRef
    -->
    <xsl:template name="DoTablenumberedRef">
        <xsl:variable name="table" select="id(@table)"/>
        <xsl:choose>
            <xsl:when test="@showCaption='short'">
                <xsl:choose>
                    <xsl:when test="$table/shortCaption and string-length($table/shortCaption) &gt; 0">
                        <xsl:apply-templates select="$table/shortCaption/child::node()[name()!='endnote']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$table/table/caption/child::node()[name()!='endnote']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@showCaption='full'">
                <xsl:apply-templates select="$table/table/caption/child::node()[name()!='endnote']"/>
            </xsl:when>
            <xsl:otherwise>
                <!--                <xsl:apply-templates select="$table" mode="tablenumbered"/>-->
                <xsl:call-template name="GetTableNumberedNumber">
                    <xsl:with-param name="tablenumbered" select="$table"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--
        HandleLiteralLabelLayoutInfo
    -->
    <xsl:template name="HandleLiteralLabelLayoutInfo" priority="-1">
        <xsl:param name="layoutInfo"/>
        <!-- default is to do nothing -->
    </xsl:template>
    <!--
        OutputAnyTextBeforeRef
    -->
    <xsl:template name="OutputAnyTextBeforeRef">
        <!-- output any canned text before the section reference -->
        <xsl:param name="ssingular" select="'section'"/>
        <xsl:param name="splural" select="'sections'"/>
        <xsl:param name="sSingular" select="'Section'"/>
        <xsl:param name="sPlural" select="'Sections'"/>
        <xsl:param name="default" select="$lingPaper/@sectionRefDefault"/>
        <xsl:param name="singularLabel" select="$lingPaper/@sectionRefSingularLabel"/>
        <xsl:param name="SingularLabel" select="$lingPaper/@sectionRefCapitalizedSingularLabel"/>
        <xsl:param name="pluralLabel" select="$lingPaper/@sectionRefPluralLabel"/>
        <xsl:param name="PluralLabel" select="$lingPaper/@sectionRefCapitalizedPluralLabel"/>
        <xsl:choose>
            <xsl:when test="@textBefore='useDefault'">
                <xsl:choose>
                    <xsl:when test="$default='none'">
                        <!-- do nothing -->
                    </xsl:when>
                    <xsl:when test="$default='singular'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$singularLabel"/>
                            <xsl:with-param name="sDefault" select="$ssingular"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$default='capitalizedSingular'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$SingularLabel"/>
                            <xsl:with-param name="sDefault" select="$sSingular"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$default='plural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$pluralLabel"/>
                            <xsl:with-param name="sDefault" select="$splural"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$default='capitalizedPlural'">
                        <xsl:call-template name="DoItemRefLabel">
                            <xsl:with-param name="sLabel" select="$PluralLabel"/>
                            <xsl:with-param name="sDefault" select="$sPlural"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@textBefore='singular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$singularLabel"/>
                    <xsl:with-param name="sDefault" select="$ssingular"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedSingular'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$SingularLabel"/>
                    <xsl:with-param name="sDefault" select="$sSingular"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='plural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$pluralLabel"/>
                    <xsl:with-param name="sDefault" select="$splural"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@textBefore='capitalizedPlural'">
                <xsl:call-template name="DoItemRefLabel">
                    <xsl:with-param name="sLabel" select="$PluralLabel"/>
                    <xsl:with-param name="sDefault" select="$sPlural"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
        OutputAnyTextBeforeAppendixRef
    -->
    <xsl:template name="OutputAnyTextBeforeAppendixRef">
        <xsl:call-template name="OutputAnyTextBeforeRef">
            <xsl:with-param name="ssingular" select="'appendix'"/>
            <xsl:with-param name="sSingular" select="'Appendix'"/>
            <xsl:with-param name="splural" select="'appendices'"/>
            <xsl:with-param name="sPlural" select="'Appendices'"/>
            <xsl:with-param name="default" select="$lingPaper/@appendixRefDefault"/>
            <xsl:with-param name="singularLabel" select="$lingPaper/@appendixRefSingularLabel"/>
            <xsl:with-param name="SingularLabel" select="$lingPaper/@appendixRefCapitalizedSingularLabel"/>
            <xsl:with-param name="pluralLabel" select="$lingPaper/@appendixRefPluralLabel"/>
            <xsl:with-param name="PluralLabel" select="$lingPaper/@appendixRefCapitalizedPluralLabel"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputAnyTextBeforeFigureRef
    -->
    <xsl:template name="OutputAnyTextBeforeFigureRef">
        <xsl:call-template name="OutputAnyTextBeforeRef">
            <xsl:with-param name="ssingular" select="'figure'"/>
            <xsl:with-param name="sSingular" select="'Figure'"/>
            <xsl:with-param name="splural" select="'figures'"/>
            <xsl:with-param name="sPlural" select="'Figures'"/>
            <xsl:with-param name="default" select="$lingPaper/@figureRefDefault"/>
            <xsl:with-param name="singularLabel" select="$lingPaper/@figureRefSingularLabel"/>
            <xsl:with-param name="SingularLabel" select="$lingPaper/@figureRefCapitalizedSingularLabel"/>
            <xsl:with-param name="pluralLabel" select="$lingPaper/@figureRefPluralLabel"/>
            <xsl:with-param name="PluralLabel" select="$lingPaper/@figureRefCapitalizedPluralLabel"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputAnyTextBeforeSectionRef
    -->
    <xsl:template name="OutputAnyTextBeforeSectionRef">
        <xsl:call-template name="OutputAnyTextBeforeRef">
            <xsl:with-param name="ssingular" select="'section'"/>
            <xsl:with-param name="sSingular" select="'Section'"/>
            <xsl:with-param name="splural" select="'sections'"/>
            <xsl:with-param name="sPlural" select="'Sections'"/>
            <xsl:with-param name="default" select="$lingPaper/@sectionRefDefault"/>
            <xsl:with-param name="singularLabel" select="$lingPaper/@sectionRefSingularLabel"/>
            <xsl:with-param name="SingularLabel" select="$lingPaper/@sectionRefCapitalizedSingularLabel"/>
            <xsl:with-param name="pluralLabel" select="$lingPaper/@sectionRefPluralLabel"/>
            <xsl:with-param name="PluralLabel" select="$lingPaper/@sectionRefCapitalizedPluralLabel"/>
        </xsl:call-template>
    </xsl:template>
    <!--
        OutputAnyTextBeforeTablenumberedRef
    -->
    <xsl:template name="OutputAnyTextBeforeTablenumberedRef">
        <xsl:call-template name="OutputAnyTextBeforeRef">
            <xsl:with-param name="ssingular" select="'table'"/>
            <xsl:with-param name="sSingular" select="'Table'"/>
            <xsl:with-param name="splural" select="'tables'"/>
            <xsl:with-param name="sPlural" select="'Tables'"/>
            <xsl:with-param name="default" select="$lingPaper/@sectionRefDefault"/>
            <xsl:with-param name="singularLabel" select="$lingPaper/@tablenumberedRefSingularLabel"/>
            <xsl:with-param name="SingularLabel" select="$lingPaper/@tablenumberedRefCapitalizedSingularLabel"/>
            <xsl:with-param name="pluralLabel" select="$lingPaper/@tablenumberedRefPluralLabel"/>
            <xsl:with-param name="PluralLabel" select="$lingPaper/@tablenumberedRefCapitalizedPluralLabel"/>
        </xsl:call-template>
    </xsl:template>
    <!--  
        OutputCitationContents
    -->
    <xsl:template name="OutputCitationContents">
        <xsl:param name="refer"/>
        <xsl:param name="refWorks" select="$refWorks"/>
        <xsl:if test="@paren='citationBoth' or @paren='citationInitial'">
            <xsl:text>(</xsl:text>
        </xsl:if>
        <xsl:if test="@author='yes'">
            <xsl:choose>
                <xsl:when test="$refer/../citeName">
                    <xsl:apply-templates select="$refer/../citeName"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$refer/../citeName">
                            <xsl:apply-templates select="$refer/../citeName"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$refer/../@citename"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="@date='yes'">
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="not(@paren) or @paren='both' or @paren='initial'">
            <xsl:text>(</xsl:text>
        </xsl:if>
        <xsl:variable name="works" select="$refWorks[../@name=$refer/../@name and @id=//citation/@ref]"/>
        <xsl:variable name="date">
            <xsl:variable name="sCiteDate" select="$refer/refDate/@citedate"/>
            <xsl:choose>
                <xsl:when test="string-length($sCiteDate) &gt; 0">
                    <xsl:value-of select="$sCiteDate"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$refer/refDate"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="@author='yes' and not(not(@paren) or @paren='both' or @paren='initial')">
            <xsl:if test="@date='yes'">
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:if test="@date!='no'">
            <xsl:value-of select="$date"/>
            <xsl:if test="count($works[refDate=$date or refDate/@citedate=$date])>1">
                <xsl:apply-templates select="$refer" mode="dateLetter">
                    <xsl:with-param name="date" select="$date"/>
                </xsl:apply-templates>
           </xsl:if>
        </xsl:if>
        <xsl:variable name="sPage" select="normalize-space(@page)"/>
        <xsl:if test="string-length($sPage) &gt; 0">
            <xsl:text>:</xsl:text>
            <xsl:value-of select="$sPage"/>
        </xsl:if>
        <xsl:variable name="sTimestamp" select="normalize-space(@timestamp)"/>
        <xsl:if test="string-length($sTimestamp) &gt; 0">
            <xsl:text>&#x20;</xsl:text>
            <xsl:value-of select="$sTimestamp"/>
        </xsl:if>
        <xsl:if test="not(@paren) or @paren='both' or @paren='final' or @paren='citationBoth'">
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>
    <!--  
        OutputFigureLabel
    -->
    <xsl:template name="OutputFigureLabel">
        <xsl:variable name="label" select="$lingPaper/@figureLabel"/>
        <xsl:choose>
            <xsl:when test="string-length($label) &gt; 0">
                <xsl:value-of select="$label"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Figure </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--  
        OutputPaperLabel
    -->
    <xsl:template name="OutputPaperLabel">
        <xsl:call-template name="OutputLabel">
            <xsl:with-param name="sDefault" select="$sPaperDefaultLabel"/>
            <xsl:with-param name="pLabel">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space(paper/@labelPaper)) &gt; 0">
                        <xsl:value-of select="paper/@labelPaper"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="//references/@labelPaper"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
