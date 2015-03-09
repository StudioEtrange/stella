@echo off
call %*
goto :eof

:: ------------------------ FEATURES MANAGEMENT-------------------------------

REM feature schema name[#version][@arch][/flavour][:os_restriction] in any order
REM				@arch could be x86 or x64
REM				/flavour could be binary or source
REM example: wget:ubuntu#1_2@x86/source
:translate_feature
	set "_schema=%~1"

	set "_TR_FEATURE_NAME=%~2"
	set "_TR_FEATURE_VER=%~3"
	set "_TR_FEATURE_ARCH=%~4"
	set "_TR_FEATURE_FLAVOUR=%~5"
	set "_TR_FEATURE_OS_RESTRICTION=%~6"
	
	
	
	set "!_TR_FEATURE_NAME!="
	set "!_TR_FEATURE_VER!="
	set "!_TR_FEATURE_ARCH!="
	set "!_TR_FEATURE_FLAVOUR!="
	set "!_TR_FEATURE_OS_RESTRICTION!="

	set "_tmp="
	set "_tmp=!_schema::="^&REM :!
	set "_tmp=!_tmp:#="^&REM #!
	set "_tmp=!_tmp:@="^&REM @!
	set "_tmp=!_tmp:/="^&REM /!
	set "%_TR_FEATURE_NAME%=!_tmp!"

	REM :
	set "_tmp="
	if not "x!_schema::=!"=="x!_schema!" (
		set "_tmp=!_schema:*:=!"
		set "_tmp=!_tmp:#="^&REM #!
		set "_tmp=!_tmp:@="^&REM @!
		set "_tmp=!_tmp:/="^&REM /!
		set "%_TR_FEATURE_OS_RESTRICTION%=!_tmp!"
	)

	REM #
	set "_tmp="
	if not "x!_schema:#=!"=="x!_schema!" (
		set "_tmp=!_schema:*#=!"
		set "_tmp=!_tmp::="^&REM :!
		set "_tmp=!_tmp:@="^&REM @!
		set "_tmp=!_tmp:/="^&REM /!
		set "%_TR_FEATURE_VER%=!_tmp!"
	)

	REM @
	set "_tmp="
	if not "x!_schema:@=!"=="x!_schema!" (
		set "_tmp=!_schema:*@=!"
		set "_tmp=!_tmp::="^&REM :!
		set "_tmp=!_tmp:#="^&REM #!
		set "_tmp=!_tmp:/="^&REM /!
		set "%_TR_FEATURE_ARCH%=!_tmp!"
	)

	REM /
	set "_tmp="
	if not "x!_schema:/=!"=="x!_schema!" (
		set "_tmp=!_schema:*/=!"
		set "_tmp=!_tmp::="^&REM :!
		set "_tmp=!_tmp:#="^&REM #!
		set "_tmp=!_tmp:@="^&REM @!
		set "%_TR_FEATURE_FLAVOUR%=!_tmp!"
	)

goto :eof

:: ARG1 return variable
:list_active_features
	set "%~1=!FEATURE_LIST_ENABLED!"
goto :eof


:info_feature
	set "_FEATURE=%~1"
	call :translate_feature "!_FEATURE!" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR"  "TR_FEATURE_OS_RESTRICTION"

	set TEST_FEATURE=0
	call %STELLA_FEATURE_RECIPE%\feature_!TR_FEATURE_NAME!.bat :feature_!TR_FEATURE_NAME! !TR_FEATURE_VER!
goto :eof


:: ARG2 return variable
:list_feature_version
	set "_FEATURE=%~1"
	set "_VAR=%~2"

	call :translate_feature "!_FEATURE!" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR"  "TR_FEATURE_OS_RESTRICTION"

	set "%_VAR%="
	call %STELLA_FEATURE_RECIPE%\feature_!TR_FEATURE_NAME!.bat :list_!TR_FEATURE_NAME! %_VAR%
goto :eof




:: enable a feature 
:init_feature
	set "_FEATURE=%~1"
	set "_OPT=%~2"

	set _opt_hidden_feature=OFF
	for %%O in (%_OPT%) do (
		if "%%O"=="HIDDEN" set _opt_hidden_feature=ON
	)

	call :translate_feature "!_FEATURE!" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR"  "TR_FEATURE_OS_RESTRICTION"

	set "_VER=!TR_FEATURE_VER!"
	if "%_VER%"=="" (
		set "_V="
		call %STELLA_FEATURE_RECIPE%\feature_!TR_FEATURE_NAME!.bat :default_!TR_FEATURE_NAME! "_V"
		set "_VER=!_V!"
	)

	set _flag=
	for %%A in (!FEATURE_LIST_ENABLED!) do (
		if "%%A"=="!TR_FEATURE_NAME!#!_VER!" set _flag=1
	)
	if "%_flag%"=="" (
		set TEST_FEATURE=0
		call %STELLA_FEATURE_RECIPE%\feature_!TR_FEATURE_NAME!.bat :feature_!TR_FEATURE_NAME! !_VER!
		if "!TEST_FEATURE!"=="1" (
			if not "%_opt_hidden_feature%"=="ON" set "FEATURE_LIST_ENABLED=!FEATURE_LIST_ENABLED! !TR_FEATURE_NAME!#!FEATURE_VER!"
			if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
		)
	)
goto :eof


:init_installed_features


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
						call :init_feature !_folder!#!_ver! "HIDDEN"
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
					call :init_feature !_folder!#!_ver!
				)
			)
		)
	)

	

	if not "!FEATURE_LIST_ENABLED!"=="" echo ** Features initialized : !FEATURE_LIST_ENABLED!
goto :eof



:install_feature_list
	set "_list=%~1"

	for %%F in (%_list%) do (		
		call :install_feature %%F
	)
goto :eof


:install_feature
	set "_FEATURE=%~1"
	set "_OPT=%~2"

	set _opt_hidden_feature=OFF
	for %%O in (%_OPT%) do (
		if "%%O"=="HIDDEN" set _opt_hidden_feature=ON
	)

	call :translate_feature "!_FEATURE!" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR"  "TR_FEATURE_OS_RESTRICTION"

	if "!TR_FEATURE_NAME!"=="required" (
		call %STELLA_COMMON%\platform.bat :__stella_features_requirement_by_os %STELLA_CURRENT_OS%
		goto :eof
	)


	REM check for official feature
	set _flag=
	for %%F in (%__STELLA_FEATURE_LIST%) do (
		if "%%F"=="!TR_FEATURE_NAME!" ( 
			set _flag=1
		)
	)
	if "!_flag!"=="" (
		echo ** Error : unknown feature
		goto :eof
	)

	if not "%_opt_hidden_feature%"=="ON" (
		call %STELLA_COMMON%\common-app.bat :add_app_feature !_FEATURE!
	)

	if not "!TR_FEATURE_OS_RESTRICTION!"=="" (
		if not "!TR_FEATURE_OS_RESTRICTION!"=="!STELLA_CURRENT_OS!" goto :eof
	)

	if "%_opt_hidden_feature%"=="ON" (
		set "_save_app_feature_root=!STELLA_APP_FEATURE_ROOT!"
		set "STELLA_APP_FEATURE_ROOT=!STELLA_INTERNAL_FEATURE_ROOT!"	
	)

	set "_VER=!TR_FEATURE_VER!"
	if "!_VER!"=="" (
		set _V=
		call %STELLA_FEATURE_RECIPE%\feature_!TR_FEATURE_NAME!.bat :default_%_FEATURE% "_V"
		set _VER=!_V!
	)

	set _flag=
	if not "%FORCE%"=="1" (
		for %%A in (!FEATURE_LIST_ENABLED!) do (
			if "%%A"=="!TR_FEATURE_NAME!#!_VER!" set _flag=1
		)
	)
	

	if "!_flag!"=="" (
		set TEST_FEATURE=0
		call %STELLA_FEATURE_RECIPE%\feature_!TR_FEATURE_NAME!.bat :install_!TR_FEATURE_NAME! !_VER!
		call :init_feature !_FEATURE! !_OPT!
	) else (
		echo ** Feature !TR_FEATURE_NAME!#!_VER! already installed
		call :init_feature !_FEATURE! !_OPT!
	)

	if "%_opt_hidden_feature%"=="ON" (
		set "STELLA_APP_FEATURE_ROOT=!_save_app_feature_root!"	
	)

goto :eof

:: reinit all feature previously enabled
:reinit_installed_features
	set FEATURE_LIST_ENABLED=
	call :init_installed_features
goto :eof



