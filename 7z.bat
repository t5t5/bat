@echo off

call "%~dp0tools\set_7z.bat"

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
set FORMAT=7z
set OUT_FILE=
set COMMAND=file
:parse_arguments
if "%~1" == "--files" (
    set COMMAND=files
) else if "%~1" == "-f" (
    set COMMAND=files
) else if "%~1" == "--out" (
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
) else if "%~1" == "--list" (
    set COMMAND=list
) else if "%~1" == "-l" (
    set COMMAND=list
) else if "%~1" == "--format" (
    call :parse_format %2
    shift
) else (
    goto :do_arc_%COMMAND%
)
shift
goto :parse_arguments

:: ---------------------------------------------------------
:parse_format
:: %%1 - формат: должно быть zip, 7z или ppmd

if "%~1" == "7z" (
    set FORMAT=7z
) else if "%~1" == "zip" (
    set FORMAT=zip
) else if "%~1" == "ppmd" (
    set FORMAT=ppmd
) else (
    echo Error. Unknown format [%~1]
    exit 1
)
exit /b 0

:get_out_file_name_7z
:: %%1 - файл
if "%OUT_FILE%" == "" (
    set OUT_FILE=%~nx1.7z
)
exit /b 0

:get_out_file_name_ppmd
:: %%1 - файл
if "%OUT_FILE%" == "" (
    set OUT_FILE=%~nx1.ppmd.7z
)
exit /b 0

:get_out_file_name_zip
:: %%1 - файл
if "%OUT_FILE%" == "" (
    set OUT_FILE=%~nx1.zip
)
exit /b 0
:: ---------------------------------------------------------
:do_arc_file
call :get_out_file_name_%FORMAT% %1
if "%~1" == "" (
    echo Error. File not defined.
    exit 1
)
if not exist "%~1" (
    echo Error. File not found [%~1].
    exit 1
)
set IN_FILE=%1
goto :do_arc_common_%FORMAT%

:: ---------------------------
:do_arc_files
if "%OUT_FILE%" == "" (
    echo Error. Option --out is required.
    exit 1
)
if "%~1" == "" (
    echo Error. File not defined.
    exit 1
)
call "%~dp0tools\gen_temp_file_name.bat" TEMP_FILE_LIST
:do_arc_files_list
if not "%~1" == "" (
    echo %1>>%TEMP_FILE_LIST%
    shift
    goto :do_arc_files_list
)
set IN_FILE=-ir@"%TEMP_FILE_LIST%"
call :do_arc_common_%FORMAT%
if exist "%TEMP_FILE_LIST%" ( del "%TEMP_FILE_LIST%" )
exit /b 0

:: ---------------------------
:do_arc_list
if "%OUT_FILE%" == "" (
    echo Error. Option --out is required.
    exit 1
)
if "%~1" == "" (
    echo Error. File not defined.
    exit 1
)
if not exist "%~1" (
    echo Error. File list not exist [%~1].
    exit 1
)
set IN_FILE=-ir@"%~1"
goto :do_arc_common_%FORMAT%

:: ---------------------------
:do_arc_common_7z
7zG.exe a -t7z "%OUT_FILE%" %IN_FILE% -m0=BCJ2 -m1=LZMA2:d=64m:a=1:fb=128:mc=128 -m2=LZMA2:d=32m -m3=LZMA2:d=32m -mb0s0:1 -mb0s1:2 -mb0s2:3 -ms -mmt -mx=9
exit /b 0

:do_arc_common_ppmd
7zG.exe a -t7z "%OUT_FILE%" "%IN_FILE%" -m0=PPMd -mx=9 -mmem=512m
exit /b 0

:do_arc_common_zip
7zG.exe a -tzip "%OUT_FILE%" "%IN_FILE%" -mx=9
exit /b 0

:usage
echo Usage: %~nx0 [options] file_or_files 
echo Options:
echo   --help or -h or help  - this screen
echo   --files or -f         - file_or_files is list of files for archive, option -o is required
echo   --out f or -o f       - f - output file name
echo   --list or -l          - file_or_files is file name with list of files for archive, option -o is required
echo   --format fmt          - zip, ppmd or 7z (default is 7z)
echo Parameters:
echo   file_or_files         - one or more files
echo Examples:
echo   %~nx0 --format ppmd some_txt.txt
echo   %~nx0 -o files_txt.7z -f --format ppmd file1.txt file2.txt
exit /b 0
