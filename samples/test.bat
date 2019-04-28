@echo off

setlocal EnableDelayedExpansion

if "%~1" == "-m" (
    call :%~2
    if !ERRORLEVEL! == 1 (
        echo Error. Method not found {%~2}. [%~f0]
        exit 1
    )
    exit 0
) else (
    call parse_arguments.bat "%~0" "args.txt" %*
) 

echo ----------------------------
set 

endlocal
exit /b 0

:: ------------------------------------------------------------------------------------------------
:usage
echo Usage: %~nx0 [options]

exit /b 0
