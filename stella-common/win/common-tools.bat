@echo off
call %*
goto :eof
::--------------- MINIMAL DEFAULT TOOLS --------------------

:wget
	echo ** Install wget
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%TOOL_ROOT%\wget"
	if not exist "%TOOL_ROOT%\wget\bin\wget.exe" (
		"%UZIP%" -o "%POOL_DIR%\tool\wget-1.11.4-1-bin.zip" -d "%TOOL_ROOT%\wget"
		"%UZIP%" -o "%POOL_DIR%\tool\wget-1.11.4-1-dep.zip" -d "%TOOL_ROOT%\wget" 
	) else (
		echo ** Already installed
	)
goto :eof


:gnumake
	echo ** Install gnumake
	set VERSION=3.81
	set INSTALL_DIR="%TOOL_ROOT%\make"
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	if not exist "%INSTALL_DIR%\bin\make.exe" (
		set URL=http://downloads.sourceforge.net/project/gnuwin32/make/3.81/make-3.81-bin.zip
		set FILE_NAME=make-3.81-bin.zip
		call %STELLA_COMMON%\common.bat :download_uncompress "!URL!" "!FILE_NAME!" "%INSTALL_DIR%"
		
		set URL=http://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-dep.zip
		set FILE_NAME=make-3.81-dep.zip
		call %STELLA_COMMON%\common.bat :download_uncompress "!URL!" "!FILE_NAME!" "%INSTALL_DIR%"
	) else (
		echo ** Already installed
	)
goto :eof

:unzip
	echo ** Install unzip
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%TOOL_ROOT%\unzip"
	if not exist "%TOOL_ROOT%\unzip\bin\unzip.exe" (
		call %STELLA_COMMON%\common.bat :copy_folder_content_into "%POOL_DIR%\tool\unzip-5.51-1-bin" "%TOOL_ROOT%\unzip\"
	) else (
		echo ** Already installed
	)
goto :eof

:sevenzip
	echo ** Install sevenzip
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%TOOL_ROOT%\sevenzip"
	if not exist "%TOOL_ROOT%\sevenzip\7z.exe" (
		call %STELLA_COMMON%\common.bat :copy_folder_content_into "%POOL_DIR%\tool\sevenzip" "%TOOL_ROOT%\sevenzip\"
	) else (
		echo ** Already installed
	)
goto :eof


:patch
	echo ** Install gnu patch
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%TOOL_ROOT%\patch"
	if not exist "%TOOL_ROOT%\patch\bin\patch.exe" (
		"%UZIP%" -o "%POOL_DIR%\tool\patch-2.5.9-7-bin.zip" -d "%TOOL_ROOT%\patch"
	) else (
		echo ** Already installed
	)
goto:eof


::---------------VARIOUS TOOLS --------------------
:openssh
	set URL=http://www.mls-software.com/files/installer_source_files.66p1-1-v1.zip
	set FILE_NAME=installer_source_files.66p1-1-v1.zip
	set VERSION=6.6p1-1-v1
	set INSTALL_DIR="%TOOL_ROOT%"

	echo ** Installing OpenSSH in %INSTALL_DIR%
	
	call :feature_openssh
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%\openssh"
	)
		if "!TEST_FEATURE!"=="0" (	
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%"
		
		call :feature_openssh
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo openssh installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_openssh
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\openssh\bin\ssh.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\openssh"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : OpenSSH in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!\bin"
	)
goto :eof

::---------------BUILD TOOLS --------------------

:ninja
	set URL=https://github.com/martine/ninja/archive/release.zip
	set VERSION="last release"
	set FILE_NAME=ninja-release.zip
	set "INSTALL_DIR=%TOOL_ROOT%\ninja-release"

	echo ** Installing ninja in %INSTALL_DIR%
	echo ** NEED PYTHON !!

	call %STELLA_COMMON%\common.bat :init_features python27

	call :feature_ninja
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		cd /D "%INSTALL_DIR%"
		python bootstrap.py

		call :feature_ninja
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo ** Ninja installed
			ninja --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_ninja
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\ninja-release\ninja.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\ninja-release"
	)

	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : ninja in !TEST_FEATURE!
		)
		set "NINJA_MAKE_CMD=!TEST_FEATURE!\%NINJA_MAKE_CMD%"
		set "NINJA_MAKE_CMD_VERBOSE=!TEST_FEATURE!\%NINJA_MAKE_CMD_VERBOSE%"
		set "NINJA_MAKE_CMD_VERBOSE_ULSSA=!TEST_FEATURE!\%NINJA_MAKE_CMD_VERBOSE_ULSSA%"
		set "FEATURE_PATH=!TEST_FEATURE!"
	)
goto :eof


:nasm
	set URL=http://www.nasm.us/pub/nasm/releasebuilds/2.11/win32/nasm-2.11-win32.zip
	set FILE_NAME=nasm-2.11-win32.zip
	set VERSION=2.11
	set INSTALL_DIR="%TOOL_ROOT%"
	
	echo ** Installing NASM version %VERSION% in %INSTALL_DIR%

	call :feature_nasm
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%\nasm-2.11"
	)
	if "!TEST_FEATURE!"=="0" (	
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%"
		
		call :feature_nasm
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo NASM installed
			nasm -version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_nasm
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\nasm-2.11\nasm.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\nasm-2.11"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : NASM in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!"
	)
goto :eof


:cmake
	set URL=http://www.cmake.org/files/v2.8/cmake-2.8.12-win32-x86.zip
	set VERSION=2.8.12
	set FILE_NAME=cmake-2.8.12-win32-x86.zip
	set "INSTALL_DIR=%TOOL_ROOT%\cmake-2.8.12-win32-x86"

	echo ** Installing cmake version %VERSION% in %INSTALL_DIR%

	call :feature_cmake
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
		call :feature_cmake
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!\bin"
			echo ** CMake installed
			cmake -version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_cmake
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\cmake-2.8.12-win32-x86\bin\cmake.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\cmake-2.8.12-win32-x86"
	)

	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : cmake in !TEST_FEATURE!
		)
		set "CMAKE_CMD=!TEST_FEATURE!\bin\%CMAKE_CMD%"
		set "CMAKE_CMD_VERBOSE=!TEST_FEATURE!\bin\%CMAKE_CMD_VERBOSE%"
		set "CMAKE_CMD_VERBOSE_ULSSA=!TEST_FEATURE!\bin\%CMAKE_CMD_VERBOSE_ULSSA%"
		set "FEATURE_PATH=!TEST_FEATURE!\bin"
	)
goto :eof





:jom
	set URL=http://download.qt-project.org/official_releases/jom/jom_1_0_13.zip
	set VERSION=1.0.13
	set FILE_NAME=jom_1_0_13.zip
	set "INSTALL_DIR=%TOOL_ROOT%\jom-1.0.13"

	echo ** Installing jom version %VERSION% in %INSTALL_DIR%

	call :feature_jom
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE"

		call :feature_jom
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo Jom installed
			jom -version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_jom
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\jom-1.0.13\jom.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\jom-1.0.13"
	)

	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : jom in !TEST_FEATURE!
		)
		set "JOM_MAKE_CMD=!TEST_FEATURE!\%JOM_MAKE_CMD%"
		set "JOM_MAKE_CMD_VERBOSE=!TEST_FEATURE!\%JOM_MAKE_CMD_VERBOSE%"
		set "JOM_MAKE_CMD_VERBOSE_ULSSA=!TEST_FEATURE!\%JOM_MAKE_CMD_VERBOSE_ULSSA%"
		set "FEATURE_PATH=!TEST_FEATURE!"
	)
goto :eof




::---------------VIRTUALIZATION TOOLS --------------------

:packer
	if "%ARCH%"=="x64" (
		set URL=https://dl.bintray.com/mitchellh/packer/0.6.0_windows_amd64.zip
		set FILE_NAME=0.6.0_windows_amd64.zip
	)
	if "%ARCH%"=="x86" (
		set URL=https://dl.bintray.com/mitchellh/packer/0.6.0_windows_386.zip
		set FILE_NAME=0.6.0_windows_386.zip
	)
	set VERSION=0.6.0
	set "INSTALL_DIR=%TOOL_ROOT%\packer-%VERSION%"

	echo ** Installing packer version %VERSION% in %INSTALL_DIR%
	call :feature_packer
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE"
		
		call :feature_packer
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo Packer installed
			packer --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_packer
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\packer-0.6.0\packer.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\packer-0.6.0"
	)

	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : packer in !TEST_FEATURE!
		)
		set "PACKER_CMD=!TEST_FEATURE!\%PACKER_CMD%"
		set "FEATURE_PATH=!TEST_FEATURE!"
	)
goto :eof



:vagrant_git
	set URL=https://github.com/mitchellh/vagrant.git
	set VERSION=git-master
	set "INSTALL_DIR=%TOOL_ROOT%\vagrant-%VERSION%"

	echo ** Installing vagrant version %VERSION% in %INSTALL_DIR%
	echo ** This version from git need RUBY 2.0 !!

	call :feature_vagrant_git
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		git clone https://github.com/mitchellh/vagrant.git "%INSTALL_DIR%"

		call %STELLA_COMMON%\common.bat :init_features "feature_ruby2 feature_rdevkit2"
		
		cd /D "%INSTALL_DIR%"
		bundle install
		
		call :feature_vagrant_git
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo Vagrant installed
			bundle exec vagrant -v
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_vagrant_git
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\vagrant-git-master\bin\vagrant" (
		set "TEST_FEATURE=%TOOL_ROOT%\vagrant-git-master"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : vagrant unstable from git in !TEST_FEATURE!
		)
		set "VAGRANT_CMD=call %STELLA_COMMON%\common-extra.bat :_call_vagrant_from_git"
		REM set "VAGRANT_CMD=set BUNDLE_GEMFILE!TEST_FEATURE!\Gemfile && bundle exec vagrant"
		REM set "VAGRANT_CMD=ruby -C!TEST_FEATURE! bin\%VAGRANT_CMD%"
		set "FEATURE_PATH=!TEST_FEATURE!"
	)
goto :eof

:_call_vagrant_from_git
	call :feature_vagrant_git
	set "BUNDLE_GEMFILE=!TEST_FEATURE!\Gemfile"
	call bundle exec vagrant %*
	set BUNDLE_GEMFILE=
goto :eof


::---------------LANGUAGE --------------------
:perl
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
	set "INSTALL_DIR=%TOOL_ROOT%\strawberry-perl-5.18.2.1"

	echo ** Installing strawberry perl portable edition version %VERSION% in %INSTALL_DIR%

	call :feature_perl
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE"
		
		call :feature_perl
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!\perl\bin"
			echo Perl installed
			perl --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_perl
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\strawberry-perl-5.18.2.1\perl\bin\perl.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\strawberry-perl-5.18.2.1"
	)

	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : perl in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!\perl\site\bin;!TEST_FEATURE!\perl\bin;!TEST_FEATURE!\c\bin"
		set TERM=dumb
	)
goto :eof

:python27
	if "%ARCH%"=="x86" (
		set URL=https://www.python.org/ftp/python/2.7.6/python-2.7.6.msi
		set FILE_NAME=python-2.7.6.msi
	)
	if "%ARCH%"=="x64" (
		set URL=https://www.python.org/ftp/python/2.7.6/python-2.7.6.amd64.msi
		set FILE_NAME=python-2.7.6.amd64.msi
	)

	set VERSION=2.7.6
	set "INSTALL_DIR=%TOOL_ROOT%\python2.7.6"

	echo ** Installing python version %VERSION% in %INSTALL_DIR%
	call :feature_python27
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download "%URL%" "%FILE_NAME%"
		cd /D %CACHE_DIR%

		msiexec /qb /i %FILE_NAME% TARGETDIR="%INSTALL_DIR%\"

		call :feature_python27
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo Python27 installed
			python.exe --version
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_python27
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\python2.7.6\python.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\python2.7.6"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : Python27 in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!"
	)
goto :eof

:ruby2
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
	set "INSTALL_DIR=%TOOL_ROOT%\ruby-2.0.0-p451-mingw32"

	echo ** Installing ruby version %VERSION% in %INSTALL_DIR%

	call :feature_ruby2
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
		call :feature_ruby2
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
:feature_ruby2
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\ruby-2.0.0-p451-mingw32\bin\ruby.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\ruby-2.0.0-p451-mingw32"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : Ruby2 in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!\bin"
		set TERM=dumb
	)
goto :eof


:rdevkit2
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
	set INSTALL_DIR="%TOOL_ROOT%\rubydevkit-4.7.2-20130224"

	echo ** Installing Ruby DevKit version %VERSION% in %INSTALL_DIR%

	call :feature_rdevkit2
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (

		call %STELLA_COMMON%\common.bat :download "%URL%" "%FILE_NAME%"
		cd /D %CACHE_DIR%

		%FILE_NAME% -y -o"%INSTALL_DIR%"

		call :feature_rdevkit2
		if not "!TEST_FEATURE!"=="0" (
			echo Ruby DevKit for Ruby2 installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_rdevkit2
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\rubydevkit-4.7.2-20130224\devkitvars.bat" (
		set "TEST_FEATURE=%TOOL_ROOT%\rubydevkit-4.7.2-20130224"
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
	)
goto :eof



:ruby19
	REM Note: choose a directory name without spaces and non us-ascii characters
	set URL=http://dl.bintray.com/oneclick/rubyinstaller/ruby-1.9.3-p545-i386-mingw32.7z
	set FILE_NAME=ruby-1.9.3-p545-i386-mingw32.7z
	set VERSION=1.9.3-p545
	set INSTALL_DIR="%TOOL_ROOT%"

	echo ** Installing ruby version %VERSION% in %INSTALL_DIR%

	call :feature_ruby19
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		call %STELLA_COMMON%\common.bat :download_uncompress "%URL%" "%FILE_NAME%" "%INSTALL_DIR%"
		
		call :feature_ruby19
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
:feature_ruby19
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\ruby-1.9.3-p545-i386-mingw32\bin\ruby.exe" (
		set "TEST_FEATURE=%TOOL_ROOT%\ruby-1.9.3-p484-i386-mingw32"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : Ruby19 in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!\bin"
		set TERM=dumb
	)
goto :eof


:rdevkit19
	:: Note: choose a directory name without spaces and non us-ascii characters
	set URL=https://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe
	set FILE_NAME=DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe
	set VERSION=4.5.2-20111229-1559
	set INSTALL_DIR="%TOOL_ROOT%\rubydevkit-4.5.2-20111229"

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

		call :feature_rdevkit19
		if not "!TEST_FEATURE!"=="0" (
			echo Ruby DevKit for Ruby19 installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof
:feature_rdevkit19
	set TEST_FEATURE=0
	if exist "%TOOL_ROOT%\rubydevkit-4.5.2-20111229\devkitvars.bat" (
		set "TEST_FEATURE=%TOOL_ROOT%\rubydevkit-4.5.2-20111229"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : Ruby DevKit for Ruby19 in !TEST_FEATURE!
		)
		SET "RI_DEVKIT=!TEST_FEATURE!\"
		set "FEATURE_PATH=!TEST_FEATURE!\bin;!TEST_FEATURE!\mingw\bin"
		REM set "FEATURE_PATH=!TEST_FEATURE!\bin;!TEST_FEATURE!\mingw\bin;!TEST_FEATURE!\mingw\libexec\gcc\mingw32\4.5.2;!TEST_FEATURE!\mingw\mingw32\bin;!TEST_FEATURE!\sbin\awk"
	)
goto :eof

