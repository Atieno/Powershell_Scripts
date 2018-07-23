@echo off
:: Created: 8.11.2017
:: Version: 1.0
:: Installs/Integrates product
::---------------------------------------------------------------------------------

SETLOCAL ENABLEDELAYEDEXPANSION

SET SOFTWARE=%1
SET VERSION=%2
SET SOFTWAREDIR=%3
SET APPLOGFILE=%4
SET INSTLOGFILE=%5
SET TOOLDIR=%6
SET CUSTOMDIR=%7
SET SOURCEDIR=%8

REM IN CASE OF NEWER VERSION UPDATE JUST THE FILENAMES, CHECK THE UNINSTALLATION SCRIPT TOO
SET BATFILENAME="Network_Troubleshooting_Tool.bat"
SET DOCFILENAME="USoB - Network Troubleshooting_EN_v3.8.pptx"
SET SHORTCUTFILENAME="Network_Troubleshooting_Tool.lnk"
REM FOLLOWING PART CAN BE KEPT
SET DESTDIR="C:\service\Scripts\GSMC\NetworkTroubleshootingTool"
SET DESTSHORTCUT="C:\Users\Public\Desktop"
SET ERRORCODE=0

ECHO %DATE% %TIME% [ins-inf] Installation of %SOFTWARE% %VERSION% started >> %APPLOGFILE%

ECHO %DATE% %TIME% [ins-inf] Ensure clear installation - Removing previous version >> %APPLOGFILE%
IF EXIST "%DESTDIR%" RMDIR "%DESTDIR%" /S /Q
IF EXIST "%DESTSHORTCUT%\%SHORTCUTFILENAME%" DEL "%DESTSHORTCUT%\%SHORTCUTFILENAME%" /F /Q

ECHO %DATE% %TIME% [ins-inf] Continue with clear installation >> %APPLOGFILE%
IF NOT EXIST "%DESTDIR%" MKDIR "%DESTDIR%"
REM COUNTING ALL COMMANDS OUTPUTS TO A VARIABLE ERRCODE, LATER EVALUATE IT
COPY /Y "%SOURCEDIR%\%BATFILENAME%" "%DESTDIR%"
SET /a ERRORCODE=%ERRORCODE% + %ERRORLEVEL%
COPY /Y "%SOURCEDIR%\%DOCFILENAME%" "%DESTDIR%"
SET /a ERRORCODE=%ERRORCODE% + %ERRORLEVEL%
COPY /Y "%SOURCEDIR%\%SHORTCUTFILENAME%" "%DESTSHORTCUT%"
SET /a ERRORCODE=%ERRORCODE% + %ERRORLEVEL%

IF NOT %ERRCODE%==0 GOTO ERROR
GOTO END

:ERROR
ECHO %DATE% %TIME% [ins-err] Installation failed, copying of sources returned sum of errolevels %ERRCODE% >> %APPLOGFILE%
EXIT /B 1

:END
ECHO %DATE% %TIME% [ins-inf] Installation of %SOFTWARE% %VERSION% finished ! >> %APPLOGFILE%
EXIT /B 0
