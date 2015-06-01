@echo off
call %*
goto :eof


:feature_docker-machine
	set "FEAT_NAME=docker-machine"
	set "FEAT_LIST_SCHEMA=0_2_0@x64:binary 0_2_0@x86:binary"
	set "FEAT_DEFAULT_VERSION=0_2_0"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_docker-machine_0_2_0
	set "FEAT_VERSION=0_2_0"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=

	set "FEAT_BINARY_URL_x64=https://github.com/docker/machine/releases/download/v0.2.0/docker-machine_windows-amd64.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=docker-machine_windows-amd64-0_2_0.exe"
	set "FEAT_BINARY_URL_x86=https://github.com/docker/machine/releases/download/v0.2.0/docker-machine_windows-386.exe"
	set "FEAT_BINARY_URL_FILENAME_x86=docker-machine_windows-386-0_2_0.exe"

	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\docker-machine.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
	set FEAT_ENV_CALLBACK=
	
	set FEAT_BUNDLE_ITEM=
goto :eof



:feature_docker-machine_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_FILENAME!" "!INSTALL_DIR!"
	move /y "!INSTALL_DIR!\!FEAT_BINARY_URL_FILENAME!" "!INSTALL_DIR!\docker-machine.exe"
	
goto :eof

