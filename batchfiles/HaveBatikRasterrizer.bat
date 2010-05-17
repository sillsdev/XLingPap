if not defined XLingPaperBatik goto resetvars
goto check
:resetvars
REM Following ensures that this command prompt has the latest environment variables.
REM For some reason XXE (maybe it's Java??) does not see any changed environment
REM variables until one does a reboot.
REM Since when we install XLingPaper we need the two path variables below to be
REM instantiated, we do this to guarantee it.
call %1
:check
if defined XLingPaperBatik goto yes
echo XLingPaper-No-XLingPaper
exit
:yes
echo XLingPaper-Yes-XLingPaper


