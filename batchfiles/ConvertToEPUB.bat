if "%6" == "paper" goto paper
set levelone=//h:div[contains(@class,'Title') and not(contains(@class, 'section')) and not(contains(@class, 'part'))  or @class='preface' or contains(@class,'acknowledgements')]
set leveltwo=//h:body/h:div[contains(@class,'Titlesection1')]
set levelthree=//h:body/h:div[contains(@class,'section2')]
goto convert
:paper
set levelone=//h:div[contains(@class,'Titlesection1') and not(preceding-sibling::h:div[@class='appendixTitle']) or contains(@class,'Title') and not(contains(@class, 'section')) or @class='abstract']
set leveltwo=//h:body/h:div[contains(@class,'Titlesection1') and preceding-sibling::h:div[@class='appendixTitle'] or contains(@class,'section2')]
set levelthree=//h:body/h:div[contains(@class,'section3')]
:convert
ebook-convert "%USERPROFILE%\Documents\Calibre Library\Unknown\%14Ebook (%3)\%14Ebook - Unknown.zip" %2.epub --level1-toc "%levelone%" --level2-toc "%leveltwo%" --level3-toc "%levelthree%" --authors %4 --publisher %5

REM ebook-convert "%USERPROFILE%\Documents\Calibre Library\Unknown\%14Ebook (%3)\%14Ebook - Unknown.zip" %2.epub --level1-toc "%levelone%" --level2-toc "%leveltwo%" --level3-toc "%levelthree%" --authors %4 --publisher %5

Rem Chapter-based
REM ebook-convert "%USERPROFILE%\Documents\Calibre Library\Unknown\%14Ebook (%3)\%14Ebook - Unknown.zip" %2.epub --level1-toc "//h:div[contains(@class,'Title') and not(contains(@class, 'section')) and not(contains(@class, 'part'))  or @class='preface' or contains(@class,'acknowledgements')]"  --level2-toc "//h:body/h:div[contains(@class,'Titlesection1')]" --level3-toc "//h:body/h:div[contains(@class,'section3')]" --authors %4 --publisher %5

