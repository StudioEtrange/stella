@echo off
call %*
goto :eof

:list_python
	set "%~1=2_7_6"
goto :eof

:default_python
	set "%~1=2_7_6"
goto :eof


:install_python
	set "_VER=%~1"
	call :default_python "_DEFAULT_VER="

	if not exist %STELLA_APP_FEATURE_ROOT%\python mkdir %STELLA_APP_FEATURE_ROOT%\python
	if "%_VER%"=="" (
		call :install_python_!_DEFAULT_VER!
	) else (
		call :install_python_%_VER%
	)
goto :eof

:feature_python
	set "_VER=%~1"
	call :default_python "_DEFAULT_VER="
	
	if "%_VER%"=="" (
		call :feature_python_!_DEFAULT_VER!
	) else (
		call :feature_python_%_VER%
	)
goto :eof


:install_python_2_7_6
	if "%ARCH%"=="x86" (
		set URL=https://www.python.org/ftp/python/2.7.6/python-2.7.6.msi
		set FILE_NAME=python-2.7.6.msi
	)
	if "%ARCH%"=="x64" (
		set URL=https://www.python.org/ftp/python/2.7.6/python-2.7.6.amd64.msi
		set FILE_NAME=python-2.7.6.amd64.msi
	)

	set VERSION=2_7_6
	set "INSTALL_DIR=%STELLA_APP_FEATURE_ROOT%\python\%VERSION%"

	echo ** Installing python version %VERSION% in %INSTALL_DIR%
	call :feature_python_2_7_6
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download "%URL%" "%FILE_NAME%"
		cd /D %STELLA_APP_CACHE_DIR%

		echo ** Launch MSIEXEC with TARGETDIR=%INSTALL_DIR%
		msiexec /qb /i %FILE_NAME% TARGETDIR="%INSTALL_DIR%\"

		call :feature_python_2_7_6
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo Python installed
			python.exe --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_python_2_7_6
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%STELLA_APP_FEATURE_ROOT%\python\2_7_6\python.exe" (
		set "TEST_FEATURE=%STELLA_APP_FEATURE_ROOT%\python\2_7_6"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : Python in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!"
		set FEATURE_VER=2_7_6
	)
goto :eof


