@echo off
call %*
goto :eof
::--------------- MINIMAL DEFAULT FEATURES --------------------

:wget
	echo ** Install wget
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%STELLA_APP_FEATURE_ROOT%\wget"
	if not exist "%STELLA_APP_FEATURE_ROOT%\wget\bin\wget.exe" (
		"%UZIP%" -o "%STELLA_POOL%\feature\wget-1.11.4-1-bin.zip" -d "%STELLA_APP_FEATURE_ROOT%\wget"
		"%UZIP%" -o "%STELLA_POOL%\feature\wget-1.11.4-1-dep.zip" -d "%STELLA_APP_FEATURE_ROOT%\wget" 
	) else (
		echo ** Already installed
	)
goto :eof


:gnumake
	echo ** Install gnumake
	set VERSION=3.81
	set INSTALL_DIR="%STELLA_APP_FEATURE_ROOT%\make"
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
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%STELLA_APP_FEATURE_ROOT%\unzip"
	if not exist "%STELLA_APP_FEATURE_ROOT%\unzip\bin\unzip.exe" (
		call %STELLA_COMMON%\common.bat :copy_folder_content_into "%STELLA_POOL%\feature\unzip-5.51-1-bin" "%STELLA_APP_FEATURE_ROOT%\unzip\"
	) else (
		echo ** Already installed
	)
goto :eof

:sevenzip
	echo ** Install sevenzip
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%STELLA_APP_FEATURE_ROOT%\sevenzip"
	if not exist "%STELLA_APP_FEATURE_ROOT%\sevenzip\7z.exe" (
		call %STELLA_COMMON%\common.bat :copy_folder_content_into "%STELLA_POOL%\feature\sevenzip" "%STELLA_APP_FEATURE_ROOT%\sevenzip\"
	) else (
		echo ** Already installed
	)
goto :eof


:patch
	echo ** Install gnu patch
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%STELLA_APP_FEATURE_ROOT%\patch"
	if not exist "%STELLA_APP_FEATURE_ROOT%\patch\bin\patch.exe" (
		"%UZIP%" -o "%STELLA_POOL%\feature\patch-2.5.9-7-bin.zip" -d "%STELLA_APP_FEATURE_ROOT%\patch"
	) else (
		echo ** Already installed
	)
goto:eof


:: ------------------------ FEATURES MANAGEMENT-------------------------------
:init_all_features
	for %%F in (%__STELLA_FEATURE_LIST%) do (
		call :init_feature %%F
	)
	if not "%FEATURE_LIST_ENABLED%"=="" echo ** Features initialized : %FEATURE_LIST_ENABLED%
goto :eof

:: ARG2 return variable
:list_feature_version
	set "_FEATURE=%~1"
	set "_VAR=%~2"

	call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :list_%_FEATURE% %_VAR%
goto :eof


:: enable a feature 
:init_feature
	set "_FEATURE=%~1"
	set "_VER=%~2"

	set _flag=
	for %%A in (%FEATURE_LIST_ENABLED%) do (
		REM TODO what if _VER is null ?
		if "%%A"=="%_FEATURE%#%_VER%" set _flag=1
	)
	if "%_flag%"=="" (
		set FEATURE_PATH=
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :feature_%_FEATURE% %_VER%
		if not "!TEST_FEATURE!"=="0" (
			set "FEATURE_LIST_ENABLED=!FEATURE_LIST_ENABLED! %_FEATURE%#%_VER%"
			if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
		)
	)

goto :eof



:install_feature
	set "_FEATURE=%~1"
	set "_VER=%~2"

	set _flag=
	for %%A in (%FEATURE_LIST_ENABLED%) do (
		REM TODO what if _VER is null ?
		if "%%A"=="%_FEATURE%#%_VER%" set _flag=1
	)

	if "%_flag%"=="" (
		set FEATURE_PATH=
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :install_%_FEATURE% %_VER%
		if not "!TEST_FEATURE!"=="0" (
			set "FEATURE_LIST_ENABLED=!FEATURE_LIST_ENABLED! %_FEATURE%#!FEATURE_VER!"
			if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
		)
	)
goto :eof

:: reinit all feature previously enabled
:reinit_all_features
	for %%F in (%FEATURE_LIST_ENABLED%) do (
		set f=%%F
		set _VER=%f:*#=%
		set "_FEATURE=%f:#="^&REM #%
		set FEATURE_PATH=
		call %STELLA_FEATURE_RECIPE%\feature_%_FEATURE%.bat :feature_%_FEATURE% %_VER%
		if not "!TEST_FEATURE!"=="0" (
			if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
		)
	)
goto :eof



