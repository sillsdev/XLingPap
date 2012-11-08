<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron">
    <pattern>
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
    <pattern>
        <title>
            <dir value="ltr">Consistent line elements within a lineGroup</dir>
        </title>
        <rule context="lineGroup">
            <report test="line[count(wrd) &gt; 0] and line[count(wrd)=0]">Some of the line elements in this lineGroup have been converted to use wrd elements and some have not.  All line elements within a lineGroup should be the same: either all using wrd or all not using wrd.  The formatted output may leave out some lines.  Please use the XLingPaper menu item / 'Convert interlinear line to wrd elements' for all lines in this lineGroup.</report>
        </rule>
        <rule context="line">
<!--            <report test="count(line) = 3 and line[count(wrd)] != line[count(wrd)]">Not all of the lines in this interlinear lineGroup have the same number of wrd elements.  The alignment will probably be incorrect.</report>-->
            <report test="preceding-sibling::line[1] and count(preceding-sibling::line[1]/wrd) != count(wrd)">This line has a different number of wrd elements in it than its immediately preceding line.  The alignment will probably be incorrect.</report>
        </rule>
    </pattern>
    <pattern>
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
    <pattern>
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
    <pattern>
        <title>
            <dir value="ltr">Check for partial table header rows</dir>
        </title>
        <rule context="table">
            <report test="not(ancestor::table) and count(tr) &gt; 5 and tr[1]/th and tr[1]/td">Warning: the first row of this table has some th cells , but it also has some td cells.  If the table goes beyond a page, no header will be repeated.  To fix this, convert the td cells to th cells (and use object elements to get the fomatting you want). </report>
        </rule>
    </pattern>
    <pattern>
        <title>
            <dir value="ltr">Check for invalid table widths (e.g., missing unit of measure)</dir>
        </title>
        <rule context="td | th">
            <report test="string-length(normalize-space(@width)) &gt; 0 and substring(normalize-space(@width),string-length(normalize-space(@width))-1,2)!='in' and substring(normalize-space(@width),string-length(normalize-space(@width))-1,2)!='mm' and substring(normalize-space(@width),string-length(normalize-space(@width))-1,2)!='cm' and substring(normalize-space(@width),string-length(normalize-space(@width))-1,2)!='pt' and substring(normalize-space(@width),string-length(normalize-space(@width)),1)!='%'">Warning: this table cell has a width specified but it does not have a proper unit of measure.   The PDF may fail to be produced.</report>
            <report test="contains(normalize-space(@width),' ')">Warning: this table cell has a width specified but it contains a space.  There should not be a space between the number and the unit of measure.  The result may not be what you want. </report>
        </rule>
    </pattern>
    <pattern>
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
    <pattern>
        <title>
            <dir value="ltr">Check for inconsistent column counts</dir>
        </title>
        <rule context="table">
            <report test="count(tr[1]/*[not(number(@colspan) &gt; 0)]) + sum(tr[1]/*[number(@colspan) &gt; 0]/@colspan) &lt; count(tr[2]/*[not(number(@colspan) &gt; 0)]) + sum(tr[2]/*[number(@colspan) &gt; 0]/@colspan)">Warning: the first row of this table does not have the same number of columns as the second row.  The XeLaTex way of producing PDF will fail.  Please make sure every row has the same number of columns (including any colspan attributes).</report>
        </rule>
    </pattern>
    <pattern>
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
    <pattern>
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
    <pattern>
        <title>
            <dir value="ltr">Check for paper with improper header and footer layouts</dir>
        </title>
        <rule context="publisherStyleSheet">
            <report test="//lingPaper and not(//chapter) and pageLayout[not(headerFooterPageStyles)]">Warning: this is a paper but it is trying to use a book-oriented publisher style sheet (i.e. it has the header and footer layout information under both front matter layout and body layout instead of under page layout).  The XeLaTex way of producing PDF will fail.  Please associate this document with a *paper* publisher style sheet..</report>
            <report test="//lingPaper and not(//chapter) and frontMatterLayout/titleHeaderFooterPageStyles">Warning: this is a paper but it is trying to use a publisher style sheet that has header and footer layout information for titles under the front matter layout.  The XeLaTex way of producing PDF will fail or not be correct.  Please fix this by removing the unneeded title header and footer layout information or by associating this document with a paper publisher style sheet..</report>
            <report test="//lingPaper and not(//chapter) and frontMatterLayout/headerFooterPageStyles">Warning: this is a paper but it is trying to use a publisher style sheet that has header and footer layout information for non-title front matter pages under the front matter layout.  The XeLaTex way of producing PDF will fail or not be correct.  Please fix this by removing the header and footer layout information for the non-title front matter or by associating this document with a paper publisher style sheet..</report>
            <report test="//lingPaper and not(//chapter) and bodyLayout/headerFooterPageStyles">Warning: this is a paper but it is trying to use a publisher style sheet that has header and footer layout information under the body layout.  The XeLaTex way of producing PDF will fail or not be correct.  Please fix this by removing the header and footer layout information in the body layout or by associating this document with a paper publisher style sheet..</report>
        </rule>
    </pattern>
    <pattern>
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
    <pattern>
        <title>
            <dir value="ltr">Check for improperly embedded interlinears</dir>
        </title>
        <rule context="interlinear">
            <report test="ancestor::table and descendant::endnote and not(parent::example)">Warning: There is an interlinear within a table and that interlinear contains an endnote somewhere.  This will fail to produce the PDF using the XeLaTex method.  Furthermore, the other outputs will probably not format correctly.  Please consider Convert/wrapping the interlinear within an example or using something else for the interlinear.</report>
        </rule>
    </pattern>
    <pattern>
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
    <pattern>
        <title>
            <dir value="ltr">Check for br elements within a line in an interlinear</dir>
        </title>
        <rule context="line">
            <report test="descendant::br"
                >Warning: There is a br element within an interlinear.  This will not produce PDF output.  Please either use an example(chart) or a table to do what you have in mind. </report>
        </rule>
    </pattern>
    <pattern>
        <title>
            <dir value="ltr">Check for abbreviation element with @usesmallcaps='Y'</dir>
        </title>
        <rule context="abbreviations">
            <report test="@usesmallcaps='yes'">Warning: The 'usesmallcaps' attribute is now deprecated.  Please use font-variant='small-caps' instead (or better yet, use a real, true-blue small-caps font and put its name in the font-family attribute).</report>
        </rule>
    </pattern>
    <pattern>
        <title>
            <dir value="ltr">Check for issues related to indexes</dir>
        </title>
        <rule context="indexTerm">
            <report test="@see=@id">The 'see' attribute of this indexTerm is referring to itself.  It should refer to a different indexTerm element.</report>
        </rule>
    </pattern>
    <pattern>
        <title>
            <dir value="ltr">Check for improper starting page number.</dir>
        </title>
        <rule context="publishingInfo/@startingPageNumber">
            <report test="string-length(normalize-space(.)) &gt; 0 and string(number(.))='NaN'">Warning: The starting page number is not a valid number.  Producing the default PDF may fail.</report>
        </rule>
    </pattern>
    <pattern>
        <title>
            <dir value="ltr">Check for graphic formats that will not work.</dir>
        </title>
        <rule context="img/@src">
            <report test="substring(.,string-length(.)-3)='.odg'">Sorry, but .odg graphic files are not supported.  Producing the default PDF will fail.</report>
        </rule>
    </pattern>
    <pattern>
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
        <rule context="/publisherStyleSheet/pageLayout | /xlingpaper/styledPaper/publisherStyleSheet/pageLayout">
            <report test="substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(pageHeight),string-length(normalize-space(pageHeight))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(pageTopMargin),string-length(normalize-space(pageTopMargin))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(pageBottomMargin),string-length(normalize-space(pageBottomMargin))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(pageInsideMargin),string-length(normalize-space(pageInsideMargin))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(pageOutsideMargin),string-length(normalize-space(pageOutsideMargin))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(headerMargin),string-length(normalize-space(headerMargin))-1,2) or substring(normalize-space(pageWidth),string-length(normalize-space(pageWidth))-1,2)!=substring(normalize-space(footerMargin),string-length(normalize-space(footerMargin))-1,2)">The unit of measure for pageWidth, pageHeight, pageTopMargin, pageBottomMargin, pageInsideMargin, pageOutsideMargin, headerMargin, and footerMargin all need to be the same.  Please make them all the same.</report>
        </rule>
        <rule context="/publisherStyleSheet/contentLayout/magnificationFactor | /xlingpaper/styledPaper/publisherStyleSheet/contentLayout/magnificationFactor">
            <report test="string(number(.))='NaN'">The magnification factor needs to be a number.  It is not.</report>
        </rule>
        <rule context="/publisherStyleSheet/contentLayout/interlinearAlignedWordSpacing/@XeLaTeXSpecial | /xlingpaper/styledPaper/publisherStyleSheet/contentLayout/interlinearAlignedWordSpacing/@XeLaTeXSpecial">
            <report test="not(contains(.,'pt'))">The spacing for aligned words in interlinears needs to be in term of points.  It is not.  Please pattern this value after the default glue of interlinear-aligned-word-skip='6.66666pt plus 3.33333pt minus 2.22222pt'</report>
        </rule>
    </pattern>
    <pattern>
        <title>
            <dir value="ltr">Check for two or more abbreviationsShownHere elements.</dir>
        </title>
        <rule context="lingPaper">
            <report test="count(descendant::abbreviationsShownHere)>1">Sorry, but you can use only one abbreviationsShownHere element.  You have two or more of them.  Please remove the extra ones.</report>
        </rule>
    </pattern>
</schema>
