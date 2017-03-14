@echo off
set "_p=%~dp0"
pushd "%~dp0"
if exist debug.log del /f /q debug.log
if exist "%~dp0\User Data" for /D %%i in ("%~dp0\User Data\*") do @if exist "%%~i\Preferences" call :clean "%~dp0" "%%~ni"
if not ["%~dp0"] == ["%LOCALAPPDATA%\Google\Chrome\"] if exist "%LOCALAPPDATA%\Google\Chrome\User Data" for /D %%i in ("%LOCALAPPDATA%\Google\Chrome\User Data\*") do @if exist "%%~i\Preferences" call :clean "%~dp0" "%%~ni"
if not ["%~dp0"] == ["%LOCALAPPDATA%\Google\Chrome SxS\"] if exist "%LOCALAPPDATA%\Google\Chrome SxS\User Data" for /D %%i in ("%LOCALAPPDATA%\Google\Chrome SxS\User Data\*") do @if exist "%%~i\Preferences" call :clean "%~dp0" "%%~ni"
if not defined LOCALAPPDATA if not ["%CD%"] == ["%USERPROFILE%\Local Settings\Application Data\Google\Chrome"] if exist "%USERPROFILE%\Local Settings\Application Data\Google\Chrome\User Data" for /D %%i in ("%USERPROFILE%\Local Settings\Application Data\Google\Chrome\User Data\*") do @if exist "%%~i\Preferences" call :clean "%~dp0" "%%~ni"
timeout /t 60 2>nul || pause

:clean
if not exist "%~1\User Data" exit /B -1
if not exist "%~1\User Data\%~2\Preferences" exit /B -2
for %%i in (
"%~1\User Data\%~2\Cache"
"%~1\User Data\PnaclTranslationCache"
"%~1\User Data\ShaderCache"
"%~1\User Data\%~2\Application Cache"
"%~1\User Data\%~2\JumpListIconsOld"
"%~1\User Data\%~2\GPUCache"
"%~1\User Data\%~2\Media Cache"
"%~1\User Data\%~2\Pepper Data\Shockwave Flash\CacheWritableAdobeRoot\AssetCache"
"%~1\User Data\%~2\ChromeDWriteFontCache"
"%~1\User Data\%~2\Current Session"
"%~1\User Data\%~2\Current Tabs"
"%~1\User Data\%~2\Service Worker\ScriptCache"
"%~1\User Data\%~2\Service Worker\CacheStorage"
) do (
attrib -r -s -h %%i /D /S
del %%i /f /s /q
)

del /f /s /q "%~1\User Data\%~2\Local Storage\*wikipedia.org*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*weibo.com*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*twitter.com*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*suning.com*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*taobao.com*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*wikisource.org*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*tmall.com_*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*itproportal.com_*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*alipay.com_*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*medium.com_*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*.jaeapp.com_*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*blog.tox.im_*"
del /f /s /q "%~1\User Data\%~2\Local Storage\*neihanshequ.com_*"
del /f /s /q "%~1\User Data\%~2\IndexedDB\https_pan.baidu.com_0.indexeddb.leveldb\*.bak"
del /f /s /q "%~1\User Data\%~2\IndexedDB\https_pan.baidu.com_0.indexeddb.leveldb\*.log"
exit /B
