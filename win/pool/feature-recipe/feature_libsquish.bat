@echo off
call %*
goto :eof

REM TODO only static lib is built. When building shared lib, there is no exported symbol from DLL (and there is no import lib built)

:feature_libsquish
	set "FEAT_NAME=libsquish"
	set "FEAT_LIST_SCHEMA=1_13:source"
	set "FEAT_DEFAULT_VERSION=1_13"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_libsquish_1_13
	set "FEAT_VERSION=1_13"
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=http://downloads.sourceforge.net/project/libsquish/libsquish-1.13.tgz"
	set "FEAT_SOURCE_URL_FILENAME=libsquish-1.13.tgz"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"
	
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=
	
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\lib\squish.lib"
	set FEAT_SEARCH_PATH=	

goto :eof



:feature_libsquish_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!STELLA_APP_FEATURE_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-src"
	
	call %STELLA_COMMON%\common-build.bat :set_toolset "MS"
	

	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!SRC_DIR!" "STRIP"	

	set "AUTO_INSTALL_CONF_FLAG_POSTFIX=-DBUILD_SQUISH_WITH_SSE2=ON -DBUILD_SQUISH_WITH_ALTIVEC=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_SQUISH_EXTRA=OFF"
	set "AUTO_INSTALL_BUILD_FLAG_POSTFIX="
	

	call %STELLA_COMMON%\common-feature.bat :feature_callback

	call %STELLA_COMMON%\common-build.bat :auto_build "!FEAT_NAME!" "!SRC_DIR!" "!INSTALL_DIR!"

goto :eof



