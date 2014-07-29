@echo off
call %*
goto :eof


REM APP RESSOURCES & ENV MANAGEMENT ---------------

:get_data
	call :_get_app_ressources "DATA" "GET" "%~1"
goto :eof

:get_assets
	if not exist "%ASSETS_ROOT%" mkdir "%ASSETS_ROOT%"
	if not exist "%ASSETS_REPOSITORY%" mkdir "%ASSETS_REPOSITORY%"
	call :_get_app_ressources "ASSETS" "GET" "%~1"
goto :eof

:update_data
	call :_get_app_ressources "DATA" "UPDATE" "%~1"
goto :eof

:update_assets
	call :_get_app_ressources "ASSETS" "UPDATE" "%~1"
goto :eof

:revert_data
	call :_get_app_ressources "DATA" "REVERT" "%~1"
goto :eof

:revert_assets
	call :_get_app_ressources "ASSETS" "REVERT" "%~1"
goto :eof

:get_all_data
	call :get_data "%STELLA_DATA_LIST%"
goto :eof

:get_all_assets
	call :get_assets "%STELLA_ASSETS_LIST%"
goto :eof


:: ARG1 ressource mode is DATA or ASSET
:: ARG2 operation is GET or UPDATE or REVERT (UPDATE or REVERT if applicable)
:: ARG3 list of ressource ID
:_get_app_ressources
	set "_mode=%~1"
	set "_operation=%~2"
	set "_list_id=%~3"

	for %%A in (!_list_id!) do (

		set "_opt=!%%A_%_mode%_OPTIONS!"
		set "_uri=!%%A_%_mode%_URI!"
		set "_prot=!%%A_%_mode%_GET_PROTOCOL!"
		set "_name=!%%A_%_mode%_NAME!"
		set "_namespace=!%%A_%_mode%_NAMESPACE!"
		
		if "!_name!"=="" (
			echo ** Error : %%A does not exist
		) else (

			set _artefact_link=0
			if "%_mode%"=="DATA" (
				set "_root=!%%A_DATA_ROOT!"
				call %STELLA_COMMON%\common.bat :rel_to_abs_path "_artefact_dest" "!_root!" "%STELLA_APP_WORK_ROOT%"
				::set "_artefact_dest=%DATA_ROOT%"
				set _artefact_link=0
			)
			if "%_mode%"=="ASSETS" (
				set "_artefact_dest=%ASSETS_REPOSITORY%"
				set _artefact_link=1
				set "_artefact_link_target=%ASSETS_ROOT%"
			)
			


			set _merge=
			set _strip=
			for %%O in (!_opt!) do (
				if "%%O"=="MERGE" set _merge=MERGE
				if "%%O"=="STRIP" set _strip=STRIP
			)

			echo * !_operation! !_name! [%%A] ressources

			if "!_merge!"=="MERGE" (
				echo * Main package of [%%A] is !_namespace!
			)


			call %STELLA_COMMON%\common.bat :get_ressource "%_mode% : !_name! [!_namespace!]" "!_uri!" "!_prot!" "!_artefact_dest!\!_namespace!" "!_merge! !_strip! !_operation!"
			if "!_merge!"=="MERGE" (
				echo * !_name! merged into !_namespace!
			)
			if "%_artefact_link%"=="1" (
				if exist "%!_artefact_link_target!\!_namespace!" if "%FORCE%"=="1" rmdir "!_artefact_link_target!\!_namespace!"
				if not exist "!_artefact_link_target!\!_namespace!" (
					echo ** Make symbolic link for !_namespace!
					call %STELLA_COMMON%\common.bat :run_admin %STELLA_COMMON%\symlink.bat "!_artefact_dest!" "!_artefact_link_target!\!_namespace!"
				)
			)
		)
	)
goto :eof

:select_app
	set "_app_path="

	set "PROPERTIES="

	if "%_app_path%"=="" (
		set "_app_path=%_CURRENT_RUNNING_DIR%"
	)


	if exist "%_app_path%\.stella" (
		set "PROPERTIES=%_app_path%\.stella"
		set "STELLA_APP_ROOT=%_app_path%"
	)
	
goto :eof

:init_app
	set "_app_name=%~1"
	set "_approot=%~2"
	set "_workroot=%~3"
	set "_cachedir=%~4"

	call %STELLA_COMMON%\common.bat :rel_to_abs_path "_approot" "%_approot%" "%_CURRENT_RUNNING_DIR%"
	if not exist "%_approot%" mkdir "%_approot%"


	call %STELLA_COMMON%\common.bat :abs_to_rel_path "_STELLA_ROOT" "%STELLA_ROOT%" "%_approot%"
	> "%_approot%\.stella-link.bat" ECHO(@set _STELLA_CURRENT_FILE_DIR=%%~dp0
	>> "%_approot%\.stella-link.bat" ECHO(@set _STELLA_CURRENT_FILE_DIR=%%_STELLA_CURRENT_FILE_DIR:~0,-1%%
	>> "%_approot%\.stella-link.bat" ECHO(@set STELLA_ROOT=%%_STELLA_CURRENT_FILE_DIR%%\%_STELLA_ROOT%

	copy /y "%STELLA_POOL%\stella-template.bat" "%_approot%\stella.bat"

	copy /y "%STELLA_POOL%\example-app.bat" "%_approot%\example-app.bat"

	copy /y "%STELLA_ROOT%\example-app-properties.stella" "%_approot%\example-app-properties.stella"

	set "PROPERTIES=%_approot%\.stella"
	if exist "%PROPERTIES%" (
		echo ** Properties file already exists
	) else (
		call %STELLA_COMMON%\common.bat :add_key "%PROPERTIES%" "STELLA" "APP_NAME" "%_app_name%"
		call %STELLA_COMMON%\common.bat :add_key "%PROPERTIES%" "STELLA" "APP_WORK_ROOT" "%_workroot%"
		call %STELLA_COMMON%\common.bat :add_key "%PROPERTIES%" "STELLA" "APP_CACHE_DIR" "%_cachedir%"
		call %STELLA_COMMON%\common.bat :add_key "%PROPERTIES%" "STELLA" "DATA_LIST" ""
		call %STELLA_COMMON%\common.bat :add_key "%PROPERTIES%" "STELLA" "ASSETS_LIST" ""
		call %STELLA_COMMON%\common.bat :add_key "%PROPERTIES%" "STELLA" "ENV_LIST" ""
		call %STELLA_COMMON%\common.bat :add_key "%PROPERTIES%" "STELLA" "INFRA_LIST" ""
	)
goto :eof


:: extract properties
:get_all_properties

	if not exist "%PROPERTIES%" (
		goto :eof
	)

	REM STELLA VARs
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "APP_NAME"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "APP_WORK_ROOT" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "APP_CACHE_DIR" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "DATA_LIST" "PREFIX" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "ASSETS_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "ENV_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "INFRA_LIST" "PREFIX"

	REM DATA
	for %%A in (!STELLA_DATA_LIST!) do (
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_NAMESPACE "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_ROOT "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_OPTIONS "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_URI "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_GET_PROTOCOL "PREFIX"
	)

	REM ASSETS
	for %%A in (!STELLA_ASSETS_LIST!) do (
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ASSETS_MAIN_PACKAGE "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ASSETS_OPTIONS "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ASSETS_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ASSETS_URI "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ASSETS_GET_PROTOCOL "PREFIX"
	)

	REM ENV
	for %%A in (!STELLA_ENV_LIST!) do (
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ENV_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" INFRA_ID "PREFIX"
	)
	
	REM INFRA
	for %%A in (!STELLA_INFRA_LIST!) do (
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" INFRA_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" INFRA_DISTRIB "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" INFRA_CPU "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" INFRA_MEM "PREFIX"
	)

	REM INFRA-ENV
	for %%A in (!STELLA_ENV_LIST!) do (
		set "_artefact_infra_id=!%%A_INFRA_ID!"
		if not "!_artefact_infra_id!"=="current" (
			set _artefact_distrib=!_artefact_infra_id!_INFRA_DISTRIB
			for %%Z in (!_artefact_distrib!) do (
				set "%%A_DISTRIB=!%%Z!"
			)
			set _artefact_mem=!_artefact_infra_id!_INFRA_MEM
			for %%Z in (!_artefact_mem!) do (
				set "%%A_MEM=!%%Z!"
			)
			set _artefact_cpu=!_artefact_infra_id!_INFRA_CPU
			for %%Z in (!_artefact_cpu!) do (
				set "%%A_CPU=!%%Z!"
			)

			call %STELLA_COMMON%\platform.bat :get_os_from_distro "%%A_OS" "!%%A_DISTRIB!"
			call %STELLA_COMMON%\platform.bat :get_platform_from_os "%%A_PLATFORM" "!%%A_OS!"
			call %STELLA_COMMON%\platform.bat :get_platform_suffix "%%A_PLATFORM_SUFFIX" "!%%A_PLATFORM!"
		) else (
			set "%%A_OS=%STELLA_CURRENT_OS%"
			set "%%A_PLATFORM=%STELLA_CURRENT_PLATFORM%"
			set "%%A_PLATFORM_SUFFIX=%STELLA_CURRENT_PLATFORM_SUFFIX%"
		)
	)
goto :eof

:setup_all_env
	call :setup_env "%STELLA_ENV_LIST%"
goto :eof

:setup_env
	set "_list_id=%~1"

	for %%A in (%_list_id%) do (
		set "_env_infra_id=!%%A_INFRA_ID!"
		set "_env_distrib=!%%A_DISTRIB!"
		set "_env_os=!%%A_OS!"
		set "_env_name=!%%A_ENV_NAME!"
		set "_env_cpu=!%%A_CPU!"
		set "_env_mem=!%%A_MEM!"

		
		if not "!_env_infra_id!"=="current" (
			echo * Setting up env '!_env_name! [%%A]' with infra '[!_env_infra_id!]' - using !_env_cpu! cpu and !_env_mem! Mo - built with '!_env_distrib!', a !_env_os! operating system
			
			call %STELLA_ROOT%\virtual.bat get-box -distrib=!_env_distrib!
			call %STELLA_ROOT%\virtual.bat create-box -distrib=!_env_distrib!
			call %STELLA_ROOT%\virtual.bat create-env -distrib=!_env_distrib! -envname=%%A -envcpu=!_env_cpu! -envmem=!_env_mem!
			@echo off
			echo * Now you can use your env using %STELLA_ROOT%\virtual.bat OR with Vagrant
		) else (
			echo * Env '!_env_name! [%%A]' is the default current system
		)
	)	