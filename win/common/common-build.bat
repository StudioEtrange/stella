@echo off
call %*



:: check if file.lib is an import lib or a static lib
:: by setting 
::		LIB_TYPE with UNKNOW, STATIC, IMPORT
:: first argument is the file to test
:is_import_or_static_lib
	set LIB_TYPE=UNKNOW
	set _nb_dll=0
	set _nb_obj=0
	for /f %%i in ('lib /list %~1 ^| findstr /N ".dll$" ^| find /c ":"') do set _nb_dll=%%i
	for /f %%j in ('lib /list %~1 ^| findstr /N ".obj$" ^| find /c ":"') do set _nb_obj=%%j
	for /f %%j in ('lib /list %~1 ^| findstr /N ".o$" ^| find /c ":"') do set /a _nb_obj=%%j+!_nb_obj!
	if %_nb_dll% EQU 0 if %_nb_obj% GTR 0 (
		set LIB_TYPE=STATIC
	)
	if %_nb_obj% EQU 0 if %_nb_dll% GTR 0 (
		set LIB_TYPE=IMPORT
	)
goto :eof



