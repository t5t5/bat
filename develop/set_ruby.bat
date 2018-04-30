@echo off
:: Поиск ruby в стандартных для него путях.
::
:: Если ruby будет найден, будут установленны соответствующие переменные среды.
:: Если ruby не будет найден, вывод соответсвующей информации и выход из cmd.

call :check_path_file "ruby.exe"
if "%ERRORLEVEL%" == "0" (
    exit /b 0
) else if exist "C:\Ruby23-x64\bin\ruby.exe" (
    call :set_path "C:\Ruby23-x64\bin"
    exit /b 0
) else (
    echo Error: Ruby not found!
    exit 1
)

:check_path_file
:: Поиск файла в стандартных путях PATH
:: %%1  - файл
:: 
:: Выход:
:: %%ERRORLEVEL%% = 0 найден
:: %%ERRORLEVEL%% = 1 не найден
if not "%~$path:1" == "" (
    exit /b 0
) else (
    exit /b 1
)

:set_path
:: Helper для set, из if не всегда срабатывает
:: %%1  - path to set
set PATH=%~1;%PATH%
exit /b 0
