@echo off
:: Поиск cmake.
::
:: Если cmake будет найден, будет настроена переменная среды Path.
:: Если cmake не будет найден, вывод соответсвующей информации и выход из cmd.
::
:: Note: Пути к cmake.exe должны быть прописаны в %~n0.paths.

setlocal EnableDelayedExpansion
set APP=cmake.exe

call :check_in_path "%APP%"
if %ERRORLEVEL% == 0 (
    exit /b 0
)

set P=
for /f "eol=# delims=; tokens=1,*" %%a in (%~dpn0.paths) do (
    echo ---%%a---%%b---
    call :check_path "%%a" "%%b" "%APP%"
    if !ERRORLEVEL! == 0 ( goto :end )
)
echo Error: cmake not found. [%~f0]
echo        Append cmake path to file [%~dpn0.paths]
exit 1

:check_path
:: Проверка наличия файла по определенному пути.
:: %%1 - Путь для проверки;
:: %%2 - Путь для установки;
:: %%3 - Имя файла для поиска.
::
:: Выход:
:: ERRORLEVEL = 0 найден
:: P          = пути
::
:: ERRORLEVEL = 1 не найден
if exist "%~1\%~3" (
    set P=%~1;%~2
    exit /b 0
)
exit /b 1

:check_in_path
:: Поиск файла в стандартных путях PATH
:: %%1  - файл
:: 
:: Выход:
:: ERRORLEVEL = 0 найден
:: ERRORLEVEL = 1 не найден
if not "%~$path:1" == "" (
    exit /b 0
)
exit /b 1

:end
endlocal&set Path=%P%;%Path%

exit /b 0
