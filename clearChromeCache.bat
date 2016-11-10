@echo off
set "_p=%~dp0"
pushd "%~dp0"
REM 批处理中%~dp0为批处理文件所在路径
if not exist "%_p%\User Data" exit
for %%i in (
"%_p%\User Data\Default\Cache"
"%_p%\User Data\PnaclTranslationCache"
"%_p%\User Data\ShaderCache"
"%_p%\User Data\Default\Application Cache"
"%_p%\User Data\Default\JumpListIconsOld"
"%_p%\User Data\Default\GPUCache"
"%_p%\User Data\Default\Media Cache"
"%_p%\User Data\Default\Pepper Data\Shockwave Flash\CacheWritableAdobeRoot\AssetCache"
"%_p%\User Data\Default\ChromeDWriteFontCache"
"%_p%\User Data\Default\Current Session"
"%_p%\User Data\Default\Current Tabs"
"%_p%\User Data\Default\Service Worker\ScriptCache"
"%_p%\User Data\Default\Service Worker\CacheStorage"
) do (
attrib -r -s -h %%i /D /S
del %%i /f /s /q
)

del /f /s /q "%_p%User Data\Default\Local Storage\*wikipedia.org*"
del /f /s /q "%_p%User Data\Default\Local Storage\*weibo.com*"
del /f /s /q "%_p%User Data\Default\Local Storage\*twitter.com*"
del /f /s /q "%_p%User Data\Default\Local Storage\*suning.com*"
del /f /s /q "%_p%User Data\Default\Local Storage\*taobao.com*"
del /f /s /q "%_p%User Data\Default\Local Storage\*wikisource.org*"
del /f /s /q "%_p%User Data\Default\Local Storage\*tmall.com_*"
del /f /s /q "%_p%User Data\Default\Local Storage\*itproportal.com_*"
del /f /s /q "%_p%User Data\Default\Local Storage\*alipay.com_*"
del /f /s /q "%_p%User Data\Default\Local Storage\*medium.com_*"
del /f /s /q "%_p%User Data\Default\Local Storage\*.jaeapp.com_*"
del /f /s /q "%_p%User Data\Default\Local Storage\*blog.tox.im_*"
del /f /s /q "%_p%User Data\Default\Local Storage\*neihanshequ.com_*"
del /f /s /q "%_p%User Data\Default\IndexedDB\*.bak"
del /f /s /q "%_p%User Data\Default\IndexedDB\*.log"
if exist debug.log del /f /q debug.log
pause
