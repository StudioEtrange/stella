@echo off
call %*
goto :eof

:: ------------------------ API -----------------
:: ARG1 return variable
:list_active_features
	set "%~1=!FEATURE_LIST_ENABLED!"
goto :eof

:: ARG2 return variable
:list_feature_version
	set "_SCHEMA=%~1"
	set "_VAR=%~2"

	call :internal_feature_context "!_SCHEMA!"

	set "%_VAR%=!FEAT_LIST_SCHEMA!"
goto :eof





:feature_init
	set "_SCHEMA=%~1"
	set "_OPT=%~2"

	set _opt_hidden_feature=OFF
	for %%O in (%_OPT%) do (
		if "%%O"=="HIDDEN" set _opt_hidden_feature=ON
	)

	call :internal_feature_context "!_SCHEMA!"

	set "_flag=0"
	for %%a in (!FEATURE_LIST_ENABLED!) do (
		if "!FEAT_NAME!#!FEAT_VERSION!"=="%%a" set _flag=1
	)

	if "!_flag!"=="0" (
		call :feature_inspect !FEAT_SCHEMA_SELECTED!
		if "!TEST_FEATURE!"=="1" (

			if not "!FEAT_BUNDLE!"=="" (
				set "save_opt_hidden_feature=!_opt_hidden_feature!"

				call :push_schema_context

				set "FEAT_BUNDLE_MODE=!FEAT_BUNDLE!"
				for %%p in (!FEAT_BUNDLE_ITEM!) do (
					REM call :feature_init %%p "HIDDEN"
					call :internal_feature_context "%%p"
					if not "!FEAT_SEARCH_PATH!"=="" set "PATH=!FEAT_SEARCH_PATH!;!PATH!"
					for %%e in (!FEAT_ENV_CALLBACK!) do (
						call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :%%e
					)
				)
				set "FEAT_BUNDLE_MODE="

				call :pop_schema_context
				set "_opt_hidden_feature=!save_opt_hidden_feature!"
			)

			if not "!_opt_hidden_feature!"=="ON" set "FEATURE_LIST_ENABLED=!FEATURE_LIST_ENABLED! !FEAT_NAME!#!FEAT_VERSION!"
			if not "!FEAT_SEARCH_PATH!"=="" set "PATH=!FEAT_SEARCH_PATH!;!PATH!"


			for %%p in (!FEAT_ENV_CALLBACK!) do (
				call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :%%p
			)

		)
	)
goto :eof



REM get information on feature (from catalog)
:feature_catalog_info
	set "_catalog_SCHEMA=%~1"
	call :internal_feature_context !_catalog_SCHEMA!
goto :eof


:: look for information about an installed feature
:feature_match_installed
	set "_match_SCHEMA=%~1"

	set "_tested="
	set "_found="


	if "!_match_SCHEMA!"=="" (
		call :internal_feature_context
	) else (

		REM we are NOT inside a bundle, because FEAT_BUNDLE_MODE is NOT set
		if "!FEAT_BUNDLE_MODE!"=="" (
			call :translate_schema !_match_SCHEMA! "__VAR_FEATURE_NAME" "__VAR_FEATURE_VER" "__VAR_FEATURE_ARCH" "__VAR_FEATURE_FLAVOUR"

			if not "!__VAR_FEATURE_VER!"=="" (
				set "_tested=!__VAR_FEATURE_VER!"
			)
			if not "!__VAR_FEATURE_ARCH!"=="" (
				set "_tested=!_tested!@!__VAR_FEATURE_ARCH!"
			)
			if exist "!STELLA_APP_FEATURE_ROOT!\!__VAR_FEATURE_NAME!" (
				REM for each detected version
				for /D %%F in ( !STELLA_APP_FEATURE_ROOT!\!__VAR_FEATURE_NAME!\* ) do (
					set "_f=%%~nxF"

					if "!_tested!"=="" (
						set "_found=!_f!"
					) else (
						call %STELLA_COMMON%\common.bat :match_exp ".*!_tested!.*" "!_f!"
						if "!_match_exp!"=="TRUE" (
							set "_found=!_f!"
						)
					)
				)
			)

			if not "!_found!"=="" (
				if not "!__VAR_FEATURE_FLAVOUR!"=="" (
					call :internal_feature_context "!__VAR_FEATURE_NAME!#!_found!:!__VAR_FEATURE_FLAVOUR!"
				) else (
					call :internal_feature_context "!__VAR_FEATURE_NAME!#!_found!"
				)
			) else (
				REM empty info values
				call :internal_feature_context
			)

		) else (
			call :internal_feature_context !_match_SCHEMA!
		)
	)
goto :eof


:push_schema_context
	call %STELLA_COMMON%\common.bat :stack_push "!TEST_FEATURE!"
	call %STELLA_COMMON%\common.bat :stack_push "!FEAT_SCHEMA_SELECTED!"
goto :eof

:pop_schema_context
	call %STELLA_COMMON%\common.bat :stack_pop "FEAT_SCHEMA_SELECTED"
	call :internal_feature_context !FEAT_SCHEMA_SELECTED!
	call %STELLA_COMMON%\common.bat :stack_pop "TEST_FEATURE"
goto :eof

:: test if a feature is installed
:: AND retrieve informations based on actually installed feature into var
:: PREFIX_<info>
:feature_info
	set "_info_schema=%~1"
	set "_info_prefix=%~2"

	if not "!_info_prefix!"=="" (
		set "_t=!_info_prefix!_TEST_FEATURE"
		set "!_t!=0"
		set "_t=!_info_prefix!_FEAT_INSTALL_ROOT"
		set "!_t!="
		set "_t=!_info_prefix!_FEAT_NAME"
		set "!_t!="
		set "_t=!_info_prefix!_FEAT_ARCH"
		set "!_t!="
		set "_t=!_info_prefix!_FEAT_SEARCH_PATH"
		set "!_t!="
	)

	call :push_schema_context
	call :feature_inspect !_info_schema!
	if "!TEST_FEATURE!"=="1" (
		if not "!_info_prefix!"=="" (
			set "_t=!_info_prefix!_TEST_FEATURE"
			set "!_t!=!TEST_FEATURE!"
			set "_t=!_info_prefix!_FEAT_INSTALL_ROOT"
			set "!_t!=!FEAT_INSTALL_ROOT!"
			set "_t=!_info_prefix!_FEAT_NAME"
			set "!_t!=!FEAT_NAME!"
			set "_t=!_info_prefix!_FEAT_ARCH"
			set "!_t!=!FEAT_ARCH!"
			set "_t=!_info_prefix!_FEAT_SEARCH_PATH"
			set "!_t!=!FEAT_SEARCH_PATH!"
		)
	)

	call :pop_schema_context

goto :eof

:: test if a feature is installed
:: AND retrieve informations based on actually installed feature (looking inside STELLA_APP_FEATURE_ROOT) OR from feature recipe if not installed
:: do not use default values from feature recipe to search installed feature
:feature_inspect
	set "_inspect_SCHEMA=%~1"
	set "feature_inspect_ORIGINAL_SCHEMA=%~1"

	set TEST_FEATURE=0

	if not "!_inspect_SCHEMA!"=="" (
		call :feature_match_installed !_inspect_SCHEMA!
		set "_inspect_SCHEMA=!feature_inspect_ORIGINAL_SCHEMA!"

		if not "!FEAT_SCHEMA_SELECTED!"=="" (
			if not "!FEAT_BUNDLE!"=="" (
				set "_t=1"

				call :push_schema_context

				set "FEAT_BUNDLE_MODE=!FEAT_BUNDLE!"
				for %%p in (!FEAT_BUNDLE_ITEM!) do (
					set "TEST_FEATURE=0"
					call :feature_inspect %%p
					if "!TEST_FEATURE!"=="0" (
						set "_t=0"
					)
				)
				set "FEAT_BUNDLE_MODE="

				call :pop_schema_context

				set "TEST_FEATURE=!_t!"
				if "!TEST_FEATURE!"=="1" (
					if not "!FEAT_INSTALL_TEST!"=="" (
						for %%f in (!FEAT_INSTALL_TEST!) do (
							if not exist "%%f" (
								set "TEST_FEATURE=0"
							)
						)
					)
				)
			) else (
				set "TEST_FEATURE=1"
				for %%f in (!FEAT_INSTALL_TEST!) do (
					if not exist "%%f" (
						set "TEST_FEATURE=0"
					)
				)
			)
		) else (
			call :feature_catalog_info !_inspect_SCHEMA!
		)
	)
goto :eof



 :feature_remove
	set "_remove_SCHEMA=%~1"
	set "_OPT=%~2"

	set _opt_internal_feature=OFF
	set _opt_hidden_feature=OFF
	for %%O in (%_OPT%) do (
		if "%%O"=="INTERNAL" set _opt_internal_feature=ON
		if "%%O"=="HIDDEN" set _opt_hidden_feature=ON
	)

	call :feature_inspect !_remove_SCHEMA!

	if not "!FEAT_SCHEMA_OS_RESTRICTION!"=="" (
			if not "!FEAT_SCHEMA_OS_RESTRICTION!"=="!STELLA_CURRENT_OS!" goto :eof
	)

	if not "!FEAT_SCHEMA_OS_EXCLUSION!"=="" (
			if "!FEAT_SCHEMA_OS_EXCLUSION!"=="!STELLA_CURRENT_OS!" goto :eof
	)

	if "%_opt_internal_feature%"=="ON" (
		set "_save_app_feature_root=!STELLA_APP_FEATURE_ROOT!"
		set "STELLA_APP_FEATURE_ROOT=!STELLA_INTERNAL_FEATURE_ROOT!"

		set "_save_app_cache_dir=!STELLA_APP_CACHE_DIR!"
		set "STELLA_APP_CACHE_DIR=!STELLA_INTERNAL_CACHE_DIR!"

		set "_save_app_temp_dir=!STELLA_APP_TEMP_DIR!"
		set "STELLA_APP_TEMP_DIR=!STELLA_INTERNAL_TEMP_DIR!"
	)

	if not "%_opt_hidden_feature%"=="ON" (
		call %STELLA_COMMON%\common-app.bat :remove_app_feature !_remove_SCHEMA!
	)

	if "!TEST_FEATURE!"=="1" (

		if not "!FEAT_BUNDLE!"=="" (
			echo Remove bundle !FEAT_NAME! version !FEAT_VERSION!
			call %STELLA_COMMON%\common.bat :del_folder !FEAT_INSTALL_ROOT!

			call %STELLA_COMMON%\common.bat :stack_push "!_remove_SCHEMA!"
			call :push_schema_context

			set "FEAT_BUNDLE_MODE=!FEAT_BUNDLE!"
			for %%p in (!FEAT_BUNDLE_ITEM!) do (
				call :feature_remove %%p "HIDDEN"
			)
			set "FEAT_BUNDLE_MODE="
			call :pop_schema_context
			call %STELLA_COMMON%\common.bat :stack_pop "_remove_SCHEMA"

		) else (
			echo Remove !FEAT_NAME! version !FEAT_VERSION! from !FEAT_INSTALL_ROOT!
			call %STELLA_COMMON%\common.bat :del_folder !FEAT_INSTALL_ROOT!
		)
	)

	if "%_opt_internal_feature%"=="ON" (
		set "STELLA_APP_FEATURE_ROOT=!_save_app_feature_root!"
		set "STELLA_APP_CACHE_DIR=!_save_app_cache_dir!"
		set "STELLA_APP_TEMP_DIR=!_save_app_temp_dir!"
	)
goto :eof

:feature_install_list
	set "_list=%~1"

	for %%f in (%_list%) do (
		call :feature_install %%f
	)
goto :eof




:feature_install
	set "_SCHEMA=%~1"
	set "_OPT=%~2"

	set _opt_internal_feature=OFF
	set _opt_hidden_feature=OFF
	set _opt_force_reinstall_dep=0
	set _opt_ignore_dep=OFF
	set _flag_export=OFF
	set _dir_export=
	set _export_mode=OFF
	set _flag_portable=OFF
	set _dir_portable=
	set _portable_mode=OFF

	for %%O in (%_OPT%) do (
		if "%%O"=="INTERNAL" set _opt_internal_feature=ON
		if "%%O"=="HIDDEN" set _opt_hidden_feature=ON
		if "%%O"=="DEP_FORCE" set _opt_force_reinstall_dep=1
		if "%%O"=="DEP_IGNORE" set _opt_ignore_dep=ON
		if "!_flag_export!"=="ON" (
			set "_dir_export=%%O"
			set _flag_export=OFF
			set _export_mode=ON
		)
		if "%%O"=="EXPORT" (
			set _flag_export=ON
		)
		if "!_flag_portable!"=="ON" (
			set "_dir_portable=%%O"
			set _flag_portable=OFF
			set _portable_mode=ON
		)
		if "%%O"=="PORTABLE" (
			set _flag_portable=ON
		)
	)



	:: EXPORT / PORTABLE MODE ------------------------------------
	if "!_export_mode!"=="ON" (
		set _opt_internal_feature=OFF
		set _opt_hidden_feature=ON

		set "FEAT_MODE_EXPORT_SCHEMA=!_SCHEMA!"
		set "_SCHEMA=mode-export"

		set "_save_app_feature_root=!STELLA_APP_FEATURE_ROOT!"
		call %STELLA_COMMON%\common.bat :rel_to_abs_path "STELLA_APP_FEATURE_ROOT" "!_dir_export!"
		set "_OPT=%_OPT:EXPORT=__%"
	)

	if "!_portable_mode!"=="ON" (
		set _opt_internal_feature=OFF
		set _opt_hidden_feature=ON

		set "FEAT_MODE_EXPORT_SCHEMA=!_SCHEMA!"
		set "_SCHEMA=mode-export"

		set "_save_app_feature_root=!STELLA_APP_FEATURE_ROOT!"
		call %STELLA_COMMON%\common.bat :rel_to_abs_path "STELLA_APP_FEATURE_ROOT" "!_dir_portable!"
		set "_OPT=%_OPT:PORTABLE=__%"

		set "_save_relocate_default_mode=!STELLA_BUILD_RELOCATE_DEFAULT!"
		call %STELLA_COMMON%\common-build.bat :set_build_mode_default "RELOCATE" "ON"
	)



	call :internal_feature_context !_SCHEMA!


	if not "!FEAT_SCHEMA_OS_RESTRICTION!"=="" (
		if not "!FEAT_SCHEMA_OS_RESTRICTION!"=="!STELLA_CURRENT_OS!" (
			echo !_SCHEMA! not installed on !STELLA_CURRENT_OS!
			goto :eof
		)
	)

	if not "!FEAT_SCHEMA_OS_EXCLUSION!"=="" (
		if "!FEAT_SCHEMA_OS_EXCLUSION!"=="!STELLA_CURRENT_OS!" (
			echo !_SCHEMA! not installed on !STELLA_CURRENT_OS!
			goto :eof
		)
	)

	if not "!FEAT_SCHEMA_SELECTED!"=="" (
		if "%_opt_internal_feature%"=="ON" (
			set "_save_app_feature_root=!STELLA_APP_FEATURE_ROOT!"
			set "STELLA_APP_FEATURE_ROOT=!STELLA_INTERNAL_FEATURE_ROOT!"

			set "_save_app_cache_dir=!STELLA_APP_CACHE_DIR!"
			set "STELLA_APP_CACHE_DIR=!STELLA_INTERNAL_CACHE_DIR!"

			set "_save_app_temp_dir=!STELLA_APP_TEMP_DIR!"
			set "STELLA_APP_TEMP_DIR=!STELLA_INTERNAL_TEMP_DIR!"
		)

		if not "%_opt_hidden_feature%"=="ON" (
			call %STELLA_COMMON%\common-app.bat :add_app_feature !_SCHEMA!
		)


		if "%FORCE%"=="1" (
			set TEST_FEATURE=0
			if "!_export_mode!"=="OFF" (
				if "!_portable_mode!"=="OFF" (
					call %STELLA_COMMON%\common.bat :del_folder !FEAT_INSTALL_ROOT!
				)
			)
		) else (
			call :feature_inspect !FEAT_SCHEMA_SELECTED!
		)

		if "!TEST_FEATURE!"=="0" (

			if "!_export_mode!"=="OFF" (
				if "!_portable_mode!"=="OFF" (
					if not exist "!FEAT_INSTALL_ROOT!" mkdir "!FEAT_INSTALL_ROOT!"
				)
			)

			REM dependencies
			if "!_opt_ignore_dep!"=="OFF" (

				set "save_FORCE=%FORCE%"
				set "FORCE=!_opt_force_reinstall_dep!"


				call %STELLA_COMMON%\common.bat :stack_push "!_SCHEMA!"
				call :push_schema_context

				set "_dependencies="
				if "!FEAT_SCHEMA_FLAVOUR!"=="source" (
					set "_dependencies=!FEAT_SOURCE_DEPENDENCIES!"
				)
				if "!FEAT_SCHEMA_FLAVOUR!"=="binary" (
					set "_dependencies=!FEAT_BINARY_DEPENDENCIES!"
				)

				for %%p in (!_dependencies!) do (
					echo Installing dependency %%p

					call :feature_install %%p "!_OPT! HIDDEN"
					if "!TEST_FEATURE!"=="0" (
						echo ** Error while installing dependency feature !FEAT_SCHEMA_SELECTED!
					)
				)

				call :pop_schema_context
				call %STELLA_COMMON%\common.bat :stack_pop "_SCHEMA"

				set "FORCE=!save_FORCE!"
			)


			REM bundle
			if not "!FEAT_BUNDLE!"=="" (


				:: save export/portable mode
				call %STELLA_COMMON%\common.bat :stack_push "!_export_mode!"
				call %STELLA_COMMON%\common.bat :stack_push "!_portable_mode!"


				if not "!FEAT_BUNDLE_ITEM!"=="" (
					call %STELLA_COMMON%\common.bat :stack_push "!_SCHEMA!"
					call :push_schema_context
					set "FEAT_BUNDLE_MODE=!FEAT_BUNDLE!"

					if not "!FEAT_BUNDLE_MODE!"=="LIST" (
						set "save_FORCE=%FORCE%"
						set "FORCE=0"
					)

					REM should be  MERGE or NESTED or LIST or MERGE_LIST
					REM NESTED : each item will be installed inside the bundle path in a separate directory (with each feature name but without version) (bundle_name/bunle_version/item_name)
					REM MERGE : each item will be installed in the bundle path (without each feature name/version)
					REM LIST : this bundle is just a list of items that will be installed normally (without bundle name nor version in path: item_name/item_version )
					REM MERGE_LIST : this bundle is a list of items that will be installed in a MERGED way (without bundle name nor version AND without each feature name/version)

					if "!FEAT_BUNDLE_MODE!"=="LIST" (
						set " _flag_hidden="
					) else (
						set "_flag_hidden=HIDDEN"
					)



					for %%p in (!FEAT_BUNDLE_ITEM!) do (
						call :feature_install %%p "!_OPT! !_flag_hidden!"
					)



					if not "!FEAT_BUNDLE_MODE!"=="LIST" (
						set "FORCE=!save_FORCE!"
					)

					set "FEAT_BUNDLE_MODE="
					call :pop_schema_context
					call %STELLA_COMMON%\common.bat :stack_pop "_SCHEMA"

				)


				:: restore export/portable mode
				call %STELLA_COMMON%\common.bat :stack_pop "_portable_mode"
				call %STELLA_COMMON%\common.bat :stack_pop "_export_mode"


				REM automatic call of callback
				call :feature_callback
			) else (

				call %STELLA_COMMON%\common.bat :stack_push "!_SCHEMA!"
				call :push_schema_context
				echo Installing !FEAT_NAME! version !FEAT_VERSION! in !FEAT_INSTALL_ROOT!
				if "!FEAT_SCHEMA_FLAVOUR!"=="source" (
					call %STELLA_COMMON%\common-build.bat :start_build_session
				)
				call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :feature_!FEAT_NAME!_install_!FEAT_SCHEMA_FLAVOUR!
				call :pop_schema_context
				call %STELLA_COMMON%\common.bat :stack_pop "_SCHEMA"
			)

			if "!_export_mode!"=="OFF" (
				if "!_portable_mode!"=="OFF" (
					set "save_SCHEMA=!_SCHEMA!"
					call :feature_inspect !FEAT_SCHEMA_SELECTED!
					if "!TEST_FEATURE!"=="1" (
						echo ** Feature !save_SCHEMA! is installed
						call :feature_init "!FEAT_SCHEMA_SELECTED!" !_OPT!
					) else (
						echo ** Error while installing feature !FEAT_SCHEMA_SELECTED!
						REM Sometimes current directory is lost by the system
						cd /D %STELLA_APP_ROOT%
					)
				)
			)

		) else (
			echo ** Feature !_SCHEMA! already installed
			call :feature_init "!FEAT_SCHEMA_SELECTED!" !_OPT!
		)



		if "!_export_mode!"=="ON" (
			set "STELLA_APP_FEATURE_ROOT=!_save_app_feature_root!"
		)

		if "!_portable_mode!"=="ON" (
			set "STELLA_APP_FEATURE_ROOT=!_save_app_feature_root!"
			call %STELLA_COMMON%\common-build.bat :set_build_mode_default "RELOCATE" "!_save_relocate_default_mode!"

		)

		if "%_opt_internal_feature%"=="ON" (
			set "STELLA_APP_FEATURE_ROOT=!_save_app_feature_root!"
			set "STELLA_APP_CACHE_DIR=!_save_app_cache_dir!"
			set "STELLA_APP_TEMP_DIR=!_save_app_temp_dir!"
		)


	) else (
		echo ** Error unknow feature !_SCHEMA!
	)

goto :eof



:: ----------- INTERNAL ----------------


:feature_init_installed
	REM init internal features
	REM internal feature are not prioritary over app features
	if not "%STELLA_INTERNAL_FEATURE_ROOT%"=="%STELLA_APP_FEATURE_ROOT%" (

		set "_save_app_feature_root=!STELLA_APP_FEATURE_ROOT!"
		set "STELLA_APP_FEATURE_ROOT=!STELLA_INTERNAL_FEATURE_ROOT!"

		for /D %%A in ( %STELLA_INTERNAL_FEATURE_ROOT%\* ) do (
			set "_folder=%%~nxA"
			REM check for official feature
			for %%F in (%__STELLA_FEATURE_LIST%) do (
				if "%%F"=="!_folder!" (
					REM for each detected version
					for /D %%V in ( %STELLA_INTERNAL_FEATURE_ROOT%\%%F\* ) do (
						set "_ver=%%~nxV"
						call :feature_init !_folder!#!_ver! "INTERNAL HIDDEN"
					)
				)
			)
		)
		set "STELLA_APP_FEATURE_ROOT=!_save_app_feature_root!"
	)


	for /D %%A in ( %STELLA_APP_FEATURE_ROOT%\* ) do (
		set "_folder=%%~nxA"
		REM check for official feature
		for %%F in (%__STELLA_FEATURE_LIST%) do (
			if "%%F"=="!_folder!" (
				REM for each detected version
				for /D %%V in ( %STELLA_APP_FEATURE_ROOT%\%%F\* ) do (
					set "_ver=%%~nxV"
					call :feature_init !_folder!#!_ver!
				)
			)
		)
	)



	if not "!FEATURE_LIST_ENABLED!"=="" echo ** Features initialized : !FEATURE_LIST_ENABLED!
goto :eof



:feature_reinit_installed
	set "FEATURE_LIST_ENABLED="
	call :feature_init_installed
goto :eof


:feature_callback
	if not "!FEAT_BUNDLE!"=="" (
		for %%p in (!FEAT_BUNDLE_CALLBACK!) do (
			call "%STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat" :%%p
		)
	) else (

		if "!FEAT_SCHEMA_FLAVOUR!"=="source" (
			for %%p in (!FEAT_SOURCE_CALLBACK!) do (
				call "%STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat" :%%p
			)
		)

		if "!FEAT_SCHEMA_FLAVOUR!"=="binary" (
			for %%p in (!FEAT_BINARY_CALLBACK!) do (
				call "%STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat" :%%p
			)
		)

	)
goto :eof

REM init feature context (properties, variables, ...)
:internal_feature_context
	set "__SCHEMA=%~1"
	set "feature_context_ORIGINAL_SCHEMA=%~1"

	set "FEAT_ARCH="

	set "TMP_FEAT_SCHEMA_NAME="
	set "TMP_FEAT_SCHEMA_VERSION="
	set "FEAT_SCHEMA_SELECTED="
	set "FEAT_SCHEMA_FLAVOUR="
	set "FEAT_SCHEMA_OS_RESTRICTION="
	set "FEAT_SCHEMA_OS_EXCLUSION="



	set "FEAT_NAME="
	set "FEAT_LIST_SCHEMA="
	set "FEAT_DEFAULT_VERSION="
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR="
	set "FEAT_VERSION="
	set "FEAT_SOURCE_URL="
	set "FEAT_SOURCE_URL_FILENAME="
	set "FEAT_SOURCE_URL_PROTOCOL="
	set "FEAT_SOURCE_DEPENDENCIES="
	set "FEAT_SOURCE_CALLBACK="
	set "FEAT_BINARY_URL="
	set "FEAT_BINARY_URL_FILENAME="
	set "FEAT_BINARY_URL_PROTOCOL="
	set "FEAT_BINARY_DEPENDENCIES="
	set "FEAT_BINARY_CALLBACK="
	set "FEAT_DEPENDENCIES="
	set "FEAT_INSTALL_TEST="
	set "FEAT_INSTALL_ROOT="
	set "FEAT_SEARCH_PATH="
	set "FEAT_ENV_CALLBACK="
	set "FEAT_BUNDLE_ITEM="
	set "FEAT_BUNDLE_CALLBACK="
	REM MERGE / NESTED / LIST / MERGE_LIST
	set "FEAT_BUNDLE="

	if not "!__SCHEMA!"=="" (
		call :select_official_schema !__SCHEMA! "FEAT_SCHEMA_SELECTED" "TMP_FEAT_SCHEMA_NAME" "TMP_FEAT_SCHEMA_VERSION" "FEAT_ARCH" "FEAT_SCHEMA_FLAVOUR" "FEAT_SCHEMA_OS_RESTRICTION" "FEAT_SCHEMA_OS_EXCLUSION"


		if not "!FEAT_SCHEMA_SELECTED!"=="" (

			REM call :translate_schema "!FEAT_SCHEMA_SELECTED!" "TMP_FEAT_SCHEMA_NAME" "TMP_FEAT_SCHEMA_VERSION" "FEAT_ARCH" "FEAT_SCHEMA_FLAVOUR" "FEAT_SCHEMA_OS_RESTRICTION" "FEAT_SCHEMA_OS_EXCLUSION"

			REM set install root (FEAT_INSTALL_ROOT)
			if "!FEAT_BUNDLE_MODE!"=="" (
				if not "!FEAT_ARCH!"=="" (
					set "FEAT_INSTALL_ROOT=!STELLA_APP_FEATURE_ROOT!\!TMP_FEAT_SCHEMA_NAME!\!TMP_FEAT_SCHEMA_VERSION!@!FEAT_ARCH!"
				) else (
					set "FEAT_INSTALL_ROOT=!STELLA_APP_FEATURE_ROOT!\!TMP_FEAT_SCHEMA_NAME!\!TMP_FEAT_SCHEMA_VERSION!"
				)
			) else (
				if "!FEAT_BUNDLE_MODE!"=="MERGE" (
					set "FEAT_INSTALL_ROOT=!FEAT_BUNDLE_PATH!"
				)
				if "!FEAT_BUNDLE_MODE!"=="NESTED" (
					set "FEAT_INSTALL_ROOT=!FEAT_BUNDLE_PATH!\!TMP_FEAT_SCHEMA_NAME!"
				)
				if "!FEAT_BUNDLE_MODE!"=="LIST" (
					if not "!FEAT_ARCH!"=="" (
						set "FEAT_INSTALL_ROOT=!STELLA_APP_FEATURE_ROOT!\!TMP_FEAT_SCHEMA_NAME!\!TMP_FEAT_SCHEMA_VERSION!@!FEAT_ARCH!"
					) else (
						set "FEAT_INSTALL_ROOT=!STELLA_APP_FEATURE_ROOT!\!TMP_FEAT_SCHEMA_NAME!\!TMP_FEAT_SCHEMA_VERSION!"
					)
				)
				if "!FEAT_BUNDLE_MODE!"=="MERGE_LIST" (
					set "FEAT_INSTALL_ROOT=!STELLA_APP_FEATURE_ROOT!"
				)
			)

			REM grab feature info
			call %STELLA_FEATURE_RECIPE%\feature_!TMP_FEAT_SCHEMA_NAME!.bat :feature_!TMP_FEAT_SCHEMA_NAME!
			call %STELLA_FEATURE_RECIPE%\feature_!TMP_FEAT_SCHEMA_NAME!.bat :feature_!TMP_FEAT_SCHEMA_NAME!_!TMP_FEAT_SCHEMA_VERSION!

			REM bundle path
			if not "!FEAT_BUNDLE!"=="" (
				if "!FEAT_BUNDLE!"=="LIST" (
					set FEAT_BUNDLE_PATH=
				) else (
					set "FEAT_BUNDLE_PATH=!FEAT_INSTALL_ROOT!"
				)
			)

			REM set url dependending on arch
			if not "!FEAT_ARCH!"=="" (
				set "_tmp=FEAT_BINARY_URL_!FEAT_ARCH!"
				for /F %%a in ('echo !_tmp!') do set "FEAT_BINARY_URL=!%%a!"

				set "_tmp=FEAT_BINARY_URL_FILENAME_!FEAT_ARCH!"
				for /F %%a in ('echo !_tmp!') do set "FEAT_BINARY_URL_FILENAME=!%%a!"

				set "_tmp=FEAT_BINARY_URL_PROTOCOL_!FEAT_ARCH!"
				for /F %%a in ('echo !_tmp!') do set "FEAT_BINARY_URL_PROTOCOL=!%%a!"

				set "_tmp=FEAT_BUNDLE_ITEM_!FEAT_ARCH!"
				for /F %%a in ('echo !_tmp!') do set "FEAT_BUNDLE_ITEM=!%%a!"

				set "_tmp=FEAT_BINARY_DEPENDENCIES_!FEAT_ARCH!"
				for /F %%a in ('echo !_tmp!') do set "FEAT_BINARY_DEPENDENCIES=!%%a!"
			)
		) else (
			REM we grab only os option
			call :translate_schema !__SCHEMA! "NONE" "NONE" "NONE" "NONE" "FEAT_SCHEMA_OS_RESTRICTION" "FEAT_SCHEMA_OS_EXCLUSION"
		)
	)
	set "__SCHEMA=!feature_context_ORIGINAL_SCHEMA!"
goto :eof



REM select an official schema
REM pick a feature schema by filling some values with default one
REM and may return split schema properties
:select_official_schema
	set "_SCHEMA=%~1"
	set "feature_select_schema_ORIGINAL_SCHEMA=%~1"
	set "_RESULT_SCHEMA=%~2"


	set "_select_VAR_FEATURE_NAME=%~3"
	set "_select_VAR_FEATURE_VER=%~4"
	set "_select_VAR_FEATURE_ARCH=%~5"
	set "_select_VAR_FEATURE_FLAVOUR=%~6"
	set "_select_VAR_FEATURE_OS_RESTRICTION=%~7"
	set "_select_VAR_FEATURE_OS_EXCLUSION=%~8"

	set "_FILLED_SCHEMA="

	if not "!_RESULT_SCHEMA!"=="" (
		set "!_RESULT_SCHEMA!="
	)

	call :translate_schema "!_SCHEMA!" "!_select_VAR_FEATURE_NAME!" "!_select_VAR_FEATURE_VER!" "!_select_VAR_FEATURE_ARCH!" "!_select_VAR_FEATURE_FLAVOUR!" "!_select_VAR_FEATURE_OS_RESTRICTION!" "!_select_VAR_FEATURE_OS_EXCLUSION!"


 	set "_TR_FEATURE_NAME=!%_select_VAR_FEATURE_NAME%!"
 	set "_TR_FEATURE_VER=!%_select_VAR_FEATURE_VER%!"
 	set "_TR_FEATURE_ARCH=!%_select_VAR_FEATURE_ARCH%!"
 	set "_TR_FEATURE_FLAVOUR=!%_select_VAR_FEATURE_FLAVOUR%!"
 	set "_TR_FEATURE_OS_RESTRICTION=!%_select_VAR_FEATURE_OS_RESTRICTION%!"
 	set "_TR_FEATURE_OS_EXCLUSION=!%_select_VAR_FEATURE_OS_EXCLUSION%!"


	set "_found_feat_name=0"
	set "_official=0"
	for %%a in (%__STELLA_FEATURE_LIST%) do (
		if "%%a"=="!_TR_FEATURE_NAME!" set "_found_feat_name=1"
	)

	if "!_found_feat_name!"=="1" (

		REM grab feature info
		call %STELLA_FEATURE_RECIPE%\feature_!_TR_FEATURE_NAME!.bat :feature_!_TR_FEATURE_NAME!

		REM fill schema with default values
		if "!_TR_FEATURE_VER!"=="" (
			set "_TR_FEATURE_VER=!FEAT_DEFAULT_VERSION!"
			if not "!_select_VAR_FEATURE_VER!"=="" set "!_select_VAR_FEATURE_VER!=!FEAT_DEFAULT_VERSION!"
		)
		if "!_TR_FEATURE_ARCH!"=="" (
			set "_TR_FEATURE_ARCH=!FEAT_DEFAULT_ARCH!"
			if not "!_select_VAR_FEATURE_ARCH!"=="" set "!_select_VAR_FEATURE_ARCH!=!FEAT_DEFAULT_ARCH!"
		)
		if "!_TR_FEATURE_FLAVOUR!"=="" (
			set "_TR_FEATURE_FLAVOUR=!FEAT_DEFAULT_FLAVOUR!"
			if not "!_select_VAR_FEATURE_FLAVOUR!"=="" set "!_select_VAR_FEATURE_FLAVOUR!=!FEAT_DEFAULT_FLAVOUR!"
		)


		set "_FILLED_SCHEMA=!_TR_FEATURE_NAME!#!_TR_FEATURE_VER!"
		if not "!_TR_FEATURE_ARCH!"=="" (
			set "_FILLED_SCHEMA=!_FILLED_SCHEMA!@!_TR_FEATURE_ARCH!"
		)
		if not "!_TR_FEATURE_FLAVOUR!"=="" (
			set "_FILLED_SCHEMA=!_FILLED_SCHEMA!:!_TR_FEATURE_FLAVOUR!"
		)

		REM ADDING OS restriction and OS exclusion
		set _OS_OPTION=
		if not "!_TR_FEATURE_OS_RESTRICTION!"=="" (
			set "_OS_OPTION=!_OS_OPTION!/!_TR_FEATURE_OS_RESTRICTION!"
		)
		if not "!_TR_FEATURE_OS_EXCLUSION!"=="" (
			set "_OS_OPTION=!_OS_OPTION!\!_TR_FEATURE_OS_EXCLUSION!"
		)


		REM check filled schema exists
		for %%l in (!FEAT_LIST_SCHEMA!) do (
			if "!_TR_FEATURE_NAME!#%%l"=="!_FILLED_SCHEMA!" (
				if not "!_RESULT_SCHEMA!"=="" (
					set "_official=1"
				)
			)
		)
	)

	if "!_official!" == "1" (
		set "!_RESULT_SCHEMA!=!_FILLED_SCHEMA!!_OS_OPTION!"

	) else (
		REM not official so empty split values

		set "%_select_VAR_FEATURE_NAME%="
		set "%_select_VAR_FEATURE_VER%="
		set "%_select_VAR_FEATURE_ARCH%="
		set "%_select_VAR_FEATURE_FLAVOUR%="
		set "%_select_VAR_FEATURE_OS_RESTRICTION%="
		set "%_select_VAR_FEATURE_OS_EXCLUSION%="
	)

	set "_SCHEMA=!feature_select_schema_ORIGINAL_SCHEMA!"
goto:eof







REM feature schema name[#version][@arch][:flavour][/os_restriction][\os_exclusion] in any order
REM				@arch could be x86 or x64
REM				:flavour could be binary or source
REM example: wget/ubuntu#1_2@x86:source wget/ubuntu#1_2@x86:source\macos
:translate_schema
	set "_trans_schema=%~1"

	set "_VAR_FEATURE_NAME=%~2"
	set "_VAR_FEATURE_VER=%~3"
	set "_VAR_FEATURE_ARCH=%~4"
	set "_VAR_FEATURE_FLAVOUR=%~5"
	set "_VAR_FEATURE_OS_RESTRICTION=%~6"
	set "_VAR_FEATURE_OS_EXCLUSION=%~7"

	set "_tmp="
	set "_tmp=!_trans_schema::="^&REM :!
	set "_tmp=!_tmp:#="^&REM #!
	set "_tmp=!_tmp:@="^&REM @!
	set "_tmp=!_tmp:/="^&REM /!
	set "_tmp=!_tmp:\="^&REM \!
	set "!_VAR_FEATURE_NAME!=!_tmp!"

	REM :
	set "_tmp="
	if not "!_VAR_FEATURE_FLAVOUR!"=="" (
		set "!_VAR_FEATURE_FLAVOUR!="
		if not "x!_trans_schema::=!"=="x!_trans_schema!" (
			set "_tmp=!_trans_schema:*:=!"
			set "_tmp=!_tmp:#="^&REM #!
			set "_tmp=!_tmp:@="^&REM @!
			set "_tmp=!_tmp:/="^&REM /!
			set "_tmp=!_tmp:\="^&REM \!
			set "!_VAR_FEATURE_FLAVOUR!=!_tmp!"
		)
	)

	REM /
	set "_tmp="
	if not "!_VAR_FEATURE_OS_RESTRICTION!"=="" (
		set "!_VAR_FEATURE_OS_RESTRICTION!="
		if not "x!_trans_schema:/=!"=="x!_trans_schema!" (
			set "_tmp=!_trans_schema:*/=!"
			set "_tmp=!_tmp::="^&REM :!
			set "_tmp=!_tmp:#="^&REM #!
			set "_tmp=!_tmp:@="^&REM @!
			set "_tmp=!_tmp:\="^&REM \!
			set "!_VAR_FEATURE_OS_RESTRICTION!=!_tmp!"
		)
	)

	REM \
	set "_tmp="
	if not "!_VAR_FEATURE_OS_EXCLUSION!"=="" (
		set "!_VAR_FEATURE_OS_EXCLUSION!="
		if not "x!_trans_schema:\=!"=="x!_trans_schema!" (
			set "_tmp=!_trans_schema:*\=!"
			set "_tmp=!_tmp:#="^&REM #!
			set "_tmp=!_tmp:@="^&REM @!
			set "_tmp=!_tmp:/="^&REM /!
			set "_tmp=!_tmp::="^&REM :!
			set "!_VAR_FEATURE_OS_EXCLUSION!=!_tmp!"
		)
	)


	REM #
	set "_tmp="
	if not "!_VAR_FEATURE_VER!"=="" (
		set "!_VAR_FEATURE_VER!="
		if not "x!_trans_schema:#=!"=="x!_trans_schema!" (
			set "_tmp=!_trans_schema:*#=!"
			set "_tmp=!_tmp::="^&REM :!
			set "_tmp=!_tmp:@="^&REM @!
			set "_tmp=!_tmp:/="^&REM /!
			set "_tmp=!_tmp:\="^&REM \!
			set "!_VAR_FEATURE_VER!=!_tmp!"
		)
	)


	REM @
	set "_tmp="
	if not "!_VAR_FEATURE_ARCH!"=="" (
		set "!_VAR_FEATURE_ARCH!="
		if not "x!_trans_schema:@=!"=="x!_trans_schema!" (
			set "_tmp=!_trans_schema:*@=!"
			set "_tmp=!_tmp::="^&REM :!
			set "_tmp=!_tmp:#="^&REM #!
			set "_tmp=!_tmp:/="^&REM /!
			set "_tmp=!_tmp:\="^&REM \!
			set "!_VAR_FEATURE_ARCH!=!_tmp!"
		)
	)

goto :eof
