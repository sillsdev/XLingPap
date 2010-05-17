@echo off
set pdffile=%1
if not exist %pdffile% goto pdfnotthere
del %pdffile%
rem see if the delete worked
if not exist %pdffile% goto pdfnotthere
del %pdffile%
goto done
:pdfnotthere
echo XLingPaper-PdfNotThere-XLingPaper
:done
rem exit
