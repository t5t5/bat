@echo off
:: Убрать пробелы справа.
::
:: %%1  - имя параметра для команды set куда нужно установить значение.
:: %%2..- строка для обработки

setlocal
set P=%~2
:loop
if "%P:~-1%" == " " (
    set P=%P:~0,-1%
) else (
    goto :end
)
goto :loop
:end
endlocal&set %~1=%P%
exit /b 0
