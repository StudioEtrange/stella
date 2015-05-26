@echo off
call %*
goto :eof


:feature_goconfig-cli
	set "FEAT_NAME=goconfig-cli"
	set "FEAT_LIST_SCHEMA=snapshot/binary"
	set "FEAT_DEFAULT_VERSION=snapshot"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_goconfig-cli_snapshot
	set "FEAT_VERSION=snapshot"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL=%STELLA_ARTEFACT_URL%/win/goconfig-cli/goconfig-cli.exe"
	set "FEAT_BINARY_URL_FILENAME=goconfig-cli.exe"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\goconfig-cli.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
	set FEAT_ENV_CALLBACK=
	
	set FEAT_BUNDLE_ITEM=
goto :eof


:feature_goconfig-cli_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%"
		
goto :eof


