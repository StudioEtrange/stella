@echo off
call %*
goto :eof


REM TODO : do not work ==> need gcc for gonative when building go

:feature_go-buildchain-bundle
	set "FEAT_NAME=go-buildchain-bundle"
	set "FEAT_LIST_SCHEMA=1_4_2"
	set "FEAT_DEFAULT_VERSION=1_4_2"
	set FEAT_DEFAULT_ARCH=
	set FEAT_DEFAULT_FLAVOUR=

	set "FEAT_BUNDLE=TRUE"
goto :eof

:feature_go-buildchain-bundle_1_4_2
	set "FEAT_VERSION=1_4_2"
	set "BUILDCHAIN_GO_VERSION=1.4.2"
	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_CALLBACK=feature_prepare_toolchain

	set FEAT_DEPENDENCIES=
	set FEAT_INSTALL_TEST=
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\_WORKSPACE_\bin"
	set FEAT_ENV=feature_go-buildchain-bundle_set_env
	
	REM BUNDLE ITEM LIST
	set "FEAT_BUNDLE_LIST=go#1_4_2"
goto :eof


:feature_go-buildchain-bundle_set_env
	set "GOPATH=!FEAT_INSTALL_ROOT!\_WORKSPACE_"
goto :eof

:feature_prepare_toolchain
	set "PATH=!FEAT_SEARCH_PATH!;%PATH%"
	call :feature_go-buildchain-bundle_set_env


	echo ** install godep
	go get github.com/tools/godep

	echo ** install gox
  	go get github.com/mitchellh/gox

	echo ** install gonative
	go get github.com/inconshreveable/gonative

	echo ** build toolchain
	if not exist "!FEAT_INSTALL_ROOT!\_GONATIVE_TOOLCHAIN_" mkdir "!FEAT_INSTALL_ROOT!\_GONATIVE_TOOLCHAIN_"
	cd /D "!FEAT_INSTALL_ROOT!\_GONATIVE_TOOLCHAIN_"
	gonative build --version="!BUILDCHAIN_GO_VERSION!" --platforms="windows_386 windows_amd64 linux_386 linux_amd64 darwin_386 darwin_amd64"
	
goto :eof