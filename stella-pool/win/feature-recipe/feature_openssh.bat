@echo off
call %*
goto :eof

:list_openssh
	set "%~1=6_6"
goto :eof

:install_openssh
	set "_VER=%~1"
	set "_DEFAULT_VER=6_6"

	if not exist %STELLA_APP_FEATURE_ROOT%\openssh mkdir %STELLA_APP_FEATURE_ROOT%\openssh
	if "%_VER%"=="" (
		call :install_openssh_%_DEFAULT_VER%
	) else (
		call :install_openssh_%_VER%
	)
goto :eof

:feature_openssh
	set "_VER=%~1"
	set "_DEFAULT_VER=6_6"

	if "%_VER%"=="" (
		call :feature_openssh_%_DEFAULT_VER%
	) else (
		call :feature_openssh_%_VER%
	)
goto :eof


:install_openssh_6_6
	set URL=http://www.mls-software.com/files/installer_source_files.66p1-1-v1.zip
	set FILE_NAME=installer_source_files.66p1-1-v1.zip
	set VERSION=6.6p1-1-v1
	set INSTALL_DIR="%STELLA_APP_FEATURE_ROOT%\openssh\6_6"

	echo ** Installing OpenSSH in %INSTALL_DIR%
	
	call :feature_openssh_6_6
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%\openssh\6_6"
	)
		if "!TEST_FEATURE!"=="0" (	
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
		call :feature_openssh_6_6
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo openssh installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_openssh_6_6
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%STELLA_APP_FEATURE_ROOT%\openssh\6_6\bin\ssh.exe" (
		set "TEST_FEATURE=%STELLA_APP_FEATURE_ROOT%\openssh\6_6"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : OpenSSH in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!\bin"
		set FEATURE_VER=6_6
	)
goto :eof




