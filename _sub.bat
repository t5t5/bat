@echo off
:: call helper для вызова bat из подкаталогов. Максимально 8 аргументов.
:: %%1  - bat

if "%1" == "" (
    echo Error. Bat not specified.
    exit 1
)

setlocal

set COUNT=0
for %%a in (%*) do set /a COUNT+=1
if %COUNT% gtr 9 (
    echo Error: Max 9 arguments.
    exit 1
)

call "%~dp0%~1" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %ERRORLEVEL%

endlocal