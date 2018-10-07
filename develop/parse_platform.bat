@echo off
:: Разбор типа платформы (x86, x32, x64)
::
:: %%1  - имя параметра для команды set куда нужно установить имя платформы (x86 или x64).
:: %%2  - имя параметра для команды set куда нужно установить код платформы (x32 или x64).
:: %%3  - имя параметра для команды set куда нужно установить текст ошибки (ERRORLEVEL != 0)
:: %%4  - параметр для разбора
::
:: Выход:
:: ERRORLEVEL = 0 - успешно разобрано, параметры 1 и 2 заполнены.
:: ERRORLEVEL = 1 - ошибка. Platform not specified.
:: ERRORLEVEL = 2 - ошибка. Unknown platform.

if "%~4" == "" (
    set %3=Platform not specified.
    exit /b 1
)

if "%~4" == "x32" (
    set %1=x86
    set %2=x32
) else if "%~4" == "x86" (
    set %1=x86
    set %2=x32
) else if "%~4" == "x64" (
    set %1=x64
    set %2=x64
) else (
    set %3=Unknown platform {%~4}.
    exit /b 2
)
exit /b 0

