@echo off
:: Поиск TortoiseGit.
::
:: Если TortoiseGit будет найден, будет настроена переменная среды Path.
:: Если TortoiseGit не будет найден, вывод соответсвующей информации и выход из cmd.
::
:: Note: Пути к TortoiseGit должны быть прописаны в %~n0.paths.

setlocal EnableDelayedExpansion
set APP=TortoiseGitProc.exe

call :search_tgit "" "%APP%"
if %ERRORLEVEL% == 0 (
    exit /b 0
)

set P=
for /f "eol=# tokens=*" %%a in (%~dpn0.paths) do (
    call :search_tgit "%%a" "%APP%"
    if !ERRORLEVEL! == 0 (
        set P=%%a
        goto :end
    )
)
echo Error. TortoiseGit not found. [%~f0]
echo        Append tgit path to file: [%~dpn0.paths]
exit 1

:end
endlocal&call :set_tgit_path "%P%"

exit /b 0

:set_tgit_path
:: Установка пути.
:: %%1 - путь к бинарникам tgit.
set Path=%~1;%Path%
exit /b 0

:search_tgit
:: Поиск tgit.
::
:: %%1 - предполагаемый путь к бинарникам tgit, если пусто, ищется в Path;
:: %%2 - имя файла для поиска
::
:: Выход:
:: ERRORLEVEL == 0 - tgit найден;
:: ERRORLEVEL == 1 - tgit не найден.
if "%~1" == "" (
    if "%~$PATH:2" == "" (
        exit /b 1
    )
) else (
    if not exist "%~1\%~2" (
        exit /b 1
    )
)
exit /b 0
