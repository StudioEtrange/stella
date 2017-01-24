@echo off
call %*
goto :eof


REM TODO build socat from source do not work - maybe try with cygwin or msys2 (https://github.com/Alexpux/MSYS2-packages/tree/master/socat)
REM TODO NOT FINISHED

:feature_socat
	set "FEAT_NAME=socat"
	set "FEAT_LIST_SCHEMA=1_7_2_1:binary"
	set "FEAT_DEFAULT_VERSION=1_7_2_1"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof

:feature_socat_1_7_3_1
	set "FEAT_VERSION=1_7_3_1"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=http://www.dest-unreach.org/socat/download/socat-1.7.3.1.tar.gz"
	set "FEAT_SOURCE_URL_FILENAME=socat-1.7.3.1.tar.gz"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\socat.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof

:feature_socat_1_7_2_1
	set "FEAT_VERSION=1_7_2_1"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=https://github.com/StudioEtrange/socat-windows/archive/1.7.2.1.zip"
	set "FEAT_BINARY_URL_FILENAME=socat-windows-1.7.2.1.zip"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\socat.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof


:feature_socat_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
goto :eof


:feature_socat_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!STELLA_APP_FEATURE_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-src"

	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!SRC_DIR!" "DEST_ERASE STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"

	msys2_shell.cmd -mintty -msys2 --full-path -where $STELLA_APP_ROOT
	msys2_shell.cmd -here -c "more stella.sh"
	REM http://linuxcommand.org/man_pages/bash1.html
	REM call %STELLA_COMMON%\common-build.bat :set_toolset "CUSTOM" "CONFIG_TOOL configure BUILD_TOOL mingw-make COMPIL_FRONTEND gcc"
	try : "$STELLA_ROOT/stella.sh boot cmd local -- __auto_build"
	REM set AUTO_INSTALL_CONF_FLAG_POSTFIX=
	REM set AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	REM call %STELLA_COMMON%\common-feature.bat :feature_callback


	REM call %STELLA_COMMON%\common-build.bat :auto_build "!FEAT_NAME!" "!SRC_DIR!" "!INSTALL_DIR!" "NO_CONFIG NO_INSTALL SOURCE_KEEP"

	REM call %STELLA_COMMON%\common :copy_folder_content_into "!SRC_DIR!" "!INSTALL_DIR!"

	REM call %STELLA_COMMON%\common.bat :del_folder "!SRC_DIR!"
goto :eof
