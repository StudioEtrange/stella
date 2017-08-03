@echo off
call %*
goto :eof


:: Use regex and return match expression
:: ARG1 is the prefix name which contains all result
::			prefix_0 will contain the whole expression matched, prefix_1 matched group 1, prefix_2 matched group 2 ...
:: ARG2 is the regex
:: ARG3 is the string to parse
:: NOTE : for ARG2 and ARG3 do NOT escape characters
:: NOTE : compatibilty needs powershell 2.0
:match_regex
	set "_var_prefix_match_regex=%~1"
	set "_regex=%~2"
	set "_string=%~3"

	for /F "tokens=1,* delims=#" %%I in ('powershell -command ^"^'!_string!^' ^| Select-String -AllMatches -Pattern ^'!_regex!^'  ^| ForEach { $_.Matches.Groups } ^| ForEach {$i^=0} { [string]$i + ^'#^' + $_.Value^; $i++ ^; } ^"') do (
		set "v=!_var_prefix_match_regex!_%%I"
		set "!v!=%%J"
	)
goto :eof



:: The function creates global variables with the parsed results.
:: ARG1 is the prefix name which will contains result
:: ARG2 is the uri to parse
:: parsed regex :
::		 [schema://][user[:password]@][host][:port][/path][?[arg1=val1]...][#fragment]
:: result :
::		prefix_URI will contain the whole uri matched
::		prefix_SCHEMA will contain schema
::		prefix_ADDRESS will contain address
::		prefix_USER will contain user
::		prefix_PASSWORD will contain password
::		prefix_HOST will contain host
::		prefix_PORT will contain port
::		prefix_PATH will contain path
::		prefix_QUERY will contain query
::		prefix_FRAGMENT will contain fragment
::		prefix_arg1 will contain val1
:uri_parse
	set "_var_prefix_uri_parse=%~1"
	set "_uri=%~2"
	set "_uri_pattern=^(([a-z]+)://)?((([^:\/]+)(:([^@\/]*))?@)?([^:\/?]*)(:([0-9]+))?)(\/[^?#]*)?(\?[^#]*)?(#.*)?$"

	call :match_regex "_tmp_prefix" "!_uri_pattern!" "!_uri!"

	:: affect result
	set "v=!_var_prefix_uri_parse!_URI"
	set "!v!=!_tmp_prefix_0!"
	set "v=!_var_prefix_uri_parse!_SCHEMA"
	set "!v!=!_tmp_prefix_2!"
	set "v=!_var_prefix_uri_parse!_ADDRESS"
	set "!v!=!_tmp_prefix_3!"
	set "v=!_var_prefix_uri_parse!_USER"
	set "!v!=!_tmp_prefix_5!"
	set "v=!_var_prefix_uri_parse!_PASSWORD"
	set "!v!=!_tmp_prefix_7!"
	set "v=!_var_prefix_uri_parse!_HOST"
	set "!v!=!_tmp_prefix_8!"
	set "v=!_var_prefix_uri_parse!_PORT"
	set "!v!=!_tmp_prefix_10!"
	set "v=!_var_prefix_uri_parse!_PATH"
	set "!v!=!_tmp_prefix_11!"
	set "v=!_var_prefix_uri_parse!_QUERY"
	set "!v!=!_tmp_prefix_12!"
	set "v=!_var_prefix_uri_parse!_FRAGMENT"
	set "!v!=!_tmp_prefix_13!"

	:: query parsing
	set "_query=!_tmp_prefix_12!"
	set "_uri_query_pattern=[?&]+([^= ]+)(=([^&]*))?"
	if not "!_query!"=="" (
		set "_i=1"
		:loop_uri_parse

			call :match_regex "_tmp_prefix_query" "!_uri_query_pattern!" "!_query!"
			set "_arg=_tmp_prefix_query_!i!"
			set /a "_i+=2"
			set "_val=_tmp_prefix_query_!i!"
			if not "!%_arg%!"=="" (
				set "_arg_name=!_var_prefix_uri_parse!_!%_arg%!"
				if "!%_val%!"=="" (
					set "!_arg_name!="
				) else (
					set "!_arg_name!=!%_val%!"
				)
				goto :loop_uri_parse
			)
	)



goto :eof
