@echo off
call %*
goto :eof

:list_goconfig-cli
	set "%~1=snapshot"
goto :eof

:default_goconfig-cli
	set "%~1=snapshot"
goto :eof

:install_goconfig-cli
	set "_VER=%~1"

	set TEST_FEATURE=0
	set FEATURE_ROOT=
	set FEATURE_PATH=
	set FEATURE_VER=

	if not exist %STELLA_APP_FEATURE_ROOT%\goconfig-cli mkdir %STELLA_APP_FEATURE_ROOT%\goconfig-cli
	if "%_VER%"=="" (
		call :default_goconfig-cli "_DEFAULT_VER"
		call :install_goconfig-cli_!_DEFAULT_VER!
	) else (
		call :list_goconfig-cli "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :install_goconfig-cli_%_VER%
			)
		)
	)
goto :eof

:feature_goconfig-cli
	set "_VER=%~1"
	
	set TEST_FEATURE=0
	set FEATURE_ROOT=
	set FEATURE_PATH=
	set FEATURE_VER=

	if "%_VER%"=="" (
		call :default_goconfig-cli "_DEFAULT_VER"
		call :feature_goconfig-cli_!_DEFAULT_VER!
	) else (
		call :list_goconfig-cli "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :feature_goconfig-cli_%_VER%
			)
		)
	)
goto :eof


:install_goconfig-cli_snapshot
	set URL=%STELLA_FEATURE_REPOSITORY%/win/goconfig-cli/goconfig-cli.exe
	set FILE_NAME=goconfig-cli.exe
	set VERSION=snapshot
	call :install_goconfig-cli_internal
goto :eof


:feature_goconfig-cli_snapshot
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\goconfig-cli\snapshot\goconfig-cli.exe"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\goconfig-cli\snapshot"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!"
	set "FEATURE_RESULT_VER=snapshot"
	call :feature_goconfig-cli_internal
goto :eof


REM --------------------------------------------------------------
:install_goconfig-cli_internal
	set "INSTALL_DIR=%STELLA_APP_FEATURE_ROOT%\goconfig-cli\%VERSION%"

	echo ** Installing goconfig-cli version %VERSION% in %INSTALL_DIR%
	call :feature_goconfig-cli_%VERSION%
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download "%URL%" "%FILE_NAME%" "%INSTALL_DIR%"
		
		call :feature_goconfig-cli_%VERSION%
		if "!TEST_FEATURE!"=="1" (
			echo goconfig-cli installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_goconfig-cli_internal
	set TEST_FEATURE=0
	
	if exist "!FEATURE_TEST!" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=!FEATURE_RESULT_ROOT!"
		set "FEATURE_PATH=!FEATURE_RESULT_PATH!"
		set "FEATURE_VER=!FEATURE_RESULT_VER!"
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : goconfig-cli in !FEATURE_ROOT!
		)
	)
goto :eof