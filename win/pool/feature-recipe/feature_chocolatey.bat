@echo off
call %*
goto :eof



:feature_chocolatey
	set "FEAT_NAME=chocolatey"
	set "FEAT_LIST_SCHEMA=latest:binary"
	set "FEAT_DEFAULT_VERSION=latest"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_chocolatey_latest
	set "FEAT_VERSION=latest"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=https://chocolatey.org/install.ps1"
	set "FEAT_BINARY_URL_FILENAME=chocolatey.ps1"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\choco.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
goto :eof


:feature_chocolatey_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!STELLA_APP_TEMP_DIR!" "DEST_ERASE FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
	
	set "ChocolateyInstall=!FEAT_INSTALL_ROOT!" && !POWERSHELL! -NoProfile -ExecutionPolicy Bypass -Command "& '!STELLA_APP_TEMP_DIR!\chocolatey.ps1' %*"

	del /q "!STELLA_APP_CACHE_DIR!\chocolatey.ps1"
	del /q "!STELLA_APP_TEMP_DIR!\chocolatey.ps1"

goto :eof


