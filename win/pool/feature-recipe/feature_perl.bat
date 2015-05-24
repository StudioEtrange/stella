@echo off
call %*
goto :eof

:feature_perl
	set "FEAT_NAME=perl"
	set "FEAT_LIST_SCHEMA=5_18_2@x64/binary 5_18_2@x86/binary"
	set "FEAT_DEFAULT_VERSION=5_18_2"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_perl_5_18_2
	set "FEAT_VERSION=5_18_2"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL_x86=http://strawberryperl.com/download/5.18.2.1/strawberry-perl-5.18.2.1-32bit-portable.zip"
	set "FEAT_BINARY_URL_FILENAME_x86=strawberry-perl-5.18.2.1-32bit-portable.zip"
	set "FEAT_BINARY_URL_x64=http://strawberryperl.com/download/5.18.2.1/strawberry-perl-5.18.2.1-64bit-portable.zip"
	set "FEAT_BINARY_URL_FILENAME_x64=strawberry-perl-5.18.2.1-64bit-portable.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\perl\bin\perl.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\perl\bin;!FEAT_INSTALL_ROOT!\perl\site\bin;!FEAT_INSTALL_ROOT!\c\bin"
	set FEAT_ENV=

	set FEAT_BUNDLE_LIST=
goto :eof


:feature_perl_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	echo ** Installing strawberry perl portable edition version 
	
	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
goto :eof

