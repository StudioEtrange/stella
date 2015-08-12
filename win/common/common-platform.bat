@echo off
call %*
goto :eof


REM DISTRIB/OS/PLATFORM INFO ---------------------------

REM NOTE :
REM classification :
REM 	platform <--- os <---- distrib
REM 		example :
REM			linux <----- ubuntu <---- ubuntu 14.04
REM			linux <----- centos <---- centos 6
REM			windows <--- windows <---- windows 7
REM suffix platform :
REM 	each platform have a suffix
REM		example :
REM			windows <---> win
REM			linux <---> linux

:get_os_from_distro
	set _return_var=%~1
	set _distro=%~2

	set "%_return_var%=unknown"

	call %STELLA_COMMON%\common.bat :match_exp "indows.*" "%_distro%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=windows"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "buntu.*" "%_distro%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=ubuntu"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "ebian.*" "%_distro%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=debian"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "archlinux.*" "%_distro%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=archlinux"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "boot2docker.*" "%_distro%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=linuxgeneric"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "Mac OS X.*" "%_distro%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=macos"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "macos.*" "%_distro%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=macos"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "Red Hat Enterprise Linux" "%_distro%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=rhel"
		goto :eof
	)

goto :eof



:get_platform_from_os
	set _return_var=%~1
	set _os=%~2


	set "%_return_var%=unknown"

	if "!_os!"=="windows" (
		set "%_return_var%=windows"
		goto :eof
	)

	if "!_os!"=="centos" (
		set "%_return_var%=linux"
		goto :eof
	)

	if "!_os!"=="centos" (
		set "%_return_var%=linux"
		goto :eof
	)
	
	if "!_os!"=="archlinux" (
		set "%_return_var%=linux"
		goto :eof
	)

	if "!_os!"=="ubuntu" (
		set "%_return_var%=linux"
		goto :eof
	)


	if "!_os!"=="debian" (
		set "%_return_var%=linux"
		goto :eof
	)

	if "!_os!"=="linuxgeneric" (
		set "%_return_var%=linux"
		goto :eof
	)

	if "!_os!"=="macos" (
		set "%_return_var%=darwin"
		goto :eof
	)

goto :eof



:get_platform_suffix
	set _return_var=%~1
	set _platform=%~2

	set "%_return_var%=unknown"


	if "!_platform!"=="windows" (
		set "%_return_var%=win"
		goto :eof
	)

	if "!_platform!"=="linux" (
		set "%_return_var%=linux"
		goto :eof
	)

	if "!_platform!"=="darwin" (
		set "%_return_var%=darwin"
		goto :eof
	)
goto :eof




:set_current_platform_info
	set HOST_CPU=unknown
	set NB_CPU=unknown
	
	call :get_os_from_distro "STELLA_CURRENT_OS" "windows"
	call :get_platform_from_os "STELLA_CURRENT_PLATFORM" "%STELLA_CURRENT_OS%"
	call :get_platform_suffix "STELLA_CURRENT_PLATFORM_SUFFIX" "%STELLA_CURRENT_PLATFORM%"
goto :eof


REM REQUIREMENTS STELLA -------------

:ask_install_requirements
	set /p input="Do you wish to auto-install requirements for stella ? [Y/n] "
	if not "%input%"=="n" (
		call :__stella_requirement
		@echo off
	)
goto :eof

:__stella_requirement
	call :__install_minimal_system_requirement
	call :__install_minimal_feature_requirement
goto :eof

:__install_minimal_system_requirement
	
goto :eof

:__install_minimal_feature_requirement
	call %STELLA_COMMON%\common-feature.bat :feature_install unzip#5_51_1 "HIDDEN INTERNAL"
	call %STELLA_COMMON%\common-feature.bat :feature_install wget#1_11_4 "HIDDEN INTERNAL"
	call %STELLA_COMMON%\common-feature.bat :feature_install sevenzip#9_38 "HIDDEN INTERNAL"
	REM call %STELLA_COMMON%\common-feature.bat :feature_install goconfig-cli#snapshot "HIDDEN INTERNAL"
goto :eof


