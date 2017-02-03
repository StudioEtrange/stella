@echo off
call %*
goto :eof



:feature_ninja
	set "FEAT_NAME=ninja"
	set "FEAT_LIST_SCHEMA=1_7_2:source 1_7_2:binary 1_6_0:source 1_6_0:binary"
	set "FEAT_DEFAULT_VERSION=1_7_2"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof



:feature_ninja_1_7_2
	set "FEAT_VERSION=1_7_2"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=https://github.com/ninja-build/ninja/archive/v1.7.2.zip"
	set "FEAT_SOURCE_URL_FILENAME=ninja-1.7.2.zip"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"

	set "FEAT_BINARY_URL=https://github.com/ninja-build/ninja/releases/download/v1.7.2/ninja-win.zip"
	set "FEAT_BINARY_URL_FILENAME=ninja-win-1.7.2.zip"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\ninja.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof


:feature_ninja_1_6_0
	set "FEAT_VERSION=1_6_0"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=https://github.com/ninja-build/ninja/archive/v1.6.0.zip"
	set "FEAT_SOURCE_URL_FILENAME=ninja-1.6.0.zip"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"

	set "FEAT_BINARY_URL=https://github.com/ninja-build/ninja/releases/download/v1.6.0/ninja-win.zip"
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
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!FEAT_INSTALL_ROOT!"

	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP FORCE_NAME !FEAT_SOURCE_URL_FILENAME!"

	call %STELLA_COMMON%\common-build.bat :set_toolset "MS"
	call %STELLA_COMMON%\common-build.bat :add_toolset "miniconda#4_2_12_PYTHON2"

	call %STELLA_COMMON%\common-build.bat :start_manual_build "!FEAT_NAME!" "!SRC_DIR!" "!INSTALL_DIR!"

	cd /D "!FEAT_INSTALL_ROOT!"
	
	if "!FEAT_VERSION!"=="1_6_0" (
		python bootstrap.py
	) else (
		python configure.py --bootstrap
	)
	call %STELLA_COMMON%\common-build.bat :end_manual_build

goto :eof
