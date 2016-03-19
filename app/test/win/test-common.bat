@setlocal enableExtensions enableDelayedExpansion
@echo off

call %~dp0\stella-link.bat include

call :test_trim

call :test_is_path_abs

call :test_abs_to_rel_path

call :test_key

goto :eof


:test_is_path_abs

call %STELLA_COMMON%\common.bat :is_path_abs "result" "path1\path2\"
echo  %result% && if not "%result%"=="FALSE" echo ERROR

call %STELLA_COMMON%\common.bat :is_path_abs "result" ".\path1\path2\"
echo  %result% && if not "%result%"=="FALSE" echo ERROR

call %STELLA_COMMON%\common.bat :is_path_abs "result" "c:\path1\path2"
echo  %result% && if not "%result%"=="TRUE" echo ERROR

call %STELLA_COMMON%\common.bat :is_path_abs "result" "\path1\path2"
echo  %result% && if not "%result%"=="FALSE" echo ERROR

call %STELLA_COMMON%\common.bat :is_path_abs "result" "\\path1\path2"
echo  %result% && if not "%result%"=="TRUE" echo ERROR

goto :eof


:test_abs_to_rel_path

call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "path10" "c:\path1\path2"
echo  %result% && if not "%result%"=="path10" echo ERROR

call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1\test.txt" "c:\path1\path2"
echo  %result% && if not "%result%"=="..\test.txt" echo ERROR

call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1\path2\test.txt" "c:\path1"
echo  %result% && if not "%result%"=="path2\test.txt" echo ERROR

call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\test.txt" "c:\path1\path2"
echo  %result% && if not "%result%"=="..\..\test.txt" echo ERROR

call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1" "c:\path1\path2"
echo  %result% && if not "%result%"==".." echo ERROR

call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1\path3" "c:\path1\path2"
echo  %result% && if not "%result%"=="..\path3" echo ERROR


call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1\path2\" "c:\path1\"
echo  %result% && if not "%result%"=="path2" echo ERROR


call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1" "c:\path1"
echo  %result% && if not "%result%"=="." echo ERROR


goto :eof


:test_trim
	call %STELLA_COMMON%\common.bat :trim "result" "test     test"
	echo X!result!X && if not "!result!"=="test     test" echo ERROR

	call %STELLA_COMMON%\common.bat :trim "result" "  test     test  "
	echo X!result!X && if not "!result!"=="test     test" echo ERROR

	set "_t= test1 test2 test3 "
	call %STELLA_COMMON%\common.bat :trim "result" "!_t!"
	echo X!result!X && if not "!result!"=="test1 test2 test3" echo ERROR

	set _t=" test1 test2 test3 "
	call %STELLA_COMMON%\common.bat :trim "result" !_t!
	echo X!result!X && if not "!result!"=="test1 test2 test3" echo ERROR

	call %STELLA_COMMON%\common.bat :trim "result" test1 test2 test3
	echo X!result!X && if not "!result!"=="test1" echo ERROR

goto:eof


:test_key
	if not exist "%STELLA_APP_WORK_ROOT%" (
		mkdir %STELLA_APP_WORK_ROOT%
	)
	call %STELLA_COMMON%\common.bat :add_key "%STELLA_APP_WORK_ROOT%\test.properties" "STELLA" "TEST" "33"
	call %STELLA_COMMON%\common.bat :get_key "%STELLA_APP_WORK_ROOT%\test.properties" "STELLA" "TEST" "PREFIX"
	echo x!STELLA_TEST!x && if not "!STELLA_TEST!"=="33" echo ERROR
goto:eof
@echo on