@echo off
:: Поиск установленного компилятора Microsoft Visual C++.
:: %%1  - platform (x86, amd64, x64, arm, x86_arm, x86_amd64, amd64_x86, amd64_arm)
::
:: Если компилятор будет найден, будут установленны соответствующие переменные среды.
:: Если компилятор не будет найден, вывод соответсвующей информации и выход из cmd.

if exist "%ProgramFiles(x86)%\Microsoft Visual Studio 15.0\VC\vcvarsall.bat" (
    call "%ProgramFiles(x86)%\Microsoft Visual Studio 15.0\VC\vcvarsall.bat" %1
) else if exist "%ProgramFiles%\Microsoft Visual Studio 15.0\VC\vcvarsall.bat" (
    call "%ProgramFiles%\Microsoft Visual Studio 15.0\VC\vcvarsall.bat" %1
) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" (
    call "%ProgramFiles(x86)%\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" %1
) else if exist "%ProgramFiles%\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" (
    call "%ProgramFiles%\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" %1
) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" (
    call "%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" %1
) else if exist "%ProgramFiles%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" (
    call "%ProgramFiles%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" %1
) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" (
    call "%ProgramFiles(x86)%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat"  %1
) else if exist "%ProgramFiles%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" (
    call "%ProgramFiles%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" %1
) else (
    echo Error: Visual Studio not found!
    exit 1
)
exit /b 0
