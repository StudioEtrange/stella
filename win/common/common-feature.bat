@echo off
call %*
goto :eof

:: ------------------------ FEATURES MANAGEMENT-------------------------------
:init_installed_features

	for /D %%A in ( %STELLA_APP_FEATURE_ROOT%\* ) do (
		set "_folder=%%~nxA"
		REM check for version
		for %%F in (%__STELLA_FEATURE_LIST%) do (
			if "%%F"=="!_folder!" ( 
				REM for each detected version
				for /D %%V in (%%F\*) do (
					call :init_feature !_folder! %%V
				)
			)
		)
	)

	if not "%FEATURE_LIST_ENABLED%"=="" echo ** Features initialized : %FEATURE_LIST_ENABLED%
goto :eof

:: ARG2 return variable
:list_feature_version
	set "_FEATURE=%~1"
	set "_VAR=%~2"

	call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :list_%_FEATURE% %_VAR%
goto :eof

:: ARG1 return variable
:list_active_features
	set "%~1=!FEATURE_LIST_ENABLED!"
goto :eof

:: enable a feature 
:init_feature
	set "_FEATURE=%~1"
	set "_VER=%~2"

	if "%_VER%"=="" (
		set "_V="
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :default_%_FEATURE% "_V"
		set "_VER=!_V!"
	)

	set _flag=
	for %%A in (%FEATURE_LIST_ENABLED%) do (
		if "%%A"=="%_FEATURE%#!_VER!" set _flag=1
	)
	if "%_flag%"=="" (
		set FEATURE_PATH=
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :feature_%_FEATURE% !_VER!
		if "!TEST_FEATURE!"=="1" (
			set "FEATURE_LIST_ENABLED=!FEATURE_LIST_ENABLED! %_FEATURE%#!FEATURE_VER!"
			if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
		)
	)

goto :eof

:install_feature_list
	set "_list=%~1"

	for %%F in (%_list%) do (		
		set item=%%F

		if not "x!item:#=!"=="x!item!" (
			set _VER=!item:*#=!
			set "_FEAT=!item:#="^&REM #!
		) else (
			set _VER=
			set _FEAT=!item!
		)
		call :install_feature !_FEAT! !_VER!
	)

goto :eof

:install_feature
	set "_FEATURE=%~1"
	set "_VER=%~2"
	set "_OPT=%~3"

	set _opt_hidden_feature=OFF
	for %%O in (%_OPT%) do (
		if "%%O"=="HIDDEN" set _opt_hidden_feature=ON
	)


	if "%_FEATURE%"=="required" (
		call %STELLA_COMMON%\platform.bat :__stella_features_requirement_by_os %STELLA_CURRENT_OS%
		goto :eof
	)

	if "%_opt_hidden_feature%"=="OFF" (
		call %STELLA_COMMON%\common-app.bat :add_app_feature !_FEATURE! !_VER!
	)

	if "!_VER!"=="" (
		set _V=
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :default_%_FEATURE% "_V"
		set _VER=!_V!
	)

	set _flag=
	for %%A in (%FEATURE_LIST_ENABLED%) do (
		if "%%A"=="%_FEATURE%#!_VER!" set _flag=1
	)
	
	if "%FORCE%"=="1" (
		if "!_flag!"=="1" (
			call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :install_%_FEATURE% !_VER!
		)
	)
	

	if "!_flag!"=="" (
		set FEATURE_PATH=
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :install_%_FEATURE% !_VER!
		if "!TEST_FEATURE!"=="1" (
			set "FEATURE_LIST_ENABLED=!FEATURE_LIST_ENABLED! %_FEATURE%#!FEATURE_VER!"
			if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
		)
	) else (
		if not "%FORCE%"=="1" (
			echo ** Feature %_FEATURE%#!_VER! already installed
		)
	)
goto :eof

:: reinit all feature previously enabled
:reinit_all_features
	for %%F in (%FEATURE_LIST_ENABLED%) do (
		set item=%%F

		set _VER=!item:*#=!
		set "_FEAT=!item:#="^&REM #!

		set FEATURE_PATH=
		call %STELLA_FEATURE_RECIPE%\feature_!_FEAT!.bat :feature_!_FEAT! !_VER!
		if "!TEST_FEATURE!"=="1" (
			if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
		)
	)
goto :eof



