@echo off
call %*
goto :eof




:: set flag for each compiler front end
:link_flags
	set "_frontend_bin_family=%~1"
	set "_var_flags=%~2"
	set "_lib_path=%~3"
	set "_include_path=%~4"
	set "_libs_name=%~5"

	if "!_frontend_bin_family!"=="gcc" (
		call :link_flags_gcc "!_var_flags!" "!_lib_path!" "!_include_path!" "!_libs_name!"
	)


	if "!_frontend_bin_family!"=="cl" (
		call :link_flags_cl "!_var_flags!" "!_lib_path!" "!_include_path!" "!_libs_name!"
	)
goto :eof



:link_flags_gcc
	set "_var_flags=%~1"
	set "_lib_path=%~2"
	set "_include_path=%~3"
	set "_libs_name=%~4"

	set _C_CXX_FLAGS=
	set "_CPP_FLAGS=-I!_include_path!"
	set "_LINK_FLAGS=-L!_lib_path!"

	for %%a in (!_libs_name!) do (
		set "_LINK_FLAGS=!_LINK_FLAGS! -l%%a"
	)

	set "_t=!_var_flags!_C_CXX_FLAGS"
	set "%_t%=!_C_CXX_FLAGS!"
	set "_t=!_var_flags!_CPP_FLAGS"
	set "%_t%=!_CPP_FLAGS!"
	set "_t=!_var_flags!_LINK_FLAGS"
	set "%_t%=!_LINK_FLAGS!"
goto :eof

:link_flags_cl
	set "_var_flags=%~1"
	set "_lib_path=%~2"
	set "_include_path=%~3"
	set "_libs_name=%~4"

	REM cl /I<path> /link /LIBPATH:<truc> foo.lib

	set "_C_CXX_FLAGS=/I!_include_path!"
	set "_CPP_FLAGS="
	set "_LINK_FLAGS=/LIBPATH:!_lib_path!"

	for %%a in (!_libs_name!) do (
		set "_LINK_FLAGS=!_LINK_FLAGS! %%a"
	)

	set "_t=!_var_flags!_C_CXX_FLAGS"
	set "%_t%=!_C_CXX_FLAGS!"
	set "_t=!_var_flags!_CPP_FLAGS"
	set "%_t%=!_CPP_FLAGS!"
	set "_t=!_var_flags!_LINK_FLAGS"
	set "%_t%=!_LINK_FLAGS!"
goto :eof



:: set flags and env for CMAKE
:set_env_vars_for_cmake

	:: CMAKE Flags
	:: note :
	::	- these flags have to be passed to the cmake command line, as cmake do not read en var
	::	- list of environment variables read by cmake http://www.cmake.org/Wiki/CMake_Useful_Variables:Environment_Variables
	set "CMAKE_C_FLAGS=!STELLA_C_CXX_FLAGS!"
	set "CMAKE_CXX_FLAGS=!STELLA_C_CXX_FLAGS!"

	:: Linker flags to be used to create shared libraries
	set "CMAKE_SHARED_LINKER_FLAGS=!STELLA_LINK_FLAGS! !STELLA_DYNAMIC_LINK_FLAGS!"
	:: Linker flags to be used to create module
	set "CMAKE_MODULE_LINKER_FLAGS=!STELLA_LINK_FLAGS! !STELLA_DYNAMIC_LINK_FLAGS!"
	:: Linker flags to be used to create static libraries
	set "CMAKE_STATIC_LINKER_FLAGS=!STELLA_LINK_FLAGS! !STELLA_STATIC_LINK_FLAGS!"
	:: Linker flags to be used to create executables
	set "CMAKE_EXE_LINKER_FLAGS=!STELLA_LINK_FLAGS! !STELLA_DYNAMIC_LINK_FLAGS!"

	:: Linked libraries
	call %STELLA_COMMON%\common.bat :trim "STELLA_LINKED_LIBS_CMAKE_LIBRARY_PATH" "!STELLA_LINKED_LIBS_CMAKE_LIBRARY_PATH!"
	call %STELLA_COMMON%\common.bat :trim "STELLA_LINKED_LIBS_CMAKE_INCLUDE_PATH" "!STELLA_LINKED_LIBS_CMAKE_INCLUDE_PATH!"
	set "CMAKE_LIBRARY_PATH=!STELLA_LINKED_LIBS_CMAKE_LIBRARY_PATH!"
	set "CMAKE_INCLUDE_PATH=!STELLA_LINKED_LIBS_CMAKE_INCLUDE_PATH!"
	:: -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH"

	:: TODO do we need this ?
	if not "!CMAKE_LIBRARY_PATH!"=="" set "CMAKE_LIBRARY_PATH=%CMAKE_LIBRARY_PATH:\=\\%"
	if not "!CMAKE_INCLUDE_PATH!"=="" set "CMAKE_INCLUDE_PATH=%CMAKE_INCLUDE_PATH:\=\\%"


	call %STELLA_COMMON%\common.bat :trim "STELLA_CMAKE_EXTRA_FLAGS" "!STELLA_CMAKE_EXTRA_FLAGS!"

goto :eof



:: set flags and env for standard build tools (GNU MAKE,...)
:set_env_vars_for_gcc

	:: ADD linked libraries flags
	call %STELLA_COMMON%\common.bat :trim "STELLA_LINKED_LIBS_C_CXX_FLAGS" "!STELLA_LINKED_LIBS_C_CXX_FLAGS!"
	call %STELLA_COMMON%\common.bat :trim "STELLA_LINKED_LIBS_CPP_FLAGS" "!STELLA_LINKED_LIBS_CPP_FLAGS!"
	call %STELLA_COMMON%\common.bat :trim "STELLA_LINKED_LIBS_LINK_FLAGS" "!STELLA_LINKED_LIBS_LINK_FLAGS!"

	set "STELLA_C_CXX_FLAGS=!STELLA_C_CXX_FLAGS! !STELLA_LINKED_LIBS_C_CXX_FLAGS!"
	set "STELLA_CPP_FLAGS=!STELLA_CPP_FLAGS! !STELLA_LINKED_LIBS_CPP_FLAGS!"
	set "STELLA_LINK_FLAGS=!STELLA_LINKED_LIBS_LINK_FLAGS! !STELLA_LINK_FLAGS! !STELLA_DYNAMIC_LINK_FLAGS! !STELLA_STATIC_LINK_FLAGS!"


 	:: flags to pass to the C compiler.
	set "CFLAGS=!STELLA_C_CXX_FLAGS!"
	:: flags to pass to the C++ compiler.
	set "CXXFLAGS=!STELLA_C_CXX_FLAGS!"
	:: flags to pass to the C preprocessor. Used when compiling C and C++ (Used to pass include_folder)
	set "CPPFLAGS=!STELLA_CPP_FLAGS!"

	:: flags to pass to the linker
	set "LDFLAGS=!STELLA_LINK_FLAGS!"

goto :eof


:: set flags and env for standard build tools (NMAKE,...)
:set_env_vars_for_cl


	:: ADD linked libraries flags
	call %STELLA_COMMON%\common.bat :trim "STELLA_LINKED_LIBS_C_CXX_FLAGS" "!STELLA_LINKED_LIBS_C_CXX_FLAGS!"
	call %STELLA_COMMON%\common.bat :trim "STELLA_LINKED_LIBS_CPP_FLAGS" "!STELLA_LINKED_LIBS_CPP_FLAGS!"
	call %STELLA_COMMON%\common.bat :trim "STELLA_LINKED_LIBS_LINK_FLAGS" "!STELLA_LINKED_LIBS_LINK_FLAGS!"

	set "STELLA_C_CXX_FLAGS=!STELLA_C_CXX_FLAGS! !STELLA_LINKED_LIBS_C_CXX_FLAGS!"
	set "STELLA_CPP_FLAGS=!STELLA_CPP_FLAGS! !STELLA_LINKED_LIBS_CPP_FLAGS!"
	set "STELLA_LINK_FLAGS=!STELLA_LINKED_LIBS_LINK_FLAGS! !STELLA_LINK_FLAGS! !STELLA_DYNAMIC_LINK_FLAGS! !STELLA_STATIC_LINK_FLAGS!"


	REM http://msdn.microsoft.com/en-us/library/d7ahf12s.aspx
 	REM flags to pass to the C compiler.
	set "CFLAGS=!STELLA_C_CXX_FLAGS!"
	REM flags to pass to the C++ compiler. (.cxx files)
	set "CXXFLAGS=!STELLA_C_CXX_FLAGS!"
	REM  flags to pass to the C++ compiler. (.cpp files)
	set "CPPFLAGS=!STELLA_C_CXX_FLAGS!"
	REM STELLA_CPP_FLAGS is not used

	:: flags to pass to the linker
	:: https://msdn.microsoft.com/en-us/library/6y6t9esh.aspx
	REM do not work == make link.exe to not found an UNKNOW link.obj file when we use LINK env var
	REM set "LINK=!STELLA_LINK_FLAGS!"

goto :eof




:: settings compiler flags -- depend on toolset (configure tool, build tool, compiler frontend)

:set_build_env
	:: CPU_INSTRUCTION_SCOPE -----------------------------------------------------------------
	:: http://sdf.org/~riley/blog/2014/10/30/march-mtune/
	if "%~1"=="CPU_INSTRUCTION_SCOPE" (
		if "!STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY!"=="gcc" (
			if "%~2"=="CURRENT" (
				set "STELLA_C_CXX_FLAGS=!STELLA_C_CXX_FLAGS! -march=native"
			)
			if "%~2"=="SAME_FAMILY" (
				set "STELLA_C_CXX_FLAGS=!STELLA_C_CXX_FLAGS! -mtune=native"
			)
			if "%~2"=="GENERIC" (
				set "STELLA_C_CXX_FLAGS=!STELLA_C_CXX_FLAGS! -mtune=generic"
			)
		)
	)

	:: set OPTIMIZATION -----------------------------------------------------------------
	if "%~1"=="OPTIMIZATION" (
		if "!STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY!"=="gcc" (
			if not "%~2"=="" (
				set "STELLA_C_CXX_FLAGS=!STELLA_C_CXX_FLAGS! -O%~2"
			)
		)
	)

	:: ARCH -----------------------------------------------------------------
	:: Setting flags for a specific arch
	if "%~1"=="ARCH" (
		if "!STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY!"=="gcc" (
			if "%~2"=="x86" (
				set "STELLA_C_CXX_FLAGS=-m32 !STELLA_C_CXX_FLAGS!"
			)
			if "%~2"=="x64" (
				set "STELLA_C_CXX_FLAGS=-m64 !STELLA_C_CXX_FLAGS!"
			)
		)
		if "!STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY!"=="cl" (
			echo TODO arch for cl ?
			REM set "CL=/arch:x86"
			REM set "LINK=/MACHINE:X86"
		)
	)


goto :eof




REM could also search (after winsdk 7.1) in this key
REM HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots
REM see https://github.com/rpavlik/cmake-modules/blob/master/FindWindowsSDK.cmake
:find_winsdk
	set "_result_var=%~1"
	set "_version=%~2"

	for /F "tokens=1 delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SDKs\Windows\!_version!" /v InstallationFolder 2^>NUL ^| findstr InstallationFolder') do (
		set "_tp=%%i"
	)
	set "_tp=%_tp:InstallationFolder=%"
	set "_tp=%_tp:REG_SZ=%"

	call %STELLA_COMMON%\common.bat :trim "_tp" "!_tp!"

	set "!_result_var!="
	if exist "!_tp!" (
		set "!_result_var!=!_tp!"
	)

goto :eof


REM usefull when using Visual Studio Express which not contain MFC
REM use MFC and ATL from WDK/DDK instead
REM code based on wdk7.1.0
REM http://www.codeproject.com/Articles/30439/How-to-compile-MFC-code-in-Visual-C-Express
REM https://ryzomcore.atlassian.net/wiki/display/RC/Building+Ryzom+MFC+Tools+with+VS+Express
REM http://www.microsoft.com/en-us/download/details.aspx?id=11800
REM _wdk_path example : set "_wdk_path=E:\CODE\WinDDK\7600.16385.1"
:_mfc_atl_wdk_tweak
	:: x86 | x64
	set "_target_arch=%~1"
	set "_wdk_path=%~2"
	echo ** Use MFC and ATL from WDK
	:: when using WDK instead of regular MFC some localized rc files are absent
	if not exist "%_wdk_path%\inc\mfc42\l.fra" (
		echo ** Make symbolic link for mfc42\l.fra
		call %STELLA_COMMON%\common.bat :run_admin %STELLA_COMMON%\symlink.bat "%_wdk_path%\inc\mfc42" "%_wdk_path%\inc\mfc42\l.fra"
	)

	set "INCLUDE=%INCLUDE%;%_wdk_path%\inc\mfc42;%_wdk_path%\inc\atl71;%_wdk_path%\inc\api"
	if "!_target_arch!"=="x64" set "LIB=%LIB%;%_wdk_path%\lib\mfc\amd64;%_wdk_path%\lib\atl\amd64;%_wdk_path%\lib\win7\amd64"
	if "!_target_arch!"=="x86" set "LIB=%LIB%;%_wdk_path%\lib\mfc\i386;%_wdk_path%\lib\atl\i386;%_wdk_path%\lib\win7\i386"
goto :eof

:vs_env_vars
	:: x86 | x64 | arm
	set "_target_arch=%~1"

	set INCLUDE=
	set LIB=
	set LIBPATH=

	set vstudio=
	set vcpath=


	echo ** Active Visual Studio

	REM Visual Studio 2005
	if not "!VS80COMNTOOLS!"=="" (
		if exist "!VS80COMNTOOLS!" (
			set "vstudio=vs8"
			set "vcpath=%VS80COMNTOOLS%..\..\VC"
			echo ** Detected Visual Studio 2005 in !VS80COMNTOOLS!
			echo ** WARN Please update Visual Studio or it may not work
			if "!_target_arch!"=="arm" (
				echo ** WARNING ARM target supported with Visual Studio 2012 / VC11 and after only
			)
		) else (
			echo ** WARN VS80COMNTOOLS is setted with !VS80COMNTOOLS! but folder do not exist
		)
	)
	REM Visual Studio 2008
	if not "!VS90COMNTOOLS!"=="" (
		if exist "!VS90COMNTOOLS!" (
			set "vstudio=vs9"
			set "vcpath=%VS90COMNTOOLS%..\..\VC"
			echo ** Detected Visual Studio 2008 in !VS90COMNTOOLS!
			echo ** WARN Please update Visual Studio or it may not work
			if "!_target_arch!"=="arm" (
				echo ** WARNING ARM target supported with Visual Studio 2012 / VC11 and after only
			)
		) else (
			echo ** WARN VS90COMNTOOLS is setted with !VS90COMNTOOLS! but folder do not exist
		)
	)
	REM Visual Studio 2010
	if not "!VS100COMNTOOLS!"=="" (
		if exist "!VS100COMNTOOLS!" (
			set "vstudio=vs10"
			set "vcpath=%VS100COMNTOOLS%..\..\VC"
			echo ** Detected Visual Studio 2010 in !VS100COMNTOOLS!
			echo ** WARN You should update Visual Studio
			if "!_target_arch!"=="arm" (
				echo ** WARNING ARM target supported with Visual Studio 2012 / VC11 and after only
			)
		) else (
			echo ** WARN VS100COMNTOOLS is setted with !VS100COMNTOOLS! but folder do not exist
		)
	)
	REM Visual Studio 2012
	if not "!VS110COMNTOOLS!"=="" (
		if exist "!VS110COMNTOOLS!" (
			set "vstudio=vs11"
			set "vcpath=%VS110COMNTOOLS%..\..\VC"
			echo ** Detected Visual Studio 2012 in !VS110COMNTOOLS!
		) else (
			echo ** WARN VS110COMNTOOLS is setted with !VS110COMNTOOLS! but folder do not exist
		)
	)
	REM Visual Studio 2013
	if not "!VS120COMNTOOLS!"=="" (
		if exist "!VS120COMNTOOLS!" (
			set "vstudio=vs12"
			set "vcpath=%VS120COMNTOOLS%..\..\VC"
			echo ** Detected Visual Studio 2013 in !VS120COMNTOOLS!
		) else (
			echo ** WARN VS120COMNTOOLS is setted with !VS120COMNTOOLS! but folder do not exist
		)
	)
	REM Visual Studio 2014 OR VS13/VC13 does not exist
	REM Visual Studio 2015
	if not "!VS140COMNTOOLS!"=="" (
		if exist "!VS140COMNTOOLS!" (
			set "vstudio=vs14"
			set "vcpath=%VS140COMNTOOLS%..\..\VC"
			echo ** Detected Visual Studio 2015 in !VS140COMNTOOLS!
		) else (
			echo ** WARN VS140COMNTOOLS is setted with !VS140COMNTOOLS! but folder do not exist
		)
	)



	if not "!vstudio!"=="" (

		set "_save_path_vs_env_vars=!PATH!"

		REM set VC env vars
		if "!vstudio!"=="vs10" (
			if "!_target_arch!"=="x86" (
				REM use SDK7.1 to set env for x86 target seems to be broken
				call "!vcpath!\vcvarsall.bat" x86
			) else (
				REM for 64 bits build with visual studio 2010, need WinSDK 7.1
				call :find_winsdk "sdk71path" "v7.1"
				if "!sdk71path!"=="" (
					echo ** WARNING : for x64 target you MUST install Windows SDK 7.1.
				) else (
					echo ** Windows SDK 7.1 Command Line environment activation
					REM TODO /Debug output
					if "!_target_arch!"=="x64" call "!sdk71path!bin\SetEnv" /x64 /release
					REM if "!_target_arch!"=="x86" call "!sdk71path!bin\SetEnv" /x86 /release
					REM by default WinSDK7.1 take same architecture than current processors
					if "!_target_arch!"=="" call "!sdk71path!bin\SetEnv" /release
				)
			)

		) else (
			if exist "!vcpath!\vcvarsall.bat" (
				echo ** Visual Studio Command Line environment activation
				if "!_target_arch!"=="" (
					call "!vcpath!\vcvarsall.bat"
				)
				if "!_target_arch!"=="x64" (
					call "!vcpath!\vcvarsall.bat" amd64
				)
				if "!_target_arch!"=="x86" (
					call "!vcpath!\vcvarsall.bat" x86
				)
			) else (
				echo ** WARNING : VC does not exist OR vcvarsall.bat does not exist
				echo ** Please install VC
			)
		)

		REM NOTE on PATH variable :
		REM ORIGINALPATH is a variable setted with some version of VS or WINSDK command line.
		REM ORIGINALPATH is setted using the value of %PATH% variable defined in the system (not the real current value of PATH)
		REM so ORIGINALPATH miss our previously setted PATH setting. It is like a "reset" of PATH
		REM so we have to set again our own PATH after this


		REM Reinit PATH Values
		set "PATH=!_save_path_vs_env_vars!;!PATH!"

		REM DO NOT USE THIS cause problem with toolset because of STELLA_APP_ROOT redefined
		REM call %STELLA_COMMON%\common-feature.bat :feature_reinit_installed


	) else (
		echo WARN Visual Studio is not found
		call %STELLA_COMMON%\common-platform.bat :require "cl" "vs" "SYSTEM"
	)



goto :eof
