@ECHO OFF
:_LOOP

CLS

ECHO.
ECHO.
ECHO.	    =================================================
ECHO.	    =                                               =
ECHO.	    =                                               =
ECHO.	    =            Rustide v1.7 by Jarsky             =
ECHO.	    =   This script auto updates Rust Game + uMOD   =
ECHO.	    =             Updated 01 January 2022           =
ECHO.	    =                                               =
ECHO.	    =                                               =
ECHO.	    =================================================
ECHO.
ECHO.

REM :: SET YOUR SERVER SETTINGS HERE
REM :: YOU MUST CHANGE THE RCON PASSWORD

set _hostname="Rustide Server"
set _ident="rustide"
set _port="28015"
set _rport="28016"
set _rcon="rust123"
set _players="100"
set _level="Procedural Map"
set _seed="0"
set _worldsize="4000"
set _serverimg="http://i.imgur.com/yHWZSYQ.png"
set _serverurl="http://oxidemod.org"
set _serverdesc="Welcome to our Rustide server!"

REM :: HERE ARE SOME MORE ADVANCED SETTINGS

set _autostart=YES
set _autorestart=NO
set _autoupdate=YES
set _forceupdate=NO
set _savebackup=YES
set _maxbackups=10
set _backuploc=.\backups

REM :: DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOURE DOING

PING 127.0.0.1 -n 5 >NUL 2>&1 || PING ::1 -n 5 >NUL 2>&1



IF "%_rcon%"==""rust123"" (GOTO _RKILL)
IF "%_autoupdate%"=="NO" (
GOTO _BACKUP
) ELSE (
IF "%_forceupdate%"=="YES" (
GOTO _UPDATE
) ELSE (
GOTO _CHECK))

:_CHECK
REM ++Check if Process Running before updating++
TASKLIST /FI "IMAGENAME eq RustDedicated.exe" 2>NUL | FIND /I /N "RustDedicated.exe">NUL
IF "%ERRORLEVEL%"=="0" (
ECHO. ANOTHER RUST IS RUNNING - UPDATE SKIPPED. 
PING 127.0.0.1 -n 30 >NUL 2>&1 || PING ::1 -n 5 >NUL 2>&1
ECHO. SERVER WILL CONTINUE STARTING SOON...
PING 127.0.0.1 -n 60 >NUL 2>&1 || PING ::1 -n 5 >NUL 2>&1
GOTO _BACKUP
)


REM ++Update Rust Install++
IF EXIST .\SteamCMD GOTO _UPDATE
wget.exe https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip --no-check-certificate
7za.exe x .\steamcmd.zip -oSteamCMD -y
DEL .\steamcmd.zip /q

:_UPDATE
ECHO	Initiating Rust Update
.\SteamCMD\steamcmd.exe	+force_install_dir +login anonymous ../Rust +app_update 258550 -beta experimental validate +quit

REM ++Get the Oxide Files++
IF EXIST	.\Oxide-Rust\ {
DEL .\Oxide-Rust\*.* /q
RMDIR /s /q .\Oxide-Rust
}

:_OXIDEUPDATE
wget.exe -w 3 https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust.zip --no-check-certificate --no-proxy --secure-protocol=TLSv1_2 -O Oxide-Rust.zip

IF EXIST .\Oxide-Rust.zip (GOTO _BACKUP) ELSE GOTO _OXIDEUPDATE

REM ++Check for the server and make a backup++

:_BACKUP
7za.exe x .\Oxide-Rust.zip -o* -y
DEL .\Oxide-Rust.zip /q
IF EXIST .\temp {
DEL .\temp\*.* /q
RMDIR /s /q .\temp
}
MKDIR .\temp
XCOPY /i /s /q /y .\rust\server\%_ident%\*.* .\temp\server\%_ident%\
IF EXIST .\rust\oxide\oxide.config.json XCOPY /i /s /q /y .\rust\oxide\*.* .\temp\oxide\
REM ::PUT ANY OTHER FILES TO COPY HERE::
REM ::--------------------------------::
IF EXIST .\rust\RustDedicated_Data\Managed\*RustIO*.dll XCOPY /i /s /q /y .\rust\RustDedicated_Data\Managed\*RustIO*.dll .\temp\RustDedicated_Data\Managed\

REM ::--------------------------------::

IF "%_savebackup%"=="NO" (GOTO _BUILD)
IF EXIST .\temp\oxide\data\*.data (GOTO _ZIP) ELSE GOTO _BUILD
:_ZIP
SET backupname=backup_%_ident%-%date:~-4,4%.%date:~-7,2%.%date:~-10,2%-%time:~0,2%.%time:~3,2%
7za.exe a -r "%_backuploc%\%backupname%".zip "%~dp0\temp\*"
FOR /F "SKIP=%_maxbackups% EOL=: DELIMS=" %%F IN ('DIR /b /o-d %_backuploc%\backup_%_ident%-*.zip') DO @DEL "%_backuploc%\%%F"

:_BUILD
IF EXIST .\build RMDIR /s /q .\build
MOVE .\temp build
XCOPY /s /q /y .\Oxide-Rust .\build
IF EXIST .\build XCOPY /s /q /y .\build .\rust
RMDIR /s /q .\Oxide-Rust
IF EXIST .\build RMDIR /s /q .\build

IF "%_autostart%"=="YES" (GOTO _RUN) 

SET /P ANSWER=Do you want to start Rust (Y/N)?
if /i {%ANSWER%}=={y} (GOTO _RUN)
if /i {%ANSWER%}=={yes} (GOTO _RUN)
GOTO _NORUN

:_RUN
PUSHD rust
.\RustDedicated.exe -batchmode +server.hostname %_hostname% +server.port %_port% +server.identity %_ident% +server.maxplayers %_players% +rcon.port %_rport% +rcon.password %_rcon% +rcon.ip 0.0.0.0 +server.saveinterval 900 +server.level %_level% +server.seed %_seed% +server.url %_serverurl% +server.headerimage %_serverimg% +server.description %_serverdesc% +server.globalchat true +server.worldsize %_worldsize% +cfg "server\%_ident%\cfg\server.cfg" -autoupdate
IF "%_autorestart%"=="NO" {
POPD
CLS
ECHO. Server %_hostname% will restart on port %_port%
PING 127.0.0.1 -n 5 >NUL 2>&1 || PING ::1 -n 5 >NUL 2>&1
GOTO _LOOP
}

EXIT

:_NORUN
CLS
ECHO.     UPDATING HAS FINISHED BUT YOU HAVE DISABLED AUTOSTART    
PAUSE
EXIT

:_RKILL
CLS 
ECHO.    ****YOU MUST CHANGE THE RCON PASSWORD TO RUN****
PAUSE
EXIT
