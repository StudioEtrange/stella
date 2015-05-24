@echo off
call %*
goto :eof


:feature_patch
	set "FEAT_NAME=patch"
	set "FEAT_LIST_SCHEMA=2_5_9/binary"
	set "FEAT_DEFAULT_VERSION=2_5_9"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_patch_2_5_9
	set "FEAT_VERSION=2_5_9"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL=http://freefr.dl.sourceforge.net/project/gnuwin32/patch/2.5.9-7/patch-2.5.9-7-bin.zip"
	set "FEAT_BINARY_URL_FILENAME=patch-2.5.9-7-bin.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\patch.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	set FEAT_ENV=
	
	set FEAT_BUNDLE_LIST=
goto :eof


:feature_patch_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE"
		
goto :eof


