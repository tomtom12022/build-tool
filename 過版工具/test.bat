set varA=B
if "%varA%"=="A" (
    echo %varA% is A
    echo AAA
) else if "%varA%"=="B" (
    echo %varA% is B
    echo BBB
) else (
    echo %varA% is C
    echo CCC
)
pause