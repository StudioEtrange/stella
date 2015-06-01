@echo off
call %*
goto :eof


:feature_wget
	set "FEAT_NAME=wget"
	set "FEAT_LIST_SCHEMA=1_11_4:binary"
	set "FEAT_DEFAULT_VERSION=1_11_4"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_wget_1_11_4
	set "FEAT_VERSION=1_11_4"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_CALLBACK=feature_wget_1_11_4_patch

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\wget.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	set FEAT_ENV_CALLBACK=
	
	set FEAT_BUNDLE_ITEM=
goto :eof


:feature_wget_1_11_4_patch
	call %STELLA_COMMON%\common.bat :uncompress "%STELLA_ARTEFACT%\wget-1.11.4-1-bin.zip" "%INSTALL_DIR%"
	call %STELLA_COMMON%\common.bat :uncompress "%STELLA_ARTEFACT%\wget-1.11.4-1-dep.zip" "%INSTALL_DIR%"
goto :eof

:feature_wget_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common-feature.bat :feature_callback
		
goto :eof




