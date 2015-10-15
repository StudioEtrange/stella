@echo off
call %*
goto :eof

:feature_libogg
	set "FEAT_NAME=libogg"
	set "FEAT_LIST_SCHEMA=DEV20150926:source"
	set "FEAT_DEFAULT_VERSION=DEV20150926"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_libogg_DEV20150926
	set "FEAT_VERSION=DEV20150926"
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=https://github.com/xiph/ogg/archive/6c36ab3fce6ed9b465dfbc3790596238b6b11e17.zip"
	set "FEAT_SOURCE_URL_FILENAME=libogg-dev-20150926.zip"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"
	
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=
	
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\ogg.dll"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"	

goto :eof



:feature_libogg_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!STELLA_APP_FEATURE_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-src"
	
	call %STELLA_COMMON%\common-build.bat :set_toolset "MS"
	

	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!SRC_DIR!" "FORCE_NAME !FEAT_SOURCE_URL_FILENAME! STRIP"	

	set "AUTO_INSTALL_CONF_FLAG_POSTFIX="
	set "AUTO_INSTALL_BUILD_FLAG_POSTFIX="
	
	call %STELLA_COMMON%\common-build.bat :auto_build "!FEAT_NAME!" "!SRC_DIR!" "!INSTALL_DIR!"

goto :eof



