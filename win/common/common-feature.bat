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

	set "flag=0"
	for %%a in (!FEATURE_LIST_ENABLED!) do (
		if "!FEAT_NAME!#!FEAT_VERSION!"=="%%a" set _flag=1
	)

	if "%_flag%"=="0" (
		call :feature_is_installed !FEAT_SCHEMA_SELECTED!
		if "!TEST_FEATURE!"=="1" (
			if not "%_opt_hidden_feature%"=="ON" set "FEATURE_LIST_ENABLED=!FEATURE_LIST_ENABLED! !FEAT_NAME!#!FEAT_VERSION!"
			if not "!FEAT_SEARCH_PATH!"=="" set "PATH=!FEAT_SEARCH_PATH!;!PATH!"

			if not "!FEAT_ENV!"=="" (
				call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :!FEAT_ENV!
			)
		)
	)
goto :eof



REM get information on feature (installed or not)
:feature_info
	set "_SCHEMA=%~1"
	call :internal_feature_context %_SCHEMA%
goto :eof

:feature_is_installed
	set "_SCHEMA=%~1"

	call :internal_feature_context %_SCHEMA%
	
	set TEST_FEATURE=0

	if not "!FEAT_BUNDLE_LIST!"=="" (
		set "_t=1"
		set "save_FEAT_INSTALL_ROOT=!FEAT_INSTALL_ROOT!"
		
		set "FEAT_BUNDLE_EMBEDDED_PATH="
		if "!FEAT_BUNDLE_EMBEDDED!"=="TRUE" (
			set "FEAT_BUNDLE_EMBEDDED_PATH=!save_FEAT_INSTALL_ROOT!"
		)

		for %%p in (!FEAT_BUNDLE_LIST!) do (
			set "TEST_FEATURE=0"
			call :feature_is_installed %%p
			if "!TEST_FEATURE!"=="0" (
				set "_t=0"
			)
		)
		set "FEAT_BUNDLE_EMBEDDED_PATH="

		call :internal_feature_context %_SCHEMA%
		set "TEST_FEATURE=$_t"
		REM if "!TEST_FEATURE!"=="1" (
			REM echo ** BUNDLE Detected in !save_FEAT_INSTALL_ROOT!
		REM )
	) else (
		if exist "!FEAT_INSTALL_TEST!" (
			set "TEST_FEATURE=1"
			REM echo ** FEATURE Detected in !FEAT_INSTALL_ROOT!
		)
	)
goto :eof

:feature_install_list
	set "_list=%~1"

	for %%f in (%_list) do (
		call :feature_install %%f
	)
goto :eof




:feature_install
	set "_SCHEMA=%~1"
	set "_OPT=%~2"

	set _opt_internal_feature=OFF
	set _opt_hidden_feature=OFF
	for %%O in (%_OPT%) do (
		if "%%O"=="INTERNAL" set _opt_internal_feature=ON
		if "%%O"=="HIDDEN" set _opt_hidden_feature=ON
	)

	if "!_SCHEMA!"=="required" (
		call %STELLA_COMMON%\platform.bat :__stella_features_requirement_by_os %STELLA_CURRENT_OS%
		goto :eof
	)

	call :internal_feature_context %_SCHEMA%

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

		if not "!FEAT_SCHEMA_OS_RESTRICTION!"=="" (
			if not "!FEAT_SCHEMA_OS_RESTRICTION!"=="!STELLA_CURRENT_OS!" goto :eof
		)

		if "%FORCE%"=="1" (
			set TEST_FEATURE=0
			call %STELLA_COMMON%\common.bat :del_folder !FEAT_INSTALL_ROOT!
		) else (
			call :feature_is_installed !FEAT_SCHEMA_SELECTED!
		)

		if "!TEST_FEATURE!"=="0" (
			if not exist !FEAT_INSTALL_ROOT! mkdir !FEAT_INSTALL_ROOT!

			if not "!FEAT_BUNDLE_LIST!"=="" (
				set "save_FORCE=%FORCE%"
				set "save_FEAT_INSTALL_ROOT=!FEAT_INSTALL_ROOT!"
				set "FORCE=0"

				set "FEAT_BUNDLE_EMBEDDED_PATH="
				set " _flag_hidden="
				if "!FEAT_BUNDLE_EMBEDDED!"=="TRUE" (
					set "FEAT_BUNDLE_EMBEDDED_PATH=!save_FEAT_INSTALL_ROOT!"
					set "_flag_hidden=HIDDEN"
				)

				for %%p in (!FEAT_BUNDLE_LIST!) do (
					call :feature_install %%p "!_OPT! !_flag_hidden!"
				)
				set "FEAT_BUNDLE_EMBEDDED_PATH="
				
				set "FORCE=!save_FORCE!"
				call :internal_feature_context %_SCHEMA%

			) else (
				echo Installing !FEAT_NAME! version !FEAT_VERSION! in !FEAT_INSTALL_ROOT!
				call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :feature_!FEAT_NAME!_install_!FEAT_SCHEMA_FLAVOUR!
			)


			call :feature_is_installed !FEAT_SCHEMA_SELECTED!
			if "!TEST_FEATURE!"=="1" (
				echo ** Feature !_SCHEMA! is installed
				call :feature_init "!FEAT_SCHEMA_SELECTED!" !_OPT!
			) else (
				echo ** Error while installing feature !FEAT_SCHEMA_SELECTED!
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
	FEATURE_LIST_ENABLED=
	call :feature_init_installed
goto :eof


:feature_apply_source_callback
	for %%p in (!FEAT_SOURCE_CALLBACK!) do (
		call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME! :%%p
	)
goto :eof


:feature_apply_binary_callback
	for %%p in (!FEAT_BINARY_CALLBACK!) do (
		call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME! :%%p
	)
goto :eof

:internal_feature_context
	set "_SCHEMA=%~1"
	set "_ORIGINAL_SCHEMA=%~1"

	set "FEAT_ARCH="
	
	set "TMP_FEAT_SCHEMA_NAME="
	set "TMP_FEAT_SCHEMA_VERSION="
	set "FEAT_SCHEMA_SELECTED="
	set "FEAT_SCHEMA_FLAVOUR="
	set "FEAT_SCHEMA_OS_RESTRICTION="


	call :select_schema !_SCHEMA! "FEAT_SCHEMA_SELECTED"

	
	set "FEAT_NAME="
	set "FEAT_LIST_SCHEMA="
	set "FEAT_DEFAULT_VERSION="
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR="
	set "FEAT_VERSION="
	set "FEAT_SOURCE_URL="
	set "FEAT_SOURCE_URL_FILENAME="
	set "FEAT_SOURCE_CALLBACK="
	set "FEAT_BINARY_URL="
	set "FEAT_BINARY_URL_FILENAME="
	set "FEAT_BINARY_CALLBACK="
	set "FEAT_DEPENDENCIES="
	set "FEAT_INSTALL_TEST="
	set "FEAT_INSTALL_ROOT="
	set "FEAT_SEARCH_PATH="
	set "FEAT_BUNDLE_LIST="
	
	REM TRUE / FALSE
	set "FEAT_BUNDLE_EMBEDDED="

	if not "!FEAT_SCHEMA_SELECTED!"=="" (
		
		call :translate_schema !FEAT_SCHEMA_SELECTED! "TMP_FEAT_SCHEMA_NAME" "TMP_FEAT_SCHEMA_VERSION" "FEAT_ARCH" "FEAT_SCHEMA_FLAVOUR" "FEAT_SCHEMA_OS_RESTRICTION"

		REM set install root
		if "!FEAT_BUNDLE_EMBEDDED_PATH!"=="" (
			if not "!FEAT_ARCH!"=="" (
				set "FEAT_INSTALL_ROOT=!STELLA_APP_FEATURE_ROOT!\!TMP_FEAT_SCHEMA_NAME!\!TMP_FEAT_SCHEMA_VERSION!@!FEAT_ARCH!"
			) else (
				set "FEAT_INSTALL_ROOT=!STELLA_APP_FEATURE_ROOT!\!TMP_FEAT_SCHEMA_NAME!\!TMP_FEAT_SCHEMA_VERSION!"
			)

		) else (
			set "FEAT_INSTALL_ROOT=!FEAT_BUNDLE_EMBEDDED_PATH!"
		)

		REM grab feature info
		call %STELLA_FEATURE_RECIPE%\feature_!TMP_FEAT_SCHEMA_NAME!.bat :feature_!TMP_FEAT_SCHEMA_NAME!
		call %STELLA_FEATURE_RECIPE%\feature_!TMP_FEAT_SCHEMA_NAME!.bat :feature_!TMP_FEAT_SCHEMA_NAME!_!TMP_FEAT_SCHEMA_VERSION!

		REM set url dependending on arch
		if not "!FEAT_ARCH!"=="" (
			set "_tmp=!FEAT_BINARY_URL!_!FEAT_ARCH!"
			set "FEAT_BINARY_URL=!%_tmp%!"
			set "_tmp=!FEAT_BINARY_URL_FILENAME!_!FEAT_ARCH!"
			set "FEAT_BINARY_URL_FILENAME=!%_tmp%!"
		)
	)

	set "_SCHEMA=%_ORIGINAL_SCHEMA%"

goto :eof




:select_schema
	set "_SCHEMA=%~1"
	set "_RESULT_SCHEMA=%~2"

	set "_FILLED_SCHEMA="

	if not "!_RESULT_SCHEMA!"=="" (
		set "!_RESULT_SCHEMA!="
	)

 	call :translate_schema "!_SCHEMA!" "_TR_FEATURE_NAME" "_TR_FEATURE_VER" "_TR_FEATURE_ARCH" "_TR_FEATURE_FLAVOUR"

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
			set "_FILLED_SCHEMA=!_FILLED_SCHEMA!/!_TR_FEATURE_FLAVOUR!"
		)
		
		REM check filled schema exists
		set "_flag=0"
		for %%l in (!FEAT_LIST_SCHEMA!) do (
			if "!_TR_FEATURE_NAME!#%%l"=="!_FILLED_SCHEMA!" (
				if not "!_RESULT_SCHEMA!"=="" (
					set "!_RESULT_SCHEMA!=!_FILLED_SCHEMA!"
				)
			)
		)
	)

goto:eof




REM feature schema name[#version][@arch][/flavour][:os_restriction] in any order
REM				@arch could be x86 or x64
REM				/flavour could be binary or source
REM example: wget:ubuntu#1_2@x86/source
:translate_schema
	set "_schema=%~1"

	set "_VAR_FEATURE_NAME=%~2"
	set "_VAR_FEATURE_VER=%~3"
	set "_VAR_FEATURE_ARCH=%~4"
	set "_VAR_FEATURE_FLAVOUR=%~5"
	set "_VAR_FEATURE_OS_RESTRICTION=%~6"

	
	set "!_VAR_FEATURE_NAME!="
	if not "!_VAR_FEATURE_VER!"=="" set "!_VAR_FEATURE_VER!="
	if not "!_VAR_FEATURE_ARCH!"=="" set "!_VAR_FEATURE_ARCH!="
	if not "!_VAR_FEATURE_FLAVOUR!"=="" set "!_VAR_FEATURE_FLAVOUR!="
	if not "!_VAR_FEATURE_OS_RESTRICTION!"=="" set "!_VAR_FEATURE_OS_RESTRICTION!="

	set "_tmp="
	set "_tmp=!_schema::="^&REM :!
	set "_tmp=!_tmp:#="^&REM #!
	set "_tmp=!_tmp:@="^&REM @!
	set "_tmp=!_tmp:/="^&REM /!
	set "%_VAR_FEATURE_NAME%=!_tmp!"

	REM :
	if not "!_VAR_FEATURE_OS_RESTRICTION!"=="" (
		set "_tmp="
		if not "x!_schema::=!"=="x!_schema!" (
			set "_tmp=!_schema:*:=!"
			set "_tmp=!_tmp:#="^&REM #!
			set "_tmp=!_tmp:@="^&REM @!
			set "_tmp=!_tmp:/="^&REM /!
			set "%_VAR_FEATURE_OS_RESTRICTION%=!_tmp!"
		)
	)

	REM #
	if not "!_VAR_FEATURE_VER!"=="" (
		set "_tmp="
		if not "x!_schema:#=!"=="x!_schema!" (
			set "_tmp=!_schema:*#=!"
			set "_tmp=!_tmp::="^&REM :!
			set "_tmp=!_tmp:@="^&REM @!
			set "_tmp=!_tmp:/="^&REM /!
			set "%_VAR_FEATURE_VER%=!_tmp!"
		)
	)

	REM @
	if not "!_VAR_FEATURE_ARCH!"=="" (
		set "_tmp="
		if not "x!_schema:@=!"=="x!_schema!" (
			set "_tmp=!_schema:*@=!"
			set "_tmp=!_tmp::="^&REM :!
			set "_tmp=!_tmp:#="^&REM #!
			set "_tmp=!_tmp:/="^&REM /!
			set "%_VAR_FEATURE_ARCH%=!_tmp!"
		)
	)

	REM /
	if not "!_VAR_FEATURE_OS_RESTRICTION!"=="" (
		set "_tmp="
		if not "x!_schema:/=!"=="x!_schema!" (
			set "_tmp=!_schema:*/=!"
			set "_tmp=!_tmp::="^&REM :!
			set "_tmp=!_tmp:#="^&REM #!
			set "_tmp=!_tmp:@="^&REM @!
			set "%_VAR_FEATURE_FLAVOUR%=!_tmp!"
		)
	)
goto :eof





