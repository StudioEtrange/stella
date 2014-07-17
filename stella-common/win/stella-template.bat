@setlocal enableExtensions enableDelayedExpansion
@echo off
REM Usage :
REM stella.bat include
REM		OR call stella :include
REM stella.bat bootstrap [install path] --- absolute or relative to app path where to install STELLA the system. If not provided, use setted value in link file (.-stella-link.bat) or in ..\lib-stella by default
REM		OR call stella :bootstrap [install path]
REM stella.bat <standard stella command>

set _CURRENT_FILE_DIR=%~dp0
set _CURRENT_RUNNING_DIR=%cd%

set IS_STELLA_LINKED=FALSE
set STELLA_ROOT=

set APP_ROOT=%_CURRENT_FILE_DIR%

REM Check if APP is linked to STELLA -------------------------
if exist "%APP_ROOT%\.stella-link.bat" (
	call %APP_ROOT%\.stella-link.bat
	if not "!STELLA_ROOT!"=="" (
		if exist "!STELLA_ROOT!\stella.bat" (
			set IS_STELLA_LINKED=TRUE
		)
	)
)


REM Standard mode ------------------
if not "%~1"==":include" if not "%~1"=="include" if not "%~1"==":bootstrap" if not "%~1"=="bootstrap" (
	if "%IS_STELLA_LINKED%"=="TRUE" (
		call "!STELLA_ROOT!\stella.bat %*"
		@echo off
	) else (
		echo ** ERROR This app is not linked to a STELLA installation path
	)
)

if "%~1"==":include" (
	call :include
)
if "%~1"=="include" (
	call :include
)

if "%~1"==":bootstrap" (
	call :bootstrap %~2
)
if "%~1"=="bootstrap" (
	call :bootstrap %~2
)
goto :eof




REM Bootstrap/auto install mode ------------------
:bootstrap
	set "_provided_path=%~1"
	if "%IS_STELLA_LINKED%"=="TRUE" (
		echo ** This app is already linked to a STELLA installation located in !STELLA_ROOT!
		call !STELLA_ROOT!\tools.bat install default
		@echo off
	) else (

		REM Try to determine install path of STELLA
		if "%_provided_path%"=="" (
			if not "!STELLA_ROOT!"=="" (
				REM install STELLA into STELLA_ROOT, and linked to the app
				call %STELLA_COMMON%\common.bat :rel_to_abs_path "_stella_install_path" "!STELLA_ROOT!" "%APP_ROOT%"
				> "%APP_ROOT%\.stella-link.bat" ECHO(set STELLA_ROOT=!STELLA_ROOT!			
			) else (
				REM install STELLA into default path, and linked to the app
				call %STELLA_COMMON%\common.bat :rel_to_abs_path "_stella_install_path" "..\lib-stella" "%APP_ROOT%"
				> "%APP_ROOT%\.stella-link.bat" ECHO(set STELLA_ROOT=..\lib-stella
			)
			git clone https://bitbucket.org/StudioEtrange/lib-stella.git "!_stella_install_path!"
		) else (

			REM install STELLA into ARG#2, and linked to the app
			call %STELLA_COMMON%\common.bat :rel_to_abs_path "_stella_install_path" "%_provided_path%" "%APP_ROOT%"
			if exist "!_stella_install_path!\stella.bat" (
				REM STELLA already installed, update it
				pushd
				cd /D "!_stella_install_path!"
				git pull
				popd
			) else (
				git clone https://bitbucket.org/StudioEtrange/lib-stella.git "!_stella_install_path!"
			)
			> "%APP_ROOT%\.stella-link.bat" ECHO(set STELLA_ROOT=%_provided_path%
		)
		call !_stella_install_path!\tools.bat install default
		@echo off
	)
goto :eof


REM Include mode ------------------
:include
	if "%IS_STELLA_LINKED%"=="TRUE" (
		call "!STELLA_ROOT!\include.bat"
	) else (
		echo ** ERROR This app is not linked to a STELLA install path
	)
goto :eof

@echo on
@endlocal
