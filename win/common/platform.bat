@echo off
call %*
goto :eof
::--------------------------------------------------------
::-- Functions
::---------------

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

goto :eof



:get_platform_from_os
	set _return_var=%~1
	set _os=%~2


	set "%_return_var%=unknown"

	call %STELLA_COMMON%\common.bat :match_exp "windows.*" "%_os%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=windows"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "centos.*" "%_os%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=linux"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "archlinux.*" "%_os%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=linux"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "ubuntu.*" "%_os%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=linux"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "debian.*" "%_os%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=linux"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "linuxgeneric.*" "%_os%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=linux"
		goto :eof
	)


	call %STELLA_COMMON%\common.bat :match_exp "macos.*" "%_os%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=macos"
		goto :eof
	)

goto :eof



:get_platform_suffix
	set _return_var=%~1
	set _platform=%~2

	set "%_return_var%=unknown"

	call %STELLA_COMMON%\common.bat :match_exp "windows" "%_platform%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=win"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "linux" "%_platform%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=linux"
		goto :eof
	)

	call %STELLA_COMMON%\common.bat :match_exp "macos" "%_platform%"
	if "!_match_exp!"=="TRUE" (
		set "%_return_var%=macos"
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


:: INIT OS PACKAGES --------------

:__stella_system_requirement_by_os
	set _os=%~1
	
	echo ** Install Stella system requirements for %_os%
goto :eof



:__stella_features_requirement_by_os
	set _os=%~1

	echo ** Install required features for %_os%
	
	call %STELLA_COMMON%\common-feature.bat :feature_install unzip#5_51_1 "HIDDEN INTERNAL"
	call %STELLA_COMMON%\common-feature.bat :feature_install wget#1_11_4 "HIDDEN INTERNAL"
	call %STELLA_COMMON%\common-feature.bat :feature_install sevenzip#9_20 "HIDDEN INTERNAL"
	call %STELLA_COMMON%\common-feature.bat :feature_install goconfig-cli#snapshot "HIDDEN INTERNAL"
goto :eof

