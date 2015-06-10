@echo off
call %*
goto :eof


REM https://chocolatey.org/packages/mingw
REM http://www.gaia-gis.it/spatialite-3.0.0-BETA/mingw64_how_to.html

REM build from sourcee
REM https://ffmpeg.zeranoe.com/blog/?cat=4

REM official website : http://mingw-w64.yaxm.org/doku.php/start
REM download url from mingw-builds from : http:/:sourceforge.net/projects/mingw-w64/

:feature_mingw-w64
	set "FEAT_NAME=mingw-w64"
	set "FEAT_LIST_SCHEMA=mingw4_gcc4_9_2@x64:binary mingw4_gcc4_9_2@x86:binary"
	set "FEAT_DEFAULT_VERSION=mingw4_gcc4_9_2"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"

goto :eof


:feature_mingw-w64_mingw4_gcc4_9_2
	set "FEAT_VERSION=mingw4_gcc4_9_2"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	REM dwarf is 32bit only, seh is 64bit only, sjlj works with 32 / 64
	set MINGW_EXCEPTION=sjlj
	if "!FEAT_ARCH!"=="x64" set MINGW_EXCEPTION=seh
	if "!FEAT_ARCH!"=="x86" set MINGW_EXCEPTION=dwarf

	REM win32 or posix
	set MINGW_THREADS=win32
	set MINGW_GCC_VERSION=4.9.2
	REM mingw branch 
	set MINGW_MAJOR_VERSION=4
	REM package revision
	set MINGW_ZIP_REVISION=2

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=
	set "FEAT_BINARY_URL_x86=http://downloads.sourceforge.net/mingw-w64/i686-!MINGW_GCC_VERSION!-release-!MINGW_THREADS!-!MINGW_EXCEPTION!-rt_v!MINGW_MAJOR_VERSION!-rev!MINGW_ZIP_REVISION!.7z"
	set "FEAT_BINARY_URL_FILENAME_x86="
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP"
	set "FEAT_BINARY_URL_x64=http://downloads.sourceforge.net/mingw-w64/x86_64-!MINGW_GCC_VERSION!-release-!MINGW_THREADS!-!MINGW_EXCEPTION!-rt_v!MINGW_MAJOR_VERSION!-rev!MINGW_ZIP_REVISION!.7z"
	set "FEAT_BINARY_URL_FILENAME_x64="
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\gcc.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	

goto :eof


:feature_mingw-w64_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP"
goto :eof



