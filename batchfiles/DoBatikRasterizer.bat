if not defined XLingPaperXXEBinPath goto resetvars
if not defined XLingPaperBatik goto resetvars
goto batik
:resetvars
REM Following ensures that this command prompt has the latest environment variables.
REM For some reason XXE (maybe it's Java??) does not see any changed environment
REM variables until one does a reboot.
REM Since when we install XLingPaper we need the two path variables below to be
REM instantiated, we do this to guarantee it.
call %2\resetvars.bat
:batik
path=%XLingPaperXXEBinPath%\jre\bin;%path%
java -jar "%XLingPaperBatik%\batik-rasterizer.jar" -m application/pdf %1

