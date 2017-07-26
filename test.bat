

set "r='^^http://(.*)/(.*)/$'"
echo %r%
set "str='http://google.fr/you/'"

for /F "tokens=*" %%V in ('powershell -command ^"^(Select-String -Pattern "%r%" -Input "%str%"^).matches.groups[1].value^"') do (
	set var=%%V
)
echo %var%



for /F "tokens=*" %%V in ('powershell -command ^"%str% ^| Select-String -Pattern "%r%"^"') do (
	set var2=%%V
)
echo %var2%


for /F "tokens=*" %%V in ('powershell -command ^"%str% ^| Select-String -AllMatches -Pattern "%r%" ^| ForEach-Object { $_.matches.Groups[2].Value }^"') do (
	set var3=%%V
)
echo %var3%

for /F "tokens=*" %%V in ('powershell -command ^"%str% ^| Select-String -Pattern "%r%" ^| ForEach { $_.Matches.Groups.Value } ^"') do (
	set var4=%%V
)
echo %var4%


REM pattern='^(([a-z]+)://)?((([^:\/]+)(:([^@\/]*))?@)?([^:\/?]*)(:([0-9]+))?)(\/[^?#]*)?(\?[^#]*)?(#.*)?$'
REM 	__stella_uri=${BASH_REMATCH[0]}
REM 	__stella_uri_schema=${BASH_REMATCH[2]}
REM 	__stella_uri_address=${BASH_REMATCH[3]}
REM 	__stella_uri_user=${BASH_REMATCH[5]}
REM 	__stella_uri_password=${BASH_REMATCH[7]}
REM 	__stella_uri_host=${BASH_REMATCH[8]}
REM 	__stella_uri_port=${BASH_REMATCH[10]}
REM 	__stella_uri_path=${BASH_REMATCH[11]}
REM 	__stella_uri_query=${BASH_REMATCH[12]}
REM 	__stella_uri_fragment=${BASH_REMATCH[13]}

REM [schema://][user[:password]@][host][:port][/path][?[arg1=val1]...][#fragment]
set "pattern='^^(([a-z]+)://)?((([^^:\/]+)(:([^^@\/]*))?@)?([^^:\/?]*)(:([0-9]+))?)(\/[^^?#]*)?(\?[^^#]*)?(#.*)?$'"

set "str='https://nomorgan:password@google.fr/foo/bar?a^=1^&b^=2#frag'"

for /F "tokens=*" %%V in ('powershell -command ^"%str% ^| Select-String -Pattern "%pattern%" ^| ForEach { $_.Matches.Groups.Value } ^"') do (
	set var5=%%V
)

for /F "tokens=*" %%V in ('powershell -command ^"%str% ^| Select-String -Pattern "%pattern%" ^| Get-Member ^| Format-List -Property * ^"') do (
	set var6=%%V
)

REM for /F "tokens=*" %%V in ('powershell -command ^"%str% ^| Select-String -Pattern "%pattern%" ^| ForEach { $_.Matches } ^"') do (
REM	set var6=%%V
REM )



REM for /F "tokens=*" %%V in ('powershell -command ^"[regex]$regexobj^="%pattern%" ^| Get-Member ^"') do (
REM	set var6=%%V
REM )

for /F "tokens=*" %%V in ('powershell -command ^"%str% ^| Select-String -Pattern "%pattern%" ^| Get-Member ^"') do (
	set var7=%%V
)

for /F "tokens=* delims=" %%V in ('powershell -command ^"%str% ^| Select-String -Pattern "%pattern%" ^| ForEach { $_.Matches.groups[10].value + $_.Matches.groups[12].value } ^"') do (
	set var8=%%V
)
