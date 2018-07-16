@echo off
setlocal enabledelayedexpansion

:: Сборка Qt
::
:: %%1  - путь к каталогу Qt (версия)
:: %%2  - путь для теневой сборки (platform)

if "%1" == "" (
   echo Error: Path to Qt is empty.
   exit 1
)
if "%2" == "" (
   echo Error: Shadow name is empty.
   exit 1
)
if not exist "%~f1\src\" (
   echo Directory 'src' don't exists in path [%~f1].
   exit 0
)

:: формат даты вида: yyyy-mm-dd
set CURDATE=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
set CURTIME=%TIME: =0%

set PATH=C:\WINDOWS;C:\WINDOWS\system32
call "%~dp0set_ruby.bat"
call "%~dp0set_perl.bat"
call "%~dp0set_python.bat"
call "%~dp0set_jom.bat"
call "%~dp0set_msvc.bat" x86
call "%~dp0set_log.bat" "%~f1\%CURDATE%-log.txt"
call "%~dp0set_openssl_inc_lib.bat"
call "%~dp0set_llvm.bat"

set QT_VERSION=%~1
set QT_BUILD_NAME=%~2
set QT_DIR_BASE=%~f1
set QT_DIR_SRC=%QT_DIR_BASE%\src
set QT_DIR_BUILD=%QT_DIR_BASE%\%QT_BUILD_NAME%
set QT_LOG=%QT_DIR_BASE%\%CURDATE%

:: Examples
::QT_BUILD_NAME=msvc-2017
::QT_DIR_BASE=C:\Qt\5.10.1
::QT_DIR_BUILD=C:\Qt\5.10.1\msvc-2017
::QT_DIR_SRC=C:\Qt\5.10.1\src
::QT_VERSION=5.10.1
::CURDATE=2018-07-01
::CURTIME=02:20:03,45

set PATH=%QT_DIR_SRC%\gnuwin32\bin;%QT_DIR_BUILD%\qtbase\bin;%PATH%

set step=%QT_DIR_BASE%\_step.bat

:: QMAKESPEC
:: QTDIR

set QT_BUILD_OPTIONS=^
-platform win32-msvc ^
-prefix ^"%QT_DIR_BUILD%\qtbase^" ^
-debug-and-release ^
-opensource ^
-confirm-license ^
-sql-odbc ^
-sql-sqlite ^
-force-asserts ^
-qt-zlib ^
-qt-pcre ^
-qt-libpng ^
-qt-libjpeg ^
-qt-freetype ^
-openssl-runtime ^
-nomake examples ^
-nomake tests ^
-plugin-manifests ^
-shared ^
-mp
::-c++std c++11

set >%QT_LOG%__set.txt

::exit 0
:: ------------------------------------------------------------------------------------------------
:: Build
goto start_build

exit 0
:: ------------------------------------------------------------------------------------------------
:step_conf
%log% " Start configuring..."
%log% " Options: %QT_BUILD_OPTIONS%"
call %QT_DIR_SRC%\configure.bat %QT_BUILD_OPTIONS%>"%QT_LOG%__00_config.txt" 2>&1
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% " End configuring"
exit /b %ERRORLEVEL%

:: ------------------------------------------------------------------------------------------------
:step_make
%log% " Start compile..."
jom>>"%QT_LOG%__01_make_nmake.txt" 2>&1
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% " End compile"
exit /b %ERRORLEVEL%

:: ------------------------------------------------------------------------------------------------
:step_install
%log% " Start install..."
jom install>>"%QT_LOG%__02_make_install.txt" 2>&1
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% " End install"
exit /b %ERRORLEVEL%

:: ------------------------------------------------------------------------------------------------
:step_docs
%log% " Start creating documentation..."
jom docs>>"%QT_LOG%__03_make_jom_docs.txt" 2>&1
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% " End create documentation"
exit /b %ERRORLEVEL%

:: ------------------------------------------------------------------------------------------------
:step_mkdir
if not exist "%QT_DIR_BUILD%" (
    %log% " [%QT_DIR_BUILD%] not found. Try create..."
    mkdir "%QT_DIR_BUILD%" >nul 2>&1
    if exist "%QT_DIR_BUILD%" %log% " [%QT_DIR_BUILD%] created successfully."
)
if not exist "%QT_DIR_BUILD%" (
    %log% " [%QT_DIR_BUILD%] not created. ERROR!!!"
    exit /b 1
)
cd /D %QT_DIR_BUILD%
exit /b 0


:: ------------------------------------------------------------------------------------------------
:begin_log
%log% "Start build Qt %QT_VERSION%"
exit /b 0

:end_log_ok
%log% "End build Qt"
exit /b 0

:end_log_error
%log% "End build Qt with error!"
exit /b 0

:save_steps
echo set STEP_CONF=%STEP_CONF% >%step%
echo set STEP_MAKE=%STEP_MAKE% >>%step%
echo set STEP_INSTALL=%STEP_INSTALL% >>%step%
echo set STEP_DOCS=%STEP_DOCS% >>%step%
exit /b 0

:load_steps
if exist %step% (
    call %step%
) else (
    set STEP_CONF=1
    set STEP_MAKE=1
    set STEP_INSTALL=1
    set STEP_DOCS=1
    call :save_steps
)
exit /b 0

:start_build
call :load_steps
::if "%1" == "conf" (
::    set STEP_CONF=1
::    set STEP_MAKE=0
::    set STEP_DOCS=0
::) else if "%1" == "make" (
::    set STEP_CONF=0
::    set STEP_MAKE=1
::    set STEP_DOCS=0
::) else if "%1" == "docs" (
::    set STEP_CONF=0
::    set STEP_MAKE=0
::    set STEP_DOCS=1
::)
::if not exist %QT_DIR_BUILD%\Makefile (
::    set STEP_CONF=1
::)

call :begin_log
call :step_mkdir
if not %ERRORLEVEL% == 0 (
    call :end_log_error
    exit /b %ERRORLEVEL%
)

if not %STEP_CONF% == 1 goto skip_conf
call :step_conf
if not %ERRORLEVEL% == 0 (
    call :end_log_error
    exit /b 1
) else (
    set STEP_CONF=0
    call :save_steps
)
:skip_conf

if not %STEP_MAKE% == 1 goto skip_make
call :step_make
if not %ERRORLEVEL% == 0 (
    call :end_log_error
    exit /b 1
) else (
    set STEP_MAKE=0
    call :save_steps
)
:skip_make

::goto :skip_install
if not %STEP_INSTALL% == 1 goto skip_install
call :step_install
if not %ERRORLEVEL% == 0 (
    call :end_log_error
    exit /b 1
) else (
    set STEP_INSTALL=0
    call :save_steps
)
:skip_install

::goto :skip_docs
if not %STEP_DOCS% == 1 goto skip_docs
call :step_docs
if not %ERRORLEVEL% == 0 (
    call :end_log_error
    exit /b 1
) else (
    set STEP_DOCS=0
    call :save_steps
)
:skip_docs

call :end_log_ok
exit /b 0
