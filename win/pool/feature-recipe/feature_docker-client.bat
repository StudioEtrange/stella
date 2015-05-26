@echo off
call %*
goto :eof


:feature_docker-client
	set "FEAT_NAME=docker-client"
	set "FEAT_LIST_SCHEMA=1_6_0@x64/binary 1_6_0@x86/binary"
	set "FEAT_DEFAULT_VERSION=1_6_0"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_docker-client_1_6_0
	set "FEAT_VERSION=1_6_0"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=

	set "FEAT_BINARY_URL_x64=https://get.docker.com/builds/Windows/x86_64/docker-1.6.0.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=docker-x86_64-1.6.0.exe"
	set "FEAT_BINARY_URL_x86=https://get.docker.com/builds/Windows/i386/docker-1.6.0.exe"
	set "FEAT_BINARY_URL_FILENAME_x86=docker-i386-1.6.0.exe"

	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\docker.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
	set FEAT_ENV_CALLBACK=
	
	set FEAT_BUNDLE_ITEM=
goto :eof



:feature_docker-client_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_FILENAME!" "!INSTALL_DIR!"
	move /y "!INSTALL_DIR!\!FEAT_BINARY_URL_FILENAME!" "!INSTALL_DIR!\docker.exe"
	
goto :eof

