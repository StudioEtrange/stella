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

if "%-properties%"=="" (
	set "-properties=%PROJECT_ROOT%\%APP%.properties"
)
set "PROPERTIES=%-properties%"

if not exist "%PROPERTIES%" (
	echo  ** ERROR properties file does not exist
	goto :end
)


call :get_all_properties

if "%ACTION%"=="init" (
	call %STELLA_ROOT%\init.bat
	call %STELLA_ROOT%\tools.bat init
	@echo off
	goto :end
)


if "%ACTION%"=="get-data" (
	call :get_data
	goto :end
)

if "%ACTION%"=="get-assets" (
	call :get_assets
	goto :end
)


:usage
   echo USAGE :
   echo %~n0 %ARGOPT_HELP_SYNTAX%
goto :end


:get_data
	if not exist "%DATA_ROOT%" mkdir "%DATA_ROOT%"
	call :_get_stella_ressources "DATA" "%~1"
goto :eof

:get_assets
	if not exist "%ASSETS_ROOT%" mkdir "%ASSETS_ROOT%"
	if not exist "%ASSETS_REPOSITORY%" mkdir "%ASSETS_REPOSITORY%"
	call :_get_stella_ressources "ASSETS" "%~1"
goto :eof

:get_all_data
	get_data %STELLA_DATA_LIST%
goto :eof

:get_all_assets
	get_assets %STELLA_ASSETS_LIST%
goto :eof

:_get_stella_ressources
	set "_mode=%~1"
	set "_list_id=%~2"

	for %%A in (!_list_id!) do (
		set _opt=!"%%A"_DATA_OPTIONS!
		set _uri=!"%%A"_DATA_URI!
		set _prot=!"%%A"_DATA_GET_PROTOCOL!
		set _name=!"%%A"_DATA_NAME!
		set _main_package=!"%%A"_DATA_MAIN_PACKAGE!
		

		set _artefact_link=0
		if "%_mode%"=="DATA" (
			set "_artefact_dest=%DATA_ROOT%"
			set _artefact_link=0
		)
		if "%_mode%"=="ASSETS" (
			set "_artefact_dest=%ASSETS_REPOSITORY%"
			set _artefact_link=1
			set "_artefact_link_target=%ASSETS_ROOT%"
		)
		


		set _merge=
		set _strip=
		for %%O in (!_opt!) do (
			if "%%O"=="MERGE" set _merge=MERGE
			if "%%O"=="STRIP" set _strip=STRIP
		)

		echo * Get %_name% [%%A] ressources

		if "!_merge!"=="MERGE" (
			echo * Main package of [%%A] is %_main_package%
		)


		if "!_merge!"=="MERGE" (
			call %STELLA_COMMON%\common.bat :get_ressource "%_mode% : !_name! [!_main_package!]" "!_uri!" "!_prot!" "!_artefact_dest!\!_main_package!" "!_merge! !_strip!"
			echo * !_name! merged into !_main_package!
			if "%_artefact_link%"=="1" (
				if exist "%!_artefact_link_target!\!_main_package!" if "%FORCE%"=="1" rmdir "!_artefact_link_target!\!_main_package!"
				if not exist "!_artefact_link_target!\!_main_package!" (
					echo ** Make symbolic link for !_main_package!
					call %STELLA_COMMON%\common.bat :run_admin %STELLA_COMMON%\symlink.bat "!_artefact_dest!\!_main_package!" "!_artefact_link_target!\!_main_package!"
				)
			)
		) else (
			call %STELLA_COMMON%\common.bat :get_ressource "%_mode% : !_name!" "!_uri!" "!_prot!" "!_artefact_dest!\!_name!" "!_strip!"
			if "%_artefact_link%"=="1" (
				if exist "%!_artefact_link_target!\!_name!" if "%FORCE%"=="1" rmdir "!_artefact_link_target!\!_name!"
				if not exist "!_artefact_link_target!\!_name!" (
					echo ** Make symbolic link for !_name!
					call %STELLA_COMMON%\common.bat :run_admin %STELLA_COMMON%\symlink.bat "!_artefact_dest!\!_name!" "!_artefact_link_target!\!_name!"
				)
			)
		)
	)
goto :eof



:: extract game properties
:get_all_properties

	REM LISTs
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "DATA_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "ASSETS_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "ENV_LIST" "PREFIX"
	call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "STELLA" "INFRA_LIST" "PREFIX"

	REM DATA
	for %%A in (!STELLA_DATA_LIST!) do (
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_MAIN_PACKAGE "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_OPTIONS "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_URI "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" DATA_GET_PROTOCOL "PREFIX"
	)

	REM ASSETS
	for %%A in (!STELLA_ASSETS_LIST!) do (
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ASSETS_MAIN_PACKAGE "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ASSETS_OPTIONS "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ASSETS_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ASSETS_URI "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ASSETS_GET_PROTOCOL "PREFIX"
	)

	REM ENV
	for %%A in (!STELLA_ENV_LIST!) do (
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" ENV_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" INFRA_ID "PREFIX"
	)
	
	REM INFRA
	for %%A in (!STELLA_INFRA_LIST!) do (
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" INFRA_NAME "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" INFRA_DISTRIB "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" INFRA_CPU "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%PROPERTIES%" "%%A" INFRA_MEM "PREFIX"
	)

	REM INFRA-ENV
	for %%A in (!STELLA_ENV_LIST!) do (
		echo %%A
		set "_artefact_infra_id=!%%A_INFRA_ID!"
		REM echo TODO : to finish INFRA-ENV
		if not "!_artefact_infra_id!"=="default" (
			set _artefact_distrib=!_artefact_infra_id!_INFRA_DISTRIB
			for %%Z in (!_artefact_distrib!) do (
				set "%%A_DISTRIB=!%%Z!"
			)
			set _artefact_mem=!_artefact_infra_id!_INFRA_MEM
			for %%Z in (!_artefact_mem!) do (
				set "%%A_MEM=!%%Z!"
			)
			set _artefact_cpu=!_artefact_infra_id!_INFRA_CPU
			for %%Z in (!_artefact_cpu!) do (
				set "%%A_CPU=!%%Z!"
			)
		)
	)
goto :eof

:end
echo ** END **
cd /D %CUR_DIR%
@echo on
@endlocal