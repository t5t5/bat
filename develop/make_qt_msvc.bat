@echo off
:: Сборка Qt

setlocal EnableDelayedExpansion

set DEBUG=0
set INPUT_PLATFORM=
set INPUT_DIR=
:parse_arguments
if "%~1" == "--help" (
    call :usage
    exit 0
) else if "%~1" == "-h" (
    call :usage
    exit 0
) else if "%~1" == "--platform" (
    set INPUT_PLATFORM=%~2
    shift /1
) else if "%~1" == "-p" (
    set INPUT_PLATFORM=%~2
    shift /1
) else if "%~1" == "--dir" (
    set INPUT_DIR=%~2
    shift /1
) else if "%~1" == "-d" (
    set INPUT_DIR=%~2
    shift /1
) else if "%~1" == "--debug" (
    set DEBUG=1
) else if "%~1" == "" (
    goto :main
) else (
    echo Error. Unknown parameter {%~1}. [%~f0 :parse_arguments]
    exit 1
)
shift /1
goto :parse_arguments

:main
call :parse_platform PLATFORM_NAME PLATFORM_CODE %INPUT_PLATFORM%
call :parse_directory QT_BASE_DIR "%INPUT_DIR%"

set INPUT_PLATFORM=
set INPUT_DIR=

call _sub tools\expand_path QT_BUILD_NAME n %QT_BASE_DIR%
if not %ERRORLEVEL% == 0 (
    echo Error. Can't get Qt name from path. {%QT_BASE_DIR%}. [%~f0 :main]
    exit 1
)

:: формат даты вида: yyyy-mm-dd
set CURDATE=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
set CURTIME=%TIME: =0%

set PATH=C:\WINDOWS;C:\WINDOWS\system32
set PATH=C:\Progs\bat;%PATH%
call "%~dp0set_ruby.bat"
call "%~dp0set_perl.bat"
call "%~dp0set_python.bat"
call "%~dp0set_jom.bat"
call "%~dp0set_msvc.bat" %PLATFORM_NAME%
call "%~dp0set_log.bat" "%QT_BASE_DIR%\%CURDATE%--%PLATFORM_CODE%-log.txt"
call "%~dp0set_openssl_inc_lib.bat" -p %PLATFORM_NAME% -v 1.0.2
call "%~dp0set_icu_inc_lib.bat" --platform %PLATFORM_NAME%
call "%~dp0set_llvm.bat" %PLATFORM_NAME%

set QT_BUILD_NAME=msvc-2017
set QT_SRC_DIR=%QT_BASE_BASE%\src
set QT_BUILD_DIR=%QT_BASE_DIR%\%QT_BUILD_NAME%-%PLATFORM_CODE%
set QT_LOG_DIR=%QT_BASE_DIR%\%QT_BUILD_NAME%-%PLATFORM_CODE%

:: Examples
::QT_BUILD_NAME=msvc-2017
::QT_DIR_BASE=C:\Qt\5.10.1
::QT_DIR_BUILD=C:\Qt\5.10.1\msvc-2017
::QT_DIR_SRC=C:\Qt\5.10.1\src
::QT_VERSION=5.10.1
::CURDATE=2018-07-01
::CURTIME=02:20:03,45

set PATH=%QT_SRC_DIR%\gnuwin32\bin;%QT_BUILD_DIR%\qtbase\bin;%PATH%

set step=%QT_BASE_DIR%\_step.bat

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

set >%QT_LOG_DIR%__set.txt

exit
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

:: ------------------------------------------------------------------------------------------------
:usage
echo Usage: %~nx0 [options]
echo Options:
echo   --help or -h               - this screen
echo   --platform arc or -p arc   - arc - platform (x86 or x64)
echo   --dir path or -d path      - path - base directory with Qt
echo   --debug                    - debug info about build
exit /b 0


:parse_platform 
:: Разбор аргумента командной строки "platform"
::
:: %%1 - имя переменной для установки PLATFORM_NAME;
:: %%2 - имя переменной для установик PLATFORM_NAME;
:: %%3 - значение аргумента "platform" для разбора.
setlocal EnableDelayedExpansion
call _sub.bat develop\parse_platform.bat _PLATFORM_NAME _PLATFORM_CODE ERROR_TEXT %3
if not %ERRORLEVEL% == 0 (
    echo Error. %ERROR_TEXT% [%~f0]
    exit 1
)
endlocal&set %1=%_PLATFORM_NAME%&set %2=%_PLATFORM_CODE%
exit /b 0


:parse_directory
:: Разбор пути, где будет сборка.
::
:: %%1 - имя переменной для установки пути сборки;
:: %%2 - путь для разбора;
setlocal EnableDelayedExpansion
set INPUT_DIR=%CD%
if not "%~1" == "" (
    set INPUT_DIR=%~f2
)
if not exist "%INPUT_DIR%\" (
    echo Error. Base directory not found {%INPUT_DIR%}. [%~f0 :parse_directory]
    exit 1
)
if not exist "%INPUT_DIR%\src\" (
    echo Error. Directory 'src' don't exists in path {%INPUT_DIR%}. [%~f0 :parse_directory]
    exit 1
)
endlocal&set %1=%INPUT_DIR%
exit /b 0


:load_steps
:: Загрузка файла с шагами сборки. Чтоб можно было пропустить шаг.
::
:: %%1 - имя файла с шагами сборки.
if exist "%~1" (
    for /f "delims== tokens=1,2" %%a in (%~1) do ( set %%a=%%b )
) else (
    call :save_steps "%~1"
)
exit /b 0


:save_steps
:: Записать файл с шагами сборки.
::
:: %%1 - имя файла с шагами сборки.
if not exist "%~dp1" (
    mkdir "%~dp1" >nul 2>&1
)
set STEP_>"%~1" 2>nul
exit /b 0


