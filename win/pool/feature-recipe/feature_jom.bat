@echo off
call %*
goto :eof



:feature_jom
	set "FEAT_NAME=jom"
	set "FEAT_LIST_SCHEMA=1_0_13/binary"
	set "FEAT_DEFAULT_VERSION=1_0_13"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_jom_1_0_13
	set "FEAT_VERSION=1_0_13"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_PATCH_CALLBACK=
	set "FEAT_BINARY_URL=http://download.qt-project.org/official_releases/jom/jom_1_0_13.zip"
	set "FEAT_BINARY_URL_FILENAME=jom_1_0_13.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\jom.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"

	set FEAT_BUNDLE_LIST=
goto :eof


:feature_jom_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
goto :eof


