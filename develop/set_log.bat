@echo off
:: Настроить логгер.
:: %%1  - Файл лога.
:: Использовать:
::   call set_log "some_file.txt"
::   %%log%% "message"

if not exist "%~dp1" (
    mkdir "%~dp1" >nul 2>&1
)

set log=call "%~dp0log.bat" "%~1"
