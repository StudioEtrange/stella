@echo off
call %*
goto :eof

REM TODO : not finished

:feature_docker-swarm
	set "FEAT_NAME=docker-swarm"
	set "FEAT_LIST_SCHEMA=1_6_0@x64/binary 1_6_0@x86/binary"
	set "FEAT_DEFAULT_VERSION=1_6_0"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_docker-swarm_1_6_0
	set "FEAT_VERSION=1_6_0"

	set "FEAT_SOURCE_URL=https://github.com/docker/swarm/archive/v0.2.0.zip"
	set "FEAT_SOURCE_URL_FILENAME=docker-swarm-0.2.0.zip"
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_CALLBACK=

	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\docker.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
	set FEAT_ENV_CALLBACK=
	
	set FEAT_BUNDLE_ITEM=
goto :eof



:feature_docker-swarm_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_FILENAME!" "!INSTALL_DIR!" "DEST_ERASE"

	
goto :eof

