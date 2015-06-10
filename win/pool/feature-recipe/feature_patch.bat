@echo off
call %*
goto :eof


:feature_patch
	set "FEAT_NAME=patch"
	set "FEAT_LIST_SCHEMA=2_5_9:binary"
	set "FEAT_DEFAULT_VERSION=2_5_9"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_patch_2_5_9
	set "FEAT_VERSION=2_5_9"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=http://freefr.dl.sourceforge.net/project/gnuwin32/patch/2.5.9-7/patch-2.5.9-7-bin.zip"
	set "FEAT_BINARY_URL_FILENAME="
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\patch.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"


goto :eof


:feature_patch_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "vagrant" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!"
		
goto :eof


