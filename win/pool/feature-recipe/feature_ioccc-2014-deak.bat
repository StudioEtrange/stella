@echo off
call %*
goto :eof

REM TODO DO NOT WORK
REM TODO implement msys2 set_toolset

:feature_ioccc-2014-deak
	set "FEAT_NAME=ioccc-2014-deak"
	set "FEAT_LIST_SCHEMA=SNAPSHOT:source"
	set "FEAT_DEFAULT_VERSION=SNAPSHOT"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_ioccc-2014-deak_SNAPSHOT
	set "FEAT_VERSION=SNAPSHOT"
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=http://www.ioccc.org/2014/2014.tar.bz2"
	set FEAT_SOURCE_URL_FILENAME=ioccc-2014.tar.bz2
	set FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\ioccc-2014-deak.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\"

goto :eof

:feature_ioccc-2014-deak_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!STELLA_APP_FEATURE_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-src"

	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!SRC_DIR!-tmp-ioccc-deak" "DEST_ERASE STRIP FORCE_NAME !FEAT_SOURCE_URL_FILENAME!"
	call %STELLA_COMMON%\common.bat :copy_folder_content_into "!SRC_DIR!-tmp-ioccc-deak\deak" "!SRC_DIR!"
	call %STELLA_COMMON%\common.bat :del_folder "!SRC_DIR!-tmp-ioccc-deak"


	REM call %STELLA_COMMON%\common-build.bat :set_toolset "CUSTOM" "CONFIG_TOOL NONE BUILD_TOOL mingw-make COMPIL_FRONTEND gcc"
	call %STELLA_COMMON%\common-build.bat :set_toolset "MINGW-W64"

	set AUTO_INSTALL_CONF_FLAG_POSTFIX=
	set AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	call %STELLA_COMMON%\common-feature.bat :feature_callback


	call %STELLA_COMMON%\common-build.bat :auto_build "!FEAT_NAME!" "!SRC_DIR!" "!INSTALL_DIR!" "NO_OUT_OF_TREE_BUILD NO_CONFIG NO_INSTALL BUILD_KEEP SOURCE_KEEP"

	REM call %STELLA_COMMON%\common :copy_folder_content_into "!SRC_DIR!" "!INSTALL_DIR!"

	
goto :eof
