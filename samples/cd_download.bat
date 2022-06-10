@echo off

call _sub.bat tools\read_reg_key.bat PATH_DOWNLOAD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "{374DE290-123F-4565-9164-39C4925E467B}"

cd /d "%PATH_DOWNLOAD%"
echo %CD%