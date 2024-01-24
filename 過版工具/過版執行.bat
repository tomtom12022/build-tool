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
set /p environment="請輸入目標環境? (DEV/SIT):"
if /i "%environment%" equ "DEV" echo. & goto CHECK_DEV_BUILD_DB
if /i "%environment%" equ "SIT" echo. & goto BUILD_SIT
goto :E_LOOP

:CHECK_DEV_BUILD_DB
set /p checkBuildDevDb="是否要過版DB? (Y/N):"
if /i "%checkBuildDevDb%" equ "Y" echo. & goto BUILD_DEV_DB
if /i "%checkBuildDevDb%" equ "N" echo. & goto CHECK_BUG_LOOP
goto :CHECK_DEV_BUILD_DB

REM 過版DEV
:BUILD_DEV_DB
set /p dev_tag="請輸入DEV tag:"
echo "%dev_tag%" | find /c "d.0.0.0." >nul || echo 此tag非DEV環境，DEV環境tag應為d.0.0.0...... && goto BUILD_DEV_DB
%git% show-ref --tags %dev_tag% --quiet || echo Tag[%dev_tag%]不存在於git上，請重新確認... && goto BUILD_DEV_DB
%git% checkout %dev_tag%
echo 已切換到tag:%dev_tag%

cd /d %bat_folder%
call :GetDbScript "Create Pre-Action" ".\lazytools\%environment%" "0.*.sql" 101_db_pre_action.sql
call :GetDbScript "Create Table" ".\abs_backend\abs-db-script\hk\hk_ddl\tables" "TB_.*.sql" 102_create_table.sql
call :GetDbScript "Create Index" ".\abs_backend\abs-db-script\hk\hk_ddl\indexes" "TB_.*.sql" 103_create_index.sql
call :GetDbScript "Create HK Type" ".\abs_backend\abs-db-script\hk\hk_ddl\types" "TT_.*.sql" 104_create_type.sql
call :GetDbScript "Create HK Package" ".\abs_backend\abs-db-script\hk\hk_ddl\packages" "PKG_.*.PKG" 105_create_package.sql
call :GetDbScript "Create HK Package Body" ".\abs_backend\abs-db-script\hk\hk_ddl\packages" "PKG_.*.PKB" 106_create_package_body.sql
call :GetDbScript "Create HK dml" ".\abs_backend\abs-db-script\hk\hk_dml\initial-load" "TB_.*.sql" 107_create_hk_dml.sql
call :GetDbScript "Create GLOBAL Package" "%db-script%\global_edb\global_ddl\packages" "PKG_.*.PKG" 108_create_global_package.sql
call :GetDbScript "Create GLOBAL Package Body" "%db-script%\global_edb\global_ddl\packages" "PKG_.*.PKB" 109_create_global_package_body.sql
call :GetDbScript "Create start sql" "." "1.*.sql" start_build_db.sql
echo 請確認sql檔案是否有問題，沒有問題請繼續下一步
pause
if exist .\result.txt del /s /q .\result.txt && echo 刪除[result.txt]成功！ && echo.
if exist .\error.txt del /s /q .\error.txt && echo 刪除[error.txt]成功！ && echo.
echo 執行驗證DB...

REM psql -c "\i start_build_db.sql" postgresql://ACCOUNT:PASSWORD@IP:PORT/DATABASE > result.txt 2>&1
REM findstr /v /c:"NOTICE:" /c:"successfully completed" /c:"COMMENT" /c:"CREATE TABLE" /c:"CREATE INDEX" /c:"CREATE TYPE" /c:"DELETE 0" /c:"INSERT 0 1" /c:"CREATE PACKAGE" /c:"CREATE PACKAGE BODY" result.txt > error.txt

echo 執行完畢，請確認error.txt內容是否有問題

:CHECK_BUG_LOOP
set /p checkBug="是否要做弱點檢查? (Y/N):"
if /i "%checkBug%" equ "Y" echo. & goto UPDATE_BAT_INFO
if /i "%checkBug%" equ "N" echo 結束執行 & pause & exit
goto :CHECK_BUG_LOOP

:UPDATE_BAT_INFO
echo 更新執行檔資訊...
cd /d %lazytools_folder%
call %lazytools_folder%\update_folder_info.bat
echo 更新完畢...

:CHECK_SPOTBUGS_LOOP
set /p checkBug="是否要做spotbugs? (Y/N):"
if /i "%checkBug%" equ "Y" echo. & goto DO_SPOTBUGS
if /i "%checkBug%" equ "N" echo.& goto CHECKMARX_LOOP
goto :CHECK_SPOTBUGS_LOOP

:DO_SPOTBUGS
REM 建立TMP
if exist %tmp_backend_folder% (
    cd /d %tmp_backend_folder%
    %git% fetch -v --progress "origin"
) else (
	mkdir %bat_folder%\tmp
	cd /d %bat_folder%\tmp
    %git% clone https://XXXX.git 
	cd /d %tmp_backend_folder%
)
%git% checkout remotes/origin/hk_dev_branch
echo 更新完成！

call %lazytools_folder%\generate_spotbugs_report
call %lazytools_folder%\collect_report_to_batfolder
call %lazytools_folder%\summarize_report_info
echo spotbugs執行完畢...
echo 刪除tmp後端...
cd /d %bat_folder% && rmdir /s /q %bat_folder%\tmp && echo 成功刪除暫存目錄-[%bat_folder%\tmp]！ & echo.
if exist %bat_folder%\tmp echo 無法刪除暫存目錄-[%bat_folder%\tmp]！ & pause

:CHECKMARX_LOOP
set /p checkCheckmarx="是否要打包檔案做Checkmarx? (Y/N):"
if /i "%checkCheckmarx%" equ "Y" echo. & goto PACK_CHECKMARX
if /i "%checkCheckmarx%" equ "N" echo 版流程結束.... & pause & exit
goto :CHECKMARX_LOOP

:PACK_CHECKMARX
echo 更新abs_frontend檔案...
if exist %frontend_folder% (
    cd /d %frontend_folder%
    %git% fetch -v --progress "origin"
) else (
    %git% clone https://XXXX.git
    cd /d %frontend_folder%
)
%git% checkout remotes/origin/hk_dev_branch
echo 更新完成！

call %lazytools_folder%\pack_checkmarx.bat
echo 過版流程結束...
pause & exit

REM 過版SIT
:BUILD_SIT
echo "請輸入SIT tag"
cd /d %backend_folder%
call %bat_folder%\lazytools\inputCompTagWithCheckExist.bat old_tag new_tag
echo %old_tag% 和 %new_tag%
%git% checkout %new_tag%
echo 已切換到tag:%new_tag%
call :GetDbScript "Alter TABLE" ".\abs_backend" "ALTER_.*.sql" 150_alter_table.sql db_change
call :GetDbScript "Alter Global Package" ".\abs_backend" "PKG_.*.PKG" 151_alter_global_package.sql global_edb
call :GetDbScript "Alter Global Package Body" ".\abs_backend" "PKG_.*.PKB" 152_alter_global_package_body.sql global_edb
call :GetDbScript "Alter Hk Package" ".\abs_backend" "PKG_.*.PKG" 153_alter_hk_package.sql hk_dml
call :GetDbScript "Alter Hk Package Body" ".\abs_backend" "PKG_.*.PKB" 154_alter_hk_package_body.sql hk_dml
call :createBuildScript "1.*.sql" start_build_db.sql

echo 請確認sql檔案是否有問題，沒有問題請繼續下一步
pause
if exist .\result.txt del /s /q .\result.txt && echo 刪除[result.txt]成功！ && echo.
if exist .\error.txt del /s /q .\error.txt && echo 刪除[error.txt]成功！ && echo.
echo 執行過版SIT DB...

REM psql -c "\i start_build_db.sql" postgresql://ACCOUNT:PASSWORD@IP:PORT/DATABASE > result.txt 2>&1
REM findstr /v /c:"NOTICE:" /c:"successfully completed" /c:"COMMENT" /c:"CREATE TABLE" /c:"CREATE INDEX" /c:"CREATE TYPE" /c:"DELETE 0" /c:"INSERT 0 1" /c:"CREATE PACKAGE" /c:"CREATE PACKAGE BODY" result.txt > error.txt
echo 執行完畢，請確認error.txt內容是否有問題
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
if /i "%environment%" equ "DEV" (
    set command=dir /b %scanFolder% ^| findstr /r %pattern%
) else (
    set command=%git% diff %old_tag% %new_tag% --name-only ^| find "%keyFolder%/" ^| findstr /r "%pattern%"
)
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
    set _path_data=%bat_folder%\%%i;
    echo \i !_path_data:\=/!>>%bat_folder%\%startBuildData%
)
endlocal
exit /b 0

:end
pause