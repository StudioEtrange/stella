@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0

call %~dp0\conf.bat


	REM ryzomcore-data : http://www.ryzomcore.org/level-design-data-move/

:: arguments
set "params=action:"get-ressources setup-pipeline" game:"_ANY_" properties:"_ANY_" vs:"vc11 vc10 vc9""
set "options=-output:"#release debug" -externlib:"#release debug" -externlibarch:"x64 x86 arm" -buildtool:"#nmake ninja" -v: -vv: -f:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage
call %STELLA_COMMON%\common.bat :init_arg

:: setting env
call %STELLA_COMMON%\common.bat :init_env

if not exist "%PROPERTIES%" (
	echo  ** ERROR game properties file does not exist
	goto :end
)


call :init_folder
call :get_properties

if "%ACTION%"=="get-ressources" (
	call :get_ressources
)


if "%ACTION%"=="setup-pipeline" (
	call :setup_pipeline
)

goto :end


:usage
   echo USAGE :
   echo %~n0 %ARGOPT_HELP_SYNTAX%
goto :end


:init_folder
	:: Tree folder
	set BUILD_NAME=%GAME%
	set "DEST=%GAMES_ROOT%\%BUILD_NAME%"

	if "%OUTPUT%"=="Release" (
		set "ROOT_SUFFIX=_rel"
	)
	if "%OUTPUT%"=="Debug" (
		set "ROOT_SUFFIX=_dbg"
	)

	if "%EXTERNLIB%"=="Release" (
		set "ROOT_SUFFIX=%ROOT_SUFFIX%_librel"
	)
	if "%EXTERNLIB%"=="Debug" (
		set "ROOT_SUFFIX=%ROOT_SUFFIX%_libdbg"
	)


	set "ROOT_CLIENT=%RYZOMCORE_BUILD_ROOT%\client_%VISUALSTUDIO_ENV%_%ARCH%%ROOT_SUFFIX%"
	set "ROOT_SERVER=%RYZOMCORE_BUILD_ROOT%\server_%VISUALSTUDIO_ENV%_%ARCH%%ROOT_SUFFIX%"
	set "ROOT_RYZOM_TOOLS=%RYZOMCORE_BUILD_ROOT%\rytool_%VISUALSTUDIO_ENV%_%ARCH%%ROOT_SUFFIX%"
	set "ROOT_NEL_TOOLS=%RYZOMCORE_BUILD_ROOT%\nltool_%VISUALSTUDIO_ENV%_%ARCH%%ROOT_SUFFIX%"
	set "DEST=%DEST%_%ARCH%%ROOT_SUFFIX%"

	if not exist "%DEST%" mkdir "%DEST%"
	REM R:\
	if not exist "%DEST%\pipeline%" mkdir "%DEST%\pipeline"
	if not exist "%DEST%\client" mkdir "%DEST%\client"
	if not exist "%DEST%\server" mkdir "%DEST%\server"
	if not exist "%DEST%\tools\ryzom" mkdir "%DEST%\tools\ryzom"
	if not exist "%DEST%\tools\nel" mkdir "%DEST%\tools\nel"
	REM TODO External tools from lib ?
	REM L:\
	if not exist "%DEST%\data" mkdir "%DEST%\data"
	REM W:\
	if not exist "%DEST%\assets" mkdir "%DEST%\assets"
	REM T:\
	if not exist "%DEST%\build" mkdir "%DEST%\build"
	if not exist "%DEST%\build\export" mkdir "%DEST%\build\export"
goto :eof



:get_ressources
	echo * Grabbing media and data ressources

	if "%FORCE%"=="1" (
		call %STELLA_COMMON%\common.bat :del_folder "%DEST%\data"
		call %STELLA_COMMON%\common.bat :del_folder "%DEST%\assets"
	)
	if not exist "%DEST%\data" mkdir "%DEST%\data"
	if not exist "%DEST%\assets" mkdir "%DEST%\assets"
	if not exist "%DEST%\build" mkdir "%DEST%\build"
	if not exist "%DEST%\build\export" mkdir "%DEST%\build\export"
	


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


:get_rc
	echo * Grabbing ryzomcore elements

	if "%FORCE%"=="1" (
		call %STELLA_COMMON%\common.bat :del_folder "%DEST%\pipeline"
		call %STELLA_COMMON%\common.bat :del_folder "%DEST%\client"
		call %STELLA_COMMON%\common.bat :del_folder "%DEST%\server"
		call %STELLA_COMMON%\common.bat :del_folder "%DEST%\tools"
	)
	:: install pipeline
	echo ** Get pipeline
	call %STELLA_COMMON%\common.bat :copy_folder_content_into %RYZOMCORE_CODE_ROOT%\nel\tools\build_gamedata %DEST%\pipeline

	:: install client
	echo ** Get client
	call %STELLA_COMMON%\common.bat :copy_folder_content_into %ROOT_CLIENT% %DEST%\client

	:: install server
	echo ** Get server
	call %STELLA_COMMON%\common.bat :copy_folder_content_into %ROOT_SERVER% %DEST%\server

	:: ryzom tools
	echo ** Get ryzom tools
	call %STELLA_COMMON%\common.bat :copy_folder_content_into %ROOT_RYZOM_TOOLS% %DEST%\tools\ryzom

	:: nel tools
	echo ** Get nel tools
	call %STELLA_COMMON%\common.bat :copy_folder_content_into %ROOT_NEL_TOOLS% %DEST%\tools\nel
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