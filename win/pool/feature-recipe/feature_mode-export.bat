@echo off
call %*
goto :eof


:feature_mode-export
	set "FEAT_NAME=mode-export"
	set "FEAT_LIST_SCHEMA=1"
	set "FEAT_DEFAULT_VERSION=1"
	set "FEAT_DEFAULT_ARCH="

	set "FEAT_BUNDLE=MERGE_LIST"
goto :eof


:feature_mode-export_1
	set "FEAT_VERSION=1"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_BUNDLE_ITEM=!FEAT_MODE_EXPORT_SCHEMA!"

	set FEAT_ENV_CALLBACK=
	set FEAT_BUNDLE_CALLBACK=

	set FEAT_INSTALL_TEST=
	set FEAT_SEARCH_PATH=

goto :eof
