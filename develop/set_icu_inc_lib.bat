@echo off
:: Включение INCLUDE и LIB для ICU.
::
setlocal EnableDelayedExpansion

set INPUT_PLATFORM=
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

set ICU_SETUP_FILE=%~dpn0_%PLATFORM_CODE%.bat
if not exist "%ICU_SETUP_FILE%" (
    echo Error. No include and lib setup file. {VERSION: %ICU_VERSION%; PLATFORM: %PLATFORM_CODE%}. [%~f0 :main]
    exit 1
)
endlocal&call %ICU_SETUP_FILE%

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
