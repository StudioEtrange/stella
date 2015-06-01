@echo off
call %*
goto :eof


:feature_nginx
	set "FEAT_NAME=nginx"
	set "FEAT_LIST_SCHEMA=1_9_1:binary"
	set "FEAT_DEFAULT_VERSION=1_9_1"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_nginx_1_9_1
	set "FEAT_VERSION=1_9_1"

	REM Dependencies (not yet implemented)
	set FEAT_DEPENDENCIES=

	REM Properties for SOURCE flavour
	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=
	
	REM Properties for BINARY flavour
	set "FEAT_BINARY_URL=http://nginx.org/download/nginx-1.9.1.zip"
	set "FEAT_BINARY_URL_FILENAME=nginx-1.9.1-win.zip"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"


	REM callback are list of functions
	REM manual callback (with feature_callback)
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	REM automatic callback each time feature is initialized, to init env var
	set FEAT_ENV_CALLBACK=

	

	REM File to test if feature is installed
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\nginx.exe"
	REM PATH to add to system PATH
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	

goto :eof

:feature_nginx_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
goto :eof



