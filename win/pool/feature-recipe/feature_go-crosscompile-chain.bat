@echo off
call %*
goto :eof



:feature_go-crosscompile-chain
	set "FEAT_NAME=go-crosscompile-chain"
	set "FEAT_LIST_SCHEMA=1_4_2"
	set "FEAT_DEFAULT_VERSION=1_4_2"
	set FEAT_DEFAULT_ARCH=

	set "FEAT_BUNDLE=NESTED"
goto :eof

:feature_go-crosscompile-chain_1_4_2
	set "FEAT_VERSION=1_4_2"
	
	REM need gcc
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_BUNDLE_ITEM=go#1_4_2"

	set FEAT_ENV_CALLBACK=feature_crosscompilechain_setenv
	set "FEAT_BUNDLE_CALLBACK=feature_crosscompilechain_setenv feature_gocrosscompilechain_toolchain"

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\_GONATIVE_TOOLCHAIN_\go\pkg\darwin_amd64\go\parser.a"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\_WORKSPACE_\bin;!FEAT_INSTALL_ROOT!\_GONATIVE_TOOLCHAIN_\go\bin"

	set "BUILDCHAIN_GO_VERSION=1.4.2"
goto :eof


:feature_crosscompilechain_setenv
	set "GOPATH=!FEAT_INSTALL_ROOT!\_WORKSPACE_"

	echo ** GOLANG cross-compile environment
	echo GOROOT = !GOROOT!
	echo GOPATH = !GOPATH!
	echo    ** Restore your dependencies - from folder containing Godeps :
	echo       godep restore
	echo    ** Cross-compile your project from source
	echo       gox -verbose -osarch=windows/386 windows/amd64 linux/386 linux/amd64 darwin/386 darwin/amd64 ^<PATH_TO_PROJECT_ROOT^|PROJECT_NAME in your GOPATH^>

goto :eof

:feature_gocrosscompilechain_toolchain
	set "PATH=!FEAT_SEARCH_PATH!;%PATH%"


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