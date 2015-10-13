@echo off
call %*
goto :eof



:feature_ninja
	set "FEAT_NAME=ninja"
	set "FEAT_LIST_SCHEMA=1_6_0:source 1_6_0:binary"
	set "FEAT_DEFAULT_VERSION=1_6_0"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_ninja_1_6_0
	set "FEAT_VERSION=1_6_0"

	REM NEED PYTHON !!
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=https://github.com/martine/ninja/archive/v1.6.0.zip"
	set "FEAT_SOURCE_URL_FILENAME=ninja-1.6.0.zip"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"

	set "FEAT_BINARY_URL=https://github.com/martine/ninja/releases/download/v1.6.0/ninja-win.zip"
	set "FEAT_BINARY_URL_FILENAME=ninja-win-1.6.0.zip"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\ninja.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof



:feature_ninja_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
goto :eof

:feature_ninja_install_source
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP FORCE_NAME !FEAT_SOURCE_URL_FILENAME!"

	cd /D "!FEAT_INSTALL_ROOT!"
	python bootstrap.py
	REM python ./configure.py --bootstrap

goto :eof



