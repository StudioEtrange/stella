@echo off
call %*
goto :eof



:feature_nodejs
	set "FEAT_NAME=nodejs"
	set "FEAT_LIST_SCHEMA=6_10_2@x64:binary 6_10_2@x86:binary"
	set "FEAT_DEFAULT_VERSION=6_10_2"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_nodejs_6_10_2
	set "FEAT_VERSION=6_10_2"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x64=https://nodejs.org/dist/v6.10.2/node-v6.10.2-win-x64.zip"
	set "FEAT_BINARY_URL_FILENAME_x64=node-v6.10.2-win-x64.zip"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"
	set "FEAT_BINARY_URL_x86=https://nodejs.org/dist/v6.10.2/node-v6.10.2-win-x86.zip"
	set "FEAT_BINARY_URL_FILENAME_x86=node-v6.10.2-win-x86.zip"
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\node.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof


:feature_nodejs_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP"
goto :eof
