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

:: формат даты вида: yyyy-mm-dd
set CURDATE=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
set CURTIME=%TIME: =0%

set QT_BUILD_NAME=llvm-1100
set QT_SRC_DIR=%QT_BASE_DIR%\src
set QT_BUILD_DIR=%QT_BASE_DIR%\%QT_BUILD_NAME%-%PLATFORM_CODE%
set QT_LOG_DIR=%QT_BASE_DIR%\%QT_BUILD_NAME%-%PLATFORM_CODE%-files
set QT_STEP_FILE=%QT_LOG_DIR%\make_step.txt
set QT_STEPS=%~dpn0.steps

call :create_dir "%QT_LOG_DIR%"

set PATH=C:\WINDOWS;C:\WINDOWS\system32
set PATH=C:\Progs\bat;%PATH%
call "%~dp0set_temp.bat"
call "%~dp0set_ruby.bat"
call "%~dp0set_perl.bat"
call "%~dp0set_python.bat" -v 2 -p %PLATFORM_NAME%
call "%~dp0set_jom.bat"
call "%~dp0set_msvc.bat" %PLATFORM_NAME%
call "%~dp0set_log.bat" "%QT_LOG_DIR%\log.txt"
call "%~dp0set_openssl_inc_lib.bat" -p %PLATFORM_NAME% -v 1.1.1
call "%~dp0set_icu_inc_lib.bat" --platform %PLATFORM_NAME%
call "%~dp0set_llvm.bat" %PLATFORM_NAME%

set PATH=%QT_SRC_DIR%\gnuwin32\bin;%QT_BUILD_DIR%\qtbase\bin;%PATH%

set QT_BUILD_OPTIONS=^
-platform win32-clang-msvc ^
-no-pch ^
-prefix ^"%QT_BUILD_DIR%\qtbase^" ^
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
-plugin-manifests ^
-skip qtwebengine ^
-skip qtconnectivity ^
-nomake examples ^
-nomake tests ^
-shared ^
-mp

::-c++std c++11

set >%QT_LOG_DIR%\set.txt

:: exit

if not exist "%QT_STEPS%" (
    echo Error. Can't find steps file. {%QT_STEPS%}. [%~f0 :main]
    exit 1
)
call :load_steps %QT_STEP_FILE%
call :begin_log

for /F "eol=# tokens=1,2,3,4,5,6 delims=;" %%a in (%QT_STEPS%) do (
    call _sub.bat tools\trim_right.bat __A "%%a"
    call _sub.bat tools\trim_right.bat __B "%%b"
    call _sub.bat tools\trim_right.bat __C "%%c"
    call _sub.bat tools\trim_right.bat __D "%%d"
    call _sub.bat tools\trim_right.bat __E "%%e"
    call _sub.bat tools\trim_right.bat __F "%%f"
    call :process_step "!__A!" "!__B!" "!__C!" "!__D!" "!__E!" "!__F!"
    if not !ERRORLEVEL! == 0 ( goto :end )
)
:end

call :end_log "%ERRORLEVEL%"
exit /b 0

:: ------------------------------------------------------------------------------------------------
:process_step
:: Обработка шага сборки
::
:: %%1 - begin log message;
:: %%2 - end log message;
:: %%3 - command;
:: %%4 - STEP;
:: %%5 - w - rewrite log, a - append log;
:: %%6 - log file
:: echo [%~1] - [%~2] - [%~3] - [%~4] - [%~5] - [%~6]
if not "%~4" == "-" (
    call :variable__get_value_by_name %~4 1
    if !ERRORLEVEL! == 0 ( exit /b 0 )
)
%log% "%~1"
%log% " Cmd: [%~3]"
if "%~5" == "a" (
    %~3 >>%~6 2>&1
) else if "%~5" == "w" (
    %~3 >%~6 2>&1
) else if "%~5" == "s" (
    %~3
)
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% "%~2"
if not %ERRORLEVEL% == 0 (
    exit /b 1
)
if not "%~4" == "-" (
    set %~4=0
    call :save_steps "%QT_STEP_FILE%"
)
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


:create_dir
:: Проверить наличие папки, и создать в случае необходимости.
::
:: %%1 - путь папки.
if not exist "%~1" (
    mkdir "%~1" >nul 2>&1
)
if not exist "%~1" (
    echo Error. Can't create directory {%~1}. [%~f0 :create_dir]
    exit 1
)
exit /b 0

:create_dir_log
:: Проверить наличие папки, и создать в случае необходимости.
::
:: %%1 - папки папки.
if not exist "%~1" (
    %log% " [%~1] not found. Try create..."
    mkdir "%~1" >nul 2>&1
    if exist "%~1" %log% " [%~1] created successfully."
)
if not exist "%~1" (
    %log% " [%~1] not created. ERROR!!!"
    exit /b 1
)
exit /b 0


:begin_log
:: Начать логирование.
%log% "Start build Qt %QT_VERSION% [%PLATFORM_CODE%]"
exit /b 0


:end_log
:: Закончить логирование.
::
:: %%1 == 0 - ошибок не было;
:: %%1 != 0 - были ошибки.
if "%~1" == "0" (
    %log% "End build Qt"
) else (
    %log% "End build Qt with error!"
)
exit /b 0


:variable__get_value_by_name
:: Получить числовое значение переменной по имени.
::
:: %%1 - Имя переменной;
:: %%2 - Значение по умолчанию, если переменная не найдена или пустая.
::
:: Выход:
:: ERRORLEVEL == %%2 - если переменная не найдена или пустая;
:: ERRORLEVEL        - значение переменной с именем %%1
call :variable__is_empty %%%1%%
if %ERRORLEVEL% == 1 ( exit /b %2 )
for /f "delims== tokens=2" %%a in ('set %1') do (exit /b %%a)
echo Error. Reached unreachable! [%~f0 :variable__get_value_by_name]
exit 1


:variable__is_empty
:: Проверить значени на пустоту.
::
:: %%1 - значение для проверки.
::
:: Выход:
:: ERRORLEVEL == 1 - значение отсутствует;
:: ERRORLEVEL == 0 - значение присутствует.
if "%1" == "" (exit /b 1) else (exit /b 0)
echo Error. Reached unreachable! [%~f0 :variable__is_empty]
exit 1

