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
echo OTO: %6
echo Empty: %7

IF %6 == False (
echo Delete all AW Tile
%TC_ROOT%\bin\aws2_install_tilecollections.exe -u=infodba -p=%2 -g=dba -file=%3 -mode=remove
)

%TC_ROOT%\bin\aws2_install_tilecollections.exe -u=infodba -p=%2 -g=dba -file=%3 -mode=add
%TC_ROOT%\bin\aws2_install_tilecollections.exe -u=infodba -p=%2 -g=dba -file=%3 -mode=update
