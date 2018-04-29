@echo off
:: Поиск перла в стандартных для него путях.
::
:: Если перл будет найден, будут установленны соответствующие переменные среды.
:: Если перл не будет найден, вывод соответсвующей информации и выход из cmd.

call :check_perl "perl.exe"
if "%ERRORLEVEL%" == "0" (
    exit /b 0
) else if exist "C:\Perl64\bin\perl.exe" (
    call :set_path "C:\Perl64\bin" "C:\Perl64\site\bin"
    exit /b 0
) else if exist "C:\Perl\bin\perl.exe" (
    call :set_path "C:\Perl\bin" "C:\Perl\site\bin"
    exit /b 0
) else (
    echo Error: Perl not found!
    exit 1
)

:check_perl
:: Поиск перла в стандартных путях PATH
:: %%1  - perl.exe
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
:: %%1  - path to perl\bin
:: %%2  - path to perl\site\bin
set PATH=%~1;%~2;%PATH%
exit /b 0
