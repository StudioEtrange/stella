REM @set _STELLA_LINK_CURRENT_FILE_DIR=%~dp0
REM @set _STELLA_LINK_CURRENT_FILE_DIR=%_STELLA_LINK_CURRENT_FILE_DIR:~0,-1%
REM @set STELLA_ROOT=%_STELLA_LINK_CURRENT_FILE_DIR%\..\lib-stella
REM @set STELLA_APP_ROOT=%_STELLA_LINK_CURRENT_FILE_DIR%

if "%_STELLA_CURRENT_RUNNING_DIR%"=="" set _STELLA_CURRENT_RUNNING_DIR=%cd%

@echo off
if not "%~1"==":include" (
	@setlocal enableExtensions enableDelayedExpansion
) else (
	call %*
	goto :eof
)

:include

if not exist %STELLA_ROOT%\stella.bat (
	echo "** WARNING Stella is missing"
)

if not "%~1"==":include" (
		call !STELLA_ROOT!\stella.bat %*
		@echo off
)

if "%~1"==":include" (
	call "!STELLA_ROOT!\conf.bat"
	call !STELLA_COMMON!\common.bat :init_stella_env
)

goto :eof



@echo on
if not "%~1"==":include" (
	@endlocal
)
