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
@REM >>>>>>>>>請更改下方路徑資訊為自己本機的路徑<<<<<<<<<
set git=%git_folder%\cmd\git.exe
cd /d %bat_folder%
echo 產製中...
set _7z="C:\Program Files\7-Zip\7z.exe"
:: 打包批次
set  abs_db_build_zip=%bat_folder%\abs_db_build.zip
if exist %abs_db_build_zip% del /q %abs_db_build_zip% && echo 刪除遺留[%abs_db_build_zip%]
echo 準備打包DB.... [%abs_db_build_zip%]...

%_7z% a %abs_db_build_zip% "abs_backend\abs-db-script\db_change"
%_7z% a %abs_db_build_zip% "abs_backend\abs-db-script\global_edb"
%_7z% a %abs_db_build_zip% "abs_backend\abs-db-script\hk"
%_7z% a %abs_db_build_zip% "abs_backend\abs-db-script\abs_ods"
%_7z% a %abs_db_build_zip% "*.sql"


echo [%abs_db_build_zip%]打包完成！
echo.
exit /b 0
