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
) do (
attrib -r -s -h %%i /D /S
del %%i /f /s /q
)