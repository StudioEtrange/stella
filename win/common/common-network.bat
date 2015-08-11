@echo off
call %*
goto :eof

REM --------------- PROXY INIT ----------------


:init_proxy
	if exist "%STELLA_ROOT%\.stella-env" (
		call %STELLA_COMMON%\common.bat :get_key "%STELLA_ROOT%\.stella-env" "STELLA_PROXY" "ACTIVE" "PREFIX"
	)

	if not "!STELLA_PROXY_ACTIVE!"=="" (
		call %STELLA_COMMON%\common.bat :get_key "%STELLA_ROOT%\.stella-env" "STELLA_PROXY_!STELLA_PROXY_ACTIVE!" "PROXY_HOST" "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%STELLA_ROOT%\.stella-env" "STELLA_PROXY_!STELLA_PROXY_ACTIVE!" "PROXY_PORT" "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%STELLA_ROOT%\.stella-env" "STELLA_PROXY_!STELLA_PROXY_ACTIVE!" "PROXY_USER" "PREFIX"
		call %STELLA_COMMON%\common.bat :get_key "%STELLA_ROOT%\.stella-env" "STELLA_PROXY_!STELLA_PROXY_ACTIVE!" "PROXY_PASS" "PREFIX"


		for %%I in (STELLA_PROXY_!STELLA_PROXY_ACTIVE!_PROXY_HOST) do set "STELLA_PROXY_HOST=!%%I!"
		for %%I in (STELLA_PROXY_!STELLA_PROXY_ACTIVE!_PROXY_PORT) do set "STELLA_PROXY_PORT=!%%I!"
		
		for %%I in (STELLA_PROXY_!STELLA_PROXY_ACTIVE!_PROXY_USER) do set "STELLA_PROXY_USER=!%%I!"
		
		if "!STELLA_PROXY_USER!"=="" (

			set "STELLA_HTTP_PROXY=http://!STELLA_PROXY_HOST!:!STELLA_PROXY_PORT!"
			set "STELLA_HTTPS_PROXY=http://!STELLA_PROXY_HOST!:!STELLA_PROXY_PORT!"
		) else (
			for %%I in (STELLA_PROXY_!STELLA_PROXY_ACTIVE!_PROXY_PASS) do set "STELLA_PROXY_PASS=!%%I!"

			set "STELLA_HTTP_PROXY=http://!STELLA_PROXY_USER!:!STELLA_PROXY_PASS!@!STELLA_PROXY_HOST!:!STELLA_PROXY_PORT!"
			set "STELLA_HTTPS_PROXY=http://!STELLA_PROXY_USER!:!STELLA_PROXY_PASS!@!STELLA_PROXY_HOST!:!STELLA_PROXY_PORT!"
		)

		set "http_proxy=!STELLA_HTTP_PROXY!"
		set "https_proxy=!STELLA_HTTPS_PROXY!"

		echo STELLA Proxy Active : !STELLA_PROXY_ACTIVE! [ !STELLA_PROXY_HOST!:!STELLA_PROXY_PORT! ]

		call :proxy_override
	)

	
goto :eof

REM ---------------- SHIM FUNCTIONS -----------------------------


:proxy_override

REM curl
if "!STELLA_PROXY_USER!"=="" set "CURL=!CURL! -x !STELLA_PROXY_HOST!:!STELLA_PROXY_PORT!"
if not "!STELLA_PROXY_USER!"=="" set "CURL=!CURL! -x !STELLA_PROXY_HOST!:!STELLA_PROXY_PORT! --proxy-user !STELLA_PROXY_USER!:!STELLA_PROXY_PASS!"

REM wget
REM use of http_proxy env var

REM hg
set "HG=!HG! --config http_proxy.host=!STELLA_PROXY_HOST!:!STELLA_PROXY_PORT! --config http_proxy.user=!STELLA_PROXY_USER! --config http_proxy.passwd=!STELLA_PROXY_PASS!"

REM git
REM use of http_proxy env var

REM mvn
if "!STELLA_PROXY_USER!"=="" set "MVN=!MVN! -DproxyActive=true  -DproxyId=!STELLA_PROXY_ACTIVE! -DproxyHost=!STELLA_PROXY_HOST! -DproxyPort=!STELLA_PROXY_PORT!"
if not "!STELLA_PROXY_USER!"=="" set "MVN=!MVN! -DproxyActive=true  -DproxyId=!STELLA_PROXY_ACTIVE! -DproxyHost=!STELLA_PROXY_HOST! -DproxyPort=!STELLA_PROXY_PORT! -DproxyUsername=!STELLA_PROXY_USER! -DproxyPassword=!STELLA_PROXY_PASS!"

REM npm
REM	command npm --https-proxy="$HTTPS_PROXY" --http-proxy="$HTTP_PROXY" "$@"	
	
goto :eof

REM -------------------- FUNCTIONS-----------------

:register_proxy
	set "_name=%~1"
	set "_host=%~2"
	set "_port=%~3"
	set "_user=%~4"
	set "_pass=%~5"

	call %STELLA_COMMON%\common.bat :add_key "%STELLA_ROOT%\.stella-env" "STELLA_PROXY_%_name%" "PROXY_HOST" "%_host%"
	call %STELLA_COMMON%\common.bat :add_key "%STELLA_ROOT%\.stella-env" "STELLA_PROXY_%_name%" "PROXY_PORT" "%_port%"
	call %STELLA_COMMON%\common.bat :add_key "%STELLA_ROOT%\.stella-env" "STELLA_PROXY_%_name%" "PROXY_USER" "%_user%"
	call %STELLA_COMMON%\common.bat :add_key "%STELLA_ROOT%\.stella-env" "STELLA_PROXY_%_name%" "PROXY_PASS" "%_pass%"
goto:eof

:enable_proxy
	set "_name=%~1"
	call %STELLA_COMMON%\common.bat :add_key "%STELLA_ROOT%\.stella-env" "STELLA_PROXY" "ACTIVE" "%_name%"
	call :init_proxy
goto:eof

:disable_proxy
	call :enable_proxy
	echo STELLA Proxy Disabled
goto:eof
