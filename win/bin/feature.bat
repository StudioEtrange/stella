@setlocal enableExtensions enableDelayedExpansion
@echo off

call %~dp0\..\..\conf.bat

:: arguments
set "params=action:"install remove list" id:"_ANY_""
set "options=-f:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set FORCE=%-f%

:: setting env
call %STELLA_COMMON%\common.bat :init_stella_env

if "%action%"=="install" (
	call %STELLA_COMMON%\common-feature.bat :feature_install %id%
	goto :end
)

if "%action%"=="remove" (
	call %STELLA_COMMON%\common-feature.bat :feature_remove %id%
	goto :end
)


if "%action%"=="list" (
	if "%id%"=="all" (
		echo required all %__STELLA_FEATURE_LIST%
	) else (
		if "%id%"=="active" (
			call %STELLA_COMMON%\common-feature.bat :list_active_features _TMP
			if not "!_TMP!"=="" echo !_TMP!
		) else (
			call %STELLA_COMMON%\common-feature.bat :list_feature_version %id% _TMP
			if not "!_TMP!"=="" echo !_TMP!
		)
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
	echo 		%~n0 install ^<feature schema^> : install a feature. schema = feature_name[#version][@arch][/binary|source][:os_restriction]
	echo 		%~n0 remove ^<feature schema^> : remove a feature
	echo 		%~n0 list ^<all^|feature name^|active^>: list all available feature OR available version of a feature OR current active features
goto :end






:end
echo ** END **
cd /D %_STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal
