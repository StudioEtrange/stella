@echo off
call %*
goto :eof

:list_jom
	set "%~1=1_0_13"
goto :eof

:default_jom
	set "%~1=1_0_13"
goto :eof

:install_jom
	set "_VER=%~1"
	call :default_jom "_DEFAULT_VER"

	if not exist %STELLA_APP_FEATURE_ROOT%\jom mkdir %STELLA_APP_FEATURE_ROOT%\jom
	if "%_VER%"=="" (
		call :install_jom_!_DEFAULT_VER!
	) else (
		call :install_jom_%_VER%
	)
goto :eof

:feature_jom
	set "_VER=%~1"
	call :default_jom "_DEFAULT_VER"

	if "%_VER%"=="" (
		call :feature_jom_!_DEFAULT_VER!
	) else (
		call :feature_jom_%_VER%
	)
goto :eof



:install_jom_1_0_13
	set URL=http://download.qt-project.org/official_releases/jom/jom_1_0_13.zip
	set VERSION=1.0.13
	set FILE_NAME=jom_1_0_13.zip
	set "INSTALL_DIR=%STELLA_APP_FEATURE_ROOT%\jom\1_0_13"

	echo ** Installing jom version %VERSION% in %INSTALL_DIR%

	call :feature_jom_1_0_13
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE"

		call :feature_jom_1_0_13
		if not "!TEST_FEATURE!"=="0" (
			echo Jom installed
			!FEATURE_ROOT!\jom -version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_jom_1_0_13
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	set FEATURE_ROOT=
	if exist "%STELLA_APP_FEATURE_ROOT%\jom\1_0_13\jom.exe" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=%STELLA_APP_FEATURE_ROOT%\jom\1_0_13"
		set "FEATURE_PATH=!FEATURE_ROOT!"
		set FEATURE_VER=1_0_13
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : jom in !FEATURE_ROOT!
		)
	)
goto :eof



