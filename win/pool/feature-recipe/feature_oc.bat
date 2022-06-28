@echo off
call %*
goto :eof



:feature_oc
	set "FEAT_NAME=oc"
	set "FEAT_LIST_SCHEMA=4_10_20:binary"
	set "FEAT_DEFAULT_VERSION=4_10_20"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof



:feature_oc_4_10_20
	set "FEAT_VERSION=4_10_20"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL="
	set "FEAT_SOURCE_URL_FILENAME="
	set "FEAT_SOURCE_URL_PROTOCOL="

	set "FEAT_BINARY_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.10.20/openshift-client-windows-4.10.20.zip"
	set "FEAT_BINARY_URL_FILENAME=openshift-client-windows-4.10.20.zip"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\oc.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof



:feature_oc_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
goto :eof
