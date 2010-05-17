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
%4
cd %2
xelatex -halt-on-error %1
if errorlevel 1 goto recorderror
if exist %ErrorFile% del %ErrorFile%
REM del %ErrorFile%
goto quit
:recorderror
echo XLingPaper-ErrorInXeLaTeX-XLingPaper > %ErrorFile%
:quit
exit 0
