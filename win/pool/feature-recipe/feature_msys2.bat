@echo off
call %*
goto :eof

REM MSYS2  is a software distribution and a posix compatibility layer like cygwin (compatibility layer : msys2.dll)

REM MSYS2 has a package manager : pacman
REM pacman use have two kind of package (MSYS2 packages and MINGW-W64 pacakges)
REM 	MSYS2 packages rely on msys2.dll
REM		MINGW-W64 packages are windows native (there is 2 types of packages here mingw32 (32bits) or mingw64 (64bits))
REM		https://github.com/Alexpux/MINGW-packages/wiki/Creating-MINGW-packages
REM 	http://repo.msys2.org/
REM For example :
REM curl package exists as
REM			 a MSYS2 package (rely on msys2.dll) [name : msys/curl]
REM 		 a MINGW-W64 64 bits package (windows native) [ name : mingw64/mingw-w64-x86_64-curl]
REM 		 a MINGW-W64 32 bits package (windows native) [ name : mingw32/mingw-w64-i686-curl]
REM	gcc exists as
REM 		 a MSYS2 pacakge (rely on msys2.dll) [name : msys/gcc]
REM 		 a MINGW-W64 64 bits package (windows native) [ name : mingw64/mingw-w64-x86_64-gcc]
REM 		 a MINGW-W64 32 bits package (windows native) [ name : mingw32/mingw-w64-i686-gcc]



REM MINGW-W64 is a native gcc tool chain for windows
REM  http://mingw-w64.org/

REM MSYS2 vs MINGW-W64 :
REM			https://sourceforge.net/p/msys2/discussion/general/thread/dcf8f4d3/#8473/588e
REM			https://www.booleanworld.com/get-unix-linux-environment-windows-msys2/

:feature_msys2
	set "FEAT_NAME=msys2"
	set "FEAT_LIST_SCHEMA=20161025@x64:binary 20161025@x86:binary"
	set "FEAT_DEFAULT_VERSION=20161025"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof






:feature_msys2_20161025
	set "FEAT_VERSION=20161025"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x64=http://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-20161025.tar.xz"
	set "FEAT_BINARY_URL_FILENAME_x64=msys2-base-x86_64-20161025.tar.xz"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"

	set "FEAT_BINARY_URL_x86=http://repo.msys2.org/distrib/i686/msys2-base-i686-20161025.tar.xz"
	set "FEAT_BINARY_URL_FILENAME_x86=msys2-base-i686-20161025.tar.xz"
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\msys2.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!;!FEAT_INSTALL_ROOT!\usr\bin;!FEAT_INSTALL_ROOT!\mingw32\bin;!FEAT_INSTALL_ROOT!\mingw64\bin"

goto :eof

:feature_msys2_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "STRIP"
	:: update catalog
	"!FEAT_INSTALL_ROOT!\msys2_shell.cmd" -where "!FEAT_INSTALL_ROOT!" -c "HTTP_PROXY=!http_proxy! HTTPS_PROXY=!https_proxy! http_proxy=!http_proxy! https_proxy=!https_proxy! no_proxy=!no_proxy! pacman -Sy"
goto :eof
