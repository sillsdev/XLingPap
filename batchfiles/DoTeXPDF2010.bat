if not defined XLingPaperXeLaTeXPath goto resetvars
goto xelatex
:resetvars
REM Following ensures that this command prompt has the latest environment variables.
REM For some reason XXE (maybe it's Java??) does not see any changed environment
REM variables until one does a reboot.
REM Since when we install XLingPaper we need the two path variables below to be
REM instantiated, we do this to guarantee it.
call %3
:xelatex
set ErrorFile=xelatex.err
echo %%1 = %1
path=%XLingPaperXeLaTeXPath%
if exist "%XLingPaperXeLaTeXPath%\xelatex.exe" goto proceed
call %3
path=%XLingPaperXeLaTeXPath%
:proceed
%4
cd %2
xelatex -halt-on-error %1
if errorlevel 1 goto recorderror
xelatex -halt-on-error %1
if errorlevel 1 goto recorderror
if exist %ErrorFile% del %ErrorFile%
copy %5 %6
del %5
goto quit
:recorderror
echo XLingPaper-ErrorInXeLaTeX-XLingPaper > %ErrorFile%
:quit
exit 0
