@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0
call %~dp0\conf.bat


:: arguments
set "params=action:"init get-data get-assets update-data update-assets revert-data revert-assets setup-env" id:"_ANY_""
set "options=-f: -approot:_ANY_ -workroot:_ANY_ -cachedir:_ANY_"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set FORCE=%-f%

:: setting env
call %STELLA_COMMON%\common.bat :init_stella_env



if "%ACTION%"=="init" (
		
	if "%-approot%"=="" (
		set "-approot=%_STELLA_CURRENT_RUNNING_DIR%"
	)
	if "%-workroot%"=="" (
		set "-workroot=."
	)

	if "%-cachedir%"=="" (
		set "-cachedir=!-workroot!\cache"
	)

	call %STELLA_COMMON%\common-app :init_app "%id%" "!-approot!" "!-workroot!" "!-cachedir!"

	cd /D "!-approot!"
	call stella.bat feature install default

	@echo off
)

if not "%ACTION%"=="init" (
	if not exist "%_STELLA_APP_PROPERTIES_FILE%" (
		echo ** ERROR properties file does not exist
	)
)

if "%ACTION%"=="get-data" (
	if "%id%"=="all" (
		call %STELLA_COMMON%\common-app.bat :get_all_data
	) else (
		call %STELLA_COMMON%\common-app.bat :get_data "%id%"
	)
)

if "%ACTION%"=="get-assets" (
	if "%id%"=="all" (
		call %STELLA_COMMON%\common-app.bat :get_all_assets		
	) else (
		call %STELLA_COMMON%\common-app.bat :get_assets "%id%"
	)
)

if "%ACTION%"=="update-data" (
	call %STELLA_COMMON%\common-app.bat :update_data "%id%"
)

if "%ACTION%"=="update-assets" (
	call %STELLA_COMMON%\common-app.bat :update_assets "%id%"
)

if "%ACTION%"=="revert-data" (
	call %STELLA_COMMON%\common-app.bat :revert_data "%id%"
)

if "%ACTION%"=="revert-assets" (
	call %STELLA_COMMON%\common-app.bat :revert_assets "%id%"
)


if "%ACTION%"=="setup-env" (
	if "%id%"=="all" (
		call %STELLA_COMMON%\common-app.bat :setup_all_env
	) else (
		call %STELLA_COMMON%\common-app.bat :setup_env "%id%"
	)
)


goto :usage


REM ------------------------------------ INTERNAL FUNCTIONS -----------------------
:usage
	echo USAGE :
	echo %~n0 %ARGOPT_HELP_SYNTAX%

	echo ----------------
	echo List of commands
	echo	* application management :
	echo 		%~n0 init ^<application name^> [-approot=^<path^>] [-workroot=^<path^>] [-cachedir=^<path^>]
	echo 		%~n0 get-data^|get-assets^|update-data^|update-assets^|revert-data^|revert-assets ^<data id^|assets id^|all^>
	echo 		%~n0 setup-env ^<env id^|all^> : download, build, deploy and run virtual environment based on app properties
goto :end



:end
echo ** END **
cd /D %_STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal
