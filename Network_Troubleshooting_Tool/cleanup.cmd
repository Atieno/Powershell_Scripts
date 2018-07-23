@echo off
REM created: 16.02.2010
REM version: 1.0
REM cleans up
REM ------------------------------------------------------------------------------------------
set SOFTWARE=%1
set VERSION=%2
set SOFTWAREDIR=%3
set APPLOGFILE=%4
set TOOLDIR=%5
set COREQDIR=%6
set PHASE=%7

:STATE
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\eServices" /v status|find "1" > nul
if %ERRORLEVEL%==0 echo %DATE% %TIME% [clu-inf] no cleanup after error >> %APPLOGFILE% & exit 0
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\eServices" /v status|find "2" > nul
if %ERRORLEVEL%==0 echo %DATE% %TIME% [clu-inf] cleanup after success >> %APPLOGFILE%

echo %DATE% %TIME% [clu-inf] start cleanup >> %APPLOGFILE%
if "%PHASE%"=="install" (
	echo %DATE% %TIME% [clu-inf] delete %SOFTWAREDIR%\..\*%SOFTWARE%^^%VERSION%.exe >> %APPLOGFILE%
	if exist %SOFTWAREDIR%\..\*%SOFTWARE%^^%VERSION%.exe del /f /q %SOFTWAREDIR%\..\*%SOFTWARE%^^%VERSION%.exe > nul
	echo %DATE% %TIME% [clu-inf] delete %SOFTWAREDIR% >> %APPLOGFILE%
	rmdir /S /Q %SOFTWAREDIR% > nul
)
if "%PHASE%"=="remove" (
	echo %DATE% %TIME% [clu-inf] delete %COREQDIR% >> %APPLOGFILE%
	rmdir /S /Q %COREQDIR% > nul
)
echo %DATE% %TIME% [clu-inf] end cleanup >> %APPLOGFILE%