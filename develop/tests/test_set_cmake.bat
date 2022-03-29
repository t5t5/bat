@echo off

setlocal EnableDelayedExpansion
set /a FAILED=0

set MESSAGE=Search cmake.
call set_cmake.bat
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%


set PATH=%SystemRoot%;%SystemRoot%\system32
set MESSAGE=Search cmake. cmake already set.
call set_cmake.bat
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%

endlocal&exit /b %FAILED%
