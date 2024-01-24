:: 不印出指令
@echo off
:: 設定編碼為UTF8
mode con cp select=65001
@REM >>>>>>>>>請更改下方路徑資訊為自己本機的路徑<<<<<<<<<
:: 設定JAVA_HOME (Maven使用)，若已設定JAVA_HOME可註解此段
set JAVA_HOME=D:\eclipse\jdk1.8.0_171_R_O
:: 批次檔路徑
set bat_folder=C:\Users\ESB20355\Desktop\HkBuildTools
@REM >>>>>>>>>請更改上方路徑資訊為自己本機的路徑<<<<<<<<<
:: 報表位置
set report_folder=%bat_folder%\site
:: jar檔位置
set JAR=%bat_folder%\findBugsReportSummary.jar
set _7z="C:\Program Files\7-Zip\7z.exe"
:: 打包後端(批次除外) + 前端
set spotbugs_report_site_zip=%bat_folder%\spotbugs_report_site.zip
if exist %spotbugs_report_site_zip% del /q %spotbugs_report_site_zip% && echo 刪除遺留[%spotbugs_report_site_zip%]
echo 打包checkmarx程式包 [%spotbugs_report_site_zip%]...
for /f %%i in ('dir %report_folder% /b') do (
    %_7z% a %spotbugs_report_site_zip% %report_folder%\%%i -xr!target
)
echo [%spotbugs_report_site_zip%]打包完成！
echo.
echo.
echo.
echo BUG統計完成....
%JAVA_HOME%\bin\java -jar %JAR% %report_folder%
echo.
echo.
exit /b
