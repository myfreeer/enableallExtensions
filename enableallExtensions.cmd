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
if exist "User Data" FOR /F "usebackq" %i IN (`dir /AD /B "User Data"`) DO @if exist "User Data\%~i\Extensions" FOR /F "usebackq" %j IN (`dir /AD /B "User Data\%~i\Extensions"`) do call :addrule %%i
if not ["%CD%"] == ["%LOCALAPPDATA%\Google\Chrome"] if exist "%LOCALAPPDATA%\Google\Chrome\User Data" FOR /F "usebackq" %i IN (`dir /AD /B "%LOCALAPPDATA%\Google\Chrome\User Data"`) DO @if exist "%LOCALAPPDATA%\Google\Chrome\User Data\%~i\Extensions" FOR /F "usebackq" %j IN (`dir /AD /B "%LOCALAPPDATA%\Google\Chrome\User Data\%~i\Extensions"`) do call :addrule %%i
if not defined LOCALAPPDATA if not ["%CD%"] == ["%USERPROFILE%\Local Settings\Application Data\Google\Chrome"] if exist "%USERPROFILE%\Local Settings\Application Data\Google\Chrome\User Data" FOR /F "usebackq" %i IN (`dir /AD /B "%USERPROFILE%\Local Settings\Application Data\Google\Chrome\User Data"`) DO @if exist "%USERPROFILE%\Local Settings\Application Data\Google\Chrome\User Data\%~i\Extensions" FOR /F "usebackq" %j IN (`dir /AD /B "%USERPROFILE%\Local Settings\Application Data\Google\Chrome\User Data\%~i\Extensions"`) do call :addrule %%i
if exist rule.txt LGPO.exe /t rule.txt
::if exist rule.txt move rule.txt nul
if exist rule.txt del /f /q rule.txt
timeout /t 60||pause
exit /B 0

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
