@echo off
:: Поиск cygwin.
::
:: Если cygwin будет найден, будет настроена переменная среды Path.
:: Если cygwin не будет найден, вывод соответсвующей информации и выход из cmd.
::
:: Note: Пути к cygwin должны быть прописаны в %~n0.paths.

setlocal EnableDelayedExpansion
set APP=uname.exe

call :search_cygwin "" "%APP%"
if %ERRORLEVEL% == 0 (
    exit /b 0
)

set P=
for /f "eol=# tokens=*" %%a in (%~dpn0.paths) do (
    call :search_cygwin "%%a" "%APP%"
    if !ERRORLEVEL! == 0 (
        set P=%%a
        goto :end
    )
)
echo Error. Cygwin not found. [%~f0]
echo        Append cygwin path to file: [%~dpn0.paths]
exit 1

:end
endlocal&set Path=%P%;%Path%

exit /b 0

:search_cygwin
:: Поиск cygwin.
::
:: %%1 - предполагаемый путь к бинарникам cygwin, если пусто, ищется в Path;
:: %%2 - имя файла для поиска (uname.exe).
::
:: Выход:
:: ERRORLEVEL == 0 - cygwin найден;
:: ERRORLEVEL == 1 - cygwin не найден.
setlocal EnableDelayedExpansion
if "%~1" == "" (
    call _sub.bat tools\expand_path.bat CYGWIN_PATH $PATH: "%~2"
    if "!CYGWIN_PATH!" == "" (
        exit /b 1
    )
) else (
    set CYGWIN_PATH=%~1\%~2
    if not exist "!CYGWIN_PATH!" (
        exit /b 1
    )
)
for /f %%a in ('"%CYGWIN_PATH%" -o') do (
    if /I "%%a" == "Cygwin" (
        exit /b 0
    )
)
endlocal
exit /b 1
