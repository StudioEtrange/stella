@echo off
call %*
goto :eof


:feature_diffutils
	set "FEAT_NAME=diffutils"
	set "FEAT_LIST_SCHEMA=2_8_7:binary"
	set "FEAT_DEFAULT_VERSION=2_8_7"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_diffutils_2_8_7
	set "FEAT_VERSION=2_8_7"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=http://downloads.sourceforge.net/project/gnuwin32/diffutils/2.8.7-1/diffutils-2.8.7-1-bin.zip"
	set FEAT_BINARY_URL_FILENAME=
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_CALLBACK=feature_diffutils_get_dep"
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\diff.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"


goto :eof

:feature_diffutils_get_dep
	call %STELLA_COMMON%\common.bat :get_resource "diffutils dependencies" "http://downloads.sourceforge.net/project/gnuwin32/diffutils/2.8.7-1/diffutils-2.8.7-1-dep.zip" "HTTP_ZIP" "!FEAT_INSTALL_ROOT!"
goto :eof


:feature_diffutils_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "diffutils" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!"
	call %STELLA_COMMON%\common-feature.bat :feature_callback
goto :eof


