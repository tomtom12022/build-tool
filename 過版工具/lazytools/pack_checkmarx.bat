:: 不印出指令
@echo off
chcp 65001
@REM >>>>>>>>>請更改下方路徑資訊為自己本機的路徑<<<<<<<<<
:: 設定git folder(路徑有空白就用雙引號包著)
set git_folder=C:\Users\ESB20355\AppData\Local\Programs\Git
:: 設定bat_folder
set bat_folder=C:\Users\ESB20355\Desktop\HkBuildTools
:: 設定Maven cmd, setting.xml
set maven_cmd=D:\apache-maven-3.8.1\bin\mvn.cmd
set m2_path=D:\m2\settings.xml
:: 設定backend_folder
set backend_folder=C:\Users\ESB20355\Desktop\HkBuildTools\abs_backend
:: 設定frontend_folder
set frontend_folder=C:\Users\ESB20355\Desktop\HkBuildTools\abs_frontend
@REM >>>>>>>>>請更改下方路徑資訊為自己本機的路徑<<<<<<<<<
set git=%git_folder%\cmd\git.exe
cd /d %bat_folder%
echo 產製中...
set _7z="C:\Program Files\7-Zip\7z.exe"
:: 打包批次
set checkmarx_batch_zip=%bat_folder%\abs_checkmarx_batch.zip
if exist %checkmarx_batch_zip% del /q %checkmarx_batch_zip% && echo 刪除遺留[%checkmarx_batch_zip%]
echo 打包checkmarx程式包 [%checkmarx_batch_zip%]...
for /f %%i in ('dir %backend_folder%\abs-batch /b') do (
    %_7z% a %checkmarx_batch_zip% %backend_folder%\abs-batch\%%i -xr!target
)
echo [%checkmarx_batch_zip%]打包完成！
echo.
:: 打包後端(批次除外) + 前端
set checkmarx_online_zip=%bat_folder%\abs_checkmarx_online.zip
if exist %checkmarx_online_zip% del /q %checkmarx_online_zip% && echo 刪除遺留[%checkmarx_online_zip%]
echo 打包checkmarx程式包 [%checkmarx_online_zip%]...
for /f %%i in ('dir %frontend_folder%\abs-frontend-* /b') do (
    %_7z% a %checkmarx_online_zip% %frontend_folder%\%%i -xr!dist -xr!node_modules
)
for /f %%i in ('dir %backend_folder%\abs-* /b ^| find /v "batch" ^| find /v "mock" ^| find /v "db-script" ^| find /v "abs-external-interface"') do (
    %_7z% a %checkmarx_online_zip% %backend_folder%\%%i -xr!target
)
%_7z% a %checkmarx_online_zip% %backend_folder%\pom.xml
%_7z% a %checkmarx_online_zip% %backend_folder%\README.md
echo [%checkmarx_online_zip%]打包完成！
echo 產製完成！ & echo.
exit /b 0
