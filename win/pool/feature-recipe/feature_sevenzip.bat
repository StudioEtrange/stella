@echo off
call %*
goto :eof



:feature_sevenzip
	set "FEAT_NAME=sevenzip"
	set "FEAT_LIST_SCHEMA=9_38/binary"
	set "FEAT_DEFAULT_VERSION=9_38"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_sevenzip_9_38
	REM portable 7-Zip 9.38Beta rev11 from http://www.winpenpack.com/en/download.php?view.46
	set "FEAT_VERSION=9_38"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL=http://sourceforge.net/projects/winpenpack/files/X-7Zip/releases/X-7Zip_9.38-beta_rev11.zip/download"
	set "FEAT_BINARY_URL_FILENAME=X-7Zip_9.38-beta_rev11.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\Bin\7-Zip\7z.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\Bin\7-Zip"
	set FEAT_ENV=
	
	set FEAT_BUNDLE_LIST=
goto :eof



:feature_sevenzip_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE"

goto :eof


