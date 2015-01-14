@echo off
call %*
goto :eof
::--------------------------------------------------------
::-- Functions
::---------------

:get_os_from_distro
	set _return_var=%~1
	set _distro=%~2

	for %%V in (!_return_var!) do (
		set "%%V=unknown"

		call %STELLA_COMMON%\common.bat :match_exp "buntu.*" "%_distro%"
		if "!_match_exp!"=="TRUE" set "%%V=ubuntu"

		call %STELLA_COMMON%\common.bat :match_exp "ebian.*" "%_distro%"
		if "!_match_exp!"=="TRUE" set "%%V=debian"

		call %STELLA_COMMON%\common.bat :match_exp "archlinux.*" "%_distro%"
		if "!_match_exp!"=="TRUE" set "%%V=archlinux"

		call %STELLA_COMMON%\common.bat :match_exp "boot2docker.*" "%_distro%"
		if "!_match_exp!"=="TRUE" set "%%V=linuxgeneric"

		call %STELLA_COMMON%\common.bat :match_exp "Mac OS X.*" "%_distro%"
		if "!_match_exp!"=="TRUE" set "%%V=macos"

		call %STELLA_COMMON%\common.bat :match_exp "macos.*" "%_distro%"
		if "!_match_exp!"=="TRUE" set "%%V=macos"

		call %STELLA_COMMON%\common.bat :match_exp "indows.*" "%_distro%"
		if "!_match_exp!"=="TRUE" set "%%V=windows"

	)
goto :eof



:get_platform_from_os
	set _return_var=%~1
	set _os=%~2

	for %%V in (!_return_var!) do (
		set "%%V=unknown"

		call %STELLA_COMMON%\common.bat :match_exp "centos.*" "%_os%"
		if "!_match_exp!"=="TRUE" set "%%V=linux"

		call %STELLA_COMMON%\common.bat :match_exp "archlinux.*" "%_os%"
		if "!_match_exp!"=="TRUE" set "%%V=linux"

		call %STELLA_COMMON%\common.bat :match_exp "ubuntu.*" "%_os%"
		if "!_match_exp!"=="TRUE" set "%%V=linux"

		call %STELLA_COMMON%\common.bat :match_exp "debian.*" "%_os%"
		if "!_match_exp!"=="TRUE" set "%%V=linux"

		call %STELLA_COMMON%\common.bat :match_exp "linuxgeneric.*" "%_os%"
		if "!_match_exp!"=="TRUE" set "%%V=linux"

		call %STELLA_COMMON%\common.bat :match_exp "windows.*" "%_os%"
		if "!_match_exp!"=="TRUE" set "%%V=windows"

		call %STELLA_COMMON%\common.bat :match_exp "macos.*" "%_os%"
		if "!_match_exp!"=="TRUE" set "%%V=macos"
	)
goto :eof



:get_platform_suffix
	set _return_var=%~1
	set _platform=%~2

	for %%V in (!_return_var!) do (
		set "%%V=unknown"

		call %STELLA_COMMON%\common.bat :match_exp "linux" "%_platform%"
		if "!_match_exp!"=="TRUE" set "%%V=linux"

		call %STELLA_COMMON%\common.bat :match_exp "macos" "%_platform%"
		if "!_match_exp!"=="TRUE" set "%%V=macos"

		call %STELLA_COMMON%\common.bat :match_exp "windows" "%_platform%"
		if "!_match_exp!"=="TRUE" set "%%V=win"
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
	
	echo ** Installing Stella system requirements for %_os%
goto :eof


