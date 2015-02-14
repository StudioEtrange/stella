@echo off
call %*
goto :eof

:list_cmake
	set "%~1=3_1_2_x86 2_8_12_x86"
goto :eof

:default_cmake
	set "%~1=2_8_12_x86"
goto :eof


:install_cmake
	set "_VER=%~1"
	
	set TEST_FEATURE=0
	set FEATURE_ROOT=
	set FEATURE_PATH=
	set FEATURE_VER=

	if not exist %STELLA_APP_FEATURE_ROOT%\cmake mkdir %STELLA_APP_FEATURE_ROOT%\cmake
	if "%_VER%"=="" (
		call :default_cmake "_DEFAULT_VER"
		call :install_cmake_!_DEFAULT_VER!
	) else (
		call :list_cmake "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :install_cmake_%_VER%
			)
		)
	)
goto :eof

:feature_cmake
	set "_VER=%~1"
	
	set TEST_FEATURE=0
	set FEATURE_ROOT=
	set FEATURE_PATH=
	set FEATURE_VER=

	if "%_VER%"=="" (
		call :default_cmake "_DEFAULT_VER"
		call :feature_cmake_!_DEFAULT_VER!
	) else (
		call :list_cmake "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :feature_cmake_%_VER%
			)
		)
	)
goto :eof



:install_cmake_2_8_12_x86
	set URL=http://www.cmake.org/files/v2.8/cmake-2.8.12-win32-x86.zip
	set VERSION=2_8_12_x86
	set FILE_NAME=cmake-2.8.12-win32-x86.zip
	set "INSTALL_DIR=%STELLA_APP_FEATURE_ROOT%\cmake\%VERSION%"

	echo ** Installing cmake version %VERSION% in %INSTALL_DIR%

	call :feature_cmake_2_8_12_x86
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
		call :feature_cmake_2_8_12_x86
		if not "!TEST_FEATURE!"=="0" (
			echo ** CMake installed
			!FEATURE_ROOT!\bin\cmake -version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_cmake_2_8_12_x86
	set TEST_FEATURE=0
	
	if exist "%STELLA_APP_FEATURE_ROOT%\cmake\2_8_12_x86\bin\cmake.exe" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=%STELLA_APP_FEATURE_ROOT%\cmake\2_8_12_x86"
		set "FEATURE_PATH=!FEATURE_ROOT!\bin"
		set FEATURE_VER=2_8_12_x86
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : cmake in !FEATURE_ROOT!
		)
	)
goto :eof





:install_cmake_3_1_2_x86
	set URL=http://www.cmake.org/files/v3.1/cmake-3.1.2-win32-x86.zip
	set VERSION=3_1_2_x86
	set FILE_NAME=cmake-3.1.2-win32-x86.zip
	set "INSTALL_DIR=%STELLA_APP_FEATURE_ROOT%\cmake\%VERSION%"

	echo ** Installing cmake version %VERSION% in %INSTALL_DIR%

	call :feature_cmake_3_1_2_x86
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
		call :feature_cmake_3_1_2_x86
		if "!TEST_FEATURE!"=="1" (
			echo ** CMake installed
			!FEATURE_ROOT!\bin\cmake -version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_cmake_3_1_2_x86
	set TEST_FEATURE=0
	
	if exist "%STELLA_APP_FEATURE_ROOT%\cmake\3_1_2_x86\bin\cmake.exe" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=%STELLA_APP_FEATURE_ROOT%\cmake\3_1_2_x86"
		set "FEATURE_PATH=!FEATURE_ROOT!\bin"
		set FEATURE_VER=3_1_2_x86
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : cmake in !FEATURE_ROOT!
		)
	)
goto :eof

