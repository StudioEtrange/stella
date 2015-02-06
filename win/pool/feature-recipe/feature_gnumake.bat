@echo off
call %*
goto :eof

:list_gnumake
	set "%~1=3_81"
goto :eof

:default_gnumake
	set "%~1=3_81"
goto :eof

:install_gnumake
	set "_VER=%~1"
	call :default_gnumake "_DEFAULT_VER"

	if not exist %STELLA_APP_FEATURE_ROOT%\gnumake mkdir %STELLA_APP_FEATURE_ROOT%\gnumake
	if "%_VER%"=="" (
		call :install_gnumake_!_DEFAULT_VER!
	) else (
		call :list_gnumake "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :install_gnumake_%_VER%
			)
		)
	)
goto :eof

:feature_gnumake
	set "_VER=%~1"
	call :default_gnumake "_DEFAULT_VER"

	if "%_VER%"=="" (
		call :feature_gnumake_!_DEFAULT_VER!
	) else (
		call :list_gnumake "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :feature_gnumake_%_VER%
			)
		)
	)
goto :eof

:install_gnumake_3_81
	set VERSION=3_81
	set INSTALL_DIR="%STELLA_APP_FEATURE_ROOT%\gnumake\%VERSION%"
	
	echo ** Installing gnumake version %VERSION% in %INSTALL_DIR%

	call :feature_gnumake_3_81
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (

		set URL=http://downloads.sourceforge.net/project/gnuwin32/make/3.81/make-3.81-bin.zip
		set FILE_NAME=make-3.81-bin.zip
		call %STELLA_COMMON%\common.bat :download_uncompress "!URL!" "!FILE_NAME!" "%INSTALL_DIR%"
		
		set URL=http://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-dep.zip
		set FILE_NAME=make-3.81-dep.zip
		call %STELLA_COMMON%\common.bat :download_uncompress "!URL!" "!FILE_NAME!" "%INSTALL_DIR%"


		call :feature_gnumake_3_81
		if not "!TEST_FEATURE!"=="0" (
			echo gnumake installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_gnumake_3_81
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	set FEATURE_ROOT=
	if exist "%STELLA_APP_FEATURE_ROOT%\gnumake\3_81\bin\make.exe" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=%STELLA_APP_FEATURE_ROOT%\gnumake\3_81"
		set "FEATURE_PATH=!FEATURE_ROOT!\bin"
		set FEATURE_VER=3_81
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : gnumake in !FEATURE_ROOT!
		)
	)
goto :eof
