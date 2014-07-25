@echo off
call %*
goto :eof

:list_ruby
	set "%~1=2_0_0 1_9_3"
goto :eof

:install_ruby
	set "_VER=%~1"
	set "_DEFAULT_VER=2_0_0"

	REM if not exist %TOOL_ROOT%\ruby mkdir %TOOL_ROOT%\ruby
	if "%_VER%"=="" (
		call :install_ruby_%_DEFAULT_VER%
	) else (
		call :install_ruby_%_VER%
	)
goto :eof

:feature_ruby
	set "_VER=%~1"
	set "_DEFAULT_VER=2_0_0"

	if "%_VER%"=="" (
		call :feature_ruby_%_DEFAULT_VER%
	) else (
		call :feature_ruby_%_VER%
	)
goto :eof




:install_ruby_2_0_0
	call :install_rdevkit2_4_7_2

	:: Note: choose a directory name without spaces and non us-ascii characters
	if "%ARCH%"=="x86" (
		set URL=http://dl.bintray.com/oneclick/rubyinstaller/ruby-2.0.0-p451-i386-mingw32.7z
		set FILE_NAME=ruby-2.0.0-p451-i386-mingw32.7z
	)
	if "%ARCH%"=="x64" (
		set URL=http://dl.bintray.com/oneclick/rubyinstaller/ruby-2.0.0-p451-x64-mingw32.7z
		set FILE_NAME=ruby-2.0.0-p451-x64-mingw32.7z
	)
	set VERSION=2.0.0-p451
	set "INSTALL_DIR=%TOOL_ROOT%\ruby2"

	echo ** Installing ruby version %VERSION% in %INSTALL_DIR%

	call :feature_ruby_2_0_0
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%"
		
		call :feature_ruby_2_0_0
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!\bin"
			echo Ruby2 installed
			ruby --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_ruby_2_0_0
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%TOOL_ROOT%\ruby2\ruby-2.0.0-p451-mingw32\bin\ruby.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\ruby2\ruby-2.0.0-p451-mingw32"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : Ruby2 in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!\bin"
		set TERM=dumb
		set FEATURE_VER=2_0_0
	)
goto :eof


:install_rdevkit2_4_7_2
	:: Note: choose a directory name without spaces and non us-ascii characters
	if "%ARCH%"=="x86" (
		set URL=http://cdn.rubyinstaller.org/archives/devkits/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe
		set FILE_NAME=DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe
	)
	if "%ARCH%"=="x64" (
		set URL=http://cdn.rubyinstaller.org/archives/devkits/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe
		set FILE_NAME=DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe
	)
	set VERSION=4.7.2-20130224
	set INSTALL_DIR="%TOOL_ROOT%\ruby2\rubydevkit-4.7.2-20130224"

	echo ** Installing Ruby DevKit-mingw64-64-4 version %VERSION% in %INSTALL_DIR%

	call :feature_rdevkit2_4_7_2
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (

		call %STELLA_COMMON%\common.bat :download "%URL%" "%FILE_NAME%"
		cd /D %CACHE_DIR%

		%FILE_NAME% -y -o"%INSTALL_DIR%"

		call :feature_rdevkit2_4_7_2
		if not "!TEST_FEATURE!"=="0" (
			echo Ruby DevKit for Ruby2 installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_rdevkit2_4_7_2
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%TOOL_ROOT%\ruby2\rubydevkit-4.7.2-20130224\devkitvars.bat" (
		set "TEST_FEATURE=%TOOL_ROOT%\ruby2\rubydevkit-4.7.2-20130224"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : Ruby DevKit for Ruby2 in !TEST_FEATURE!
		)
		REM call %TOOL_ROOT%\rubydevkit-4.7.2-20130224\devkitvars.bat
		SET "RI_DEVKIT=!TEST_FEATURE!\"
		set "FEATURE_PATH=!TEST_FEATURE!\bin;!TEST_FEATURE!\mingw\bin"
		REM set "FEATURE_PATH=!TEST_FEATURE!\bin;!TEST_FEATURE!\mingw\bin"
		REM set "FEATURE_PATH=%FEATURE_PATH%;!TEST_FEATURE!\mingw\libexec\gcc\x86_64-w64-mingw32\4.7.2;!TEST_FEATURE!\mingw\x86_64-w64-mingw32\bin"
		REM set "FEATURE_PATH=%FEATURE_PATH%;!TEST_FEATURE!\mingw\libexec\gcc\i686-w64-mingw32\4.7.2;!TEST_FEATURE!\mingw\i686-w64-mingw32\bin"
		set FEATURE_VER=4_7_2
	)
goto :eof



:install_ruby_1_9_3
	call :install_rdevkit19_4_5_2

	REM Note: choose a directory name without spaces and non us-ascii characters
	set URL=http://dl.bintray.com/oneclick/rubyinstaller/ruby-1.9.3-p545-i386-mingw32.7z
	set FILE_NAME=ruby-1.9.3-p545-i386-mingw32.7z
	set VERSION=1.9.3-p545
	set INSTALL_DIR="%TOOL_ROOT%\ruby19"

	echo ** Installing ruby version %VERSION% in %INSTALL_DIR%

	call :feature_ruby_1_9_3
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%"
		
		call :feature_ruby_1_9_3
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!\bin"
			echo Ruby19 installed
			ruby --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_ruby_1_9_3
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%TOOL_ROOT%\ruby19\ruby-1.9.3-p545-i386-mingw32\bin\ruby.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\ruby19\ruby-1.9.3-p484-i386-mingw32"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : Ruby 1.9.3 in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!\bin"
		set TERM=dumb
		set FEATURE_VER=1_9_3
	)
goto :eof

:install_rdevkit19_4_5_2
	:: Note: choose a directory name without spaces and non us-ascii characters
	set URL=https://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe
	set FILE_NAME=DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe
	set VERSION=4.5.2-20111229-1559
	set INSTALL_DIR="%TOOL_ROOT%\ruby19\rubydevkit-4.5.2-20111229"

	echo ** Installing Ruby DevKit version %VERSION% in %INSTALL_DIR%

	call :feature_rdevkit19
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (

		call %STELLA_COMMON%\common.bat :download "%URL%" "%FILE_NAME%"
		cd /D %CACHE_DIR%

		DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe -y -o"%INSTALL_DIR%"

		call :feature_rdevkit19_4_5_2
		if not "!TEST_FEATURE!"=="0" (
			echo Ruby DevKit for Ruby19 installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_rdevkit19_4_5_2
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%TOOL_ROOT%\ruby19\rubydevkit-4.5.2-20111229\devkitvars.bat" (
		set "TEST_FEATURE=%TOOL_ROOT%\ruby19\rubydevkit-4.5.2-20111229"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : Ruby DevKit for Ruby19 in !TEST_FEATURE!
		)
		SET "RI_DEVKIT=!TEST_FEATURE!\"
		set "FEATURE_PATH=!TEST_FEATURE!\bin;!TEST_FEATURE!\mingw\bin"
		REM set "FEATURE_PATH=!TEST_FEATURE!\bin;!TEST_FEATURE!\mingw\bin;!TEST_FEATURE!\mingw\libexec\gcc\mingw32\4.5.2;!TEST_FEATURE!\mingw\mingw32\bin;!TEST_FEATURE!\sbin\awk"
		set FEATURE_VER=4_5_2
	)
goto :eof




