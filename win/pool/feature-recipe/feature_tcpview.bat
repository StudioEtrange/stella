@echo off
call %*
goto :eof


:feature_tcpview
	set "FEAT_NAME=tcpview"
	set "FEAT_LIST_SCHEMA=last:binary"
	set "FEAT_DEFAULT_VERSION=last"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_tcpview_last
	set "FEAT_VERSION=last"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=https://download.sysinternals.com/files/TCPView.zip"
	set "FEAT_BINARY_URL_FILENAME=TCPView.zip"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"
	
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\Tcpview.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\"
goto :eof


:feature_tcpview_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
goto :eof


