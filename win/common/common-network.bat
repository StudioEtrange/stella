@echo off
call %*
goto :eof

REM --------------- PROXY INIT ----------------

:init_proxy
	call :reset_proxy_values
	call :read_proxy_values

	if not "!STELLA_PROXY_ACTIVE!"=="" (
		:: do not set system proxy values if we uses values from system
		if not "!STELLA_PROXY_ACTIVE!"=="FROM_SYSTEM" (
			call :set_system_proxy_values
		)
		call :proxy_override
	)

goto :eof


:read_proxy_values

	set "use_system_proxy_setting=OFF"

	if exist "!STELLA_ENV_FILE!" (
		call %STELLA_COMMON%\common.bat :get_key "!STELLA_ENV_FILE!" "STELLA_PROXY" "ACTIVE" "PREFIX"

		if not "!STELLA_PROXY_ACTIVE!"=="" (
			call %STELLA_COMMON%\common.bat :get_key "!STELLA_ENV_FILE!" "STELLA_PROXY_!STELLA_PROXY_ACTIVE!" "PROXY_HOST" "PREFIX"
			call %STELLA_COMMON%\common.bat :get_key "!STELLA_ENV_FILE!" "STELLA_PROXY_!STELLA_PROXY_ACTIVE!" "PROXY_PORT" "PREFIX"
			call %STELLA_COMMON%\common.bat :get_key "!STELLA_ENV_FILE!" "STELLA_PROXY_!STELLA_PROXY_ACTIVE!" "PROXY_USER" "PREFIX"
			call %STELLA_COMMON%\common.bat :get_key "!STELLA_ENV_FILE!" "STELLA_PROXY_!STELLA_PROXY_ACTIVE!" "PROXY_PASS" "PREFIX"
			call %STELLA_COMMON%\common.bat :get_key "!STELLA_ENV_FILE!" "STELLA_PROXY_!STELLA_PROXY_ACTIVE!" "PROXY_SCHEMA" "PREFIX"

			:: read NO_PROXY values from env file
			call %STELLA_COMMON%\common.bat :get_key "!STELLA_ENV_FILE!" "STELLA_PROXY" "NO_PROXY" "PREFIX"
			if "!STELLA_PROXY_NO_PROXY!"=="" (
				set "STELLA_NO_PROXY=!STELLA_DEFAULT_NO_PROXY!"
			) else (
				if "!STELLA_DEFAULT_NO_PROXY!"=="" (
					set "STELLA_NO_PROXY=!STELLA_PROXY_NO_PROXY!"
				) else (
					set "STELLA_NO_PROXY=!STELLA_DEFAULT_NO_PROXY!,!STELLA_PROXY_NO_PROXY!"
				)
			)

			for %%I in (STELLA_PROXY_!STELLA_PROXY_ACTIVE!_PROXY_HOST) do set "STELLA_PROXY_HOST=!%%I!"
			for %%I in (STELLA_PROXY_!STELLA_PROXY_ACTIVE!_PROXY_PORT) do set "STELLA_PROXY_PORT=!%%I!"
			for %%I in (STELLA_PROXY_!STELLA_PROXY_ACTIVE!_PROXY_SCHEMA) do set "STELLA_PROXY_SCHEMA=!%%I!"
			if "!STELLA_PROXY_SCHEMA!"=="" (
				set "STELLA_PROXY_SCHEMA=http"
			)

			for %%I in (STELLA_PROXY_!STELLA_PROXY_ACTIVE!_PROXY_USER) do set "STELLA_PROXY_USER=!%%I!"
			if "!STELLA_PROXY_USER!"=="" (
				if "!STELLA_PROXY_PORT!"=="" (
					set "STELLA_HTTP_PROXY=!STELLA_PROXY_SCHEMA!://!STELLA_PROXY_HOST!"
					set "STELLA_HTTPS_PROXY=!STELLA_PROXY_SCHEMA!://!STELLA_PROXY_HOST!"
				) else (
					set "STELLA_HTTP_PROXY=!STELLA_PROXY_SCHEMA!://!STELLA_PROXY_HOST!:!STELLA_PROXY_PORT!"
					set "STELLA_HTTPS_PROXY=!STELLA_PROXY_SCHEMA!://!STELLA_PROXY_HOST!:!STELLA_PROXY_PORT!"
				)
			) else (
				for %%I in (STELLA_PROXY_!STELLA_PROXY_ACTIVE!_PROXY_PASS) do set "STELLA_PROXY_PASS=!%%I!"
				if "!STELLA_PROXY_PORT!"=="" (
					set "STELLA_HTTP_PROXY=!STELLA_PROXY_SCHEMA!://!STELLA_PROXY_USER!:!STELLA_PROXY_PASS!@!STELLA_PROXY_HOST!"
					set "STELLA_HTTPS_PROXY=!STELLA_PROXY_SCHEMA!://!STELLA_PROXY_USER!:!STELLA_PROXY_PASS!@!STELLA_PROXY_HOST!"
				) else (
					set "STELLA_HTTP_PROXY=!STELLA_PROXY_SCHEMA!://!STELLA_PROXY_USER!:!STELLA_PROXY_PASS!@!STELLA_PROXY_HOST!:!STELLA_PROXY_PORT!"
					set "STELLA_HTTPS_PROXY=!STELLA_PROXY_SCHEMA!://!STELLA_PROXY_USER!:!STELLA_PROXY_PASS!@!STELLA_PROXY_HOST!:!STELLA_PROXY_PORT!"
				)
			)
			
		) else (
			set "use_system_proxy_setting=ON"
		)
	) else (
		set "use_system_proxy_setting=ON"
	)

	if "!use_system_proxy_setting!"=="ON" (
		call :read_system_proxy_values
	)

goto :eof

REM reset stella proxy values
:reset_proxy_values
	set STELLA_PROXY_ACTIVE=
	set STELLA_PROXY_HOST=
	set STELLA_PROXY_SCHEMA=
	set STELLA_PROXY_USER=
	set STELLA_PROXY_PASS=
	set STELLA_HTTP_PROXY=
	set STELLA_HTTPS_PROXY=
	set STELLA_PROXY_NO_PROXY=
	set STELLA_NO_PROXY=
goto :eof

:read_system_proxy_values


	if "!HTTP_PROXY!"=="" (
		set "STELLA_HTTP_PROXY=!http_proxy!"
	) else (
		set "STELLA_HTTP_PROXY=!HTTP_PROXY!"
	)
	if "!HTTPS_PROXY!"=="" (
		set "STELLA_HTTPS_PROXY=!https_proxy!"
	) else (
		set "STELLA_HTTPS_PROXY=!HTTPS_PROXY!"
	)
	if "!STELLA_NO_PROXY!"=="" (
		set "STELLA_NO_PROXY=!no_proxy!"
	) else (
		set "STELLA_NO_PROXY=!NO_PROXY!"
	)

	if not "!STELLA_HTTP_PROXY!"=="" (
		set "STELLA_PROXY_ACTIVE=FROM_SYSTEM"

		call %STELLA_COMMON%\common.bat :uri_parse "parseproxy" "!STELLA_HTTP_PROXY!"
		set "STELLA_PROXY_SCHEMA=!parseproxy_SCHEMA!"
		set "STELLA_PROXY_USER=!parseproxy_USER!"
		set "STELLA_PROXY_PASS=!parseproxy_PASSWORD!"
		set "STELLA_PROXY_HOST=!parseproxy_HOST!"
		set "STELLA_PROXY_PORT=!parseproxy_PORT!"
	)
goto :eof


:set_system_proxy_values
	:: override already existing system proxy env var only if stella proxy is active
	if not "!STELLA_PROXY_ACTIVE!"=="" (
		set "http_proxy=!STELLA_HTTP_PROXY!"
		set "HTTP_PROXY=!STELLA_HTTP_PROXY!"
		set "https_proxy=!STELLA_HTTPS_PROXY!"
		set "HTTPS_PROXY=!STELLA_HTTPS_PROXY!"

		echo STELLA HTTP Proxy=!STELLA_HTTP_PROXY! STELLA HTTPS Proxy=!STELLA_HTTPS_PROXY!
		if not "!STELLA_NO_PROXY!"=="" (
			set "no_proxy=!STELLA_NO_PROXY!"
			set "NO_PROXY=!STELLA_NO_PROXY!"

			REM echo STELLA NO Proxy : !STELLA_NO_PROXY!
		)
	)
goto :eof


:show_current_proxy_values
	echo ** Current active registered proxy : !STELLA_PROXY_ACTIVE!
	echo ** Current env variable for http proxy :
	echo http_proxy=!http_proxy!
	echo HTTP_PROXY=!HTTP_PROXY!
	echo https_proxy=!https_proxy!
	echo HTTPS_PROXY=!HTTPS_PROXY!
	echo no_proxy=!no_proxy!
	echo NO_PROXY=!NO_PROXY!
goto :eof

:reset_system_proxy_values
	set http_proxy=
	set HTTP_PROXY=
	set https_proxy=
	set HTTPS_PROXY=
	set	no_proxy=
	set NO_PROXY=
goto :eof

REM ---------------- SHIM FUNCTIONS -----------------------------


:proxy_override

REM curl
if "!STELLA_PROXY_USER!"=="" set "CURL=!CURL! -x !STELLA_PROXY_HOST!:!STELLA_PROXY_PORT!"
if not "!STELLA_PROXY_USER!"=="" set "CURL=!CURL! -x !STELLA_PROXY_HOST!:!STELLA_PROXY_PORT! --proxy-user !STELLA_PROXY_USER!:!STELLA_PROXY_PASS!"

REM wget
REM wget use itself http_proxy env var

REM hg
set "HG=!HG! --config http_proxy.host=!STELLA_PROXY_HOST!:!STELLA_PROXY_PORT! --config http_proxy.user=!STELLA_PROXY_USER! --config http_proxy.passwd=!STELLA_PROXY_PASS!"

REM git
REM git use ifselt of http_proxy env var
REM configuration file .gitconfig in home directory override http_proxy env

REM mvn
set "_temp=!STELLA_NO_PROXY:,=|!"
if "!STELLA_PROXY_USER!"=="" set "MVN=!MVN! -DproxyActive=true  -DproxyId=!STELLA_PROXY_ACTIVE! -DproxyHost=!STELLA_PROXY_HOST! -DproxyPort=!STELLA_PROXY_PORT! -Dhttp.nonProxyHosts="!_temp!""
if not "!STELLA_PROXY_USER!"=="" set "MVN=!MVN! -DproxyActive=true  -DproxyId=!STELLA_PROXY_ACTIVE! -DproxyHost=!STELLA_PROXY_HOST! -DproxyPort=!STELLA_PROXY_PORT! -DproxyUsername=!STELLA_PROXY_USER! -DproxyPassword=!STELLA_PROXY_PASS! -Dhttp.nonProxyHosts=!_temp!"

REM npm
REM	command npm --https-proxy="$HTTPS_PROXY" --http-proxy="$HTTP_PROXY" "$@"

goto :eof

REM -------------------- FUNCTIONS-----------------

:register_proxy
	set "_name=%~1"
	set "_uri=%~2"

	call %STELLA_COMMON%\common.bat :uri_parse "parseproxy" "!_uri!"

	if "!parseproxy_SCHEMA!"=="" (
		set "parseproxy_SCHEMA=http"
	)

	call %STELLA_COMMON%\common.bat :add_key "!STELLA_ENV_FILE!" "STELLA_PROXY_%_name%" "PROXY_HOST" "!parseproxy_HOST!"
	call %STELLA_COMMON%\common.bat :add_key "!STELLA_ENV_FILE!" "STELLA_PROXY_%_name%" "PROXY_PORT" "!parseproxy_PORT!"
	call %STELLA_COMMON%\common.bat :add_key "!STELLA_ENV_FILE!" "STELLA_PROXY_%_name%" "PROXY_USER" "!parseproxy_USER!"
	call %STELLA_COMMON%\common.bat :add_key "!STELLA_ENV_FILE!" "STELLA_PROXY_%_name%" "PROXY_PASS" "!parseproxy_PASSWORD!"
	call %STELLA_COMMON%\common.bat :add_key "!STELLA_ENV_FILE!" "STELLA_PROXY_%_name%" "PROXY_SCHEMA" "!parseproxy_SCHEMA!"
goto:eof

:enable_proxy
	set "_name=%~1"
	call %STELLA_COMMON%\common.bat :add_key "!STELLA_ENV_FILE!" "STELLA_PROXY" "ACTIVE" "%_name%"
	call :init_proxy
goto:eof

:disable_proxy
	call :enable_proxy
	call :reset_proxy_values
	call :reset_system_proxy_values

	echo STELLA Proxy Disabled
goto:eof



:: no_proxy is read from conf file only if a stella proxy is active
:register_no_proxy
	set "_uri=%~1"
	
	call %STELLA_COMMON%\common.bat :get_key "!STELLA_ENV_FILE!" "STELLA_PROXY" "NO_PROXY" "PREFIX"

	call %STELLA_COMMON%\common.bat :uri_parse "parseproxy" "!_uri!"

	set "_exist="
	if not "!STELLA_PROXY_NO_PROXY!"=="" set "STELLA_PROXY_NO_PROXY=!STELLA_PROXY_NO_PROXY:,= !"
	for %%p in (!STELLA_PROXY_NO_PROXY!) do (
		if "%%p"=="!parseproxy_HOST!" (
			set "_exist=1"
		)
	)

	if "!_exist!"=="" (
		if "!STELLA_PROXY_NO_PROXY!"== "" (
			set "STELLA_PROXY_NO_PROXY=!parseproxy_HOST!"
		) else (
			set "STELLA_PROXY_NO_PROXY=!STELLA_PROXY_NO_PROXY! !parseproxy_HOST!"
		)

		call %STELLA_COMMON%\common.bat :trim "STELLA_PROXY_NO_PROXY" "!STELLA_PROXY_NO_PROXY!"
		set "STELLA_PROXY_NO_PROXY=!STELLA_PROXY_NO_PROXY: =,!"
		call %STELLA_COMMON%\common.bat :add_key "!STELLA_ENV_FILE!" "STELLA_PROXY" "NO_PROXY" "!STELLA_PROXY_NO_PROXY!"
		call :init_proxy
	)
goto:eof


:: only temporary no proxy
:: will be reseted each time proxy values are read from env file
:no_proxy_for
	set "_uri=%~1"

	call %STELLA_COMMON%\common.bat :uri_parse "parseproxy" "!_uri!"


	set "_exist="
	set "_tmp_no_proxy=!STELLA_NO_PROXY:,= !"

	for %%p in (!_tmp_no_proxy!) do (
		if "%%p"=="!parseproxy_HOST!" (
			set "_exist=1"
		)
	)

	if "!_exist!"=="" (
		echo STELLA Proxy : temp proxy bypass for !parseproxy_HOST!
		if "!STELLA_NO_PROXY!"== "" (
			set "STELLA_NO_PROXY=!parseproxy_HOST!"
		) else (
			set "STELLA_NO_PROXY=!STELLA_NO_PROXY!,!parseproxy_HOST!"
		)
		call :set_system_proxy_values
	)
goto :eof