@echo off
chcp 65001
@REM >>>>>>>>>請更改下方路徑資訊為自己本機的路徑<<<<<<<<<
:: 設定bat_folder
set bat_folder=C:\Users\ESB20355\Desktop\HkBuildTools
:: 設定Maven cmd, setting.xml
set maven_cmd=D:\apache-maven-3.8.1\bin\mvn.cmd
set m2_path=D:\m2\settings.xml
:: 設定backend_folder
set tmp_backend_folder=C:\Users\ESB20355\Desktop\HkBuildTools\tmp\abs_backend
@REM >>>>>>>>>請更改下方路徑資訊為自己本機的路徑<<<<<<<<<
cd /d %bat_folder%
setlocal ENABLEDELAYEDEXPANSION
echo 產製中...
start "maven site" /wait cmd /k "%maven_cmd% -s %m2_path% -f !tmp_backend_folder! -T 1C clean compile -Pdev site:site & pause & exit"
echo 產製完成！ & echo.
endlocal 
exit /b
