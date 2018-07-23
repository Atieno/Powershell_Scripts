@ECHO OFF
:: ===========================================================================
:: This script performs network checks in Benetton tills
:: Parameter
::		%1 - Processing Mode (0 or empty = default, 1 = debug)
::	 	%2 - Channel (DOS, FOS)
::		%3 - Country (IT, DE, ES, FR, RU)
::		%4 - TYPE (P, R)
:: ===========================================================================
:: Version History
:: DATE		VERSION			AUTHOR				COMMENT
:: 2017-06-21   3.8			Mirco Gaviano		Changed Telnet tests to an in-built PS script, in order to handle result with ERRORLEVEL variable,
::												Minor GUI & Textual improvements
:: 2017-06-16   3.7			Mirco Gaviano		Added MHT, Redsys and MSMQ checks, corrected Microstrategy check, 
::												modified name convention (version hard-coded in main menu),
::												Minor GUI & Textual improvements
:: 2017-01-27	3.6			Simone Porru		Major GUI & Textual improvements, removed dinamic window dimension
:: 2016-10-11	3.5			Mirco Gaviano		Adapted to GSMC log folder's structure
:: 2016-10-11	3.4			Mirco Gaviano		Reworked standard mode layout, added dinamic window dimension 
:: 2016-09-28	3.3			Mirco Gaviano		Reworked debug mode, Added User-Friendly tests
:: 2016-08-31	3.2			Mirco Gaviano		Reworked steps in accordance to new support's troubleshooting guide
:: 2016-08-31	3.1			Mirco Gaviano		Added User-Friendly tests
:: 2016-08-30	3.0			Mirco Gaviano		Major Rework of Batch Structure
:: 2016-02-10	2.4			Mirco Gaviano		Corrected path for batch deployment
:: 2016-02-10	2.3			Mirco Gaviano		Minor GUI & Textual improvements, added check
::												that shows the content of file hosts
:: 2016-02-09	2.2			Mirco Gaviano		Small improvement, changed check 
::												DNS PING to PROXY SERVER SETTINGS		
:: 2016-02-09	2.1			Mirco Gaviano		Improvement on log destination path, corrected optional redirection to start
:: 2015-09-10	2.0			Matthias Tietz		Some small improvements and Bug fixing in path to "all logs" file,
::												Renaming var TYPE to SYSTEM_TYPE because TYPE is a default keyword
:: 2015-09-09 	1.0 		Simone Porru 		Initial Version
::
:: ===========================================================================
SETLOCAL
mode con cols=110 lines=50
TITLE NETWORK TROUBLESHOOTING TOOL
:: Release Version Declaration
SET "RELEASE=ver. 3.8 - rel. 2017-06-21"
:: Global Variables Declaration
SET "PROCESSING_MODE_DEFAULT=0"
SET "PROCESSING_MODE_DEBUG=1"
SET "PROCESSING_MODE=%1"
:: Channel TYPE Declaration
SET "CHANNEL_VARIANT_DOS=DOS"
SET "CHANNEL_VARIANT_FOS=FOS"
SET "CHANNEL=%2"
::SET "CHANNEL=%CHANNEL_VARIANT_DOS%"
:: Debug Country Declaration
SET "COUNTRY_DEBUG_IT=IT"
SET "COUNTRY_DEBUG_DE=DE"
SET "COUNTRY_DEBUG_ES=ES"
SET "COUNTRY_DEBUG_FR=FR"
SET "COUNTRY_DEBUG_RU=RU"
SET "COUNTRY=%3"
:: System TYPE Declaration
SET "SYSTEM_TYPE_PRODUCTION=P"
SET "SYSTEM_TYPE_REFERENCE=R"
SET "SYSTEM_TYPE=%4"
:: DNS Declaration
SET "DNS1=192.168.228.197"
SET "DNS2=192.168.228.198"
:: Log Folder Declaration
IF NOT EXIST C:\service\Scripts\GSMC\Log MD C:\service\Scripts\GSMC\Log
IF NOT EXIST C:\service\Scripts\GSMC\Log\NetworkTroubleshootingTool MD C:\service\Scripts\GSMC\Log\NetworkTroubleshootingTool
:: Log Full Path Declaration
SET "LOGPATH=C:\service\Scripts\GSMC\Log\NetworkTroubleshootingTool"
:: Log Files Declaration
SET "ES_EFTTestLogFilePath=%LOGPATH%\ES_TEST_EFT.log"
SET "DE_EFTTestLogFilePath=%LOGPATH%\DE_TEST_EFT.log"
SET "ReachMHTLogFilePath=%LOGPATH%\ReachMHT.log"
SET "Reach_MSMQ_TpAdminLogFilePath=%LOGPATH%\Reach_MSMQ_TpAdmin.log"
SET "ReachTpAdminLogFilePath=%LOGPATH%\Reach_TpAdmin.log"
SET "Reach_MSMQ_TxCollectorLogFilePath=%LOGPATH%\Reach_MSMQ_TxCollector.log"
SET "ReachTxCollectorLogFilePath=%LOGPATH%\Reach_TxCollector.log"
SET "ReachMicrostrategyLogFilePath=%LOGPATH%\Reach_Microstrategy.log"
SET "ReachInternetLogFilePath=%LOGPATH%\Reach_Internet.log"
SET "FirewallLogFilePath=%LOGPATH%\Firewall_Status.log"
SET "ShowProxylogFilePath=%LOGPATH%\Show_Proxy_Settings.log"
SET "fileHostsFilePath=%LOGPATH%\Show_Hosts.log"
SET "ipConfigLogFilePath=%LOGPATH%\Ipconfig.log"
:: File HOSTS Location Declaration
SET "hostspath=C:\windows\system32\drivers\etc\hosts"
:: ALL_Checks.log Declaration
SET hr=%time:~0,2%
IF "%hr:~0,1%" EQU " " SET hr=0%hr:~1,1%
SET "PATH_TO_LOGFILE_ALL=%LOGPATH%\ALL_Checks_%date:~-4,4%%date:~-7,2%%date:~-10,2%_%hr%%time:~3,2%%time:~6,2%.log"
:: Declaring Processing Mode as Default
IF /I "%PROCESSING_MODE%"=="" SET "PROCESSING_MODE=%PROCESSING_MODE_DEFAULT%"
:: On Debug mode the parameters sent during call will be checked
IF /I "%PROCESSING_MODE%" EQU "%PROCESSING_MODE_DEBUG%" ( 
	GOTO INIT_DEBUG_MODUS
	) else ( 
	GOTO INIT_DEFAULT_MODUS
)

:INIT_DEBUG_MODUS
SET "PROCESSING_MODE=%PROCESSING_MODE_DEBUG%"
ECHO Debug mode activated...
ECHO Reading parameters for channel and system type
:: Assigning Channel Test
IF /I "%CHANNEL%"=="D" SET "CHANNEL=%CHANNEL_VARIANT_DOS%"
IF /I "%CHANNEL%"=="DO" SET "CHANNEL=%CHANNEL_VARIANT_DOS%"
IF /I "%CHANNEL%"=="DOS" SET "CHANNEL=%CHANNEL_VARIANT_DOS%"
IF /I "%CHANNEL%"=="F" SET "CHANNEL=%CHANNEL_VARIANT_FOS%"
IF /I "%CHANNEL%"=="FO" SET "CHANNEL=%CHANNEL_VARIANT_FOS%"
IF /I "%CHANNEL%"=="FOS" SET "CHANNEL=%CHANNEL_VARIANT_FOS%"
:: Declaring if Empty Channel TYPE Direct as Default
IF NOT "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" IF NOT "%CHANNEL%"=="%CHANNEL_VARIANT_FOS%" SET "CHANNEL=%CHANNEL_VARIANT_DOS%"
:: Assigning Country Test
IF /I "%COUNTRY%"=="I" SET "COUNTRY=%COUNTRY_DEBUG_IT%"
IF /I "%COUNTRY%"=="IT" SET "COUNTRY=%COUNTRY_DEBUG_IT%"
IF /I "%COUNTRY%"=="D" SET "COUNTRY=%COUNTRY_DEBUG_DE%"
IF /I "%COUNTRY%"=="DE" SET "COUNTRY=%COUNTRY_DEBUG_DE%"
IF /I "%COUNTRY%"=="E" SET "COUNTRY=%COUNTRY_DEBUG_ES%"
IF /I "%COUNTRY%"=="ES" SET "COUNTRY=%COUNTRY_DEBUG_ES%"
IF /I "%COUNTRY%"=="F" SET "COUNTRY=%COUNTRY_DEBUG_FR%"
IF /I "%COUNTRY%"=="FR" SET "COUNTRY=%COUNTRY_DEBUG_FR%"
IF /I "%COUNTRY%"=="R" SET "COUNTRY=%COUNTRY_DEBUG_RU%"
IF /I "%COUNTRY%"=="RU" SET "COUNTRY=%COUNTRY_DEBUG_RU%"
:: Declaring if Empty Country IT as Default
IF NOT "%COUNTRY%"=="%COUNTRY_DEBUG_IT%" IF NOT "%COUNTRY%"=="%COUNTRY_DEBUG_DE%" IF NOT "%COUNTRY%"=="%COUNTRY_DEBUG_ES%" IF NOT "%COUNTRY%"=="%COUNTRY_DEBUG_FR%" IF NOT "%COUNTRY%"=="%COUNTRY_DEBUG_RU%" SET "COUNTRY=%COUNTRY_DEBUG_IT%"
:: Declaring if Empty System TYPE Reference as Default
IF NOT "%SYSTEM_TYPE%"=="%SYSTEM_TYPE_PRODUCTION%" IF NOT "%SYSTEM_TYPE%"=="%SYSTEM_TYPE_REFERENCE%" SET "SYSTEM_TYPE=%SYSTEM_TYPE_REFERENCE%"
:: Route system servers
IF /I "%SYSTEM_TYPE%"=="%SYSTEM_TYPE_PRODUCTION%" GOTO PRODUCTION
IF /I "%SYSTEM_TYPE%"=="%SYSTEM_TYPE_REFERENCE%" GOTO REFERENCE

:INIT_DEFAULT_MODUS
ECHO Script is running in default modus...
:: Store Local TYPE Declaration
SET "SYSTEM_TYPE=%COMPUTERNAME:~-1%"
SET "COUNTRY=%COMPUTERNAME:~,2%"
::DOS Case
IF /I "%SYSTEM_TYPE%"=="P" SET "CHANNEL=%CHANNEL_VARIANT_DOS%" && GOTO PRODUCTION
IF /I "%SYSTEM_TYPE%"=="R" SET "CHANNEL=%CHANNEL_VARIANT_DOS%" && GOTO REFERENCE
::FOS Case
IF /I "%SYSTEM_TYPE%"=="F" SET "CHANNEL=%CHANNEL_VARIANT_FOS%" && GOTO PRODUCTION
IF /I "%SYSTEM_TYPE%"=="T" SET "CHANNEL=%CHANNEL_VARIANT_FOS%" && GOTO REFERENCE

GOTO WRONGNAME

:PRODUCTION
SET "Environment=PRODUCTION"
SET "TpAdminDOSHN=DEBEN9010TP001P"
SET "TpAdminDOSIP=192.168.228.7"
SET "TpAdminFOSHN=DEBEN9010TP002P"
SET "TpAdminFOSIP=192.168.228.8"
SET "TxCollectorHN=DEBEN9010TP003P"
SET "TxCollectorIP=192.168.228.9"

GOTO START

:REFERENCE
SET "Environment=REFERENCE"
SET "TpAdminDOSHN=DEBEN9010TP001R"
SET "TpAdminDOSIP=192.168.228.134"
SET "TpAdminFOSHN=DEBEN9010TP002R"
SET "TpAdminFOSIP=192.168.228.135"
SET "TxCollectorHN=DEBEN9010TP003R"
SET "TxCollectorIP=192.168.228.136"

:START
CLS
IF EXIST .\*.ps1 DEL .\*.ps1
ECHO    *************** DIEBOLD  NIXDORF ***************
ECHO.
ECHO ******************************************************
ECHO ************ NETWORK TROUBLESHOOTING TOOL ************
ECHO ************  %RELEASE%  ************
ECHO ******************************************************
ECHO.
ECHO    Country . . . . . . . . . . . . . : %COUNTRY%
ECHO    Channel . . . . . . . . . . . . . : %CHANNEL%
ECHO    Environment . . . . . . . . . . . : %ENVIRONMENT%
IF /I "%PROCESSING_MODE%"=="%PROCESSING_MODE_DEBUG%" ECHO    Hostname. . . . . . . . . . . . . : TILL_HOSTNAME
IF /I "%PROCESSING_MODE%"=="%PROCESSING_MODE_DEFAULT%" ECHO    Hostname. . . . . . . . . . . . . : %COMPUTERNAME%
IPCONFIG | find "IPv4"
ECHO.
ECHO ******************************************************
ECHO ************      Available options:      ************
ECHO ******************************************************
ECHO.
ECHO  1.	IPCONFIG
ECHO  2.	Shows file "HOSTS"
ECHO  3.	Shows INTERNET PROXY SETTINGS
ECHO  4.	Windows FIREWALL Status
ECHO  5.	TpAdmin Connectivity Test
ECHO  6.	TpAdmin MSMQ Connectivity Test 
ECHO  7.	TxCollector Connectivity Test
ECHO  8.	TxCollector MSMQ Connectivity Test
ECHO  9.	Microstrategy Connectivity Test
ECHO  10.	Internet Public Access Test
ECHO  11.	MHT Loyalty WebService Connectivity Tests
IF /I "%COUNTRY%"=="DE" IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" ECHO  12.	DE Store: EFT Connectivity Test
IF /I "%COUNTRY%"=="ES" IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" ECHO  13.	ES Store: REDSYS Connectivity Test (EFT)
ECHO.
ECHO.
ECHO 99.	CHECK ALL OPTIONS
ECHO.
ECHO  0.	EXIT
ECHO.
ECHO.
:: Menu choice variable Insertion and Validity Test
SET "CHECK=1000"
set /P CHECK= Please, select the test to be performed: 
:: MENU REDIRECTION CHECKS
IF %CHECK%==1 GOTO CHK1
IF %CHECK%==2 GOTO CHK2
IF %CHECK%==3 GOTO CHK3
IF %CHECK%==4 GOTO CHK4
IF %CHECK%==5 GOTO CHK5
IF %CHECK%==6 GOTO CHK6
IF %CHECK%==7 GOTO CHK7
IF %CHECK%==8 GOTO CHK8
IF %CHECK%==9 GOTO CHK9
IF %CHECK%==10 GOTO CHK10
IF %CHECK%==11 GOTO CHK11
IF /I "%COUNTRY%"=="DE" IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" IF %CHECK%==12 GOTO CHK12
IF /I "%COUNTRY%"=="ES" IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" IF %CHECK%==13 GOTO CHK13
IF %CHECK%==99 GOTO CHK1
IF %CHECK%==0 GOTO CHK0
GOTO START

:CHK1
CLS
ECHO.
ECHO 1.	IPCONFIG
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO %date% %time% > %ipConfigLogFilePath%
IPCONFIG /all >> %ipConfigLogFilePath%
CLS
ECHO 1.	IPCONFIG
ECHO.
TYPE %ipConfigLogFilePath%
TYPE %ipConfigLogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
ECHO.
PAUSE
IF %CHECK%==99 GOTO CHK2
GOTO START

:CHK2
CLS
ECHO.
ECHO  2.	Shows file "HOSTS"
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO.
ECHO %date% %time% > %fileHostsFilePath%
TYPE %hostspath% >> %fileHostsFilePath%
CLS
ECHO  2.	Shows file "HOSTS"
ECHO.
TYPE %fileHostsFilePath% >> "%PATH_TO_LOGFILE_ALL%"
NOTEPAD %fileHostsFilePath%
ECHO.
ECHO File Opened ... Checked and Closed
ECHO.
PAUSE
IF %CHECK%==99 GOTO CHK3
GOTO START

:CHK3
CLS
ECHO.
ECHO  3.	Shows PROXY SETTINGS 
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO %date% %time% > %ShowProxylogFilePath%
ECHO. >> %ShowProxylogFilePath%
ECHO.
ECHO Here the keys that regulate the handling of Benetton's Proxy Server:
ECHO.
ECHO HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings >> %ShowProxylogFilePath%
ECHO. >> %ShowProxylogFilePath%
ECHO.
REG QUERY "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" | FINDSTR "ProxyEnable" >> %ShowProxylogFilePath%
REG QUERY "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" | FINDSTR "AutoConfigURL" >> %ShowProxylogFilePath%
CLS
ECHO  3.	Shows PROXY SETTINGS
ECHO.
TYPE %ShowProxylogFilePath%
TYPE %ShowProxylogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
ECHO.
PAUSE
IF %CHECK%==99 GOTO CHK4
GOTO START

:CHK4
CLS
ECHO.
ECHO  4.	FIREWALL Status
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO %date% %time% > %FirewallLogFilePath%
ECHO. >> %FirewallLogFilePath%
ECHO.
NETSH advfirewall show allprofiles | FINDSTR "Settings State" >> %FirewallLogFilePath%
CLS
ECHO  4.	FIREWALL Status
ECHO.
TYPE %FirewallLogFilePath%
TYPE %FirewallLogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
ECHO.
PAUSE
IF %CHECK%==99 GOTO CHK5
GOTO START

:CHK5
CLS
ECHO.
ECHO  5.	TpAdmin Connectivity Test
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO %date% %time% > %ReachTpAdminLogFilePath%
ECHO.>> %ReachTpAdminLogFilePath%
ECHO PING BY HOSTNAME IN PROGRESS... PLEASE WAIT
ECHO.
ECHO PING BY HOSTNAME >> %ReachTpAdminLogFilePath%
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" PING -n 3 %TpAdminDOSHN% >> %ReachTpAdminLogFilePath%
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_FOS%" PING -n 3 %TpAdminFOSHN% >> %ReachTpAdminLogFilePath%
ECHO TRACERT BY HOSTNAME IN PROGRESS... PLEASE WAIT
ECHO.
ECHO. >> %ReachTpAdminLogFilePath%
ECHO TRACERT BY HOSTNAME >> %ReachTpAdminLogFilePath%
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" TRACERT -d -h 7 %TpAdminDOSHN% >> %ReachTpAdminLogFilePath%
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_FOS%" TRACERT -d -h 7 %TpAdminFOSHN% >> %ReachTpAdminLogFilePath%
ECHO. >> %ReachTpAdminLogFilePath%
ECHO NSLOOKUP BY HOSTNAME IN PROGRESS... PLEASE WAIT
ECHO.
ECHO NSLOOKUP BY HOSTNAME >> %ReachTpAdminLogFilePath%
ECHO. >> %ReachTpAdminLogFilePath%
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" NSLOOKUP %TpAdminDOSHN% >> %ReachTpAdminLogFilePath%
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_FOS%" NSLOOKUP %TpAdminFOSHN% >> %ReachTpAdminLogFilePath%
CLS
ECHO  5.	TpAdmin Connectivity Test
ECHO.
TYPE %ReachTpAdminLogFilePath%
TYPE %ReachTpAdminLogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
PAUSE
IF %CHECK%==99 GOTO CHK6
GOTO START

:CHK6
CLS
ECHO param(>>ps_telnet_tpadmin_test.ps1
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" ECHO     [string] $remoteHost = "%TpAdminDOSHN%",>>ps_telnet_tpadmin_test.ps1
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_FOS%" ECHO     [string] $remoteHost = "%TpAdminFOSHN%",>>ps_telnet_tpadmin_test.ps1
ECHO     [int] $port = 1801>>ps_telnet_tpadmin_test.ps1
ECHO      )>>ps_telnet_tpadmin_test.ps1
ECHO # Open the socket, and connect to the computer on the specified port>>ps_telnet_tpadmin_test.ps1
ECHO write-host "Connecting to $remoteHost on port $port">>ps_telnet_tpadmin_test.ps1
ECHO try {>>ps_telnet_tpadmin_test.ps1
ECHO   $socket = new-object System.Net.Sockets.TcpClient($remoteHost, $port)>>ps_telnet_tpadmin_test.ps1
ECHO } catch [Exception] {>>ps_telnet_tpadmin_test.ps1
ECHO   write-host $_.Exception.GetType().FullName>>ps_telnet_tpadmin_test.ps1
ECHO   write-host $_.Exception.Message>>ps_telnet_tpadmin_test.ps1
ECHO   exit 1 >>ps_telnet_tpadmin_test.ps1
ECHO }>>ps_telnet_tpadmin_test.ps1
ECHO write-host "Connected.`n">>ps_telnet_tpadmin_test.ps1
ECHO exit 0 >>ps_telnet_tpadmin_test.ps1
ECHO.
ECHO  6.	TpAdmin MSMQ Connectivity Test
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO %date% %time% > %Reach_MSMQ_TpAdminLogFilePath%
ECHO. >> %Reach_MSMQ_TpAdminLogFilePath%
ECHO Checking MSMQ Connection between POS and TPADMIN on port 1801...
ECHO.
Powershell -ExecutionPolicy ByPass -File .\ps_telnet_tpadmin_test.ps1
ECHO TELNET TEST:>> %Reach_MSMQ_TpAdminLogFilePath%
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" IF %ERRORLEVEL% EQU 0 ECHO CONNECTION TO %TpAdminDOSHN% ON PORT 1801 ESTABLISHED!>> %Reach_MSMQ_TpAdminLogFilePath%
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" IF %ERRORLEVEL% NEQ 0 ECHO CONNECTION TO %TpAdminDOSHN% ON PORT 1801 FAILED!>> %Reach_MSMQ_TpAdminLogFilePath%
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_FOS%" IF %ERRORLEVEL% EQU 0 ECHO CONNECTION TO %TpAdminFOSHN% ON PORT 1801 ESTABLISHED!>> %Reach_MSMQ_TpAdminLogFilePath%
IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_FOS%" IF %ERRORLEVEL% NEQ 0 ECHO CONNECTION TO %TpAdminFOSHN% ON PORT 1801 FAILED!>> %Reach_MSMQ_TpAdminLogFilePath%
IF EXIST .\ps_telnet_tpadmin_test.ps1 DEL .\ps_telnet_tpadmin_test.ps1
CLS
ECHO  6.	TpAdmin MSMQ Connectivity Test
ECHO.
TYPE %Reach_MSMQ_TpAdminLogFilePath%
TYPE %Reach_MSMQ_TpAdminLogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
ECHO.
PAUSE
IF %CHECK%==99 GOTO CHK7
GOTO START

:CHK7
CLS
ECHO.
ECHO  7.	TxCollector Connectivity Test
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO %date% %time% > %ReachTxCollectorLogFilePath%
ECHO.>> %ReachTxCollectorLogFilePath%
ECHO PING BY HOSTNAME IN PROGRESS... PLEASE WAIT
ECHO.
ECHO PING BY HOSTNAME >> %ReachTxCollectorLogFilePath%
PING -n 3 %TxCollectorHN% >> %ReachTxCollectorLogFilePath%
ECHO TRACERT BY HOSTNAME IN PROGRESS... PLEASE WAIT
ECHO.
ECHO. >> %ReachTxCollectorLogFilePath%
ECHO TRACERT BY HOSTNAME >> %ReachTxCollectorLogFilePath%
TRACERT -d -h 7 %TxCollectorHN% >> %ReachTxCollectorLogFilePath%
ECHO. >> %ReachTxCollectorLogFilePath%
ECHO NSLOOKUP BY HOSTNAME IN PROGRESS... PLEASE WAIT
ECHO.
ECHO NSLOOKUP BY HOSTNAME >> %ReachTxCollectorLogFilePath%
ECHO. >> %ReachTxCollectorLogFilePath%
NSLOOKUP %TxCollectorHN% >> %ReachTxCollectorLogFilePath%
CLS
ECHO  7.	TxCollector Connectivity Test
ECHO.
TYPE %ReachTxCollectorLogFilePath%
TYPE %ReachTxCollectorLogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
PAUSE
IF %CHECK%==99 GOTO CHK8
GOTO START

:CHK8
CLS
ECHO param(>>ps_telnet_txcollector_test.ps1
ECHO     [string] $remoteHost = "%TxCollectorHN%",>>ps_telnet_txcollector_test.ps1
ECHO     [int] $port = 1801>>ps_telnet_txcollector_test.ps1
ECHO      )>>ps_telnet_txcollector_test.ps1
ECHO # Open the socket, and connect to the computer on the specified port>>ps_telnet_txcollector_test.ps1
ECHO write-host "Connecting to $remoteHost on port $port">>ps_telnet_txcollector_test.ps1
ECHO try {>>ps_telnet_txcollector_test.ps1
ECHO   $socket = new-object System.Net.Sockets.TcpClient($remoteHost, $port)>>ps_telnet_txcollector_test.ps1
ECHO } catch [Exception] {>>ps_telnet_txcollector_test.ps1
ECHO   write-host $_.Exception.GetType().FullName>>ps_telnet_txcollector_test.ps1
ECHO   write-host $_.Exception.Message>>ps_telnet_txcollector_test.ps1
ECHO   exit 1 >>ps_telnet_txcollector_test.ps1
ECHO }>>ps_telnet_txcollector_test.ps1
ECHO write-host "Connected.`n">>ps_telnet_txcollector_test.ps1
ECHO exit 0 >>ps_telnet_txcollector_test.ps1
ECHO.
ECHO  8.	TxCollector MSMQ Connectivity Test
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO %date% %time% > %Reach_MSMQ_TxCollectorLogFilePath%
ECHO. >> %Reach_MSMQ_TxCollectorLogFilePath%
ECHO Checking MSMQ Connection between POS and TXCOLLECTOR on port 1801...
ECHO.
Powershell -ExecutionPolicy ByPass -File .\ps_telnet_txcollector_test.ps1
ECHO TELNET TEST:>> %Reach_MSMQ_TxCollectorLogFilePath%
IF %ERRORLEVEL% EQU 0 ECHO CONNECTION TO %TxCollectorHN% ON PORT 1801 ESTABLISHED!>> %Reach_MSMQ_TxCollectorLogFilePath%
IF %ERRORLEVEL% NEQ 0 ECHO CONNECTION TO %TxCollectorHN% ON PORT 1801 FAILED!>> %Reach_MSMQ_TxCollectorLogFilePath%
IF EXIST .\ps_telnet_txcollector_test.ps1 DEL .\ps_telnet_txcollector_test.ps1
CLS
ECHO  8.	TxCollector MSMQ Connectivity Test
ECHO.
TYPE %Reach_MSMQ_TxCollectorLogFilePath%
TYPE %Reach_MSMQ_TxCollectorLogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
ECHO.
PAUSE
IF %CHECK%==99 GOTO CHK9
GOTO START

:CHK9
CLS
ECHO.
ECHO  9.	Microstrategy Connectivity Test
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO %date% %time% > %ReachMicrostrategyLogFilePath%
ECHO. >> %ReachMicrostrategyLogFilePath%
ECHO PING IN PROGRESS... PLEASE WAIT
ECHO.
ECHO PING: >>  %ReachMicrostrategyLogFilePath%
PING -n 3 mstr10.benettongroup.org >> %ReachMicrostrategyLogFilePath%
ECHO TRACERT IN PROGRESS... PLEASE WAIT
ECHO.
ECHO. >>  %ReachMicrostrategyLogFilePath%
ECHO TRACERT: >>  %ReachMicrostrategyLogFilePath%
TRACERT -d -h 10 mstr10.benettongroup.org >> %ReachMicrostrategyLogFilePath%
ECHO. >> %ReachMicrostrategyLogFilePath%
ECHO NSLOOKUP IN PROGRESS... PLEASE WAIT
ECHO.
ECHO NSLOOKUP: >>  %ReachMicrostrategyLogFilePath%
ECHO.>>  %ReachMicrostrategyLogFilePath%
NSLOOKUP mstr10.benettongroup.org >> %ReachMicrostrategyLogFilePath%
CLS
ECHO  9.	Microstrategy Connectivity Test
ECHO.
TYPE %ReachMicrostrategyLogFilePath%
TYPE %ReachMicrostrategyLogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
PAUSE
IF %CHECK%==99 GOTO CHK10
GOTO START

:CHK10
CLS
ECHO.
ECHO  10.	Internet Public Access Test
ECHO.
ECHO PING GOOGLE SITE... PLEASE WAIT
ECHO %date% %time% > %ReachInternetLogFilePath%
ECHO. >> %ReachInternetLogFilePath%
ECHO PING GOOGLE SITE >> %ReachInternetLogFilePath%
PING -n 3 www.google.com >> %ReachInternetLogFilePath%
ECHO. >> %ReachInternetLogFilePath%
ECHO.
ECHO PING GOOGLE PUBLIC DNS... PLEASE WAIT
ECHO.
ECHO PING GOOGLE PUBLIC DNS >> %ReachInternetLogFilePath%
PING -n 3 8.8.8.8 >> %ReachInternetLogFilePath%
CLS
ECHO  10.	Internet Public Access Test
ECHO.
TYPE %ReachInternetLogFilePath%
TYPE %ReachInternetLogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
ECHO.
PAUSE
IF %CHECK%==99 GOTO CHK11
GOTO START

:CHK11
CLS
ECHO.
ECHO  11.	MHT Loyalty WebService Connectivity Test
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO %date% %time% > %ReachMHTLogFilePath%
ECHO. > %ReachMHTLogFilePath%
ECHO PING IN PROGRESS... PLEASE WAIT
ECHO.
ECHO PING: >>  %ReachMHTLogFilePath%
PING -n 3 crmsvc.benetton.com >> %ReachMHTLogFilePath%
ECHO.
ECHO OPENING BROWSER PAGE... PLEASE WAIT
ECHO.
START "" https://crmsvc.benetton.com/IntegrationService/CrmIntegration.asmx
CLS
ECHO  11.	MHT Loyalty WebService Connectivity Test
ECHO.
ECHO ******************************************************************************************************
ECHO * A debug-level MHT Loyalty page will now be opened on default browser.                              *
ECHO * If page titled "CRM Integration" is loaded successfully, test is OK. You may close the browser.    *
ECHO ******************************************************************************************************
TYPE %ReachMHTLogFilePath%
TYPE %ReachMHTLogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
ECHO.
PAUSE
IF %CHECK%==99 IF /I "%COUNTRY%"=="DE" IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" GOTO CHK12
IF %CHECK%==99 IF /I "%COUNTRY%"=="ES" IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" GOTO CHK13
GOTO START

:CHK12
CLS
ECHO.
ECHO  12.	DE Store: EFT Connectivity Test
ECHO.
SET /P EFT=Please, insert the IP Address of the EFT related to this POS: 
ECHO param(>>ps_telnet_test.ps1
ECHO     [string] $remoteHost = "%EFT%",>>ps_telnet_test.ps1
ECHO     [int] $port = 20002>>ps_telnet_test.ps1
ECHO      )>>ps_telnet_test.ps1
ECHO # Open the socket, and connect to the computer on the specified port>>ps_telnet_test.ps1
ECHO write-host "Connecting to $remoteHost on port $port">>ps_telnet_test.ps1
ECHO try {>>ps_telnet_test.ps1
ECHO   $socket = new-object System.Net.Sockets.TcpClient($remoteHost, $port)>>ps_telnet_test.ps1
ECHO } catch [Exception] {>>ps_telnet_test.ps1
ECHO   write-host $_.Exception.GetType().FullName>>ps_telnet_test.ps1
ECHO   write-host $_.Exception.Message>>ps_telnet_test.ps1
ECHO   exit 1 >>ps_telnet_test.ps1
ECHO }>>ps_telnet_test.ps1
ECHO write-host "Connected.`n">>ps_telnet_test.ps1
ECHO exit 0 >>ps_telnet_test.ps1
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO %date% %time% > %DE_EFTTestLogFilePath%
ECHO. >> %DE_EFTTestLogFilePath%
ECHO PING POS EFT: >> %DE_EFTTestLogFilePath%
PING -n 3 %EFT% >> %DE_EFTTestLogFilePath%
CLS
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO TELNET POS EFT
ECHO.
ECHO Checking connection between POS and EFT on port 20002...
ECHO.
ECHO. >> %DE_EFTTestLogFilePath%
Powershell -ExecutionPolicy ByPass -File .\ps_telnet_test.ps1
ECHO TELNET TEST:>> %DE_EFTTestLogFilePath%
IF %ERRORLEVEL% EQU 0 ECHO CONNECTION ON EFT WITH IP: %EFT% ON PORT 20002 ESTABLISHED!>> %DE_EFTTestLogFilePath%
IF %ERRORLEVEL% NEQ 0 ECHO CONNECTION ON EFT WITH IP: %EFT% ON PORT 20002 FAILED!>> %DE_EFTTestLogFilePath%
IF EXIST .\ps_telnet_test.ps1 DEL .\ps_telnet_test.ps1
CLS
ECHO  12.	DE Store: EFT Connectivity Test
ECHO.
TYPE %DE_EFTTestLogFilePath%
TYPE %DE_EFTTestLogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
ECHO.
PAUSE
IF %CHECK%==99 IF /I "%COUNTRY%"=="ES" IF /I "%CHANNEL%"=="%CHANNEL_VARIANT_DOS%" GOTO CHK13
GOTO START

:CHK13
CLS
ECHO.
ECHO  13.	ES Store: REDSYS Connectivity Test (EFT)
ECHO.
ECHO CHECK IN PROGRESS... PLEASE WAIT
ECHO.
ECHO %date% %time% > %ES_EFTTestLogFilePath%
ECHO. > %ES_EFTTestLogFilePath%
ECHO PING IN PROGRESS... PLEASE WAIT
ECHO.
ECHO PING: >>  %ES_EFTTestLogFilePath%
PING -n 3 tpvpc.redsys.es >> %ES_EFTTestLogFilePath%
PING -n 3 canales.redsys.es >> %ES_EFTTestLogFilePath%
ECHO.
ECHO OPENING REDSYS BROWSER PAGE... PLEASE WAIT
ECHO.
START "" http://canales.redsys.es
CLS
ECHO  13.	ES Store: REDSYS Connectivity Test (EFT)
ECHO.
ECHO ******************************************************************************************************
ECHO * The Redsys Portal page will now be opened on default browser to check its reachability.            *
ECHO * If site is loaded successfully, test is OK. You may close the browser.                             *
ECHO ******************************************************************************************************
ECHO.
TYPE %ES_EFTTestLogFilePath%
TYPE %ES_EFTTestLogFilePath% >> "%PATH_TO_LOGFILE_ALL%"
ECHO.
PAUSE
GOTO START

:WRONGNAME
CLS
ECHO.
ECHO ******************************************************************************************************
ECHO *                    WARNING: THIS MACHINE DOES NOT RESPECT THE NAME CONVENTION                      *
ECHO ******************************************************************************************************
ECHO.
ECHO.
ECHO.
ECHO If you want to run the script in debug you have to call "Network_Troubleshooting_Tool.bat p1 p2 p3 p4"
ECHO Possible options (First option is default in case of Empty Parameter)
ECHO.
ECHO Parameter p1 - Mode  	[0 = Default ^| 1 = Debug]
ECHO Parameter p2 - Channel [D/DO/DOS = Direct Stores ^| F/FO/FOS = Franchisee Stores]
ECHO Parameter p3 - Country [I/IT = Italy ^| D/DE = Germany ^| E/ES = Spain ^| F/FR = France ^| R/RU = Russia] 
ECHO Parameter p4 - Type    [R = Reference ^| P = Production]
ECHO.
ECHO Example1: Debug Run, DOS German Reference Store 		"Network_Troubleshooting_Tool.bat 1 D D R"
ECHO.
ECHO Example2: Normal Run, FOS Italian Production Store		"Network_Troubleshooting_Tool.bat 0 F I P"
ECHO.
ECHO Example3: Debug Run, DOS Spain Reference Store			"Network_Troubleshooting_Tool.bat 1 D E R"
ECHO.
ECHO ******************************************************************************************************
ECHO * 3rd Parameter is requested to debug dedicated Country functions (Choice 12,13)                     *
ECHO ******************************************************************************************************
ECHO.
PAUSE
:CHK0
IF /I "%PROCESSING_MODE%"=="%PROCESSING_MODE_DEBUG%" GOTO END 
EXIT

:END
ECHO.
endlocal
