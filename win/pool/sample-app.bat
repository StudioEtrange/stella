@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0

call %~dp0\stella-link.bat :include

:: arguments
set "params=param1:"param1 param2""
set "options=-f: -opt1:"#default_val val1 val2 val3""

call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage



echo PARAM1 = %param1%
echo OPT1 = %-opt1%
echo F Flag = %-f%


call %STELLA_API%is_path_abs "VAR1" "c:\lib"
echo %VAR1%

goto :eof

:usage
	echo USAGE :
	echo %~n0 %ARGOPT_HELP_SYNTAX%
goto :eof


@echo on
@endlocal