@echo off
set pdffile=%1
if not exist %pdffile% goto pdfnotthere
goto done
:pdfnotthere
echo XLingPaper-PdfNotThere-XLingPaper
:done
rem exit
