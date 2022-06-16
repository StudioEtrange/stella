@setlocal enableExtensions enableDelayedExpansion
@setlocal
@echo off

call %~dp0\stella-link.bat include

set "TEST_LIST=test_strlen_1 test_strlen_2 test_string_remove_1 test_string_remove_2 test_string_remove_3 test_string_remove_4 test_string_remove_5 test_string_remove_6 test_trim test_is_path_abs test_abs_to_rel_path test_key"
for %%T in (!TEST_LIST!) do (
	set TEST_CURRENT=%%T
	echo ** Launch : !TEST_CURRENT!
	call :!TEST_CURRENT!
)
goto :eof




:TEST_ERROR
	echo ******** TEST_ERROR in !TEST_CURRENT! ********
goto :eof


REM various tests -----------------------------

:test_strlen_1
	set result=
	call %STELLA_COMMON%\common.bat :broken_strlen "result" "12345"
	echo %result% && if not "!result!"=="5" goto :TEST_ERROR

	set result=
	call %STELLA_COMMON%\common.bat :broken_strlen "result" "foo testbartestfoo"
	echo %result% && if not "!result!"=="18" goto :TEST_ERROR

	set result=
	call %STELLA_COMMON%\common.bat :broken_strlen "result" ""
	echo %result% && if not "!result!"=="0" goto :TEST_ERROR
goto :eof



:test_strlen_2
	set result=
	call %STELLA_COMMON%\common.bat :broken_strlen "result" "^"
	echo !result! && if not "!result!"=="1" goto :TEST_ERROR

	set result=
	call %STELLA_COMMON%\common.bat :broken_strlen "result" "a !"
	echo !result! && if not "!result!"=="3" goto :TEST_ERROR
goto :eof



:test_string_remove_1
	set result=
	call %STELLA_COMMON%\common.bat :broken_string_remove "result" "footest bartestfoo" "test"
	echo %result% && if not "%result%"=="foo barfoo" goto :TEST_ERROR
goto :eof

:test_string_remove_2
	set result=
	call %STELLA_COMMON%\common.bat :broken_string_remove "result" "footest&bar^test&barf^^o^^^o" "&bar^"
	echo "%result%" && if not "%result%"=="footesttest&barf^^o^^^o" goto :TEST_ERROR
goto :eof

:test_string_remove_3
	set result=
	call %STELLA_COMMON%\common.bat :broken_string_remove "result" "footest&bar^test&barfoo" "&bar"
	echo "!result!" && if not "!result!"=="footest^testfoo" goto :TEST_ERROR
goto :eof

:test_string_remove_4
	set result=
	call %STELLA_COMMON%\common.bat :broken_string_remove "result" "foo& | ( < > ^test" "& | ( < > ^"
	echo "!result!" && if not "!result!"=="footest" goto :TEST_ERROR
goto :eof

:test_string_remove_5
	set result=
	call %STELLA_COMMON%\common.bat :broken_string_remove "result" "foo!bar" "!"
	echo "!result!" && if not "!result!"=="foobar" goto :TEST_ERROR
goto :eof

:test_string_remove_6
	set result=
	call %STELLA_COMMON%\common.bat :broken_string_remove "result" "foo=bar=" "="
	echo "!result!" && if not "!result!"=="footest" goto :TEST_ERROR
goto :eof


:test_is_path_abs
	call %STELLA_COMMON%\common.bat :is_path_abs "result" "path1\path2\"
	echo  %result% && if not "%result%"=="FALSE" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :is_path_abs "result" ".\path1\path2\"
	echo  %result% && if not "%result%"=="FALSE" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :is_path_abs "result" "c:\path1\path2"
	echo  %result% && if not "%result%"=="TRUE" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :is_path_abs "result" "\path1\path2"
	echo  %result% && if not "%result%"=="FALSE" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :is_path_abs "result" "\\path1\path2"
	echo  %result% && if not "%result%"=="TRUE" goto :TEST_ERROR
goto :eof


:test_abs_to_rel_path
	call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "path10" "c:\path1\path2"
	echo %result% && if not "%result%"=="path10" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1\test.txt" "c:\path1\path2"
	echo %result% && if not "%result%"=="..\test.txt" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1\path2\test.txt" "c:\path1"
	echo %result% && if not "%result%"=="path2\test.txt" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\test.txt" "c:\path1\path2"
	echo %result% && if not "%result%"=="..\..\test.txt" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1" "c:\path1\path2"
	echo %result% && if not "%result%"==".." goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1\path3" "c:\path1\path2"
	echo %result% && if not "%result%"=="..\path3" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1\path2\" "c:\path1\"
	echo %result% && if not "%result%"=="path2" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :abs_to_rel_path "result" "c:\path1" "c:\path1"
	echo %result% && if not "%result%"=="." goto :TEST_ERROR
goto :eof


:test_trim
	call %STELLA_COMMON%\common.bat :trim "result" "test     test"
	echo X!result!X && if not "!result!"=="test     test" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :trim "result" "  test     test  "
	echo X!result!X && if not "!result!"=="test     test" goto :TEST_ERROR

	set "_t= test1 test2 test3 "
	call %STELLA_COMMON%\common.bat :trim "result" "!_t!"
	echo X!result!X && if not "!result!"=="test1 test2 test3" goto :TEST_ERROR

	set _t=" test1 test2 test3 "
	call %STELLA_COMMON%\common.bat :trim "result" !_t!
	echo X!result!X && if not "!result!"=="test1 test2 test3" goto :TEST_ERROR

	call %STELLA_COMMON%\common.bat :trim "result" test1 test2 test3
	echo X!result!X && if not "!result!"=="test1" goto :TEST_ERROR

goto:eof


:test_key
	if not exist "%STELLA_APP_WORK_ROOT%" (
		mkdir %STELLA_APP_WORK_ROOT%
	)
	call %STELLA_COMMON%\common.bat :add_key "%STELLA_APP_WORK_ROOT%\test.properties" "STELLA" "TEST" "33"
	call %STELLA_COMMON%\common.bat :get_key "%STELLA_APP_WORK_ROOT%\test.properties" "STELLA" "TEST" "PREFIX"
	echo x!STELLA_TEST!x && if not "!STELLA_TEST!"=="33" goto :TEST_ERROR
goto:eof


REM regex tests -----------------------------
:test_match_regex_1
	set "prefix=PREFIX"
	set "pattern=^a.*b$"
	set "str=test"
	call %STELLA_COMMON%\common.bat :match_regex "%prefix%" "%pattern%" "%str%"
	echo Should be NONE : %PREFIX_0% && if not "%PREFIX_0%"=="" goto :ERROR
	echo Should be NONE : %PREFIX_1% && if not "%PREFIX_1%"=="" goto :ERROR
	echo Should be NONE : %PREFIX_2% && if not "%PREFIX_2%"=="" goto :ERROR
	echo Should be NONE : %PREFIX_3% && if not "%PREFIX_3%"=="" goto :ERROR
goto:eof

:test_match_regex_2
	set "prefix=PREFIX"
	set "pattern=^a.*b$"
	set "str=acbacb"
	call %STELLA_COMMON%\common.bat :match_regex "%prefix%" "%pattern%" "%str%"
	echo Should be acbacb : %PREFIX_0% && if not "%PREFIX_0%"=="acbacb" goto :ERROR
	echo Should be NONE : %PREFIX_1% && if not "%PREFIX_1%"=="" goto :ERROR
	echo Should be NONE : %PREFIX_2% && if not "%PREFIX_2%"=="" goto :ERROR
	echo Should be NONE : %PREFIX_3% && if not "%PREFIX_3%"=="" goto :ERROR
goto:eof

:test_match_regex_3
	set "prefix=PREFIX"
	set "pattern=a.b"
	set "str=acbacb"
	call %STELLA_COMMON%\common.bat :match_regex "%prefix%" "%pattern%" "%str%"
	echo Should be abc : %PREFIX_0% && if not "%PREFIX_0%"=="abc" goto :ERROR
	echo Should be abc : %PREFIX_1% && if not "%PREFIX_1%"=="abc" goto :ERROR
	echo Should be NONE : %PREFIX_2% && if not "%PREFIX_2%"=="" goto :ERROR
	echo Should be NONE : %PREFIX_3% && if not "%PREFIX_3%"=="" goto :ERROR
goto:eof

:test_match_regex_4
	set "prefix=PREFIX"
	set "pattern=^(a.b)(d.f)$"
	set "str=acbdcf"
	call %STELLA_COMMON%\common.bat :match_regex "%prefix%" "%pattern%" "%str%"
	echo Should be acbdcf : %PREFIX_0% && if not "%PREFIX_0%"=="acbdcf" goto :ERROR
	echo Should be abc : %PREFIX_1% && if not "%PREFIX_1%"=="abc" goto :ERROR
	echo Should be dcf : %PREFIX_2% && if not "%PREFIX_2%"=="dcf" goto :ERROR
	echo Should be NONE : %PREFIX_3% && if not "%PREFIX_3%"=="" goto :ERROR
goto:eof





set "prefix=PREFIX"


echo TEST1
set "pattern=^a.*b$"
set "str=test"
call %STELLA_COMMON%\common.bat :match_regex "%prefix%" "%pattern%" "%str%"
echo Should be NONE : %PREFIX_0%
echo Should be NONE : %PREFIX_1%
echo Should be NONE : %PREFIX_2%
echo Should be NONE : %PREFIX_3%

echo TEST2
set "pattern=^a.*b$"
set "str=acbacb"
call %STELLA_COMMON%\common.bat :match_regex "%prefix%" "%pattern%" "%str%"
echo Should be acbacb : %PREFIX_0%
echo Should be NONE : %PREFIX_1%
echo Should be NONE : %PREFIX_2%
echo Should be NONE : %PREFIX_3%

echo TEST3
set "pattern=a.b"
set "str=acbadb"
call %STELLA_COMMON%\common.bat :match_regex "%prefix%" "%pattern%" "%str%"
echo Should be abc : %PREFIX_0%
echo Should be adc : %PREFIX_1%
echo Should be NONE : %PREFIX_2%
echo Should be NONE : %PREFIX_3%

echo TEST4
set "pattern=^(a.b)(d.f)$"
set "str=acbdcf"
call %STELLA_COMMON%\common.bat :match_regex "%prefix%" "%pattern%" "%str%"

echo Should be acbdcf : %PREFIX_0%
echo Should be abc : %PREFIX_1%
echo Should be dcf : %PREFIX_2%
echo Should be NONE : %PREFIX_3%


echo TEST5
set "str=https://user:password@google.fr/foo/bar?a=1&b=2&c#frag"
call %STELLA_COMMON%\common.bat :uri_parse "%prefix%" "%str%"

echo uri should be https://user:password@google.fr/foo/bar?a=1^&b=2^&c#frag : "%PREFIX_URI%"
echo schema should be https : %PREFIX_SCHEMA%
echo address should be user:password@google.fr : %PREFIX_ADDRESS%
echo user should be user : %PREFIX_USER%
echo password should be password : %PREFIX_PASSWORD%
echo host should be google.fr : %PREFIX_HOST%
echo port should be NONE : %PREFIX_PORT%
echo path should be /foo/bar : %PREFIX_PATH%
echo query should be ?a=1^&b=2^&c : "%PREFIX_QUERY%"
echo fragment should be frag : %PREFIX_FRAGMENT%
echo arg a value should be 1 : %PREFIX_a%
echo arg b value should be 2 : %PREFIX_b%
echo arg c value should be NONE : %PREFIX_c%



@echo on
