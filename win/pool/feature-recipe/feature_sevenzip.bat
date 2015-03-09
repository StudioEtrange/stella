@echo off
call %*
goto :eof



:feature_sevenzip
	set "FEAT_NAME=sevenzip"
	set "FEAT_LIST_SCHEMA=9_20/binary"
	set "FEAT_DEFAULT_VERSION=9_20"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_sevenzip_9_20
	set "FEAT_VERSION=9_20"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_PATCH_CALLBACK=
	set "FEAT_BINARY_URL=http://www.7-zip.org/a/7za920.zip"
	set "FEAT_BINARY_URL_FILENAME=7za920.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\7za.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"

	set FEAT_BUNDLE_LIST=
goto :eof


:feature_sevenzip_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
goto :eof


