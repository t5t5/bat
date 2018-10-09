@echo off
:: Проверить включено ли отложенное расширение переменных среды.
:: Вых: ERRORLEVEL=1 - отложенное расширение переменных среды включено;
::      ERRORLEVEL=0 - отложенное расширение переменных среды выключено.

setlocal

set A=1
if "1!A!" == "11" ( goto :ede_enabled )
exit /b 0
:ede_enabled
exit /b 1

endlocal
