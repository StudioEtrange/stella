@echo off
REM Usage :
REM stella.bat include
REM		OR call stella :include
REM stella.bat bootstrap [install path] --- install path is first fixed into link file (.-stella-link.bat)
REM		OR call stella :bootstrap [install path]
REM stella.bat <standard stella command>

set IS_STELLA_LINKED=FALSE
set STELLA_ROOT=


REM Check if APP is linked to STELLA -------------------------
if exist "%~dp0\.stella-link.bat" (
	call %~dp0\.stella-link.bat
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
	call :bootstrap
)
if "%~1"=="bootstrap" (
	call :bootstrap
)
goto :eof




REM Bootstrap/auto install mode ------------------
:bootstrap
	if "%IS_STELLA_LINKED%"=="TRUE" (
		echo ** This app is already linked to a STELLA installation located in !STELLA_ROOT!
		call !STELLA_ROOT!\tools.bat install default
		@echo off
	) else (

		REM Try to determine install path of STELLA
		if "%~2"=="" (
			if not "!STELLA_ROOT!"=="" (
				REM install STELLA into STELLA_ROOT, and linked to the app
				git clone https://bitbucket.org/StudioEtrange/lib-stella.git "!STELLA_ROOT!"
				> "%~dp0\.stella-link.bat" ECHO(set STELLA_ROOT=!STELLA_ROOT!
				call !STELLA_ROOT!\tools.bat install default
				@echo off
			) else (
				echo ** ERROR please specify an install path for STELLA
			)
		) else (
			REM install path is specified in arg #2
			if exist "%~2\stella.bat" (
				REM STELLA already installed, update it
				pushd
				cd /D "%~2"
				git pull
				popd
				call !STELLA_ROOT!\tools.bat install default
				@echo off
			) else (
				REM install STELLA into arg #2, and linked to the app
				git clone https://bitbucket.org/StudioEtrange/lib-stella.git "%~2"
				> "%~dp0\.stella-link.bat" ECHO(set STELLA_ROOT=%~2
				call !STELLA_ROOT!\tools.bat install default
				@echo off
			)
		)
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


