@echo off
call %*
goto :eof




:feature_go-build-chain
	set "FEAT_NAME=go-build-chain"
	set "FEAT_LIST_SCHEMA=1_4_2"
	set "FEAT_DEFAULT_VERSION=1_4_2"
	set FEAT_DEFAULT_ARCH=

	set "FEAT_BUNDLE=NESTED"
goto :eof

:feature_go-build-chain_1_4_2
	set "FEAT_VERSION=1_4_2"
	
	REM need gcc
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_BUNDLE_ITEM="go#1_4_2"

	set "FEAT_ENV_CALLBACK=feature_go_buildchain_setenv"
	set "FEAT_BUNDLE_CALLBACK=feature_go_buildchain_setenv feature_go_prepare_buildchain"

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\_WORKSPACE_\bin\godep"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\_WORKSPACE_\bin"

	set "BUILDCHAIN_GO_VERSION=1.4.2"
goto :eof


:feature_go_buildchain_setenv
	set "GOPATH=!FEAT_INSTALL_ROOT!\_WORKSPACE_"

	echo ** GOLANG build environment
	echo   ** Restore your dependencies - from folder containing Godeps :
	echo      godep restore
goto :eof

:feature_go_prepare_buildchain
	set PATH="!FEAT_SEARCH_PATH!;!PATH!"


	echo ** install godep
	go get github.com/tools/godep
	
goto :eof
