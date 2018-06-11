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

call 7zz.bat --format zip %*
exit /b 0

:usage
echo Usage: %~nx0 [options] file_or_files 
echo Options:
echo   --help or -h or help  - this screen
echo   --files or -f         - file_or_files is list of files for archive, option -o is required
echo   --out f or -o f       - f - output file name
echo   --list or -l          - file_or_files is file name with list of files for archive, option -o is required
echo   --format fmt          - zip, ppmd or 7z (default is zip)
echo Parameters:
echo   file_or_files         - one or more files
echo Examples:
echo   %~nx0 some_txt.txt
echo   %~nx0 -o files_txt.zip -f file1.txt file2.txt
exit /b 0