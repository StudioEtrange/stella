@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0

call %~dp0\conf.bat



:: arguments
set "params=domain:"app tools virtual api" action:"init get-data get-assets update-data update-assets revert-data revert-assets setup-env install list create-env run-env stop-env destroy-env info-env create-box get-box destroy-box" id:"_ANY_""
set "options=-f: -arch:"#x64 x86" -envcpu:_ANY_ -envmem:_ANY_ -vmgui: -l: -approot:_ANY_ -workroot:_ANY_ -cachedir:_ANY_"

call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set ARCH=%-arch%
set FORCE=%-f%

:: setting env
call %STELLA_COMMON%\common.bat :init_stella_env



REM --------------- APP ----------------------------
if "%DOMAIN%"=="app" (

	if "%ACTION%"=="init" (
		
		if "%-approot%"=="" (
			set "-approot=%_CURRENT_RUNNING_DIR%"
		)
		if "%-workroot%"=="" (
			set "-workroot=."
		)

		if "%-cachedir%"=="" (
			set "-cachedir=!-workroot!\cache"
		)

		call %STELLA_COMMON%\common-app :init_app "%id%" "!-approot!" "!-workroot!" "!-cachedir!"

		cd /D "!-approot!"
		call %STELLA_ROOT%\tools.bat install default
		@echo off
	)

	if not "%ACTION%"=="init" (
		if not exist "%PROPERTIES%" (
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

)
if "%DOMAIN%"=="app" goto :end



REM --------------- API ----------------------------
if "%DOMAIN%"=="api" (
	if "%ACTION%"=="list" (
		if "%id%"=="all" (
			call %STELLA_COMMON%\common-api.bat :api_list "VAR"
			echo !VAR!
		)
	)
)
if "%DOMAIN%"=="api" goto :end


REM --------------- TOOLS ----------------------------
if "%DOMAIN%"=="tools" (
	set "_tools_options=-arch=%ARCH%"
	if "%-f%"=="1" set "_tools_options=%_tools_options% -f"
	if "%-v%"=="1" set "_tools_options=%_tools_options% -v"
	if "%-vv%"=="1" set "_tools_options=%_tools_options% -vv"

	if "%ACTION%"=="install" (
		set vers=%id:*#=%
		set "id=%id:#="^&REM #%
		call %STELLA_ROOT%\tools.bat install "%id%" -vers=%vers% %_tools_options%
		@echo off
	)

	if "%ACTION%"=="list" (
		call %STELLA_ROOT%\tools.bat list "%id%" %_tools_options%
		@echo off
	)
)
if "%DOMAIN%"=="tools" goto :end


REM --------------- VIRTUAL ----------------------------
if "%DOMAIN%"=="virtual" (
	set "_virtual_options="
	if not "%-envcpu%"=="" set "_virtual_options=%_virtual_options% -envcpu=%-envcpu%"
	if not "%-envmem%"=="" set "_virtual_options=%_virtual_options% -envmem=%-envmem%"
	if "%-vmgui%"=="1" set "_virtual_options=%_virtual_options% -vmgui"
	if "%-l%"=="1" set "_virtual_options=%_virtual_options% -l"

	if "%-f%"=="1" set "_virtual_options=%_virtual_options% -f"
	if "%-v%"=="1" set "_virtual_options=%_virtual_options% -v"
	if "%-vv%"=="1" set "_virtual_options=%_virtual_options% -vv"

	
	if "%ACTION%"=="list" (
		if "%id%"=="env" (
			call %STELLA_ROOT%\virtual.bat list-env %_virtual_options%
			@echo off
		)
		if "%id%"=="box" (
			call %STELLA_ROOT%\virtual.bat list-box %_virtual_options%
			@echo off
		)
		if "%id%"=="distrib" (
			call %STELLA_ROOT%\virtual.bat list-distrib %_virtual_options%
			@echo off
		)
		
	)

	if "%ACTION%"=="create-env" (
		set distrib=%id:*#=%
		set "id=%id:#="^&REM #%
		call %STELLA_ROOT%\virtual.bat create-env -distrib=!distrib! -envname="%id%" %_virtual_options%
		@echo off
	)

	if "%ACTION%"=="run-env" (
		call %STELLA_ROOT%\virtual.bat run-env -envname="%id%" %_virtual_options%
		@echo off
	)

	if "%ACTION%"=="stop-env" (
		call %STELLA_ROOT%\virtual.bat stop-env -envname="%id%" %_virtual_options%
		@echo off
	)

	if "%ACTION%"=="destroy-env" (
		call %STELLA_ROOT%\virtual.bat destroy-env -envname="%id%" %_virtual_options%
		@echo off
	)

	if "%ACTION%"=="info-env" (
		call %STELLA_ROOT%\virtual.bat info-env -envname="%id%" %_virtual_options%
		@echo off
	)

	if "%ACTION%"=="create-box" (
		call %STELLA_ROOT%\virtual.bat create-box -distrib="%id%" %_virtual_options%
		@echo off
	)

	if "%ACTION%"=="get-box" (
		call %STELLA_ROOT%\virtual.bat get-box -distrib="%id%" %_virtual_options%
		@echo off
	)

	if "%ACTION%"=="destroy-box" (
		call %STELLA_ROOT%\virtual.bat destroy-box -distrib="%id%" %_virtual_options%
		@echo off
	)

)
if "%DOMAIN%"=="virtual" goto :end



:usage
	echo USAGE :
	echo %~n0 %ARGOPT_HELP_SYNTAX%
	echo ----------------
	echo List of commands
	echo 	* application management :
	echo 		%~n0 app init ^<application name^> [-approot=^<path^>] [-workroot=^<path^>] [-cachedir=^<path^>]
	echo 		%~n0 app get-data get-asset supdate-data update-assets revert-data revert-assets ^<data id^|assets id^|all^>
	echo 		%~n0 app setup-env ^<env id^|all^> : download, build, deploy and run virtual environment based on app properties
	echo	* tools management :
	echo 		%~n0 tools install default : install default tools
	echo 		%~n0 tools install ^<tool name#version^> : install a tools. version is optionnal
	echo 		%~n0 tools list ^<all^|tool name^>: list all available tools OR available version of a tool
	echo 		%~n0 tools list all: list available tools
	echo	* virtual management :
	echo 		%~n0 virtual create-env ^<env id#distrib id^> : create a new environment from a generic box prebuilt with a specific distribution
	echo		%~n0 virtual run-env stop-env destroy-env info-env ^<env id^> : manage environment
	echo 		%~n0 virtual create-box get-box destroy-box ^<distrib id^> : manage generic boxes built with a specific distribution
	echo 		%~n0 virtual list ^<box^|env^|distrib^>
	echo	* API :
	echo 		%~n0 api list all : list public functions of stella api
goto :end



:end
@echo ** END **
@cd /D %_CURRENT_RUNNING_DIR%
@echo on
@endlocal