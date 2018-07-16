echo off
:: Поиск llvm в стандартных для него путях.
::
:: Если llvm будет найден, будут установленны соответствующие переменные среды.
:: Если llvm не будет найден, вывод соответсвующей информации и выход из cmd.

if exist "%ProgramFiles%\LLVM" (
    call :set_environment LLVM_INSTALL_DIR "%ProgramFiles%\LLVM"
    exit /b 0
) else if exist "%ProgramFiles(x86)%\LLVM" (
    call :set_environment LLVM_INSTALL_DIR "%ProgramFiles(x86)%\LLVM"
    exit /b 0
) else (
    echo Error: LLVM not found!
    exit 1
)

:set_environment
:: Helper для set, из if не всегда срабатывает
:: %%1 - environment variable name
:: %%2 - value to set
set %1=%~2
exit /b 0
