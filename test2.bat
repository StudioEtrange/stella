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
	set "_var_prefix=%~1"
	set "_regex=%~2"
	set "_string=%~3"

	for /F "tokens=1,* delims=#" %%I in ('powershell -command ^"^'!_string!^' ^| Select-String -Pattern "^'!_regex!^'"  ^| ForEach { $_.Matches[0].Groups } ^| ForEach {$i^=0} { [string]$i + ^'#^' + $_.Value^; $i++ ^; } ^"') do (
		set "v=!_var_prefix!_%%I"
		set "!v!=%%J"
	)
goto :eof



:: The function creates global variables with the parsed results.
:: ARG1 is the prefix name which will contains result
:: ARG2 is the uri to parse
:: parsed regex :
::		 [schema://][user[:password]@][host][:port][/path][?[arg1=val1]...][#fragment]
:: result :
::		prefix_0 will contain the whole uri matched
::		prefix_2 will contain schema
::		prefix_3 will contain address
::		prefix_5 will contain user
::		prefix_7 will contain password
::		prefix_8 will contain host
::		prefix_10 will contain port
::		prefix_11 will contain path
::		prefix_12 will contain query
::		prefix_13 will contain fragment
:uri_parse
	set "_var_prefix=%~1"
	set "_uri=%~2"
	set "_uri_pattern=^(([a-z]+)://)?((([^:\/]+)(:([^@\/]*))?@)?([^:\/?]*)(:([0-9]+))?)(\/[^?#]*)?(\?[^#]*)?(#.*)?$"

	call :match_regex "!_var_prefix!" "!_uri_pattern!" "!_uri!"

goto :eof