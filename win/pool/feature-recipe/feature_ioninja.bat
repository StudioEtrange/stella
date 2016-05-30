@echo off
call %*
goto :eof

:feature_ioninja
	set "FEAT_NAME=ioninja"
	set "FEAT_LIST_SCHEMA=3_6_5@x86:binary 3_6_5@x64:binary"
	set "FEAT_DEFAULT_VERSION=3_6_5"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof



:feature_ioninja_3_6_5
	set "FEAT_VERSION=3_6_5"


	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x64=http://tibbo.com/downloads/archive/ioninja/ioninja-3.6.5/ioninja-windows-3.6.5-amd64.7z"
	set "FEAT_BINARY_URL_FILENAME_x64=ioninja-windows-3.6.5-amd64.7z"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"
	set "FEAT_BINARY_URL_x86=http://tibbo.com/downloads/archive/ioninja/ioninja-3.6.5/ioninja-windows-3.6.5-x86.7z"
	set "FEAT_BINARY_URL_FILENAME_x86=ioninja-windows-3.6.5-x86.7z"
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\ioninja.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof



:feature_ioninja_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
goto :eof
