@echo off
call %*
goto :eof



:api_proxy
	set "FUNC_NAME=%0"
	set "FUNC_NAME=%FUNC_NAME:*+=%"

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

	for %%F in (%STELLA_API_FEATURE_PUBLIC%) do (
		if "%%F"=="%FUNC_NAME%" (
			call %STELLA_COMMON%\common-feature.bat :%FUNC_NAME% %*
			goto :eof
		)
	)

	for %%F in (%STELLA_API_VIRTUAL_PUBLIC%) do (
		if "%%F"=="%FUNC_NAME%" (
			call %STELLA_COMMON%\common-virtual.bat :%FUNC_NAME% %*
			goto :eof
		)
	)

	for %%F in (%STELLA_API_BUILD_PUBLIC%) do (
		if "%%F"=="%FUNC_NAME%" (
			call %STELLA_COMMON%\common-build.bat :%FUNC_NAME% %*
			goto :eof
		)
	)

	echo ** API ERROR : Function %FUNC_NAME% does not exist
	
goto :eof



:api_list
	set "%~1=[ COMMON-API : %STELLA_API_COMMON_PUBLIC% ]	[ FEATURE-API : %STELLA_API_FEATURE_PUBLIC% ] 	[ APP-API : %STELLA_API_APP_PUBLIC% ] 	[ VIRTUAL-API : %STELLA_API_VIRTUAL_PUBLIC% ] [ BUILDL-API : %STELLA_API_BUILD_PUBLIC% ]"
goto :eof