@echo off
:: %%1 - вызывающий батник
:: %%2 - файл с описанием аргуметов
:: %%3 ... 

setlocal EnableDelayedExpansion

:: echo ---
:: echo %*
:: echo ---

set SENDER_BAT=%~1

for /f "eol=# tokens=1,2,3 delims=;" %%a in (%~2) do (
    call _sub.bat tools\trim_right.bat OPTION_NAME "%%a"
    call _sub.bat tools\trim_right.bat OPTION_TYPE "%%b"
    call _sub.bat tools\trim_right.bat OPTION_VALUE "%%c"

    call :trim_left_char OPTION_NAME - "!OPTION_NAME!"
    :: echo [!OPTION_NAME!]--[!OPTION_TYPE!]--[!OPTION_VALUE!]
    if "!OPTION_TYPE!" == "set" (
        set OPTION_ACTION_!OPTION_NAME!=!OPTION_VALUE!
    ) else if "!OPTION_TYPE!" == "callback" (
        set OPTION_ACTION_!OPTION_NAME!=!OPTION_VALUE!
    ) else (
        echo Error. Unknown option type {!OPTION_TYPE!} [%~f0]
        exit 1
    )
)
:: set OPTION_ACTION_

:parse_arguments
if "%~3" == "" (
    exit /b 0
)
call :trim_left_char OPTION_NAME - "%~3"

call :variable__get_value_by_name ACTION OPTION_ACTION_%OPTION_NAME% "-NF-"
if "%ACTION%" == "-NF-" (
    echo Error.
    exit 1
)
set %ACTION%=%~4
set

endlocal
exit 1

:trim_left_char
:: %%1  - имя переменной для установки значения;
:: %%2  - char;
:: %%3..- строка для обработки.
setlocal
for /f "tokens=* delims=%~2" %%a in ("%~3") do endlocal&set %~1=%%a
exit /b 0


:variable__get_value_by_name
:: Получить числовое значение переменной по имени.
::
:: %%1 - имя переменной для установки значение;
:: %%2 - имя переменной;
:: %%3 - значение по умолчанию, если переменная не найдена или пустая.
::
:: Выход:
:: ERRORLEVEL == 0 - все нормально.
echo [%~1]-[%~2]-[%~3]
call :variable__is_empty %%%2%%
if %ERRORLEVEL% == 1 (
    set %~1=%~3
    exit /b 0
)
for /f "delims== tokens=2" %%a in ('set %2') do (
    set %~1=%%a
    exit /b 0
)
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

