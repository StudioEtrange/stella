@echo off
call %*
goto :eof



:feature_openssh
	set "FEAT_NAME=openssh"
	set "FEAT_LIST_SCHEMA=6_6@x64/binary 6_6@x86/binary 6_8@x64/binary 6_8@x86/binary"
	set "FEAT_DEFAULT_VERSION=6_8"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_openssh_6_6
	set "FEAT_VERSION=6_6"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL_x64=http://www.mls-software.com/files/installer_source_files.661p1-3.zip"
	set "FEAT_BINARY_URL_FILENAME_x64=installer_source_files.661p1-3.zip"
	set "FEAT_BINARY_URL_x86=http://www.mls-software.com/files/installer_source_files.661p1-3.zip"
	set "FEAT_BINARY_URL_FILENAME_x86=installer_source_files.661p1-3.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\ssh.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	set FEAT_ENV_CALLBACK=
	
	set FEAT_BUNDLE_ITEM=
goto :eof


:feature_openssh_6_8
	set "FEAT_VERSION=6_8"

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_CALLBACK=
	set "FEAT_BINARY_URL_x64=http://www.mls-software.com/files/installer_source_files.68p1-1.zip"
	set "FEAT_BINARY_URL_FILENAME_x64=installer_source_files.68p1-1.zip"
	set "FEAT_BINARY_URL_x86=http://www.mls-software.com/files/installer_source_files.68p1-1.zip"
	set "FEAT_BINARY_URL_FILENAME_x86=installer_source_files.68p1-1.zip"
	set FEAT_BINARY_CALLBACK=

	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\ssh.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"
	set FEAT_ENV_CALLBACK=
	
	set FEAT_BUNDLE_ITEM=
goto :eof



:feature_openssh_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
	mkdir "%INSTALL_DIR%\bin"
	if "!FEAT_ARCH!"=="x64" (
		xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin64\*.dll" "%INSTALL_DIR%\bin\"
		xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin64\ssh*.*" "%INSTALL_DIR%\bin\"
		xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin64\scp*.*" "%INSTALL_DIR%\bin\"
		xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin64\sftp*.*" "%INSTALL_DIR%\bin\"
		xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin64\*sum.*" "%INSTALL_DIR%\bin\"
		if exist "!FEAT_INSTALL_ROOT!\bin64\cyglsa" xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin64\cyglsa" "%INSTALL_DIR%\bin\"
	) else (
		xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin32\*.dll" "%INSTALL_DIR%\bin\"
		xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin32\ssh*.*" "%INSTALL_DIR%\bin\"
		xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin32\scp*.*" "%INSTALL_DIR%\bin\"
		xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin32\sftp*.*" "%INSTALL_DIR%\bin\"
		xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin32\*sum.*" "%INSTALL_DIR%\bin\"
		if exist "!FEAT_INSTALL_ROOT!\bin32\cyglsa" xcopy /q /y /e /i "!FEAT_INSTALL_ROOT!\bin32\cyglsa" "%INSTALL_DIR%\bin\"
	)	
goto :eof


