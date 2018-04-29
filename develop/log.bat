@echo off
:: Вывод сообщения в лог файл и в консоль.
:: %%1  - file
:: %%2  - message for loggin
:: Как использовать описано в файле set_log.bat

echo %DATE% %TIME: =0%	%~2>>%1
echo %DATE% %TIME: =0%	%~2
