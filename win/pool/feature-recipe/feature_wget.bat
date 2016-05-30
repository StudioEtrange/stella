@echo off
call %*
goto :eof

REM binaries from here are out of date http://gnuwin32.sourceforge.net/packages/wget.htm
REM new binaries are available here https://eternallybored.org/misc/wget/

:feature_wget
	set "FEAT_NAME=wget"
	set "FEAT_LIST_SCHEMA=1_17_1@x86:binary 1_17_1@x64:binary 1_17_1_INTERNAL@x86:binary"
	set "FEAT_DEFAULT_VERSION=1_17_1"
	set "FEAT_DEFAULT_ARCH=x86"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof



:feature_wget_1_17_1
	set "FEAT_VERSION=1_17_1"


	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x64=https://eternallybored.org/misc/wget/releases/wget-1.17.1-win64.zip"
	set "FEAT_BINARY_URL_FILENAME_x64=wget-1.17.1-win64.zip"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"
	set "FEAT_BINARY_URL_x86=https://eternallybored.org/misc/wget/releases/wget-1.17.1-win32.zip"
	set "FEAT_BINARY_URL_FILENAME_x86=wget-1.17.1-win32.zip"
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\wget.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof


:feature_wget_1_17_1_INTERNAL
	set "FEAT_VERSION=1_17_1_INTERNAL"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x64="
	set "FEAT_BINARY_URL_FILENAME_x64="
	set "FEAT_BINARY_URL_PROTOCOL_x64="
	set "FEAT_BINARY_URL_x86=%STELLA_ARTEFACT%\wget-1.17.1-win32.zip"
	set "FEAT_BINARY_URL_FILENAME_x86=wget-1.17.1-win32.zip"
	set "FEAT_BINARY_URL_PROTOCOL_x86=FILE_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\wget.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof



:feature_wget_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
goto :eof
