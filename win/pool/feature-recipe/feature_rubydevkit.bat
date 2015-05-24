@echo off
call %*
goto :eof



:feature_rubydevkit
	set "FEAT_NAME=rubydevkit"
	set "FEAT_LIST_SCHEMA=4_7_2@x64/binary 4_7_2@x86/binary 4_5_2@x86/binary"
	set "FEAT_DEFAULT_VERSION=4_7_2"
	set "FEAT_DEFAULT_ARCH=x86"
	set "FEAT_DEFAULT_FLAVOUR=binary"

	
goto :eof

:feature_rubydevkit_env
	set TERM=dumb
	SET "RI_DEVKIT=!FEAT_INSTALL_ROOT!\"
goto :eof

:feature_rubydevkit_4_7_2
	set "FEAT_VERSION=4_7_2"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL_x64=http://cdn.rubyinstaller.org/archives/devkits/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe"
	set "FEAT_BINARY_URL_x86=http://cdn.rubyinstaller.org/archives/devkits/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe"
	set "FEAT_BINARY_URL_FILENAME_x86=DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\devkitvars.bat"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin;!FEAT_INSTALL_ROOT!\mingw\bin"
	set FEAT_ENV=feature_rubydevkit_env

	set FEAT_BUNDLE_LIST=
goto :eof



:feature_rubydevkit_4_5_2
	set "FEAT_VERSION=4_5_2"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL_x86=https://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe"
	set "FEAT_BINARY_URL_FILENAME_x86=DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\devkitvars.bat"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin;!FEAT_INSTALL_ROOT!\mingw\bin"
	set FEAT_ENV=feature_rubydevkit_env

	set FEAT_BUNDLE_LIST=
goto :eof


:feature_rubydevkit_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%"

	cd /D %STELLA_APP_CACHE_DIR%

	%FEAT_BINARY_URL_FILENAME% -y -o"%INSTALL_DIR%"
		
goto :eof






