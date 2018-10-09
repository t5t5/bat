@echo off

setlocal DisableDelayedExpansion
set FAILED=0

setlocal

call is_enabled_delayed_expansion.bat
if %ERRORLEVEL% == 1 (
    set MESSAGE=passed
) else (
    set MESSAGE=FAILED
    set /a FAILED+=1
)
echo %MESSAGE% ... Delayed expansion is off

endlocal&set /a FAILED=%FAILED%


setlocal EnableDelayedExpansion

call is_enabled_delayed_expansion.bat
if %ERRORLEVEL% == 1 (
    set MESSAGE=passed
) else (
    set MESSAGE=FAILED
    set /a FAILED+=1
)
echo %MESSAGE% ... Delayed expansion is on

endlocal&set /a FAILED=%FAILED%


setlocal DisableDelayedExpansion

call is_enabled_delayed_expansion.bat
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed
) else (
    set MESSAGE=FAILED
    set /a FAILED+=1
)
echo %MESSAGE% ... Delayed expansion is off

endlocal&set /a FAILED=%FAILED%


setlocal EnableDelayedExpansion

call is_enabled_delayed_expansion.bat
if %ERRORLEVEL% == 1 (
    set MESSAGE=passed
) else (
    set MESSAGE=FAILED
    set /a FAILED+=1
)
echo %MESSAGE% ... Delayed expansion is on

endlocal&set /a FAILED=%FAILED%


endlocal&exit /b %FAILED%
