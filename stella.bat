@setlocal enableExtensions enableDelayedExpansion
@echo off

call %~dp0\conf.bat



:: arguments
set "params=domain:"app feature virtual api" action:"init get-data get-assets update-data update-assets revert-data revert-assets get-features setup-env install list create-env run-env stop-env destroy-env info-env create-box get-box" id:"_ANY_""
set "options=-f: -vcpu:_ANY_ -vmem:_ANY_ -head: -login: -approot:_ANY_ -workroot:_ANY_ -cachedir:_ANY_ -samples:"

call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

::set ARCH=%-arch%
set FORCE=%-f%

:: setting env
:: call %STELLA_COMMON%\common.bat :init_stella_env



REM --------------- APP ----------------------------
if "%DOMAIN%"=="app" (
	set "_app_options="
	if not "%-approot%"=="" set "_app_options=!_app_options! -approot=%-approot%"
	if not "%-workroot%"=="" set "_app_options=!_app_options! -workroot=%-workroot%"
	if not "%-cachedir%"=="" set "_app_options=!_app_options! -cachedir=%-cachedir%"
	

	if "%-samples%"=="1" set "_app_options=!_app_options! -samples"
	if "%-f%"=="1" set "_app_options=!_app_options! -f"
	
	call %STELLA_BIN%\app.bat %ACTION% %id% !_app_options!
	@echo off
	goto :end

)
if "%DOMAIN%"=="app" goto :end



REM --------------- API ----------------------------
if "%DOMAIN%"=="api" (
	if "%ACTION%"=="list" (
		if "%id%"=="all" (
			call %STELLA_COMMON%\common-api.bat :api_list "VAR"
			echo !VAR!
			goto :end
		)
	)
)
if "%DOMAIN%"=="api" goto :end


REM --------------- FEATURE ----------------------------
if "%DOMAIN%"=="feature" (
	set "_feature_options="
	if "%-f%"=="1" set "_feature_options=!_feature_options! -f"
	
	call %STELLA_BIN%\feature.bat %ACTION% %id% !_feature_options!
	@echo off
	goto :end
	
)
if "%DOMAIN%"=="feature" goto :end


REM --------------- VIRTUAL ----------------------------
if "%DOMAIN%"=="virtual" (
	set "_virtual_options="
	if not "%-vcpu%"=="" set "_virtual_options=!_virtual_options! -vcpu=%-vcpu%"
	if not "%-vmem%"=="" set "_virtual_options=!_virtual_options! -vmem=%-vmem%"
	if "%-head%"=="1" set "_virtual_options=!_virtual_options! -head"
	if "%-login%"=="1" set "_virtual_options=!_virtual_options! -login"

	if "%-f%"=="1" set "_virtual_options=!_virtual_options! -f"
	
	call %STELLA_BIN%\virtual.bat %ACTION% %id% !_virtual_options!
	@echo off
	goto :end
)
if "%DOMAIN%"=="virtual" goto :end



:usage
	echo USAGE :
	echo %~n0 %ARGOPT_HELP_SYNTAX%
	echo ----------------
	echo List of commands
	echo 	* application management :
	echo 		%~n0 app init ^<application name^> [-approot=^<path^>] [-workroot=^<path^>] [-cachedir=^<path^>] [-samples]
	echo 		%~n0 app get-data^|get-assets^|update-data^|update-assets^|revert-data^|revert-assets ^<data id^|assets id^|all^>
	echo 		%~n0 app get-features all : install all features defined in app properties file
	echo 		%~n0 app setup-env ^<env id^|all^> : download, build, deploy and run virtual environment based on app properties
	echo	* feature management :
	echo 		%~n0 feature install required : install required features for Stella
	echo 		%~n0 feature install ^<feature name^> : install a features. schema = feature_name[#version][@arch][/binary|source][:os_restriction]
	echo 		%~n0 feature list ^<all^|feature name^|active^>: list all available features OR available version of a feature OR current active features
	echo	* virtual management :
	echo 		%~n0 virtual create-env ^<env id#distrib id^> [-head] [-vmem=xxxx] [-vcpu=xx] : create a new environment from a generic box prebuilt with a specific distribution
	echo		%~n0 virtual run-env ^<env id^> [-login] : manage environment
	echo		%~n0 virtual stop-env^|destroy-env ^<env id^> : manage environment
	echo 		%~n0 virtual create-box^|get-box ^<distrib id^> : manage generic boxes built with a specific distribution
	echo 		%~n0 virtual list ^<box^|env^|distrib^>
	echo	* API :
	echo 		%~n0 api list all : list public functions of stella api
goto :end



:end
@echo ** END **
@cd /D %_STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal