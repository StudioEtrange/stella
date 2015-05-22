@echo off
call %*
goto :eof

REM Recipe for Oracle Java SE Development Kit
REM http://stackoverflow.com/questions/1619662/how-can-i-get-the-latest-jre-jdk-as-a-zip-file-rather-than-exe-or-msi-installe

:feature_oracle-javasejdk
	set "FEAT_NAME=oracle-javasejdk"
	set "FEAT_LIST_SCHEMA=8u45@x86/binary 8u45@x64/binary"
	set "FEAT_DEFAULT_VERSION=8u45"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof

:feature_oraclesejdk_env
	set "JAVA_HOME=!FEAT_INSTALL_ROOT!"
goto :eof



:feature_oracle-javasejdk_8u45
	set "FEAT_VERSION=8u45"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=	
	set "FEAT_BINARY_URL_x64=http://download.oracle.com/otn-pub/java/jdk/8u45-b15/jdk-8u45-windows-x64.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=jdk-8u45-windows-x64.exe"
	set "FEAT_BINARY_URL_x86=http://download.oracle.com/otn-pub/java/jdk/8u45-b15/jdk-8u45-windows-i586.exe"
	set "FEAT_BINARY_URL_FILENAME_86=jdk-8u45-windows-i586.exe"

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\java"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	set "FEAT_ENV=feature_oraclesejdk_env"
	
	set FEAT_BUNDLE_LIST=
goto :eof


:feature_oracle-javasejdk_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	%WGET% --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "%FEAT_BINARY_URL%" -O "%STELLA_APP_CACHE_DIR%\%FEAT_BINARY_URL_FILENAME%"

	call %STELLA_COMMON%\common.bat :uncompress "%STELLA_APP_CACHE_DIR%\%FEAT_BINARY_URL_FILENAME%" "%STELLA_APP_TEMP_DIR%" "DEST_ERASE"
goto :eof


