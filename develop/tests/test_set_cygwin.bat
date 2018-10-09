@echo off

setlocal EnableDelayedExpansion
set /a FAILED=0

set MESSAGE=Search cygwin.
call set_cygwin.bat
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%

set PATH=C:\cygwin\bin;%PATH%

set MESSAGE=Search cygwin. Cygwin already set.
call set_cygwin.bat
if not %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%
endlocal&exit /b %FAILED%
