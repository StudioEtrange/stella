@echo off
call %*
goto :eof

:list_nasm
	set "%~1=2_11"
goto :eof

:default_nasm
	set "%~1=2_11"
goto :eof

:install_nasm
	set "_VER=%~1"
	call :default_nasm "_DEFAULT_VER"

	if not exist %STELLA_APP_FEATURE_ROOT%\nasm mkdir %STELLA_APP_FEATURE_ROOT%\nasm
	if "%_VER%"=="" (
		call :install_nasm_!_DEFAULT_VER!
	) else (
		call :install_nasm_%_VER%
	)
goto :eof

:feature_nasm
	set "_VER=%~1"
	call :default_nasm "_DEFAULT_VER"

	if "%_VER%"=="" (
		call :feature_nasm_!_DEFAULT_VER!
	) else (
		call :feature_nasm_%_VER%
	)
goto :eof




:install_nasm_2_11
	set URL=http://www.nasm.us/pub/nasm/releasebuilds/2.11/win32/nasm-2.11-win32.zip
	set FILE_NAME=nasm-2.11-win32.zip
	set VERSION=2_11
	set INSTALL_DIR="%STELLA_APP_FEATURE_ROOT%\nasm\%VERSION%"
	
	echo ** Installing NASM version %VERSION% in %INSTALL_DIR%

	call :feature_nasm_2_11
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (	
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
		call :feature_nasm_2_11
		if not "!TEST_FEATURE!"=="0" (
			echo NASM installed
			!FEATURE_ROOT!\nasm -version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_nasm_2_11
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	set FEATURE_ROOT=
	if exist "%STELLA_APP_FEATURE_ROOT%\nasm\2_11\nasm.exe" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=%STELLA_APP_FEATURE_ROOT%\nasm\2_11"
		set "FEATURE_PATH=!FEATURE_ROOT!"
		set FEATURE_VER=2_11
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : NASM in !FEATURE_ROOT!
		)
	)
goto :eof

