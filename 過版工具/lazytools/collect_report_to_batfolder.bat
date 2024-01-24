:: 不印出指令
@echo off
:: 設定編碼為UTF8:: 設定編碼為UTF8
mode con cp select=65001
@REM >>>>>>>>>請更改下方路徑資訊為自己本機的路徑<<<<<<<<<
:: 批次檔路徑
set bat_folder=C:\Users\ESB20355\Desktop\HkBuildTools
:: 專案路徑 - 後端
set tmp_backend_folder=C:\Users\ESB20355\Desktop\HkBuildTools\tmp\abs_backend
@REM >>>>>>>>>請更改上方路徑資訊為自己本機的路徑<<<<<<<<<
:: 暫存檔 - 放存在site的目錄
set temp_file=%bat_folder%\temp.txt
:: 報表位置
set report_folder=%bat_folder%\site
:: 刪除遺留site folder
if exist %report_folder% rmdir %report_folder% /s /q && echo 成功刪除[%report_folder%]
cd /d %tmp_backend_folder%
for /f %%i in ('dir /s /b site') do (
    cd /d %%i
    cd ../..
    cd >> %temp_file%
)
cd /d %tmp_backend_folder%
setlocal ENABLEDELAYEDEXPANSION
:: 依序查找
for /f "delims=" %%i in (%temp_file%) do (
    call :GetPathAfterKeyword %%i abs_backend _path 
    if "!_path!" neq "" (
        xcopy "%tmp_backend_folder%\!_path!\target\site" "%report_folder%\!_path!\" /E /Y /K
    ) else xcopy "%tmp_backend_folder%\target\site" "%report_folder%\" /E /Y /K
)
endlocal
cd /d %bat_folder% && cd && del temp.txt
if /i "%is_build_mode%" equ "" (
    echo 作業完成！請按空白鍵進行下一步 & echo. & pause
)
exit /b
:: 切割路徑Function，找到指定位置後回傳剩餘路徑
:: 傳入參數: 
:: 1. 路徑
:: 2. 比對keyword
:: 回傳參數:
:: 3. 剩餘路徑
:GetPathAfterKeyword
set tmp=%~1
set keyword=%~2
:loop
for /f "tokens=1* delims=\" %%i in ("!tmp!") do (
    set tmp=%%j
    if "%%i" equ "%keyword%" set %~3=%%j
    if "%%i" equ "%keyword%" goto :end
)
if "!tmp!" neq "" goto :loop
:end
exit /b
