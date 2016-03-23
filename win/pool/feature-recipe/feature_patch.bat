@echo off
call %*
goto :eof

REM NOTE patch from gnuwin32 project has a bug on windows with UAC
REM http://butnottoohard.blogspot.fr/2010/01/windows-7-chronicles-gnu-patch-mtexe.html
REM http://math.nist.gov/oommf/software-patchsets/patch_on_Windows7.html

:feature_patch
	set "FEAT_NAME=patch"
	set "FEAT_LIST_SCHEMA=2_5_9_INTERNAL:binary"
	set "FEAT_DEFAULT_VERSION=2_5_9_INTERNAL"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_patch_2_5_9_INTERNAL
	set "FEAT_VERSION=2_5_9_INTERNAL"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=%STELLA_ARTEFACT%\patch-2_5_9-7-with-manifest.zip"
	set "FEAT_BINARY_URL_FILENAME=patch-2_5_9-7-with-manifest.zip"
	set "FEAT_BINARY_URL_PROTOCOL=FILE_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\patch.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"



goto :eof


:feature_patch_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"	
goto :eof




