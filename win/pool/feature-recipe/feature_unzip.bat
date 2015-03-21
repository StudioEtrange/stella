@echo off
call %*
goto :eof



:feature_unzip
	set "FEAT_NAME=unzip"
	set "FEAT_LIST_SCHEMA=5_51_1/binary"
	set "FEAT_DEFAULT_VERSION=5_51_1"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_unzip_5_51_1
	set "FEAT_VERSION=5_51_1"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_PATCH_CALLBACK=
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_CALLBACK=feature_unzip_5_51_1_patch

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\unzip.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	set FEAT_ENV=
	
	set FEAT_BUNDLE_LIST=
goto :eof


:feature_unzip_5_51_1_patch
	call %STELLA_COMMON%\common.bat :copy_folder_content_into "%STELLA_REPOSITORY_LOCAL%\unzip-5.51-1-bin" "%INSTALL_DIR%"
goto :eof

:feature_unzip_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common-feature.bat :feature_apply_binary_callback
		
goto :eof


