@echo off
:: Поиск jom.
::
:: Если jom будет найден, будет настроена переменная среды Path.
:: Если jom не будет найден, вывод соответсвующей информации и выход из cmd.
::
:: Note: Пути к jom.exe должны быть прописаны в %~n0.paths.

setlocal EnableDelayedExpansion
set APP=jom.exe

call :check_in_path "%APP%"
if "%ERRORLEVEL%" == "0" (
    exit /b 0
)

set P=
for /f "eol=# tokens=*" %%a in (%~dpn0.paths) do (
    call :check_path "%%a" "%APP%"
    if !ERRORLEVEL! == 0 ( goto :end )
)
echo Error: Jom not found. [%~f0]
echo        Append jom path to file: [%~dpn0.paths]
exit 1

:check_path
:: Проверка наличия файла по определенному пути.
:: %%1 - Путь для проверки;
:: %%2 - Имя файла для поиска.
::
:: Выход:
:: ERRORLEVEL = 0 найден
:: ERRORLEVEL = 1 не найден

if exist "%~1\%~2" (
    set P=%~1
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
set P=
exit /b 0

