@ECHO off
REM ****************************************************************************************************************
REM ** This script builds Azure-uAMQP-C for use by the ANSI C samples.
REM ** This requires CMAKE to be installed.
REM ** This must be run from a Visual Studio command line.
REM ****************************************************************************************************************
SETLOCAL

set CMAKEEXE=cmake
set SRCDIR=%~dp0\src\azure-uamqp-c
set INSTALLDIR=%~dp0

IF NOT EXIST %SRCDIR% GOTO noSource
cd %SRCDIR%

IF "%1"=="no-clean" GOTO noClean
ECHO STEP 1) Deleting old projects.
IF EXIST %INSTALLDIR%\azure-uamqp-c rmdir /s /q %INSTALLDIR%\azure-uamqp-c
IF EXIST .\build rmdir /s /q .\build
:noClean

IF NOT EXIST .\build MKDIR .\build

ECHO STEP 2) Running CMAKE...
set OpenSSLDir=%INSTALLDIR%\openssl
cd .\build
%CMAKEEXE% -Duse_schannel:BOOL=ON -Duse_openssl:BOOL=OFF -Dmemory_trace:bool=OFF ..

ECHO STEP 3) Building project...
msbuild ALL_BUILD.vcxproj /p:Configuration=Debug 

ECHO STEP 4) Install Azure-uAMQP-C...

cd ..
IF NOT EXIST %INSTALLDIR% MKDIR %INSTALLDIR%
IF NOT EXIST %INSTALLDIR%\azure-uamqp-c MKDIR %INSTALLDIR%\azure-uamqp-c
IF NOT EXIST %INSTALLDIR%\azure-uamqp-c\include MKDIR %INSTALLDIR%\azure-uamqp-c\include
IF NOT EXIST %INSTALLDIR%\azure-uamqp-c\lib MKDIR %INSTALLDIR%\azure-uamqp-c\lib

XCOPY /Y /Q ".\build\Debug\*.*" "%INSTALLDIR%\azure-uamqp-c\lib"
XCOPY /Y /Q ".\build\c-utility\Debug\*.*" "%INSTALLDIR%\azure-uamqp-c\lib"
XCOPY /Y /Q /S ".\inc" "%INSTALLDIR%\azure-uamqp-c\include" 
XCOPY /Y /Q /S ".\c-utility\inc" "%INSTALLDIR%\azure-uamqp-c\include" 

ECHO *** ALL DONE ***
GOTO theEnd

:noSource
ECHO.
ECHO Azure-uAMQP-C source not found. Please check the path.
ECHO Searched for: %SRCDIR%
GOTO theEnd

:theEnd
ENDLOCAL