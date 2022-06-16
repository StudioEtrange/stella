@if not "%~1"=="include" if not "%~1"=="chaining" if not "%~1"=="nothing" setlocal enableExtensions enableDelayedExpansion
@set _STELLA_LINK_CURRENT_FILE_DIR=%~dp0
@set _STELLA_LINK_CURRENT_FILE_DIR=%_STELLA_LINK_CURRENT_FILE_DIR:~0,-1%
@set STELLA_ROOT=%_STELLA_LINK_CURRENT_FILE_DIR%\..\..\..\..\stella
@set STELLA_DEP_FLAVOUR=DEV
@set STELLA_DEP_VERSION=LATEST

@echo off
@if not "%~1"=="chaining" set STELLA_APP_ROOT=%_STELLA_LINK_CURRENT_FILE_DIR%


if not "%~1"=="nothing" (
	if not "%~1"=="bootstrap" (
		if not exist "!STELLA_ROOT!\stella.bat" (
			if exist "!STELLA_ROOT!\..\stella-link.bat" (	
				echo ** Try to chain link stella from !STELLA_ROOT!\..
				call "!STELLA_ROOT!\..\stella-link.bat" chaining
			) else (
				echo ** WARNING Stella is missing -- bootstraping stella
				call "!_STELLA_LINK_CURRENT_FILE_DIR!\stella-link.bat" bootstrap
				@echo off
			)
		)
	)
)

if "%~1"=="include" (
	call "!STELLA_ROOT!\conf.bat"
	call !STELLA_COMMON!\common.bat :init_stella_env
	goto :eof
)

if "%~1"=="nothing" (
	goto :eof
)

if "%~1"=="chaining" (
	goto :eof
)

if "%~1"=="bootstrap" (
	cd /D "!_STELLA_LINK_CURRENT_FILE_DIR!"
	powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/StudioEtrange/stella/master/win/pool/stella-bridge.bat', 'stella-bridge.bat')"
	stella-bridge.bat bootstrap
	del /q stella-bridge.bat
	goto :eof
)


call "!STELLA_ROOT!\stella.bat" %*

@if not "%~1"=="include" @if not "%~1"=="chaining" if not "%~1"=="nothing" @endlocal

