@echo off
call %*
goto :eof

REM To generate a ca-bundle.crt file containing root certificates, use mk-ca-bundle.vbs, and put the result in bin folder
	
REM TODO TO finish neeed openssl libssh (by default use WinSSL -- but its betteeer to use opeenssl)
:feature_curl
	set "FEAT_NAME=curl"
	set "FEAT_LIST_SCHEMA=7_45_0:source 7_45_0@x64:binary 7_45_0@x86:binary"
	set "FEAT_DEFAULT_VERSION=7_45_0"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_curl_7_45_0
	set "FEAT_VERSION=7_45_0"
	set "FEAT_SOURCE_DEPENDENCIES=zlib#1_2_8"
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=http://curl.haxx.se/download/curl-7.45.0.zip"
	set "FEAT_SOURCE_URL_FILENAME=curl-7.45.0.zip"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"
	
	set "FEAT_BINARY_URL_x64=https://bintray.com/artifact/download/vszakats/generic/curl-7.45.0-win64-mingw.7z"
	set "FEAT_BINARY_URL_FILENAME_x64=curl-7.45.0-win64-mingw.7z"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP"

	set "FEAT_BINARY_URL_x86=https://bintray.com/artifact/download/vszakats/generic/curl-7.45.0-win32-mingw.7z"
	set "FEAT_BINARY_URL_FILENAME_x86=curl-7.45.0-win32-mingw.7z"
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP"
	
	set "FEAT_SOURCE_CALLBACK=feature_curl_link"
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\libcurl.dll"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"	

goto :eof

:feature_curl_link
	call %STELLA_COMMON%\common-build.bat :link_feature_library "zlib#1_2_8" "FORCE_DYNAMIC"
goto :eof



:feature_curl_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "STRIP"
goto :eof





:feature_curl_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!STELLA_APP_FEATURE_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-src"
	
	call %STELLA_COMMON%\common-build.bat :set_toolset "MS"
	

	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!SRC_DIR!" "STRIP"	

	REM copy script to make certificats text file
	copy /Y "!SRC_DIR!\mk-ca-bundle.pl" "!INSTALL_DIR!\"
	copy /Y "!SRC_DIR!\mk-ca-bundle.vbs" "!INSTALL_DIR!\"

	call %STELLA_COMMON%\common-feature.bat :feature_callback

	REM build static lib
	set "AUTO_INSTALL_CONF_FLAG_POSTFIX=-DCURL_ZLIB=ON -DHTTP_ONLY=OFF -DCMAKE_USE_OPENSSL=ON -DCMAKE_USE_LIBSSH2=ON -DENABLE_IPV6=ON -DCURL_STATICLIB=ON -DBUILD_CURL_TESTS=OFF"
	set "AUTO_INSTALL_BUILD_FLAG_POSTFIX="
	call %STELLA_COMMON%\common-build.bat :auto_build "!FEAT_NAME!" "!SRC_DIR!" "!INSTALL_DIR!" "SOURCE_KEEP BUILD_KEEP"

	REM build dynamic lib
	set "AUTO_INSTALL_CONF_FLAG_POSTFIX=-DCURL_ZLIB=ON -DHTTP_ONLY=OFF -DCMAKE_USE_OPENSSL=ON -DCMAKE_USE_LIBSSH2=ON -DENABLE_IPV6=ON"
	set "AUTO_INSTALL_BUILD_FLAG_POSTFIX="
	REM -DBUILD_CURL_EXE=ON 
	call %STELLA_COMMON%\common-build.bat :auto_build "!FEAT_NAME!" "!SRC_DIR!" "!INSTALL_DIR!"


	echo ** To generate a ca-bundle.crt file containing root certificates, you should run !INSTALL_DIR!\mk-ca-bundle.vbs, and put the result in !INSTALL_DIR!\bin
	
goto :eof



