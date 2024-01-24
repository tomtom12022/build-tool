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

REM psql -c "\i start_build_db.sql" postgresql://ACCOUNT:PASSWORD@IP:PORT/DATABASE > result.txt 2>&1
REM findstr /v /c:"NOTICE:" /c:"successfully completed" /c:"COMMENT" /c:"CREATE TABLE" /c:"CREATE INDEX" /c:"CREATE TYPE" /c:"DELETE 0" /c:"INSERT 0 1" /c:"CREATE PACKAGE" /c:"CREATE PACKAGE BODY" result.txt > error.txt
findstr /v /c:"NOTICE:" /c:"successfully completed" /c:"COMMENT" /c:"CREATE TABLE" /c:"CREATE INDEX" /c:"CREATE TYPE" /c:"DELETE 0" /c:"INSERT 0 1" /c:"CREATE PACKAGE" /c:"CREATE PACKAGE BODY" result.txt > error.txt
echo 執行完畢，請確認error.txt內容是否有問題，沒有問題則DB過版完成

cd /d %bat_folder%
echo 請確認sql檔案是否有問題，沒有問題請繼續下一步進行打包
pause
call %lazytools_folder%\pack_db_zip.bat

echo 執行完畢，請將打包完的zip開立一般上線單由DBA執行