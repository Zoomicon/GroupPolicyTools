:: gpresult_snapshot.bat
:: Purpose : Generate a Group Policy RSOP snapshot in XML format.
:: Output  : gpresult_YYYYMMDD.xml saved next to this script.
:: UAC     : If not already elevated, prompts for admin rights and
::           reruns itself with the script folder as working directory.
:: Usage   : Run manually or via Task Scheduler to capture periodic snapshots.

@echo off
setlocal

set "SCRIPT_DIR=%~dp0"

:: --- self-elevate if not admin ---
fsutil dirty query %systemdrive% >nul 2>&1
if errorlevel 1 (
    echo Requesting administrative privileges...
    powershell -NoLogo -NoProfile -Command ^
        "Start-Process -FilePath '%~f0' -Verb RunAs -WorkingDirectory '%SCRIPT_DIR%'" ^
        2>nul
    exit /b
)

:: --- actual script below runs only when elevated or if user declined ---
for /f %%A in ('powershell -NoLogo -NoProfile -Command "(Get-Date).ToString(\"yyyyMMdd\")"') do set "ISODATE=%%A"

gpresult.exe /x "%SCRIPT_DIR%gpresult_%ISODATE%.xml" /f

echo Saved "%SCRIPT_DIR%gpresult_%ISODATE%.xml"
endlocal
