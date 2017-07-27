@setlocal enableExtensions enableDelayedExpansion
@echo off

set _CURRENT_FILE_DIR=%~dp0
set _CURRENT_FILE_DIR=%_CURRENT_FILE_DIR:~0,-1%



set "prefix=PREFIX"


echo TEST1
set "pattern=^a.*b$"
set "str=test"
call %_CURRENT_FILE_DIR%\test2.bat :match_regex "%prefix%" "%pattern%" "%str%"
echo Should be NONE : %PREFIX_0%
echo Should be NONE : %PREFIX_1%
echo Should be NONE : %PREFIX_2%
echo Should be NONE : %PREFIX_3%

echo TEST2
set "pattern=^a.*b$"
set "str=acbacb"
call %_CURRENT_FILE_DIR%\test2.bat :match_regex "%prefix%" "%pattern%" "%str%"
echo Should be acbacb : %PREFIX_0%
echo Should be NONE : %PREFIX_1%
echo Should be NONE : %PREFIX_2%
echo Should be NONE : %PREFIX_3%

echo TEST3
set "pattern=a.b"
set "str=acbacb"
call %_CURRENT_FILE_DIR%\test2.bat :match_regex "%prefix%" "%pattern%" "%str%"
echo Should be abc : %PREFIX_0%
echo Should be abc : %PREFIX_1%
echo Should be NONE : %PREFIX_2%
echo Should be NONE : %PREFIX_3%

echo TEST4
set "pattern=^(a.b)(d.f)$"
set "str=acbdcf"
call %_CURRENT_FILE_DIR%\test2.bat :match_regex "%prefix%" "%pattern%" "%str%"

echo Should be acbdcf : %PREFIX_0%
echo Should be abc : %PREFIX_1%
echo Should be dcf : %PREFIX_2%
echo Should be NONE : %PREFIX_3%


echo TEST5
set "str=https://user:password@google.fr/foo/bar?a=1&b=2&c#frag"
call %_CURRENT_FILE_DIR%\test2.bat :uri_parse  "%prefix%" "%str%"

echo uri should be https://nomorgan:password@google.fr/foo/bar?a=1^&b=2#frag : "%PREFIX_URI%"
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



@endlocal