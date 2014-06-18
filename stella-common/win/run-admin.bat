:::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights
:: http://stackoverflow.com/questions/7044985/how-can-i-auto-elevate-my-batch-file-so-that-it-requests-from-uac-admin-rights/12264592#12264592
:: Pass command to execute as arg to this batch
:::::::::::::::::::::::::::::::::::::::::
@echo off

set "_arg=%*"

:check_privileges
	NET FILE 1>NUL 2>NUL
	if "%errorlevel%"=="0" (
		set HAVE_PRIVILEGES=1
	) else (
		set HAVE_PRIVILEGES=0
	)

	:: check if we have already tried but we missed privilege (to not infinity loop)
	if "%~1"=="###_FLAG_###" if "%HAVE_PRIVILEGES%"=="0" (
		ECHO ** ERROR Can not gain privileges
		goto :eof
	)
	:: we have privileges
	if "%HAVE_PRIVILEGES%"=="1" goto got_privileges
	:: we do not have privileges
	if "%HAVE_PRIVILEGES%"=="0" goto get_privileges


:get_privileges
	ECHO ** Invoking UAC for Privilege Escalation 
	setlocal DisableDelayedExpansion
	set "batchPath=%~0"
	setlocal EnableDelayedExpansion
	ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs" 
	ECHO UAC.ShellExecute "!batchPath!", "###_FLAG_### !_arg!", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs" 
	"%temp%\OEgetPrivileges.vbs"
	exit /B 

:got_privileges
	ECHO =============================
	ECHO Running Admin shell
	ECHO =============================
	setlocal & pushd .

	ECHO ** We have privileges
	set "_arg=%_arg:###_FLAG_###=%"
	
	REM echo %_arg%
	cmd /C %_arg%
	