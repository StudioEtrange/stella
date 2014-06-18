@echo off
call %*
goto :eof
::--------------------------------------------------------
::-- Functions
::--------------------------------------------------------

:: COMMON COMMAND LINE ARG PARSE
:init_arg

	:: VERBOSE
	if "%-vv%"=="" if "%-v%"=="" set /a "VERBOSE_MODE = %DEFAULT_VERBOSE_MODE%"
	if "%-vv%"=="1" ( 
		set /a "VERBOSE_MODE = 2"
	) else if "%-v%"=="1" (
		set /a "VERBOSE_MODE = 1"
	)

goto :eof


:init_env
	call :init_arg
	call :init_all_features
goto :eof


:: ------------------------ FEATURES MANAGEMENT-------------------------------
:init_all_features
	call :init_features feature_openssh
	call :init_features feature_python27
	call :init_features feature_ninja
	call :init_features feature_jom
	call :init_features feature_cmake
	call :init_features feature_perl
	call :init_features feature_ruby2
	::rubydevkit have binaries which override other features like perl
	::call :init_features feature_rdevkit2
	call :init_features feature_packer
	REM call :init_features feature_vagrant_git
	call :init_features feature_nasm
goto :eof


:: enable a list of feature 
:: call :init_features feat1 feat2
:init_features
	set "_FEATURE_LIST=%~1"

	for %%F in (%_FEATURE_LIST%) do (
		set _flag=
		for %%A in (%FEATURE_LIST_ENABLED%) do (
			if "%%A"=="%%F" set _flag=1
		)
		if "%_flag%"=="" (
			set FEATURE_PATH=
			call %STELLA_COMMON%\common-extra.bat :%%F
			if not "!TEST_FEATURE!"=="0" (
				set "FEATURE_LIST_ENABLED=!FEATURE_LIST_ENABLED! %%F"
				if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
			)
		)
	)
goto :eof

:: reinit all feature previously enabled
:reinit_all_features
	for %%F in (%FEATURE_LIST_ENABLED%) do (
		set FEATURE_PATH=
		call %STELLA_COMMON%\common-extra.bat :%%F
		if not "!TEST_FEATURE!"=="0" (
			if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
		)
	)
goto :eof


:useqt
	if "%~1"=="4" (
		if "%~2"=="x64" (
			if "%QT4_X64%"=="" set "QT4_X64=%QT_ROOT%\qt4_x64"
			set "QTDIR=!QT4_X64!"
			set "PATH=!QTDIR!\bin;%PATH%"
			echo ** Setting Qt%~1% dir !QTDIR! and setting system path
		)
		if "%~2"=="x86" (
			if "%QT4_X86%"=="" set "QT4_X64=%QT_ROOT%\qt4_x86"
			set "QTDIR=!QT4_X86!"
			set "PATH=!QTDIR!\bin;%PATH%"
			echo ** Setting Qt%~1% dir !QTDIR! and setting system path
		)
	)
	if "%~1"=="5" (
		if "%~2"=="x64" (
			if "%QT5_X64%"=="" set "QT5_X64=%QT_ROOT%\qt5_x64"
			set "QTDIR=!QT5_X64!"
			set "PATH=!QTDIR!\qtbase\bin;%PATH%"
			echo ** Setting Qt%~1% dir !QTDIR! and setting system path
		)
		if "%~2"=="x86" (
			if "%QT5_X86%"=="" set "QT5_X86=%QT_ROOT%\qt5_x86"
			set "QTDIR=!QT5_X86!"
			set "PATH=!QTDIR!\qtbase\bin;%PATH%"
			echo ** Setting Qt%~1% dir !QTDIR! and setting system path
		)
	)
goto :eof

:set_verbose_mode
	if "%~1"=="1" (
		set "MAKE_CMD=%MAKE_CMD_VERBOSE%"
		set "CMAKE_CMD=%CMAKE_CMD_VERBOSE%"
	)

	if "%~1"=="2" (
		set "MAKE_CMD=%MAKE_CMD_VERBOSE_ULTRA%"
		set "CMAKE_CMD=%CMAKE_CMD_VERBOSE_ULTRA%"
	)
goto :eof




:: FILES TOOL ---------------------------------------
:del_folder
	if exist %~1 (
		echo ** Deleting %~1 folder
		call :timecount_start timecount_id
		del /f/s/q %~1 >nul
		rmdir /s/q %~1 >nul
		call :timecount_stop !timecount_id!
		echo ** Folder deleted in !RCS_TIMECOUNT_ELAPSED!

		REM takeown /f %~1 /r /d y >nul
		REM icacls %~1 /reset /t >nul
		REM icacls %~1 /setowner "%username%" /t >nul
	)
goto :eof	

:: copy content of folder ARG1 into folder ARG2 (with an optional filter ARG3)
:copy_folder_content_into
	set "_filter=%~3"
	if not exist %~2 mkdir %~2
	if "%_filter%"=="" (
		xcopy /q /y /e /i "%~1" "%~2"
	) else (
		xcopy /q /y /e /i "%~1\%_filter%" "%~2\"
	)
goto :eof

:: MEASURE TOOL------------
:timecount_start
	set %~1=%RANDOM%%RANDOM%
	set "_rcs_timecount_start_!%~1!=%time%"
goto :eof

:timecount_stop
	set _end_time=%time%
	set _start_time=!_rcs_timecount_start_%~1!

	:: TODO the separator change depending of the local language. it is not always : and .
	set _options="tokens=1-4 delims=:,."
	for /f %_options% %%a in ("%_start_time%") do set start_h=%%a&set /a start_m=100%%b %% 100&set /a start_s=100%%c %% 100&set /a start_ms=100%%d %% 100
	for /f %_options% %%a in ("%_end_time%") do set end_h=%%a&set /a end_m=100%%b %% 100&set /a end_s=100%%c %% 100&set /a end_ms=100%%d %% 100

	set /a _hours=%end_h%-%start_h%
	set /a _mins=%end_m%-%start_m%
	set /a _secs=%end_s%-%start_s%
	set /a _ms=%end_ms%-%start_ms%

	if %_hours% lss 0 set /a _hours = 24%_hours%
	if %_mins% lss 0 set /a _hours = %_hours% - 1 & set /a _mins = 60%_mins%
	if %_secs% lss 0 set /a _mins = %_mins% - 1 & set /a _secs = 60%_secs%
	if %_ms% lss 0 set /a _secs = %_secs% - 1 & set /a _ms = 100%_ms%
	if 1%_ms% lss 100 set _ms=0%_ms%

	set /a _totalsecs = %_hours%*3600 + %_mins%*60 + %_secs% 
	set "RCS_TIMECOUNT_ELAPSED=%_hours%:%_mins%:%_secs%.%_ms% -- total : %_totalsecs%.%_ms%s"
goto :eof

:: PROCESSUS TOOL--------------
:fork
	set _TITLE=%APP_NAME_FULL% -- %~1
	REM folder in will the terminal will stay after command is over
	set _FOLDER=%~2
	set _COMMAND=%~3
	REM the launcher script will wait until the forked terminal is finished
	set _WAIT=%~4
	REM will compute in the same terminal
	set _SAME_WINDOW=%~5
	REM terminal will not close at the end
	set _DETACH=%~6

	echo ** Forking: %~3
	if "%_DETACH%"=="TRUE" (
		set "_DETACH=/K"
	) else (
		set "_DETACH=/C"
	)

	if "%_WAIT%"=="TRUE" ( 
		set "_WAIT=/wait"
	) else (
		set _WAIT=
	)
		
	if "%_SAME_WINDOW%"=="TRUE" (
		set "_SAME_WINDOW=/b"
	) else (
		set _SAME_WINDOW=
	)

	if "%_WAIT%"=="TRUE" (
		call %STELLA_COMMON%\common.bat :timecount_start timecount_id
	)
	
	start "%_TITLE%" %_WAIT% %_SAME_WINDOW% /D%_FOLDER% cmd %_DETACH% %_COMMAND%

	if "%_WAIT%"=="TRUE" (
		call %STELLA_COMMON%\common.bat :timecount_stop !timecount_id!
		echo ** Fork terminated in !RCS_TIMECOUNT_ELAPSED!
	)
goto :eof

:: set a new command line with RCS var initialized
:bootstrap_env
	set _TITLE=%APP_NAME_FULL% -- %~1
	:: folder in wich the new bootstraped env will remain
	set _FOLDER=%~2

	call :fork "%_TITLE%" "%_FOLDER%" "%STELLA_COMMON%\bootstrap-rcs-env.bat -internalcall" "FALSE" "FALSE" "TRUE"
	echo ** A new env %_TITLE% is bootstrapped with all RCS default variable setted
goto :eof


:: DOWNLOAD AND ZIP TOOLS-----------------------------------------------------
:get_ressource
	set "NAME=%~1"
	set "URI=%~2"
	set "PROTOCOL=%~3"
	set "FINAL_DESTINATION=%~4"
	REM DO NOT USE * in NAME
	REM option should passed as one string "OPT1 OPT2"
	REM 	"MERGE" for merge in FINAL_DESTINATION
	REM 	"STRIP" for remove root folder and copy content of root folder in FINAL_DESTINATION
	SET "OPT=%~5"

	set "_name_legal=%NAME::=%"
	set "_name_legal=%NAME:\=%"
	set "_name_legal=%NAME:/=%"
	set "_name_legal=%NAME:!=%"
	set "_name_legal=%NAME:<=%"
	set "_name_legal=%NAME:>=%"
	set "_name_legal=%NAME:?=%"
	set "_name_legal=%NAME: =_%"

	set _opt_merge=OFF
	set _opt_strip=OFF
	for %%O in (%OPT%) do (
		if "%%O"=="MERGE" set _opt_merge=ON
		if "%%O"=="STRIP" set _opt_strip=ON
	)
	
	echo ** Getting ressource : %NAME% into %FINAL_DESTINATION%

	if "%FORCE%"=="1" (
		call :del_folder "%FINAL_DESTINATION%"
	)


	:: check if ressource already grabbed or merged
	set _FLAG=1
	if "%_opt_merge%"=="ON" (
		if exist "%FINAL_DESTINATION%\._MERGED_!_name_legal!" ( 
			set _FLAG=0
			echo ** Ressource already merged
		)
	) else (
		if exist "%FINAL_DESTINATION%" (
			set _FLAG=0
			echo ** Ressource already grabbed
		)
	)
	
	:: strip root folder mode
	set "_STRIP=FALSE"
	if "%_opt_strip%"=="ON" set "_STRIP=TRUE"

	if "%_FLAG%"=="1" (
		if not exist "%FINAL_DESTINATION%" mkdir %FINAL_DESTINATION%

		if "%PROTOCOL%"=="HTTP_ZIP" (
			echo MERGE : %_opt_merge%
			echo STRIP : %_opt_strip%
			call :download_uncompress "%URI%" "_AUTO_" "%FINAL_DESTINATION%" "FALSE" "%_STRIP%"
			if "%_opt_merge%"=="ON" echo 1 > "%FINAL_DESTINATION%\._MERGED_!_name_legal!"
		)
		if "%PROTOCOL%"=="HTTP" (
			echo MERGE : %_opt_merge%
			:: HTTP protocol use always merge by default : because it never erase destination folder
			:: the flag file will be setted only if we pass the option MERGE
			call :download "%URI%" "_AUTO_" "%FINAL_DESTINATION%"
			if "%_opt_merge%"=="ON" echo 1 > "%FINAL_DESTINATION%\._MERGED_!_name_legal!"
		)
		if "%PROTOCOL%"=="HG" (
			echo MERGE : %_opt_merge%
			if "%_opt_strip%"=="ON" echo STRIP Not supported with HG protocol
			hg clone %URI% "%FINAL_DESTINATION%"
			if "%_opt_merge%"=="ON" echo 1 > "%FINAL_DESTINATION%\._MERGED_!_name_legal!"
		)
		if "%PROTOCOL%"=="GIT" (
			echo MERGE : %_opt_merge%
			if "%_opt_strip%"=="ON" echo STRIP Not supported with GIT protocol
			git clone %URI% "%FINAL_DESTINATION%"
			if "%_opt_merge%"=="ON" echo 1 > "%FINAL_DESTINATION%\._MERGED_!_name_legal!"
		)
		if "%PROTOCOL%"=="FILE" (
			echo MERGE : %_opt_merge%
			if "%_opt_strip%"=="ON" echo STRIP Not supported with FILE protocol
			call :copy_folder_content_into "%URI%" "%FINAL_DESTINATION%"
			if "%_opt_merge%"=="ON" echo 1 > "%FINAL_DESTINATION%\._MERGED_!_name_legal!"
		)
		if "%PROTOCOL%"=="FILE_ZIP" (
			echo MERGE : %_opt_merge%
			echo STRIP : %_opt_strip%
			call :uncompress "%URI%" "%FINAL_DESTINATION%" "FALSE" "%_STRIP%"
			if "%_opt_merge%"=="ON" echo 1 > "%FINAL_DESTINATION%\._MERGED_!_name_legal!"
		)
	)
goto :eof

:download_uncompress
	set URL=%~1
	set FILE_NAME=%~2
	set UNZIP_DIR=%~3
	:: delete destination folder (default : FALSE)
	set DEST_ERASE=%~4
	:: delete first level folders in archive (aka STRIP) (default : FALSE)
	set STRIP=%~5

	if not "%DEST_ERASE%"=="TRUE" set DEST_ERASE=FALSE
	if not "%STRIP%"=="TRUE" set STRIP=FALSE
	
	if "%URL%"=="" (
		echo ** ERROR missing URL
		goto :eof
	)
	if "%FILE_NAME%"=="" (
		echo ** ERROR missing filename
		goto :eof
	)

	if "%FILE_NAME%"=="_AUTO_" (
		for %%A in ( %URL% ) do set FILE_NAME=%%~nxA
		echo ** Guessed file name is %FILE_NAME%
	)

	call :download "%URL%" "%FILE_NAME%"

	call :uncompress "%CACHE_DIR%\%FILE_NAME%" "%UNZIP_DIR%" "%DEST_ERASE%" "%STRIP%" 
goto :eof

:uncompress
	set FILE_PATH=%~1
	set UNZIP_DIR=%~2
	:: delete destination folder (default : FALSE)
	set DEST_ERASE=%~3
	:: delete first level folders in archive (aka STRIP) (default : FALSE)
	set STRIP=%~4
	
	if not "%DEST_ERASE%"=="TRUE" set DEST_ERASE=FALSE
	if not "%STRIP%"=="TRUE" set STRIP=FALSE
	
	if "%DEST_ERASE%"=="TRUE" if exist "%UNZIP_DIR%" call :del_folder "%UNZIP_DIR%"
	if not exist "%UNZIP_DIR%" mkdir "%UNZIP_DIR%"

	echo ** Uncompress %FILE_PATH% in %UNZIP_DIR%

	for %%A in ( %FILE_PATH% ) do set _FILENAME=%%~nxA
	for %%B in ( %FILE_PATH% ) do set EXTENSION=%%~xB
	if "%EXTENSION%"==".7z" (
		echo ** Using 7zip : %U7ZIP%
		set "USE7ZIP=TRUE"
	) else (
		echo ** Using unzip : %UZIP%
		set "USE7ZIP=FALSE"
	)

	if "%STRIP%"=="FALSE" (
		if "%USE7ZIP%"=="FALSE" "%UZIP%" -o "%FILE_PATH%" -d "%UNZIP_DIR%"
		if "%USE7ZIP%"=="TRUE" "%U7ZIP%" x "%FILE_PATH%" -y -o"%UNZIP_DIR%"
	) else (
		echo ** Stripping first folder
		if exist "%TEMP_DIR%\%_FILENAME%" (
			rmdir /q /s "%TEMP_DIR%\%_FILENAME%"
		)
		mkdir "%TEMP_DIR%\%_FILENAME%"
		if "%USE7ZIP%"=="FALSE" "%UZIP%" -o "%FILE_PATH%" -d "%TEMP_DIR%\%_FILENAME%"
		if "%USE7ZIP%"=="TRUE" "%U7ZIP%" x "%FILE_PATH%" -y -o"%TEMP_DIR%\%_FILENAME%"
		
		cd /D "%TEMP_DIR%\%_FILENAME%"
		for /D %%i in (*) do (
			::for /D %%i in (*) do xcopy /q /y /e /i %%i "%UNZIP_DIR%"
			cd %%i			
			for /D %%j in (*) do move /y %%j "%UNZIP_DIR%\"
			for %%j in (*) do move /y %%j "%UNZIP_DIR%\"
		)
		cd /D "%PROJECT_ROOT%"
		if exist "%TEMP_DIR%\%_FILENAME%" rmdir /q /s "%TEMP_DIR%\%_FILENAME%"
	)
goto :eof

:download
	set URL=%~1
	set FILE_NAME=%~2
	set DEST_DIR=%~3
	set "DL_DIR=%CACHE_DIR%"

	if "%URL%"=="" (
		echo ** ERROR missing URL
		goto :eof
	)
	if "%FILE_NAME%"=="" (
		set FILE_NAME=_AUTO_
	)

	if "%FILE_NAME%"=="_AUTO_" (
		for %%A in ( %URL% ) do set FILE_NAME=%%~nxA
		echo ** Guessed file name is %FILE_NAME%
	)

	if not exist "%DL_DIR%" (
		mkdir "%DL_DIR%"
	)

	echo ** Download %FILE_NAME% from %URL% into cache
	
	REM if "%FORCE%"=="1" (
	REM	del /q /s "%DL_DIR%\%FILE_NAME%"
	REM )

	if not exist "%DL_DIR%\%FILE_NAME%" (
		"%WGET%" "%URL%" -O "%DL_DIR%\%FILE_NAME%" --no-check-certificate
	) else (
		echo ** Already downloaded
	)

	if not "%DEST_DIR%"=="" (
		if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"
		copy /y "%DL_DIR%\%FILE_NAME%" "%DEST_DIR%\"
		echo ** %FILE_NAME% is in %DEST_DIR%
	)

goto :eof

REM INI FILE MANAGEMENT---------------------------------------------------
:add_key
	set "_FILE=%~1"
	set "_SECTION=%~2"
	set "_KEY=%~3"
	set "_VAL=%~4"
	
	if not exist "%_FILE%" > "%_FILE%" echo(
	if "%_SECTION%"=="" (
		>nul call %STELLA_COMMON%\ini.bat /i "%_KEY%" /v "%_VAL%" "%_FILE%"
	) else (
		>nul call %STELLA_COMMON%\ini.bat /i "%_KEY%" /v "%_VAL%" /s "%_SECTION%" "%_FILE%"
	)
goto :eof

:get_key
	set "_FILE=%~1"
	set "_SECTION=%~2"
	set "_KEY=%~3"
	set "_OPT=%~4"

	set _opt_section_prefix=OFF
	for %%O in (%OPT%) do (
		if "%%O"=="PREFIX" set _opt_section_prefix=ON
	)


	if "%_opt_section_prefix%"=="ON" (
		for /f "delims=" %%I in ('call %STELLA_COMMON%\ini.bat /i "%_KEY%" /s "%_SECTION%" "%_FILE%"') do set "%_SECTION%_%_KEY%=%%I"
	) else (
		for /f "delims=" %%I in ('call %STELLA_COMMON%\ini.bat /i "%_KEY%" /s "%_SECTION%" "%_FILE%"') do set "%_KEY%=%%I"
	)
goto :eof


:del_key
	set "_FILE=%~1"
	set "_SECTION=%~2"
	set "_KEY=%~3"

	if "%_SECTION%"=="" (
		>nul call %STELLA_COMMON%\ini.bat /d "%_KEY%" "%_FILE%"
	) else (
		>nul call %STELLA_COMMON%\ini.bat /d "%_KEY%" /s "%_SECTION%" "%_FILE%"
	)
goto :eof


REM FLAG MANAGEMENT---------------------------------------------------
:add_flag
	REM do not refactor this code with parenthesis or try to remove loop : PB with ) and with "
	set "FLAG_FILE=%~1"
	set "FLAG_NAME=%~2"
	shift
	shift
	set "FLAG_VALUE=%~1"
	:_loop
		shift
		if "%~1" neq "" set "FLAG_VALUE=!FLAG_VALUE! %~1"
		if "%~1" neq "" goto :_loop
	REM do not refactor this code with parenthesis
	if exist "%FLAG_FILE%" call :del_flag "%FLAG_FILE%" "%FLAG_NAME%"
	if exist "%FLAG_FILE%" >> %FLAG_FILE% echo(%FLAG_NAME%=%FLAG_VALUE%
	if not exist "%FLAG_FILE%" > %FLAG_FILE% echo(%FLAG_NAME%=%FLAG_VALUE%
goto :eof

:del_flag
	set "FLAG_FILE=%~1"
	set "FLAG_NAME=%~2"
	set "FLAGS_FILE_TEMP=%FLAG_FILE%.temp"
	
	if exist "%FLAG_FILE%.temp" del /f /q /s "%FLAG_FILE%".temp >nul

	if exist "%FLAG_FILE%" (
		for /f "tokens=1,2 delims==" %%K in ( %FLAG_FILE% ) do (
			if "%%K"=="" (
				>> %FLAGS_FILE_TEMP% echo(%%K
			) else (
	   			if not "%%K"=="%FLAG_NAME%" >> %FLAGS_FILE_TEMP% echo(%%K=%%L
	   		)
		)
	   	for %%Z in ( %FLAG_FILE% ) do set _filename=%%~nxZ
		if exist "%FLAG_FILE%" del /f /q /s "%FLAG_FILE%" >nul
		rename "%FLAGS_FILE_TEMP%" "!_filename!"
	)
goto :eof

:get_flag
	set "FLAG_FILE=%~1"
	set "FLAG_NAME=%~2"

	if exist "%FLAG_FILE%" (
		FOR /F "tokens=1,2 delims==" %%K IN (%FLAG_FILE%) do (
	   		if "%%K"=="%FLAG_NAME%" (
	   			set "%%K=%%L"
	   		)
	   	)
	)
goto :eof

:reset_all_flag
	set "FLAG_FILE=%~1"
	del /q /s /f "%FLAG_FILE%" >nul
goto :eof


:: VARIOUS ---------------------------------------
:: check if file.lib is an import lib or a static lib
:: by setting 
::		LIB_TYPE with UNKNOW, STATIC, IMPORT
:: first argument is the file to test
:is_import_or_static_lib
	set LIB_TYPE=UNKNOW
	set _nb_dll=0
	set _nb_obj=0
	for /f %%i in ('lib /list %~1 ^| findstr /N ".dll$" ^| find /c ":"') do set _nb_dll=%%i
	for /f %%j in ('lib /list %~1 ^| findstr /N ".obj$" ^| find /c ":"') do set _nb_obj=%%j
	for /f %%j in ('lib /list %~1 ^| findstr /N ".o$" ^| find /c ":"') do set /a _nb_obj=%%j+!_nb_obj!
	if %_nb_dll% EQU 0 if %_nb_obj% GTR 0 (
		set LIB_TYPE=STATIC
	)
	if %_nb_obj% EQU 0 if %_nb_dll% GTR 0 (
		set LIB_TYPE=IMPORT
	)
goto :eof

:run_admin
	set _cmd=%*
	set _cmd=%_cmd:"=%
	echo ** ADMIN : Try to get admin privileges
	if %VERBOSE_MODE% GTR 0 echo ** ADMIN EXECUTE : !_cmd!
	call %STELLA_COMMON%\run-admin.bat !_cmd!
goto :eof