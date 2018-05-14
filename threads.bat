@echo off

setlocal enabledelayedexpansion

:: prepare parameters for wait4ready
set CURDATE=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
set CURTIME=%TIME: =0%

set CURTIME=%CURTIME::=_%
set TASK_WINDOW_NAME=%CURTIME:,=_%__%CURDATE:-=_%

:: default options
set THREADS=%NUMBER_OF_PROCESSORS%
set TASKID=0

:: parse task
if "%1" == "" (
    call :usage
) else if "%1" == "help" (
    call :usage
) else if "%1" == "tasks" (
    set TASK=tasks
) else if "%1" == "files" (
    set TASK=files
) else if "%1" == "dirs" (
    set TASK=dirs
) else (
    echo Error: Unknown command [%1].
    exit 1
)

:: parse command argument
shift
call :parse_argument_for_%TASK% %1
shift

:: parse options
:parse_options
if "%~1" == "--threads" (
    call :parse_argument_threads %2
) else if "%~1" == "--taskid" (
    call :parse_argument_taskid
) else if "%~1" == "--id" (
    call :parse_argument_taskid
) else (
    call :parse_argument_file_bat "%~1"
    goto :do_%TASK%
)
set /a N=%ERRORLEVEL%
:skip_options_arguments
if %N% == 0 goto :parse_options
shift
set /a N-=1
goto :skip_options_arguments

exit

:: -----parse command arguments--------------------------
:parse_argument_for_tasks
:: %%1 - must be parameter N for tasks
set /a N=%1+0
if "%1" == "" (
   echo Error: Tasks count should not be empty!
   exit 1
) else if %N% lss 1 (
   echo Error: Tasks count must be number, 1 or more!
   exit 1
)
set TASK_COUNT=%N%
exit /b 0

:parse_argument_for_files
:: In: %%1 - must be parameter mask for files
if "%1" == "" (
   echo Error: File mask should not be empty!
   exit 1
)
set FILE_MASK=%1
exit /b 0

:parse_argument_for_dirs
:: In: %%1 - must be parameter mask for dirs
if "%1" == "" (
   echo Error: Dir mask should not be empty!
   exit 1
)
set DIR_MASK=%1
exit /b 0

:: -----parse options arguments--------------------------
:parse_argument_threads
:: In: %%1 - N threads
:: Out: %%ERRORLEVEL%% - number arguments for shift
set /a N=%1+0
if "%1" == "" (
   echo Error: Threads count should not be empty!
   exit 1
) else if %N% lss 1 (
   echo Error: Threads count must be number, 1 or more!
   exit 1
)
set THREADS=%N%
exit /b 2

:parse_argument_taskid
:: In:
:: Out: %%ERRORLEVEL%% - number arguments for shift
set TASKID=1
exit /b 1

:parse_argument_file_bat
:: In: %%1 - filebat
if "%~1" == "" (
    echo Error: file_bat should not be empty.
    exit 1
) else if not exist "%~1" (
    echo Error: [%~1] not exists.
    exit 1
) else if exist "%~1\" (
    echo Error: [%~1] is directory, must be a bat file.
    exit 1
)
set FILE_BAT=%~1
exit /b 0
:: -----task tasks---------------------------------------
:do_tasks
:: In: %%1             - file_bat
::     %%2...          - parameters for bat
::     %%TASK_COUNT%%  - task count >= 1
::     %%THREADS%%     - threads count >= 1
::     %%TASKID%%      - taskid = 1 or 0
::echo TASK_COUNT=%TASK_COUNT%
::echo THREADS   =%THREADS%
::echo TASKID    =%TASKID%

shift

:: %%1 - point to parameters
set ARGS=
:do_tasks_args
if not "%~1" == "" (
   set ARGS=%ARGS% %1
   shift
   goto :do_tasks_args
)

for /l %%i in (1,1,%TASK_COUNT%) do (
    if %TASKID% == 1 (
        start /min "(task: %%i) %TASK_WINDOW_NAME%" threads_start_helper.bat "%FILE_BAT%" %%i%ARGS%
    ) else (
        start /min "(task: %%i) %TASK_WINDOW_NAME%" threads_start_helper.bat "%FILE_BAT%"%ARGS%
    )
    call :wait4ready %THREADS%
)
call :wait4ready 1
exit 0

:: -----task files---------------------------------------
:do_files
:: In: %%1             - file_bat
::     %%2...          - parameters for bat
::     %%FILE_MASK%%   - file mask
::     %%THREADS%%     - threads count >= 1
::     %%TASKID%%      - taskid = 1 or 0
::echo FILE_MASK=%FILE_MASK%
::echo THREADS  =%THREADS%
::echo TASKID   =%TASKID%

shift

:: %%1 - point to parameters
set ARGS=
:do_files_args
if not "%~1" == "" (
   set ARGS=%ARGS% %1
   shift
   goto :do_files_args
)

set /a X=1
for %%i in (%FILE_MASK%) do (
    if %TASKID% == 1 (
        start /min "(task: !X!) %TASK_WINDOW_NAME%" threads_start_helper.bat "%FILE_BAT%" "%%i" !X!%ARGS%
    ) else (
        start /min "(task: !X!) %TASK_WINDOW_NAME%" threads_start_helper.bat "%FILE_BAT%" "%%i"%ARGS%
    )
    set /a X=!X!+1
    call :wait4ready %THREADS%
)
call :wait4ready 1
exit 0

:: -----task dirs----------------------------------------
:do_dirs
:: In: %%1             - file_bat
::     %%2...          - parameters for bat
::     %%DIR_MASK%%    - dir mask
::     %%THREADS%%     - threads count >= 1
::     %%TASKID%%      - taskid = 1 or 0
::echo DIR_MASK=%DIR_MASK%
::echo THREADS =%THREADS%
::echo TASKID  =%TASKID%
::echo FILE_BAT=%FILE_BAT%

shift

:: %%1 - point to parameters
set ARGS=
:do_dirs_args
if not "%~1" == "" (
   set ARGS=%ARGS% %1
   shift
   goto :do_dirs_args
)

set /a X=1
for /d %%i in (%DIR_MASK%) do (
    if %TASKID% == 1 (
        start /I /min "(task: !X!) %TASK_WINDOW_NAME%" threads_start_helper.bat "%FILE_BAT%" "%%i" !X!%ARGS%
    ) else (
        start /I /min "(task: !X!) %TASK_WINDOW_NAME%" threads_start_helper.bat "%FILE_BAT%" "%%i"%ARGS%
    )
    set /a X=!X!+1
    call :wait4ready %THREADS%
)
call :wait4ready 1
exit 0

:: ------------------------------------------------------

:wait4ready
:: %%1  - количество потоков для проверки, возврат если количество меньше заданого
set /A n=0
for /F "delims=" %%A in ('tasklist /v /fi "imagename eq cmd.exe" /nh ^| findstr /LIC:%TASK_WINDOW_NAME%') do (set /A n+=1)
if %n% LSS %~1 exit /b
ping -w 100 -n 1 127.0.0.1>nul
goto :wait4ready


:usage
:: Показать информацию по использованию
echo Usage: %~nx0 command arg [--threads N] [--taskid^|-id] file_bat [parameters]
echo Commands:
echo   help             - usage inforamtion
echo   tasks N          - start N tasks (N ^>= 1)
echo   files "mask"     - process files "mask"
echo   dirs "mask"      - process directories "mask"
echo Options:
echo   --threads N      - number threads N
echo   --taskid or --id - first parameter for file_bat will be task id (1..N)
echo Parametesr:
echo   parameters       - parameters for file_bat (maximum 9)
exit 0