@echo off
call %*
goto :eof



:feature_nikpeviewer
	set "FEAT_NAME=nikpeviewer"
	set "FEAT_LIST_SCHEMA=0_21@x86/binary"
	set "FEAT_DEFAULT_VERSION=0_21"
	set "FEAT_DEFAULT_ARCH=x86"
	set "FEAT_DEFAULT_FLAVOUR=binary"
	
goto :eof


:feature_nikpeviewer_0_21
	set "FEAT_VERSION=0_21"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL_x86=http://www.codedebug.com/Downloads/Download.php?file=NikPEViewer_21v.zip"
	set "FEAT_BINARY_URL_FILENAME_x86=NikPEViewer_21v.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\NikPEViewer.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
	set FEAT_ENV=

	set FEAT_BUNDLE_LIST=
goto :eof





:feature_nikpeviewer_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE"
		
goto :eof






