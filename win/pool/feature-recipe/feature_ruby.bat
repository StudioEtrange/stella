@echo off
call %*
goto :eof



:feature_ruby
	set "FEAT_NAME=ruby"
	set "FEAT_LIST_SCHEMA=2_0_0@x64/binary 2_0_0@x86/binary 1_9_3@x86/binary"
	set "FEAT_DEFAULT_VERSION=2_0_0"
	set "FEAT_DEFAULT_ARCH=x86"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof



:feature_ruby_env
	set TERM=dumb
goto :eof

:feature_ruby_2_0_0
	set "FEAT_VERSION=2_0_0"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL_x64=http://dl.bintray.com/oneclick/rubyinstaller/ruby-2.0.0-p451-x64-mingw32.7z"
	set "FEAT_BINARY_URL_FILENAME_x64=ruby-2.0.0-p451-x64-mingw32.7z"
	set "FEAT_BINARY_URL_x86=http://dl.bintray.com/oneclick/rubyinstaller/ruby-2.0.0-p451-i386-mingw32.7z"
	set "FEAT_BINARY_URL_FILENAME_x86=ruby-2.0.0-p451-i386-mingw32.7z"
	set FEAT_BINARY_CALLBACK=

	REM TODO dep install_rubydevkit_4_7_2_x64 _x86
	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_ROOT=!FEAT_INSTALL_ROOT!\ruby-2.0.0-p451-mingw32"
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\ruby.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	set FEAT_ENV=feature_ruby_env

	set FEAT_BUNDLE_LIST=
goto :eof


:feature_ruby_1_9_3
	set "FEAT_VERSION=1_9_3"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL_x86=http://dl.bintray.com/oneclick/rubyinstaller/ruby-1.9.3-p545-i386-mingw32.7z"
	set "FEAT_BINARY_URL_FILENAME_x86=ruby-1.9.3-p545-i386-mingw32.7z"
	set FEAT_BINARY_CALLBACK=

	REM TODO dep install_rubydevkit_4_5_2 _x86
	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_ROOT=!FEAT_INSTALL_ROOT!\ruby-1.9.3-p545-i386-mingw32"
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\ruby.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	set FEAT_ENV=feature_ruby_env

	set FEAT_BUNDLE_LIST=
goto :eof


:feature_ruby_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%"
		
goto :eof


