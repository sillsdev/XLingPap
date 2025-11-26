<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" defaultPhase="check">
    <phase id="empty"/>
    <phase id="check">
        <active pattern="line"/>
        <active pattern="lineGroup"/>
        <active pattern="nestings"/>
        <active pattern="notimplemented"/>
        <active pattern="headers"/>
        <active pattern="tablewidths"/>
        <active pattern="deprecatedtable"/>
        <active pattern="columns"/>
        <active pattern="tripleqs"/>
        <active pattern="book"/>
        <active pattern="paper"/>
        <active pattern="definitions"/>
        <active pattern="interlinears"/>
        <active pattern="lineembeded"/>
        <!-- following no longer relevant -->
<!--        <active pattern="badbr"/>-->
        <active pattern="deprecatedsmallcaps"/>
        <active pattern="deprecatedsmallcaps2"/>
        <active pattern="fontsize"/>
        <active pattern="index"/>
        <active pattern="linebefore-weight"/>
        <active pattern="startpagenumber"/>
        <active pattern="graphics"/>
        <active pattern="pubstylesheets"/>
        <active pattern="abbreviationsShownHere"/>
        <active pattern="contentType"/>
        <active pattern="chapterInCollection"/>
        <active pattern="verticalspacing"/>
        <active pattern="contentTypeLocation"/>
        <active pattern="abbrRef"/>
        <active pattern="endnoteInSecTitle"/>
        <active pattern="indexRangeInSecTitle"/>
        <active pattern="deprecatedethnCode"/>
        <active pattern="glossaryTermRefersToItself"/>
        <active pattern="emptycitation"/>
    </phase>
    <pattern id="line">
        <title>
            <dir value="ltr">Well-formed line elements</dir>
        </title>
        <rule context="line">
            <assert test="count(langData) &lt;= 1">Too many langData elements in this line element.  Use only one langData in order to produce properly aligned output.</assert>
            <assert test="count(gloss) &lt;= 1">Too many gloss elements in this line element.  Use only one gloss in order to produce properly aligned output.</assert>
            <report test="langData/object">Using an object element within a langData element here will not produce the correct output.  Use wrd elements within this line element instead.  See section 5.3.1.2 "Word-aligned, marking certain words or morphemes" in the XLingPaper user documentation.</report>
            <report test="langData/endnote">Using an endnote element within a langData element here will not produce the correct output.  Use wrd elements within this line element instead.  See section 5.3.1.2 "Word-aligned, marking certain words or morphemes" in the XLingPaper user documentation.</report>
            <report test="gloss/object">Using an object element within a gloss element here will not produce the correct output.  Use wrd elements within this line element instead.  See section 5.3.1.2 "Word-aligned, marking certain words or morphemes" in the XLingPaper user documentation.</report>
            <report test="gloss/abbrRef">Using an abbrRef element within a gloss element here will not produce the correct output.  Use wrd elements within this line element instead.  See section 5.3.1.2 "Word-aligned, marking certain words or morphemes" in the XLingPaper user documentation.</report>
            <report test="gloss/endnote">Using an endnote element within a gloss element here will not produce the correct output.  Use wrd elements within this line element instead.  See section 5.3.1.2 "Word-aligned, marking certain words or morphemes" in the XLingPaper user documentation.</report>
        </rule>
    </pattern>
    <pattern id="lineGroup">
        <title>
            <dir value="ltr">Consistent line elements within a lineGroup</dir>
        </title>
        <rule context="lineGroup">
            <report test="line[count(wrd) &gt; 0] and line[count(wrd)=0]">Some of the line elements in this lineGroup have been converted to use wrd elements and some have not.  All line elements within a lineGroup should be the same: either all using wrd or all not using wrd.  The formatted output may leave out some lines.  Please use the XLingPaper menu item / 'Convert interlinear line to wrd elements' for all lines in this lineGroup.</report>
        </rule>
        <rule context="line">
<!--            <report test="count(line) = 3 and line[count(wrd)] != line[count(wrd)]">Not all of the lines in this interlinear lineGroup have the same number of wrd elements.  The alignment will probably be incorrect.</report>-->
            <report test="preceding-sibling::line[1] and count(preceding-sibling::line[1]/wrd[not(exampleRef)]) != count(wrd)">This line has a different number of wrd elements in it than its immediately preceding line.  The alignment will probably be incorrect.</report>
        </rule>
    </pattern>
    <pattern id="nestings">
        <title>
            <dir value="ltr">Check for nested langData, nested gloss, and nested link elements</dir>
        </title>
        <rule context="langData">
            <report test="parent::langData and string-length(normalize-space(parent::langData)) = string-length(normalize-space(.))">There is a langData embedded within a langData here for no apparent reason.   To fix this, click on the numbered link, then, using the mouse, do a copy; next click on the enclosing langData element in the Node Path Bar and finally do a paste.</report>
        </rule>
        <rule context="gloss">
            <report test="parent::gloss and string-length(normalize-space(parent::gloss)) = string-length(normalize-space(.))">There is a gloss embedded within a gloss here for no apparent reason.   To fix this, click on the numbered link, then, using the mouse, do a copy; next click on the enclosing gloss element in the Node Path Bar and finally do a paste.</report>
        </rule>
        <rule context="link">
            <report test="parent::link and string-length(normalize-space(parent::link)) = string-length(normalize-space(.))">There is a link embedded within a link here for no apparent reason.   To fix this, click on the numbered link, then, using the mouse, do a copy; next click on the enclosing link element in the Node Path Bar and finally do a paste.</report>
        </rule>
    </pattern>
    <pattern id="notimplemented">
        <title>
            <dir value="ltr">Check for yet-to-be-implemented elements</dir>
        </title>
        <rule context="conflatedLine">
            <report test=".">The conflatedLing element has no been implemented fully yet.  Please do not use it.</report>
        </rule>
        <rule context="lineSet">
            <report test=".">The lineSet element has no been implemented fully yet.  Please do not use it.</report>
        </rule>
        <rule context="lineSetRow">
            <report test=".">The lineSetRow element has no been implemented fully yet.  Please do not use it.</report>
        </rule>
    </pattern>
    <pattern id="headers">
        <title>
            <dir value="ltr">Check for partial table header rows</dir>
        </title>
        <rule context="table">
            <report test="not(ancestor::table) and count(tr) &gt; 5 and tr[1]/th and tr[1]/td">Warning: the first row of this table has some th cells , but it also has some td cells.  If the table goes beyond a page, no header will be repeated.  To fix this, convert the td cells to th cells (and use object elements to get the fomatting you want). </report>
        </rule>
    </pattern>
    <pattern id="tablewidths">
        <title>
            <dir value="ltr">Check for invalid table widths (e.g., missing unit of measure)</dir>
        </title>
        <rule context="td | th">
            <report test="string-length(normalize-space(@width)) &gt; 0 and substring(normalize-space(@width),string-length(normalize-space(@width))-1,2)!='in' and substring(normalize-space(@width),string-length(normalize-space(@width))-1,2)!='mm' and substring(normalize-space(@width),string-length(normalize-space(@width))-1,2)!='cm' and substring(normalize-space(@width),string-length(normalize-space(@width))-1,2)!='pt' and substring(normalize-space(@width),string-length(normalize-space(@width)),1)!='%'">Warning: this table cell has a width specified but it does not have a proper unit of measure.   The PDF may fail to be produced.</report>
            <report test="contains(normalize-space(@width),' ')">Warning: this table cell has a width specified but it contains a space.  There should not be a space between the number and the unit of measure.  The result may not be what you want. </report>
            <report test="contains(@width,' ')">Warning: this table cell has a width specified but it contains a space.  The PDF may not be produced.  Please remove the space.</report>
        </rule>
    </pattern>
    <pattern id="deprecatedtable">
        <title>
            <dir value="ltr">Check for deprecated table elements</dir>
        </title>
        <rule context="col">
            <report test=".">Warning: the col element is deprecated.  Please replace it with a td element. </report>
        </rule>
        <rule context="headerCol">
            <report test=".">Warning: the headerCol element is deprecated.  Please replace it with a th element. </report>
        </rule>
        <rule context="headerRow">
            <report test=".">Warning: the headerRow element is deprecated.  Please replace it with a tr element. </report>
        </rule>
        <rule context="row">
            <report test=".">Warning: the row element is deprecated.  Please replace it with a tr element. </report>
        </rule>
    </pattern>
    <pattern id="columns">
        <title>
            <dir value="ltr">Check for inconsistent column counts</dir>
        </title>
        <rule context="table">
            <report test="count(tr[1]/*[not(number(@colspan) &gt; 0)]) + sum(tr[1]/*[number(@colspan) &gt; 0]/@colspan) &lt; count(tr[2]/*[not(number(@colspan) &gt; 0)]) + sum(tr[2]/*[number(@colspan) &gt; 0]/@colspan)">Warning: the first row of this table does not have the same number of columns as the second row.  The XeLaTex way of producing PDF will fail.  Please make sure every row has the same number of columns (including any colspan attributes).</report>
        </rule>
    </pattern>
    <pattern id="tripleqs">
        <title>
            <dir value="ltr">Check for yet-to-be-filled-out "???" attribute values</dir>
        </title>
        <rule context="refAuthor">
            <report test="@citename='???' or @name='???'">Warning: A refAuthor still has a citename and/or name attribute that contains '???'.  Please fill out the proper content. </report>
        </rule>
        <rule context="link">
            <report test="@href='???'">Warning: A link element's href attribute is still set to '???'.  Please fill out the proper content using the Attributes Editor. </report>
        </rule>
        <rule context="img">
            <report test="@src='fileName'">Warning: An img element's src attribute is still set to 'fileName'.  Please fill out the real name of the file using the Attributes Editor. </report>
        </rule>
    </pattern>
    <pattern id="book">
        <title>
            <dir value="ltr">Check for book with improper header and footer layouts</dir>
        </title>
        <rule context="publisherStyleSheet">
            <report test="//chapter and pageLayout/headerFooterPageStyles">Warning: this is a book but it is trying to use a paper-oriented publisher style sheet (i.e. it has the header and footer layout information under page layout instead of under both front matter layout and body layout).  The XeLaTex way of producing PDF will fail.  Please associate this document with a *book* publisher style sheet..</report>
            <report test="//chapter and frontMatterLayout[not(titleHeaderFooterPageStyles)]">Warning: this is a book but it is trying to use a publisher style sheet that does not have header and footer layout information for titles under the front matter layout.  The XeLaTex way of producing PDF will fail or not be correct.  Please fix this by adding the correct header and footer layout information or by associating this document with a book publisher style sheet..</report>
            <report test="//chapter and frontMatterLayout[not(headerFooterPageStyles)]">Warning: this is a book but it is trying to use a publisher style sheet that does not have header and footer layout information for non-title front matter pages under the front matter layout.  The XeLaTex way of producing PDF will fail or not be correct.  Please fix this by adding the correct header and footer layout information or by associating this document with a book publisher style sheet..</report>
            <report test="//chapter and bodyLayout[not(headerFooterPageStyles)]">Warning: this is a book but it is trying to use a publisher style sheet that does not have header and footer layout information under the body layout.  The XeLaTex way of producing PDF will fail or not be correct.  Please fix this by adding the correct header and footer layout information or by associating this document with a book publisher style sheet..</report>
        </rule>
    </pattern>
    <pattern id="paper">
        <title>
            <dir value="ltr">Check for paper with improper header and footer layouts</dir>
        </title>
        <rule context="publisherStyleSheet">
            <report test="//lingPaper and not(//chapter | //chapterInCollection) and pageLayout[not(headerFooterPageStyles)]">Warning: this is a paper but it is trying to use a book-oriented publisher style sheet (i.e. it has the header and footer layout information under both front matter layout and body layout instead of under page layout).  The XeLaTex way of producing PDF will fail.  Please associate this document with a *paper* publisher style sheet..</report>
            <report test="//lingPaper and not(//chapter | //chapterInCollection) and frontMatterLayout/titleHeaderFooterPageStyles">Warning: this is a paper but it is trying to use a publisher style sheet that has header and footer layout information for titles under the front matter layout.  The XeLaTex way of producing PDF will fail or not be correct.  Please fix this by removing the unneeded title header and footer layout information or by associating this document with a paper publisher style sheet..</report>
            <report test="//lingPaper and not(//chapter | //chapterInCollection) and frontMatterLayout/headerFooterPageStyles">Warning: this is a paper but it is trying to use a publisher style sheet that has header and footer layout information for non-title front matter pages under the front matter layout.  The XeLaTex way of producing PDF will fail or not be correct.  Please fix this by removing the header and footer layout information for the non-title front matter or by associating this document with a paper publisher style sheet..</report>
            <report test="//lingPaper and not(//chapter | //chapterInCollection) and bodyLayout/headerFooterPageStyles">Warning: this is a paper but it is trying to use a publisher style sheet that has header and footer layout information under the body layout.  The XeLaTex way of producing PDF will fail or not be correct.  Please fix this by removing the header and footer layout information in the body layout or by associating this document with a paper publisher style sheet..</report>
        </rule>
    </pattern>
    <pattern id="definitions">
        <title>
            <dir value="ltr">Check for ill-formed definitions</dir>
        </title>
        <rule context="definition">
            <report test="ancestor::p and descendant::ul or ancestor::p and descendant::ol">Warning: there is a definition in a paragraph that has an embedded list in it.  This will probably not come out very well.  Please consider making it be an example(definition) instead.</report>
        </rule>
    </pattern>
    <!--  This is not the correct semantic check.  One *should* be able to have something like language-date tone-data gloss  
    <pattern>
        <title>
            <dir value="ltr">Check for poorly formed word and listWord elements</dir>
        </title>
        <rule context="listWord">
            <report test="count(langData) + count(gloss) &gt; 2">Warning: There is a listWord element with more than two langData and gloss elements.  This is not the intended use of listWord so it may not come out as you want.  Please consider splitting this into multiple example(listWord) items with only a single pair of langData and gloss in each or consider making it be an example(table).</report>
        </rule>
        <rule context="word">
            <report test="count(langData) + count(gloss) &gt; 2">Warning: There is a word element with more than two langData and gloss elements.  This is not the intended use of listWord so it may not come out as you want.  Please consider splitting this into multiple example(listWord) items with only a single pair of langData and gloss in each or consider making it be an example(table).</report>
        </rule>
    </pattern>
-->
    <pattern id="interlinears">
        <title>
            <dir value="ltr">Check for improperly embedded interlinears</dir>
        </title>
        <rule context="interlinear">
            <report test="ancestor::table and descendant::endnote and not(parent::example)">Warning: There is an interlinear within a table and that interlinear contains an endnote somewhere.  This will fail to produce the PDF using the XeLaTex method.  Furthermore, the other outputs will probably not format correctly.  Please consider Convert/wrapping the interlinear within an example or using something else for the interlinear.</report>
        </rule>
        <rule context="interlinearSource">
            <report test="ancestor::interlinear-text">Warning: There is an interlinearSource element within an interlinear inside an interlinear-text.  This is not appropriate and not needed.  Please remove the interlinearSource element.</report>
        </rule>
    </pattern>
    <pattern id="lineembeded">
        <title>
            <dir value="ltr">Check for embedded elements in  line/langData or line/gloss</dir>
        </title>
        <rule context="langData">
            <report test="parent::line and descendant::*[name()='endnoteRef' or name()='citation' or name()='langData' or name()='gloss' or name()='exampleRef' or name()='sectionRef' or name()='appendixRef' or name()='comment' or name()='br' or name()='figureRef' or name()='tablenumberedRef' or name()='q' or name()='img' or name()='genericRef' or name()='genericTarget' or name()='link' or name()='indexedItem' or name()='indexedRangeBegin' or name()='indexedRangeEnd' or name()='interlinearRefCitation' or name()='mediaObject']"
                >Warning: There is an interlinear using the space alignment and there is a langData element with an embedded element (e.g. citation or endnoteRef).  This will not format correctly.  To fix this, please remove each such embedded element (you can cut and paste them in a paragraph somewhere to save your work).  Then see section 5.3.1.2 'Word-aligned, marking certain words or morphemes' of the user documentation for how to convert what you have to wrd elements. </report>
        </rule>
        <rule context="gloss">
            <report test="parent::line and descendant::*[name()='endnoteRef' or name()='citation' or name()='langData' or name()='gloss' or name()='exampleRef' or name()='sectionRef' or name()='appendixRef' or name()='comment' or name()='br' or name()='figureRef' or name()='tablenumberedRef' or name()='q' or name()='img' or name()='genericRef' or name()='genericTarget' or name()='link' or name()='indexedItem' or name()='indexedRangeBegin' or name()='indexedRangeEnd' or name()='interlinearRefCitation' or name()='mediaObject']">Warning: There is an interlinear using the space alignment and there is a gloss element with an embedded element (e.g. citation or endnoteRef).  This will not format correctly.  To fix this, please remove each such embedded element (you can cut and paste them in a paragraph somewhere to save your work).  Then see section 5.3.1.2 'Word-aligned, marking certain words or morphemes' of the user documentation for how to convert what you have to wrd elements. </report>
        </rule>
    </pattern>
<!-- This no longer causes the PDF to fail. 
    <pattern id="badbr">
        <title>
            <dir value="ltr">Check for br elements within a line in an interlinear</dir>
        </title>
        <rule context="line">
            <report test="descendant::br"
                >Warning: There is a br element within an interlinear.  This will not produce PDF output.  Please either use an example(chart) or a table to do what you have in mind. </report>
        </rule>
    </pattern>-->
    <pattern id="deprecatedsmallcaps">
        <title>
            <dir value="ltr">Check for abbreviation element with @usesmallcaps='Y'</dir>
        </title>
        <rule context="abbreviations">
            <report test="@usesmallcaps='yes'">Warning: The 'usesmallcaps' attribute is now deprecated.  Please use a real, true-blue small-caps font and put its name in the font-family attribute.</report>
        </rule>
    </pattern>
    <pattern id="deprecatedsmallcaps2">
        <title>
            <dir value="ltr">Check for use of font-variant='small-caps'</dir>
        </title>
        <rule context="/lingPaper/languages/language | /lingPaper/types/type | /xlingpaper/styledPaper/lingPaper/languages/language | /xlingpaper/styledPaper/lingPaper/types/type | /xlingpaper/styledPaper/publisherStyleSheet//* | /publisherStyleSheet//*">
            <report test="@font-variant='small-caps'">Warning: using a font-variant of 'small-caps' is now deprecated.  Please use a real, true-blue small-caps font and put its name in the font-family attribute.  Also be sure to either remove the font-variant attribute or at least set it to 'normal'.</report>
        </rule>
    </pattern>
    <pattern id="index">
        <title>
            <dir value="ltr">Check for issues related to indexes</dir>
        </title>
        <rule context="indexTerm">
            <report test="@see=@id">The 'see' attribute of this indexTerm is referring to itself.  It should refer to a different indexTerm element.</report>
        </rule>
    </pattern>
    <pattern id="linebefore-weight">
        <title>Check for ill-formed linebefore-weight attribute values</title>
        <rule context="*/@linebefore-weight">
            <report test="contains(normalize-space(.),' ')">The linebefore-weight attribute should not contain a space. Please remove it.</report>
            <report test="string-length(normalize-space(.)) &gt; 0 and substring(normalize-space(.),string-length(normalize-space(.))-1,2)!='pt'">Warning: this linebefore-weight attribute does not end with 'pt'.  Please add 'pt' after the number.  The PDF may fail to be produced.</report>
        </rule>
    </pattern>
    <pattern id="startpagenumber">
        <title>
            <dir value="ltr">Check for improper starting page number.</dir>
        </title>
        <rule context="publishingInfo/@startingPageNumber">
            <report test="string-length(normalize-space(.)) &gt; 0 and string(number(.))='NaN'">Warning: The starting page number is not a valid number.  Producing the default PDF may fail.</report>
        </rule>
    </pattern>
    <pattern id="graphics">
        <title>
            <dir value="ltr">Check for graphic formats that will not work.</dir>
        </title>
        <rule context="img/@src">
            <report test="contains(.,'  ') or contains(.,'%20%20')">Graphic file names containing two spaces in a row are not supported.  Producing the default PDF will fail.</report>
            <report test="substring(.,string-length(.)-3)='.odg'">Sorry, but .odg graphic files are not supported.  Producing the default PDF will fail.</report>
        </rule>
    </pattern>
    
    <pattern id="pubstylesheets">
        <title>
            <dir value="ltr">Check for issues related to publisher style sheets</dir>
        </title>
        <rule context="/publisherStyleSheet/pageLayout/pageWidth | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/pageWidth">
            <report test="contains(normalize-space(.),' ')">The page width should not contain a space.  Please remove it.</report>
        </rule>
        <rule context="/publisherStyleSheet/pageLayout/pageHeight | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/pageHeight">
            <report test="contains(normalize-space(.),' ')">The page height should not contain a space.  Please remove it.</report>
        </rule>
        <rule context="/publisherStyleSheet/pageLayout/pageTopMargin | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/pageTopMargin">
            <report test="contains(normalize-space(.),' ')">The page top margin should not contain a space.  Please remove it.</report>
        </rule>
        <rule context="/publisherStyleSheet/pageLayout/pageBottomMargin | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/pageBottomMargin">
            <report test="contains(normalize-space(.),' ')">The page bottom margin should not contain a space.  Please remove it.</report>
        </rule>
        <rule context="/publisherStyleSheet/pageLayout/pageInsideMargin | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/pageInsideMargin">
            <report test="contains(normalize-space(.),' ')">The page inside margin should not contain a space.  Please remove it.</report>
        </rule>
        <rule context="/publisherStyleSheet/pageLayout/pageOutsideMargin | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/pageOutsideMargin">
            <report test="contains(normalize-space(.),' ')">The page outside margin should not contain a space.  Please remove it.</report>
        </rule>
        <rule context="/publisherStyleSheet/pageLayout/headerMargin | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/headerMargin">
            <report test="contains(normalize-space(.),' ')">The header margin should not contain a space.  Please remove it.</report>
        </rule>
        <rule context="/publisherStyleSheet/pageLayout/footerMargin | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/footerMargin">
            <report test="contains(normalize-space(.),' ')">The footer margin should not contain a space.  Please remove it.</report>
        </rule>
        <rule context="/publisherStyleSheet/pageLayout/paragraphIndent | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/paragraphIndent">
            <report test="contains(normalize-space(.),' ')">The paragraph indent should not contain a space.  Please remove it.</report>
        </rule>
        <rule context="/publisherStyleSheet/pageLayout/blockQuoteIndent | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/blockQuoteIndent">
            <report test="contains(normalize-space(.),' ')">The block quote indent should not contain a space.  Please remove it.</report>
        </rule>
        <rule context="/publisherStyleSheet/pageLayout/basicPointSize | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/basicPointSize">
            <report test="string(number(.))='NaN'">The basic point size needs to be a number.  It is not.</report>
        </rule>
        <rule context="/publisherStyleSheet/pageLayout/footnotePointSize | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout/footnotePointSize">
            <report test="string(number(.))='NaN'">The footnote point size needs to be a number.  It is not.</report>
        </rule>
        <!-- no longer an issue <rule context="/publisherStyleSheet/pageLayout | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout">
            <report test="substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(pageHeight),string-length(normalize-space(pageHeight))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(pageTopMargin),string-length(normalize-space(pageTopMargin))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(pageBottomMargin),string-length(normalize-space(pageBottomMargin))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(pageInsideMargin),string-length(normalize-space(pageInsideMargin))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(pageOutsideMargin),string-length(normalize-space(pageOutsideMargin))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(headerMargin),string-length(normalize-space(headerMargin))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(footerMargin),string-length(normalize-space(footerMargin))-1,2)">The unit of measure for pageWidth, pageHeight, pageTopMargin, pageBottomMargin, pageInsideMargin, pageOutsideMargin, headerMargin, and footerMargin all need to be the same.  Please make them all the same.</report>
        </rule>-->
        <rule context="/publisherStyleSheet/contentLayout/magnificationFactor | /xlingpaper/styledPaper/publisherStyleSheet/contentLayout/magnificationFactor">
            <report test="string(number(.))='NaN'">The magnification factor needs to be a number.  It is not.</report>
        </rule>
        <rule context="/publisherStyleSheet/contentLayout/interlinearAlignedWordSpacing/@XeLaTeXSpecial | /xlingpaper/styledPaper/publisherStyleSheet/contentLayout/interlinearAlignedWordSpacing/@XeLaTeXSpecial">
            <report test="not(contains(.,'pt'))">The spacing for aligned words in interlinears needs to be in term of points.  It is not.  Please pattern this value after the default glue of interlinear-aligned-word-skip='6.66666pt plus 3.33333pt minus 2.22222pt'</report>
        </rule>
    </pattern>
    <pattern id="abbreviationsShownHere">
        <title>
            <dir value="ltr">Check for two or more abbreviationsShownHere elements.</dir>
        </title>
        <rule context="lingPaper[not(descendant::chapterInCollection)]">
            <report test="count(descendant::abbreviationsShownHere)>1">Sorry, but you can use only one abbreviationsShownHere element.  You have two or more of them.  Please remove the extra ones.</report>
        </rule>
        <rule context="lingPaper[descendant::chapterInCollection]">
            <report test="count(descendant::abbreviationsShownHere[not(ancestor::chapterInCollection)])>1">Sorry, but you can use only one abbreviationsShownHere element outside of chapterInCollection elements.  You have two or more of them.  Please remove the extra ones.</report>
        </rule>
        <rule context="chapterInCollection">
            <report test="count(descendant::abbreviationsShownHere)>1">Sorry, but you can use only one abbreviationsShownHere element within a chapterInCollection element.  You have two or more of them.  Please remove the extra ones.</report>
        </rule>
    </pattern>
    <pattern id="contentType">
        <title>
            <dir value="ltr">Check for non-excluded reference elements to elements being excluded via a contentType.</dir>
        </title>
        <rule context="exampleRef[not(ancestor::*[string-length(@contentType)!=0])]">
            <report test="@num=//example/@num[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] and string-length(@contentType)=0">There is an exampleRef which refers to an example which may be excluded in the output (via a contentType) and yet the exampleRef itself is always present.  Please make sure that both the example and its exampleRef are excluded in the same situations.</report>
        </rule>
        <rule context="sectionRef[not(ancestor::*[string-length(@contentType)!=0])]">
            <report test="@sec=//section1/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] or @sec=//section2/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] or @sec=//section3/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] or @sec=//section4/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] or @sec=//section5/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] or @sec=//section6/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] or @sec=//chapter/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] or @sec=//chapterBeforePart/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] and string-length(@contentType)=0">There is a sectionRef which refers to a section or a chapter which may be excluded in the output (via a contentType) and yet the sectionRef itself is always present.  Please make sure that both the section (or chapter) and its sectionRef are excluded in the same situations.</report>
        </rule>
        <rule context="appendixRef[not(ancestor::*[string-length(@contentType)!=0])]">
            <report test="@app=//appendix/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] and string-length(@contentType)=0">There is an appendixRef which refers to an appendix which may be excluded in the output (via a contentType) and yet the appendixRef itself is always present.  Please make sure that both the appendix and its appendixRef are excluded in the same situations.</report>
        </rule>
        <rule context="interlinearRef[not(ancestor::*[string-length(@contentType)!=0])]">
            <report test="@textref=//interlinear/@text[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]]">There is an interlinearRef which refers to an interlinear in an interlinear text which may be excluded in the output (via a contentType) and yet the interlinearRef itself is always present.  Please make sure that both the interlinear and its interlinearRef are excluded in the same situations.</report>
        </rule>
        <rule context="interlinearRefCitation[not(ancestor::*[string-length(@contentType)!=0])]">
            <report test="@textref=//interlinear/@text[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]]">There is an interlinearRefCitation which refers to an interlinear in an interlinear text which may be excluded in the output (via a contentType) and yet the interlinearRefCitation itself is always present.  Please make sure that both the interlinear and its interlinearRefCitation are excluded in the same situations.</report>
        </rule>
        <rule context="figureRef[not(ancestor::*[string-length(@contentType)!=0])]">
            <report test="@figure=//figure/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] and string-length(@contentType)=0">There is a figureRef which refers to a figure which may be excluded in the output (via a contentType) and yet the figureRef itself is always present.  Please make sure that both the figure and its figureRef are excluded in the same situations.</report>
        </rule>
        <rule context="tablenumberedRef[not(ancestor::*[string-length(@contentType)!=0])]">
            <report test="@table=//tablenumbered/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] and string-length(@contentType)=0">There is a tablenumberedRef which refers to a tablenumbered which may be excluded in the output (via a contentType) and yet the tablenumberedRef itself is always present.  Please make sure that both the tablenumbered and its tablenumberedRef are excluded in the same situations.</report>
        </rule>
        <rule context="abbrRef[not(ancestor::*[string-length(@contentType)!=0])]">
            <report test="//abbreviationsShownHere[ancestor::*[string-length(@contentType)!=0]]">There is an abbreviationsShownHere element which may be excluded in the output (via a contentType) and yet there are one or more abbrRef elements which are always present.  Please make sure that both the abbreviationsShownHere and all abbrRefs are excluded in the same situations.</report>
        </rule>
        <rule context="genericRef[not(ancestor::*[string-length(@contentType)!=0])]">
            <report test="@gref=//genericTarget/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]] and string-length(@contentType)=0">There is a genericRef which refers to a genericTarget which may be excluded in the output (via a contentType) and yet the genericRef itself is always present.  Please make sure that both the genericTarget and its genericRef are excluded in the same situations.</report>
        </rule>
        <rule context="endnoteRef[not(ancestor::*[string-length(@contentType)!=0])]">
            <report test="@note=//endnote/@id[string-length(../@contentType)!=0 or ancestor::*[string-length(@contentType)!=0]]">There is an endnoteRef which refers to an endnote which may be excluded in the output (via a contentType) and yet the endnoteRef itself is always present.  Please make sure that both the endnote and its endnoteRef are excluded in the same situations.</report>
        </rule>
    </pattern>
    <pattern id="chapterInCollection">
        <rule context="chapterInCollectionBackMatterLayout">
            <assert test="preceding-sibling::chapterInCollectionLayout ">There is a chapterInCollectionBackMatterLayout element in a publisher style sheet but no chapterInCollectionLayout element.  The chapterInCollectionBackMatterLayout will be ignored.</assert>
        </rule>
        <rule context="chapterInCollectionFrontMatterLayout">
            <assert test="preceding-sibling::chapterInCollectionLayout ">There is a chapterInCollectionFrontMatterLayout element in a publisher style sheet but no chapterInCollectionLayout  element.  The chapterInCollectionFrontMatterLayout will be ignored.</assert>
        </rule>
        <rule context="authorLayout[preceding-sibling::*[1][name()='contentsLayout']]">
            <assert test="//chapterInCollectionLayout">There is an authorLayout element immediately after a contentsLayout element, but no chapterInCollectionLayout.  This authorLayout will be ignored.</assert>
        </rule>
        <rule context="chapterInCollection">
            <report test="/xlingpaper/styledPaper and not(/xlingpaper/styledPaper/publisherStyleSheet/bodyLayout/chapterInCollectionLayout)">This document has a chapterInCollection element and a publisher style sheet, but there is no chapterInCollectionLayout element in the body layout of the publisher style sheet.  The output will probably be incorrect.  Please add a chapterInCollectionLayout element.</report>
        </rule>
    </pattern>
    <pattern id="fontsize">
        <title>Check for ill-formed font-size attribute values</title>
        <rule context="/lingPaper/languages/language/@font-size | /lingPaper/types/type/@font-size | /xlingpaper/styledPaper/lingPaper/languages/language/@font-size | /xlingpaper/styledPaper/lingPaper/types/type/@font-size | /xlingpaper/styledPaper/publisherStyleSheet//@font-size | /publisherStyleSheet//@font-size">
            <report test="contains(normalize-space(.),' ')">The font-size attribute should not contain a space.  Please remove it.</report>
            <report test="string-length(normalize-space(.)) &gt; 0 and substring(normalize-space(.),string-length(normalize-space(.))-1,2)!='pt' and substring(normalize-space(.),string-length(normalize-space(.)),1)!='%' and normalize-space(.)!='smaller' and normalize-space(.)!='larger' and normalize-space(.)!='large' and normalize-space(.)!='medium' and normalize-space(.)!='small' and normalize-space(.)!='x-large' and normalize-space(.)!='xx-large' and normalize-space(.)!='x-small' and normalize-space(.)!='xx-small'">Warning: this font-size attribute does not have a proper unit of measure.   Please use either 'pt' or '%'.  The PDF may fail to be produced.</report>
        </rule>
    </pattern>
    <pattern id="verticalspacing">
        <title>Check for ill-formed spacebefore and spaceafter attribute values</title>
        <rule context="/lingPaper/framedTypes/framedType/@spaceafter | /xlingpaper/styledPaper/lingPaper/framedTypes/framedType/@spaceafter | /xlingpaper/styledPaper/publisherStyleSheet//@spaceafter | /publisherStyleSheet//@spaceafter">
            <report test="contains(normalize-space(.),' ')">The spaceafter attribute should not contain a space.  Please remove it.</report>
            <report test="string-length(normalize-space(.)) &gt; 0 and substring(normalize-space(.),string-length(normalize-space(.))-1,2)!='in' and substring(normalize-space(.),string-length(normalize-space(.))-1,2)!='mm' and substring(normalize-space(.),string-length(normalize-space(.))-1,2)!='cm' and substring(normalize-space(.),string-length(normalize-space(.))-1,2)!='pt' and substring(normalize-space(.),string-length(normalize-space(.)),1)!='%'">Warning: this spaceafter attribute does not have a proper unit of measure.   The PDF may fail to be produced.</report>
        </rule>
        <rule context="/lingPaper/framedTypes/framedType/@spacebefore | /xlingpaper/styledPaper/lingPaper/framedTypes/framedType/@spacebefore | /xlingpaper/styledPaper/publisherStyleSheet//@spacebefore | /publisherStyleSheet//@spacebefore">
            <report test="contains(normalize-space(.),' ')">The spacebefore attribute should not contain a space.  Please remove it.</report>
            <report test="string-length(normalize-space(.)) &gt; 0 and substring(normalize-space(.),string-length(normalize-space(.))-1,2)!='in' and substring(normalize-space(.),string-length(normalize-space(.))-1,2)!='mm' and substring(normalize-space(.),string-length(normalize-space(.))-1,2)!='cm' and substring(normalize-space(.),string-length(normalize-space(.))-1,2)!='pt' and substring(normalize-space(.),string-length(normalize-space(.)),1)!='%'">Warning: this spacebefore attribute does not have a proper unit of measure.   The PDF may fail to be produced.</report>
        </rule>
    </pattern>
    <pattern id="contentTypeLocation">
        <title>Check for ill-formed contentType locations</title>
        <rule context="blockquote">
            <report test="count(p)=1 and string-length(p/@contentType)!=0">There is a contentType set for the sole p element within a blockquote.  There will probably be extra, unwanted vertical space in the output.  Please set the contentType on the blockquote element instead of on the p element.</report>
        </rule>
    </pattern>
    <pattern id="abbrRef">
        <title>Check for ill-formed abbrRef elements in morpheme-aligned interlinear</title>
        <rule context="abbrRef[parent::item]">
            <report test="parent::item/@type!='gls'">There is an abbrRef in an item element that is not a gloss.  Please only use abbrRef elements in gloss lines.</report>
        </rule>
        <rule context="abbrRef[ancestor::secTitle]">
            <report test="ancestor::langData">Using an abbrRef element embedded within a langData inside of a secTitle element may fail to produce PDF output.  Please use a gloss element instead of langData.</report>
        </rule>
    </pattern>
    <pattern id="endnoteInSecTitle">
        <title><dir value="ltr">Check for embedded endnote in secTitle</dir></title>
        <rule context="secTitle">
            <report test="*/endnote">Using an endnote element embedded within another element here may fail to produce PDF output.  Put the endnote directly within the secTitle element, not inside the embedded element.</report>
        </rule>
    </pattern>
    <pattern id="indexRangeInSecTitle">
        <title><dir value="ltr">Check for index range items in secTitle</dir></title>
        <rule context="secTitle">
            <report test="indexedRangeBegin | indexedRangeEnd">Using an indexedRangeBegin and/or indexedRangeEnd element within a secTitle element may fail to create the page in the index portion of the PDF output.  Put the indexedRangeBegin element at the beginning of the first paragraph of the chapter/section/appendix, not inside the secTitle element.</report>
        </rule>
    </pattern>
    <pattern id="deprecatedethnCode">
        <title>
            <dir value="ltr">Check for use of ethnCode</dir>
        </title>
        <rule context="/lingPaper/languages/language | /xlingpaper/styledPaper/lingPaper/languages/language">
            <report test="string-length(normalize-space(@ethnCode)) &gt; 0">Warning: using an ethnCode is now deprecated.  Please use ISO639-3Code instead.</report>
        </rule>
    </pattern>
    <pattern id="glossaryTermRefersToItself">
        <title>
            <dir value="ltr">Check for a gloosaryTerm referring to itself</dir>
        </title>
        <rule context="glossaryTermRef">
            <report test="@glossaryTerm=ancestor::glossaryTerm/@id">Warning: This glossary term definition refers to itself. Only refer to other glossary terms.</report>
        </rule>
    </pattern>
    <pattern id="emptycitation">
        <title>
            <dir value="ltr">Check for a citation that has no text in the output</dir>
        </title>
        <rule context="citation">
            <report test="@author='no' and @date='no' and @paren='none' and string-length(@page)=0">Warning: This citation is empty.  Nothing will show in the output, yet the cited reference may appear in the list of references.</report>
        </rule>
    </pattern>
</schema>
