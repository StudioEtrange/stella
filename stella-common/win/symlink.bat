@echo OFF

REM Author: Josh Jaques.
REM Copyright: Josh Jaques, 2011. All rights reserved.

REM set xp=true for XP mode, false for vista/win7 mode
REM xp mode requires that you have junction on your path
REM Download from here: http://download.sysinternals.com/Files/Junction.zip
REM GITHUB https://github.com/JDeuce/symlink.bat
REM Extract to C:\Windows\System32
set xp=false

:read_params
    if [%1] EQU [] ( 
        goto :usage
    ) ELSE (
	REM note %~1 = 1 without quotes
        set target=%~1
    )

    if [%2] EQU [] (
        goto :usage 
    ) ELSE ( 
        set link_name=%~2
    )

:verify_params
    if NOT EXIST "%target%" (goto :invalid_target)
    if EXIST "%link_name%" (goto :invalid_link)

:print_params
    echo Using target: "%target%"
    echo Using linkname: "%link_name%"

:main
    REM Check if target is a directory 
    if EXIST %target%\ (
	goto :link_directory
    ) else (
        goto :link_file
    )
goto :eof

:link_directory
    echo Doing directory link
    if %xp% EQU true (
        echo Using XP Mode
        junction "%link_name%" "%target%" > NUL
    ) else (
        mklink /d "%link_name%" "%target%" > NUL
    )
goto :eof

:link_file
    cho Doing file link
    if %xp% EQU true (
        echo Using XP Mode
        fsutil hardlink create "%link_name%" "%target%" > NUL
    ) else (
        mklink "%link_name%" "%target%" > NUL
    )
goto :eof

:usage
    echo Usage: [target] [link_name]
goto :eof

:invalid_target
    echo Target "%target%" does not exist
goto :eof

:invalid_link
    echo Link "%link_name%" already exists
goto :eof

REM Addon from StudioEtrange
:delete_link_directory
    rmdir %~1
goto :eof

:delete_link_file
    del /q %~1
goto :eof
