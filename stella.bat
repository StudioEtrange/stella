@setlocal enableExtensions enableDelayedExpansion
@echo off

call %~dp0\conf.bat

:: arguments
set "params=domain:"app feature stella proxy boot sys" action:"bypass version on off register search remove link api install init get-data get-assets get-data-pack get-assets-pack delete-data delete-data-pack delete-assets delete-assets-pack update-data update-assets revert-data revert-assets update-data-pack update-assets-pack revert-data-pack revert-assets-pack get-feature install list shell" id:"_ANY_""
set "options=-f: -buildarch:"x86 x64" -approot:_ANY_ -workroot:_ANY_ -cachedir:_ANY_ -stellaroot:_ANY_ -samples: -proxy:_ANY_ -depforce: -depignore: -export:_ANY_ -portable:_ANY_"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set FORCE=%-f%


REM --------------- APP ----------------------------
if "%DOMAIN%"=="app" (
	call %STELLA_COMMON%\common.bat :init_stella_env
	
	if "%ACTION%"=="init" (	
		if "%-approot%"=="" (
			set "-approot=%STELLA_CURRENT_RUNNING_DIR%\%id%"
		)
		if "%-workroot%"=="" (
			set "-workroot=!-approot!\workspace"
		)
		if "%-cachedir%"=="" (
			set "-cachedir=!-approot!\cache"
		)

		call %STELLA_COMMON%\common-app :init_app "%id%" "!-approot!" "!-workroot!" "!-cachedir!"
		if "%-samples%"=="1" (
			call %STELLA_COMMON%\common-app :create_app_samples "!-approot!"
			goto :end
		)
	)

	if "%ACTION%"=="link" (
		call %STELLA_COMMON%\common-app.bat :link_app "%id%" "STELLA_ROOT !-stellaroot!"
		goto :end
	)

	if not "%ACTION%"=="init" if not "%ACTION%"=="link" (
		if not exist "%_STELLA_APP_PROPERTIES_FILE%" (
			echo ** ERROR properties file does not exist
			goto :end
		)
	)

	if "%ACTION%"=="get-feature" (
		if "%id%"=="all" (
			call %STELLA_COMMON%\common-app.bat :get_features
		) else (
			call %STELLA_COMMON%\common-app.bat :get_feature "%id%"
		)
		goto :end
	)
	if "%ACTION%"=="get-data" (
		call %STELLA_COMMON%\common-app.bat :get_data "%id%"
		goto :end
	)
	if "%ACTION%"=="get-data-pack" (
		call %STELLA_COMMON%\common-app.bat :get_data_pack "%id%"
		goto :end
	)
	if "%ACTION%"=="get-assets" (
		call %STELLA_COMMON%\common-app.bat :get_assets "%id%"
		goto :end
	)
	if "%ACTION%"=="get-assets-pack" (
		call %STELLA_COMMON%\common-app.bat :get_assets_pack "%id%"
		goto :end
	)
	if "%ACTION%"=="delete-data" (
		call %STELLA_COMMON%\common-app.bat :delete_data "%id%"
		goto :end
	)
	if "%ACTION%"=="delete-assets" (
		call %STELLA_COMMON%\common-app.bat :delete_assets "%id%"
		goto :end
	)
	if "%ACTION%"=="delete-data-pack" (
		call %STELLA_COMMON%\common-app.bat :delete_data_pack "%id%"
		goto :end
	)
	if "%ACTION%"=="delete-assets-pack" (
		call %STELLA_COMMON%\common-app.bat :delete_assets_pack "%id%"
		goto :end
	)
	if "%ACTION%"=="update-data" (
		call %STELLA_COMMON%\common-app.bat :update_data "%id%"
		goto :end
	)
	if "%ACTION%"=="update-assets" (
		call %STELLA_COMMON%\common-app.bat :update_assets "%id%"
		goto :end
	)
	if "%ACTION%"=="revert-data" (
		call %STELLA_COMMON%\common-app.bat :revert_data "%id%"
		goto :end
	)
	if "%ACTION%"=="revert-assets" (
		call %STELLA_COMMON%\common-app.bat :revert_assets "%id%"
		goto :end
	)
)
if "%DOMAIN%"=="app" goto :end


REM --------------- FEATURE ----------------------------
if "%DOMAIN%"=="feature" (
	call %STELLA_COMMON%\common.bat :init_stella_env

	if "%ACTION%"=="install" (
		set "_feature_options="
		if not "%-buildarch%"=="" (
			call %STELLA_COMMON%\common-build.bat :set_build_mode_default "ARCH" "%-buildarch%"
		)
		if "%-depforce%"=="1" set "_feature_options=!_feature_options! DEP_FORCE"
		if "%-depignore%"=="1" set "_feature_options=!_feature_options! DEP_IGNORE"
		
		if not "%-export%"=="" set "_feature_options=!_feature_options! EXPORT !-export!"
		if not "%-portable%"=="" set "_feature_options=!_feature_options! PORTABLE !-portable!"


		call %STELLA_COMMON%\common-feature.bat :feature_install %id% "!_feature_options!"
		goto :end
	)

	if "%ACTION%"=="remove" (
		call %STELLA_COMMON%\common-feature.bat :feature_remove %id%
		goto :end
	)


	if "%ACTION%"=="list" (
		if "%id%"=="all" (
			echo all %__STELLA_FEATURE_LIST%
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

)
if "%DOMAIN%"=="feature" goto :end

REM --------------- SYS ----------------------------
if "%DOMAIN%"=="sys" (
	call %STELLA_COMMON%\common.bat :init_stella_env

	if "%ACTION%"=="install" (
		call %STELLA_COMMON%\common-platform.bat :sys_install "%id%"
		goto :end
	)
	if "%ACTION%"=="remove" (
		call %STELLA_COMMON%\common-platform.bat :sys_remove "%id%"
		goto :end
	)
	if "%ACTION%"=="list" (
		echo !STELLA_SYS_PACKAGE_LIST!
		goto :end
	)
)
if "%DOMAIN%"=="sys" goto :end



REM --------------- BOOT ----------------------------
if "%DOMAIN%"=="boot" (
	call %STELLA_COMMON%\common.bat :init_stella_env

	if "%ACTION%"=="shell" (
		if "%id%"=="local" (
			call %STELLA_COMMON%\common.bat :bootstrap_stella_env
			goto :end
		)
	)
	
)
if "%DOMAIN%"=="boot" goto :end

REM --------------- PROXY ----------------------------
if "%DOMAIN%"=="proxy" (
	call %STELLA_COMMON%\common.bat :init_stella_env

	if "%ACTION%"=="on" (
		call %STELLA_COMMON%\common-network.bat :enable_proxy "%id%"
		goto :end
	)
	if "%ACTION%"=="off" (
		call %STELLA_COMMON%\common-network.bat :disable_proxy
		goto :end
	)
	if "%ACTION%"=="bypass" (
		call %STELLA_COMMON%\common-network.bat :register_no_proxy "%id%"
		goto :end
	)
	if "%ACTION%"=="register" (
		call %STELLA_COMMON%\common-network.bat :register_proxy %id% %-proxy%
		goto :end
	)
	if "%ACTION%"=="list" (
		call %STELLA_COMMON%\common-network.bat :show_current_proxy_values
		goto :end
	)

)
if "%DOMAIN%"=="proxy" goto :end



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





:usage
	echo USAGE :
	echo %~n0 %ARGOPT_HELP_SYNTAX%
	echo ----------------
	echo List of commands
	echo	* application management :
	echo 		app init ^<application name^> [-approot=^<path^>] [-workroot=^<path^>] [-cachedir=^<path^>] [-samples]
	echo 		app get-data^|get-assets^|delete-data^|delete-assets^|update-data^|update-assets^|revert-data^|revert-assets ^<data id^|assets id^>
	echo 		app get-data-pack^|get-assets-pack^|delete-data-pack^|delete-assets-pack^|update-data-pack^|update-assets-pack^|revert-data-pack^|revert-assets-pack ^<data pack name^|assets pack name^>
	echo 		app get-feature ^<all^|feature schema^> : install all features defined in app properties file or install a matching one
	echo 		app link ^<app-path^> [-stellaroot=^<path^>] : link an app to a specific stella path
	echo	* feature management :
	echo 		feature install ^<feature schema^> [-depforce] [-depignore] [-buildarch=x86^|x64] [-export=^<path^>] [-portable=^<path^>] : install a feature. [-depforce] will force to reinstall all dependencies. [-depignore] will ignore dependencies. schema = feature_name[#version][@arch][:binary^|source][/os_restriction][\os_exclusion]
	echo 		feature remove ^<feature schema^> : remove a feature
	echo 		feature list ^<all^|feature name^|active^>: list all available features OR available version of a feature OR current active features
	echo	* various :
	echo 		api list all : list public functions of stella api
	echo 		stella install dep : install all features and systems requirements for the current OS (%STELLA_CURRENT_OS%)
	echo 		stella version print : print stella version
	echo 		stella search path : print current system search path
	echo	* network management :
	echo 		proxy on ^<name^> : active this proxy
	echo 		proxy off now : active this proxy
	echo 		proxy register ^<name^> -proxy=^<protocol://user:password@host:port^> : register a web proxy
	echo 		proxy bypass ^<host^> : register a host that will not use proxy
	echo		proxy list all : show all current proxy information
	echo	* bootstrap management :
	echo 		boot shell local : launch a shell with all stella env var setted
	echo	* system package management : WARN This will affect your system
	echo 		sys install ^<package name^> : install  a system package
	echo 		sys remove ^<package name^> : remove a system package
	echo 		sys list all : list all available system package name
goto :end


:end
@echo ** END **
@cd /D %STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal
