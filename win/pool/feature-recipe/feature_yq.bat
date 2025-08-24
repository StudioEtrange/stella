@echo off
call %*
goto :eof


:feature_yq
	set "FEAT_NAME=yq"
	set "FEAT_LIST_SCHEMA=4_47_1@x64:binary 4_47_1@x86:binary"
	set "FEAT_DEFAULT_VERSION=4_47_1"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_yq_4_47_1
	set "FEAT_VERSION=4_47_1"

	if "!STELLA_CURRENT_CPU_FAMILY!"=="intel" (
		set "FEAT_BINARY_URL_x86=https://github.com/mikefarah/yq/releases/download/v4.47.1/yq_windows_386.exe"
		set "FEAT_BINARY_URL_FILENAME_x86=yq_windows_386-4_47_1.exe"
		set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP"
		set "FEAT_BINARY_URL_x64=https://github.com/mikefarah/yq/releases/download/v4.47.1/yq_windows_amd64.exe"
		set "FEAT_BINARY_URL_FILENAME_x64=yq_windows_amd64-4_47_1.exe"
		set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP"
	)
	if "!STELLA_CURRENT_CPU_FAMILY!"=="arm" (
		set "FEAT_BINARY_URL_x86=https://github.com/mikefarah/yq/releases/download/v4.47.1/yq_windows_arm.exe"
		set "FEAT_BINARY_URL_FILENAME_x86=yq_windows_arm-4_47_1.exe"
		set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP"
		set "FEAT_BINARY_URL_x64=https://github.com/mikefarah/yq/releases/download/v4.47.1/yq_windows_arm64.exe"
		set "FEAT_BINARY_URL_FILENAME_x64=yq_windows_arm64-4_47_1.exe"
		set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP"
	)

	REM List of files to test if feature is installed
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\yq.exe"
	REM PATH to add to system PATH
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"

goto :eof


:feature_yq_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
	move /y "!FEAT_INSTALL_ROOT!\!FEAT_BINARY_URL_FILENAME!" "!FEAT_INSTALL_ROOT!\yq.exe"
goto :eof
