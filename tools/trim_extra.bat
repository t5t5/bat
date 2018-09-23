@echo off
:: Убрать лишние пробелы в строке, а также полностью в начале и конце строки.
::
:: %%1  - имя параметра для команды set куда нужно установить значение.
:: %%2..- строка для обработки.

setlocal EnableDelayedExpansion
set P=%*
for /f "tokens=1*" %%a in ("!P!") do endlocal&set %1=%%b
exit /b 0
