@echo off
call %*
goto :eof


:feature_template
	set "FEAT_NAME=template"
	set "FEAT_LIST_SCHEMA=1_0_0@x64/binary 1_0_0@x86/binary"
	set "FEAT_DEFAULT_VERSION=1_0_0"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_template_1_0_0
	REM if FEAT_ARCH is not not null, properties FOO_ARCH=BAR will be selected and setted as FOO=BAR
	REM if FOO_ARCH is empty, FOO will not be changed

	set "FEAT_VERSION=1_0_0"

	REM Dependencies (not yet implemented)
	set FEAT_DEPENDENCIES=

	REM Properties for SOURCE flavour
	set "FEAT_SOURCE_URL=http://foo.com/template-1_0_0-src.zip"
	set "FEAT_SOURCE_URL_FILENAME="
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"
	
	REM Properties for BINARY flavour
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=
	set "FEAT_BINARY_URL_x86=http://foo.com/bar"
	set "FEAT_BINARY_URL_FILENAME_x86=template-1_0_0-x86.zip"
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP"
	set "FEAT_BINARY_URL_x64=http://foo.com/template-1_0_0-x86.zip"
	set "FEAT_BINARY_URL_FILENAME_x64=template-1_0_0-x86.zip"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"

	REM callback are list of functions
	REM manual callback (with feature_callback)
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	REM automatic callback each time feature is initialized, to init env var
	set FEAT_ENV_CALLBACK=feature_template_setenv

	

	REM File to test if feature is installed
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\template.exe"
	REM PATH to add to system PATH
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	

goto :eof

:feature_template_setenv
	set "TEMPLATE_HOME=!FEAT_INSTALL_ROOT!"
goto :eof

:feature_template_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
	call %STELLA_COMMON%\common-feature :feature_callback

goto :eof

:feature_template_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!FEAT_INSTALL_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-src"
	set "BUILD_DIR=!FEAT_INSTALL_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-build"

	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!SRC_DIR!" "DEST_ERASE STRIP"
	
	call %STELLA_COMMON%\common-feature :feature_callback

	REM build instructions
	cd /D %BUILD_DIR%
	nmake -f %SRC_DIR%\Makefile

goto :eof


