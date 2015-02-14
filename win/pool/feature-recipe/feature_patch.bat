@echo off
call %*
goto :eof

:list_patch
	set "%~1=2_5_9"
goto :eof

:default_patch
	set "%~1=2_5_9"
goto :eof

:install_patch
	set "_VER=%~1"

	set TEST_FEATURE=0
	set FEATURE_ROOT=
	set FEATURE_PATH=
	set FEATURE_VER=	

	if not exist %STELLA_APP_FEATURE_ROOT%\patch mkdir %STELLA_APP_FEATURE_ROOT%\patch
	if "%_VER%"=="" (
		call :default_patch "_DEFAULT_VER"
		call :install_patch_!_DEFAULT_VER!
	) else (
		call :list_patch "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :install_patch_%_VER%
			)
		)
	)
goto :eof

:feature_patch
	set "_VER=%~1"

	set TEST_FEATURE=0
	set FEATURE_ROOT=
	set FEATURE_PATH=
	set FEATURE_VER=

	if "%_VER%"=="" (
		call :default_patch "_DEFAULT_VER"
		call :feature_patch_!_DEFAULT_VER!
	) else (
		call :list_patch "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :feature_patch_%_VER%
			)
		)
	)
goto :eof


:install_patch_2_5_9
	set URL=%STELLA_FEATURE_REPOSITORY%/win/patch/patch-2.5.9-7-bin.zip
	set FILE_NAME=patch-2.5.9-7-bin.zip
	set VERSION=2_5_9
	call :install_patch_internal
goto :eof


:feature_patch_2_5_9
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\patch\2_5_9\bin\patch.exe"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\patch\2_5_9"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!\bin"
	set "FEATURE_RESULT_VER=2_5_9"
	call :feature_patch_internal
goto :eof


REM --------------------------------------------------------------
:install_patch_internal
	set "INSTALL_DIR=%STELLA_APP_FEATURE_ROOT%\patch\%VERSION%"

	echo ** Installing patch version %VERSION% in %INSTALL_DIR%
	call :feature_patch_%VERSION%
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE"
		
		call :feature_patch_%VERSION%
		if "!TEST_FEATURE!"=="1" (
			echo patch installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_patch_internal
	set TEST_FEATURE=0
	
	if exist "!FEATURE_TEST!" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=!FEATURE_RESULT_ROOT!"
		set "FEATURE_PATH=!FEATURE_RESULT_PATH!"
		set "FEATURE_VER=!FEATURE_RESULT_VER!"
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : patch in !FEATURE_ROOT!
		)
	)
goto :eof