@echo off

for /F "tokens=1 delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v7.1" /v InstallationFolder') do (
	set "_tp=%%i"
	set "_path=%_tp:InstallationFolder=%"
	set "_path=%_path:REGZ=%"

	call %STELLA_COMMON%\common.bat :trim "_path" "!_path!"
)

echo %a%

