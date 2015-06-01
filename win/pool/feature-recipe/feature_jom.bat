@echo off
call %*
goto :eof



:feature_jom
	set "FEAT_NAME=jom"
	set "FEAT_LIST_SCHEMA=1_0_13/binary"
	set "FEAT_DEFAULT_VERSION=1_0_13"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_jom_1_0_13
	set "FEAT_VERSION=1_0_13"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=http://download.qt-project.org/official_releases/jom/jom_1_0_13.zip"
	set FEAT_BINARY_URL_FILENAME=
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\jom.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof


:feature_jom_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP"
goto :eof


