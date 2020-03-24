@echo off
set TC_ROOT=%1tcroot
set TC_DATA=%1tcdata
call %TC_DATA%\tc_profilevars.bat
set TC_TMP_DIR=%~dp0
echo Syslog Path: %TC_TMP_DIR%

echo TC_ROOT: %TC_ROOT%
echo TC_DATA: %TC_DATA%
echo HomePath: %1
echo InfodbaPWD: %2
echo FilePath: %3
echo logFile: %4
echo ErrorFilePath: %5
echo FolderStructure: %6
echo Empty: %7

set filePath=
setlocal enabledelayedexpansion
for /F "tokens=*" %%A in (%3) do (
   echo %%A
   set filePath=%6\%%A
   echo filepath2: !filePath!
   %TC_ROOT%\bin\plmxml_import.exe -u=infodba -p=%2 -g=dba -xml_file=!filePath! -transfermode=incremental_import -import_mode=overwrite
)
endlocal
