@echo off
call %*
goto :eof



:feature_dependencywalker
	set "FEAT_NAME=dependencywalker"
	set "FEAT_LIST_SCHEMA=2_2@x64/binary 2_2@x86/binary"
	set "FEAT_DEFAULT_VERSION=2_2"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
	
goto :eof


:feature_dependencywalker_2_2
	set "FEAT_VERSION=2_2"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL_x64=http://www.dependencywalker.com/depends22_x64.zip"
	set "FEAT_BINARY_URL_FILENAME_x64=depends22_x64.zip"
	set "FEAT_BINARY_URL_x86=http://www.dependencywalker.com/depends22_x86.zip"
	set "FEAT_BINARY_URL_FILENAME_x86=depends22_x86.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\depends.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
	set FEAT_ENV_CALLBACK=

	set FEAT_BUNDLE_ITEM=
goto :eof





:feature_dependencywalker_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
goto :eof






