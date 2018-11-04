@echo off
:: Поиск python.
::
:: Если python будет найден, будет настроена переменная среды Path.
:: Если python не будет найден, вывод соответсвующей информации и выход из cmd.
::
:: Note: Пути к python.exe должны быть прописаны в %~n0.paths.

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
call :parse_platform PLATFORM_NAME PLATFORM_CODE %INPUT_PLATFORM%
call :parse_version VERSION %INPUT_VERSION%

set INPUT_PLATFORM=
set INPUT_VERSION=

set APP=python.exe

call :search_application "" "%APP%" :check_python "%VERSION%" "%PLATFORM_CODE%"
if "%ERRORLEVEL%" == "0" (
    exit /b 0
)

set P=
for /f "eol=# tokens=*" %%a in (%~dpn0.paths) do (
    call :search_application "%%a" "%APP%" :check_python "%VERSION%" "%PLATFORM_CODE%"
    if !ERRORLEVEL! == 0 (
        set P=%%a
        goto :end
    )
)
echo Error: Python not found. [%~f0]
echo        Append python path to file: [%~dpn0.paths]
exit 1

:end
endlocal&set Path=%P%;%Path%

exit /b 0


:: ------------------------------------------------------------------------------------------------
:usage
echo Usage: %~nx0 [options]
echo Options:
echo   --help or -h               - this screen
echo   --platform arc or -p arc   - arc - platform (x86 or x64)
echo   --version vers or -v vers  - vers - version of python
exit /b 0

:parse_platform 
:: Разбор аргумента командной строки "platform"
::
:: %%1 - имя переменной для установки PLATFORM_NAME;
:: %%2 - имя переменной для установик PLATFORM_CODE;
:: %%3 - значение аргумента "platform" для разбора.
setlocal EnableDelayedExpansion
call _sub.bat develop\parse_platform.bat _PLATFORM_NAME _PLATFORM_CODE ERROR_TEXT %3
if %ERRORLEVEL% == 1 (
    set _PLATFORM_NAME=
    set _PLATFORM_CODE=
) else if not %ERRORLEVEL% == 0 (
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
    set VERSION=
) else if "%~2" == "2" (
    set VERSION=2
) else if "%~2" == "3" (
    set VERSION=3
) else (
    echo Error. Unknown version of python [%~f0 :parse_version]
    exit 1
)
endlocal&set %1=%VERSION%
exit /b 0


:check_python
:: Проверка python.
::
:: %%1 - полный путь к python;
:: %%2 - версия;
:: %%3 - код платформы.
::
:: Выход:
:: ERRORLEVEL == 0 - все хорошо;
:: ERRORLEVEL == 1 - все плохо.

setlocal EnableDelayedExpansion
:: echo PATH:     %1
:: echo VERSION:  %2
:: echo PLATFORM: %3

if not "%~2" == "" (
    call :check_python_version "%~1" "%~2"
    if not !ERRORLEVEL! == 0 (
        
        exit /b 1
    )
)

if not "%~3" == "" (
    call :check_python_platform "%~1" "%~3"
    if not !ERRORLEVEL! == 0 (
        exit /b 1
    )
)
endlocal
exit /b 0

:check_python_version
:: Проверка версии python.
:: %%1 - полный путь к python;
:: %%2 - версия.
::
:: Выход:
:: ERRORLEVEL == 0 - версия соответствует;
:: ERRORLEVEL == 1 - версия не соответствует.

setlocal
set PV=
for /F "usebackq tokens=2 delims=. " %%a in (`%~1 -V 2^>^&1`) do (
    set PV=%%a
)
if "%PV%" == "%~2" (
    exit /b 0
) else (
    exit /b 1
)
endlocal
echo Error. Reached unreachable. [%~f0 :check_python_version]
exit 1


:check_python_platform
:: Проверка разрядности python.
:: %%1 - полный путь к python;
:: %%2 - код платформы.
::
:: Выход:
:: ERRORLEVEL == 0 - разрядность соответствует;
:: ERRORLEVEL == 1 - разрядность не соответствует.
setlocal
set PP=
set CMD=%~1 -c "import struct;print(8 * struct.calcsize('P'))"
for /F "usebackq" %%a in (`%CMD%`) do (
    set PP=x%%a
)
if "%PP%" == "%~2" (
    exit /b 0
) else (
    exit /b 1
)
endlocal
echo Error. Reached unreachable. [%~f0 :check_python_platform]
exit 1


:search_application
:: Поиск приложения.
::
:: %%1 - предполагаемый путь к приложению, если пусто, ищется в Path.
:: %%2 - имя файла для поиска;
:: %%3 - если есть, callback для дополнительной проверки.
::
:: Выход:
:: ERRORLEVEL == 0 - приложение найдено;
:: ERRORLEVEL == 1 - приложение не найдено.

setlocal EnableDelayedExpansion
if "%~1" == "" (
    call _sub.bat tools\expand_path.bat APP_PATH $PATH: "%~2"
    if "!APP_PATH!" == "" (
        exit /b 1
    )
) else (
    set APP_PATH=%~1\%~2
    if not exist "!APP_PATH!" (
        exit /b 1
    )
)

if "%~3" == "" (
    exit /b 0
)

set ARGS=
:search_application_args
if not -%4- == -- (
    set ARGS=%ARGS% "%~4"
    shift /4
    goto :search_application_args
)
call %~3 "!APP_PATH!"%ARGS%
if not %ERRORLEVEL% == 0 (
    exit /b 1
) else (
    exit /b 0
)
endlocal
echo Error. Reached unreachable. [%~f0 :search_application]
exit 1

