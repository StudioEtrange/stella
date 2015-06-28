@setlocal enableExtensions enableDelayedExpansion
@echo off

call %~dp0\..\..\conf.bat


:: arguments
set "params=action:"link init get-data get-data-pack get-assets get-assets-pack delete-data delete-data-pack delete-assets delete-assets-pack update-data update-assets revert-data revert-assets update-data-pack update-assets-pack revert-data-pack revert-assets-pack get-feature" id:"_ANY_""
set "options=-f: -approot:_ANY_ -workroot:_ANY_ -cachedir:_ANY_ -stellaroot:_ANY_ -samples:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set FORCE=%-f%

:: setting env
call %STELLA_COMMON%\common.bat :init_stella_env



if "%ACTION%"=="init" (
		
	if "%-approot%"=="" (
		set "-approot=%STELLA_CURRENT_RUNNING_DIR%\%id%"
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

if "%ACTION%"=="link" (
	call %STELLA_COMMON%\common-app.bat :link_app "%id%" "!-stellaroot!"
	goto :end
)

if not "%ACTION%"=="init" if not "%ACTION%"=="link" (
	if not exist "%_STELLA_APP_PROPERTIES_FILE%" (
		echo ** ERROR properties file does not exist
		goto :end
	)
)



if "%ACTION%"=="get-feature" (
	if "%id%"=="all" (
		call %STELLA_COMMON%\common-app.bat :get_features
	) else (
		call %STELLA_COMMON%\common-app.bat :get_feature "%id%"
	)
	goto :end
)

if "%ACTION%"=="get-data" (
	call %STELLA_COMMON%\common-app.bat :get_data "%id%"
	goto :end
)

if "%ACTION%"=="get-data-pack" (
	call %STELLA_COMMON%\common-app.bat :get_data_pack "%id%"
	goto :end
)



if "%ACTION%"=="get-assets" (
	call %STELLA_COMMON%\common-app.bat :get_assets "%id%"
	goto :end
)

if "%ACTION%"=="get-assets-pack" (
	call %STELLA_COMMON%\common-app.bat :get_assets_pack "%id%"
	goto :end
)


if "%ACTION%"=="delete-data" (
	call %STELLA_COMMON%\common-app.bat :delete_data "%id%"
	goto :end
)

if "%ACTION%"=="delete-assets" (
	call %STELLA_COMMON%\common-app.bat :delete_assets "%id%"
	goto :end
)


if "%ACTION%"=="delete-data-pack" (
	call %STELLA_COMMON%\common-app.bat :delete_data_pack "%id%"
	goto :end
)

if "%ACTION%"=="delete-assets-pack" (
	call %STELLA_COMMON%\common-app.bat :delete_assets_pack "%id%"
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




goto :usage


REM ------------------------------------ INTERNAL FUNCTIONS -----------------------
:usage
	echo USAGE :
	echo %~n0 %ARGOPT_HELP_SYNTAX%

	echo ----------------
	echo List of commands
	echo	* application management :
	echo 		%~n0 init ^<application name^> [-approot=^<path^>] [-workroot=^<path^>] [-cachedir=^<path^>] [-samples]
	echo 		%~n0 get-data^|get-assets^|delete-data^|delete-assets^|update-data^|update-assets^|revert-data^|revert-assets ^<list of data id^|list of assets id^>
	echo 		%~n0 get-data-pack^|get-assets-pack^|delete-data-pack^|delete-assets-pack^|update-data-pack^|update-assets-pack^|revert-data-pack^|revert-assets-pack ^<data pack name^|assets pack name^>
	echo 		%~n0 app get-feature ^<all^|feature schema^> : install all features defined in app properties file or install a matching one
	echo		%~n0 link ^<app-path^> [-stellaroot=^<path^>] : link an app to a specific stella path
	echo		search path : print current system search path
goto :end



:end
echo ** END **
cd /D %STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal
