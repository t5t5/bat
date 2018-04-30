@echo off
:: Поиск python в стандартных для него путях.
::
:: Если python будет найден, будут установленны соответствующие переменные среды.
:: Если python не будет найден, вывод соответсвующей информации и выход из cmd.

call :check_path_file "python.exe"
if "%ERRORLEVEL%" == "0" (
    exit /b 0
) else if exist "C:\Python37\python.exe" (
    call :set_path "C:\Python37\Scripts" "C:\Python37"
    exit /b 0
) else if exist "C:\Python36\python.exe" (
    call :set_path "C:\Python36\Scripts" "C:\Python36"
    exit /b 0
) else if exist "C:\Python35\python.exe" (
    call :set_path "C:\Python35\Scripts" "C:\Python35"
    exit /b 0
) else (
    echo Error: Python not found!
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
:: %%1  - path 1 to set
:: %%2  - path 2 to set
set PATH=%~1;%~2;%PATH%
exit /b 0
