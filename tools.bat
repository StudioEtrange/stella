@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0

call %~dp0\conf.bat

:: arguments
set "params=action:"install list" id:"default all %TOOL_LIST%""
set "options=-f: -vers:"_ANY_""
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set FORCE=%-f%

:: setting env
call %STELLA_COMMON%\common.bat :init_stella_env

if "%action%"=="install" (

	if "%id%"=="default" (
		call :init_tools
	) else (
		call %STELLA_COMMON%\common-tools.bat :install_feature %id% %-vers%
	)

	goto :end	
)


if "%action%"=="list" (
	if "%id%"=="all" (
		echo "default %TOOL_LIST%"
	) else (
		call %STELLA_COMMON%\common-tools.bat :list_feature_version %id% _TMP
		echo !_TMP!
	)
	goto :end
)

goto :usage


:usage
   echo USAGE :
   echo %~n0 %ARGOPT_HELP_SYNTAX%
goto :end



:init_tools
	echo ** Initialize Tools
	if not exist "%STELLA_APP_ROOT%" mkdir "%STELLA_APP_ROOT%"
	
	call %STELLA_COMMON%\common-tools.bat :unzip
	call %STELLA_COMMON%\common-tools.bat :wget
	call %STELLA_COMMON%\common-tools.bat :sevenzip
	call %STELLA_COMMON%\common-tools.bat :patch
	call %STELLA_COMMON%\common-tools.bat :gnumake
goto :eof



:end
echo ** END **
cd /D %_CURRENT_RUNNING_DIR%
@echo on
@endlocal
