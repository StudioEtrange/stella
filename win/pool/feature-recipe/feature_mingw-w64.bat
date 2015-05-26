@echo off
call %*
goto :eof


REM https://chocolatey.org/packages/mingw
REM http://www.gaia-gis.it/spatialite-3.0.0-BETA/mingw64_how_to.html

REM build from sourcee
REM https://ffmpeg.zeranoe.com/blog/?cat=4

REM official website : http://mingw-w64.yaxm.org/doku.php/start
REM download url from mingw-builds from : http://sourceforge.net/projects/mingw-w64/

:feature_mingw-w64
	set "FEAT_NAME=mingw-w64"
	set "FEAT_LIST_SCHEMA=mingw4_gcc4_9_2@x64/binary mingw4_gcc4_9_2@x86/binary"
	set "FEAT_DEFAULT_VERSION=mingw4_gcc4_9_2"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"

goto :eof


:feature_mingw-w64_mingw4_gcc4_9_2
	set "FEAT_VERSION=mingw4_gcc4_9_2"

	REM dwarf is 32bit only, seh is 64bit only, sjlj works with 32 / 64
	set MINGW_EXCEPTION=sjlj
	REM win32 or posix
	set MINGW_THREADS=win32
	set MINGW_GCC_VERSION=4.9.2
	REM mingw branch 
	set MINGW_MAJOR_VERSION=4
	REM package revision
	set MINGW_ZIP_REVISION=2

	REM Properties for SOURCE flavour
	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=
	
	REM Properties for BINARY flavour
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=
	set "FEAT_BINARY_URL_x86=http://downloads.sourceforge.net/mingw-w64/i686-!MINGW_GCC_VERSION!-release-!MINGW_THREADS!-!MINGW_EXCEPTION!-rt_v!MINGW_MAJOR_VERSION!-rev!MINGW_ZIP_REVISION!.7z"
	set "FEAT_BINARY_URL_FILENAME_x86="
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP"
	set "FEAT_BINARY_URL_x64=http://downloads.sourceforge.net/mingw-w64/x86_64-!MINGW_GCC_VERSION!-release-!MINGW_THREADS!-!MINGW_EXCEPTION!-rt_v!MINGW_MAJOR_VERSION!-rev!MINGW_ZIP_REVISION!.7z"
	set "FEAT_BINARY_URL_FILENAME_x64="
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"

	REM callback are list of functions
	REM manual callback (with feature_callback)
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	REM automatic callback each time feature is initialized, to init env var
	set FEAT_ENV_CALLBACK=feature_mingw-w64_setenv

	REM Dependencies (not yet implemented)
	set FEAT_DEPENDENCIES=

	REM File to test if feature is installed
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\gcc.exe"
	REM PATH to add to system PATH
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	

goto :eof

:feature_mingw-w64_setenv
	set "VAR=VALUE"
goto :eof

:feature_mingw-w64_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP"
goto :eof



