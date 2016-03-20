@echo off
call %*
goto :eof

REM NOTE : Python 2.7.9 and later (on the python2 series), 
REM 		and Python 3.4 and later include pip by default

:feature_python
	set "FEAT_NAME=python"
	set "FEAT_LIST_SCHEMA=2_7_10@x64:binary 2_7_10@x86:binary"
	set "FEAT_DEFAULT_VERSION=2_7_10"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_python_2_7_10
	set "FEAT_VERSION=2_7_10"
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=
	
	set "FEAT_BINARY_URL_x86=https://www.python.org/ftp/python/2.7.10/python-2.7.10.msi"
	set "FEAT_BINARY_URL_FILENAME_x86=python-2.7.6.msi"
	set FEAT_BINARY_URL_PROTOCOL_x86=
	set "FEAT_BINARY_URL_x64=https://www.python.org/ftp/python/2.7.10/python-2.7.10.amd64.msi"
	set "FEAT_BINARY_URL_FILENAME_x64=python-2.7.6.amd64.msi"
	set FEAT_BINARY_URL_PROTOCOL_x64=

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\python.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"	

goto :eof


:feature_python_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%"
	cd /D %STELLA_APP_CACHE_DIR%

	echo ** Launch MSIEXEC with TARGETDIR=%INSTALL_DIR%
	msiexec /qn /a %FEAT_BINARY_URL_FILENAME% TARGETDIR="%INSTALL_DIR%\"

goto :eof



