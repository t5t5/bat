@echo off

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

set CURDATE=%DATE:~6,4%_%DATE:~3,2%_%DATE:~0,2%
set CURTIME=%TIME: =0%
set CURTIME=%CURTIME::=_%
set CURTIME=%CURTIME:~0,8%

set SUFFIX=__%CURDATE%__%CURTIME%

set FORMAT=7z
set EXTENSION=7z
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
	set EXTENSION=7z
) else if "%~1" == "zip" (
    set FORMAT=zip
	set EXTENSION=zip
) else if "%~1" == "ppmd" (
    set FORMAT=ppmd
	set EXTENSION=ppmd.7z
) else (
    echo Error. Unknown format [%~1]
    exit 1
)
exit /b 0

:get_out_file_name
:: %%1 - файл
if "%OUT_FILE%" == "" (
    call :get_out_file_name_suffix "%~1" %EXTENSION%
) else (
    call :get_out_file_name_suffix "%OUT_FILE%" %EXTENSION%
)
exit /b 0

:get_out_file_name_suffix
:: %%1 - имя файла
:: %%2 - расширение
if "%~x1" == ".%2" (
    set OUT_FILE=%~dpn1%SUFFIX%.%2
) else (
    set OUT_FILE=%~dpnx1%SUFFIX%.%2
)
exit /b 0

:: ---------------------------------------------------------
:do_arc_file
::echo OUT_FILE:  %OUT_FILE%
::echo FORMAT:    %FORMAT%
::echo EXTENSION: %EXTENSION%
call :get_out_file_name %1
call 7z.bat --format %FORMAT% --out %OUT_FILE% %1
exit /b %ERRORLEVEL%

:: ---------------------------
:do_arc_files
if "%OUT_FILE%" == "" (
    echo Error. Option --out is required.
    exit 1
)
::echo OUT_FILE:  %OUT_FILE%
::echo FORMAT:    %FORMAT%
::echo EXTENSION: %EXTENSION%
call :get_out_file_name_suffix "%OUT_FILE%" %EXTENSION%

set FILES=
:do_arc_files_list
if not "%~1" == "" (
	set FILES=%FILES% %1
	shift
	goto :do_arc_files_list
)
call 7z.bat --files --format %FORMAT% --out %OUT_FILE%%FILES%
exit /b %ERRORLEVEL%

:: ---------------------------
:do_arc_list
if "%OUT_FILE%" == "" (
    echo Error. Option --out is required.
    exit 1
)
::echo OUT_FILE:  %OUT_FILE%
::echo FORMAT:    %FORMAT%
::echo EXTENSION: %EXTENSION%
call :get_out_file_name_suffix "%OUT_FILE%" %EXTENSION%
call 7z.bat --list --format %FORMAT% --out %OUT_FILE% %1
exit /b %ERRORLEVEL%

:usage
echo Usage: %~nx0 [options] file_or_files 
echo Options:
echo   --help or -h or help  - this screen
echo   --files or -f         - file_or_files is list of files for archive, option -o is required
echo   --list or -l          - file_or_files is file name with list of files for archive, option -o is required
echo   --out f or -o f       - f - template output file name
echo   --format fmt          - zip, ppmd or 7z (default is zip)
echo Parameters:
echo   file_or_files         - one or more files
echo Examples:
echo   %~nx0 --out c:\backup_file --format ppmd --list l.txt
echo   %~nx0 some_txt.txt
echo   %~nx0 -o files_txt.zip -f file1.txt file2.txt

exit /b 0
