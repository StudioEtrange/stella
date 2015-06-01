@echo off
call %*
goto :eof



:feature_conemu
	set "FEAT_NAME=conemu"
	set "FEAT_LIST_SCHEMA=preview150307a:binary"
	set "FEAT_DEFAULT_VERSION=preview150307a"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_conemu_preview150307a
	set "FEAT_VERSION=preview150307a"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=http://heanet.dl.sourceforge.net/project/conemu/Preview/ConEmuPack.150307a.7z"
	set FEAT_BINARY_URL_FILENAME=
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\ConEmu64.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof


:feature_conemu_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE"	
goto :eof

