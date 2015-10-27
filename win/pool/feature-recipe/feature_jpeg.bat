@echo off
call %*
goto :eof

REM http://www.ijg.org/
REM unnofficial sources with cmake : https://github.com/LuaDist/libjpeg
	
:feature_jpeg
	set "FEAT_NAME=jpeg"
	set "FEAT_LIST_SCHEMA=9a:source"
	set "FEAT_DEFAULT_VERSION=9a"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_jpeg_9a
	set "FEAT_VERSION=9a"
	set "FEAT_SOURCE_DEPENDENCIES="
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=http://www.ijg.org/files/jpegsr9a.zip"
	set "FEAT_SOURCE_URL_FILENAME=jpegsr9a.zip"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"
	
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=
	
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\liblibjpeg.dll"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"	

goto :eof


:feature_jpeg_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!STELLA_APP_FEATURE_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-src"
	
	call %STELLA_COMMON%\common-build.bat :set_toolset "CUSTOM" "CONFIG_TOOL NONE BUILD_TOOL nmake COMPIL_FRONTEND cl"
	
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!SRC_DIR!" "STRIP"	

	set AUTO_INSTALL_CONF_FLAG_POSTFIX=
	set "AUTO_INSTALL_BUILD_FLAG_POSTFIX=/f makefile.vc nodebug=1"
	
	set "CFLAGS=/MD"
	copy /Y "!SRC_DIR!\jconfig.vc" "!SRC_DIR!\jconfig.h"
	
	call %STELLA_COMMON%\common-build.bat :auto_build "!FEAT_NAME!" "!SRC_DIR!" "!INSTALL_DIR!" "NO_OUT_OF_TREE_BUILD NO_CONFIG SOURCE_KEEP NO_INSPECT"
	
	mkdir "!INSTALL_DIR!\bin"
	mkdir "!INSTALL_DIR!\lib"
	mkdir "!INSTALL_DIR!\include"

	copy /Y "!SRC_DIR!\*.exe" "!INSTALL_DIR!\bin\" 2>NUL
	copy /Y "!SRC_DIR!\*.dll" "!INSTALL_DIR!\bin\" 2>NUL
	copy /Y "!SRC_DIR!\*.lib" "!INSTALL_DIR!\lib\" 2>NUL
	copy /Y "!SRC_DIR!\*.h" "!INSTALL_DIR!\include\" 2>NUL


	call %STELLA_COMMON%\common.bat :del_folder "!SRC_DIR!"
	call %STELLA_COMMON%\common-build.bat :inspect_build "!INSTALL_DIR!"
	
goto :eof



