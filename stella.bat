@setlocal enableExtensions enableDelayedExpansion
@echo off

call %~dp0\conf.bat



:: arguments
set "params=domain:"app feature stella proxy boot" action:"version on off register search remove link api install init get-data get-assets get-data-pack get-assets-pack delete-data delete-data-pack delete-assets delete-assets-pack update-data update-assets revert-data revert-assets update-data-pack update-assets-pack revert-data-pack revert-assets-pack get-feature install list stella docker" id:"_ANY_""
set "options=-f: -approot:_ANY_ -workroot:_ANY_ -cachedir:_ANY_ -stellaroot:_ANY_ -samples: -proxyhost:_ANY_ -proxyport:_ANY_ -proxyuser:_ANY_ -proxypass:_ANY_ -depforce: -depignore:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set FORCE=%-f%


REM --------------- APP ----------------------------
if "%DOMAIN%"=="app" (
	set "_app_options="
	if not "%-approot%"=="" set "_app_options=!_app_options! -approot=%-approot%"
	if not "%-workroot%"=="" set "_app_options=!_app_options! -workroot=%-workroot%"
	if not "%-cachedir%"=="" set "_app_options=!_app_options! -cachedir=%-cachedir%"
	if not "%-stellaroot%"=="" set "_app_options=!_app_options! -stellaroot=%-stellaroot%"	

	if "%-samples%"=="1" set "_app_options=!_app_options! -samples"
	if "%-f%"=="1" set "_app_options=!_app_options! -f"
	
	call %STELLA_BIN%\app.bat %ACTION% %id% !_app_options!
	@echo off
	goto :end

)
if "%DOMAIN%"=="app" goto :end



REM --------------- BOOT ----------------------------
if "%DOMAIN%"=="boot" (
	call %STELLA_COMMON%\common.bat :init_stella_env

	if "%ACTION%"=="stella" (
		if "%id%"=="shell" (
			call %STELLA_COMMON%\common.bat :bootstrap_stella_env
			goto :end
		)
	)
)
if "%DOMAIN%"=="boot" goto :end




REM --------------- STELLA ----------------------------
if "%DOMAIN%"=="stella" (
	call %STELLA_COMMON%\common.bat :init_stella_env
	
	if "%ACTION%"=="api" (
		if "%id%"=="list" (
			call %STELLA_COMMON%\common-api.bat :api_list "VAR"
			echo !VAR!
			goto :end
		)
	)

	if "%ACTION%"=="install" (
		if "%id%"=="dep" (
			call %STELLA_COMMON%\common-platform.bat :__stella_requirement
			goto :end
		)
	)

	

	if "%ACTION%"=="version" (
		if "%id%"=="print" (
			call %STELLA_COMMON%\common.bat :get_stella_flavour "VAR1"
			call %STELLA_COMMON%\common.bat :get_stella_version "VAR2"
			echo !VAR1! -- !VAR2!
			goto :end
		)
		
	)

	if "%ACTION%"=="search" (
		if "%id%"=="path" (
			call %STELLA_COMMON%\common.bat :get_active_path "_TMP"
			if not "!_TMP!"=="" echo !_TMP!
		)
		goto :end
	)

)
if "%DOMAIN%"=="stella" goto :end


REM --------------- FEATURE ----------------------------
if "%DOMAIN%"=="feature" (
	set "_feature_options="
	if "%-f%"=="1" set "_feature_options=!_feature_options! -f"
	if "%-depforce%"=="1" set "_feature_options=!_feature_options! -depforce"
	if "%-depignore%"=="1" set "_feature_options=!_feature_options! -depignore"
	
	call %STELLA_BIN%\feature.bat %ACTION% %id% !_feature_options!
	@echo off
	goto :end
	
)
if "%DOMAIN%"=="feature" goto :end

REM --------------- PROXY ----------------------------
if "%DOMAIN%"=="proxy" (
	if "%ACTION%"=="on" (
		call %STELLA_COMMON%\common-network.bat :enable_proxy "%id%"
		goto :end
	)
	if "%ACTION%"=="off" (
		call %STELLA_COMMON%\common-network.bat :disable_proxy
		goto :end
	)
	if "%ACTION%"=="register" (
		call %STELLA_COMMON%\common-network.bat :register_proxy %id% %-proxyhost% %-proxyport% %-proxyuser% %-proxypass%
		goto :end
	)
	
)
if "%DOMAIN%"=="proxy" goto :end



:usage
	echo USAGE :
	echo %~n0 %ARGOPT_HELP_SYNTAX%
	echo ----------------
	echo List of commands
	echo 	* application management :
	echo 		app init ^<application name^> [-approot=^<path^>] [-workroot=^<path^>] [-cachedir=^<path^>] [-samples]
	echo 		app get-data^|get-assets^|delete-data^|delete-assets^|update-data^|update-assets^|revert-data^|revert-assets ^<data id^|assets id^>
	echo 		app get-data-pack^|get-assets-pack^|delete-data-pack^|delete-assets-pack^|update-data-pack^|update-assets-pack^|revert-data-pack^|revert-assets-pack ^<data pack name^|assets pack name^>
	echo 		app get-feature ^<all^|feature schema^> : install all features defined in app properties file or install a matching one
	echo 		app setup-env ^<env id^|all^> : download, build, deploy and run virtual environment based on app properties
	echo		app link ^<app-path^> [-stellaroot=^<path^>] : link an app to a specific stella path
	echo	* feature management :
	echo 		feature install ^<feature schema^> [-depforce] [-depignore] : install a feature. [-depforce] will force to reinstall all dependencies. [-depignore] will ignore dependencies. schema = feature_name[#version][@arch][:binary^|source][/os_restriction][\os_exclusion]
	echo 		feature remove ^<feature schema^> : remove a feature
	echo 		feature list ^<all^|feature name^|active^>: list all available features OR available version of a feature OR current active features
	echo	* various :
	echo 		api list all : list public functions of stella api
	echo		stella install dep : install all features and systems requirements for the current OS (%STELLA_CURRENT_OS%)
	echo		stella version print : print stella version
	echo		stella search path : print current system search path
	echo	* network management :
	echo 	    proxy on ^<name^> : active this proxy
	echo 	    proxy off now : active this proxy
	echo    	proxy register ^<name^> -proxyhost=^<host^> -proxyport=^<port^> [-proxyuser=^<string^> -proxypass=^<string^>] : register this proxy
	echo 	* bootstrap management :
	echo 		boot stella shell : launch a shell with all stella env var setted
	echo		boot docker ^<docker-id^> [commands] : launch a command on a docker container with stella mounted as /stella --  need docker installed on your system

goto :end


:end
@echo ** END **
@cd /D %STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal