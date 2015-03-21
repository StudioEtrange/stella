@echo off
call %*
goto :eof



:feature_conemu
	set "FEAT_NAME=conemu"
	set "FEAT_LIST_SCHEMA=preview150307a/binary"
	set "FEAT_DEFAULT_VERSION=preview150307a"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_conemu_preview150307a
	set "FEAT_VERSION=preview150307a"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_PATCH_CALLBACK=
	set "FEAT_BINARY_URL=http://heanet.dl.sourceforge.net/project/conemu/Preview/ConEmuPack.150307a.7z"
	set "FEAT_BINARY_URL_FILENAME=ConEmuPack.150307a.7z"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\ConEmu64.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
	set FEAT_ENV=
	
	set FEAT_BUNDLE_LIST=
goto :eof


:feature_conemu_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE"
		
goto :eof


