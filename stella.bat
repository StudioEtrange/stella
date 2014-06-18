@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0

call %~dp0\conf.bat

:: arguments
set "params=app:"_ANY_" action:"init get-data get-assets get-all-data get-all-assets create-env create-all-env""
set "options=-properties:"_ANY_" -id:"_ANY" -v: -vv: -f:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

:: setting env
call %STELLA_COMMON%\common.bat :init_env

if not exist "%PROPERTIES%" (
	echo  ** ERROR properties file does not exist
	goto :end
)


call :get_properties

if "%ACTION%"=="init" (
	call %STELLA_ROOT%\init.bat
	call %STELLA_ROOT%\tools.bat init
)


if "%ACTION%"=="get-data" (
	call :get_data
)

goto :end


:usage
   echo USAGE :
   echo %~n0 %ARGOPT_HELP_SYNTAX%
goto :end


:get_data
	set _list_id=%~1
	if not exist "%DATA_ROOT%" mkdir "%DATA_ROOT%"
	call :_get_stella_ressources "DATA" "%_list_id%"
goto :end

:_get_stella_ressources
	


	echo * Get DATA ressources
	echo * Main DATA package is %DATA_MAIN_PACKAGE%
	for /l %%x in (1, 1, %DATA_NUMBER%) do (
		set _opt=!DATA_OPTIONS_%%x!
		set _uri=!DATA_URI_%%x!
		set _prot=!DATA_GET_PROTOCOL_%%x!
		set _name=!DATA_NAME_%%x!
		
		set _merge=
		set _strip=
		for %%O in (!_opt!) do (
			if "%%O"=="MERGE" set _merge=MERGE
			if "%%O"=="STRIP" set _strip=STRIP
		)

		if "!_merge!"=="MERGE" (
			call %STELLA_COMMON%\common.bat :get_ressource "DATA #%%x [%DATA_MAIN_PACKAGE% - !_name!]" "!_uri!" "!_prot!" "%DEST%\data\%DATA_MAIN_PACKAGE%" "!_merge! !_strip!"
			echo * !_name! merged into %DATA_MAIN_PACKAGE%
		) else (
			call %STELLA_COMMON%\common.bat :get_ressource "DATA #%%x [!_name!]" "!_uri!" "!_prot!" "%DEST%\data\!_name!" "!_strip!"
		)
	)




	echo * Get RAW ASSETS ressources
	echo * Main RAW ASSETS package is %RAW_ASSETS_MAIN_PACKAGE%
	for /l %%x in (1, 1, %RAW_ASSETS_NUMBER%) do (
		set _opt=!RAW_ASSETS_OPTIONS_%%x!
		set _uri=!RAW_ASSETS_URI_%%x!
		set _prot=!RAW_ASSETS_GET_PROTOCOL_%%x!
		set _name=!RAW_ASSETS_NAME_%%x!

		set _merge=
		set _strip=
		for %%O in (!_opt!) do (
			if "%%O"=="MERGE" set _merge=MERGE
			if "%%O"=="STRIP" set _strip=STRIP
		)

		if "!_merge!"=="MERGE" (
			call %STELLA_COMMON%\common.bat :get_ressource "RAW ASSETS #%%x [%RAW_ASSETS_MAIN_PACKAGE% - !_name!]" "!_uri!" "!_prot!" "%ASSETS_REPOSITORY%\RAW\%RAW_ASSETS_MAIN_PACKAGE%" "!_merge! !_strip!"
			echo * !_name! merged into %RAW_ASSETS_MAIN_PACKAGE%
			if exist "%DEST%\assets\%RAW_ASSETS_MAIN_PACKAGE%" if "%FORCE%"=="1" rmdir "%DEST%\assets\%RAW_ASSETS_MAIN_PACKAGE%"
			if not exist "%DEST%\assets\%RAW_ASSETS_MAIN_PACKAGE%" (
				echo ** Make symbolic link for %RAW_ASSETS_MAIN_PACKAGE%
				call %STELLA_COMMON%\common.bat :run_admin %STELLA_COMMON%\symlink.bat "%ASSETS_REPOSITORY%\RAW\%RAW_ASSETS_MAIN_PACKAGE%" "%DEST%\assets\%RAW_ASSETS_MAIN_PACKAGE%"
			)
		) else (
			call %STELLA_COMMON%\common.bat :get_ressource "RAW ASSETS #%%x [!_name!]" "!_uri!" "!_prot!" "%ASSETS_REPOSITORY%\RAW\!_name!" "!_strip!"
			if exist "%DEST%\assets\!_name!" if "%FORCE%"=="1" rmdir "%DEST%\assets\!_name!"
			if not exist "%DEST%\assets\!_name!" (
				echo ** Make symbolic link for !_name!
				call %STELLA_COMMON%\common.bat :run_admin %STELLA_COMMON%\symlink.bat "%ASSETS_REPOSITORY%\RAW\!_name!" "%DEST%\assets\!_name!"
			)
		)
	)




 	REM EXPORTED ASSETS MAIN PACKAGE must contain a root directory named "export"
	echo * Get EXPORTED ASSETS ressources
	echo * Main EXPORTED ASSETS package is %EXPORTED_ASSETS_MAIN_PACKAGE%
	for /l %%x in (1, 1, %EXPORTED_ASSETS_NUMBER%) do (
		set _opt=!EXPORTED_ASSETS_OPTIONS_%%x!
		set _uri=!EXPORTED_ASSETS_URI_%%x!
		set _prot=!EXPORTED_ASSETS_GET_PROTOCOL_%%x!
		set _name=!EXPORTED_ASSETS_NAME_%%x!

		set _merge=
		set _strip=
		for %%O in (!_opt!) do (
			if "%%O"=="MERGE" set _merge=MERGE
			if "%%O"=="STRIP" set _strip=STRIP
		)

		if "!_merge!"=="MERGE" (
			call %STELLA_COMMON%\common.bat :get_ressource "EXPORTED ASSETS #%%x [%EXPORTED_ASSETS_MAIN_PACKAGE% - !_name!]" "!_uri!" "!_prot!" "%ASSETS_REPOSITORY%\EXPORTED\%EXPORTED_ASSETS_MAIN_PACKAGE%" "!_merge! !_strip!"
			echo * !_name! merged into %EXPORTED_ASSETS_MAIN_PACKAGE%
			if exist "%DEST%\build\export\%EXPORTED_ASSETS_MAIN_PACKAGE%" if "%FORCE%"=="1" rmdir "%DEST%\build\export\%EXPORTED_ASSETS_MAIN_PACKAGE%"
			if not exist "%DEST%\build\export\%EXPORTED_ASSETS_MAIN_PACKAGE%" (
				echo ** Make symbolic link for %EXPORTED_ASSETS_MAIN_PACKAGE%
				call %STELLA_COMMON%\common.bat :run_admin %STELLA_COMMON%\symlink.bat "%ASSETS_REPOSITORY%\EXPORTED\%EXPORTED_ASSETS_MAIN_PACKAGE%" "%DEST%\build\export\%EXPORTED_ASSETS_MAIN_PACKAGE%"
			)
		) else (
			call %STELLA_COMMON%\common.bat :get_ressource "EXPORTED ASSETS #%%x [!_name!]" "!_uri!" "!_prot!" "%ASSETS_REPOSITORY%\EXPORTED\!_name!" "!_strip!"
			if exist "%DEST%\build\export\!_name!" if "%FORCE%"=="1" rmdir "%DEST%\build\export\!_name!"
			if not exist "%DEST%\build\export\!_name!" (
				echo ** Make symbolic link for !_name!
				call %STELLA_COMMON%\common.bat :run_admin %STELLA_COMMON%\symlink.bat "%ASSETS_REPOSITORY%\EXPORTED\!_name!" "%DEST%\build\export\!_name!"
			)			
		)
	)

goto :eof



:: extract game properties
:get_properties

	for %%A in (DATA RAW_ASSETS EXPORTED_ASSETS) do (
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" "%%A"_MAIN_PACKAGE
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" "%%A"_NUMBER
		set _number=!"%%A"_NUMBER!
		if "%_number%"=="" set _number=0
		for /l %%x in (1, 1, %_number%) do (
			call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" "%%A"_OPTIONS_"%%x"
			call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" "%%A"_NAME_"%%x"
			call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" "%%A"_URI_"%%x"
			call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" "%%A"_GET_PROTOCOL_"%%x"
		)
	)

	REM call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "DATA_MAIN_PACKAGE"
	REM call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "DATA_NUMBER"
	REM if "%DATA_NUMBER%"=="" set DATA_NUMBER=0
	REM for /l %%x in (1, 1, %DATA_NUMBER%) do (
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "DATA_OPTIONS_%%x"
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "DATA_NAME_%%x"
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "DATA_URI_%%x"
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "DATA_GET_PROTOCOL_%%x"
	REM )

	REM call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "RAW_ASSETS_MAIN_PACKAGE"
	REM call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "RAW_ASSETS_NUMBER"
	REM if "%RAW_ASSETS_NUMBER%"=="" set RAW_ASSETS_NUMBER=0
	REM for /l %%x in (1, 1, %RAW_ASSETS_NUMBER%) do (
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "RAW_ASSETS_OPTIONS_%%x"
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "RAW_ASSETS_NAME_%%x"
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "RAW_ASSETS_URI_%%x"
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "RAW_ASSETS_GET_PROTOCOL_%%x"
	REM )

	REM call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "EXPORTED_ASSETS_MAIN_PACKAGE"
	REM call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "EXPORTED_ASSETS_NUMBER"
	REM if "%EXPORTED_ASSETS_NUMBER%"=="" set EXPORTED_ASSETS_NUMBER=0
	REM for /l %%x in (1, 1, %EXPORTED_ASSETS_NUMBER%) do (
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "EXPORTED_ASSETS_OPTIONS_%%x"
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "EXPORTED_ASSETS_NAME_%%x"
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "EXPORTED_ASSETS_URI_%%x"
	REM 	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "EXPORTED_ASSETS_GET_PROTOCOL_%%x"
	REM )


goto :eof

:end
echo ** END **
cd /D %CUR_DIR%
@echo on
@endlocal