@echo off
call %*
goto :eof



:feature_gnumake
	set "FEAT_NAME=gnumake"
	set "FEAT_LIST_SCHEMA=3_81/binary"
	set "FEAT_DEFAULT_VERSION=3_81"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_gnumake_3_81
	set "FEAT_VERSION=3_81"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_PATCH_CALLBACK=
	set "FEAT_BINARY_URL=http://downloads.sourceforge.net/project/gnuwin32/make/3.81/make-3.81-bin.zip http://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-dep.zip"
	set "FEAT_BINARY_URL_FILENAME=_AUTO_"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\make.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"

	set FEAT_BUNDLE_LIST=
goto :eof


:feature_gnumake_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	for %%i in (!FEAT_BINARY_URL!) do (
		call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "_AUTO_" "%INSTALL_DIR%" "DEST_ERASE STRIP"
	)	
goto :eof
