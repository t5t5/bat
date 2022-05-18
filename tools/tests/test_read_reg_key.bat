@echo off

call read_reg_key.bat PATH_DESK "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "Desktop"

echo %PATH_DESK%