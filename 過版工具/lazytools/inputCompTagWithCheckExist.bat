:T_LOOP
echo Diff with previous version... 
call :SetTagThenCheckExist "請輸入tag of Version 1 (base): " old_tag
call :SetTagThenCheckExist "請輸入tag of Version 2: " new_tag
if "%old_tag%" equ "%new_tag%" echo 欲比較Tag相等，請重新輸入... && echo. && goto T_LOOP
set %~1=%old_tag%
set %~2=%new_tag%
exit /b 0

REM 請使用者輸入Tag並確認是否存在 
REM 傳入參數 
REM 1. 輸入提示訊息 
REM 輸出參數 
REM 2. 存在遠端的tag  
:SetTagThenCheckExist
:INPUT_LOOP
set inputMsg=%~1
set /p tag="%inputMsg%"
%git_folder%\cmd\git.exe show-ref --tags %tag% --quiet || echo Tag[%tag%]不存在，請重新確認... && echo. && goto INPUT_LOOP
set %~2=%tag%
exit /b 0