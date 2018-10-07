@echo off
:: Включение INCLUDE и LIB для openssl.
::
setlocal EnableDelayedExpansion

set INPUT_PLATFORM=
set INPUT_VERSION=
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
) else if "%~1" == "" (
    goto :main
) else (
    echo Error. Unknown parameter {%~1}. [%~f0 :parse_arguments]
    exit 1
)
shift /1
goto :parse_arguments

:main
set PATTERN_SUPPORTED_VERSION=1[0-1][0-9x]
set PATTERN_10x=10[0-9x]
set PATTERN_11x=11[0-9x]
call :parse_platform PLATFORM_NAME PLATFORM_CODE %INPUT_PLATFORM%
call :parse_version OPENSSL_VERSION "%INPUT_VERSION%"

set OPENSSL_SETUP_FILE=%~dpn0_%OPENSSL_VERSION%__%PLATFORM_CODE%.bat
if not exist "%OPENSSL_SETUP_FILE%" (
    echo Error. No include and lib setup file. {VERSION: %OPENSSL_VERSION%; PLATFORM: %PLATFORM_CODE%}. [%~f0 :main]
    exit 1
)
endlocal&call %OPENSSL_SETUP_FILE%

exit /b 0

:: ------------------------------------------------------------------------------------------------
:usage
echo Usage: %~nx0 [options]
echo Options:
echo   --help or -h               - this screen
echo   --platform arc or -p arc   - arc - platform (x86 or x64)
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
if "%~2" == "" (
    echo Error. Version not defined. [%~f0 :parse_version]
    exit 1
)
set VERSION=%~2
set VERSION=%VERSION:.=%
for /F "delims=" %%a in ('echo %VERSION%^|findstr /RIC:%PATTERN_SUPPORTED_VERSION%') do (
    set A=%%a
)

if "%A%" == "" (
    echo Error. Can't detect version. {%VERSION%}. [%~f0 :parse_version]
    exit 1
)
call :get_version VERSION %VERSION%
if not %ERRORLEVEL% == 0 (
    echo Error. Unknown version. [%~f0 :parse_version]
    exit 1
)
endlocal&set %1=%VERSION%
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


