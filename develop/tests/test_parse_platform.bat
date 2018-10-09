@echo off

setlocal
set /a FAILED=0

call parse_platform.bat PLATFORM_NAME PLATFORM_CODE ERROR_TEXT
if %ERRORLEVEL% == 1 (
    set MESSAGE=passed
) else (
    set MESSAGE=FAILED
    set /a FAILED+=1
)
echo %MESSAGE% ... Platform not specified.


call parse_platform.bat PLATFORM_NAME PLATFORM_CODE ERROR_TEXT amd64
if %ERRORLEVEL% == 2 (
    set MESSAGE=passed
) else (
    set MESSAGE=FAILED
    set /a FAILED+=1
)
echo %MESSAGE% ... Unknown platform.


call parse_platform.bat PLATFORM_NAME PLATFORM_CODE ERROR_TEXT x86
set /a CODE=0
if not "%PLATFORM_NAME%" == "x86" ( set /a CODE+=1 )
if not "%PLATFORM_CODE%" == "x32" ( set /a CODE+=1 )
if not %ERRORLEVEL% == 0 ( set /a CODE+=1 )
if %CODE% == 0 (
    set MESSAGE=passed
) else (
    set MESSAGE=FAILED
    set /a FAILED+=1
)
echo %MESSAGE% ... Platform x86.

call parse_platform.bat PLATFORM_NAME PLATFORM_CODE ERROR_TEXT x32
set /a CODE=0
if not "%PLATFORM_NAME%" == "x86" ( set /a CODE+=1 )
if not "%PLATFORM_CODE%" == "x32" ( set /a CODE+=1 )
if not %ERRORLEVEL% == 0 ( set /a CODE+=1 )
if %CODE% == 0 (
    set MESSAGE=passed
) else (
    set MESSAGE=FAILED
    set /a FAILED+=1
)
echo %MESSAGE% ... Platform x32.

call parse_platform.bat PLATFORM_NAME PLATFORM_CODE ERROR_TEXT x64
set /a CODE=0
if not "%PLATFORM_NAME%" == "x64" ( set /a CODE+=1 )
if not "%PLATFORM_CODE%" == "x64" ( set /a CODE+=1 )
if not %ERRORLEVEL% == 0 ( set /a CODE+=1 )
if %CODE% == 0 (
    set MESSAGE=passed
) else (
    set MESSAGE=FAILED
    set /a FAILED+=1
)
echo %MESSAGE% ... Platform x64.

endlocal&exit /b %FAILED%
