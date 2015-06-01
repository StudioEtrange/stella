@echo off
call %*
goto :eof


:feature_docker-bundle
	set "FEAT_NAME=docker-bundle"
	set "FEAT_LIST_SCHEMA=1_0_0@x64 1_0_0@x86"
	set "FEAT_DEFAULT_VERSION=1_0_0"
	set "FEAT_DEFAULT_ARCH=x64"

	set "FEAT_BUNDLE=NESTED"
goto :eof

:feature_docker-bundle_1_0_0
	set "FEAT_VERSION=1_0_0"
	
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_BUNDLE_ITEM=
	set "FEAT_BUNDLE_ITEM_x86=docker-client#1_6_0@x86 docker-machine#0_2_0@x86"
	set "FEAT_BUNDLE_ITEM_x64=docker-client#1_6_0@x64 docker-machine#0_2_0@x64"

	set FEAT_ENV_CALLBACK=
	set FEAT_BUNDLE_CALLBACK=

	set FEAT_INSTALL_TEST=
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
	
goto :eof
