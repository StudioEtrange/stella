@echo off
call %*
goto :eof

REM TODO : build static lib

:feature_freetype
	set "FEAT_NAME=freetype"
	set "FEAT_LIST_SCHEMA=2_6_1:source"
	set "FEAT_DEFAULT_VERSION=2_6_1"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_freetype_2_6_1
	set "FEAT_VERSION=2_6_1"
	set "FEAT_SOURCE_DEPENDENCIES=zlib#1_2_8 libpng#1_6_18 bzip2#1_0_6"
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=http://downloads.sourceforge.net/project/freetype/freetype2/2.6.1/ft261.zip"
	set "FEAT_SOURCE_URL_FILENAME=ft261.zip"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"
	
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=
	
	set "FEAT_SOURCE_CALLBACK=feature_freetype_patch feature_freetype_link"
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\libfreetype.dll"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"	

goto :eof

:feature_freetype_patch
	REM patch CMakeLists to allow build DLL on windows with mingw
	patch --verbose "!SRC_DIR!\CMakeLists.txt" "!STELLA_PATCH!\freetype\patch-CMakeLists-mingw-shared.txt"

	REM TODO dont know if we need this
	REM patch long to 64bits
	REM https://github.com/Robmaister/SharpFont.Dependencies/tree/master/freetype2
	REM https://github.com/Robmaister/SharpFont.Dependencies/blob/master/freetype2/win64.patch
	REM if "!STELLA_BUILD_ARCH!"=="x64" (
		REM copy /Y "!STELLA_PATCH!\freetype\win64.patch" "!SRC_DIR!\"
		REM cd /D "!SRC_DIR!"
		REM patch -p0 < win64.patch
	REM )

goto :eof


:feature_freetype_link
	call %STELLA_COMMON%\common-build.bat :link_feature_library "zlib#1_2_8" "FORCE_DYNAMIC"
	call %STELLA_COMMON%\common-build.bat :link_feature_library "libpng#1_6_18" "FORCE_DYNAMIC"
	call %STELLA_COMMON%\common-build.bat :link_feature_library "bzip2#1_0_6" "FORCE_STATIC FORCE_RENAME libbz2-static.lib libbz2.lib"
goto :eof

:feature_freetype_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!STELLA_APP_FEATURE_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-src"
	
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!SRC_DIR!" "DEST_ERASE STRIP"	

	call %STELLA_COMMON%\common-build.bat :set_toolset "CUSTOM" "CONFIG_TOOL cmake BUILD_TOOL mingw-make COMPIL_FRONTEND gcc"
	REM call %STELLA_COMMON%\common-build.bat :set_toolset "STANDARD" 

	set "AUTO_INSTALL_CONF_FLAG_POSTFIX=-DBUILD_SHARED_LIBS:BOOL=TRUE"
	set "AUTO_INSTALL_BUILD_FLAG_POSTFIX="
	

	call %STELLA_COMMON%\common-feature.bat :feature_callback

	:: out of tree build do not work
	call %STELLA_COMMON%\common-build.bat :auto_build "!FEAT_NAME!" "!SRC_DIR!" "!INSTALL_DIR!"

goto :eof



