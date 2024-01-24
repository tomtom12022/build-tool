@echo off
chcp 65001

@REM >>>>>>>>>需要手動修改的資訊<<<<<<<<<
:: 設定git folder(路徑有空白就用雙引號包著)
set git_folder=C:\Users\ESB20355\AppData\Local\Programs\Git
:: 設定JAVA_HOME (Maven使用)，若已設定JAVA_HOME可註解此段
set JAVA_HOME=D:\eclipse\jdk1.8.0_171_R_O
:: 設定Maven cmd, setting.xml
set maven_cmd=D:\apache-maven-3.8.1\bin\mvn.cmd
set m2_path=D:\m2\settings.xml
@REM >>>>>>>>>需要手動修改的資訊<<<<<<<<<

:: bat_folder
set bat_folder=%cd%
:: backend_folder
set backend_folder=%bat_folder%\abs_backend
:: frontend_folder
set frontend_folder=%bat_folder%\abs_frontend
:: db-script_folder
set db-script=%backend_folder%\abs-db-script
:: git檔案路徑
set git=%git_folder%\cmd\git.exe
:: psql.exe檔案路徑
set psql=%bat_folder%\psql.exe
:: lazytools_folder
set lazytools_folder=%bat_folder%\lazytools
REM tmp_backend_folder
set tmp_backend_folder=%bat_folder%\tmp\abs_backend

set _7z="C:\Program Files\7-Zip\7z.exe"
:: 打包批次
set  abs_db_build_zip=%bat_folder%\abs_db_build.zip

cd /d %bat_folder%
REM 清空目錄下的sql檔
call :clearSqlData

echo 更新檔案...
if exist %backend_folder% (
    cd /d %backend_folder%
    %git% fetch -v --progress "origin"
) else (
    %git% clone https://XXXX.git
    cd /d %backend_folder%
)
echo 更新完成！

:E_LOOP
set /p environment="請輸入目標環境? (SIT):"
if /i "%environment%" equ "SIT" echo. & goto BUILD_DB
goto :E_LOOP

REM 過版DEV
:BUILD_DB
set /p build_tag="請輸入SIT tag:"
%git% show-ref --tags %build_tag% --quiet || echo Tag[%build_tag%]不存在於git上，請重新確認... && goto BUILD_DB
%git% checkout %build_tag%
echo 已切換到tag:%build_tag%

if "%environment%" equ "SIT" (set lowcase_environment=sit)
if "%environment%" equ "UAT" (set lowcase_environment=uat)
if "%environment%" equ "PROD" (set lowcase_environment=prod)

cd /d %bat_folder%
call :GetDbScript "Create Pre-Action" ".\lazytools\%environment%" "0.*.sql" ddl_101_db_pre_action.sql

call :GetDbScript "Create GLOBAL Table" ".\abs_backend\abs-db-script\global_edb\global_ddl\tables" "TB_.*.sql" ddl_102_create_global_table.sql
call :GetDbScript "Create GLOBAL Index" ".\abs_backend\abs-db-script\global_edb\global_ddl\indexes" "TB_.*.sql" ddl_103_create_global_index.sql
call :GetDbScript "Create GLOBAL Type" ".\abs_backend\abs-db-script\global_edb\global_ddl\types" "TT_.*.sql" ddl_104_create_global_type.sql
call :GetDbScript "Create GLOBAL Package" ".\abs_backend\abs-db-script\global_edb\global_ddl\packages" "PKG_.*.PKG" ddl_105_create_global_package.sql
call :GetDbScript "Create GLOBAL Package Body" ".\abs_backend\abs-db-script\global_edb\global_ddl\packages" "PKG_.*.PKB" ddl_106_create_global_package_body.sql

call :GetDbScript "Create HK Table" ".\abs_backend\abs-db-script\hk\hk_ddl\tables" "TB_.*.sql" ddl_107_create_hk_table.sql
call :GetDbScript "Create HK Index" ".\abs_backend\abs-db-script\hk\hk_ddl\indexes" "TB_.*.sql" ddl_108_create_hk_index.sql
call :GetDbScript "Create HK Type" ".\abs_backend\abs-db-script\hk\hk_ddl\types" "TT_.*.sql" ddl_109_create_hk_type.sql
call :GetDbScript "Create HK Package" ".\abs_backend\abs-db-script\hk\hk_ddl\packages" "PKG_.*.PKG" ddl_110_create_hk_package.sql
call :GetDbScript "Create HK Package Body" ".\abs_backend\abs-db-script\hk\hk_ddl\packages" "PKG_.*.PKB" ddl_111_create_hk_package_body.sql

call :GetDbScript "Create ABS ODS GLOBAL Table" ".\abs_backend\abs-db-script\abs_ods\abs_ods_global\tables" "TB_.*.sql" ddl_112_create_abs_ods_global_table.sql
call :GetDbScript "Create ABS ODS GLOBAL Index" ".\abs_backend\abs-db-script\abs_ods\abs_ods_global\indexes" "TB_.*.sql" ddl_113_create_abs_ods_global_index.sql

call :GetDbScript "Create ABS ODS HK Table" ".\abs_backend\abs-db-script\abs_ods\abs_ods_hk\tables" "TB_.*.sql" ddl_114_create_abs_ods_hk_table.sql

call :GetDbScript "Create GLOBAL dml" ".\abs_backend\abs-db-script\global_edb\global_dml\initial-load" "TB_.*.sql" dml_101_create_global_dml.sql
call :GetDbScript "Create GLOBAL dml" ".\abs_backend\abs-db-script\global_edb\global_dml\test-data\%lowcase_environment%" "TB_.*.sql" dml_102_create_global_dml.sql
call :GetDbScript "Create HK dml" ".\abs_backend\abs-db-script\hk\hk_dml\initial-load" "TB_.*.sql" dml_103_create_hk_dml.sql
call :GetDbScript "Create HK dml" ".\abs_backend\abs-db-script\hk\hk_dml\initial-load\%lowcase_environment%" "TB_.*.sql" dml_104_create_hk_env_dml.sql

call :GetDbScript "Create start ddl sql" "." "ddl_1.*.sql" start_build_ddl_db.sql
call :GetDbScript "Create start dml sql" "." "dml_1.*.sql" start_build_dml_db.sql

echo 請確認sql檔案是否有問題，沒有問題請繼續下一步
REM pause
REM if exist .\result.txt del /s /q .\result.txt && echo 刪除[result.txt]成功！ && echo.
REM if exist .\error.txt del /s /q .\error.txt && echo 刪除[error.txt]成功！ && echo.
echo 執行打包DB...

cd /d %bat_folder%
REM echo 請確認sql檔案是否有問題，沒有問題請繼續下一步進行打包
REM pause

if exist %abs_db_build_zip% del /q %abs_db_build_zip% && echo 刪除遺留[%abs_db_build_zip%]
echo 準備打包DB.... [%abs_db_build_zip%]...

%_7z% a %abs_db_build_zip% "lazytools\%environment%\"
%_7z% a %abs_db_build_zip% "abs_backend\abs-db-script\db_change"
%_7z% a %abs_db_build_zip% "abs_backend\abs-db-script\global_edb"
%_7z% a %abs_db_build_zip% "abs_backend\abs-db-script\hk"
%_7z% a %abs_db_build_zip% "abs_backend\abs-db-script\abs_ods"
%_7z% a %abs_db_build_zip% "*.sql"


echo [%abs_db_build_zip%]打包完成！

echo 執行完畢，請將打包完的zip開立一般上線單由DBA執行

REM psql -c "\i start_build_db.sql" postgresql://ACCOUNT:PASSWORD@IP:PORT/DATABASE > result.txt 2>&1
REM findstr /v /c:"NOTICE:" /c:"successfully completed" /c:"COMMENT" /c:"CREATE TABLE" /c:"CREATE INDEX" /c:"CREATE TYPE" /c:"DELETE 0" /c:"INSERT 0 1" /c:"CREATE PACKAGE" /c:"CREATE PACKAGE BODY" result.txt > error.txt

pause & exit

REM 產製db script
REM 傳入參數
REM 1. 視窗名稱
REM 2. 查找目錄路徑(abs-db-script之後)
REM 3. 目標檔案Pattern
REM 4. 輸出檔案名稱
 
:GetDbScript
setlocal ENABLEDELAYEDEXPANSION
:: declare variable這個要
set title=%~1
set scanFolder=%~2
set pattern=%~3
set outputFile=%~4
set keyFolder=%~5
call :WriteHead
call :GetCommand %scanFolder% %pattern% _command
call :WriteBody
echo 載入完成! 請查看[%outputFile%] & echo.
endlocal
exit /b 0

:clearSqlData
::刪除目錄下的sql檔案
for /f "delims=" %%f in ('dir /a /b %bat_folder% ^| findstr "\.sql"') do (
    echo 刪除%%f....
    if exist %%f del /s /q %%f && echo 刪除[%%f]成功！ && echo.
) 
exit /b 0

:WriteHead
:: 寫入Sql檔 表頭
echo 載入 [%title%] 指令中...
echo \encoding UTF8;>>%bat_folder%\%outputFile%
exit /b 0

:WriteBody
for /f "delims=" %%i in ('!_command!') do (
    set _path=%scanFolder%\%%i;
    echo \i !_path:\=/!>>%bat_folder%\%outputFile%
)
exit /b 0

REM 產出指令 
REM 傳入參數 
REM 1. 查找目錄名稱 
REM 2. 目標檔案Pattern  
:GetCommand
set scanFolder=%~1
set pattern=%~2
set command=dir /b %scanFolder% ^| findstr /r %pattern%
set %~3=!command!
exit /b

REM 產生start_build_db.sql
REM 1. 搜尋的檔案
REM 2. 產生的檔案
:createBuildScript
setlocal ENABLEDELAYEDEXPANSION
set searchData=%~1
set startBuildData=%~2
echo 載入start_build_db.sql指令中...
echo \encoding UTF8;>>%bat_folder%\%startBuildData%
set build_cmd=dir /b %bat_folder% ^| findstr /r %searchData%
for /f "delims=" %%i in ('dir /b %bat_folder% ^| findstr /r %searchData%') do (
    set _path_data=.\%%i;
    echo \i !_path_data:\=/!>>%bat_folder%\%startBuildData%
)
endlocal
exit /b 0

:end
pause