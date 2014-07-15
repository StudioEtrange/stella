@echo off
call %*
goto :eof


REM APP RESSOURCES & ENV MANAGEMENT ---------------

:get_data
	if not exist "%DATA_ROOT%" mkdir "%DATA_ROOT%"
	call :_get_stella_ressources "DATA" "%~1"
goto :eof

:get_assets
	if not exist "%ASSETS_ROOT%" mkdir "%ASSETS_ROOT%"
	if not exist "%ASSETS_REPOSITORY%" mkdir "%ASSETS_REPOSITORY%"
	call :_get_stella_ressources "ASSETS" "%~1"
goto :eof

:get_all_data
	get_data %STELLA_DATA_LIST%
goto :eof

:get_all_assets
	get_assets %STELLA_ASSETS_LIST%
goto :eof



:_get_stella_ressources
	set "_mode=%~1"
	set "_list_id=%~2"

	for %%A in (!_list_id!) do (
		set _opt=!"%%A"_DATA_OPTIONS!
		set _uri=!"%%A"_DATA_URI!
		set _prot=!"%%A"_DATA_GET_PROTOCOL!
		set _name=!"%%A"_DATA_NAME!
		set _main_package=!"%%A"_DATA_MAIN_PACKAGE!
		

		set _artefact_link=0
		if "%_mode%"=="DATA" (
			set "_artefact_dest=%DATA_ROOT%"
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

		echo * Get %_name% [%%A] ressources

		if "!_merge!"=="MERGE" (
			echo * Main package of [%%A] is %_main_package%
		)


		if "!_merge!"=="MERGE" (
			call %STELLA_COMMON%\common.bat :get_ressource "%_mode% : !_name! [!_main_package!]" "!_uri!" "!_prot!" "!_artefact_dest!\!_main_package!" "!_merge! !_strip!"
			echo * !_name! merged into !_main_package!
			if "%_artefact_link%"=="1" (
				if exist "%!_artefact_link_target!\!_main_package!" if "%FORCE%"=="1" rmdir "!_artefact_link_target!\!_main_package!"
				if not exist "!_artefact_link_target!\!_main_package!" (
					echo ** Make symbolic link for !_main_package!
					call %STELLA_COMMON%\common.bat :run_admin %STELLA_COMMON%\symlink.bat "!_artefact_dest!\!_main_package!" "!_artefact_link_target!\!_main_package!"
				)
			)
		) else (
			call %STELLA_COMMON%\common.bat :get_ressource "%_mode% : !_name!" "!_uri!" "!_prot!" "!_artefact_dest!\!_name!" "!_strip!"
			if "%_artefact_link%"=="1" (
				if exist "%!_artefact_link_target!\!_name!" if "%FORCE%"=="1" rmdir "!_artefact_link_target!\!_name!"
				if not exist "!_artefact_link_target!\!_name!" (
					echo ** Make symbolic link for !_name!
					call %STELLA_COMMON%\common.bat :run_admin %STELLA_COMMON%\symlink.bat "!_artefact_dest!\!_name!" "!_artefact_link_target!\!_name!"
				)
			)
		)
	)
goto :eof

:select_app_properties
	set "_app_path=%~1"

	set "PROPERTIES="

	if "%_app_path%"=="" (
		set "_app_path=%PROJECT_ROOT%"
	)


	if exist "%_app_path%\.stella" (
		set "PROPERTIES=%_app_path%\.stella"
	)
	
goto :eof

:init_app
	set "_app_name=%~1"
	set "_approot=%~2"
	set "_workroot=%~3"
	set "_cachedir=%~4"

	if not exist "%_approot%" mkdir "%_approot%"

	REM > "%_approot%\.stella-link.bat" ECHO(@setlocal enableExtensions enableDelayedExpansion
	REM >> "%_approot%\.stella-link.bat" ECHO(@echo off
	> "%_approot%\.stella-link.bat" ECHO(@set STELLA_ROOT=%STELLA_ROOT%
	REM >> "%_approot%\.stella-link.bat" ECHO(@echo on
	REM >> "%_approot%\.stella-link.bat" ECHO(@endlocal

	copy /y "%STELLA_COMMON%\stella-template.bat" "%_approot%\stella.bat"
	REM > "%_approot%\stella.bat" ECHO(@setlocal enableExtensions enableDelayedExpansion
	REM >> "%_approot%\stella.bat" ECHO(@echo off
	REM >> "%_approot%\stella.bat" ECHO(call %STELLA_ROOT%\stella.bat %%*
	REM >> "%_approot%\stella.bat" ECHO(@echo on
	REM >> "%_approot%\stella.bat" ECHO(@endlocal


	set "PROPERTIES=%_approot%\.stella"

	if exist "%PROPERTIES%" (
		echo ** Properties file already exists
	) else (

		REM call %STELLA_COMMON%\common.bat :add_key "%PROPERTIES%" "STELLA" "APP_ROOT" "%_approot%"
		call %STELLA_COMMON%\common.bat :add_key "%PROPERTIES%" "STELLA" "APP_WORK_ROOT" "%_workroot%"
		call %STELLA_COMMON%\common.bat :add_key "%PROPERTIES%" "STELLA" "CACHE_DIR" "%_cachedir%"
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
	REM call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "APP_ROOT"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "APP_WORK_ROOT"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "CACHE_DIR"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "DATA_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "ASSETS_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "ENV_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "INFRA_LIST" "PREFIX"

	REM DATA
	for %%A in (!STELLA_DATA_LIST!) do (
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_MAIN_PACKAGE "PREFIX"
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
		if not "!_artefact_infra_id!"=="default" (
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
		if not "%_env_infra_id%"=="default" (
			call %STELLA_ROOT%\virtual.bat get-box -distrib=%_env_distrib%
			call %STELLA_ROOT%\virtual.bat create-box -distrib=%_env_distrib%
			call %STELLA_ROOT%\virtual.bat create-env -distrib=%_env_distrib% -envname=%_env_name% -envcpu=%_env_cpu% -envmem=%_env_mem%
			@echo off
			echo * Now you can use your env using %STELLA_ROOT%\virtual.bat OR with Vagrant
		) else (
			echo * ENV [%%A] use default current env
		)
	)	