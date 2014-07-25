@echo off
call %*
goto :eof

:list_packer
	set "%~1=0_6_0"
goto :eof

:install_packer
	set "_VER=%~1"
	set "_DEFAULT_VER=0_6_0"

	if not exist %TOOL_ROOT%\packer mkdir %TOOL_ROOT%\packer
	if "%_VER%"=="" (
		call :install_packer_%_DEFAULT_VER%
	) else (
		call :install_packer_%_VER%
	)
goto :eof

:feature_packer
	set "_VER=%~1"
	set "_DEFAULT_VER=0_6_0"

	if "%_VER%"=="" (
		call :feature_packer_%_DEFAULT_VER%
	) else (
		call :feature_packer_%_VER%
	)
goto :eof


:install_packer_0_6_0
	if "%ARCH%"=="x64" (
		set URL=https://dl.bintray.com/mitchellh/packer/0.6.0_windows_amd64.zip
		set FILE_NAME=0.6.0_windows_amd64.zip
	)
	if "%ARCH%"=="x86" (
		set URL=https://dl.bintray.com/mitchellh/packer/0.6.0_windows_386.zip
		set FILE_NAME=0.6.0_windows_386.zip
	)
	set VERSION=0_6_0
	set "INSTALL_DIR=%TOOL_ROOT%\packer\%VERSION%"

	echo ** Installing packer version %VERSION% in %INSTALL_DIR%
	call :feature_packer_0_6_0
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE"
		
		call :feature_packer_0_6_0
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo Packer installed
			packer --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_packer_0_6_0
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%TOOL_ROOT%\packer\0_6_0\packer.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\packer\0_6_0"
	)

	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : packer in !TEST_FEATURE!
		)
		set "PACKER_CMD=!TEST_FEATURE!\%PACKER_CMD%"
		set "FEATURE_PATH=!TEST_FEATURE!"
		set FEATURE_VER=0_6_0
	)
goto :eof



