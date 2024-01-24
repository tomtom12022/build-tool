:: 不印出指令
@echo off

:: 設定編碼為UTF8
mode con cp select=65001

call :ReplaceInfo "generate_spotbugs_report.bat"
call :ReplaceInfo "collect_report_to_batfolder.bat"
call :ReplaceInfo "summarize_report_info.bat"
call :ReplaceInfo "pack_checkmarx.bat"
call :ReplaceInfo "pack_db_zip.bat"
exit /b 0

:ReplaceInfo
echo 更新路徑資訊至[%~1] 
rename "%~1" "text.tmp"
(for /f "tokens=1* delims==" %%i in (text.tmp) do (
    if "%%j" equ "" (
        echo %%i
    ) else if "%%i" equ "set bat_folder" (
        echo %%i=%bat_folder%
    ) else if "%%i" equ "set git_folder" (
        echo %%i=%git_folder%
    ) else if "%%i" equ "set backend_folder" (
        echo %%i=%backend_folder%
    ) else if "%%i"=="set frontend_folder" (
        echo %%i=%frontend_folder%
    ) else if "%%i" equ "set sql_developer_folder" (
        echo %%i=%sql_developer_folder%
    ) else if "%%i" equ "set JAVA_HOME" (
        echo %%i=%JAVA_HOME%
    ) else if "%%i" equ "set m2_path" (
        echo %%i=%m2_path%
    ) else if "%%i" equ "set maven_cmd" (
        echo %%i=%maven_cmd%
    ) else if "%%i" equ "set tmp_backend_folder" (
        echo %%i=%tmp_backend_folder%
    )else echo %%i=%%j
)) > "%~1"
del text.tmp
exit /b 0