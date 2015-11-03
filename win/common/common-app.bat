@echo off
call %*
goto :eof


REM APP RESSOURCES & ENV MANAGEMENT ---------------




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
	set "_target_approot=%~1"
	set "OPT=%~2"
	REM set "_stella_root=%~2"

	set _opt_share_cache=OFF
	set _opt_share_workspace=OFF
	set _flag_stella_root=OFF
	set "_stella_root=!STELLA_ROOT!"

	for %%O in (%OPT%) do (
		if "%%O"=="CACHE" (
			set _opt_share_cache=ON
		)
		if "%%O"=="WORKSPACE" (
			set _opt_share_workspace=ON
		)
		if "!_flag_stella_root!"=="ON" (
			set "_stella_root=%%O"
			set _flag_stella_root=OFF
		)
		if "%%O"=="STELLA_ROOT" (
			set _flag_stella_root=ON
		)
	)

	call %STELLA_COMMON%\common.bat :rel_to_abs_path "_target_approot" "!_target_approot!" "%STELLA_CURRENT_RUNNING_DIR%"

	call %STELLA_COMMON%\common.bat :is_path_abs "IS_ABS" "!_stella_root!"
	if "%IS_ABS%"=="FALSE" (
		call %STELLA_COMMON%\common.bat :rel_to_abs_path "_stella_root" "!_stella_root!" "%_target_approot%"
	)

	call %STELLA_COMMON%\common.bat :get_stella_flavour "_s_flavour" "!_stella_root!"
	call %STELLA_COMMON%\common.bat :get_stella_version "_s_ver" "!_stella_root!"

	call %STELLA_COMMON%\common.bat :abs_to_rel_path "_stella_root" "!_stella_root!" "%_target_approot%"

	

	> "!_target_approot!\stella-link.bat.temp" ECHO(@if not "%%~1"=="include" if not "%%~1"=="chaining" if not "%%~1"=="nothing" setlocal enableExtensions enableDelayedExpansion
	>> "!_target_approot!\stella-link.bat.temp" ECHO(@set _STELLA_LINK_CURRENT_FILE_DIR=%%~dp0
	>> "!_target_approot!\stella-link.bat.temp" ECHO(@set _STELLA_LINK_CURRENT_FILE_DIR=%%_STELLA_LINK_CURRENT_FILE_DIR:~0,-1%%
	>> "!_target_approot!\stella-link.bat.temp" ECHO(@set STELLA_ROOT=%%_STELLA_LINK_CURRENT_FILE_DIR%%\!_stella_root!
	>> "!_target_approot!\stella-link.bat.temp" ECHO(@set STELLA_DEP_FLAVOUR=!_s_flavour!
	>> "!_target_approot!\stella-link.bat.temp" ECHO(@set STELLA_DEP_VERSION=!_s_ver!

	copy /b "!_target_approot!\stella-link.bat.temp"+"%STELLA_TEMPLATE%\sample-stella-link.bat" "!_target_approot!\stella-link.bat"

	del /f /q "!_target_approot!\stella-link.bat.temp" >nul

	REM tweak stella properties file
	set "_target_STELLA_APP_PROPERTIES_FILE=!_target_approot!\%STELLA_APP_PROPERTIES_FILENAME%"
	if "!_opt_share_workspace!"=="ON" (
		call %STELLA_COMMON%\common.bat :add_key "!_target_STELLA_APP_PROPERTIES_FILE!" "STELLA" "APP_WORK_ROOT" "!STELLA_APP_WORK_ROOT!"
	)
	if "!_opt_share_cache!"=="ON" (
		call %STELLA_COMMON%\common.bat :add_key "!_target_STELLA_APP_PROPERTIES_FILE!" "STELLA" "APP_CACHE_DIR" "!STELLA_APP_CACHE_DIR!"
	)
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
	REM call %STELLA_COMMON%\common.bat :is_path_abs "IS_ABS" "%STELLA_ROOT%"
	REM if "%IS_ABS%"=="FALSE" (
	REM		call %STELLA_COMMON%\common.bat :rel_to_abs_path "_stella_root" "%STELLA_ROOT%" "!_approot!"
	REM )
	
	call %STELLA_COMMON%\common.bat :get_stella_flavour "_s_flavour" "!_stella_root!"
	call %STELLA_COMMON%\common.bat :get_stella_version "_s_ver" "!_stella_root!"


	call %STELLA_COMMON%\common.bat :abs_to_rel_path "_workroot" "!_workroot!" "!_approot!"
	call %STELLA_COMMON%\common.bat :abs_to_rel_path "_cachedir" "!_cachedir!" "!_approot!"
	call %STELLA_COMMON%\common.bat :abs_to_rel_path "_stella_root" "%STELLA_ROOT%" "!_approot!"


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
		REM call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "ENV_LIST" ""
		REM call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "INFRA_LIST" ""
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
	REM if "!STELLA_APP_CACHE_DIR!"=="" (
		call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "APP_CACHE_DIR" "PREFIX"
	REM )

	call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "APP_CACHE_DIR" "PREFIX"
	REM call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "DATA_LIST" "PREFIX"
	REM call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "ASSETS_LIST" "PREFIX"
	REM call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "ENV_LIST" "PREFIX"
	REM call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "INFRA_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%_properties_file%" "STELLA" "APP_FEATURE_LIST" "PREFIX"

	REM call :get_data_properties "%_properties_file%" "!STELLA_DATA_LIST!"
	REM call :get_assets_properties "%_properties_file%" "!STELLA_ASSETS_LIST!"
	REM call :get_infra_properties "%_properties_file%" "!STELLA_INFRA_LIST!"
	REM call :get_env_properties "%_properties_file%" "!STELLA_ENV_LIST!"

goto :eof

:get_app_property
	set "_SECTION=%~1"
	set "_KEY=%~2"
	call %STELLA_COMMON%\common.bat :get_key "!_STELLA_APP_PROPERTIES_FILE!" "!_SECTION!" "!_KEY!" "PREFIX"
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

