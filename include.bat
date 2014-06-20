if "%APP_ROOT%"=="" (
	echo ** ERROR : please specify your APP_ROOT variable
	exit /B 0
)
call %~dp0\conf.bat