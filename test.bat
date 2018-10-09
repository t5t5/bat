@echo off
:: Тестирование bat.
:: %%1 - bat файл для теста.
::
:: note: Тест должен быть в файле: %~dp1tests\test_%~nx1

if "%1" == "" (
    echo Error. Test file not specified. [%~f0]
    echo        Usage: %~f0 testing.bat
    exit 1
)

set TEST_TARGET=%~f1
set TEST_FILE=%~dp1tests\test_%~nx1

if not exist "%TEST_TARGET%" (
    echo Error. Test target not found {TARGET: %TEST_TARGET%}. [%~f0]
    exit 1
)

if not exist "%TEST_FILE%" (
    echo Error. Test file not found {TEST: %TEST_FILE%}. [%~f0]
    exit 1
)

echo ------------------------------------------------------------------
echo --- Start test for: %TEST_TARGET% 
echo ------------------------------------------------------------------
call %TEST_FILE%
echo ------------------------------------------------------------------
if %ERRORLEVEL% == 0 (
    echo --- PASSED: %TEST_TARGET%
) else (
    echo --- FAILED: %TEST_TARGET%
)
echo ------------------------------------------------------------------
