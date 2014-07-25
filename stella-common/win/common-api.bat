@echo off
call %*
goto :eof



:stella_api_proxy
	set "FUNC_NAME=%0"
	set "FUNC_NAME=%FUNC_NAME:*+=%"
	echo FUNCTION: %FUNC_NAME%

	for %%F in (%STELLA_API_COMMON_PUBLIC%) do (
		if "%%F"=="%FUNC_NAME%" (
			call %STELLA_COMMON%\common.bat :%FUNC_NAME% %*
			goto :eof
		)
	)

	for %%F in (%STELLA_API_APP_PUBLIC%) do (
		if "%%F"=="%FUNC_NAME%" (
			call %STELLA_COMMON%\common-app.bat :%FUNC_NAME% %*
			goto :eof
		)
	)

	for %%F in (%STELLA_API_TOOLS_PUBLIC%) do (
		echo %%F
		if "%%F"=="%FUNC_NAME%" (
			call %STELLA_COMMON%\common-tools.bat :%FUNC_NAME% %*
			goto :eof
		)
	)

	echo ** API ERROR : Function %FUNC_NAME% does not exist
	
goto :eof

:stella_api_list
	set "%~1=[ COMMON-API : %STELLA_API_COMMON_PUBLIC% ] [ TOOLS-API : %STELLA_API_TOOLS_PUBLIC% ] [ APP-API : %STELLA_API_APP_PUBLIC% ]"
goto :eof