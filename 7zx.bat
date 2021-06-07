@echo off

call "%~dp0tools\set_7z.bat"
call "%~dp0tools\gen_temp_file_name.bat" TEMP_FILE_LIST

if "%~1" == "" (
    call :usage
    exit 0
) else if "%~1" == "help" (
    call :usage
    exit 0
) else if "%~1" == "--help" (
    call :usage
    exit 0
) else if "%~1" == "-h" (
    call :usage
    exit 0
)
set OUT_FILE=
:parse_arguments
if "%~1" == "--out" (
    if "%~2" == "" (
       echo Error. Option --out is empty.
       exit 1
    )
    set OUT_FILE=%~2
    shift
) else if "%~1" == "-o" (
    if "%~2" == "" (
       echo Error. Option --out is empty.
       exit 1
    )
    set OUT_FILE=%~2
    shift
) else (
    goto :do_extract
)
shift
goto :parse_arguments

:: ---------------------------------------------------------
:do_extract
if not "%OUT_FILE%" == "" (
::  %CMD_7Z% x "%~f1"
    7zG.exe x "%1" -o"%OUT_FILE%"
) else (
::  %CMD_7Z% x "%~f1"
    7zG.exe x "%1"
)
exit /b 0

:usage
echo Usage: %~nx0 [options] file
echo Options:
echo   --help or -h or help  - this screen
echo   --out f or -o f       - f - output file name
echo Parameters:
echo   file                  - file for extract
exit /b 0
