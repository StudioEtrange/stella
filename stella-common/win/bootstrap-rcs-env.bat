@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** BOOTSTRAPING RCS ENV

call %~dp0\..\conf.bat
:: arguments
set "params="
set "options=-v: -vv: -internalcall:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage
call %STELLA_COMMON%\common.bat :init_arg


:: setting env
call %STELLA_COMMON%\common.bat :init_env

::setting verbose mode
call %STELLA_COMMON%\common.bat :set_verbose_mode %VERBOSE_MODE%


if not "%-internalcall%"=="1" (
	REM cmd /k "%~dp0\%~nx0" %* -alreadyboostraped
	call %STELLA_COMMON%\common.bat :fork "RCS bootstrap" "%CD%" "%STELLA_COMMON%\bootstrap-rcs-env.bat -internalcall" "FALSE" "FALSE" "TRUE"
)

:end
cd /D %CUR_DIR%
echo ** END **
@echo on


	


