@echo off
:: Поиск 7-zip.
::
:: Если 7-zip будет найден, будут установленны соответствующие переменные среды.
:: Если 7-zip не будет найден, вывод соответсвующей информации и выход из cmd.

call :check_path_file %1
if "%ERRORLEVEL%" == "0" (
    exit /b 0
) else if exist "%ProgramFiles%\7-Zip\7zG.exe" (
    call :set_path "%ProgramFiles%\7-Zip"
    exit /b 0
) else if exist "%ProgramFiles(x86)%\7-Zip\7zG.exe" (
    call :set_path "%ProgramFiles(x86)%\7-Zip"
    exit /b 0
) else (
    echo Error: 7-zip not found!
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
