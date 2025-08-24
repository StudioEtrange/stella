@echo off
call %*
goto :eof


:feature_unzip
	set "FEAT_NAME=unzip"
	set "FEAT_LIST_SCHEMA=5_51_1_INTERNAL:binary"
	set "FEAT_DEFAULT_VERSION=5_51_1_INTERNAL"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_unzip_5_51_1_INTERNAL
	set "FEAT_VERSION=5_51_1_INTERNAL"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=%STELLA_ARTEFACT%\unzip-5.51-1-bin"
	set FEAT_BINARY_URL_FILENAME=
	set "FEAT_BINARY_URL_PROTOCOL=FILE"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\unzip.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"

goto :eof



:feature_unzip_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" ""
goto :eof

