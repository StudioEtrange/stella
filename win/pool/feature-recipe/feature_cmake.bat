@echo off
call %*
goto :eof

:feature_cmake
	set "FEAT_NAME=cmake"
	set "FEAT_LIST_SCHEMA=3_1_2@x86/binary 2_8_12@x86/binary"
	set "FEAT_DEFAULT_VERSION=3_1_2"
	set "FEAT_DEFAULT_ARCH=x86"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_cmake_3_1_2
	set "FEAT_VERSION=3_1_2"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_PATCH_CALLBACK=
	set "FEAT_BINARY_URL_x86=http://www.cmake.org/files/v3.1/cmake-3.1.2-win32-x86.zip"
	set "FEAT_BINARY_URL_FILENAME_x86=cmake-3.1.2-win32-x86.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\cmake.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"

	set FEAT_BUNDLE_LIST=
goto :eof


:feature_cmake_2_8_12
	set "FEAT_VERSION=2_8_12"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_PATCH_CALLBACK=
	set "FEAT_BINARY_URL_x86=http://www.cmake.org/files/v2.8/cmake-2.8.12-win32-x86.zip"
	set "FEAT_BINARY_URL_FILENAME_x86=cmake-2.8.12-win32-x86.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\cmake.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"

	set FEAT_BUNDLE_LIST=
goto :eof

:feature_cmake_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
goto :eof


