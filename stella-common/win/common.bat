@echo off
call %*
goto :eof
::--------------------------------------------------------
::-- Functions
::--------------------------------------------------------

:: COMMON COMMAND LINE ARG PARSE------------------------ 
:init_arg

	:: VERBOSE
	if "%-vv%"=="" if "%-v%"=="" set /a "VERBOSE_MODE = %DEFAULT_VERBOSE_MODE%"
	if "%-vv%"=="1" ( 
		set /a "VERBOSE_MODE = 2"
	) else if "%-v%"=="1" (
		set /a "VERBOSE_MODE = 1"
	)

	set ARCH=%-arch%
	set FORCE=%-f%

goto :eof

:: COMMON ENV------------------------ 
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
			call %STELLA_COMMON%\common-tools.bat :%%F
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
		call %STELLA_COMMON%\common-tools.bat :%%F
		if not "!TEST_FEATURE!"=="0" (
			if not "!FEATURE_PATH!"=="" set "PATH=!FEATURE_PATH!;!PATH!"
		)
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


:: Test if a path is absolute
:: ARG1 is the name of the return variable - TRUE if path is absolute, FALSE if path is not absolute
:: ARG2 path to test
REM http://stackoverflow.com/questions/141344/how-to-check-if-directory-exists-in-path
:is_path_abs
	set "_result_var_is_path_abs=%~1"
	set "_test_path=%~2"
echo("%_test_path%"|findstr /i /r /c:^"^^\"[a-zA-Z]:[\\/][^\\/]" ^
                           /c:^"^^\"[\\][\\]" >nul ^
  && set "%_result_var_is_path_abs%=TRUE" || set "%_result_var_is_path_abs%=FALSE"
goto :eof

:: Convert relative to absolute path
:: ARG1 is the name of the return variable
:: ARG2 is the path to Convert
:: ARG3 is optional - This is the absolute path from which the path is relative - By default we take current directory
REM http://stackoverflow.com/questions/1645843/resolve-absolute-path-from-relative-path-and-or-file-name
REM %~f1 get the fully qualified path of your first argument but this gives a path according to the current working directory
REM %~dp0 get the fully qualified path of the 0th argument (which is the current script)
:rel_to_abs_path
	set "_result_var_rel_to_abs_path=%~1"
	set "_rel_path=%~2"
	if defined %2 set "_rel_path=!%~2!"

	call :is_path_abs "IS_ABS" "%_rel_path%"
	if "%IS_ABS%"=="TRUE" ( 
		set "_abs_root_path="
		for %%A in ( %_rel_path%\ ) do set "_temp_path=%%~dpA"
		set %_result_var_rel_to_abs_path%=!_temp_path:~0,-1!
	) else (
		set "_abs_root_path=%~3"
		if not defined _abs_root_path set "_abs_root_path=%_CURRENT_RUNNING_DIR%"
		for /f "tokens=*" %%A in ("!_abs_root_path!.\%_rel_path%") do set "%_result_var_rel_to_abs_path%=%%~fA"
	)
	
	REM for %%A in ( %_rel_path%\ ) do set _rel_path=%%~dpA
	REM set _rel_path=%_rel_path:~0,-1%
goto :eof

:: Convert absolute to relative path
:: ARG1 is the name of the return variable
:: ARG2 is the path to Convert
:: ARG3 is optional - This is the absolute path from which the path will be relative - By default we take current directory
REM http://www.dostips.com/DtCodeCmdLib.php#Function.MakeRelative
:abs_to_rel_path
	set "_result_var_abs_to_rel_path=%~1"
	set _abs_path=%~2
	if defined %2 set _abs_path=!%~2!
	set _base_path=%~3

	call :is_path_abs "IS_ABS" "%_abs_path%"
	
	REM Do not try to put code below in a IF statement
	
	if not defined _base_path set _base_path=%_CURRENT_RUNNING_DIR%
	for /f "tokens=*" %%a in ("%_abs_path%") do set _abs_path=%%~fa
	for /f "tokens=*" %%a in ("%_base_path%") do set _base_path=%%~fa
	set _mat=&rem variable to store matching part of the name
	set _upp=&rem variable to reference a parent
	for /f "tokens=*" %%a in ('echo.%_base_path:\=^&echo.%') do (
	    set _sub=!_sub!%%a\
	    call set _tmp=%%_abs_path:!_sub!=%%
	    if "!_tmp!" NEQ "!_abs_path!" (set _mat=!_sub!)ELSE (set _upp=!_upp!..\)
	)
	set _abs_path=%_upp%!_abs_path:%_mat%=!
	set %_result_var_abs_to_rel_path%=%_abs_path%


	if "%IS_ABS%"=="FALSE" set %_result_var_abs_to_rel_path%=%~2
goto :eof

:: MEASURE TOOL------------
:timecount_start
	set %~1=%RANDOM%%RANDOM%
	set "_stella_timecount_start_!%~1!=%time%"
goto :eof

:timecount_stop
	set _end_time=%time%
	set _start_time=!_stella_timecount_start_%~1!

	:: TODO the separator change depending of the local language. it is not always ':' and '.'
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
	set "STELLA_TIMECOUNT_ELAPSED=%_hours%:%_mins%:%_secs%.%_ms% -- total : %_totalsecs%.%_ms%s"
goto :eof

:: PROCESSUS TOOL--------------
:fork
	REM TODO APP NAME
	set _TITLE=%APP_NAME_FULL% -- %~1
	REM folder in will the terminal will stay after command is over
	set _FOLDER=%~2
	set _COMMAND=%~3
	set _OPT=%~4
	
	REM OPTIONS
	REM WAIT : the launcher script will wait until the forked terminal is finished
	REM SAME_WINDOW : will compute in the same terminal
	REM DETACH : terminal will not close at the end
	
	set _opt_wait=OFF
	set _opt_same_window=OFF
	set _opt_detach=OFF
	for %%O in (%_OPT%) do (
		if "%%O"=="WAIT" set _opt_wait=ON
		if "%%O"=="SAME_WINDOW" set _opt_same_window=ON
		if "%%O"=="DETACH" set _opt_detach=ON
	)



	echo ** Forking: %~3
	if "%_opt_detach%"=="ON" (
		set "_DETACH=/K"
	) else (
		set "_DETACH=/C"
	)

	if "%_opt_wait%"=="ON" ( 
		set "_WAIT=/wait"
	) else (
		set _WAIT=
	)
		
	if "%_opt_same_window%"=="ON" (
		set "_SAME_WINDOW=/b"
	) else (
		set _SAME_WINDOW=
	)

	if "%_opt_wait%"=="ON" (
		call %STELLA_COMMON%\common.bat :timecount_start timecount_id
	)
	
	start "%_TITLE%" %_WAIT% %_SAME_WINDOW% /D%_FOLDER% cmd %_DETACH% %_COMMAND%

	if "%_opt_wait%"=="ON" (
		call %STELLA_COMMON%\common.bat :timecount_stop !timecount_id!
		echo ** Fork terminated in !STELLA_TIMECOUNT_ELAPSED!
	)
goto :eof

:: set a new command line with STELLA var initialized
:bootstrap_env
	REM TODO APP NAME
	REM Useless ?
	set _TITLE=%APP_NAME_FULL% -- %~1
	:: folder in wich the new bootstraped env will remain
	set _FOLDER=%~2

	call :fork "%_TITLE%" "%_FOLDER%" "%STELLA_COMMON%\bootstrap-stella-env.bat -internalcall" "DETACH"
	echo ** A new env %_TITLE% is bootstrapped with all STELLA default variable setted
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
	
	if not "%FINAL_DESTINATION%"=="" (
		echo ** Getting ressource : %NAME% into %FINAL_DESTINATION%
	) else (
		echo ** Getting ressource : %NAME%
	)

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
	set "_STRIP="
	if "%_opt_strip%"=="ON" set "_STRIP=STRIP"

	if "%_FLAG%"=="1" (
		if not exist "%FINAL_DESTINATION%" mkdir %FINAL_DESTINATION%

		if "%PROTOCOL%"=="HTTP_ZIP" (
			echo MERGE : %_opt_merge%
			echo STRIP : %_opt_strip%
			call :download_uncompress "%URI%" "_AUTO_" "%FINAL_DESTINATION%" "%_STRIP%"
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
			call :uncompress "%URI%" "%FINAL_DESTINATION%" "%_STRIP%"
			if "%_opt_merge%"=="ON" echo 1 > "%FINAL_DESTINATION%\._MERGED_!_name_legal!"
		)
	)
goto :eof

:download_uncompress
	set URL=%~1
	set FILE_NAME=%~2
	set UNZIP_DIR=%~3
	set OPT=%~4

	
	REM OPTIONS
	REM 	DEST_ERASE
	REM 		delete destination folder
	REM 	STRIP
	REM 		delete first level folders in archive
	
	set _opt_dest_erase=OFF
	set _opt_strip=OFF
	for %%O in (%OPT%) do (
		if "%%O"=="DEST_ERASE" set _opt_dest_erase=ON
		if "%%O"=="STRIP" set _opt_strip=ON
	)

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

	call :uncompress "%CACHE_DIR%\%FILE_NAME%" "%UNZIP_DIR%" "%OPT%"
goto :eof

:uncompress
	set FILE_PATH=%~1
	set UNZIP_DIR=%~2
	set OPT=%~3

	
	REM OPTIONS
	REM 	DEST_ERASE
	REM 		delete destination folder
	REM 	STRIP
	REM 		delete first level folders in archive
	
	set _opt_dest_erase=OFF
	set _opt_strip=OFF
	for %%O in (%OPT%) do (
		if "%%O"=="DEST_ERASE" set _opt_dest_erase=ON
		if "%%O"=="STRIP" set _opt_strip=ON
	)
	
	
	if "%_opt_dest_erase%"=="ON" if exist "%UNZIP_DIR%" call :del_folder "%UNZIP_DIR%"
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

	if "%_opt_strip%"=="OFF" (
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
			REM TODO why not cd /D %%i ?????
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

	if not exist "%CACHE_DIR%" (
		mkdir "%CACHE_DIR%"
	)

	echo ** Download %FILE_NAME% from %URL% into cache
	
	REM if "%FORCE%"=="1" (
	REM	del /q /s "%CACHE_DIR%\%FILE_NAME%"
	REM )

	if not exist "%CACHE_DIR%\%FILE_NAME%" (
		"%WGET%" "%URL%" -O "%CACHE_DIR%\%FILE_NAME%" --no-check-certificate
	) else (
		echo ** Already downloaded
	)

	if not "%DEST_DIR%"=="" if not "%DEST_DIR%"=="%CACHE_DIR%" (
		if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"
		copy /y "%CACHE_DIR%\%FILE_NAME%" "%DEST_DIR%\"
		echo ** Downloaded %FILE_NAME% is in %DEST_DIR%
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
	for %%O in (%_OPT%) do (
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
:: check if a "findstr windows regexp" can be found in a string
:: by setting 
::		_match_exp with TRUE or FALSE
:: first argument is the regexp
:: second argument is the string
:: NOTE : read result var with !_match_exp!
:match_exp
	set _win_regexp=%~1
	set _string=%~2

	set "_match_exp=FALSE"
	for /f %%m in ('echo  %_string%^| findstr /N "%_win_regexp%" ^| find /c ":"') do (
		if not "%%m"=="0" set "_match_exp=TRUE"
	)
goto :eof

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