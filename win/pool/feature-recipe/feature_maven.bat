@echo off
call %*
goto :eof



:feature_maven
	set "FEAT_NAME=maven"
	set "FEAT_LIST_SCHEMA=3_3_3/binary"
	set "FEAT_DEFAULT_VERSION=3_3_3"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof

:feature_maven_env
	set "M2_HOME=!FEAT_INSTALL_ROOT!"
goto :eof



:feature_maven_3_3_3
	set "FEAT_VERSION=3_3_3"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=	
	set "FEAT_BINARY_URL=http://apache.mirrors.ovh.net/ftp.apache.org/dist/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.zip"
	set "FEAT_BINARY_URL_FILENAME=apache-maven-3.3.3-bin.zip"
	set FEAT_BINARY_CALLBACK=
	
	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\mvn"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	set "FEAT_ENV=feature_maven_env"
	
	set FEAT_BUNDLE_LIST=
goto :eof


:feature_maven_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
goto :eof


