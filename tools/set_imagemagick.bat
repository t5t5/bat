@echo off
:: Поиск утилиты imagemagick.
::
:: %%1  - имя утилиты из пакета imagemagic, например mogrify.exe
:: Если утилита imagemagick будет найдена, будут установленны соответствующие переменные среды.
:: Если утилита imagemagick не будет найдена, вывод соответсвующей информации и выход из cmd.

call :check_path_file %1
if "%ERRORLEVEL%" == "0" (
    exit /b 0
) else if exist "C:\Progs\ImageMagick\%~nx1" (
    call :set_path "C:\Progs\ImageMagick"
    exit /b 0
) else (
    echo Error: ImageMagick not found!
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
