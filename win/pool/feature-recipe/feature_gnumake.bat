@echo off
call %*
goto :eof



:feature_gnumake
	set "FEAT_NAME=gnumake"
	set "FEAT_LIST_SCHEMA=3_81:binary"
	set "FEAT_DEFAULT_VERSION=3_81"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_gnumake_3_81
	set "FEAT_VERSION=3_81"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=
	
	set "FEAT_BINARY_URL=http://downloads.sourceforge.net/project/gnuwin32/make/3.81/make-3.81-bin.zip http://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-dep.zip"
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\make.exe !FEAT_INSTALL_ROOT!\bin\libiconv2.dll"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"

goto :eof


:feature_gnumake_install_binary
	
	if exist "!FEAT_INSTALL_ROOT!" rmdir /s/q "!FEAT_INSTALL_ROOT!"

	for %%i in (!FEAT_BINARY_URL!) do (
		call %STELLA_COMMON%\common.bat :download_uncompress "%%i" "_AUTO_" "!FEAT_INSTALL_ROOT!" ""
	)	
goto :eof
