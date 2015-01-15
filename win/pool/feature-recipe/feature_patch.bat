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
	call :default_patch "_DEFAULT_VER"

	if not exist %STELLA_APP_FEATURE_ROOT%\patch mkdir %STELLA_APP_FEATURE_ROOT%\patch
	if "%_VER%"=="" (
		call :install_patch_!_DEFAULT_VER!
	) else (
		call :install_patch_%_VER%
	)
goto :eof

:feature_patch
	set "_VER=%~1"
	call :default_patch "_DEFAULT_VER"

	if "%_VER%"=="" (
		call :feature_patch_!_DEFAULT_VER!
	) else (
		call :feature_patch_%_VER%
	)
goto :eof

:install_patch_2_5_9
	set VERSION=2_5_9
	set INSTALL_DIR="%STELLA_APP_FEATURE_ROOT%\patch\%VERSION%"
	
	echo ** Installing patch version %VERSION% in %INSTALL_DIR%

	call :feature_patch_2_5_9
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (

		call %STELLA_COMMON%\common.bat :uncompress "%STELLA_POOL%\feature\patch-2.5.9-7-bin.zip" "%INSTALL_DIR%"

		call :feature_patch_2_5_9
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo patch installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_patch_2_5_9
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%STELLA_APP_FEATURE_ROOT%\patch\2_5_9\bin\patch.exe" (
		set "TEST_FEATURE=%STELLA_APP_FEATURE_ROOT%\patch\2_5_9"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : patch in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!"
		set FEATURE_VER=2_5_9
	)
goto :eof
