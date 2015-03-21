@echo off
call %*
goto :eof



:feature_openssh
	set "FEAT_NAME=openssh"
	set "FEAT_LIST_SCHEMA=6_6/binary"
	set "FEAT_DEFAULT_VERSION=6_6"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_openssh_6_6
	set "FEAT_VERSION=6_6"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_PATCH_CALLBACK=
	set "FEAT_BINARY_URL=http://www.mls-software.com/files/installer_source_files.66p1-1-v1.zip"
	set "FEAT_BINARY_URL_FILENAME=installer_source_files.66p1-1-v1.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\ssh.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	set FEAT_ENV=
	
	set FEAT_BUNDLE_LIST=
goto :eof


:feature_openssh_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
goto :eof


