@echo off
call %*
goto :eof

REM this is only docker client

:feature_docker
	set "FEAT_NAME=docker"
	set "FEAT_LIST_SCHEMA=1_6_0@x64:binary 1_6_0@x86:binary"
	set "FEAT_DEFAULT_VERSION=1_6_0"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_docker_1_6_0
	set "FEAT_VERSION=1_6_0"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x64=https://get.docker.com/builds/Windows/x86_64/docker-1.6.0.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=docker-x86_64-1.6.0.exe"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP"

	set "FEAT_BINARY_URL_x86=https://get.docker.com/builds/Windows/i386/docker-1.6.0.exe"
	set "FEAT_BINARY_URL_FILENAME_x86=docker-i386-1.6.0.exe"
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\docker.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"

goto :eof



:feature_docker_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
	move /y "!FEAT_INSTALL_ROOT!\!FEAT_BINARY_URL_FILENAME!" "!FEAT_INSTALL_ROOT!\docker.exe"
goto :eof

