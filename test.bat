@setlocal enableExtensions enableDelayedExpansion
@echo off

set _CURRENT_FILE_DIR=%~dp0
set _CURRENT_FILE_DIR=%_CURRENT_FILE_DIR:~0,-1%



set "prefix=PREFIX"


echo TEST1
set "pattern=^a.*b$"
set "str=test"
call %_CURRENT_FILE_DIR%\test2.bat :match_regex "%prefix%" "%pattern%" "%str%"
echo %PREFIX_0%
echo %PREFIX_1%
echo %PREFIX_2%
echo %PREFIX_3%

echo TEST2
set "pattern=(a.*b)"
set "str=acbacb"
call %_CURRENT_FILE_DIR%\test2.bat :match_regex "%prefix%" "%pattern%" "%str%"
echo %PREFIX_0%
echo %PREFIX_1%
echo %PREFIX_2%
echo %PREFIX_3%

echo TEST3
set "pattern=^(([a-z]+)://)?((([^:\/]+)(:([^@\/]*))?@)?([^:\/?]*)(:([0-9]+))?)(\/[^?#]*)?(\?[^#]*)?(#.*)?$"
set "str=https://nomorgan:password@google.fr/foo/bar?a=1&b=2#frag"
call %_CURRENT_FILE_DIR%\test2.bat :match_regex "%prefix%" "%pattern%" "%str%"


echo %PREFIX_0%
echo %PREFIX_1%
echo %PREFIX_2%
echo %PREFIX_3%

echo !PREFIX_0!
echo !PREFIX_1!
echo !PREFIX_2!
echo !PREFIX_3!
echo !PREFIX_10!
echo !PREFIX_12!



echo TEST4
call %_CURRENT_FILE_DIR%\test2.bat :uri_parse  "%prefix%" "%str%"


echo %PREFIX_0%
echo %PREFIX_1%
echo %PREFIX_2%
echo %PREFIX_3%

echo !PREFIX_0!
echo !PREFIX_1!
echo !PREFIX_2!
echo !PREFIX_3!
echo !PREFIX_10!
echo !PREFIX_12!
@endlocal