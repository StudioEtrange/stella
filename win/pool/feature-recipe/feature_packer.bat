@echo off
call %*
goto :eof


:feature_packer
	set "FEAT_NAME=packer"
	set "FEAT_LIST_SCHEMA=0_7_5@x64:binary 0_7_5@x86:binary"
	set "FEAT_DEFAULT_VERSION=0_7_5"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_packer_0_7_5
	set "FEAT_VERSION=0_7_5"
	
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x86=https://dl.bintray.com/mitchellh/packer/packer_0.7.5_windows_386.zip"
	set "FEAT_BINARY_URL_FILENAME_x86="
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP"
	set "FEAT_BINARY_URL_x64=https://dl.bintray.com/mitchellh/packer/packer_0.7.5_windows_amd64.zip"
	set "FEAT_BINARY_URL_FILENAME_x64="
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\packer.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"

goto :eof


:feature_packer_install_binary
call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP"
		
goto :eof


