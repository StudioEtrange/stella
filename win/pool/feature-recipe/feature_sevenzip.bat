@echo off
call %*
goto :eof

:list_sevenzip
	set "%~1=9_20"
goto :eof

:default_sevenzip
	set "%~1=9_20"
goto :eof

:install_sevenzip
	set "_VER=%~1"
	call :default_sevenzip "_DEFAULT_VER"

	if not exist %STELLA_APP_FEATURE_ROOT%\sevenzip mkdir %STELLA_APP_FEATURE_ROOT%\sevenzip
	if "%_VER%"=="" (
		call :install_sevenzip_!_DEFAULT_VER!
	) else (
		call :install_sevenzip_%_VER%
	)
goto :eof

:feature_sevenzip
	set "_VER=%~1"
	call :default_sevenzip "_DEFAULT_VER"

	if "%_VER%"=="" (
		call :feature_sevenzip_!_DEFAULT_VER!
	) else (
		call :feature_sevenzip_%_VER%
	)
goto :eof

:install_sevenzip_9_20
	set URL=http://www.7-zip.org/a/7za920.zip
	set FILE_NAME=7za920.zip
	set VERSION=9_20
	set INSTALL_DIR="%STELLA_APP_FEATURE_ROOT%\sevenzip\%VERSION%"
	
	echo ** Installing sevenzip version %VERSION% in %INSTALL_DIR%

	call :feature_sevenzip_9_20
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE"
		
		call :feature_sevenzip_9_20
		if not "!TEST_FEATURE!"=="0" (
			echo sevenzip installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_sevenzip_9_20
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	set FEATURE_ROOT=
	if exist "%STELLA_APP_FEATURE_ROOT%\sevenzip\9_20\7za.exe" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=%STELLA_APP_FEATURE_ROOT%\sevenzip\9_20"
		set "FEATURE_PATH=!FEATURE_ROOT!"
		set FEATURE_VER=9_20
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : sevenzip in !FEATURE_ROOT!
		)
	)
goto :eof
