@echo off
call %*
goto :eof

:list_ninja
	set "%~1=last_release"
goto :eof

:default_ninja
	set "%~1=last_release"
goto :eof


:install_ninja
	set "_VER=%~1"
	call :default_ninja "_DEFAULT_VER"

	if not exist %STELLA_APP_FEATURE_ROOT%\ninja mkdir %STELLA_APP_FEATURE_ROOT%\ninja

	if "%_VER%"=="" (
		call :install_ninja_%_DEFAULT_VER%
	) else (
		call :install_ninja_%_VER%
	)
goto :eof

:feature_ninja
	set "_VER=%~1"
	call :default_ninja "_DEFAULT_VER"

	if "%_VER%"=="" (
		call :feature_ninja_!_DEFAULT_VER!
	) else (
		call :feature_ninja_%_VER%
	)
goto :eof




:install_ninja_last_release
	set URL=https://github.com/martine/ninja/archive/release.zip
	set VERSION="last_release"
	set FILE_NAME=ninja-release.zip
	set "INSTALL_DIR=%STELLA_APP_FEATURE_ROOT%\ninja\%VERSION%"

	echo ** Installing ninja in %INSTALL_DIR%
	echo ** NEED PYTHON !!

	call %STELLA_COMMON%\common-feature.bat :init_feature python 2_7_6

	call :feature_ninja_last_release
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		cd /D "%INSTALL_DIR%"
		REM python bootstrap.py
		python ./configure.py --bootstrap

		call :feature_ninja_last_release
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo ** Ninja installed
			ninja --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_ninja_last_release
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%STELLA_APP_FEATURE_ROOT%\ninja\last_release\ninja.exe" (
		set "TEST_FEATURE=%STELLA_APP_FEATURE_ROOT%\ninja\last_release"
	)

	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : ninja in !TEST_FEATURE!
		)
		REM set "NINJA_MAKE_CMD=!TEST_FEATURE!\%NINJA_MAKE_CMD%"
		REM set "NINJA_MAKE_CMD_VERBOSE=!TEST_FEATURE!\%NINJA_MAKE_CMD_VERBOSE%"
		REM set "NINJA_MAKE_CMD_VERBOSE_ULTRA=!TEST_FEATURE!\%NINJA_MAKE_CMD_VERBOSE_ULSSA%"
		set "FEATURE_PATH=!TEST_FEATURE!"
		set FEATURE_VER=last_release
	)
goto :eof

