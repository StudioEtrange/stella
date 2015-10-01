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
				set "save_FEAT_SCHEMA_SELECTED_0=!FEAT_SCHEMA_SELECTED!"		

				set "FEAT_BUNDLE_MODE=!FEAT_BUNDLE!"

				for %%p in (!FEAT_BUNDLE_ITEM!) do (
					call :feature_init %%p "HIDDEN"
				)
				set "FEAT_BUNDLE_MODE="

				REM re-compute bundle variables
				set "FEAT_SCHEMA_SELECTED=!save_FEAT_SCHEMA_SELECTED_0!"
				call :internal_feature_context !FEAT_SCHEMA_SELECTED!
			)
			
			if not "!save_opt_hidden_feature!"=="ON" set "FEATURE_LIST_ENABLED=!FEATURE_LIST_ENABLED! !FEAT_NAME!#!FEAT_VERSION!"
			if not "!FEAT_SEARCH_PATH!"=="" set "PATH=!FEAT_SEARCH_PATH!;!PATH!"

			
			for %%p in (!FEAT_ENV_CALLBACK!) do (
				call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :%%p
			)

		)
	)
goto :eof



REM get information on feature (from catalog)
:feature_catalog_info
	set "_SCHEMA=%~1"
	call :internal_feature_context %_SCHEMA%
goto :eof


:: look for information about an installed feature
:feature_match_installed
	set "_SCHEMA=%~1"

	set "_tested="
	set "_found="

	REM we are NOT inside a bundle, because FEAT_BUNDLE_MODE is NOT set
	if "!FEAT_BUNDLE_MODE!"=="" (
		call :translate_schema !_SCHEMA! "__VAR_FEATURE_NAME" "__VAR_FEATURE_VER" "__VAR_FEATURE_ARCH" "__VAR_FEATURE_FLAVOUR"

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
		call :internal_feature_context !_SCHEMA!
	)

goto :eof


:: test if a feature is installed
:: AND retrieve informations based on actually installed feature (looking inside STELLA_APP_FEATURE_ROOT) OR from feature recipe if not installed
:: do not use default values from feature recipe to search installed feature
:feature_inspect
	set "_SCHEMA=%~1"
	set "feature_inspect_ORIGINAL_SCHEMA=%~1"

	set TEST_FEATURE=0

	call :feature_match_installed %_SCHEMA%
	set "_SCHEMA=!feature_inspect_ORIGINAL_SCHEMA!"

	if not "!FEAT_SCHEMA_SELECTED!"=="" (
		if not "!FEAT_BUNDLE!"=="" (
			set "_t=1"
			set "FEAT_BUNDLE_MODE=!FEAT_BUNDLE!"
			
			set "save_FEAT_SCHEMA_SELECTED_1=!FEAT_SCHEMA_SELECTED!"
			for %%p in (!FEAT_BUNDLE_ITEM!) do (
				set "TEST_FEATURE=0"
				call :feature_inspect %%p
				if "!TEST_FEATURE!"=="0" (
					set "_t=0"
				)
			)
			set "FEAT_BUNDLE_MODE="
			set "FEAT_SCHEMA_SELECTED=!save_FEAT_SCHEMA_SELECTED_1!"
			call :internal_feature_context !FEAT_SCHEMA_SELECTED!
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
		call :feature_catalog_info %_SCHEMA%
	)
goto :eof



 :feature_remove
	set "_SCHEMA=%~1"
	set "_OPT=%~2"

	set _opt_internal_feature=OFF
	set _opt_hidden_feature=OFF
	for %%O in (%_OPT%) do (
		if "%%O"=="INTERNAL" set _opt_internal_feature=ON
		if "%%O"=="HIDDEN" set _opt_hidden_feature=ON
	)

	call :feature_inspect %_SCHEMA%
	
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
		call %STELLA_COMMON%\common-app.bat :remove_app_feature !_SCHEMA!
	)

	if "!TEST_FEATURE!"=="1" (

		if not "!FEAT_BUNDLE!"=="" (
			echo Remove bundle !FEAT_NAME! version !FEAT_VERSION!
			call %STELLA_COMMON%\common.bat :del_folder !FEAT_INSTALL_ROOT!

			set "save_FEAT_SCHEMA_SELECTED_2=!FEAT_SCHEMA_SELECTED!"
			set "FEAT_BUNDLE_MODE=!FEAT_BUNDLE!"
			for %%p in (!FEAT_BUNDLE_ITEM!) do (
				call :feature_remove %%p "HIDDEN"
			)
			set "FEAT_BUNDLE_MODE="
			set "FEAT_SCHEMA_SELECTED=!save_FEAT_SCHEMA_SELECTED_2!"

			REM compute bundle variables
			call :internal_feature_context !FEAT_SCHEMA_SELECTED!
			
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
	for %%O in (%_OPT%) do (
		if "%%O"=="INTERNAL" set _opt_internal_feature=ON
		if "%%O"=="HIDDEN" set _opt_hidden_feature=ON
		if "%%O"=="DEP_FORCE" set _opt_force_reinstall_dep=1
		if "%%O"=="DEP_IGNORE" set _opt_ignore_dep=ON
	)

	REM if "!_SCHEMA!"=="required" (
	REM	call %STELLA_COMMON%\common-platform.bat :__install_minimal_feature_requirement
	REM 	goto :eof
	REM )

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
			call %STELLA_COMMON%\common.bat :del_folder !FEAT_INSTALL_ROOT!
		) else (
			call :feature_inspect !FEAT_SCHEMA_SELECTED!
		)

		if "!TEST_FEATURE!"=="0" (

			if not exist "!FEAT_INSTALL_ROOT!" mkdir "!FEAT_INSTALL_ROOT!"

			REM dependencies
			if "!IGNORE_DEP!"=="OFF" (
				REM TODO see unix implementation : stack call is inside dependencies loop
				set "save_FORCE=%FORCE%"
				set "FORCE=!_opt_force_reinstall_dep!"
				set "save_FEAT_SCHEMA_SELECTED_3=!FEAT_SCHEMA_SELECTED!"

				set _f_dep=0
				if "!FEAT_SCHEMA_FLAVOUR!"=="source" (
					for %%p in (!FEAT_SOURCE_DEPENDENCIES!) do (
						echo Installing dependency %%p
						REM TODO put stack call HERE
						call :feature_install %%p "!_OPT! HIDDEN"
						if "!TEST_FEATURE!"=="0" (
							echo ** Error while installing dependency feature !FEAT_SCHEMA_SELECTED!
						)
						REM TODO put stack call HERE
						set _f_dep=1
					)
				)

				if "!FEAT_SCHEMA_FLAVOUR!"=="binary" (
					for %%p in (!FEAT_BINARY_DEPENDENCIES!) do (
						echo Installing dependency %%p
						REM TODO put stack call HERE
						call :feature_install %%p "!_OPT! HIDDEN"
						if "!TEST_FEATURE!"=="0" (
							echo ** Error while installing dependency feature !FEAT_SCHEMA_SELECTED!
						)
						REM TODO put stack call HERE
						set _f_dep=1
					)
				)
				set "FORCE=!save_FORCE!"
				set "FEAT_SCHEMA_SELECTED=!save_FEAT_SCHEMA_SELECTED_3!"
				if "!_f_dep!"=="1" call :internal_feature_context !FEAT_SCHEMA_SELECTED!
			)


			REM bundle
			if not "!FEAT_BUNDLE!"=="" (
				set "FEAT_BUNDLE_MODE=!FEAT_BUNDLE!"
				
				if not "!FEAT_BUNDLE_ITEM!"=="" (

					set "save_FEAT_SCHEMA_SELECTED_4=!FEAT_SCHEMA_SELECTED!"

					if not "!FEAT_BUNDLE_MODE!"=="LIST" (
						set "save_FORCE=%FORCE%"
						set "FORCE=0"
					)

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

					set "FEAT_SCHEMA_SELECTED=!save_FEAT_SCHEMA_SELECTED_4!"
					call :internal_feature_context !FEAT_SCHEMA_SELECTED!
					
				)
				set "FEAT_BUNDLE_MODE="
				
				
				REM automatic call of callback
				call :feature_callback
			) else (
				echo Installing !FEAT_NAME! version !FEAT_VERSION! in !FEAT_INSTALL_ROOT!
				call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :feature_!FEAT_NAME!_install_!FEAT_SCHEMA_FLAVOUR!
			)

			call :feature_inspect !FEAT_SCHEMA_SELECTED!
			if "!TEST_FEATURE!"=="1" (
				echo ** Feature !_SCHEMA! is installed
				call :feature_init "!FEAT_SCHEMA_SELECTED!" !_OPT!
			) else (
				echo ** Error while installing feature !FEAT_SCHEMA_SELECTED!
				REM Sometimes current directory is lost by the system
				cd /D %STELLA_APP_ROOT%
			)

		) else (
			echo ** Feature !_SCHEMA! already installed
			call :feature_init "!FEAT_SCHEMA_SELECTED!" !_OPT!
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
			call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :%%p
		)
	) else (
		
		if "!FEAT_SCHEMA_FLAVOUR!"=="source" (
			for %%p in (!FEAT_SOURCE_CALLBACK!) do (
				call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :%%p
			)
		)

		if "!FEAT_SCHEMA_FLAVOUR!"=="binary" (
			for %%p in (!FEAT_BINARY_CALLBACK!) do (
				call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :%%p
			)
		)

	)
goto :eof

REM init feature context (properties, variables, ...)
:internal_feature_context
	set "_SCHEMA=%~1"
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
	REM MERGE / NESTED / LIST
	set "FEAT_BUNDLE="

	if not "!_SCHEMA!"=="" (
		REM TODO we call translate_schema inside select_official_schema, so double call
		call :select_official_schema !_SCHEMA! "FEAT_SCHEMA_SELECTED"
	)

	if not "!FEAT_SCHEMA_SELECTED!"=="" (

		call :translate_schema "!FEAT_SCHEMA_SELECTED!" "TMP_FEAT_SCHEMA_NAME" "TMP_FEAT_SCHEMA_VERSION" "FEAT_ARCH" "FEAT_SCHEMA_FLAVOUR" "FEAT_SCHEMA_OS_RESTRICTION" "FEAT_SCHEMA_OS_EXCLUSION"

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
		call :translate_schema !_SCHEMA! "NONE" "NONE" "NONE" "NONE" "FEAT_SCHEMA_OS_RESTRICTION" "FEAT_SCHEMA_OS_EXCLUSION"
	)

	set "_SCHEMA=!feature_context_ORIGINAL_SCHEMA!"
goto :eof


REM select an official schema
REM pick a feature schema by filling some values with default one
:select_official_schema
	set "_SCHEMA=%~1"
	set "feature_select_schema_ORIGINAL_SCHEMA=%~1"
	set "_RESULT_SCHEMA=%~2"

	

	set "_FILLED_SCHEMA="

	if not "!_RESULT_SCHEMA!"=="" (
		set "!_RESULT_SCHEMA!="
	)

 	call :translate_schema "!_SCHEMA!" "_TR_FEATURE_NAME" "_TR_FEATURE_VER" "_TR_FEATURE_ARCH" "_TR_FEATURE_FLAVOUR" "_TR_FEATURE_OS_RESTRICTION" "_TR_FEATURE_OS_EXCLUSION"

	set "_official=0"
	for %%a in (%__STELLA_FEATURE_LIST%) do (
		if "%%a"=="!_TR_FEATURE_NAME!" set "_official=1"
	)

	if "%_official%"=="1" (

		REM grab feature info
		call %STELLA_FEATURE_RECIPE%\feature_!_TR_FEATURE_NAME!.bat :feature_!_TR_FEATURE_NAME!

		REM fill schema with default values
		if "!_TR_FEATURE_VER!"=="" (
			set "_TR_FEATURE_VER=!FEAT_DEFAULT_VERSION!"
		)
		if "!_TR_FEATURE_ARCH!"=="" (
			set "_TR_FEATURE_ARCH=!FEAT_DEFAULT_ARCH!"
		)
		if "!_TR_FEATURE_FLAVOUR!"=="" (
			set "_TR_FEATURE_FLAVOUR=!FEAT_DEFAULT_FLAVOUR!"
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
					set "!_RESULT_SCHEMA!=!_FILLED_SCHEMA!!_OS_OPTION!"
				)
			)
		)
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

	
	set "!_VAR_FEATURE_NAME!="
	if not "!_VAR_FEATURE_VER!"=="" set "!_VAR_FEATURE_VER!="
	if not "!_VAR_FEATURE_ARCH!"=="" set "!_VAR_FEATURE_ARCH!="
	if not "!_VAR_FEATURE_FLAVOUR!"=="" set "!_VAR_FEATURE_FLAVOUR!="
	if not "!_VAR_FEATURE_OS_RESTRICTION!"=="" set "!_VAR_FEATURE_OS_RESTRICTION!="
	if not "!_VAR_FEATURE_OS_EXCLUSION!"=="" set "!_VAR_FEATURE_OS_EXCLUSION!="

	set "_tmp="
	set "_tmp=!_trans_schema::="^&REM :!
	set "_tmp=!_tmp:#="^&REM #!
	set "_tmp=!_tmp:@="^&REM @!
	set "_tmp=!_tmp:/="^&REM /!
	set "_tmp=!_tmp:\="^&REM \!
	set "%_VAR_FEATURE_NAME%=!_tmp!"



	REM :
	set "_tmp="
	if not "!_VAR_FEATURE_FLAVOUR!"=="" (
		if not "x!_trans_schema::=!"=="x!_trans_schema!" (
			set "_tmp=!_trans_schema:*:=!"
			set "_tmp=!_tmp:#="^&REM #!
			set "_tmp=!_tmp:@="^&REM @!
			set "_tmp=!_tmp:/="^&REM /!
			set "_tmp=!_tmp:\="^&REM \!
			set "%_VAR_FEATURE_FLAVOUR%=!_tmp!"
		)
	)

	REM /
	set "_tmp="
	if not "!_VAR_FEATURE_OS_RESTRICTION!"=="" (
		if not "x!_trans_schema:/=!"=="x!_trans_schema!" (
			set "_tmp=!_trans_schema:*/=!"
			set "_tmp=!_tmp::="^&REM :!
			set "_tmp=!_tmp:#="^&REM #!
			set "_tmp=!_tmp:@="^&REM @!
			set "_tmp=!_tmp:\="^&REM \!
			set "%_VAR_FEATURE_OS_RESTRICTION%=!_tmp!"
		)
	)

	REM \
	set "_tmp="
	if not "!_VAR_FEATURE_OS_EXCLUSION!"=="" (
		if not "x!_trans_schema:\=!"=="x!_trans_schema!" (
			set "_tmp=!_trans_schema:*\=!"
			set "_tmp=!_tmp:#="^&REM #!
			set "_tmp=!_tmp:@="^&REM @!
			set "_tmp=!_tmp:/="^&REM /!
			set "_tmp=!_tmp::="^&REM :!
			set "%_VAR_FEATURE_OS_EXCLUSION%=!_tmp!"
		)
	)
	

	REM #
	set "_tmp="
	if not "!_VAR_FEATURE_VER!"=="" (
		if not "x!_trans_schema:#=!"=="x!_trans_schema!" (
			set "_tmp=!_trans_schema:*#=!"
			set "_tmp=!_tmp::="^&REM :!
			set "_tmp=!_tmp:@="^&REM @!
			set "_tmp=!_tmp:/="^&REM /!
			set "_tmp=!_tmp:\="^&REM \!
			set "%_VAR_FEATURE_VER%=!_tmp!"
		)
	)

	REM @
	set "_tmp="
	if not "!_VAR_FEATURE_ARCH!"=="" (
		if not "x!_trans_schema:@=!"=="x!_trans_schema!" (
			set "_tmp=!_trans_schema:*@=!"
			set "_tmp=!_tmp::="^&REM :!
			set "_tmp=!_tmp:#="^&REM #!
			set "_tmp=!_tmp:/="^&REM /!
			set "_tmp=!_tmp:\="^&REM \!
			set "%_VAR_FEATURE_ARCH%=!_tmp!"
		)
	)

goto :eof





