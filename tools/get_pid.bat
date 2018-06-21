@echo off
:: Получить PID текущего процесса в котором запущен этот bat.
:: 
:: Из другого bat файла запускать:
:: call "tools\get_pid.bat"
:: %%ERRORLEVEL%% - будет содержать PID

setlocal
set CURDATE=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
set CURTIME=%TIME: =0%

set CURTIME=%CURTIME::=_%
set TASK_WINDOW_NAME=%CURTIME:,=_%__%CURDATE:-=_%__%RANDOM%
title %TASK_WINDOW_NAME%
for /f "tokens=2 delims=," %%a in ('tasklist /v /fo csv /fi "IMAGENAME eq cmd.exe" /nh  ^| findstr /LIC:%TASK_WINDOW_NAME%') do (
   exit /b %%~a
)
for /f "tokens=2 delims=," %%a in ('tasklist /v /fo csv /fi "IMAGENAME eq far.exe" /nh  ^| findstr /LIC:%TASK_WINDOW_NAME%') do (
   exit /b %%~a
)
::very slow
for /f "tokens=2 delims=," %%a in ('tasklist /v /fo csv /nh ^| findstr /i /LIC:%TASK_WINDOW_NAME%') do (
   exit /b %%~a
)
echo Error. Can't get PID.
exit 1
endlocal