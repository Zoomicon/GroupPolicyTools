:: gpresult_timeline_paths.bat
:: Purpose : Call gpresult_timeline_paths.ps1 in this folder to
::           generate gpresult_timeline_paths.txt.

@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%gpresult_timeline_paths.ps1"
endlocal
