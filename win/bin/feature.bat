@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0

call %~dp0\..\..\conf.bat

:: arguments
set "params=action:"install list" id:"required all %__STELLA_FEATURE_LIST%""
set "options=-f: -vers:_ANY_"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set FORCE=%-f%

:: setting env
call %STELLA_COMMON%\common.bat :init_stella_env

if "%action%"=="install" (
	call %STELLA_COMMON%\common-feature.bat :install_feature %id% %-vers%
	goto :end
)


if "%action%"=="list" (
	if "%id%"=="all" (
		echo required all %__STELLA_FEATURE_LIST%
	) else (
		call %STELLA_COMMON%\common-feature.bat :list_feature_version %id% _TMP
		echo !_TMP!
	)
	goto :end
)

goto :usage


:usage
   	echo USAGE :
   	echo %~n0 %ARGOPT_HELP_SYNTAX%

   	echo ----------------
	echo List of commands
   	echo	* feature management :
	echo 		%~n0 install required : install required features for Stella
	echo 		%~n0 install ^<feature name^> [-vers=^<version^>] : install a feature. version is optional
	echo 		%~n0 list ^<all^|feature name^>: list all available feature OR available version of a feature
	echo 		%~n0 list all: list available features
goto :end






:end
echo ** END **
cd /D %_STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal
