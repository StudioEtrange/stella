@echo off
call %*
goto :eof


:: BUILD WORKFLOW

:: SET SOME DEFAULT BUILD MODE
::	__set_build_mode_default "RELOCATE" "ON"
::  __set_build_mode_default "DARWIN_STDLIB" "LIBCPP"

:: START BUILD SESSION
::	__start_build_session : reset every __set_build_mode values to default or empty
::				__reset_build_env
::				__set_toolset STELLA_BUILD_DEFAULT_TOOLSET




::		GET SOURCE CODE
::		__get_resource

::		SET TOOLSET
::		__set_toolset

::		ADD EXTRA TOOLS
::		__add_toolset "python"

:: 		SET CUSTOM BUILD MODE
::		__set_build_mode ARCH x86

::		SET CUSTOM FLAGS
::		set "STELLA_C_CXX_FLAGS=!STELLA_C_CXX_FLAGS! -DFLAG"

::		LINK BUILD TO OTHER LIBRARY
::		__link_feature_library

::		AUTOMATIC BUILD AND INSTALL
::		__auto_build OR __start_manual_build/__end_manual_build


::				INSTALL/INIT REQUIRED TOOLSET
::				__enable_current_toolset 	(included in __start_manual_build)

::				SET BUILD ENV AND FLAGS
::				__prepare_build (included in __start_manual_build)
::
::
::						call set_env_vars_for_gcc
:: 						call set_env_vars_for_cl
::						call set_env_vars_for_cmake

::				LAUNCH CONFIG TOOL
::				__launch_configure
::				LAUNCH BUILD TOOL
::				__launch_build

::				__inspect_and_fix_build
::						call __fix_built_files
::						call __check_built_files

::				DISABLE REQUIRED TOOLSET
::				__disable_current_toolset (included in __end_manual_build)

:: TOOLSET & BUILD TOOLS ----------------
:: Available tools :
:: 	CONFIG_TOOL SCHEMA : cmake, configure
:: 	BUILD_TOOL SCHEMA : nmake, ninja, jom, mingw-make, msys-make, msys-mingw-make
:: 	COMPIL_FRONTEND SCHEMA :  cl, mingw-gcc, msys-gcc, msys-mingw-gcc
::						in reality COMPIL_FRONTEND should be called COMPIL_DRIVER
::
::
:: Available preconfigured build toolset on windows system :
:: 	TOOLSET 		| CONFIG TOOL 				| BUILD TOOL 							| COMPIL FRONTEND
::	MS				|	cmake					|		nmake							|			cl
:: 	MSYS2			| 	configure				|		msys-mingw-make					|			msys-mingw-gcc
::	MINGW-W64		| 	NULL					|		mingw-make						|			mingw-gcc
:: NONE ===> disable build toolset and all tools

:: MSYS2 TOOLSET
::		make AND gcc are installed from pacman : bundle : mingw64/mingw-w64-x86_64-toolchain or mingw32/mingw-w64-i686-toolchain
::				we do not use msys/make nor msys/gcc versions from msys2 (whose rely on msys2.dll), but from mingw-w64 inside msys2
::				WARN : bundle mingw-w64-x86_64-toolchain install a lot of binaries which may generate conflicts (ex:python)
::				NOTE : activate a mingw env when using msys2_shell.cmd ? https://www.booleanworld.com/get-unix-linux-environment-windows-msys2/
::					   in the same way as vs_env_vars function
:: MINGW-W64 TOOLSET
::		mingw-make AND mingw-gcc are part of default mingw-w64 env


:start_build_session
	call :reset_build_env

	call :set_toolset "!STELLA_BUILD_DEFAULT_TOOLSET!"
goto :eof

:: BUILD ------------------------------------------------------------------------------------------------------------------------------
:start_manual_build
	set "NAME=%~1"
	set "SOURCE_DIR=%~2"
	set "INSTALL_DIR=%~3"

	echo ** Manual-building !NAME!

	call %STELLA_COMMON%\common-build-toolset.bat :enable_current_toolset

	call :prepare_build "!INSTALL_DIR!" "!SOURCE_DIR!"
goto :eof

:end_manual_build
	call %STELLA_COMMON%\common-build-toolset.bat :disable_current_toolset
	echo ** Done
goto :eof


:prepare_build
	set "_install_dir=%~1"
	set "_source_dir=%~2"
	set "_build_dir=%~3"


	:: set env
	call :set_build_env "ARCH" "!STELLA_BUILD_ARCH!"
	call :set_build_env "CPU_INSTRUCTION_SCOPE" "!STELLA_BUILD_CPU_INSTRUCTION_SCOPE!"
	call :set_build_env "OPTIMIZATION" "!STELLA_BUILD_OPTIMIZATION!"

	:: trim list
	call %STELLA_COMMON%\common.bat :trim "STELLA_C_CXX_FLAGS" "!STELLA_C_CXX_FLAGS!"
	call %STELLA_COMMON%\common.bat :trim "STELLA_CPP_FLAGS" "!STELLA_CPP_FLAGS!"
	call %STELLA_COMMON%\common.bat :trim "STELLA_LINK_FLAGS" "!STELLA_LINK_FLAGS!"


	:: set compiler env flags -------------
	:: cmake take care of compiler flags in case of other compil frontend
	if "!STELLA_BUILD_CONFIG_TOOL_BIN_FAMILY!"=="cmake" (
		call :set_env_vars_for_cmake
	) else (
		:: gcc
		if "!STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY!"=="gcc" (
			call :set_env_vars_for_gcc
		) else (
			:: cl
			if "!STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY!"=="cl" (
				call :set_env_vars_for_cl
			)
		)
	)


	:: print build info ------------
	echo ** BUILD TOOLSET
	echo ====^> Preconfigured Toolset : !STELLA_BUILD_TOOLSET!
	echo ====^> Configuration Tool : !STELLA_BUILD_CONFIG_TOOL! [family : !STELLA_BUILD_CONFIG_TOOL_BIN_FAMILY!]
	echo ====^> Build management Tool : !STELLA_BUILD_BUILD_TOOL! [family : !STELLA_BUILD_BUILD_TOOL_BIN_FAMILY!]
	echo ====^> Compiler Frontend : !STELLA_BUILD_COMPIL_FRONTEND! [family : !STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY!]
	echo ====^> env CC : !CC!
	echo ====^> env CXX : !CXX!
	echo ====^> env CPP : !CPP!
	echo ====^> Extra toolset : !STELLA_BUILD_EXTRA_TOOLSET!
	echo ====^> Toolset features checked : !STELLA_BUILD_CHECK_TOOLSET!
	echo ** BUILD INFO
	echo ====^> Build arch directive : !STELLA_BUILD_ARCH!
	echo ====^> Parallelized (if supported) : !STELLA_BUILD_PARALLELIZE!
	echo ====^> Relocatable : !STELLA_BUILD_RELOCATE!
	echo ====^> Linked lib from stella features : !STELLA_LINKED_LIBS_LIST!
	echo ** FOLDERS
	echo ====^> Install directory : !_install_dir!
	echo ====^> Source directory : !_source_dir!
	echo ====^> Build directory : !_build_dir!
	echo ** SOME FLAGS
	echo ====^> STELLA_C_CXX_FLAGS : !STELLA_C_CXX_FLAGS!
	echo ====^> STELLA_CPP_FLAGS : !STELLA_CPP_FLAGS!
	echo ====^> STELLA_LINK_FLAGS : !STELLA_LINK_FLAGS!
	echo ====^> STELLA_DYNAMIC_LINK_FLAGS : !STELLA_DYNAMIC_LINK_FLAGS!
	echo ====^> STELLA_STATIC_LINK_FLAGS : !STELLA_STATIC_LINK_FLAGS!
	echo ====^> CMAKE_LIBRARY_PATH : !CMAKE_LIBRARY_PATH!
	echo ====^> CMAKE_INCLUDE_PATH : !CMAKE_INCLUDE_PATH!
	echo ====^> STELLA_CMAKE_EXTRA_FLAGS : !STELLA_CMAKE_EXTRA_FLAGS!
	echo ** SOME ENV
	echo ====^> INCLUDE : !INCLUDE!
	echo ====^> LIB : !LIB!
	echo ====^> LIBPATH : !LIBPATH!
	echo ====^> LIBRARY_PATH (unix world var) : !LIBRARY_PATH!
goto :eof



:auto_build
	set "NAME=%~1"
	set "SOURCE_DIR=%~2"
	set "INSTALL_DIR=%~3"
	set "OPT=%~4"

	:: DEBUG SOURCE_KEEP BUILD_KEEP NO_CONFIG NO_BUILD NO_OUT_OF_TREE_BUILD NO_INSPECT NO_INSTALL POST_BUILD_STEP


	:: keep source code after build (default : FALSE)
	set "_opt_source_keep="
	:: keep build dir after build (default : FALSE)
	set "_opt_build_keep="
	:: configure step activation (default : TRUE)
	set "_opt_configure=ON"
	:: build step activation (default : TRUE)
	set "_opt_build=ON"
	:: build from another folder (default : TRUE)
	set "_opt_out_of_tree_build=ON"
	:: disable fix & check build (default : ON)
	set "_opt_inspect_and_fix_build=ON"
	for %%O in (%OPT%) do (
		if "%%O"=="SOURCE_KEEP" set _opt_source_keep=ON
		if "%%O"=="BUILD_KEEP" set _opt_build_keep=ON
		if "%%O"=="NO_CONFIG" set _opt_configure=OFF
		if "%%O"=="NO_BUILD" set _opt_build=OFF
		if "%%O"=="NO_OUT_OF_TREE_BUILD" set _opt_out_of_tree_build=OFF
		if "%%O"=="NO_INSPECT" set _opt_inspect_and_fix_build=OFF
	)

	:: can not build out of tree without configure first
	if "!_opt_configure!"=="OFF" (
		set "_opt_out_of_tree_build=OFF"
	)

	echo  ** Auto-building !NAME! into !INSTALL_DIR! for !STELLA_CURRENT_OS!


	call %STELLA_COMMON%\common-build-toolset.bat :enable_current_toolset


	:: folder stuff
	set "BUILD_DIR=!SOURCE_DIR!"
	if "!_opt_out_of_tree_build!"=="ON" (
		call %STELLA_COMMON%\common.bat :dirname "t1" "!SOURCE_DIR!"
		call %STELLA_COMMON%\common.bat :basename "t2" "!SOURCE_DIR!"
		set "BUILD_DIR=!t1!\!!t2!-build"
	)

	if not exist "!INSTALL_DIR!" mkdir "!INSTALL_DIR!"

	if "!_opt_out_of_tree_build!"=="ON" (
		echo ** Out of tree build is active
		if "!FORCE!"=="1" (
			call %STELLA_COMMON%\common.bat :del_folder "!BUILD_DIR!"
		)
		if not "!_opt_build_keep!"=="ON" (
			call %STELLA_COMMON%\common.bat :del_folder "!BUILD_DIR!"
		)
	) else (
		echo ** Out of tree build is not active
	)



	:: set build env
	call :prepare_build "!INSTALL_DIR!" "!SOURCE_DIR!" "!BUILD_DIR!"

	:: launch process
	if "!_opt_configure!"=="ON" (
		call :launch_configure "!SOURCE_DIR!" "!INSTALL_DIR!" "!BUILD_DIR!" "!OPT!"
	)
	if "!_opt_build!"=="ON" (
		call :launch_build "!SOURCE_DIR!" "!INSTALL_DIR!" "!BUILD_DIR!" "!OPT!"
	)


	cd /D "!INSTALL_DIR!"

	:: clean workspace
	if not "!_opt_source_keep!"=="ON" (
		call %STELLA_COMMON%\common.bat :del_folder "!SOURCE_DIR!"
	)

	if "!_opt_out_of_tree_build!"=="ON" (
		if not "!_opt_build_keep!"=="ON" (
			call %STELLA_COMMON%\common.bat :del_folder "!BUILD_DIR!"
		)
	)

	cd /D "!INSTALL_DIR!"
	if "!_opt_inspect_and_fix_build!"=="ON" (
		call :inspect_and_fix_build "!INSTALL_DIR!"
	)

	call %STELLA_COMMON%\common-build-toolset.bat :disable_current_toolset
	echo ** Done
goto :eof



:launch_configure

	set "AUTO_SOURCE_DIR=%~1"
	set "AUTO_INSTALL_DIR=%~2"
	set "AUTO_BUILD_DIR=%~3"
	set "OPT=%~4"

	:: debug mode (default : OFF)
	set _debug=

	for %%O in (%OPT%) do (
		if "%%O"=="DEBUG" (
			set "_debug=ON"
		)
	)



	if not exist "!AUTO_BUILD_DIR!" mkdir "!AUTO_BUILD_DIR!"
	cd /D "!AUTO_BUILD_DIR!"

	:: GLOBAL FLAGs
	:: AUTO_INSTALL_CONF_FLAG_PREFIX -- TODO NOT USED
	:: AUTO_INSTALL_CONF_FLAG_POSTFIX

	if "!STELLA_BUILD_CONFIG_TOOL_BIN_FAMILY!"=="configure" (

		echo TODO NOT IMPLEMENTED
	)

	if "!STELLA_BUILD_CONFIG_TOOL_BIN_FAMILY!"=="cmake" (
		if "!STELLA_BUILD_BUILD_TOOL!"=="mingw-make" (
			set "CMAKE_GENERATOR=MinGW Makefiles"
		)
		if "!STELLA_BUILD_BUILD_TOOL!"=="msys-make" (
			set "CMAKE_GENERATOR=MSYS Makefiles"
		)
		if "!STELLA_BUILD_BUILD_TOOL!"=="msys-mingw-make" (
			set "CMAKE_GENERATOR=MSYS Makefiles"
		)

		if "!STELLA_BUILD_BUILD_TOOL!"=="ninja" (
			set "CMAKE_GENERATOR=Ninja"
		)

		if "!STELLA_BUILD_BUILD_TOOL!"=="nmake" (
			set "CMAKE_GENERATOR=NMake Makefiles"
		)

		if "!STELLA_BUILD_BUILD_TOOL!"=="jom" (
			set "CMAKE_GENERATOR=NMake Makefiles"
			REM set "CMAKE_GENERATOR=NMake Makefiles JOM"
		)
		if "!_debug!"=="ON" (
			set "_debug=--debug-output"
		)

		REM -DCMAKE_DEBUG_POSTFIX=$DEBUG_POSTFIX

		cmake !_debug! "!AUTO_SOURCE_DIR!" !STELLA_CMAKE_EXTRA_FLAGS! !AUTO_INSTALL_CONF_FLAG_POSTFIX! ^
		-DCMAKE_C_FLAGS:STRING="!CMAKE_C_FLAGS!" -DCMAKE_CXX_FLAGS:STRING="!CMAKE_CXX_FLAGS!" ^
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="!CMAKE_SHARED_LINKER_FLAGS!" -DCMAKE_MODULE_LINKER_FLAGS:STRING="!CMAKE_MODULE_LINKER_FLAGS!" ^
		-DCMAKE_STATIC_LINKER_FLAGS:STRING="!CMAKE_STATIC_LINKER_FLAGS!" -DCMAKE_EXE_LINKER_FLAGS:STRING="!CMAKE_EXE_LINKER_FLAGS!" ^
		-DCMAKE_BUILD_TYPE=Release ^
		-DCMAKE_INSTALL_PREFIX="!AUTO_INSTALL_DIR!" ^
		-DCMAKE_INSTALL_BINDIR="!AUTO_INSTALL_DIR!\bin" -DINSTALL_BIN_DIR="!AUTO_INSTALL_DIR!\bin" -DCMAKE_INSTALL_LIBDIR="!AUTO_INSTALL_DIR!\lib" -DINSTALL_LIB_DIR="!AUTO_INSTALL_DIR!\lib" ^
		-DCMAKE_LIBRARY_PATH="!CMAKE_LIBRARY_PATH!" -DCMAKE_INCLUDE_PATH="!CMAKE_INCLUDE_PATH!" ^
		-DCMAKE_SYSTEM_INCLUDE_PATH:PATH="!CMAKE_INCLUDE_PATH!" -DCMAKE_SYSTEM_LIBRARY_PATH:PATH="!CMAKE_LIBRARY_PATH!" ^
		-G "!CMAKE_GENERATOR!"

	)


goto :eof


:launch_build
	set "AUTO_SOURCE_DIR=%~1"
	set "AUTO_INSTALL_DIR=%~2"
	set "AUTO_BUILD_DIR=%~3"
	set "OPT=%~4"

	:: parallelize build
	set "_opt_parallelize=!STELLA_BUILD_PARALLELIZE!"

	:: debug mode (default : OFF)
	set "_debug="
	:: configure step activation (default : TRUE)
	set "_opt_configure=ON"
	:: install step activation (default : TRUE)
	set "_opt_install=ON"
	:: build steps after building (in order)
	set "_flag_opt_post_build_step=OFF"
	set "_post_build_step="

	for %%O in (!OPT!) do (
		if "%%O"=="DEBUG" (
			set "_debug=ON"
			set "_flag_post_build_step=OFF"
		)
		if "%%O"=="NO_CONFIG" (
			set "_opt_configure=OFF"
			set "_flag_post_build_step=OFF"
		)
		if "%%O"=="NO_INSTALL" (
			set "_opt_install=OFF"
			set "_flag_post_build_step=OFF"
		)
		if "!_flag_post_build_step!"=="ON" (
			set "_post_build_step=!_post_build_step! %%O"
			set "_flag_post_build_step=OFF"
		)
		if "%%O"=="POST_BUILD_STEP" (
			set "_flag_post_build_step=ON"
		)
	)

	:: FLAGs
	:: AUTO_INSTALL_BUILD_FLAG_PREFIX -- TODO NOT USED
	:: AUTO_INSTALL_BUILD_FLAG_POSTFIX

	set "_FLAG_PARALLEL="

	if not exist "!AUTO_BUILD_DIR!" mkdir "!AUTO_BUILD_DIR!"
	cd /D "!AUTO_BUILD_DIR!"

	:: POST_BUILD_STEP
	if "!_opt_install!"=="ON" (
		set "_step_install_present="
		for %%s in (!_post_build_step!) do (
			if not "%%s"=="install" (
				set "_step_install_present=ON"
			)
		)
		:: we add install in first place if not already present
		if "!_step_install_present!"=="" (
			set "_post_build_step=install !_post_build_step!"
		)
	) else (
		set "_steps="
		for %%s in (!_post_build_step!) do (
			if not "%%s"=="install" (
				set "_steps=!_steps! %%s"
			)
		)
		set "_post_build_step=!_steps!"
	)


	REM TODO REVIEW MSYS / MinGW Make
	if "!STELLA_BUILD_BUILD_TOOL_BIN_FAMILY!"=="make" (
		if "!_opt_parallelize!"=="ON" (
			set "_FLAG_PARALLEL=-j!STELLA_NB_CPU!"
		)
		if "!_debug!"=="ON" (
			set "_debug=--debug=b"
		)
		if "!_opt_configure!"=="ON" (
			:: First step : build
			make !_debug! !_FLAG_PARALLEL! !AUTO_INSTALL_BUILD_FLAG_POSTFIX!

			:: Other build step
			for %%s in (!_post_build_step!) do (
				make !_debug! !_FLAG_PARALLEL! !AUTO_INSTALL_BUILD_FLAG_POSTFIX! %%s
			)
		) else (
			:: First step : build
			make !_debug! !_FLAG_PARALLEL! ^
			PREFIX="!AUTO_INSTALL_DIR!" prefix="!AUTO_INSTALL_DIR!" ^
			!AUTO_INSTALL_BUILD_FLAG_POSTFIX!

			:: Other build step
			for %%s in (!_post_build_step!) do (
				make !_debug! ^
				PREFIX="!AUTO_INSTALL_DIR!" prefix="!AUTO_INSTALL_DIR!" ^
				!AUTO_INSTALL_BUILD_FLAG_POSTFIX! %%s
			)
		)

	)

	if "!STELLA_BUILD_BUILD_TOOL_BIN_FAMILY!"=="make" (
		if "!_opt_parallelize!"=="ON" (
			set "_FLAG_PARALLEL=-j!STELLA_NB_CPU!"
		)
		if "!_debug!"=="ON" (
			set "_debug=--debug=b"
		)
		if "!_opt_configure!"=="ON" (
			:: First step : build
			make !_debug! !_FLAG_PARALLEL! !AUTO_INSTALL_BUILD_FLAG_POSTFIX!

			:: Other build step
			for %%s in (!_post_build_step!) do (
				make !_debug! !_FLAG_PARALLEL! !AUTO_INSTALL_BUILD_FLAG_POSTFIX! %%s
			)
		) else (
			:: First step : build
			mingw32-make !_debug! !_FLAG_PARALLEL! ^
			PREFIX="!AUTO_INSTALL_DIR!" prefix="!AUTO_INSTALL_DIR!" ^
			!AUTO_INSTALL_BUILD_FLAG_POSTFIX!

			:: Other build step
			for %%s in (!_post_build_step!) do (
				mingw32-make !_debug! ^
				PREFIX="!AUTO_INSTALL_DIR!" prefix="!AUTO_INSTALL_DIR!" ^
				!AUTO_INSTALL_BUILD_FLAG_POSTFIX! %%s
			)
		)

	)


	if "!STELLA_BUILD_BUILD_TOOL_BIN_FAMILY!"=="jom" (
		REM TODO parallelization flag ?
		REM if "!_opt_parallelize!"=="ON" (
		REM			set "_FLAG_PARALLEL=-j!STELLA_NB_CPU!"
		REM )
		REM TODO debut flag ?
		REM if "!_debug!"=="ON" (
		REM 	set "_debug=--debug=b"
		REM )

		:: First step : build
		jom !_debug! !_FLAG_PARALLEL! ^
		!AUTO_INSTALL_BUILD_FLAG_POSTFIX!

		:: Other build step
		for %%s in (!_post_build_step!) do (
			jom !_debug! !_FLAG_PARALLEL! ^
			!AUTO_INSTALL_BUILD_FLAG_POSTFIX! %%s
		)

	)


	if "!STELLA_BUILD_BUILD_TOOL_BIN_FAMILY!"=="ninja" (
		if not "!_opt_parallelize!"=="ON" (
			set "_FLAG_PARALLEL=-j1"
		) else (
			:: ninja is auto parallelized
			set "_FLAG_PARALLEL="
		)
		if "!_debug!"=="ON" (
			set "_debug=-v"
		)

		:: First step : build
		ninja !_debug! !_FLAG_PARALLEL! !AUTO_INSTALL_BUILD_FLAG_POSTFIX!

		:: Other build step
		for %%s in (!_post_build_step!) do (
			REM install step exist mainly when cmake generate it, otherwise ignore 'install' step
			if "%%s"=="install" (
				if "!STELLA_BUILD_CONFIG_TOOL_BIN_FAMILY!"=="cmake" (
					ninja !_debug! !AUTO_INSTALL_BUILD_FLAG_POSTFIX! %%s
				)
			) else (
				ninja !_debug! !AUTO_INSTALL_BUILD_FLAG_POSTFIX! %%s
			)
		)
	)

	if "!STELLA_BUILD_BUILD_TOOL_BIN_FAMILY!"=="nmake" (
		if "!_opt_parallelize!"=="ON" (
			set "CL=/MP !CL!"
		)

		:: First step : build
		nmake !AUTO_INSTALL_BUILD_FLAG_POSTFIX!

		:: Other build step
		for %%s in (!_post_build_step!) do (
			REM install step exist mainly when cmake generate it, otherwise ignore 'install' step
			if "%%s"=="install" (
				if "!STELLA_BUILD_CONFIG_TOOL_BIN_FAMILY!"=="cmake" (
					nmake !AUTO_INSTALL_BUILD_FLAG_POSTFIX! install
				)
			) else (
				nmake !AUTO_INSTALL_BUILD_FLAG_POSTFIX! install
			)
		)

	)

goto :eof



:dep_choose_origin
	set "_result_dep_choose_origin=%~1"
	set "_SCHEMA=%~2"


	call %STELLA_COMMON%\common-feature.bat :translate_schema "!_SCHEMA!" "_CHOOSE_ORIGIN_FEATURE_NAME"



	set "_origin=STELLA"
	for %%u in (!STELLA_BUILD_DEP_FROM_SYSTEM!) do (
		if "%%u"=="!_CHOOSE_ORIGIN_FEATURE_NAME!" (
			set "_origin=SYSTEM"
		)
	)

	set "%_result_dep_choose_origin%=!_origin!"

goto :eof


:: ENV and FLAGS management---------------------------------------------------------------------------------------------------------------------------------------

:reset_build_env
	:: BUILD FLAGS
	set STELLA_C_CXX_FLAGS=
	set STELLA_CPP_FLAGS=
	set STELLA_DYNAMIC_LINK_FLAGS=
	set STELLA_STATIC_LINK_FLAGS=
	set STELLA_LINK_FLAGS=
	set STELLA_CMAKE_EXTRA_FLAGS=
	set STELLA_CMAKE_RPATH_BUILD_PHASE=
	set STELLA_CMAKE_RPATH_INSTALL_PHASE=
	set STELLA_CMAKE_RPATH=
	set STELLA_CMAKE_RPATH_DARWIN=

	:: LINKED LIBRARIES
	set STELLA_LINKED_LIBS_LIST=
	set STELLA_LINKED_LIBS_C_CXX_FLAGS=
	set STELLA_LINKED_LIBS_CPP_FLAGS=
	set STELLA_LINKED_LIBS_LINK_FLAGS=
	set STELLA_LINKED_LIBS_CMAKE_LIBRARY_PATH=
	set STELLA_LINKED_LIBS_CMAKE_INCLUDE_PATH=
	set STELLA_BUILD_PKG_CONFIG_PATH=
	REM set LINKED_LIBS_PATH=

	:: BUILD MODE
	set "STELLA_BUILD_RELOCATE=!STELLA_BUILD_RELOCATE_DEFAULT!"
	set "STELLA_BUILD_RPATH=!STELLA_BUILD_RPATH_DEFAULT!"
	set "STELLA_BUILD_CPU_INSTRUCTION_SCOPE=!STELLA_BUILD_CPU_INSTRUCTION_SCOPE_DEFAULT!"
	set "STELLA_BUILD_OPTIMIZATION=!STELLA_BUILD_OPTIMIZATION_DEFAULT!"
	set "STELLA_BUILD_PARALLELIZE=!STELLA_BUILD_PARALLELIZE_DEFAULT!"
	set "STELLA_BUILD_LINK_MODE=!STELLA_BUILD_LINK_MODE_DEFAULT!"
	set "STELLA_BUILD_DEP_FROM_SYSTEM=!STELLA_BUILD_DEP_FROM_SYSTEM_DEFAULT!"
	set "STELLA_BUILD_ARCH=!STELLA_BUILD_ARCH_DEFAULT!"

	:: EXTERNAL VARIABLE
	:: reset variable from outside stella
	:: dont need this, they are reaffected when calling set_cmake_flags and set_standard_flags
	::flags to pass to the C compiler.
	set CFLAGS=
	::flags to pass to the C++ compiler.
	set CXXFLAGS=
	::flags to pass to the C preprocessor. Used when compiling C and C++
	set CPPFLAGS=
	::flags to pass to the linker
	set LINK=
	set LDFLAGS=
	set CMAKE_C_FLAGS=
	set CMAKE_CXX_FLAGS=
	set CMAKE_SHARED_LINKER_FLAGS=
	set CMAKE_MODULE_LINKER_FLAGS=
	set CMAKE_STATIC_LINKER_FLAGS=
	set CMAKE_EXE_LINKER_FLAGS=


	:: TOOLSET
	set STELLA_BUILD_TOOLSET=
	set STELLA_BUILD_TOOLSET_PATH=
	set STELLA_BUILD_EXTRA_TOOLSET=
	set STELLA_BUILD_CHECK_TOOLSET=
	set STELLA_BUILD_CONFIG_TOOL=
	set STELLA_BUILD_BUILD_TOOL=
	set STELLA_BUILD_COMPIL_FRONTEND=
	set STELLA_BUILD_CONFIG_TOOL_SCHEMA=
	set STELLA_BUILD_BUILD_TOOL_SCHEMA=
	set STELLA_BUILD_COMPIL_FRONTEND_SCHEMA=
	set STELLA_BUILD_CONFIG_TOOL_BIN_FAMILY=
	set STELLA_BUILD_BUILD_TOOL_BIN_FAMILY=
	set STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY=
goto :eof


:set_build_mode_default
	set "_arg1=%~1"
	set "_arg2=%~2"
	set "_arg3=%~3"

	if "!_arg1!"=="DEP_FROM_SYSTEM" (
		set "_var=STELLA_BUILD_!_arg1!_DEFAULT"
		set "!_var!=!_arg2! !_arg3!"
	) else (
		set "_var=STELLA_BUILD_!_arg1!_DEFAULT"
		set "!_var!=!_arg2!"
	)
goto :eof

:: TOOLSET agnostic
:set_build_mode

	:: STATIC/DYNAMIC LINK -----------------------------------------------------------------
	:: force build system to force a linking mode when it is possible
	:: STATIC | DYNAMIC | DEFAULT
	if "%~1"=="LINK_MODE" (
		set "STELLA_BUILD_LINK_MODE=%~2"
	)

	:: CPU_INSTRUCTION_SCOPE -----------------------------------------------------------------
	:: http://sdf.org/~riley/blog/2014/10/30/march-mtune/
	:: CURRENT | SAME_FAMILY | GENERIC
	if "%~1"=="CPU_INSTRUCTION_SCOPE" (
		set "STELLA_BUILD_CPU_INSTRUCTION_SCOPE=%~2"
	)
	:: ARCH -----------------------------------------------------------------
	:: Setting flags for a specific arch
	if "%~1"=="ARCH" (
		set "STELLA_BUILD_ARCH=%~2"
	)

	:: BINARIES RELOCATABLE -----------------------------------------------------------------
	:: ON | OFF
	::		every dependency will be added to a DT_NEEDED field in elf files
	:: 				on linux : DT_NEEDED contain dependency filename only
	:: 				on macos : ????? contain dependency filename only
	::		if OFF : RPATH values will be added for each dependency by absolute path
	::		if ON : RPATH values will contain relative values to a nested lib folder containing dependencies
	if "%~1"=="RELOCATE" (
		set "STELLA_BUILD_RELOCATE=%~2"
	)

	:: OPTIMIZATION LEVEL-----------------------------------------------------------------
	if "%~1"=="OPTIMIZATION" (
		set "STELLA_BUILD_OPTIMIZATION=%~2"
	)

	:: PARALLELIZATION -----------------------------------------------------------------
	if "%~1"=="PARALLELIZE" (
		set "STELLA_BUILD_PARALLELIZE=%~2"
	)

	:: DEPENDENCIES FROM SYSTEM -----------------------------------------------------------------
	:: these features will be picked from the system
	:: have an effect only for feature declared in FEAT_SOURCE_DEPENDENCIES, FEAT_BINARY_DEPENDENCIES or passed to  __link_feature_libray
	if "%~1"=="DEP_FROM_SYSTEM" (
		if "%~2"=="ADD" (
			set "STELLA_BUILD_DEP_FROM_SYSTEM=!STELLA_BUILD_DEP_FROM_SYSTEM! %~3"
		)
	)

goto :eof


:: CHECK BUILD ------------------------------------------------------------------------------------------------------------------------------
:inspect_and_fix_build
	set "_path=%~1"

	set _test_tool=
	call %STELLA_COMMON%\common.bat :which "_test1" "dumpbin"
	if not "!_test1!"=="" (
		set "_test_tool=dumpbin"
	) else (
		call %STELLA_COMMON%\common.bat :which "_test1" "objdump"
		if not "!_test1!"=="" (
			set "_test_tool=objdump"
		)
	)


	if not "!_test_tool!"=="" (

		for %%f in (!_path!\*) do (
			:: checking built files
			call :check_built_files "%%f"
		)
		for /D %%f in (!_path!\*) do (
			call :inspect_and_fix_build "%%f"
		)

	) else (
		echo ** WARN : can not find a test tool like dumpbin or objdump
	)

goto :eof


:check_built_files
	set "_path=%~1"

	set _is_bin=1
	if "!_test_tool!"=="dumpbin" (
		dumpbin !_path! 2>NUL | findstr "invalid format" 1>NUL && set "_is_bin="|| set "_is_bin=1"
	) else (
		if "!_test_tool!"=="objdump" (
			objdump -f !_path! 1>NUL 2>&1 || set "_is_bin="
		)
	)

	if "!_is_bin!"=="1" (
		echo.
		echo --
		echo ** Analysing !_path!
		call :check_arch "!_path!" "!STELLA_BUILD_ARCH!"
		call :check_dynamic_linking "!_path!"
		echo.
	)
goto :eof

:check_arch
	set "_path=%~1"
	set "_wanted_arch=%~2"

	if "!_test_tool!"=="dumpbin" (
		dumpbin /headers "!_path!" 2>NUL | findstr machine | findstr x86 1>NUL && set "_result=x86" || set "_result=x64"
	) else (
		if "!_test_tool!"=="objdump" (
			objdump -f "!_path!" 2>NUL | findstr x86-64 1>NUL && set "_result=x64" || set "_result=x86"
		)
	)

	if "!_wanted_arch!"=="" (
		echo *** Detected ARCH : !_result!
	) else (

		if "!_wanted_arch!"=="!_result!" (
			echo *** Detected ARCH : !_result! -- OK
		) else (
			echo *** Detected ARCH : !_result! Wanted ARCH : !_wanted_arch! -- WARN
		)
	)

goto :eof

REM check linked DLL
REM could be done with depends.exe /c (console cmd) OR with dumpbin OR with cmake
REM On windows lib search order is
REM 1.The directory from which the application loaded.
REM	2.The system directory. Use the GetSystemDirectory function to get the path of this directory.
REM	3.The 16-bit system directory. There is no function that obtains the path of this directory, but it is searched.
REM	4.The Windows directory. Use the GetWindowsDirectory function to get the path of this directory.
REM	5.The current directory.
REM	6.The directories that are listed in the PATH environment variable. Note that this does not include the per-application path specified by the App Paths registry key. The App Paths key is not used when computing the DLL search path.
:check_dynamic_linking
	set "_path=%~1"

	set "_path=%_path:\=\\%"
	cmake -DBINARY_FILE:PATH="!_path!" -P "!STELLA_POOL!\check_linked_lib.cmake"

goto :eof

:: VARIOUS ------------------------------------------------------------------------------------------------------------------------------

:: check if file.lib is an import lib or a static lib
:: by setting
::		UNKNOW, STATIC, IMPORT
:: first argument is the file to test
:: TODO FIXME when using this function, lib.exe or objdump.exe might not be on PATH yet (toolsets might be enabled later)
:: https://github.com/soluwalana/pefile-go
:is_import_or_static_lib
	set "_result_var=%~1"
	set "!_result_var!=UNKNOW"

	call %STELLA_COMMON%\common.bat :which "_test_tool" "lib"
	if "!_test_tool!"=="" (
		call %STELLA_COMMON%\common.bat :which "_test_tool" "objdump"
		if "!_test_tool!"=="" (
			echo ** WARN cannot find lib.exe or objdump to analyse lib file
		) else (
			set "_test_tool=objdump -a"
		)
	) else (
		set "_test_tool=lib /list"
	)

	if not "!_test_tool!"=="" (
		set _nb_dll=0
		set _nb_obj=0

		for /f %%i in ('!_test_tool! %~2 2^>NUL ^| findstr /N ".dll$" ^| find /c ":"') do set _nb_dll=%%i
		for /f %%j in ('!_test_tool! %~2 2^>NUL ^| findstr /N ".obj$" ^| find /c ":"') do set _nb_obj=%%j
		for /f %%k in ('!_test_tool! %~2 2^>NUL ^| findstr /N ".o$" ^| find /c ":"') do set /a _nb_obj=%%k+!_nb_obj!
		if !_nb_dll! EQU 0 if !_nb_obj! GTR 0 (
			set "!_result_var!=STATIC"
		)
		if !_nb_obj! EQU 0 if !_nb_dll! GTR 0 (
			set "!_result_var!=IMPORT"
		)
	)
goto :eof



:dep_choose_origin
	set "_result_dep_choose_origin=%~1"
	set "_SCHEMA=%~2"


	call %STELLA_COMMON%\common-feature.bat :translate_schema "!_SCHEMA!" "_CHOOSE_ORIGIN_FEATURE_NAME"



	set "_origin=STELLA"
	for %%u in (!STELLA_BUILD_DEP_FROM_SYSTEM!) do (
		if "%%u"=="!_CHOOSE_ORIGIN_FEATURE_NAME!" (
			set "_origin=SYSTEM"
		)
	)

	set "%_result_dep_choose_origin%=!_origin!"

goto :eof