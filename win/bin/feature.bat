@setlocal enableExtensions enableDelayedExpansion
@echo off

call %~dp0\..\..\conf.bat

:: arguments
set "params=action:"install remove list" id:"_ANY_""
set "options=-f: -depforce: -depignore:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set FORCE=%-f%

:: setting env
call %STELLA_COMMON%\common.bat :init_stella_env

if "%action%"=="install" (
	set "_feature_options="
	if "%-depforce%"=="1" set "_feature_options=!_feature_options! DEP_FORCE"
	if "%-depignore%"=="1" set "_feature_options=!_feature_options! DEP_IGNORE"
	call %STELLA_COMMON%\common-feature.bat :feature_install %id% !_feature_options!
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
	echo 		%~n0 install ^<feature schema^> [-depforce] [-depignore] : install a feature. [-depforce] will force to reinstall all dependencies. [-depignore] will ignore dependencies. schema = feature_name[#version][@arch][:binary^|source][/os_restriction][\os_exclusion]
	echo 		%~n0 remove ^<feature schema^> : remove a feature
	echo 		%~n0 list ^<all^|feature name^|active^>: list all available feature OR available version of a feature OR current active features
goto :end






:end
echo ** END **
cd /D %STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal
