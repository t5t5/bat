@echo off
setlocal enabledelayedexpansion
:: Сборка OpenSSL.

set OPENSSL_BASE_DIR=
set PLATFORM_NAME=
set PLATFORM=
:parse_arguments
if "%~1" == "--help" (
    call :usage
    exit 0
) else if "%~1" == "-h" (
    call :usage
    exit 0
) else if "%~1" == "--platform" (
	call :parse_platform %2
	shift /1
) else if "%~1" == "-p" (
	call :parse_platform %2
	shift /1
) else if "%~1" == "--dir" (
	call :parse_base_dir %2
	shift /1
) else if "%~1" == "-d" (
	call :parse_base_dir %2
	shift /1
) else if "%~1" == "" (
	goto :begin
) else (
	echo Error. Unknown parameter [%~1].
	exit 1
)
shift /1
goto :parse_arguments

:begin
set PATTERN_VERSION=_1[0-1][0-9]_
set PATTERN_10x=_10[0-9]_
set PATTERN_11x=_11[0-9]_
call :check_platform
call :check_base_dir
call :get_openssl_version %OPENSSL_BASE_DIR%
call :get_openssl_name %OPENSSL_BASE_DIR%

:: x32 or x64
echo PLATFORM_NAME    =%PLATFORM_NAME%
:: x86 or x64
echo PLATFORM         =%PLATFORM%
echo OPENSSL_BASE_DIR =%OPENSSL_BASE_DIR%
echo OPENSSL_NAME     =%OPENSSL_NAME%

:: формат даты вида: yyyy-mm-dd
set CURDATE=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
set CURTIME=%TIME: =0%

call "%~dp0set_msvc.bat" %PLATFORM%
call "%~dp0set_perl.bat"
call "%~dp0set_jom.bat"
call "%~dp0set_log.bat" "%OPENSSL_BASE_DIR%\%CURDATE%-log.txt"

set OPENSSL_INSTALL_DIR=%OPENSSL_BASE_DIR%\%PLATFORM_NAME%\bin
set OPENSSL_SSL_DIR=%OPENSSL_INSTALL_DIR%\ssl
set OPENSSL_SRC_DIR=%OPENSSL_BASE_DIR%\%PLATFORM_NAME%\src
set OPENSSL_LOG_DIR=%OPENSSL_BASE_DIR%\%PLATFORM_NAME%
set OPENSSL_STEP_FILE=%OPENSSL_BASE_DIR%\%PLATFORM_NAME%\make_step.txt
set OPENSSL_STEPS=%~dpn0_%VERSION%_%PLATFORM_NAME%.steps

if not exist "%OPENSSL_STEPS%" (
    echo Error. Can't find steps file. [%OPENSSL_STEPS%]
    exit 1
)

call :load_steps %OPENSSL_STEP_FILE%
call :begin_log

for /F "eol=# tokens=1,2,3,4,5,6 delims=;" %%a in (%OPENSSL_STEPS%) do (
    call _sub.bat tools\trim_right.bat __A "%%a"
    call _sub.bat tools\trim_right.bat __B "%%b"
    call _sub.bat tools\trim_right.bat __C "%%c"
    call _sub.bat tools\trim_right.bat __D "%%d"
    call _sub.bat tools\trim_right.bat __E "%%e"
    call _sub.bat tools\trim_right.bat __F "%%f"
    call :main_step "!__A!" "!__B!" "!__C!" "!__D!" "!__E!" "!__F!"
    if not !ERRORLEVEL! == 0 ( goto :end )
)
:end
if %ERRORLEVEL% == 0 (
    call :end_log_ok
) else (
    call :end_log_error
)
exit /b 0

:: ------------------------------------------------------------------------------------------------
:main_step
:: %%1 - begin log message
:: %%2 - end log message
:: %%3 - command
:: %%4 - STEP
:: %%5 - w - rewrite log, a - append log
:: %%6 - log file
::echo [%~1] - [%~2] - [%~3] - [%~4] - [%~5] - [%~6]
if not "%~4" == "-" (
	call :variable__get_value_by_name %~4 1
	if !ERRORLEVEL! == 0 ( exit /b 0 )
)
%log% "%~1"
if "%~5" == "a" (
    %~3 >>%~6 2>&1
) else if "%~5" == "w" (
	%~3 >%~6 2>&1
)
%log% " ErrorLevel=[%ERRORLEVEL%]"
%log% "%~2"
if not %ERRORLEVEL% == 0 (
	exit /b 1
)
if not "%~4" == "-" (
    set %~4=0
    call :save_steps "%OPENSSL_STEP_FILE%"
)
exit /b 0

:: ------------------------------------------------------------------------------------------------
:usage
echo Usage: %~nx0 [options]
echo Options:
echo   --help or -h               - this screen
echo   --platform arc or -p arc   - arc - platform (x86 or x64)
echo   --dir path or -d path      - path - base directory with openssl
exit /b 0

:parse_platform 
:: Разбор аргумента командной строки "platform"
:: %%1 - значение аргумента "platform"
if "%~1" == "x32" (
	set PLATFORM_NAME=x32
	set PLATFORM=x86
) else if "%~1" == "x86" (
	set PLATFORM_NAME=x32
	set PLATFORM=x86
) else if "%~1" == "x64" (
	set PLATFORM_NAME=x64
	set PLATFORM=x64
) else (
	echo Error. Platform unknown [%~1].
	exit 1
)
exit /b 0

:parse_base_dir
:: Проверка аргумента командной строки "dir"
:: %%1 dir
if not exist "%~1" (
	echo Error. Base directory not found [%~1].
	exit 1
)
set OPENSSL_BASE_DIR=%~f1
exit /b 0

:check_platform
:: Проверка установлен ли обязательный аргумент "platform"
if "%PLATFORM%" == "" (
	echo Error. Platfrom not specified.
	exit 1
)
exit /b 0

:check_base_dir
:: Проверка установлен ли путь к OpenSSL.
if "%OPENSSL_BASE_DIR%" == "" (
	set OPENSSL_BASE_DIR=%CD%
)
:: В папке должен присутствовать каталог src.
if not exist "%OPENSSL_BASE_DIR%\src\" (
   echo Error. Directory 'src' don't exists in path [%OPENSSL_BASE_DIR%].
   exit 1
)
for /F "delims=" %%a in ('echo %OPENSSL_BASE_DIR%^|findstr /RIC:%PATTERN_VERSION%') do (
    set A=%%a
)
if "%A%" == "" (
    echo Error. Unknown version 1.
    exit 1
)
exit /b 0

:get_openssl_version
echo [%OPENSSL_BASE_DIR%]
echo for /F "delims=" %%a in ('echo %OPENSSL_BASE_DIR%^|findstr /RIC:%PATTERN_10x%') do (
for /F "delims=" %%a in ('echo %OPENSSL_BASE_DIR%^|findstr /RIC:%PATTERN_10x%') do (
    set VERSION=10x
    echo 111
    exit /b 0
)
for /F "delims=" %%a in ('echo %OPENSSL_BASE_DIR%^|findstr /RIC:%PATTERN_11x%') do (
    set VERSION=11x
    echo 222
    exit /b 0
)
echo Error. Unknown version 2.
exit 1

:get_openssl_name
:: Получить имя OpenSSL папки из полного пути.
:: %%1  - путь к исходной папке OpenSSL
set OPENSSL_NAME=%~n1
exit /b 0

:begin_log
:: Начать логирование.
%log% "Start build OPENSSL %OPENSSL_NAME% [%PLATFORM_NAME%]"
exit /b 0

:end_log_ok
:: Закночить лиг без ошибок.
%log% "End build OPENSSL"
exit /b 0

:end_log_error
:: Закончить лог с ошибками.
%log% "End build OPENSSL with error!"
exit /b 0

:check_src_dir
:: Проверить наличие папки с исходниками OpenSSL. И переход в нее.
if not exist "%OPENSSL_SRC_DIR%" (
    %log% " [%OPENSSL_SRC_DIR%] not exists. ERROR!!!"
    exit /b 1
)
cd %OPENSSL_SRC_DIR%
exit /b 0

:make_install_dir
:: Проверить наличие папки для установки OpenSSL. И создать в случае необходимости.
if not exist "%OPENSSL_INSTALL_DIR%" (
    %log% " [%OPENSSL_INSTALL_DIR%] not found. Try create..."
    mkdir "%OPENSSL_INSTALL_DIR%" >nul 2>&1
    if exist "%OPENSSL_INSTALL_DIR%" %log% " [%OPENSSL_INSTALL_DIR%] created successfully."
)
if not exist "%OPENSSL_INSTALL_DIR%" (
    %log% " [%OPENSSL_INSTALL_DIR%] not created. ERROR!!!"
    exit /b 1
)
exit /b 0

:load_steps
:: Загрузка файла с шагами сборки. Чтоб можно было пропустить шаг.
:: %%1 - step file name
if exist "%~1" (
	for /f "delims== tokens=1,2" %%a in (%~1) do ( set %%a=%%b )
) else (
    call :save_steps "%~1"
)
exit /b 0

:save_steps
:: Записать файл с шагами сборки.
:: %%1 - step file name
if not exist "%~dp1" (
    mkdir "%~dp1" >nul 2>&1
)
set STEP_>"%~1" 2>nul
exit /b 0

:create_inc_lib_file
:: Создать файл для включения INCLUDE и LIB.
setlocal
set SET_INC_LIB_FILE=%~dp0set_openssl_inc_lib_%PLATFORM_NAME%.bat
set SET_INC_LIB_FILE_BAK=%~dp0set_openssl_inc_lib_%PLATFORM_NAME%.bak

if exist "%SET_INC_LIB_FILE%" (
    move /Y "%SET_INC_LIB_FILE%" "%SET_INC_LIB_FILE_BAK%" 1>nul 2>&1
)

echo :: auto genarated by %~nx0 at %CURDATE% %CURTIME%>"%SET_INC_LIB_FILE%"
echo set INCLUDE=%%INCLUDE%%;%OPENSSL_INSTALL_DIR%\include>>"%SET_INC_LIB_FILE%"
echo set LIB=%%LIB%%;%OPENSSL_INSTALL_DIR%\lib>>"%SET_INC_LIB_FILE%"
endlocal
exit /b 0

:variable__get_value_by_name
:: Get variable numeric value by name
:: %%1 - variable name
:: %%2 - default value, if variable name not found
:: Returns: %%ERRORLEVEL%%=%%2 if variable not exists or empty, otherwise return variable value.
call :variable__is_empty %%%1%%
if %ERRORLEVEL% == 1 ( exit /b %2 )
for /f "delims== tokens=2" %%a in ('set %1') do (exit /b %%a)
echo Reached unreachable! [:variable__get_value_by_name]
exit 1

:variable__is_empty
:: Check variable for empty
:: %%1 - value
:: Returns 1 if vaiable is empty, otherwise returns 0.
if "%1" == "" (exit /b 1) else (exit /b 0)
echo Reached unreachable! [:variable__is_empty]
exit 1

