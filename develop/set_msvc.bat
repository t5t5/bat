@echo off
:: Поиск установленного компилятора Microsoft Visual C++.
:: %%1  - platform (x86, amd64, x64, arm, x86_arm, x86_amd64, amd64_x86, amd64_arm)
::
:: Если компилятор будет найден, будут установленны соответствующие переменные среды.
:: Если компилятор не будет найден, вывод соответсвующей информации и выход из cmd.
::
:: Note: Пути к VisuaStudio должны быть прописаны в %~n0.paths.

if "%~1" == "" (
    echo Error: Platform not specified. [%~f0]
    exit 1
)

setlocal EnableDelayedExpansion

call :detect_target_platform_%PROCESSOR_ARCHITECTURE%_%~1 TARGET_PLATFORM
if "%TARGET_PLATFORM%" == "" (
     echo Error. Unknown visual studio platform.
     exit 1
)

set APP=vcvarsall.bat

for /f "eol=# tokens=*" %%a in (%~dpn0.paths) do (
    call :check_and_prepare_app "%%a\%APP%"
    if !ERRORLEVEL! == 0 ( goto :end )
)
echo Error: Visual studio not found. [%~f0]
echo        Append msvc path to file: [%~dpn0.paths]
exit 1

:check_and_prepare_app
:: Проверка наличия файла по определенному пути и подготовка для запуска.
:: %%1 - Полный путь и имя файла для проверки.
::
:: Выход:
:: ERRORLEVEL = 0 найден
:: APP        = полный путь к файлу
::
:: ERRORLEVEL = 1 не найден
if exist "%~1" (
    set APP="%~1"
    exit /b 0
)
exit /b 1

:detect_target_platform_AMD64_x86:
set %~1=amd64_x86
exit /b 0

:detect_target_platform_AMD64_x32:
set %~1=amd64_x86
exit /b 0

:detect_target_platform_AMD64_x64:
set %~1=amd64
exit /b 0

:detect_target_platform_x86_x86:
set %~1=x86
exit /b 0

:detect_target_platform_x86_x32:
set %~1=x86
exit /b 0

:detect_target_platform_x86_x64:
set %~1=x86_amd64
exit /b 0


:end
endlocal&set APP=%APP%&set TARGET_PLATFORM=%TARGET_PLATFORM%
call %APP% %TARGET_PLATFORM%
set APP=
set TARGET_PLATFORM=
exit /b 0

