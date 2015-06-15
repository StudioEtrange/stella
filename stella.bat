@setlocal enableExtensions enableDelayedExpansion
@echo off

call %~dp0\conf.bat



:: arguments
set "params=domain:"app feature virtual stella proxy" action:"version on off register search remove link bootstrap api install init get-data get-assets get-data-pack get-assets-pack delete-data delete-data-pack delete-assets delete-assets-pack update-data update-assets revert-data revert-assets update-data-pack update-assets-pack revert-data-pack revert-assets-pack get-feature setup-env install list create-env run-env stop-env destroy-env info-env create-box get-box" id:"_ANY_""
set "options=-f: -vcpu:_ANY_ -vmem:_ANY_ -head: -login: -approot:_ANY_ -workroot:_ANY_ -cachedir:_ANY_ -stellaroot:_ANY_ -samples: -proxyhost:_ANY_ -proxyport:_ANY_ -proxyuser:_ANY_ -proxypass:_ANY_"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

::set ARCH=%-arch%
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
			call %STELLA_COMMON%\platform.bat :__stella_requirement
			goto :end
		)
	)

	if "%ACTION%"=="bootstrap" (
		if "%id%"=="env" (
			call %STELLA_COMMON%\common.bat :bootstrap_stella_env
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
if "%DOMAIN%"=="api" goto :end


REM --------------- FEATURE ----------------------------
if "%DOMAIN%"=="feature" (
	set "_feature_options="
	if "%-f%"=="1" set "_feature_options=!_feature_options! -f"
	
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


REM --------------- VIRTUAL ----------------------------
if "%DOMAIN%"=="virtual" (
	set "_virtual_options="
	if not "%-vcpu%"=="" set "_virtual_options=!_virtual_options! -vcpu=%-vcpu%"
	if not "%-vmem%"=="" set "_virtual_options=!_virtual_options! -vmem=%-vmem%"
	if "%-head%"=="1" set "_virtual_options=!_virtual_options! -head"
	if "%-login%"=="1" set "_virtual_options=!_virtual_options! -login"

	if "%-f%"=="1" set "_virtual_options=!_virtual_options! -f"
	
	call %STELLA_BIN%\virtual.bat %ACTION% %id% !_virtual_options!
	@echo off
	goto :end
)
if "%DOMAIN%"=="virtual" goto :end



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
	echo 		feature install required : install required features for Stella
	echo 		feature install ^<feature schema^> : install a feature. schema = feature_name[#version][@arch][:binary^|source][/os_restriction][\os_exclusion]
	echo 		feature remove ^<feature schema^> : remove a feature
	echo 		feature list ^<all^|feature name^|active^>: list all available features OR available version of a feature OR current active features
	echo	* virtual management :
	echo 		virtual create-env ^<env id#distrib id^> [-head] [-vmem=xxxx] [-vcpu=xx] : create a new environment from a generic box prebuilt with a specific distribution
	echo		virtual run-env ^<env id^> [-login] : manage environment
	echo		virtual stop-env^|destroy-env ^<env id^> : manage environment
	echo 		virtual create-box^|get-box ^<distrib id^> : manage generic boxes built with a specific distribution
	echo 		virtual list ^<box^|env^|distrib^>
	echo	* various :
	echo 		api list all : list public functions of stella api
	echo		stella bootstrap env : launch a shell with all stella env var setted
	echo		stella install dep : install all features and systems requirements for the current OS (%STELLA_CURRENT_OS%)
	echo		stella version print : print stella version
	echo		stella search path : print current system search path
	echo	* network management :
	echo 	    proxy on ^<name^> : active this proxy
	echo 	    proxy off now : active this proxy
	echo    	proxy register ^<name^> -proxyhost=^<host^> -proxyport=^<port^> [-proxyuser=^<string^> -proxypass=^<string^>] : register this proxy
goto :end


:end
@echo ** END **
@cd /D %STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal