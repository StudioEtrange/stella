@echo off
call %*
goto :eof


:feature_socat
	set "FEAT_NAME=socat"
	set "FEAT_LIST_SCHEMA=1_7_2_1:binary"
	set "FEAT_DEFAULT_VERSION=1_7_2_1"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_socat_1_7_2_1
	set "FEAT_VERSION=1_7_2_1"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=
	
	set "FEAT_BINARY_URL=https://github.com/StudioEtrange/socat-windows/archive/1.7.2.1.zip"
	set "FEAT_BINARY_URL_FILENAME=socat-windows-1.7.2.1.zip"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\socat.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof


:feature_socat_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
goto :eof


