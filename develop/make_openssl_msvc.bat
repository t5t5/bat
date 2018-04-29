@echo off
setlocal enabledelayedexpansion

set OPENSSL_NAME=openssl_102_20180428

set PATH=C:\Progs\bat;%PATH%

:: формат даты вида: yyyy-mm-dd
set CURDATE=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
set CURTIME=%TIME: =0%

call _sub develop\set_msvc.bat x86
call _sub develop\set_perl.bat
call _sub develop\set_log.bat "%~dp0%OPENSSL_NAME%\%CURDATE%-log.txt"

set OPENSSL_INSTALL_DIR=%~dp0%OPENSSL_NAME%
set OPENSSL_SRC_DIR=%~dp0%OPENSSL_NAME%\src
set OPENSSL_LOG_DIR=%~dp0%OPENSSL_NAME%
set STEP_FILE=%~dp0%OPENSSL_NAME%\make_step.bat

:: ------------------------------------------------------------------------------------------------
::Build
goto start_build
exit 0
:: ------------------------------------------------------------------------------------------------
:ossl_make_install_dir
if not exist "%OPENSSL_INSTALL_DIR%" (
    %log% " [%OPENSSL_INSTALL_DIR%] not found. Try create..."
    mkdir "%OPENSSL_INSTALL_DIR%" >nul 2>&1
    if exist "%OPENSSL_INSTALL_DIR%" %log% " [%OPENSSL_INSTALL_DIR%] created successfully."
)
if not exist "%OPENSSL_INSTALL_DIR%" (
    %log% " [%OPENSSL_INSTALL_DIR%] not created. ERROR!!!"
    exit /b 1
)
exit /b 0

:: ------------------------------------------------------------------------------------------------
:ossl_test_src_dir
if not exist "%OPENSSL_SRC_DIR%" (
    %log% " [%OPENSSL_SRC_DIR%] not exists. ERROR!!!"
    exit /b 1
)
cd %OPENSSL_SRC_DIR%
exit /b 0

:: ------------------------------------------------------------------------------------------------
:ossl_configure
%log% " Configure..."
perl Configure VC-WIN32 no-asm --prefix=%OPENSSL_INSTALL_DIR% enable-static-engine >%OPENSSL_LOG_DIR%\1-configure.txt 2>&1
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% " End configure"
exit /b %ERRORLEVEL%

:: ------------------------------------------------------------------------------------------------
:ossl_assign_numbers
%log% " Assign numbers..."
perl util\mkdef.pl crypto ssl update >%OPENSSL_LOG_DIR%\2-assign.txt 2>&1
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% " End assign numbers"
exit /b %ERRORLEVEL%

:: ------------------------------------------------------------------------------------------------
:ossl_prepare
%log% " Prepare..."
call ms\do_ms >%OPENSSL_LOG_DIR%\3-prepare.txt 2>&1
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% " End prepare"
exit /b %ERRORLEVEL%

:: ------------------------------------------------------------------------------------------------
:ossl_compile
%log% " Compile..."
nmake -f ms\ntdll.mak >>%OPENSSL_LOG_DIR%\4-compile.txt 2>&1
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% " End compile"
exit /b %ERRORLEVEL%

:: ------------------------------------------------------------------------------------------------
:ossl_test
%log% " Test..."
nmake -f ms\ntdll.mak test >%OPENSSL_LOG_DIR%\5-test.txt 2>&1
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% " End test"
exit /b %ERRORLEVEL%

:: ------------------------------------------------------------------------------------------------
:ossl_install
%log% " Install..."
nmake -f ms\ntdll.mak install >%OPENSSL_LOG_DIR%\6-install.txt 2>&1
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% " End install"
exit /b %ERRORLEVEL%

:: ------------------------------------------------------------------------------------------------
:begin_log
%log% "Start build OPENSSL %OPENSSL_NAME%"
exit /b 0

:end_log_ok
%log% "End build OPENSSL"
exit /b 0

:end_log_error
%log% "End build OPENSSL with error!"
exit /b 0

:save_steps
:: %%1 - step file name
if not exist "%~dp1" (
    mkdir "%~dp1" >nul 2>&1
)
echo set STEP_CONFIGURE=%STEP_CONFIGURE% >"%~1"
echo set STEP_ASSIGN=%STEP_ASSIGN% >>"%~1"
echo set STEP_PREPARE=%STEP_PREPARE% >>"%~1"
echo set STEP_COMPILE=%STEP_COMPILE% >>"%~1"
echo set STEP_TEST=%STEP_TEST% >>"%~1"
echo set STEP_INSTALL=%STEP_INSTALL% >>"%~1"
exit /b 0

:load_steps
:: %%1 - step file name
if exist "%~1" (
    call "%~1"
) else (
    set STEP_CONFIGURE=1
    set STEP_ASSIGN=1
    set STEP_PREPARE=1
    set STEP_COMPILE=1
    set STEP_TEST=1
    set STEP_INSTALL=1
    call :save_steps "%~1"
)
exit /b 0

:: ------------------------------------------------------------------------------------------------
:start_build
call :load_steps %STEP_FILE%
call :begin_log
call :ossl_test_src_dir
if not %ERRORLEVEL% == 0 (
    call :end_log_error
    exit /b 1
)
call :ossl_make_install_dir
if not %ERRORLEVEL% == 0 (
    call :end_log_error
    exit /b 1
)
if %STEP_CONFIGURE% == 1 (
    call :ossl_configure
    if not !ERRORLEVEL! == 0 (
        call :end_log_error
        exit /b 1
    )
)
set STEP_CONFIGURE=0
call :save_steps "%STEP_FILE%"

if %STEP_ASSIGN% == 1 (
    call :ossl_assign_numbers
    if not !ERRORLEVEL! == 0 (
        call :end_log_error
        exit /b 1
    )
)
set STEP_ASSIGN=0
call :save_steps "%STEP_FILE%"

if %STEP_PREPARE% == 1 (
    call :ossl_prepare
    if not !ERRORLEVEL! == 0 (
        call :end_log_error
        exit /b 1
    )
)
set STEP_PREPARE=0
call :save_steps "%STEP_FILE%"

if %STEP_COMPILE% == 1 (
    call :ossl_compile
    if not !ERRORLEVEL! == 0 (
        call :end_log_error
        exit /b 1
    )
)
set STEP_COMPILE=0
call :save_steps "%STEP_FILE%"

if %STEP_TEST% == 1 (
    call :ossl_test
    if not !ERRORLEVEL! == 0 (
        call :end_log_error
        exit /b 1
    )
)
set STEP_TEST=0
call :save_steps "%STEP_FILE%"

if %STEP_INSTALL% == 1 (
    call :ossl_install
    if not !ERRORLEVEL! == 0 (
        call :end_log_error
        exit /b 1
    )
)
set STEP_INSTALL=0
call :save_steps "%STEP_FILE%"

call :end_log_ok
exit /b 0


