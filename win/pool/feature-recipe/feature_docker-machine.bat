@echo off
call %*
goto :eof


:feature_docker-machine
	set "FEAT_NAME=docker-machine"
	set "FEAT_LIST_SCHEMA=0_2_0@x64:binary 0_2_0@x86:binary 0_4_0@x86:binary 0_4_0@x64:binary"
	set "FEAT_DEFAULT_VERSION=0_4_0"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_docker-machine_0_2_0
	set "FEAT_VERSION=0_2_0"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x64=https://github.com/docker/machine/releases/download/v0.2.0/docker-machine_windows-amd64.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=docker-machine_windows-amd64-0_2_0.exe"
	set FEAT_BINARY_URL_PROTOCOL_x64=HTTP
	set "FEAT_BINARY_URL_x86=https://github.com/docker/machine/releases/download/v0.2.0/docker-machine_windows-386.exe"
	set "FEAT_BINARY_URL_FILENAME_x86=docker-machine_windows-386-0_2_0.exe"
	set FEAT_BINARY_URL_PROTOCOL_x86=HTTP

	set FEAT_ENV_CALLBACK=
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\docker-machine.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof


:feature_docker-machine_0_4_0
	set "FEAT_VERSION=0_4_0"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x64=https://github.com/docker/machine/releases/download/v0.4.0/docker-machine_windows-amd64.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=docker-machine_windows-amd64-0_4_0.exe"
	set FEAT_BINARY_URL_PROTOCOL_x64=HTTP
	set "FEAT_BINARY_URL_x86=https://github.com/docker/machine/releases/download/v0.4.0/docker-machine_windows-386.exe"
	set "FEAT_BINARY_URL_FILENAME_x86=docker-machine_windows-386-0_4_0.exe"
	set FEAT_BINARY_URL_PROTOCOL_x86=HTTP

	set FEAT_ENV_CALLBACK=
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\docker-machine.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof


:feature_docker-machine_install_binary

	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE"
	
	move /y "!FEAT_INSTALL_ROOT!\!FEAT_BINARY_URL_FILENAME!" "!FEAT_INSTALL_ROOT!\docker-machine.exe"
	
goto :eof

