@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0

call %~dp0\conf.bat



:: arguments
set "params=domain:"app tools virtual" action:"init get-data get-assets setup-env install create-env run-env stop-env destroy-env create-box get-box destroy-box" id:"_ANY_""
set "options=-v: -vv: -f: -arch:"#x64 x86" -vmcpu:_ANY_ -vmmemory:_ANY_ -vmgui: -l: -approot:_ANY_ -workroot:_ANY_ -cachedir:_ANY_"

call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

:: setting env
call %STELLA_COMMON%\common.bat :init_env



REM --------------- APP ----------------------------
if "%DOMAIN%"=="app" (

	if "%ACTION%"=="init" (
		REM first init STELLA
		call %STELLA_ROOT%\init.bat
		@echo off
		if "%-approot%"=="" (
			set "-approot=%PROJECT_ROOT%"
		)
		if "%-workroot%"=="" (
			set "-workroot=!-approot!"
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
	
	if "%ACTION%"=="setup-env" (
		if "%id%"=="all" (
			call %STELLA_COMMON%\common-app.bat :setup_all_env
		) else (
			call %STELLA_COMMON%\common-app.bat :setup_env "%id%"
		)
	)

)
if "%DOMAIN%"=="app" goto :end

REM --------------- TOOLS ----------------------------
if "%DOMAIN%"=="tools" (
	set "_tools_options=-arch=%ARCH%"
	if "%-f%"=="1" set "_tools_options=%_tools_options% -f"
	if "%-v%"=="1" set "_tools_options=%_tools_options% -v"
	if "%-vv%"=="1" set "_tools_options=%_tools_options% -vv"

	if "%ACTION%"=="install" (
		call %STELLA_ROOT%\tools.bat install "%id%" %_tools_options%
		@echo off
	)
)
if "%DOMAIN%"=="tools" goto :end


REM --------------- VIRTUAL ----------------------------
REM TODO info-env list-env list-box commands
if "%DOMAIN%"=="virtual" (
	set "_virtual_options="
	if not "%-vmcpu%"=="" set "_virtual_options=%_virtual_options% -vmcpu=%-vmcpu%"
	if not "%-vmmemory%"=="" set "_virtual_options=%_virtual_options% -vmmemory=%-vmmemory%"
	if "%-vmgui%"=="1" set "_virtual_options=%_virtual_options% -vmgui"
	if "%-l%"=="1" set "_virtual_options=%_virtual_options% -l"

	if "%-f%"=="1" set "_virtual_options=%_virtual_options% -f"
	if "%-v%"=="1" set "_virtual_options=%_virtual_options% -v"
	if "%-vv%"=="1" set "_virtual_options=%_virtual_options% -vv"

	
	if "%ACTION%"=="create-env" (
		call %STELLA_ROOT%\virtual.bat create-env -envname="%id%" %_virtual_options%
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
	echo 		%~n0 app get-data get-assets ^<data OR assets id OR all^>
	echo 		%~n0 app setup-env ^<env id OR all^>
	echo	* tools management :
	echo 		%~n0 tools install default : install default tools
	echo 		%~n0 tools install ^<tool name^> : install a tools
	echo 		%~n0 tools install list : list available tools
	echo	* virtual management :
	echo 		%~n0 virtual create-env run-env stop-env destroy-env ^<env id^>
	echo 		%~n0 virtual create-box get-box destroy-box ^<distrib id^>
goto :end



:end
@echo ** END **
@cd /D %CUR_DIR%
@echo on
@endlocal