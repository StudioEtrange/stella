@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0

call %~dp0\conf.bat

:: arguments
set "params=action:"install list" id:"default all %TOOL_LIST%""
set "options=-arch:"#x64 x86" -f: -v: -vv: -vers:"_ANY_""
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

:: setting env
call %STELLA_COMMON%\common.bat :init_env

if "%action%"=="install" (

	if "%id%"=="default" (
		call :init_tools
	)
	if "%id%"=="ninja" (
		call %STELLA_COMMON%\common-tools.bat :install_feature ninja %-vers%
	)
	if "%id%"=="jom" (
		call %STELLA_COMMON%\common-tools.bat :install_feature jom %-vers%
	)
	if "%id%"=="cmake" (
		call %STELLA_COMMON%\common-tools.bat :install_feature cmake %-vers%
	)
	if "%id%"=="packer" (
		call %STELLA_COMMON%\common-tools.bat :install_feature packer %-vers%
	)
	if "%id%"=="perl" (
		call %STELLA_COMMON%\common-tools.bat :install_feature perl %-vers%
	)
	if "%id%"=="nasm" (
		call %STELLA_COMMON%\common-tools.bat :install_feature nasm %-vers%
	)
	if "%id%"=="python" (
		call %STELLA_COMMON%\common-tools.bat :install_feature python %-vers%
	)
	if "%id%"=="vagrant" (
		call %STELLA_COMMON%\common-tools.bat :install_feature vagrant %-vers%
	)
	if "%id%"=="openssh" (
		call %STELLA_COMMON%\common-tools.bat :install_feature openssh %-vers%
	)
	if "%id%"=="ruby" (
		call %STELLA_COMMON%\common-tools.bat :install_feature ruby %-vers%
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
	if not exist "%TOOL_ROOT%" mkdir "%TOOL_ROOT%"
	
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
