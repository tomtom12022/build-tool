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

set old_tag="s.0.0.0.202307141800"
set new_tag="s.0.0.0.202307211900"
set pattern="PKG_.*.PKG"
set scanFolder=".\abs_backend"
set outputFile="123.sql"
cd /d %backend_folder%

set command=%git% diff %old_tag% %new_tag% --name-only | find "hk/" | findstr /r "%pattern%"

echo \encoding UTF8;>>%bat_folder%\%outputFile%


for /f "delims=" %%i in ('%git% diff %old_tag% %new_tag% --name-only ^| find "hk/" ^| findstr /r "%pattern%"') do (
	echo %%i;
REM    set _path=%scanFolder%\%%i;
REM    echo \i !_path:\=/!>>%bat_folder%\%outputFile%
)

pause