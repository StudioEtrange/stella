@echo off
call %*
goto :eof

:list_perl
	set "%~1=5_18_2"
goto :eof

:default_perl
	set "%~1=5_18_2"
goto :eof

:install_perl
	set "_VER=%~1"
	call :default_perl "_DEFAULT_VER"

	if not exist %STELLA_APP_FEATURE_ROOT%\perl mkdir %STELLA_APP_FEATURE_ROOT%\perl
	if "%_VER%"=="" (
		call :install_perl_!_DEFAULT_VER!
	) else (
		call :install_perl_%_VER%
	)
goto :eof

:feature_perl
	set "_VER=%~1"
	call :default_perl "_DEFAULT_VER"
	
	if "%_VER%"=="" (
		call :feature_perl_!_DEFAULT_VER!
	) else (
		call :feature_perl_%_VER%
	)
goto :eof



:install_perl_5_18_2
	:: Note: choose a directory name without spaces and non us-ascii characters
	if "%ARCH%"=="x64" (
		set URL=http://strawberryperl.com/download/5.18.2.1/strawberry-perl-5.18.2.1-64bit-portable.zip
		set FILE_NAME=strawberry-perl-5.18.2.1-64bit-portable.zip
	)
	if "%ARCH%"=="x86" (
		set URL=http://strawberryperl.com/download/5.18.2.1/strawberry-perl-5.18.2.1-32bit-portable.zip
		set FILE_NAME=strawberry-perl-5.18.2.1-32bit-portable.zip
	)
	set VERSION=5.18.2.1
	set "INSTALL_DIR=%STELLA_APP_FEATURE_ROOT%\perl\strawberry-perl-5.18.2.1"

	echo ** Installing strawberry perl portable edition version %VERSION% in %INSTALL_DIR%

	call :feature_perl_5_18_2
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE"
		
		call :feature_perl_5_18_2
		if not "!TEST_FEATURE!"=="0" (
			echo Perl installed
			!FEATURE_ROOT!\perl\bin\perl --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_perl_5_18_2
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	set FEATURE_ROOT=
	if exist "%STELLA_APP_FEATURE_ROOT%\perl\strawberry-perl-5.18.2.1\perl\bin\perl.exe" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=%STELLA_APP_FEATURE_ROOT%\perl\strawberry-perl-5.18.2.1"
		set "FEATURE_PATH=!FEATURE_ROOT!\perl\bin;!FEATURE_ROOT!\perl\site\bin;!FEATURE_ROOT!\c\bin"
		set FEATURE_VER=5_18_2
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : perl in !FEATURE_ROOT!
		)
		set TERM=dumb
	)
goto :eof
