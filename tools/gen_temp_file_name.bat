@echo off
:: Сгенерировать уникальное имя файла для временного файла.
::
:: %%1  - имя параметра для команды set куда нужно установить значение.

if "%~1" == "" (
    echo Error. Not set parameter name.
    exit 1
)

:unique_loop
set %1=%TEMP%\bat~%RANDOM%.tmp
call :is_exist %1
if %ERRORLEVEL% == 0 (
    exit /b 0
) else if %ERRORLEVEL% == 1 (
    goto :unique_loop
)
echo Error. Gen temp file name fail!
exit 1

:is_exist
:: Проверить наличие файла.
::
:: Вх:  %%1 имя параметра где лежит имя файла
:: Вых: ERRORLEVEL=1 - файл существует
::      ERRORLEVEL=0 - файл не существует
for /f "usebackq tokens=2* delims==" %%a in (`set %1`) do (
   if exist "%%a" (
       exit /b 1
   ) else (
       exit /b 0
   )
)
exit /b 2
