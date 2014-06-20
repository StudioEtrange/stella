@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** BOOTSTRAPING STELLA ENV

call %~dp0\..\conf.bat
:: arguments
set "params="
set "options=-v: -vv: -internalcall:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

:: setting env
call %STELLA_COMMON%\common.bat :init_env


if not "%-internalcall%"=="1" (
	REM cmd /k "%~dp0\%~nx0" %* -alreadyboostraped
	call %STELLA_COMMON%\common.bat :fork "STELLA bootstrap" "%CD%" "%STELLA_COMMON%\bootstrap-stella-env.bat -internalcall" "DETACH"
)

:end
cd /D %CUR_DIR%
echo ** END **
@echo on


	


