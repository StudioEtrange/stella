@echo off
call %*
goto :eof


:feature_fasttext
	set "FEAT_NAME=fasttext"
	set "FEAT_LIST_SCHEMA=SNAPSHOT:source"
	set "FEAT_DEFAULT_VERSION=SNAPSHOT"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_fasttext_SNAPSHOT
	set "FEAT_VERSION=SNAPSHOT"
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=https://github.com/facebookresearch/fastText"
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=GIT

	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\fasttext.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\"

goto :eof

:feature_fasttext_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!STELLA_APP_FEATURE_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-src"

	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!SRC_DIR!" "DEST_ERASE"

	call %STELLA_COMMON%\common-build.bat :set_toolset "CUSTOM" "CONFIG_TOOL NONE BUILD_TOOL mingw-make COMPIL_FRONTEND mingw-gcc"

	set AUTO_INSTALL_CONF_FLAG_POSTFIX=
	set AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	call %STELLA_COMMON%\common-feature.bat :feature_callback


	call %STELLA_COMMON%\common-build.bat :auto_build "!FEAT_NAME!" "!SRC_DIR!" "!INSTALL_DIR!" "NO_CONFIG NO_INSTALL SOURCE_KEEP"

	call %STELLA_COMMON%\common :copy_folder_content_into "!SRC_DIR!" "!INSTALL_DIR!"

	call %STELLA_COMMON%\common.bat :del_folder "!SRC_DIR!"
goto :eof
