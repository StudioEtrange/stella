@echo off
call %*
goto :eof

:list_ruby
	set "%~1=2_0_0_x64 2_0_0_x86 1_9_3"
goto :eof

:default_ruby
	set "%~1=2_0_0_x64"
goto :eof

:install_ruby
	set "_VER=%~1"	

	REM if not exist %STELLA_APP_FEATURE_ROOT%\ruby mkdir %STELLA_APP_FEATURE_ROOT%\ruby
	if "%_VER%"=="" (
		call :default_ruby "_DEFAULT_VER"
		call :install_ruby_!_DEFAULT_VER!
	) else (
		call :list_ruby "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :install_ruby_%_VER%
			)
		)
	)
goto :eof

:feature_ruby
	set "_VER=%~1"

	if "%_VER%"=="" (
		call :default_ruby "_DEFAULT_VER"
		call :feature_ruby_!_DEFAULT_VER!
	) else (
		call :list_ruby "_list_ver"
		for %%v in (!_list_ver!) do (
			if "%%v"=="%_VER%" (
				call :feature_ruby_%_VER%
			)
		)
	)
goto :eof

REM --------------------------------------------------------------
:install_ruby_2_0_0_x64
	set URL=http://dl.bintray.com/oneclick/rubyinstaller/ruby-2.0.0-p451-x64-mingw32.7z
	set FILE_NAME=ruby-2.0.0-p451-x64-mingw32.7z
	set VERSION=2_0_0_x64
	call :install_ruby_internal
	call :install_rubydevkit_4_7_2_x64
goto :eof

:install_ruby_2_0_0_x86
	set URL=http://dl.bintray.com/oneclick/rubyinstaller/ruby-2.0.0-p451-i386-mingw32.7z
	set FILE_NAME=ruby-2.0.0-p451-i386-mingw32.7z
	set VERSION=2_0_0_x86
	call :install_ruby_internal
	call :install_rubydevkit_4_7_2_x86
goto :eof

:install_ruby_1_9_3
	set URL=http://dl.bintray.com/oneclick/rubyinstaller/ruby-1.9.3-p545-i386-mingw32.7z
	set FILE_NAME=ruby-1.9.3-p545-i386-mingw32.7z
	set VERSION=1_9_3
	call :install_ruby_internal
	call :install_rubydevkit_4_5_2
goto :eof



:feature_ruby_2_0_0_x64
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\ruby\2_0_0_x64\ruby-2.0.0-p451-mingw32\bin\ruby.exe"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\ruby\2_0_0_x64\ruby-2.0.0-p451-mingw32"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!\bin"
	set "FEATURE_RESULT_VER=2_0_0_x64"
	call :feature_ruby_internal
goto :eof

:feature_ruby_2_0_0_x86
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\ruby\2_0_0_x86\ruby-2.0.0-p451-mingw32\bin\ruby.exe"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\ruby\2_0_0_x86\ruby-2.0.0-p451-mingw32"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!\bin"
	set "FEATURE_RESULT_VER=2_0_0_x86"
	call :feature_ruby_internal
goto :eof

:feature_ruby_1_9_3
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\ruby\1_9_3\ruby-1.9.3-p545-i386-mingw32\bin\ruby.exe"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\ruby\1_9_3\ruby-1.9.3-p545-i386-mingw32"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!\bin"
	set "FEATURE_RESULT_VER=1_9_3"
	call :feature_ruby_internal
goto :eof


:install_rubydevkit_4_7_2_x64
	set URL=http://cdn.rubyinstaller.org/archives/devkits/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe
	set FILE_NAME=DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe
	set VERSION=4_7_2_x64
	call :install_rubydevkit_internal
goto :eof

:install_rubydevkit_4_7_2_x86
	set URL=http://cdn.rubyinstaller.org/archives/devkits/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe
	set FILE_NAME=DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe
	set VERSION=4_7_2_x86
	call :install_rubydevkit_internal
goto :eof

:install_rubydevkit_4_5_2
	set URL=https://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe
	set FILE_NAME=DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe
	set VERSION=4_5_2
	call :install_rubydevkit_internal
goto :eof

:feature_rubydevkit_4_7_2_x64
	set "FEATURE_RESULT_VER=4_7_2_x64"
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\rubydevkit\!FEATURE_RESULT_VER!\devkitvars.bat"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\rubydevkit\!FEATURE_RESULT_VER!"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!\bin;!FEATURE_RESULT_ROOT!\mingw\bin"
	call :feature_rubydevkit_internal
goto :eof

:feature_rubydevkit_4_7_2_x86
	set "FEATURE_RESULT_VER=4_7_2_x86"
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\rubydevkit\!FEATURE_RESULT_VER!\devkitvars.bat"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\rubydevkit\!FEATURE_RESULT_VER!"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!\bin;!FEATURE_RESULT_ROOT!\mingw\bin"
	call :feature_rubydevkit_internal
goto :eof

:feature_rubydevkit_4_5_2
	set "FEATURE_RESULT_VER=4_5_2"
	set "FEATURE_TEST=%STELLA_APP_FEATURE_ROOT%\rubydevkit\!FEATURE_RESULT_VER!\devkitvars.bat"
	set "FEATURE_RESULT_ROOT=%STELLA_APP_FEATURE_ROOT%\rubydevkit\!FEATURE_RESULT_VER!"
	set "FEATURE_RESULT_PATH=!FEATURE_RESULT_ROOT!\bin;!FEATURE_RESULT_ROOT!\mingw\bin"
	call :feature_rubydevkit_internal
goto :eof

REM --------------------------------------------------------------
:install_ruby_internal
		:: Note: choose a directory name without spaces and non us-ascii characters
	set "INSTALL_DIR=%STELLA_APP_FEATURE_ROOT%\ruby\%VERSION%"

	echo ** Installing ruby version %VERSION% in %INSTALL_DIR%

	call :feature_ruby_!VERSION!
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%"
		
		call :feature_ruby_!VERSION!
		if "!TEST_FEATURE!"=="1" (
			echo Ruby installed
			!FEATURE_ROOT!\bin\ruby --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_ruby_internal
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	set FEATURE_ROOT=
	if exist "!FEATURE_TEST!" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=!FEATURE_RESULT_ROOT!"
		set "FEATURE_PATH=!FEATURE_RESULT_PATH!"
		set "FEATURE_VER=!FEATURE_RESULT_VER!"
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : Ruby in !FEATURE_ROOT!
		)
		set TERM=dumb
	)
goto :eof


REM --------------------------------------------------------------

:install_rubydevkit_internal
	:: Note: choose a directory name without spaces and non us-ascii characters
	set INSTALL_DIR="%STELLA_APP_FEATURE_ROOT%\rubydevkit\%VERSION%"

	echo ** Installing Ruby DevKit version %VERSION% in %INSTALL_DIR%

	call :feature_rubydevkit_!VERSION!
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (

		call %STELLA_COMMON%\common.bat :download "%URL%" "%FILE_NAME%"
		cd /D %STELLA_APP_CACHE_DIR%

		%FILE_NAME% -y -o"%INSTALL_DIR%"

		call :feature_rubydevkit_!VERSION!
		if "!TEST_FEATURE!"=="1" (
			echo Ruby DevKit for Ruby2 installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_rubydevkit_internal
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	set FEATURE_ROOT=
	if exist "!FEATURE_TEST!" (
		set "TEST_FEATURE=1"
		set "FEATURE_ROOT=!FEATURE_RESULT_ROOT!"
		set "FEATURE_PATH=!FEATURE_RESULT_PATH!"
		set "FEATURE_VER=!FEATURE_RESULT_VER!"
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : Ruby DevKit in !FEATURE_ROOT!
		)
		SET "RI_DEVKIT=!FEATURE_ROOT!\"
	)

goto :eof




