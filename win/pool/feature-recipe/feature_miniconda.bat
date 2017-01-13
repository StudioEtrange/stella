@echo off
call %*
goto :eof


:feature_miniconda
	set "FEAT_NAME=miniconda"
	set "FEAT_LIST_SCHEMA=4_2_12_PYTHON3@x64:binary 4_2_12_PYTHON3@x86:binary 4_2_12_PYTHON2@x64:binary 4_2_12_PYTHON2@x86:binary"
	set "FEAT_DEFAULT_VERSION=4_2_12_PYTHON2"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof






:feature_miniconda_4_2_12_PYTHON3
	set "FEAT_VERSION=4_2_12_PYTHON3"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x64=https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Windows-x86_64.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=Miniconda3-4.2.12-Windows-x86_64.exe"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP"

	set "FEAT_BINARY_URL_x86=https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Windows-x86.exe"
	set "FEAT_BINARY_URL_FILENAME_x86=Miniconda3-4.2.12-Windows-x86.exe"
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\Scripts\conda.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!;!FEAT_INSTALL_ROOT!\Scripts"

goto :eof


:feature_miniconda_4_2_12_PYTHON2
	set "FEAT_VERSION=4_2_12_PYTHON2"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL_x64=https://repo.continuum.io/miniconda/Miniconda2-4.2.12-Windows-x86_64.exe"
	set "FEAT_BINARY_URL_FILENAME_x64=Miniconda2-4.2.12-Windows-x86_64.exe"
	set "FEAT_BINARY_URL_PROTOCOL_x64=HTTP"

	set "FEAT_BINARY_URL_x86=https://repo.continuum.io/miniconda/Miniconda2-4.2.12-Windows-x86.exe"
	set "FEAT_BINARY_URL_FILENAME_x86=Miniconda2-4.2.12-Windows-x86.exe"
	set "FEAT_BINARY_URL_PROTOCOL_x86=HTTP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\Scripts\conda.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!;!FEAT_INSTALL_ROOT!\Scripts"

goto :eof


:feature_miniconda_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
	if exist "!FEAT_INSTALL_ROOT!\!FEAT_BINARY_URL_FILENAME!" (
		start /wait "" "!FEAT_INSTALL_ROOT!\!FEAT_BINARY_URL_FILENAME!" /InstallationType=JustMe /RegisterPython=0 /NoRegistry=1 /AddToPath=0 /S /D=!FEAT_INSTALL_ROOT!
		del /q/f "!FEAT_INSTALL_ROOT!\!FEAT_BINARY_URL_FILENAME!"
	)
goto :eof
