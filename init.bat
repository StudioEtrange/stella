@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0

call %~dp0\conf.bat


:: arguments
set "params="
set "options="
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

:: setting env
call %STELLA_COMMON%\common.bat :init_env

call :init_stella

goto :end

:usage
   echo USAGE :
   echo %~n0 %ARGOPT_HELP_SYNTAX%
goto :end


:init_stella
	call %STELLA_COMMON%\platform.bat :init_stella_by_os %STELLA_CURRENT_OS%
goto :eof


:end
echo ** END **
cd /D %CUR_DIR%
@echo on
@endlocal