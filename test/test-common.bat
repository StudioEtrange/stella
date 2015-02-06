@setlocal enableExtensions enableDelayedExpansion
@echo off

call %~dp0\..\conf.bat

call :test_abs_to_rel_path

call :test_trim

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
	call %STELLA_COMMON%\common.bat :trim "result" test test
	echo  %result% && if not "%result%"=="test test" echo ERROR

	call %STELLA_COMMON%\common.bat :trim "result" " test test "
	echo  %result% && if not "%result%"=="test test" echo ERROR

goto:eof

@echo on