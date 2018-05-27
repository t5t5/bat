@echo off
:: Удалить файлы
:: %%1... файлы для удаления

::setlocal enabledelayedexpansion

setlocal
set OPTIONS=
set /a RESULT_CODE=0
set FP=%~1
set FILE_LIST=

:parse_arguments
if "%~1" == "" (
    call :do_del_files %FILE_LIST%
) else if "%~1" == "--help" (
    call :usage
    exit 0
) else if "%~1" == "-h" (
    call :usage
    exit 0
) else if /i "%~1" == "-p" (
    set OPTIONS=%OPTIONS% /P
) else if /i "%~1" == "-f" (
    set OPTIONS=%OPTIONS% /F
) else if /i "%~1" == "-s" (
    set OPTIONS=%OPTIONS% /S
) else if /i "%~1" == "-q" (
    set OPTIONS=%OPTIONS% /Q
) else if /i "%FP:~0,2%" == "-a" (
    set OPTIONS=%OPTIONS% %FP:~2%
) else (
    set FILE_LIST=%FILE_LIST% %1
)
shift
goto :parse_arguments
:: ----------------------------------------------
:do_del_files
if "%~1" == "" (
    exit 0
)

set /a RET_CODE=0
:do_args
if not "%~1" == "" (
    call :do_del_file %1
    if not %ERRORLEVEL% == 0 (
        set /a RET_CODE=1
    )
    shift
    goto :do_args
)

exit %RET_CODE%

:do_del_file
:: %%1 - файл для удаления
if not exist "%~1" ( exit /b 0 )

del%OPTIONS% "%~1" 2>nul

exit /b %ERRORLEVEL%

:usage
echo Usage: %~nx0 [options] files
echo   files : A filename or a list of files, may include wildcards.
echo   options:
echo     -p  Give a Yes/No Prompt before deleting. 
echo     -f  Ignore read-only setting and delete anyway (FORCE) 
echo     -s  Delete from all Subfolders (DELTREE)
echo     -q  Quiet mode, do not give a Yes/No Prompt before deleting.
echo     -a  Select files to delete based on file_attributes
echo          file_attributes:
echo             R  Read-only    -R  NOT Read-only
echo             A  Archive      -A  NOT Archive
echo             S  System       -S  NOT System
echo             H  Hidden       -H  NOT Hidden
echo             I  Not content indexed  -I  content indexed files
echo             L  Reparse points       -L  NOT Reparse pointsecho
exit /b 0
