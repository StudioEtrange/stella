@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0

call %~dp0\stella-link.bat include

:: arguments
set "params=domain:"foo env" action:"run install uninstall""
set "options=-f: -opt:"#default_val val1 val2 val3""
call %STELLA_API%argparse %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage



echo OPT1 = %-opt1%



REM --------------- FOO ----------------------------
if "%DOMAIN%"=="foo" (
	if "%ACTION%"=="run" (
		echo OPT = %-opt%
	)

)
if "%DOMAIN%"=="foo" goto :end

REM --------------- ENV ----------------------------
if "%DOMAIN%"=="env" (
	if "%ACTION%"=="install" (
		echo ** Install requirements
		call %STELLA_API%get_features
		
	)
	if "%ACTION%"=="uninstall" (
		call %STELLA_API%del_folder %STELLA_APP_WORK_ROOT%
	)

)
if "%DOMAIN%"=="env" goto :end


goto :eof




:usage
	echo USAGE :
	echo %~n0 %ARGOPT_HELP_SYNTAX%
	echo ----------------
	echo List of commands
	echo 	* foo management :
	echo 		foo run [-opt=^<string^>]
	echo 	* general management :
	echo		env install^|uninstall : deploy/undeploy this app
goto :eof



:end
@echo ** END **
@cd /D %STELLA_CURRENT_RUNNING_DIR%
@echo on
@endlocal