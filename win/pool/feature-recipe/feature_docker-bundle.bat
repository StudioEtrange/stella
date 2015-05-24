@echo off
call %*
goto :eof



:feature_docker-bundle
	set "FEAT_NAME=docker-bundle"
	set "FEAT_LIST_SCHEMA=1"
	set "FEAT_DEFAULT_VERSION=1"
	set FEAT_DEFAULT_ARCH=
	set FEAT_DEFAULT_FLAVOUR=

	set "FEAT_BUNDLE=TRUE"
goto :eof

:feature_docker-bundle_1
	set "FEAT_VERSION=1"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set FEAT_INSTALL_TEST=
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
	set FEAT_ENV=
	
	REM BUNDLE ITEM LIST
	set "FEAT_BUNDLE_LIST=docker-client#1_6_0 docker-machine#0_2_0"
goto :eof
