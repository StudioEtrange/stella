@echo off
call %*
goto :eof

REM TODO : desktop link with 'gitk.exe' which is a window app

:feature_git
	set "FEAT_NAME=git"
	set "FEAT_LIST_SCHEMA=1_9_5:binary"
	set "FEAT_DEFAULT_VERSION=1_9_5"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof

REM this is a portable version
REM recipe inspired from https://chocolatey.org/packages/git.commandline
REM real version is Git-1.9.5-preview20150319
:feature_git_1_9_5
	set "FEAT_VERSION=1_9_5"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=
	
	set "FEAT_BINARY_URL=https://github.com/msysgit/msysgit/releases/download/Git-1.9.5-preview20150319/PortableGit-1.9.5-preview20150319.7z"
	set FEAT_BINARY_URL_FILENAME=
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\cmd\git.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\cmd"
goto :eof



:feature_git_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP"	
goto :eof


