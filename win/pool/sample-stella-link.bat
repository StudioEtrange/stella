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
