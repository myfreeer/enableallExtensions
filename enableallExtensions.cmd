@echo off
setlocal EnableExtensions EnableDelayedExpansion
color 1f
:--------------------------------------------------------------------------
REG QUERY "HKU\S-1-5-19" >nul 2>&1
if %errorlevel% NEQ 0 goto :UACPrompt
goto :gotAdmin
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~fs0 %*", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /b
:gotAdmin
pushd "%~dp0"
:--------------------------------------------------------------------------
title Add All Existing Chrome Extensions To ExtensionInstallWhitelist
if exist rule.txt del rule.txt
set /a n=0
call :addbase
FOR /F "usebackq" %%i IN (`dir /AD /B "User Data\Default\Extensions"`) DO call :addrule %%i
if exist rule.txt LGPO.exe /t rule.txt
::if exist rule.txt move rule.txt nul
if exist rule.txt del /f /q rule.txt
pause
exit /B 0
exit /B 1
exit /B -1

:addbase
echo Computer>rule.txt
echo Software\Policies\Google\Chrome\ExtensionInstallWhitelist>>rule.txt
echo ^*>>rule.txt
echo DELETEALLVALUES>>rule.txt
exit /B

:addrule
set /a n+=1
if [%1]==[] exit /B -1
if [%n%]==[] exit /B -1
echo Computer>>rule.txt
echo Software\Policies\Google\Chrome\ExtensionInstallWhitelist>>rule.txt
echo ^%n%>>rule.txt
echo SZ:%1>>rule.txt
exit /B