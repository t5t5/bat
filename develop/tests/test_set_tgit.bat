@echo off

setlocal EnableDelayedExpansion
set /a FAILED=0

set MESSAGE=Search tgit. Tgit already set.
call set_tgit.bat
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%


set PATH=%SystemRoot%;%SystemRoot%\system32
set MESSAGE=Search tgit.
call set_tgit.bat
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%

endlocal&exit /b %FAILED%
