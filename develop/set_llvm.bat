@echo off
:: Поиск llvm.
:: %%1  - platform (x86, x32, x64)
::
:: Если llvm будет найден, будут установленны соответствующие переменные среды.
:: Если llvm не будет найден, вывод соответсвующей информации и выход из cmd.
if "%~1" == "" (
    echo Error: Platform not specified. [%~f0]
    exit 1
)
setlocal EnableDelayedExpansion

if "%~1" == "x32" (
	set PLATFORM_NAME=x32
) else if "%~1" == "x86" (
	set PLATFORM_NAME=x32
) else if "%~1" == "x64" (
	set PLATFORM_NAME=x64
) else (
    echo Error: Unknown platform {%~1}. [%~f0]
    exit 1
)

set P=
for /f "eol=# tokens=*" %%a in (%~dpn0.%PLATFORM_NAME%.paths) do (
    call :check_path "%%a"
    if !ERRORLEVEL! == 0 ( goto :end )
)
echo Error: LLVM %PLATFORM_NAME% not found. [%~f0]
echo        Append LLVM path to file: [%~dpn0.%PLATFORM_NAME%.paths]
exit 1

:check_path
:: Проверка наличия пути
:: %%1 - Путь для проверки
::
:: Выход:
:: ERRORLEVEL = 0 найден
:: P          = путь
::
:: ERRORLEVEL = 1 не найден
if exist "%~1" (
    set P="%~1"
    exit /b 0
)
exit /b 1

:end
endlocal&set LLVM_INSTALL_DIR=%P%

call :remove_quot %LLVM_INSTALL_DIR%
exit /b 0

:remove_quot
:: Убрать кавычки
:: %%1 - путь, где нужно убрать
::
:: Выход:
:: LLVM_INSTALL_DIR - путь без кавычек
set LLVM_INSTALL_DIR=%~1
exit /b 0

