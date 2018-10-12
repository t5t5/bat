@echo off

setlocal
set /a FAILED=0

set MESSAGE=Expand: ~nx notepa.exe
call :native_expand_nx VAR00_N notepa.exe
call expand_path.bat VAR00_E nx notepa.exe
if "%VAR00_E%" == "%VAR00_E%" (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%

set MESSAGE=Expand: ~dp test_expand_path.bat
call :native_expand_dp VAR05_N test_expand_path.bat
call expand_path.bat VAR05_E dp test_expand_path.bat
if "%VAR05_E%" == "%VAR05_N%" (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%

set MESSAGE=Expand: ~dp 7z.bat
call :native_expand_dp VAR10_N 7z.bat
call expand_path.bat VAR10_E dp 7z.bat
if "%VAR10_E%" == "%VAR10_N%" (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)

set MESSAGE=Expand: ~dp$PATH: notepa.exe
call :native_expand_path_dp VAR15_N notepa.exe
call expand_path.bat VAR15_E dp$PATH: notepa.exe
if "%VAR15_E%" == "%VAR15_N%" (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%

set MESSAGE=Expand: ~dp$PATH: notepad.exe
call :native_expand_path_dp VAR20_N notepad.exe
call expand_path.bat VAR20_E dp$PATH: notepad.exe
if "%VAR20_E%" == "%VAR20_N%" (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%

set MESSAGE=Expand: ~$PATH: notepa.exe
call :native_expand_path VAR25_N notepa.exe
call expand_path.bat VAR25_E $PATH: notepa.exe
if "%VAR25_E%" == "%VAR25_N%" (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%

set MESSAGE=Expand: ~$PATH: notepad.exe
call :native_expand_path VAR30_N notepad.exe
call expand_path.bat VAR30_E $PATH: notepad.exe
if "%VAR30_E%" == "%VAR30_N%" (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE%

set TTT=""111" "222" 3 4"
set MESSAGE=Expand: "~"
call :native_expand_quot VAR35_N %TTT%
call expand_path.bat VAR35_E "" %TTT%
if "%VAR35_E%" == "%VAR35_N%" (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE% [%TTT%] =^> e:[%VAR35_E%] and n:[%VAR35_E%]

set TTT=1111111111111111
set MESSAGE=Expand: "~"
call :native_expand_quot VAR40_N %TTT%
call expand_path.bat VAR40_E "" %TTT%
if "%VAR40_E%" == "%VAR40_N%" (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE% [%TTT%] =^> e:[%VAR40_E%] and n:[%VAR40_E%]

set TTT="1111111111111111"
set MESSAGE=Expand: "~"
call :native_expand_quot VAR45_N %TTT%
call expand_path.bat VAR45_E "" %TTT%
if "%VAR45_E%" == "%VAR45_N%" (
    set MESSAGE=passed ... %MESSAGE%
) else (
    set MESSAGE=FAILED ... %MESSAGE%
    set /a FAILED+=1
)
echo %MESSAGE% [%TTT%] =^> e:[%VAR45_E%] and n:[%VAR45_E%]

endlocal&exit /b %FAILED%

:: ----------------------------

:native_expand_nx
set %1=%~nx2
exit /b 0

:native_expand_dp
set %1=%~dp2
exit /b 0

:native_expand_path_dp
set %1=%~dp$PATH:2
exit /b 0

:native_expand_path
set %1=%~$PATH:2
exit /b 0

:native_expand_quot
set %1=%~2
exit /b 0

