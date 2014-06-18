@echo off
call %*
goto :eof
::--------------------------------------------------------
::-- argopt
::-- by Studio/Etrange (NoMorgan nomorgan@gmail.com)
::--------------------------------------------------------

:: PARAMETERS
:: all parameters are mandatory
:: parameter order is important
:: parameters can have a list of possible values OR can have anystring
::			* To accept any string value for a parameter, use _ANY_
:: set "params=param1:"val1 val2" param2:"val1 val2 val3""

:: OPTIONS
:: optional arg are not mandatory
:: option order is not important
:: optionnal arg can have a list of possible values OR can have anystring OR or can be a flag
:: 			* If the first value listed begin with # then this is the default value. 
::			* To accept any string value for an option, use _ANY_
:: 			* optional arg without any listed value are considered as flag and set with value of 1
:: set "options=-option1:"#default_val1 val2" -flag1: -option2="_ANY_""

:: global variable 
::		set ARGOPT_DEBUG=1 to active debug mode
:: return variable
:: 		ARGOPT_FLAG_ERROR=1 if an error occured
::		ARGOPT_FLAG_HELP=1 if user use help option (help option bypass all parameter and option checking, disable with set ARGOPT_AUTOHELP_DISABLE=1)
:: 		ARGOPT_HELP_SYNTAX set with a syntax message

:: EXAMPLE
::@setlocal enableExtensions enableDelayedExpansion
::set "params=vs:"vc11 vc10 vc9" cpu:"64 32 arm" name:"_ANY_""
::set "options=-output:"#release debug" -externlib:"#release" -v: -vv: -h: -j:_ANY_"
::call %~dp0\argopt.bat :argopt %*
::if "%ARGOPT_FLAG_ERROR%"=="1" echo ERROR : %ARGOPT_HELP_SYNTAX%
::if "%ARGOPT_FLAG_HELP%"=="1" echo HELP : %ARGOPT_HELP_SYNTAX%
::endlocal

:argopt
set "ARGOPT_MARK_DEFAULT_VALUE=#"
set "ARGOPT_ANY_VALUE=_ANY_"
set "ARGOPT_FLAG_ERROR="
set "ARGOPT_FLAG_HELP="
set "ARGOPT_HELP_SYNTAX="
set "ARGOPT_SET_OPTION="
set "ARGOPT_SET_PARAM="
set "ARGOPT_AUTOHELP_OPTION_NAME=-help"
set "ARGOPT_AUTOHELP_DISABLE="


:: init parameters
set /a "i = 0"
for %%O in (%params%) do (
	for /f "tokens=1,* delims=: " %%A in ("%%O") do (
		set /a "i = i + 1"
		set "param_name_!i!=%%A"
		set "param_values_!i!=%%~B"
		if "%%~B"=="%ARGOPT_ANY_VALUE%" (
			set "ARGOPT_HELP_SYNTAX=!ARGOPT_HELP_SYNTAX!%%A"
		) else (
			set "ar=%%~B"
			set "ARGOPT_HELP_SYNTAX=!ARGOPT_HELP_SYNTAX!%%A=!ar: =^|!"
		)
	)
	set "ARGOPT_HELP_SYNTAX=!ARGOPT_HELP_SYNTAX! "
)
set /a "nb_params = !i!"

:: init options
:: add default help option
if "%ARGOPT_DISABLE_HELP%"=="" (
	set "options=%ARGOPT_AUTOHELP_OPTION_NAME%: %options%"
)
for %%K in (%options%) do (
	for /f "tokens=1,* delims=:" %%X in ("%%K") do (
		if "%%~Y"=="" (
			set "%%X=%%~Y"
			set "ARGOPT_HELP_SYNTAX=!ARGOPT_HELP_SYNTAX! [%%X]"
		) else (
			set "val=%%~Y"
			set "%%X=!val:%ARGOPT_MARK_DEFAULT_VALUE%=!"
			if "%%~Y"=="%ARGOPT_ANY_VALUE%" (
				set "ARGOPT_HELP_SYNTAX=!ARGOPT_HELP_SYNTAX! [%%X=STRING]"
			) else (
				set "ar=%%~Y"
				set "ARGOPT_HELP_SYNTAX=!ARGOPT_HELP_SYNTAX! [%%X=!ar: =^|!]"
			)
		)
		
	)
)


:: main loop
set /a "i = 1"
:argloop
if "%ARGOPT_FLAG_ERROR%"=="" if "!ARGOPT_FLAG_HELP!"=="" if not "%~1"=="" (

	:: process auto help option
	if "%ARGOPT_DISABLE_HELP%"=="" (
		if "!i!" == "1" (
			if "%~1"=="%ARGOPT_AUTOHELP_OPTION_NAME%" (
			  	set "%~1=1"
			  	set "ARGOPT_SET_OPTION=!ARGOPT_SET_OPTION! %~1"
			  	set "ARGOPT_FLAG_HELP=1"
			)
		)
	)

	:: process parameters
	if !i! LEQ %nb_params% if "!ARGOPT_FLAG_HELP!"=="" (
		if "!param_values_%i%!"=="%ARGOPT_ANY_VALUE%" (
			set "!param_name_%i%!=%~1"
			set "ARGOPT_SET_PARAM=!ARGOPT_SET_PARAM! !param_name_%i%!"
		) else (
			for %%F in (!param_values_%i%!) do (
				if "%~1"=="%%F" (
					set "!param_name_%i%!=%~1"
					set "ARGOPT_SET_PARAM=!ARGOPT_SET_PARAM! !param_name_%i%!"
				)
			)
		)
		set "p=!param_name_%i%!"
		goto :hack1
		:: hack to force refresh value of !%p%!
		:hack1
		if "!%p%!"=="" (
			echo ** ERROR invalid argument #!i! - Parameter : '!param_name_%i%!' must have one of this values : !param_values_%i%!
			set ARGOPT_FLAG_ERROR=1
		)
	)
	:: process options
	if !i! GTR %nb_params% if "!ARGOPT_FLAG_HELP!"=="" (
		set "test=!options:*%~1:=! "
		if "!test!"=="!options! " (
		  echo ** ERROR invalid argument #!i! - Unknow option : '%~1'
		  set ARGOPT_FLAG_ERROR=1
		) else if "!test:~0,1!"==" " (
		  :: this option is a flag
		  set "%~1=1"
		  set "ARGOPT_SET_OPTION=!ARGOPT_SET_OPTION! %~1"
		  if "%~1"=="%ARGOPT_AUTOHELP_OPTION_NAME%" (
			  	set "ARGOPT_FLAG_HELP=1"
		  )
		) else (
		  :: this option require value
		  set "av=!%~1!"
		  set "%~1="
		  for %%S in (!av!) do (
		  	if "%%S"=="%ARGOPT_ANY_VALUE%" (
		  		set "%~1=%~2"
		  		set "ARGOPT_SET_OPTION=!ARGOPT_SET_OPTION! %~1"
		  	)
			if "%~2"=="%%S" (
				set "%~1=%%S"
				set "ARGOPT_SET_OPTION=!ARGOPT_SET_OPTION! %~1"
			)
		  )
		  goto :hack2
		  :: hack to force refresh value of !%~1!
		  :hack2
		  if "!%~1!"=="" (
			echo ** ERROR invalid argument #!i! - Option : '%~1' must have one of this values : !av!
			set ARGOPT_FLAG_ERROR=1
		  )
		  shift /1
		)	
	)
	set /a "i = i + 1"
	shift /1
	goto :argloop
)


if "%ARGOPT_FLAG_ERROR%"=="" if "%ARGOPT_FLAG_HELP%"=="" (
	:: checking missing parameters
	for %%O in (%params%) do (
		for /f "tokens=1,* delims=: " %%A in ("%%O") do (
			set "param_missing=1"
			for %%M in (%ARGOPT_SET_PARAM%) do (
				if "%%A"=="%%M" (
					set "param_missing="
				)
			)
			if "!param_missing!"=="1" (
				echo ** ERROR Missing Parameter : '%%A' possible values are : %%~B
				set ARGOPT_FLAG_ERROR=1
			)
		)
	)

	:: setting unsetted options with default values
	for %%K in (%options%) do (
		for /f "tokens=1,* delims=:" %%X in ("%%K") do (
			if "%%~Y" NEQ "" (
				set "opt_to_set=1"
				for %%M in (%ARGOPT_SET_OPTION%) do (
					if "%%X"=="%%M" (
						set "opt_to_set="
					)
				)
				:: unset option
				if "!opt_to_set!"=="1" (
					set "val=%%~Y"
					set "mark=!val:~0,1!"
					:: this option have default value
					if "!mark!"=="%ARGOPT_MARK_DEFAULT_VALUE%" (
						for /f "tokens=1" %%F in ("%%~Y") do (
							set "val=%%F"
							set "%%X=!val:%ARGOPT_MARK_DEFAULT_VALUE%=!"
						)
					) else (
						:: this option does not have default value
						set "%%X="
					)

				)
			)
		)
	)
)

::for debug
if "%ARGOPT_DEBUG%"=="1" (
	echo ** ARGOPT DEBUG **
	for %%O in (%params%) do for /f "tokens=1,* delims=: " %%A in ("%%O") do echo PARAMETER: %%A=!%%A!
	for %%K in (%options%) do for /f "tokens=1,* delims=:" %%X in ("%%K") do echo OPTION: %%X=!%%X!
)
goto :eof




