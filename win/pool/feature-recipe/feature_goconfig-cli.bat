@echo off
call %*
goto :eof


:feature_goconfig-cli
	set "FEAT_NAME=goconfig-cli"
	set "FEAT_LIST_SCHEMA=snapshot:binary"
	set "FEAT_DEFAULT_VERSION=snapshot"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_goconfig-cli_snapshot
	set "FEAT_VERSION=snapshot"
	
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=%STELLA_ARTEFACT_URL%/win/goconfig-cli/goconfig-cli.exe"
	set "FEAT_BINARY_URL_FILENAME="
	set "FEAT_BINARY_URL_PROTOCOL=HTTP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=
	
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\goconfig-cli.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"

goto :eof


:feature_goconfig-cli_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP"
goto :eof


