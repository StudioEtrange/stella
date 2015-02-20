@echo off
call %*
goto :eof

:list_packer
	set "%~1=0_6_0_x64 0_6_0_x86 0_7_5_x64 0_7_5_x86"
goto :eof

:default_packer
	set "%~1=0_7_5_x64"
goto :eof


:install_packer
	set "_VER=%~1"

	set TEST_FEATURE=0
	set FEATURE_ROOT=
	set FEATURE_PATH=
	set FEATURE_VER=

	if not exist %STELLA_APP_FEATURE_ROOT%\packer mkdir %STELLA_APP_FEATURE_ROOT%\packer
	if "%_VER%"=="" (
		call :default_packer "_DEFAULT_VER"
		call :install_packer_!_DEFAULT_VER!
	) else (
		call :list_packer "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :install_packer_%_VER%
			)
		)
	)
goto :eof

:feature_packer
	set "_VER=%~1"

	set TEST_FEATURE=0
	set FEATURE_ROOT=
	set FEATURE_PATH=
	set FEATURE_VER=

	if "%_VER%"=="" (
		call :default_packer "_DEFAULT_VER"
		call :feature_packer_!_DEFAULT_VER!
	) else (
		call :list_packer "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :feature_packer_%_VER%
			)
		)
	)
goto :eof

REM --------------------------------------------------------------
:install_packer_0_6_0_x64
	set URL=https://dl.bintray.com/mitchellh/packer/0.6.0_windows_amd64.zip
	set FILE_NAME=0.6.0_windows_amd64.zip
	set VERSION=0_6_0_x64
	call :install_packer_internal
goto :eof
:feature_packer_0_6_0_x64
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\packer\0_6_0_x64\packer.exe"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\packer\0_6_0_x64"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!"
	set "FEATURE_RESULT_VER=0_6_0_x64"
	call :feature_packer_internal
goto :eof


:install_packer_0_6_0_x86
	set URL=https://dl.bintray.com/mitchellh/packer/0.6.0_windows_386.zip
	set FILE_NAME=0.6.0_windows_386.zip
	set VERSION=0_6_0_x86
	call :install_packer_internal
goto :eof
:feature_packer_0_6_0_x86
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\packer\0_6_0_x86\packer.exe"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\packer\0_6_0_x86"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!"
	set "FEATURE_RESULT_VER=0_6_0_x86"
	call :feature_packer_internal
goto :eof




:install_packer_0_7_5_x64
	set URL=https://dl.bintray.com/mitchellh/packer/0.7.5_windows_amd64.zip
	set FILE_NAME=0.7.5_windows_amd64.zip
	set VERSION=0_7_5_x64
	call :install_packer_internal
goto :eof
:feature_packer_0_7_5_x64
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\packer\0_7_5_x64\packer.exe"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\packer\0_7_5_x64"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!"
	set "FEATURE_RESULT_VER=0_7_5_x64"
	call :feature_packer_internal
goto :eof

:install_packer_0_7_5_x86
	set URL=https://dl.bintray.com/mitchellh/packer/0.7.5_windows_386.zip
	set FILE_NAME=0.7.5_windows_386.zip
	set VERSION=0_7_5_x86
	call :install_packer_internal
goto :eof
:feature_packer_0_7_5_x86
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\packer\0_7_5_x86\packer.exe"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\packer\0_7_5_x86"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!"
	set "FEATURE_RESULT_VER=0_7_5_x86"
	call :feature_packer_internal
goto :eof


REM --------------------------------------------------------------
:install_packer_internal
	set "INSTALL_DIR=%STELLA_APP_FEATURE_ROOT%\packer\%VERSION%"

	echo ** Installing packer version %VERSION% in %INSTALL_DIR%
	call :feature_packer_%VERSION%
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE"
		
		call :feature_packer_%VERSION%
		if "!TEST_FEATURE!"=="1" (
			echo Packer installed
			!FEATURE_ROOT!\packer --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_packer_internal
	set TEST_FEATURE=0
	
	if exist "!FEATURE_TEST!" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=!FEATURE_RESULT_ROOT!"
		set "FEATURE_PATH=!FEATURE_RESULT_PATH!"
		set "FEATURE_VER=!FEATURE_RESULT_VER!"
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : packer in !FEATURE_ROOT!
		)
	)
goto :eof


