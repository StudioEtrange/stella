@echo off
call %*
goto :eof

REM Recipe for Oracle Java SE Development Kit
REM http://stackoverflow.com/questions/1619662/how-can-i-get-the-latest-jre-jdk-as-a-zip-file-rather-than-exe-or-msi-installe
REM http://stackoverflow.com/a/27028869

:feature_oracle-jdk
	set "FEAT_NAME=oracle-jdk"
	set "FEAT_LIST_SCHEMA=8u152@x64:binary 8u152@x86:binary 8u45@x86:binary 8u45@x64:binary 7u80@x86:binary 7u80@x64:binary"
	set "FEAT_DEFAULT_VERSION=8u152"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof

:feature_oraclesejdk_env
	set "JAVA_HOME=!FEAT_INSTALL_ROOT!"
goto :eof



:feature_oracle-jdk_8u152
	set "FEAT_VERSION=8u152"
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=
	set "FEAT_BINARY_URL_x64=http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jdk-8u152-windows-x64.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=jdk-8u152-windows-x64.exe"
	set FEAT_BINARY_URL_PROTOCOL_x64=
	set "FEAT_BINARY_URL_x86=http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jdk-8u152-windows-i586.exe"
	set "FEAT_BINARY_URL_FILENAME_86=jdk-8u152-windows-i586.exe"
	set FEAT_BINARY_URL_PROTOCOL_x86=

	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_CALLBACK=unzip_jdk_new"
	set "FEAT_ENV_CALLBACK=feature_oraclesejdk_env"

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\java.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	
goto :eof

:feature_oracle-jdk_8u45
	set "FEAT_VERSION=8u45"
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=
	set "FEAT_BINARY_URL_x64=http://download.oracle.com/otn/java/jdk/8u45-b15/jdk-8u45-windows-x64.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=jdk-8u45-windows-x64.exe"
	set FEAT_BINARY_URL_PROTOCOL_x64=
	set "FEAT_BINARY_URL_x86=http://download.oracle.com/otn/java/jdk/8u45-b15/jdk-8u45-windows-i586.exe"
	set "FEAT_BINARY_URL_FILENAME_86=jdk-8u45-windows-i586.exe"
	set FEAT_BINARY_URL_PROTOCOL_x86=

	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_CALLBACK=unzip_jdk_old"
	set "FEAT_ENV_CALLBACK=feature_oraclesejdk_env"

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\java.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	
goto :eof

:feature_oracle-jdk_7u80
	set "FEAT_VERSION=7u80"
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=
	
	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL_x64=http://download.oracle.com/otn/java/jdk/7u80-b15/jdk-7u80-windows-x64.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=jdk-7u80-windows-x64.exe"
	set FEAT_BINARY_URL_PROTOCOL_x64=
	set "FEAT_BINARY_URL_x86=http://download.oracle.com/otn/java/jdk/7u80-b15/jdk-7u80-windows-i586.exe"
	set "FEAT_BINARY_URL_FILENAME_86=jdk-7u80-windows-i586.exe"
	set FEAT_BINARY_URL_PROTOCOL_x86=

	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_CALLBACK=unzip_jdk_old"
	set "FEAT_ENV_CALLBACK=feature_oraclesejdk_env"

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\java.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"

goto :eof




:feature_oracle-jdk_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	if not exist "%STELLA_APP_CACHE_DIR%\%FEAT_BINARY_URL_FILENAME%" "%WGET%" --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "%FEAT_BINARY_URL%" -O "%STELLA_APP_CACHE_DIR%\%FEAT_BINARY_URL_FILENAME%"

	call %STELLA_COMMON%\common-feature :feature_callback

	cd /D !FEAT_INSTALL_ROOT!
	for /r %%f in (*) do call :unpack_jdk %%f

goto:eof



REM http://stackoverflow.com/a/27028869
REM https://techtavern.wordpress.com/2014/03/25/portable-java-8-sdk-on-windows/#comment-4854


REM Recipe for JDK 8 (update 93 and newer)
:unzip_jdk_new
	call %STELLA_COMMON%\common.bat :uncompress "%STELLA_APP_CACHE_DIR%\%FEAT_BINARY_URL_FILENAME%" "!FEAT_INSTALL_ROOT!_build" "DEST_ERASE"
	move "!FEAT_INSTALL_ROOT!_build\.rsrc\1033\JAVA_CAB10\111" "!FEAT_INSTALL_ROOT!_build\.rsrc\1033\JAVA_CAB10\111.7z"
	call %STELLA_COMMON%\common.bat :uncompress "!FEAT_INSTALL_ROOT!_build\.rsrc\1033\JAVA_CAB10\111.7z" "!FEAT_INSTALL_ROOT!" ""

	call %STELLA_COMMON%\common.bat :uncompress "!FEAT_INSTALL_ROOT!\tools.zip" "!FEAT_INSTALL_ROOT!" ""

	del /q "!FEAT_INSTALL_ROOT!\tools.zip"
	call %STELLA_COMMON%\common.bat :del_folder "!FEAT_INSTALL_ROOT!_build"
goto:eof

REM Recipe for JDK 8 (update 92 and older)
:unzip_jdk_old
	call %STELLA_COMMON%\common.bat :uncompress "%STELLA_APP_CACHE_DIR%\%FEAT_BINARY_URL_FILENAME%" "!FEAT_INSTALL_ROOT!" "DEST_ERASE"
	call %STELLA_COMMON%\common.bat :uncompress "!FEAT_INSTALL_ROOT!\tools.zip" "!FEAT_INSTALL_ROOT!" ""

	del /q "!FEAT_INSTALL_ROOT!\tools.zip"
goto:eof


:unpack_jdk
	if NOT "%~x1" == ".pack" goto :eof
	set _FOLDER=%~p1

	REM set PWD=%CD%
	pushd %_FOLDER%
	echo Unpacking %~nx1
	"!FEAT_INSTALL_ROOT!\bin\unpack200.exe" %~nx1 %~n1.jar
	popd
goto :eof


