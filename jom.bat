@echo off
:: Wrapper for jom for QtCreator for cyrillic error messages in msvc.
::http://www.prog.org.ru/topic_30878_0.html
::http://www.prog.org.ru/topic_11639_0.html

chcp 1251 >nul

call "%~dp0develop\set_jom.bat"

jom.exe %*
