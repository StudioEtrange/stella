@echo off
call %*
goto :eof


:feature_nasm
	set "FEAT_NAME=nasm"
	set "FEAT_LIST_SCHEMA=2_11/binary"
	set "FEAT_DEFAULT_VERSION=2_11"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_nasm_2_11
	set "FEAT_VERSION=2_11"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL=http://www.nasm.us/pub/nasm/releasebuilds/2.11/win32/nasm-2.11-win32.zip"
	set "FEAT_BINARY_URL_FILENAME=nasm-2.11-win32.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\nasm.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
	set FEAT_ENV=
	
	set FEAT_BUNDLE_LIST=
goto :eof


:feature_nasm_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
goto :eof


