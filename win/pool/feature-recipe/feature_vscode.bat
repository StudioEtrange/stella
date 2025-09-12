@echo off
call %*
goto :eof


REM https://github.com/microsoft/vscode
REM existing versions lists : https://github.com/microsoft/vscode/tags
REM latest download links : https://code.visualstudio.com/Download
REM all versions download links : https://code.visualstudio.com/docs/supporting/faq#_previous-release-versions

:feature_vscode
	set "FEAT_NAME=vscode"
	REM 1_98_2 is last version that can run (remotely or not) on linux glibc 2.17
	set "FEAT_LIST_SCHEMA=1_104_0@x64:binary 1_98_2@x64:binary 1_96_4@x64:binary"
	set "FEAT_DEFAULT_VERSION=1_104_0"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof



:feature_vscode_1_104_0
	set "FEAT_VERSION=1_104_0"
	
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x86="
	set "FEAT_BINARY_URL_FILENAME_x86="
	set "FEAT_BINARY_URL_PROTOCOL_x86="
	set "FEAT_BINARY_URL_x64=https://update.code.visualstudio.com/1.104.0/win32-x64-archive/stable"
	set "FEAT_BINARY_URL_FILENAME_x64=VSCode-win32-x64-1.104.0.zip"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\Code.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"

goto :eof


:feature_vscode_1_98_2
	set "FEAT_VERSION=1_98_2"
	
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x86="
	set "FEAT_BINARY_URL_FILENAME_x86="
	set "FEAT_BINARY_URL_PROTOCOL_x86="
	set "FEAT_BINARY_URL_x64=https://update.code.visualstudio.com/1.98.2/win32-x64-archive/stable"
	set "FEAT_BINARY_URL_FILENAME_x64=VSCode-win32-x64-1.98.2.zip"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\Code.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"

goto :eof



:feature_vscode_1_96_4
	set "FEAT_VERSION=1_96_4"
	
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x86="
	set "FEAT_BINARY_URL_FILENAME_x86="
	set "FEAT_BINARY_URL_PROTOCOL_x86="
	set "FEAT_BINARY_URL_x64=https://update.code.visualstudio.com/1.96.4/win32-x64-archive/stable"
	set "FEAT_BINARY_URL_FILENAME_x64=VSCode-win32-x64-1.96.4.zip"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\Code.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"

goto :eof


:feature_vscode_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE FORCE_NAME !FEAT_BINARY_URL_FILENAME!"	
goto :eof


