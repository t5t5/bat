@echo off
:: call helper для вызова bat из подкаталогов.
:: %%1  - bat
:: %%2... аргументы для %%1

if "%1" == "" (
    echo Error. Bat not specified.
    exit 1
)

set FILE_BAT=%~dp0%~1

shift

:: %%1 - point to parameters
set ARGS=
:do_tasks_args
if not "%~1" == "" (
   set ARGS=%ARGS% %1
   shift
   goto :do_tasks_args
)

call "%FILE_BAT%"%ARGS%
exit /b %ERRORLEVEL%
