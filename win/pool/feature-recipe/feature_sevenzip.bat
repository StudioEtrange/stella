@echo off
call %*
goto :eof



:feature_sevenzip
	set "FEAT_NAME=sevenzip"
	set "FEAT_LIST_SCHEMA=9_38:binary"
	set "FEAT_DEFAULT_VERSION=9_38"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_sevenzip_9_38
	REM portable 7-Zip 9.38Beta rev11 from http://www.winpenpack.com/en/download.php?view.46
	set "FEAT_VERSION=9_38"
	
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=http://downloads.sourceforge.net/project/winpenpack/X-7Zip/releases/X-7Zip_9.38-beta_rev11.zip"
	set "FEAT_BINARY_URL_FILENAME=X-7Zip_9.38-beta_rev11.zip"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\Bin\7-Zip\7z.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\Bin\7-Zip"

goto :eof



:feature_sevenzip_install_binary

	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "FORCE_NAME !FEAT_BINARY_URL_FILENAME!"

goto :eof


