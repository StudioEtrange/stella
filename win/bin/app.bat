@setlocal enableExtensions enableDelayedExpansion
@echo off

call %~dp0\..\..\conf.bat


:: arguments
set "params=action:"link init get-data get-assets update-data update-assets revert-data revert-assets setup-env get-feature" id:"_ANY_""
set "options=-f: -approot:_ANY_ -workroot:_ANY_ -cachedir:_ANY_ -stellaroot:_ANY_ -samples:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set FORCE=%-f%

:: setting env
call %STELLA_COMMON%\common.bat :init_stella_env



if "%ACTION%"=="init" (
		
	if "%-approot%"=="" (
		set "-approot=%_STELLA_CURRENT_RUNNING_DIR%\%id%"
	)
	if "%-workroot%"=="" (
		set "-workroot=!-approot!"
	)

	if "%-cachedir%"=="" (
		set "-cachedir=!-workroot!\cache"
	)

	call %STELLA_COMMON%\common-app :init_app "%id%" "!-approot!" "!-workroot!" "!-cachedir!"
	if "%-samples%"=="1" (
		call %STELLA_COMMON%\common-app :create_app_samples "!-approot!"
	)

	@echo off
	goto :end
)

if not "%ACTION%"=="init" (
	if not exist "%_STELLA_APP_PROPERTIES_FILE%" (
		echo ** ERROR properties file does not exist
		goto :end
	)
)

if "%ACTION%"=="link" (
	call %STELLA_COMMON%\common-app.bat :link_app "%id%" "!-stellaroot!"
	goto :end
)

if "%ACTION%"=="get-data" (
	if "%id%"=="all" (
		call %STELLA_COMMON%\common-app.bat :get_all_data
	) else (
		call %STELLA_COMMON%\common-app.bat :get_data "%id%"
	)
	goto :end
)

if "%ACTION%"=="get-feature" (
	if "%id%"=="all" (
		call %STELLA_COMMON%\common-app.bat :get_features
	) else (
		call %STELLA_COMMON%\common-app.bat :get_feature "%id%"
	)
	goto :end
)

if "%ACTION%"=="get-assets" (
	if "%id%"=="all" (
		call %STELLA_COMMON%\common-app.bat :get_all_assets		
	) else (
		call %STELLA_COMMON%\common-app.bat :get_assets "%id%"
	)
	goto :end
)

if "%ACTION%"=="update-data" (
	call %STELLA_COMMON%\common-app.bat :update_data "%id%"
	goto :end
)

if "%ACTION%"=="update-assets" (
	call %STELLA_COMMON%\common-app.bat :update_assets "%id%"
	goto :end
)

if "%ACTION%"=="revert-data" (
	call %STELLA_COMMON%\common-app.bat :revert_data "%id%"
	goto :end
)

if "%ACTION%"=="revert-assets" (
	call %STELLA_COMMON%\common-app.bat :revert_assets "%id%"
	goto :end
)


if "%ACTION%"=="setup-env" (
	if "%id%"=="all" (
		call %STELLA_COMMON%\common-app.bat :setup_all_env
	) else (
		call %STELLA_COMMON%\common-app.bat :setup_env "%id%"
	)
	goto :end
)


goto :usage


REM ------------------------------------ INTERNAL FUNCTIONS -----------------------
:usage
	echo USAGE :
	echo %~n0 %ARGOPT_HELP_SYNTAX%

	echo ----------------
	echo List of commands
	echo	* application management :
	echo 		%~n0 init ^<application name^> [-approot=^<path^>] [-workroot=^<path^>] [-cachedir=^<path^>] [-samples]
	echo 		%~n0 get-data^|get-assets^|update-data^|update-assets^|revert-data^|revert-assets ^<data id^|assets id^|all^>
	echo 		%~n0 app get-feature ^<all^|feature schema^> : install all features defined in app properties file or install a matching one
	echo 		%~n0 setup-env ^<env id^|all^> : download, build, deploy and run virtual environment based on app properties
	echo		%~n0 link ^<app-path^> [-stellaroot=^<path^>] : link an app to a specific stella path
	
goto :end



:end
echo ** END **
cd /D %_STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal
