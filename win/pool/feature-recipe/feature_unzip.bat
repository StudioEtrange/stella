@echo off
call %*
goto :eof

:list_unzip
	set "%~1=5_51_1"
goto :eof

:default_unzip
	set "%~1=5_51_1"
goto :eof

:install_unzip
	set "_VER=%~1"
	call :default_unzip "_DEFAULT_VER"

	if not exist %STELLA_APP_FEATURE_ROOT%\unzip mkdir %STELLA_APP_FEATURE_ROOT%\unzip
	if "%_VER%"=="" (
		call :install_unzip_!_DEFAULT_VER!
	) else (
		call :install_unzip_%_VER%
	)
goto :eof

:feature_unzip
	set "_VER=%~1"
	call :default_unzip "_DEFAULT_VER"

	if "%_VER%"=="" (
		call :feature_unzip_!_DEFAULT_VER!
	) else (
		call :feature_unzip_%_VER%
	)
goto :eof

:install_unzip_5_51_1
	set VERSION=5_51_1
	set INSTALL_DIR="%STELLA_APP_FEATURE_ROOT%\unzip\%VERSION%"
	
	echo ** Installing unzip version %VERSION% in %INSTALL_DIR%

	call :feature_unzip_5_51_1
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (

		call %STELLA_COMMON%\common.bat :copy_folder_content_into "%STELLA_FEATURE_REPOSITORY_LOCAL%\unzip-5.51-1-bin" "%INSTALL_DIR%"
		
		call :feature_unzip_5_51_1
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo unzip installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_unzip_5_51_1
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%STELLA_APP_FEATURE_ROOT%\unzip\5_51_1\bin\unzip.exe" (
		set "TEST_FEATURE=%STELLA_APP_FEATURE_ROOT%\unzip\5_51_1"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : unzip in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!"
		set FEATURE_VER=5_51_1
	)
goto :eof
