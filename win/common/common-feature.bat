@echo off
call %*
goto :eof

:: ------------------------ FEATURES MANAGEMENT-------------------------------
:init_all_features
	for %%F in (%__STELLA_FEATURE_LIST%) do (
		call :init_feature %%F
	)
	if not "%FEATURE_LIST_ENABLED%"=="" echo ** Features initialized : %FEATURE_LIST_ENABLED%
goto :eof

:: ARG2 return variable
:list_feature_version
	set "_FEATURE=%~1"
	set "_VAR=%~2"

	call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :list_%_FEATURE% %_VAR%
goto :eof


:: enable a feature 
:init_feature
	set "_FEATURE=%~1"
	set "_VER=%~2"

	if "%_VER%"=="" (
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :default_%_FEATURE% "_VER"
	)

	set _flag=
	for %%A in (%FEATURE_LIST_ENABLED%) do (
		if "%%A"=="%_FEATURE%#!_VER!" set _flag=1
	)
	if "%_flag%"=="" (
		set FEATURE_PATH=
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :feature_%_FEATURE% !_VER!
		if not "!TEST_FEATURE!"=="0" (
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

	call %STELLA_COMMON%\common-app.bat :add_app_feature %_FEATURE% %_VER%

	if "%_VER%"=="" (
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :default_%_FEATURE% "_VER"
	)

	set _flag=
	for %%A in (%FEATURE_LIST_ENABLED%) do (
		if "%%A"=="%_FEATURE%#!_VER!" set _flag=1
	)
	
	

	if "%_flag%"=="" (
		set FEATURE_PATH=
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :install_%_FEATURE% !_VER!
		if not "!TEST_FEATURE!"=="0" (
			set "FEATURE_LIST_ENABLED=!FEATURE_LIST_ENABLED! %_FEATURE%#!FEATURE_VER!"
			if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
		)
	) else (
		echo ** Feature %_FEATURE%#!_VER! already installed
	)
goto :eof

:: reinit all feature previously enabled
:reinit_all_features
	for %%F in (%FEATURE_LIST_ENABLED%) do (
		set item=%%F
		set _VER=%item:*#=%
		set "_FEAT=%item:#="^&REM #%
		set FEATURE_PATH=
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :feature_!_FEAT! !_VER!
		if not "!TEST_FEATURE!"=="0" (
			if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
		)
	)
goto :eof



