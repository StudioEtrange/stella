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

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=
	
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=feature_wget_1_11_4_artefact
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\wget.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
goto :eof


:feature_wget_1_11_4_artefact
	call %STELLA_COMMON%\common.bat :uncompress "%STELLA_ARTEFACT%\wget-1.11.4-1-bin.zip" "!FEAT_INSTALL_ROOT!"
	call %STELLA_COMMON%\common.bat :uncompress "%STELLA_ARTEFACT%\wget-1.11.4-1-dep.zip" "!FEAT_INSTALL_ROOT!"
goto :eof

:feature_wget_install_binary

	call %STELLA_COMMON%\common-feature.bat :feature_callback
		
goto :eof




