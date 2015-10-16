@echo off
call %*
goto :eof

:feature_docker-swarm
	set "FEAT_NAME=docker-swarm"
	set "FEAT_LIST_SCHEMA=0_2_0:source 0_2_0:source"
	set "FEAT_DEFAULT_VERSION=0_2_0"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_docker-swarm_0_2_0
	set "FEAT_VERSION=0_2_0"

	set FEAT_SOURCE_DEPENDENCIES="go-build-chain#1_4_2"
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=https://github.com/docker/swarm/archive/v0.2.0.zip"
	set "FEAT_SOURCE_URL_FILENAME=docker-swarm-0.2.0.zip"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"
	
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\swarm.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"

goto :eof



:feature_docker-swarm_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!FEAT_INSTALL_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-src"
	set BUILD_DIR=

	set "GOPATH=!SRC_DIR!"
	set "SRC_DIR=!SRC_DIR!\src\github.com\docker\swarm"
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!SRC_DIR!" "DEST_ERASE STRIP FORCE_NAME !FEAT_SOURCE_URL_FILENAME!"
	
	echo ** Building .. !SRC_DIR!

	cd /D "!SRC_DIR!"
	godep restore

	cd /D "!GOPATH!"
	go install github.com/docker/swarm

	copy /y "!GOPATH!\bin\swarm.exe" "!INSTALL_DIR!\swarm.exe"
goto :eof

