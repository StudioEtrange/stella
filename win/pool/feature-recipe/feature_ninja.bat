@echo off
call %*
goto :eof



:feature_ninja
	set "FEAT_NAME=ninja"
	set "FEAT_LIST_SCHEMA=last_release/source"
	set "FEAT_DEFAULT_VERSION=last_release"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_ninja_last_release
	set "FEAT_VERSION=last_release"

	set "FEAT_SOURCE_URL=https://github.com/martine/ninja/archive/release.zip"
	set "FEAT_SOURCE_URL_FILENAME=ninja-release.zip"
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_CALLBACK=

	REM NEED PYTHON !!
	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\ninja.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
	set FEAT_ENV=
	
	set FEAT_BUNDLE_LIST=
goto :eof


:feature_ninja_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_SOURCE_URL%" "%FEAT_SOURCE_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
	
	cd /D "%INSTALL_DIR%"
	python bootstrap.py
	REM python ./configure.py --bootstrap

goto :eof



