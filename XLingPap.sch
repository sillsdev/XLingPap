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
            <report test="gloss/object">Using an object element within a gloss element here will not produce the correct output.  Use wrd elements within this line element instead.  See section 5.3.1.2 "Word-aligned, marking certain words or morphemes" in the XLingPaper user documentation.</report>
            <report test="gloss/abbrRef">Using an abbrRef element within a gloss element here will not produce the correct output.  Use wrd elements within this line element instead.  See section 5.3.1.2 "Word-aligned, marking certain words or morphemes" in the XLingPaper user documentation.</report>
        </rule>
    </pattern>
    <pattern>
        <title>
            <dir value="ltr">Check for nested langData and nested gloss elements</dir>
        </title>
        <rule context="langData">
            <report test="parent::langData and string-length(normalize-space(parent::langData)) = string-length(normalize-space(.))">There is a langData embedded within a langData here for no apparent reason.   To fix this, click on the numbered link, then, using the mouse, do a cut; next click on the enclosing langData element in the Node Path Bar and finally do a paste.</report>
        </rule>
        <rule context="gloss">
            <report test="parent::gloss and string-length(normalize-space(parent::gloss)) = string-length(normalize-space(.))">There is a gloss embedded within a gloss here for no apparent reason.   To fix this, click on the numbered link, then, using the mouse, do a cut; next click on the enclosing gloss element in the Node Path Bar and finally do a paste.</report>
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
</schema>
