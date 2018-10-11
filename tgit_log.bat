@echo off
:: Вызов диалога Git Log из пакета TortoiseGit.
::
:: Об использовании TortoiseGitProc:
:: https://tortoisegit.org/docs/tortoisegit/tgit-automation.html

call "%~dp0develop\set_tgit.bat"

start TortoiseGitProc /command:log /path:.
