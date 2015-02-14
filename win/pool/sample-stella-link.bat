
@echo off

if not exist %STELLA_ROOT%\stella.bat (
	echo ** WARNING Stella is missing
)

if "%~1"==":include" (
	call %*
	goto :eof
)
 if "%~1"==":nothing" (
 	call %*
	goto :eof
)

@setlocal enableExtensions enableDelayedExpansion


if not "%~1"==":include" if not "%~1"=="bootstrap" if not "%~1"==":nothing" (
		call !STELLA_ROOT!\stella.bat %*
		@echo off
)

if "%~1"=="bootstrap" (
	cd /D "!_STELLA_LINK_CURRENT_FILE_DIR!"
	powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/StudioEtrange/stella/master/win/pool/stella-bridge.bat', 'stella-bridge.bat')"
	stella-bridge.bat bootstrap
	del /q stella-bridge.bat
)

goto :eof

:include
	call "!STELLA_ROOT!\conf.bat"
	call !STELLA_COMMON!\common.bat :init_stella_env
goto :eof

:nothing
goto :eof


@echo on
if not "%~1"==":include" if not "%~1"==":nothing" (
	@endlocal
)
