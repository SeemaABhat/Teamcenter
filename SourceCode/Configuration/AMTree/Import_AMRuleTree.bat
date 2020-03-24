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
echo Empty: %6

%TC_ROOT%\bin\am_install_tree.exe -u=infodba -p=%2 -g=dba -format=xml -operation=import -path=%3 -mode=replace_all
