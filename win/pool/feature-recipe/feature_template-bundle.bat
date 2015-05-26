@echo off
call %*
goto :eof


:feature_template-bundle
	set "FEAT_NAME=template-bundle"
	set "FEAT_LIST_SCHEMA=1_0_0@x64 1_0_0@x86"
	set "FEAT_DEFAULT_VERSION=1_0_0"
	set "FEAT_DEFAULT_ARCH=x64"

	REM should be empty or MERGE or NESTED or LIST
	REM NESTED : each item will be installed inside the bundle path in a separate directory
	REM MERGE : each item will be installed in the bundle path
	REM LIST : this bundle is just a list of item that will be installed normally
	set "FEAT_BUNDLE=NESTED"
goto :eof


:feature_template-bundle_1_0_0
	REM if FEAT_ARCH is not not null, properties FOO_ARCH=BAR will be selected and setted as FOO=BAR
	REM if FOO_ARCH is empty, FOO will not be changed

	set "FEAT_VERSION=1_0_0"

	REM Dependencies (not yet implemented)
	set FEAT_DEPENDENCIES=

	REM Properties for bundle
	set FEAT_BUNDLE_ITEM=
	set "FEAT_BUNDLE_ITEM_x86=foo#1_0_0@x86 bar#1_0_0@x86"
	set "FEAT_BUNDLE_ITEM_x84=foo#1_0_0@x64 bar#1_0_0@x64"

	REM callback are list of functions
	REM automatic callback each time feature is initialized, to init env var
	set FEAT_ENV_CALLBACK=feature_template-bundle_setenv
	REM automatic callback after all items in bundle list are installed
	set FEAT_BUNDLE_CALLBACK=

		
	REM File to test if feature is installed
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\template-bundle.exe"

	REM PATH to add to system PATH
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	

goto :eof

:feature_template-bundle_setenv
	set "TEMPLATE_BUNDLE_HOME_HOME=!FEAT_INSTALL_ROOT!"
goto :eof



