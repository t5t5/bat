@echo off
:: Прочитать значение из реестра
:: %%1  - имя параметра для команды set куда нужно установить значение
:: %%2  - путь в реестре
:: %%3  - имя параметра

for /f "usebackq tokens=1,2,*" %%i in (`reg query "%~2" /v "%~3"`) do (set %1=%%k)
exit /b 0