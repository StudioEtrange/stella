@echo off
call %*
goto :eof


:feature_nasm
	set "FEAT_NAME=nasm"
	set "FEAT_LIST_SCHEMA=2_11:binary"
	set "FEAT_DEFAULT_VERSION=2_11"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_nasm_2_11
	set "FEAT_VERSION=2_11"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=http://www.nasm.us/pub/nasm/releasebuilds/2.11/win32/nasm-2.11-win32.zip"
	set "FEAT_BINARY_URL_FILENAME="
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=feature_go_set_env

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\nasm.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"

goto :eof


:feature_nasm_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP"	
goto :eof


