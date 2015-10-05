@echo off
call %*


:: BUILD WORKFLOW

:: SET SOME DEFAULT BUILD MODE
::	__set_build_mode_default "RELOCATE" "ON"
::  __set_build_mode_default "DARWIN_STDLIB" "LIBCPP"

:: START BUILD SESSION
::	__start_build_session (reset everything to default values or empty)

::		GET SOURCE CODE
::		__get_resource

:: 		SET CUSTOM BUILD MODE
::		__set_build_mode ARCH x86
::
::		LINK BUILD TO OTHER LIBRARY
::		__link_feature_library

::		AUTOMATIC BUILD
::		__auto_build

::				SET BUILD ENV AND FLAGS
::				__apply_build_env
::						call __set_standard_build_flags
::						call __set_cmake_build_flags

::				LAUNCH CONFIG TOOL
::				__launch_configure
::				LAUNCH BUILD TOOL
::				__launch_build

::				__inspect_build
::						call __fix_built_files 
::						call __check_built_files



:: BUILD ------------------------------------------------------------------------------------------------------------------------------

:start_build_session
	call :reset_build_env
goto :eof


:auto_build
	set "NAME=%~1"
	set "SOURCE_DIR=%~2"
	set "INSTALL_DIR=%~3"
	set "OPT=%~4"

	:: DEBUG SOURCE_KEEP BUILD_KEEP UNPARALLELIZE NO_CONFIG CONFIG_TOOL xxxx NO_BUILD BUILD_TOOL xxxx ARCH xxxx NO_OUT_OF_TREE_BUILD NO_INSPECT_BUILD NO_INSTALL

	


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
	set "_opt_inspect_build=ON"
	for %%O in (%OPT%) do (
		if "%%O"=="SOURCE_KEEP" set _opt_source_keep=ON
		if "%%O"=="BUILD_KEEP" set _opt_build_keep=ON
		if "%%O"=="NO_CONFIG" set _opt_configure=OFF
		if "%%O"=="NO_BUILD" set _opt_build=ON
		if "%%O"=="NO_OUT_OF_TREE_BUILD" set _opt_out_of_tree_build=ON
		if "%%O"=="NO_INSPECT_BUILD" set _opt_inspect_build=OFF
	)

	:: can not build out of tree without configure first
	if "!_opt_configure!"=="OFF" (
		set "_opt_out_of_tree_build=OFF"
	)


	echo  ** Auto-building !NAME! into !INSTALL_DIR! for !STELLA_CURRENT_OS!

	:: folder stuff
	set "BUILD_DIR=!SOURCE_DIR!"
	if "!_opt_out_of_tree_build!"=="ON" (
		call %STELLA_COMMON%\common.bat :dirname "!SOURCE_DIR!" "t1"
		call %STELLA_COMMON%\common.bat :basename "!SOURCE_DIR!" "t2"
		set "BUILD_DIR=!t1!\!!t2!-build"
	)

	if not exist "!INSTALL_DIR!" mkdir !INSTALL_DIR!
	
	if "!_opt_out_of_tree_build!"=="ON" (
		if "!FORCE!"=="1" (
			call %STELLA_COMMON%\common.bat :del_folder "!BUILD_DIR!"
		)
		if not "!_opt_build_keep!"=="ON" (
			call %STELLA_COMMON%\common.bat :del_folder "!BUILD_DIR!"
		)
	)


	:: requirements
	:: TODO
	::__require "gcc" "build-chain-standard" "PREFER_SYSTEM"

	:: relocation mode
	if "!STELLA_BUILD_RELOCATE!"=="ON" (
		echo *** We are in RELOCATION mode !
	)

	
	:: __compute_mode "$INSTALL_DIR"

	# set build env
	__apply_build_env "$OPT"

	# launch process
	[ "$_opt_configure" == "ON" ] && __launch_configure "$SOURCE_DIR" "$INSTALL_DIR" "$BUILD_DIR" "$OPT"
	[ "$_opt_build" == "ON" ] && __launch_build "$SOURCE_DIR" "$INSTALL_DIR" "$BUILD_DIR" "$OPT"


	# clean workspace
	[ ! "$_opt_source_keep" == "ON" ] && rm -Rf "$SOURCE_DIR"

	if [ "$_opt_out_of_tree_build" == "ON" ]; then
		[ ! "$_opt_build_keep" == "ON" ] && rm -Rf "$BUILD_DIR"
	fi

	cd "$INSTALL_DIR"
	[ "$_opt_inspect_build" == "ON" ] && __inspect_build "$INSTALL_DIR"

	echo " ** Done"
goto :eof



:: VARIOUS ------------------------------------------------------------------------------------------------------------------------------

:: check if file.lib is an import lib or a static lib
:: by setting 
::		LIB_TYPE with UNKNOW, STATIC, IMPORT
:: first argument is the file to test
:is_import_or_static_lib
	set LIB_TYPE=UNKNOW
	set _nb_dll=0
	set _nb_obj=0
	for /f %%i in ('lib /list %~1 ^| findstr /N ".dll$" ^| find /c ":"') do set _nb_dll=%%i
	for /f %%j in ('lib /list %~1 ^| findstr /N ".obj$" ^| find /c ":"') do set _nb_obj=%%j
	for /f %%j in ('lib /list %~1 ^| findstr /N ".o$" ^| find /c ":"') do set /a _nb_obj=%%j+!_nb_obj!
	if %_nb_dll% EQU 0 if %_nb_obj% GTR 0 (
		set LIB_TYPE=STATIC
	)
	if %_nb_obj% EQU 0 if %_nb_dll% GTR 0 (
		set LIB_TYPE=IMPORT
	)
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
	set LINKED_LIBS_C_CXX_FLAGS=
	set LINKED_LIBS_CPP_FLAGS=
	set LINKED_LIBS_LINK_FLAGS=
	set LINKED_LIBS_PATH=
	set LINKED_LIBS_CMAKE_LIBRARY_PATH=
	set LINKED_LIBS_CMAKE_INCLUDE_PATH=

	:: BUILD MODE
	set "STELLA_BUILD_RELOCATE=!STELLA_BUILD_RELOCATE_DEFAULT"
	set "STELLA_BUILD_RPATH=!STELLA_BUILD_RPATH_DEFAULT"
	set "STELLA_BUILD_CPU_INSTRUCTION_SCOPE=!STELLA_BUILD_CPU_INSTRUCTION_SCOPE_DEFAULT"
	set "STELLA_BUILD_OPTIMIZATION=!STELLA_BUILD_OPTIMIZATION_DEFAULT"
	set "STELLA_BUILD_PARALLELIZE=!STELLA_BUILD_PARALLELIZE_DEFAULT"
	set "STELLA_BUILD_LINK_MODE=!STELLA_BUILD_LINK_MODE_DEFAULT"
	set "STELLA_BUILD_DEP_FROM_SYSTEM=!STELLA_BUILD_DEP_FROM_SYSTEM_DEFAULT"
	set "STELLA_BUILD_ARCH=!STELLA_BUILD_ARCH_DEFAULT"
	set "STELLA_BUILD_DARWIN_STDLIB=!STELLA_BUILD_DARWIN_STDLIB"
	set "STELLA_BUILD_MACOSX_DEPLOYMENT_TARGET=!STELLA_BUILD_MACOSX_DEPLOYMENT_TARGET"

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
	set LDFLAGS=
	set CMAKE_C_FLAGS=
	set CMAKE_CXX_FLAGS=
	set CMAKE_SHARED_LINKER_FLAGS=
	set CMAKE_MODULE_LINKER_FLAGS=
	set CMAKE_STATIC_LINKER_FLAGS=
	set CMAKE_EXE_LINKER_FLAGS=
goto :eof


