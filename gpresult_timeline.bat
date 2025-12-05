:: gpresult_timeline.bat
:: Purpose : Build a timeline of Group Policy changes between
::           consecutive gpresult_YYYYMMDD.xml snapshots.
:: Input   : All gpresult_*.xml files in this folder, sorted by name (date).
:: Output  : gpresult_timeline.txt listing the starting snapshot and,
::           for each later snapshot, the differences vs the previous one.
:: Notes   : Compares XML line-by-line and prints OLD/NEW lines with
::           line numbers for each change.

@echo off
setlocal EnableDelayedExpansion

set "OUT=gpresult_timeline.txt"
> "%OUT%" echo Group Policy timeline (differences between consecutive gpresult_YYYYMMDD.xml snapshots)
>>"%OUT%" echo.

rem --- collect and sort file list once ---
set "COUNT=0"
for /f "delims=" %%F in ('dir /b /on gpresult_*.xml 2^>nul') do (
    set /a COUNT+=1
    set "FILE_!COUNT!=%%F"
)

if %COUNT% EQU 0 (
    echo No gpresult_*.xml files found.
    >>"%OUT%" echo No gpresult_*.xml files found.
    goto :EOF
)

echo [DEBUG] Found %COUNT% file^(s^).

rem --- first file is starting point ---
set "PREV=!FILE_1!"
echo [DEBUG] Starting point is !PREV!
>>"%OUT%" echo Starting point: !PREV!
>>"%OUT%" echo.

rem --- compare each subsequent file to previous one ---
for /L %%I in (2,1,%COUNT%) do (
    set "CUR=!FILE_%%I!"
    echo [DEBUG] Comparing !CUR! to !PREV!
    >>"%OUT%" echo ==========================================================
    >>"%OUT%" echo Changes in !CUR! ^(vs !PREV!^):
    >>"%OUT%" echo.

    powershell -NoLogo -NoProfile -Command ^
      " $oldLines = Get-Content -Path '%CD%\!PREV!';" ^
      " $newLines = Get-Content -Path '%CD%\!CUR!';" ^
      " $max = [Math]::Max($oldLines.Count, $newLines.Count);" ^
      " for ($i = 0; $i -lt $max; $i++) {" ^
      "   $old = if ($i -lt $oldLines.Count) { $oldLines[$i] } else { $null };" ^
      "   $new = if ($i -lt $newLines.Count) { $newLines[$i] } else { $null };" ^
      "   if ($old -ne $new) {" ^
      "     $ln = $i + 1;" ^
      "     if ($old -ne $null) { Write-Output ('OLD [{0}] {1}' -f $ln, $old) }" ^
      "     if ($new -ne $null) { Write-Output ('NEW [{0}] {1}' -f $ln, $new) }" ^
      "     Write-Output ''" ^
      "   }" ^
      " }" >>"%OUT%"

    >>"%OUT%" echo.
    set "PREV=!CUR!"
)

echo Timeline written to "%OUT%"
endlocal
