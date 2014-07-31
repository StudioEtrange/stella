@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0
echo ** Requirement : Vagrant 1.6 from http://www.vagrantup.com/
echo ** Recommanded : vagrant-vbguest plugin https://github.com/dotless-de/vagrant-vbguest http://kvz.io/blog/2013/01/16/vagrant-tip-keep-virtualbox-guest-additions-in-sync/
echo 					vagrant plugin install vagrant-vbguest
echo ** Requirement : Virtualbox 4.3.12 from https://www.virtualbox.org/
call %~dp0\conf.bat


:: docker installation on windows : http://docs.docker.io/en/latest/installation/windows/

:: arguments
set "params=action:"create-env run-env stop-env destroy-env info-env create-box get-box list" id:"_ANY_""
set "options=-f: -login: -vcpu:_ANY_ -vmem:_ANY_ -head:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set FORCE=%-f%

:: setting env
call %STELLA_COMMON%\common.bat :init_stella_env

REM --------------- BOX MANAGEMENT -------------------------
if "%action%"=="list" (
	if "%id"=="distrib" (
		call %STELLA_COMMON%\common-virtual.bat :list_distrib "VAR"
		echo !VAR!
	)
	if "%id"=="box" (
		call %STELLA_COMMON%\common-virtual.bat :list_box
	)
	if "%id"=="env" (
		call %STELLA_COMMON%\common-virtual.bat :list_env
	)
	goto :end
)

REM --------------- BOX MANAGEMENT -------------------------
if "%action%"=="create-box" (
	call %STELLA_COMMON%\common-virtual.bat :create_box %id%
	goto :end
)

if "%action%"=="get-box" (
	call %STELLA_COMMON%\common-virtual.bat :get_box %id%
	goto :end
)



REM --------------- ENV MANAGEMENT -------------------------
if "%action%"=="create-env" (
	set distrib=%id:*#=%
	set "id=%id:#="^&REM #%

	set _create_opt=
	if "%-head%"=="1" (
		set _create_opt="HEAD"
	)
	if not "%-vmem%"=="" (
		set _create_opt="!_create_opt! MEM !-vmem!"
	)
	if not "%-vcpu%"=="" (
		set _create_opt="!_create_opt! MEM !-vcpu!"
	)
	call %STELLA_COMMON%\common-virtual.bat :create_env !id! !distrib! "!_create_opt!"
	goto :end
)

if "%action%"=="destroy-env" (
	call %STELLA_COMMON%\common-virtual.bat :destroy_env %id%
	goto :end
)

if "%action%"=="run-env" (
	if "%-login%"=="1" (
		call %STELLA_COMMON%\common-virtual.bat :run_env %id% "TRUE"
	) else (
		call %STELLA_COMMON%\common-virtual.bat :run_env %id%
	)
	goto :end
)

if "%action%"=="stop-env" (
	call %STELLA_COMMON%\common-virtual.bat :stop_env %id%
	goto :end
)

if "%action%"=="info-env" (
	call %STELLA_COMMON%\common-virtual.bat :info_env %id%
	goto :end
)



goto :usage


REM ------------------------------------ INTERNAL FUNCTIONS -----------------------
:usage
	echo USAGE :
	echo %~n0 %ARGOPT_HELP_SYNTAX%

	echo ----------------
	echo List of commands
	echo	* virtual management :
	echo 		%~n0 create-env ^<env id#distrib id^> [-head] [-vmem=xxxx] [-vcpu=xx] : create a new environment from a generic box prebuilt with a specific distribution
	echo		%~n0 run-env ^<env id^> [-login] : manage environment
	echo		%~n0 stop-env destroy-env ^<env id^> : manage environment
	echo 		%~n0 create-box get-box ^<distrib id^> : manage generic boxes built with a specific distribution
	echo 		%~n0 list ^<box^|env^|distrib^>
goto :end



:end
echo ** END **
cd /D %_STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal
