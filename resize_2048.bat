@echo off
if "%~1" == "" (
    call _sub.bat tools\set_imagemagick.bat mogrify.exe
    call threads.bat dirs * "%~dpnx0"
    exit 0
)

call _sub.bat tools\set_imagemagick.bat mogrify.exe
attrib -R /S /D "%~f1\*"

if not exist ".\2048\%~1" ( mkdir ".\2048\%~1" )
mogrify -monitor -path ".\2048\%~1" -density 72 -quality 88 -resize 2048x2048^> "%~1\*.jp*"
exit
