@echo off
call %*
goto :eof


REM APP RESSOURCES & ENV MANAGEMENT ---------------


:get_active_path
	set "%~1=!PATH!"
goto:eof

:add_app_feature
	set "_SCHEMA=%~1"
	call :app_feature "ADD" "!_SCHEMA!"
goto :eof

:remove_app_feature
	set "_SCHEMA=%~1"
	call :app_feature "REMOVE" "!_SCHEMA!"
goto :eof

:app_feature
	set "_MODE=%~1"
	set "_SCHEMA=%~2"
	set "_app_feature_list="

	call %STELLA_COMMON%\common-feature.bat :translate_schema "!_SCHEMA!" "_TR_FEATURE_NAME" "_TR_FEATURE_VER" "_TR_FEATURE_ARCH" "_TR_FEATURE_FLAVOUR" "_TR_FEATURE_OS_RESTRICTION" "_TR_FEATURE_OS_EXCLUSION"

	set _flag_add_app_feature=0
	if exist "%_STELLA_APP_PROPERTIES_FILE%" (
		if "!STELLA_APP_FEATURE_LIST!"=="" (
			if "%_MODE%"=="ADD" set "_app_feature_list=!_app_feature_list! !_SCHEMA!"
		) else (
			REM scan if feature exist in app feature list
			for %%F in (!STELLA_APP_FEATURE_LIST!) do (
				
				call %STELLA_COMMON%\common-feature.bat :translate_schema "%%F" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	
				if "!_TR_FEATURE_OS_EXCLUSION!"=="!TR_FEATURE_OS_EXCLUSION!" (
					if "!_TR_FEATURE_OS_RESTRICTION!"=="!TR_FEATURE_OS_RESTRICTION!" (
						if "!_TR_FEATURE_VER!"=="!TR_FEATURE_VER!" (
							if "!_TR_FEATURE_NAME!"=="!TR_FEATURE_NAME!" (
								if "!_TR_FEATURE_ARCH!"=="!TR_FEATURE_ARCH!" (
									if "!_TR_FEATURE_FLAVOUR!"=="!TR_FEATURE_FLAVOUR!" (
										set _flag_add_app_feature=1
									)
								)
							)
						)
					)
				)
				if "%_MODE%"=="REMOVE" (
					if not "!_flag_add_app_feature!"=="1" (
						set "_app_feature_list=!_app_feature_list! %%F"
					)
					set _flag_add_app_feature=0
				)
				if "%_MODE%"=="ADD" (
					set "_app_feature_list=!_app_feature_list! %%F"
				)
			)

			if "%_MODE%"=="ADD" (
				REM This is a new feature
				if "!_flag_add_app_feature!"=="0" (
					set "_app_feature_list=!_app_feature_list! !_SCHEMA!"
				)
			)
		)

		

		call %STELLA_COMMON%\common.bat :trim "_app_feature_list" "!_app_feature_list!"
		call %STELLA_COMMON%\common.bat :trim "STELLA_APP_FEATURE_LIST" "!STELLA_APP_FEATURE_LIST!"

		if not "!STELLA_APP_FEATURE_LIST!"=="!_app_feature_list!" (
			call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "APP_FEATURE_LIST" "!_app_feature_list!"
			REM refresh value
			set "STELLA_APP_FEATURE_LIST=!_app_feature_list!"
		)
	)
goto :eof

REM instal all features listed in app feature list.
:get_features
	call %STELLA_COMMON%\common-feature.bat :feature_install_list "!STELLA_APP_FEATURE_LIST!"
goto :eof

REM install a feature listed in app feature list. Look for matching version in app feature list, so could match several version
:get_feature
	set "_SCHEMA=%~1"

	call %STELLA_COMMON%\common-feature.bat :translate_schema "!_SCHEMA!" "_TR_FEATURE_NAME" "_TR_FEATURE_VER" "_TR_FEATURE_ARCH" "_TR_FEATURE_FLAVOUR"  "_TR_FEATURE_OS_RESTRICTION" "_TR_FEATURE_OS_EXCLUSION"
	
	set _flag_get_feature=1

	if not "!STELLA_APP_FEATURE_LIST!"=="" (
		for %%F in (!STELLA_APP_FEATURE_LIST!) do (
			
			call %STELLA_COMMON%\common-feature.bat :translate_schema "%%F" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR"  "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
			
			set _flag_get_feature=1
			if not "%_TR_FEATURE_NAME%"=="%TR_FEATURE_NAME%" (
				set _flag_get_feature=0
			)
			if not "%_TR_FEATURE_FLAVOUR%"=="" (
				if not "%_TR_FEATURE_FLAVOUR%"=="%TR_FEATURE_FLAVOUR%" (
					set _flag_get_feature=0
				)
			)
			if not "%_TR_FEATURE_ARCH%"=="" (
				if not "%_TR_FEATURE_ARCH%"=="%TR_FEATURE_ARCH%" (
					set _flag_get_feature=0
				)
			)
			if not "%_TR_FEATURE_VER%"=="" (
				if not "%_TR_FEATURE_VER%"=="%TR_FEATURE_VER%" (
					set _flag_get_feature=0
				)
			)

			if "!_flag_get_feature!"=="1" (
				call %STELLA_COMMON%\common-feature.bat :feature_install "%%F"
			)
		)
	)

goto :eof

REM get a list of data id
:get_data
	call :_app_resources "DATA" "GET" "%~1"
goto :eof

REM get a list of assets id
:get_assets
	if not exist "%ASSETS_ROOT%" mkdir "%ASSETS_ROOT%"
	if not exist "%ASSETS_REPOSITORY%" mkdir "%ASSETS_REPOSITORY%"
	call :_app_resources "ASSETS" "GET" "%~1"
goto :eof

:update_data
	call :_app_resources "DATA" "UPDATE" "%~1"
goto :eof

:update_assets
	call :_app_resources "ASSETS" "UPDATE" "%~1"
goto :eof

:revert_data
	call :_app_resources "DATA" "REVERT" "%~1"
goto :eof

:revert_assets
	call :_app_resources "ASSETS" "REVERT" "%~1"
goto :eof

:delete_data
	call :_app_resources "DATA" "DELETE" "%~1"
goto :eof

:delete_assets
	call :_app_resources "ASSETS" "DELETE" "%~1"
goto :eof


:get_data_pack
	set "_list_name=%~1"

	call %STELLA_COMMON%\common.bat :get_key "!_STELLA_APP_PROPERTIES_FILE!" "STELLA" "!_list_name!" ""

	for /F %%a in ('echo !_list_name!') do set "_list_pack=!%%a!"
	call :get_data "!_list_pack!"
goto:eof

:get_assets_pack
	set "_list_name=%~1"
	call %STELLA_COMMON%\common.bat :get_key "!_STELLA_APP_PROPERTIES_FILE!" "STELLA" "!_list_name!" ""
	
	for /F %%a in ('echo !_list_name!') do set "_list_pack=!%%a!"
	call :get_assets "!_list_pack!"
goto:eof

:delete_data_pack
	set "_list_name=%~1"

	call %STELLA_COMMON%\common.bat :get_key "!_STELLA_APP_PROPERTIES_FILE!" "STELLA" "!_list_name!" ""

	for /F %%a in ('echo !_list_name!') do set "_list_pack=!%%a!"
	call :delete_data "!_list_pack!"
goto:eof

:delete_assets_pack
	set "_list_name=%~1"
	call %STELLA_COMMON%\common.bat :get_key "!_STELLA_APP_PROPERTIES_FILE!" "STELLA" "!_list_name!" ""
	
	for /F %%a in ('echo !_list_name!') do set "_list_pack=!%%a!"
	call :delete_assets "!_list_pack!"
goto:eof


:update_data_pack
	set "_list_name=%~1"

	call %STELLA_COMMON%\common.bat :get_key "!_STELLA_APP_PROPERTIES_FILE!" "STELLA" "!_list_name!" ""

	for /F %%a in ('echo !_list_name!') do set "_list_pack=!%%a!"
	call :update_data "!_list_pack!"
goto:eof

:update_assets_pack
	set "_list_name=%~1"
	call %STELLA_COMMON%\common.bat :get_key "!_STELLA_APP_PROPERTIES_FILE!" "STELLA" "!_list_name!" ""
	
	for /F %%a in ('echo !_list_name!') do set "_list_pack=!%%a!"
	call :update_assets "!_list_pack!"
goto:eof

:revert_data_pack
	set "_list_name=%~1"

	call %STELLA_COMMON%\common.bat :get_key "!_STELLA_APP_PROPERTIES_FILE!" "STELLA" "!_list_name!" ""

	for /F %%a in ('echo !_list_name!') do set "_list_pack=!%%a!"
	call :revert_data "!_list_pack!"
goto:eof

:revert_assets_pack
	set "_list_name=%~1"
	call %STELLA_COMMON%\common.bat :get_key "!_STELLA_APP_PROPERTIES_FILE!" "STELLA" "!_list_name!" ""
	
	for /F %%a in ('echo !_list_name!') do set "_list_pack=!%%a!"
	call :revert_assets "!_list_pack!"
goto:eof



:: ARG1 resource mode is DATA or ASSET
:: ARG2 operation is GET or UPDATE or REVERT or DELETE (UPDATE or REVERT if applicable)
:: ARG3 list of resource ID
:_app_resources
	set "_mode=%~1"
	set "_operation=%~2"
	set "_list_id=%~3"

	if "%_mode%"=="DATA" (
		call :get_data_properties "!_STELLA_APP_PROPERTIES_FILE!" "%_list_id%"
	)
	if "%_mode%"=="ASSETS" (
		call :get_assets_properties "!_STELLA_APP_PROPERTIES_FILE!" "%_list_id%"
	)

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
			for %%O in (!_opt!) do (
				if "%%O"=="MERGE" set _merge=MERGE
			)

			echo * !_operation! !_name! [%%A] resources

			if "!_merge!"=="MERGE" (
				echo * Main package of [%%A] is !_namespace!
			)


			call %STELLA_COMMON%\common.bat :resource "%_mode% : !_name! [!_namespace!]" "!_uri!" "!_prot!" "!_artefact_dest!\!_namespace!" "!_opt! !_operation!"

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

:: ARG 1 Return properties file path
:: ARG 2 optional : specify an app path
:select_app
	set "_app_path=%~2"

	set "_properties_file="

	if "%_app_path%"=="" (
		set "_app_path=%STELLA_CURRENT_RUNNING_DIR%"
	)


	if exist "%_app_path%\%STELLA_APP_PROPERTIES_FILENAME%" (
		set "_properties_file=%_app_path%\%STELLA_APP_PROPERTIES_FILENAME%"
		REM set "STELLA_APP_ROOT=%_app_path%"
	)
	
	set "%~1=!_properties_file!"
goto :eof


:create_app_samples
	set "_approot=%~1"

	copy /y "%STELLA_TEMPLATE%\sample-app.bat" "%_approot%\sample-app.bat"
	copy /y "%STELLA_TEMPLATE%\sample-stella.properties" "%_approot%\sample-stella.properties"

goto :eof

:link_app
	set "_approot=%~1"
	set "_stella_root=%~2"

	if "!_stella_root!" == "" {
		set "_stella_root=%STELLA_ROOT%"
	} 

	call %STELLA_COMMON%\common.bat :rel_to_abs_path "_approot" "!_approot!" "%STELLA_CURRENT_RUNNING_DIR%"

	call %STELLA_COMMON%\common.bat :is_path_abs "IS_ABS" "%_stella_root%"
	if "%IS_ABS%"=="FALSE" (
		call %STELLA_COMMON%\common.bat :rel_to_abs_path "_stella_root" "%_stella_root%" "%_approot%"
	)
	call %STELLA_COMMON%\common.bat :abs_to_rel_path "_stella_root" "%_stella_root%" "%_approot%"

	call %STELLA_COMMON%\common.bat :get_stella_version "_s_ver" "LONG" "!_stella_root!"
	set "_s_flavour=OFFICIAL"
	if exist "!_stella_root!\.git" set "_s_flavour=GIT"

	> "!_approot!\stella-link.bat.temp" ECHO(@if not "%%~1"=="include" if not "%%~1"=="chaining" if not "%%~1"=="nothing" setlocal enableExtensions enableDelayedExpansion
	>> "!_approot!\stella-link.bat.temp" ECHO(@set _STELLA_LINK_CURRENT_FILE_DIR=%%~dp0
	>> "!_approot!\stella-link.bat.temp" ECHO(@set _STELLA_LINK_CURRENT_FILE_DIR=%%_STELLA_LINK_CURRENT_FILE_DIR:~0,-1%%
	>> "!_approot!\stella-link.bat.temp" ECHO(@set STELLA_ROOT=%%_STELLA_LINK_CURRENT_FILE_DIR%%\!_stella_root!
	>> "!_approot!\stella-link.bat.temp" ECHO(@set STELLA_DEP_FLAVOUR=!_s_flavour!
	>> "!_approot!\stella-link.bat.temp" ECHO(@set STELLA_DEP_VERSION=!_s_ver!

	copy /b "!_approot!\stella-link.bat.temp"+"%STELLA_TEMPLATE%\sample-stella-link.bat" "!_approot!\stella-link.bat"

	del /f /q "!_approot!\stella-link.bat.temp" >nul

goto :eof

:init_app
	set "_app_name=%~1"
	set "_approot=%~2"
	set "_workroot=%~3"
	set "_cachedir=%~4"

	call %STELLA_COMMON%\common.bat :rel_to_abs_path "_approot" "!_approot!" "%STELLA_CURRENT_RUNNING_DIR%"
	if not exist "!_approot!" mkdir "!_approot!"


	if "!_workroot!" == "" (
    	set _workroot=!_approot!\workspace
    )
  	if "!_cachedir!" == "" (
  		set _cachedir=!_approot!\cache
  	)

	call %STELLA_COMMON%\common.bat :is_path_abs "IS_ABS" "!_workroot!"
	if "%IS_ABS%"=="FALSE" (
		call %STELLA_COMMON%\common.bat :rel_to_abs_path "_workroot" "!_workroot!" "!_approot!"
	)
	call %STELLA_COMMON%\common.bat :is_path_abs "IS_ABS" "!_cachedir!"
	if "%IS_ABS%"=="FALSE" (
		call %STELLA_COMMON%\common.bat :rel_to_abs_path "_cachedir" "!_cachedir!" "!_approot!"
	)
	call %STELLA_COMMON%\common.bat :is_path_abs "IS_ABS" "%STELLA_ROOT%"
	if "%IS_ABS%"=="FALSE" (
		call %STELLA_COMMON%\common.bat :rel_to_abs_path "_stella_root" "%STELLA_ROOT%" "!_approot!"
	)

	call %STELLA_COMMON%\common.bat :abs_to_rel_path "_workroot" "!_workroot!" "!_approot!"
	call %STELLA_COMMON%\common.bat :abs_to_rel_path "_cachedir" "!_cachedir!" "!_approot!"
	call %STELLA_COMMON%\common.bat :abs_to_rel_path "_stella_root" "%STELLA_ROOT%" "!_approot!"

	call %STELLA_COMMON%\common.bat :get_stella_version "_s_ver" "LONG" "%STELLA_ROOT%"
	set "_s_flavour=OFFICIAL"
	if exist "!_stella_root!\.git" set "_s_flavour=GIT"

	> "!_approot!\stella-link.bat.temp" ECHO(@if not "%%~1"=="include" if not "%%~1"=="chaining" if not "%%~1"=="nothing" setlocal enableExtensions enableDelayedExpansion
	>> "!_approot!\stella-link.bat.temp" ECHO(@set _STELLA_LINK_CURRENT_FILE_DIR=%%~dp0
	>> "!_approot!\stella-link.bat.temp" ECHO(@set _STELLA_LINK_CURRENT_FILE_DIR=%%_STELLA_LINK_CURRENT_FILE_DIR:~0,-1%%
	>> "!_approot!\stella-link.bat.temp" ECHO(@set STELLA_ROOT=%%_STELLA_LINK_CURRENT_FILE_DIR%%\!_stella_root!
	>> "!_approot!\stella-link.bat.temp" ECHO(@set STELLA_DEP_FLAVOUR=!_s_flavour!
	>> "!_approot!\stella-link.bat.temp" ECHO(@set STELLA_DEP_VERSION=!_s_ver!

	copy /b "!_approot!\stella-link.bat.temp"+"%STELLA_TEMPLATE%\sample-stella-link.bat" "!_approot!\stella-link.bat"

	del /f /q "!_approot!\stella-link.bat.temp" >nul

	set "_STELLA_APP_PROPERTIES_FILE=!_approot!\%STELLA_APP_PROPERTIES_FILENAME%"
	if exist "%_STELLA_APP_PROPERTIES_FILE%" (
		echo ** Properties file already exists
	) else (
		call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "APP_NAME" "!_app_name!"
		call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "APP_WORK_ROOT" "!_workroot!"
		call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "APP_CACHE_DIR" "!_cachedir!"
		REM call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "DATA_LIST" ""
		REM call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "ASSETS_LIST" ""
		call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "ENV_LIST" ""
		call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "INFRA_LIST" ""
		call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "APP_FEATURE_LIST" ""
	)
goto :eof


:: extract properties
:get_all_properties
	set "_properties_file=%~1"

	if not exist "%_properties_file%" (
		goto :eof
	)

	REM STELLA VARs
	call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "APP_NAME" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "APP_WORK_ROOT" "PREFIX"

	REM so that nested stella application will use the same cache folder
	if "!STELLA_APP_CACHE_DIR!"=="" (
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "APP_CACHE_DIR" "PREFIX"
	)

	call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "APP_CACHE_DIR" "PREFIX"
	REM call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "DATA_LIST" "PREFIX"
	REM call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "ASSETS_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "ENV_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "INFRA_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "APP_FEATURE_LIST" "PREFIX"

	REM call :get_data_properties "%_properties_file%" "!STELLA_DATA_LIST!"
	REM call :get_assets_properties "%_properties_file%" "!STELLA_ASSETS_LIST!"
	call :get_infra_properties "%_properties_file%" "!STELLA_INFRA_LIST!"
	call :get_env_properties "%_properties_file%" "!STELLA_ENV_LIST!"

goto :eof

:get_data_properties
	set "_properties_file=%~1"
	set "_data_list=%~2"

	if not exist "%_properties_file%" (
		goto :eof
	)

	REM DATA
	for %%A in (!_data_list!) do (
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" DATA_NAMESPACE "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" DATA_ROOT "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" DATA_OPTIONS "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" DATA_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" DATA_URI "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" DATA_GET_PROTOCOL "PREFIX"
	)
goto :eof

:get_assets_properties
	set "_properties_file=%~1"
	set "_assets_list=%~2"

	if not exist "%_properties_file%" (
		goto :eof
	)

	REM ASSETS
	for %%A in (!_assets_list!) do (
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" ASSETS_MAIN_PACKAGE "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" ASSETS_OPTIONS "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" ASSETS_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" ASSETS_URI "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" ASSETS_GET_PROTOCOL "PREFIX"
	)
goto :eof

:get_infra_properties
	set "_properties_file=%~1"
	set "_infra_list=%~2"

	if not exist "%_properties_file%" (
		goto :eof
	)

	REM INFRA
	for %%A in (!_infra_list!) do (
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" INFRA_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" INFRA_DISTRIB "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" INFRA_CPU "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" INFRA_MEM "PREFIX"
	)
goto :eof

:: Note : call get_infra_properties first
:get_env_properties
	set "_properties_file=%~1"
	set "_env_list=%~2"

	if not exist "%_properties_file%" (
		goto :eof
	)

	REM ENV
	for %%A in (!_env_list!) do (
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" ENV_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "%%A" INFRA_ID "PREFIX"
	)

	REM INFRA-ENV
	for %%A in (!_env_list!) do (
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
			
			call %STELLA_BIN%\virtual.bat get-box !_env_distrib!
			call %STELLA_BIN%\virtual.bat create-box !_env_distrib!
			call %STELLA_BIN%\virtual.bat create-env "%%A#!_env_distrib!" -vcpu=!_env_cpu! -vmem=!_env_mem!
			@echo off
			echo * Now you can use your env using %STELLA_BIN%\virtual.bat OR with Vagrant
		) else (
			echo * Env '!_env_name! [%%A]' is the default current system
		)
	)
goto :eof





:ask_init_app
	set /p input="Do you wish to init your stella app (create properties files, link app to stella...) ? [Y/n] "
		if not "%input%"=="n" (
			for /D %%I IN ("%STELLA_CURRENT_RUNNING_DIR%") do set _project_name=%%~nxI
			set /p input="What is your project name ? [!_project_name!] "
			if not "!input!"=="" (
				set "_project_name=!input!"
			)

			set /p input="Do you wish to generate a sample app for your project ? [y/N] "
			if "!input!"=="y" (
				REM using default values for app paths (because we didnt ask them)
				call :init_app "!_project_name!" "!STELLA_CURRENT_RUNNING_DIR!"

				call :create_app_samples "!STELLA_CURRENT_RUNNING_DIR!"
			) else (
				call :init_app "!_project_name!" "!STELLA_CURRENT_RUNNING_DIR!"
			)
			@echo off
		)
goto :eof

