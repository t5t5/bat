@echo off
:: Сборка OpenSSL.

setlocal EnableDelayedExpansion

set DEBUG=0
set INPUT_PLATFORM=
set INPUT_VERSION=
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
) else if "%~1" == "--version" (
    set INPUT_VERSION=%~2
    shift /1
) else if "%~1" == "-v" (
    set INPUT_VERSION=%~2
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
set PATTERN_SUPPORTED_VERSION=_1[0-1][0-9]_
set PATTERN_10x=_10[0-9]_
set PATTERN_11x=_11[0-9]_
call :parse_platform PLATFORM_NAME PLATFORM_CODE %INPUT_PLATFORM%
call :parse_version OPENSSL_VERSION "%INPUT_VERSION%"
call :parse_directory OPENSSL_BASE_DIR OPENSSL_VERSION "%INPUT_DIR%" "%OPENSSL_VERSION%"

set INPUT_PLATFORM=
set INPUT_VERSION=
set INPUT_DIR=

call _sub tools\expand_path OPENSSL_NAME n %OPENSSL_BASE_DIR%
if not %ERRORLEVEL% == 0 (
    echo Error. Can't get openssl name from path {%OPENSSL_BASE_DIR%}. [%~f0 :main]
    exit 1
)

:: формат даты вида: yyyy-mm-dd
set CURDATE=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
set CURTIME=%TIME: =0%

call "%~dp0set_temp.bat"
call "%~dp0set_msvc.bat" %PLATFORM_NAME%
call "%~dp0set_perl.bat"
call "%~dp0set_jom.bat"
call "%~dp0set_log.bat" "%OPENSSL_BASE_DIR%\%CURDATE%--%PLATFORM_CODE%-log.txt"

set OPENSSL_INSTALL_DIR=%OPENSSL_BASE_DIR%\%PLATFORM_CODE%\bin
set OPENSSL_SSL_DIR=%OPENSSL_INSTALL_DIR%\ssl
set OPENSSL_SRC_DIR=%OPENSSL_BASE_DIR%\%PLATFORM_CODE%\src
set OPENSSL_LOG_DIR=%OPENSSL_BASE_DIR%\%PLATFORM_CODE%
set OPENSSL_STEP_FILE=%OPENSSL_BASE_DIR%\%PLATFORM_CODE%\make_step.txt
set OPENSSL_STEPS=%~dpn0_%OPENSSL_VERSION%_%PLATFORM_CODE%.steps

if "%DEBUG%" == "1" (
    :: x32 or x64
    echo PLATFORM_CODE       =%PLATFORM_CODE%
    :: x86 or x64
    echo PLATFORM_NAME       =%PLATFORM_NAME%
    echo OPENSSL_BASE_DIR    =%OPENSSL_BASE_DIR%
    echo OPENSSL_NAME        =%OPENSSL_NAME%
    echo OPENSSL_VERSION     =%OPENSSL_VERSION%
    echo OPENSSL_INSTALL_DIR =%OPENSSL_INSTALL_DIR%
    echo OPENSSL_SSL_DIR     =%OPENSSL_SSL_DIR%
    echo OPENSSL_SRC_DIR     =%OPENSSL_SRC_DIR%
    echo OPENSSL_LOG_DIR     =%OPENSSL_LOG_DIR%
    echo OPENSSL_STEP_FILE   =%OPENSSL_STEP_FILE%
    echo OPENSSL_STEPS       =%OPENSSL_STEPS%
)


if not exist "%OPENSSL_STEPS%" (
    echo Error. Can't find steps file. {%OPENSSL_STEPS%}. [%~f0 :main]
    exit 1
)

call :load_steps %OPENSSL_STEP_FILE%
call :begin_log

for /F "eol=# tokens=1,2,3,4,5,6 delims=;" %%a in (%OPENSSL_STEPS%) do (
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
::echo [%~1] - [%~2] - [%~3] - [%~4] - [%~5] - [%~6]
if not "%~4" == "-" (
    call :variable__get_value_by_name %~4 1
    if !ERRORLEVEL! == 0 ( exit /b 0 )
)
%log% "%~1"
if "%~5" == "a" (
    %~3 >>%~6 2>&1
) else if "%~5" == "w" (
    %~3 >%~6 2>&1
)
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% "%~2"
if not %ERRORLEVEL% == 0 (
    exit /b 1
)
if not "%~4" == "-" (
    set %~4=0
    call :save_steps "%OPENSSL_STEP_FILE%"
)
exit /b 0

:: ------------------------------------------------------------------------------------------------
:usage
echo Usage: %~nx0 [options]
echo Options:
echo   --help or -h               - this screen
echo   --platform arc or -p arc   - arc - platform (x86 or x64)
echo   --dir path or -d path      - path - base directory with openssl
echo   --version vers or -v vers  - version OpenSSL
echo   --debug                    - debug info about build
exit /b 0


:parse_platform 
:: Разбор аргумента командной строки "platform"
::
:: %%1 - имя переменной для установки PLATFORM_NAME;
:: %%2 - имя переменной для установик PLATFORM_CODE;
:: %%3 - значение аргумента "platform" для разбора.
setlocal EnableDelayedExpansion
call _sub.bat develop\parse_platform.bat _PLATFORM_NAME _PLATFORM_CODE ERROR_TEXT %3
if not %ERRORLEVEL% == 0 (
    echo Error. %ERROR_TEXT% [%~f0 :parse_platform]
    exit 1
)
endlocal&set %1=%_PLATFORM_NAME%&set %2=%_PLATFORM_CODE%
exit /b 0


:parse_version
:: Разбор входного параметра с версией.
::
:: %%1 - имя переменной для установки версии;
:: %%2 - версия для разбора.
setlocal EnableDelayedExpansion
set VERSION=%~2
if not "%~2" == "" (
    set VERSION=%VERSION:.=%
) else (
    set VERSION=
)
endlocal&set %1=%VERSION%
exit /b 0


:parse_directory
:: Разбор пути, где будет сборка.
::
:: %%1 - имя переменной для установки пути сборки;
:: %%2 - имя переменной для установки значения версии;
:: %%3 - путь для разбора;
:: %%4 - версия для разбора.
setlocal EnableDelayedExpansion
set INPUT_DIR=%CD%
if not "%~1" == "" (
    set INPUT_DIR=%~f3
)
if not exist "%INPUT_DIR%\" (
    echo Error. Base directory not found {%INPUT_DIR%}. [%~f0 :parse_directory]
    exit 1
)
if not exist "%INPUT_DIR%\src\" (
    echo Error. Directory 'src' don't exists in path {%INPUT_DIR%}. [%~f0 :parse_directory]
    exit 1
)
if not "%~4" == "" (
    set VERSION=_%~4_
) else (
    set VERSION=%INPUT_DIR%
)
for /F "delims=" %%a in ('echo %VERSION%^|findstr /RIC:%PATTERN_SUPPORTED_VERSION%') do (
    set A=%%a
)
if "%A%" == "" (
    echo Error. Can't detect version. {%VERSION%}. [%~f0 :parse_directory]
    exit 1
)
call :get_version VERSION %VERSION%
if not %ERRORLEVEL% == 0 (
    echo Error. Unknown version. [%~f0 :parse_directory]
    exit 1
)
endlocal&set %2=%VERSION%&set %1=%INPUT_DIR%
exit /b 0


:get_version
:: Получить версию.
::
:: %%1 - имя переменной для установки значения версии;
:: %%2 - строка содержащая версию.
:: 
:: Выход:
:: ERRORLEVEL = 0 - успешно разобрано, параметр заполнен.
:: ERRORLEVEL = 1 - ошибка.
set %1=
for /F "delims=" %%a in ('echo %~2^|findstr /RIC:%PATTERN_10x%') do (
    set %1=10x
    exit /b 0
)
for /F "delims=" %%a in ('echo %~2^|findstr /RIC:%PATTERN_11x%') do (
    set %1=11x
    exit /b 0
)
exit /b 1


:begin_log
:: Начать логирование.
%log% "Start build OPENSSL %OPENSSL_NAME% [%PLATFORM_CODE%]"
exit /b 0


:end_log
:: Закончить логирование.
::
:: %%1 == 0 - ошибок не было;
:: %%1 != 0 - были ошибки.
if "%~1" == "0" (
    %log% "End build OPENSSL"
) else (
    %log% "End build OPENSSL with error!"
)
exit /b 0


:check_src_dir
:: Проверить наличие папки с исходниками OpenSSL. И переход в нее.
if not exist "%OPENSSL_SRC_DIR%" (
    %log% " [%OPENSSL_SRC_DIR%] not exists. ERROR!!!"
    exit /b 1
)
cd %OPENSSL_SRC_DIR%
exit /b 0


:make_install_dir
:: Проверить наличие папки для установки OpenSSL. И создать в случае необходимости.
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


:create_inc_lib_file
:: Создать файл для включения INCLUDE и LIB.
setlocal
set SET_INC_LIB_FILE=%~dp0set_openssl_inc_lib_%OPENSSL_VERSION%__%PLATFORM_CODE%.bat
set SET_INC_LIB_FILE_BAK=%~dp0set_openssl_inc_lib_%OPENSSL_VERSION%__%PLATFORM_CODE%.bak

if exist "%SET_INC_LIB_FILE%" (
    move /Y "%SET_INC_LIB_FILE%" "%SET_INC_LIB_FILE_BAK%" 1>nul 2>&1
)

echo :: auto genarated by %~nx0 at %CURDATE% %CURTIME%>"%SET_INC_LIB_FILE%"
echo set INCLUDE=%%INCLUDE%%;%OPENSSL_INSTALL_DIR%\include>>"%SET_INC_LIB_FILE%"
echo set LIB=%%LIB%%;%OPENSSL_INSTALL_DIR%\lib>>"%SET_INC_LIB_FILE%"
endlocal
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

