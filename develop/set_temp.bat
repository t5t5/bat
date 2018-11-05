@echo off
:: Установить временную папку.
::
:: Note: Пути к должны быть прописаны в %~n0.paths.
:: Note: Сделано для возможности задать "быстрые" временные папки, например на RAM диске.

for /f "eol=# tokens=*" %%a in (%~dpn0.paths) do (
    if exist "%%a" (
        set TEMP=%%a
        set TMP=%%a
    )
)

