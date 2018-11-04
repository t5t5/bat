@echo off

set PATH=C:\WINDOWS;C:\WINDOWS\system32
set PATH=C:\Progs\bat;%PATH%


setlocal EnableDelayedExpansion
set /a FAILED=0

setlocal
set MESSAGE=Search python. [Any, Any]
call set_python.bat
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE% [%PATH%]
endlocal&set /a FAILED=%FAILED%

echo ---

setlocal
set MESSAGE=Search python. [2, 32]
call set_python.bat -v 2 -p x32
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE% [%PATH%]
endlocal&set /a FAILED=%FAILED%

echo ---

setlocal
set MESSAGE=Search python. [2, 64]
call set_python.bat -v 2 -p x64
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE% [%PATH%]
endlocal&set /a FAILED=%FAILED%

echo ---

setlocal
set MESSAGE=Search python. [3, 32]
call set_python.bat -v 3 -p x32
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE% [%PATH%]
endlocal&set /a FAILED=%FAILED%

echo ---

setlocal
set MESSAGE=Search python. [3, 64]
call set_python.bat -v 3 -p x64
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE% [%PATH%]
endlocal&set /a FAILED=%FAILED%

echo ---

setlocal
set MESSAGE=Search python. [3, Any]
call set_python.bat -v 3
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE% [%PATH%]
endlocal&set /a FAILED=%FAILED%

echo ---

setlocal
set MESSAGE=Search python. [Any, 64]
call set_python.bat -p x64
if %ERRORLEVEL% == 0 (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE% [%PATH%]
endlocal&set /a FAILED=%FAILED%


endlocal&exit /b %FAILED%
