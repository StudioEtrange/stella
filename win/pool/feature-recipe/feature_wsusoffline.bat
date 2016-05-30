@echo off
call %*
goto :eof

REM Update Microsoft Windows and Office without an Internet connection

:feature_wsusoffline
	set "FEAT_NAME=wsusoffline"
	set "FEAT_LIST_SCHEMA=10_6_2:binary"
	set "FEAT_DEFAULT_VERSION=10_6_2"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof



:feature_wsusoffline_10_6_2
	set "FEAT_VERSION=10_6_2"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=http://download.wsusoffline.net/wsusoffline1062.zip"
	set "FEAT_BINARY_URL_FILENAME=wsusoffline1062.zip"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\UpdateGenerator.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof


:feature_wsusoffline_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP"


goto :eof
