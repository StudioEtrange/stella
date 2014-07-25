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
set "params=action:"create-env run-env stop-env destroy-env info-env list-env create-box get-box list-box destroy-box list-distrib""
set "options=-distrib:"%DISTRIB_LIST%" -f: -envname:_ANY_ -envcpu:_ANY_ -envmem:_ANY_ -vmgui: -l:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

set FORCE=%-f%

:: setting env
call %STELLA_COMMON%\common.bat :init_stella_env


::other command line arguments
set VM_ENV_NAME=%-envname%
set ENV_CPU=%-envcpu%
set ENV_MEM=%-envmem%
if "%-vmgui%"=="" set VM_HEADLESS=false
if "%ENV_CPU%"=="" set ENV_CPU=1
if "%ENV_MEM%"=="" set ENV_MEM=384
set DISTRIB=%-distrib%

if not "%DISTRIB%"=="" (
	call :_set_matrix %DISTRIB%
)


REM --------------- BOX MANAGEMENT -------------------------
if "%action%"=="create-box" (
	call :_virtual_init_folder
	call %STELLA_COMMON%\common-virtual.bat :create_box
	goto :end
)

if "%action%"=="get-box" (
	call %STELLA_COMMON%\common-virtual.bat :get_box
	goto :end
)

if "%action%"=="list-box" (
	call %STELLA_COMMON%\common-virtual.bat :list_box
	goto :end
)


REM --------------- ENV MANAGEMENT -------------------------

if "%action%"=="list-distrib" (
	call %STELLA_COMMON%\common-virtual.bat :list_distrib "VAR"
	echo !VAR!
	goto :end
)

if "%action%"=="create-env" (
	call :_virtual_init_folder
	call %STELLA_COMMON%\common-virtual.bat :create_env
	goto :end
)

if "%action%"=="list-env" (
	call %STELLA_COMMON%\common-virtual.bat :list_env
	goto :end
)

if "%action%"=="destroy-env" (
	call :_virtual_init_folder
	call %STELLA_COMMON%\common-virtual.bat :destroy_env
	goto :end
)

if "%action%"=="run-env" (
	call :_virtual_init_folder
	call %STELLA_COMMON%\common-virtual.bat :run_env
	goto :end
)

if "%action%"=="stop-env" (
	call :_virtual_init_folder
	call %STELLA_COMMON%\common-virtual.bat :stop_env
	goto :end
)

if "%action%"=="info-env" (
	call :_virtual_init_folder
	call %STELLA_COMMON%\common-virtual.bat :info_env
	goto :end
)



goto :usage


REM ------------------------------------ INTERNAL FUNCTIONS -----------------------
:usage
   echo USAGE :
   echo %~n0 %ARGOPT_HELP_SYNTAX%
goto :end

:_virtual_init_folder
	if not exist "%VIRTUAL_WORK_ROOT%" mkdir "%VIRTUAL_WORK_ROOT%"
	if not exist "%VIRTUAL_ENV_ROOT%" mkdir "%VIRTUAL_ENV_ROOT%"
	if not exist "%VIRTUAL_TEMPLATE_ROOT%" mkdir "%VIRTUAL_TEMPLATE_ROOT%"
goto :eof


:end
echo ** END **
cd /D %_CURRENT_RUNNING_DIR%
@echo on
@endlocal
