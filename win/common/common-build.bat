@echo off
call %*
goto :eof


:: BUILD WORKFLOW

:: SET SOME DEFAULT BUILD MODE
::	__set_build_mode_default "RELOCATE" "ON"
::  __set_build_mode_default "DARWIN_STDLIB" "LIBCPP"

:: START BUILD SESSION
::	__start_build_session (reset everything to default values or empty)

::		GET SOURCE CODE
::		__get_resource

::		SET TOOLSET
::		__set_toolset STANDARD|MS|CUSTOM

:: 		SET CUSTOM BUILD MODE
::		__set_build_mode ARCH x86
::
::		LINK BUILD TO OTHER LIBRARY
::		__link_feature_library

::		AUTOMATIC BUILD AND INSTALL
::		__auto_build

::				SET BUILD ENV AND FLAGS
::				__prepare_build
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



:start_build_session
	call :reset_build_env
goto :eof


:: TOOLSET ------------------------------------------------------------------------------------------------------------------------------
:set_toolset
	set "MODE=%~1"
	set "OPT=%~2"

	:: configure tool
	set _flag_configure=
	set "CONFIG_TOOL=!STELLA_BUILD_DEFAULT_CONFIG_TOOL!"

	:: build tool
	set _flag_build=
	set "BUILD_TOOL=!STELLA_BUILD_DEFAULT_BUILD_TOOL!"

	:: compiler frontend
	set _flag_frontend=
	set "COMPIL_FRONTEND=!STELLA_BUILD_DEFAULT_COMPIL_FRONTEND!"

	if "!MODE!"=="CUSTOM" (
		for %%O in (%OPT%) do (
			if "!_flag_configure!"=="ON" (
				set "CONFIG_TOOL=%%O"
				set "_flag_configure=FORCE"
			)
			if "%%O"=="CONFIG_TOOL" (
				set "_flag_configure=ON"
			)
			if "!_flag_build!"=="ON" (
				set "BUILD_TOOL=%%O"
				set "_flag_build=FORCE"
			)
			if "%%O"=="BUILD_TOOL" (
				set "_flag_build=ON"
			)
			if "!_flag_frontend!"=="ON" (
				set "COMPIL_FRONTEND=%%O"
				set "_flag_frontend=FORCE"
			)
			if "%%O"=="COMPIL_FRONTEND" (
				set "_flag_frontend=ON"
			)
		)
	)

	if "!MODE!"=="STANDARD" (
		set "STELLA_BUILD_TOOLSET=STANDARD"

		set "_flag_configure=FORCE"
		set "CONFIG_TOOL=cmake"

		set "BUILD_TOOL=mingw-make"

		set "_flag_frontend=FORCE"
		set "COMPIL_FRONTEND=gcc"
	)


	if "!MODE!"=="MS" (
		set "STELLA_BUILD_TOOLSET=MS"

		set "_flag_configure=FORCE"
		set "CONFIG_TOOL=cmake"

		set "BUILD_TOOL=nmake"

		set "_flag_frontend=FORCE"
		set "COMPIL_FRONTEND=cl"
	)

	if "!CONFIG_TOOL!"=="cmake" (
		if not "!_flag_build!"=="FORCE" (
			call %STELLA_COMMON%\common.bat :which "_test1" "ninja"
			if not "!_test1!"=="" (
				set "BUILD_TOOL=ninja"
				if not "!_flag_frontend!"=="FORCE" (
					set "COMPIL_FRONTEND=gcc"
				)
			)
		)
	)


	set "STELLA_BUILD_CONFIG_TOOL=!CONFIG_TOOL!"
	set "STELLA_BUILD_BUILD_TOOL=!BUILD_TOOL!"
	set "STELLA_BUILD_COMPIL_FRONTEND=!COMPIL_FRONTEND!"


goto :eof

:require_current_toolset
	echo ** Require build toolset : !STELLA_BUILD_TOOLSET!
	if "!STELLA_BUILD_TOOLSET!" == "MS" (
		call %STELLA_COMMON%\common-platform.bat :require "cl" "vs2015community" "PREFER_SYSTEM"
	)
	if "!STELLA_BUILD_TOOLSET!" == "STANDARD" (
		call %STELLA_COMMON%\common-platform.bat :require "gcc" "mingw-w64" "PREFER_STELLA"
	)

	if "!STELLA_BUILD_CONFIG_TOOL!" == "cmake" (
		call %STELLA_COMMON%\common-platform.bat :require "cmake" "cmake#3_3_2@x86:binary" "PREFER_STELLA"
	)

	if "!STELLA_BUILD_BUILD_TOOL!" == "ninja" (
		call %STELLA_COMMON%\common-platform.bat :require "ninja" "ninja" "PREFER_STELLA"
	)
	if "!STELLA_BUILD_BUILD_TOOL!" == "mingw-make" (
		call %STELLA_COMMON%\common-platform.bat :require "mingw32-make" "mingw-w64" "PREFER_STELLA"
	)
	if "!STELLA_BUILD_BUILD_TOOL!" == "nmake" (
		call %STELLA_COMMON%\common-platform.bat :require "nmake" "vs2015community" "PREFER_SYSTEM"
	)

	if "!STELLA_BUILD_COMPIL_FRONTEND!" == "gcc" (
		call %STELLA_COMMON%\common-platform.bat :require "gcc" "mingw-w64" "PREFER_STELLA"
	)
	if "!STELLA_BUILD_COMPIL_FRONTEND!" == "jom" (
		call %STELLA_COMMON%\common-platform.bat :require "jom" "jom" "PREFER_STELLA"
	)
	if "!STELLA_BUILD_COMPIL_FRONTEND!" == "cl" (
		call %STELLA_COMMON%\common-platform.bat :require "cl" "vs2015community" "PREFER_SYSTEM"
	)

	echo ** Require build toolset : !STELLA_BUILD_TOOLSET!

goto :eof

:: BUILD ------------------------------------------------------------------------------------------------------------------------------
:auto_build
	set "NAME=%~1"
	set "SOURCE_DIR=%~2"
	set "INSTALL_DIR=%~3"
	set "OPT=%~4"

	:: DEBUG SOURCE_KEEP BUILD_KEEP NO_CONFIG NO_BUILD NO_OUT_OF_TREE_BUILD NO_INSPECT NO_INSTALL


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


	set "_check="
	if "!_opt_configure!"=="ON" (
		set "_check=1"
	)
	if "!_opt_build!"=="ON" (
		set "_check=1"
	)
	if "!_check!"=="1" (
		call :require_current_toolset
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


	::if "!STELLA_BUILD_CONFIG_TOOL!"=="configure" (
	::	echo "!AUTO_SOURCE_DIR!\configure" --prefix="!AUTO_INSTALL_DIR!" !AUTO_INSTALL_CONF_FLAG_POSTFIX!
	::)

	if "!STELLA_BUILD_CONFIG_TOOL!"=="cmake" (
		if "!STELLA_BUILD_BUILD_TOOL!"=="mingw-make" (
			set "CMAKE_GENERATOR=MinGW Makefiles"
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


	for %%O in (!OPT!) do (
		if "%%O"=="DEBUG" (
			set "_debug=ON"
		)
		if "%%O"=="NO_CONFIG" (
			set "_opt_configure=OFF"
		)
		if "%%O"=="NO_INSTALL" (
			set "_opt_install=OFF"
		)
	)

	:: FLAGs
	:: AUTO_INSTALL_BUILD_FLAG_PREFIX -- TODO NOT USED
	:: AUTO_INSTALL_BUILD_FLAG_POSTFIX

	set "_FLAG_PARALLEL="

	if not exist "!AUTO_BUILD_DIR!" mkdir "!AUTO_BUILD_DIR!"
	cd /D "!AUTO_BUILD_DIR!"

	if "!STELLA_BUILD_BUILD_TOOL!"=="mingw-make" (
		if "!_opt_parallelize!"=="ON" (
			set "_FLAG_PARALLEL=-j!STELLA_NB_CPU!"
		)
		if "!_debug!"=="ON" (
			set "_debug=--debug=b"
		)
		if "!_opt_configure!"=="ON" (
			mingw32-make !_debug! !_FLAG_PARALLEL! !AUTO_INSTALL_BUILD_FLAG_POSTFIX!
			if "!_opt_install!"=="ON" (
				mingw32-make !_debug! !AUTO_INSTALL_BUILD_FLAG_POSTFIX! install
			)
		) else (
			mingw32-make !_debug! !_FLAG_PARALLEL! ^
			PREFIX="!AUTO_INSTALL_DIR!" prefix="!AUTO_INSTALL_DIR!" ^
			!AUTO_INSTALL_BUILD_FLAG_POSTFIX!
			if "!_opt_install!"=="ON" (
				mingw32-make !_debug! ^
				PREFIX="!AUTO_INSTALL_DIR!" prefix="!AUTO_INSTALL_DIR!" ^
				!AUTO_INSTALL_BUILD_FLAG_POSTFIX! install
			)
		)

	)


	if "!STELLA_BUILD_BUILD_TOOL!"=="ninja" (
		if not "!_opt_parallelize!"=="ON" (
			set "_FLAG_PARALLEL=-j1"
		) else (
			:: ninja is auto parallelized
			set "_FLAG_PARALLEL="
		)
		if "!_debug!"=="ON" (
			set "_debug=-v"
		)

		ninja !_debug! !_FLAG_PARALLEL! !AUTO_INSTALL_BUILD_FLAG_POSTFIX!

		REM install step exist mainly when cmake generate it
		if "!STELLA_BUILD_CONFIG_TOOL!"=="cmake" (
			if "!_opt_install!"=="ON" (
				ninja !_debug! !AUTO_INSTALL_BUILD_FLAG_POSTFIX! install
			)
		)
	)

	if "!STELLA_BUILD_BUILD_TOOL!"=="nmake" (
		if "!_opt_parallelize!"=="ON" (
			set "CL=/MP !CL!"
		)
		nmake !AUTO_INSTALL_BUILD_FLAG_POSTFIX!

		REM install step exist mainly when cmake generate it
		if "!STELLA_BUILD_CONFIG_TOOL!"=="cmake" (
			if "!_opt_install!"=="ON" (
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

:link_feature_library
	set "SCHEMA=%~1"
	set "OPT=%~2"


	set _ROOT=
	set _BIN=
	set _LIB=
	set _INCLUDE=


	set _folders=OFF
	set _var_folders=
	set _flags=OFF
	set _var_flags=
	set _opt_flavour=
	set _flag_lib_folder=OFF
	set _lib_folder=lib
	set _flag_bin_folder=OFF
	set _bin_folder=bin
	set _flag_include_folder=OFF
	set _include_folder=include
	set _opt_set_flags=ON
	set _flag_libs_name=OFF
	set _libs_name=
	set _flag_rename=OFF
	set _list_rename=


	if "!STELLA_BUILD_LINK_MODE!"=="DEFAULT" (
		set "_opt_flavour=DEFAULT"
	)
	if "!STELLA_BUILD_LINK_MODE!"=="DYNAMIC" (
		set "_opt_flavour=FORCE_DYNAMIC"
	)
	if "!STELLA_BUILD_LINK_MODE!"=="STATIC" (
		set "_opt_flavour=FORCE_STATIC"
	)

	REM FORCE_RENAME : rename files when isolating files -- only apply when FORCE_STATIC or FORCE_DYNAMIC is ON
	for %%O in (%OPT%) do (
		if "%%O"=="FORCE_STATIC" (
			set _opt_flavour=%%O
			set _flag_libs_name=OFF
			set _flag_rename=OFF
		)
		if "%%O"=="FORCE_DYNAMIC" (
			set _opt_flavour=%%O
			set _flag_libs_name=OFF
			set _flag_rename=OFF
		)

		if "!_flag_lib_folder!"=="ON" (
			set "_lib_folder=%%O"
			set _flag_lib_folder=OFF
		)
		if "%%O"=="FORCE_LIB_FOLDER" (
			set _flag_lib_folder=ON
			set _flag_libs_name=OFF
			set _flag_rename=OFF
		)
		if "!_flag_bin_folder!"=="ON" (
			set "_bin_folder=%%O"
			set _flag_bin_folder=OFF
		)
		if "%%O"=="FORCE_BIN_FOLDER" (
			set _flag_bin_folder=ON
			set _flag_libs_name=OFF
			set _flag_rename=OFF
		)
		if "!_flag_include_folder!"=="ON" (
			set "_include_folder=%%O"
			set _flag_include_folder=OFF
		)
		if "%%O"=="FORCE_INCLUDE_FOLDER" (
			set _flag_include_folder=ON
			set _flag_libs_name=OFF
			set _flag_rename=OFF
		)

		if "!_flags!"=="ON" (
			set "_var_flags=%%O"
			set _flags=OFF
		)
		if "%%O"=="GET_FLAGS" (
			set _flags=ON
			set _flag_libs_name=OFF
			set _flag_rename=OFF
		)
		if "!_folders!"=="ON" (
			set "_var_folders=%%O"
			set _folders=OFF
		)
		if "%%O"=="GET_FOLDER" (
			set _folders=ON
			set _flag_libs_name=OFF
			set _flag_rename=OFF
		)

		if "%%O"=="NO_SET_FLAGS" (
			set _opt_set_flags=OFF
			set _flag_libs_name=OFF
			set _flag_rename=OFF
		)

		if "!_flag_libs_name!"=="ON" (
			set "_libs_name=!_libs_name! %%O"
		)
		if "%%O"=="LIBS_NAME" (
			set "_flag_libs_name=ON"
			set _flag_rename=OFF
		)

		if "!_flag_rename!"=="ON" (
			set "_list_rename=!_list_rename! %%O"
		)
		if "%%O"=="FORCE_RENAME" (
			set "_flag_rename=ON"
			set _flag_libs_name=OFF
		)

	)

	if "!_opt_flavour!"=="DEFAULT" (
		set "_list_rename="
	)

	:: check origin for this schema
	set "_origin="
	set _dummy=%SCHEMA:FORCE_ORIGIN_STELLA =%
	if not "!_dummy!"=="!SCHEMA!" (
		set "_origin=STELLA"
		set "SCHEMA=!_dummy!"
	) else (
		set _dummy=%SCHEMA:FORCE_ORIGIN_SYSTEM =%
		if not "!_dummy!"=="!SCHEMA!" (
			set "_origin=SYSTEM"
			set "SCHEMA=!_dummy!"
		) else (

			call :dep_choose_origin "_origin" "!SCHEMA!"
		)
	)

	if "!_origin!"=="SYSTEM" (
		echo We do not link against STELLA version of !SCHEMA!, but from SYSTEM.
		goto :eof
	)

	echo ** Linked to !SCHEMA!

	:: INSPECT required lib through schema
	call %STELLA_COMMON%\common-feature.bat :push_schema_context
	call %STELLA_COMMON%\common-feature.bat :feature_inspect !SCHEMA!

	if "!TEST_FEATURE!"=="1" (
		set "REQUIRED_LIB_ROOT=!FEAT_INSTALL_ROOT!"
	) else (
		set "REQUIRED_LIB_ROOT="
		echo ** ERROR : depend on lib !SCHEMA!
	)
	call %STELLA_COMMON%\common-feature.bat :pop_schema_context

	:: ISOLATE LIBS
	set "LIB_TARGET_FOLDER="

	if "!_opt_flavour!"=="FORCE_STATIC" (

		set "LIB_TARGET_FOLDER=!REQUIRED_LIB_ROOT!\stella-dep-static"
		echo *** Isolate dependencies into !LIB_TARGET_FOLDER!

		call %STELLA_COMMON%\common.bat :del_folder "!LIB_TARGET_FOLDER!"
		mkdir "!LIB_TARGET_FOLDER!"

		echo *** Copying items from !REQUIRED_LIB_ROOT!\!_lib_folder! to !LIB_TARGET_FOLDER!
		for %%f in ("!REQUIRED_LIB_ROOT!\!_lib_folder!\*.*") do (
			call :is_import_or_static_lib "_type" "%%f"
			if "!_type!"=="STATIC" (
				set "_renamed_filename="
				set "_filename=%%~nxf"
				set _pair=1
				set _do_rename=0
				for %%k in (!_list_rename!) do (
					if "!_pair!"=="1" (
						set _pair=0
						if "!_filename!"=="%%k" set _do_rename=1
					) else (
						if "!_do_rename!"=="1" set "_renamed_filename=%%k"
						set _pair=1
						set _do_rename=0
					)
				)
				copy /Y "%%f" "!LIB_TARGET_FOLDER!\!_renamed_filename!"
			)
		)
	)
	if "!_opt_flavour!"=="FORCE_DYNAMIC" (

		set "LIB_TARGET_FOLDER=!REQUIRED_LIB_ROOT!\stella-dep-dynamic"
		echo *** Isolate dependencies into !LIB_TARGET_FOLDER!

		call %STELLA_COMMON%\common.bat :del_folder "!LIB_TARGET_FOLDER!"
		mkdir "!LIB_TARGET_FOLDER!"

		echo *** Copying items from !REQUIRED_LIB_ROOT!\!_lib_folder! to !LIB_TARGET_FOLDER!
		for %%f in ("!REQUIRED_LIB_ROOT!\!_lib_folder!\*.*") do (
			call :is_import_or_static_lib "_type" "%%f"
			if "!_type!"=="IMPORT" (
				set "_renamed_filename="
				set "_filename=%%~nxf"
				set _pair=1
				set _do_rename=0
				for %%k in (!_list_rename!) do (
					if "!_pair!"=="1" (
						set _pair=0
						if "!_filename!"=="%%k" set _do_rename=1
					) else (
						if "!_do_rename!"=="1" set "_renamed_filename=%%k"
						set _pair=1
						set _do_rename=0
					)
				)
				copy /Y "%%f" "!LIB_TARGET_FOLDER!\!_renamed_filename!"
			)
		)
		REM TODO DO NOT COPY DLL ?
		echo *** Copying DLL items from !REQUIRED_LIB_ROOT!\!_bin_folder! to !LIB_TARGET_FOLDER!
		for %%f in ("!REQUIRED_LIB_ROOT!\!_bin_folder!\*.dll") do (
			set "_renamed_filename="
			set "_filename=%%~nxf"
			set _pair=1
			set _do_rename=0
			for %%k in (!_list_rename!) do (
				if "!_pair!"=="1" (
					set _pair=0
					if "!_filename!"=="%%k" set _do_rename=1
				) else (
					if "!_do_rename!"=="1" set "_renamed_filename=%%k"
					set _pair=1
					set _do_rename=0
				)
			)
			copy /Y "%%f" "!LIB_TARGET_FOLDER!\!_renamed_filename!"
		)

	)
	if "!_opt_flavour!"=="DEFAULT" (
		set "LIB_TARGET_FOLDER=!REQUIRED_LIB_ROOT!\!_lib_folder!"
	)

	:: RESULTS

	set "_ROOT=!REQUIRED_LIB_ROOT!"
	set "_BIN=!REQUIRED_LIB_ROOT!\bin"
	set "_INCLUDE=!REQUIRED_LIB_ROOT!\!_include_folder!"
	set "_LIB=!LIB_TARGET_FOLDER!"


	set "LINKED_LIBS_PATH=!LINKED_LIBS_PATH! !_opt_flavour! !_LIB!"

	:: set stella build system flags ----
	if "!_opt_set_flags!"=="ON" (
		call :set_link_flags "!_LIB!" "!_INCLUDE!" "!_libs_name!"
	)

	:: set <var> flags ----
	if not "!_var_flags!"=="" (
		call :link_flags "!STELLA_BUILD_COMPIL_FRONTEND!" "!_var_flags!" "!_lib_path!" "!_include_path!" "!_libs_name!"
	)

	:: set <folder> vars ----
	if not "!_var_folders!"=="" (
		set "_t=!_var_folders!_ROOT"
		set "%_t%=!_ROOT!"
		set "_t=!_var_folders!_LIB"
		set "%_t%=!_LIB!"
		set "_t=!_var_folders!_INCLUDE"
		set "%_t%=!_INCLUDE!"
		set "_t=!_var_folders!_BIN"
		set "%_t%=!_BIN!"
	)
goto :eof


:set_link_flags
	set "_lib_path=%~1"
	set "_include_path=%~2"
	set "_libs_name=%~3"

	if not "!STELLA_BUILD_CONFIG_TOOL!"=="cmake" (
		if "!STELLA_BUILD_COMPIL_FRONTEND!"=="gcc" (
			call :link_flags_gcc "_flags" "!_lib_path!" "!_include_path!" "!_libs_name!"
			set "LINKED_LIBS_C_CXX_FLAGS=!LINKED_LIBS_C_CXX_FLAGS! !_flags_C_CXX_FLAGS!"
			set "LINKED_LIBS_CPP_FLAGS=!LINKED_LIBS_CPP_FLAGS! !_flags_CPP_FLAGS!"
			set "LINKED_LIBS_LINK_FLAGS=!LINKED_LIBS_LINK_FLAGS !_flags_LINK_FLAGS!"
		)
		if "!STELLA_BUILD_COMPIL_FRONTEND!"=="cl" (
			call :link_flags_cl "_flags" "!_lib_path!" "!_include_path!" "!_libs_name!"
			set "LINKED_LIBS_C_CXX_FLAGS=!LINKED_LIBS_C_CXX_FLAGS! !_flags_C_CXX_FLAGS!"
			set "LINKED_LIBS_CPP_FLAGS=!LINKED_LIBS_CPP_FLAGS! !_flags_CPP_FLAGS!"
			set "LINKED_LIBS_LINK_FLAGS=!LINKED_LIBS_LINK_FLAGS !_flags_LINK_FLAGS!"
		)

	) else (
		set "LINKED_LIBS_CMAKE_LIBRARY_PATH=!LINKED_LIBS_CMAKE_LIBRARY_PATH!;!_lib_path!"
		set "LINKED_LIBS_CMAKE_INCLUDE_PATH=!LINKED_LIBS_CMAKE_INCLUDE_PATH!;!_include_path!"
	)

goto :eof

:: set flag for each compiler front end
:link_flags
	set "_frontend=%~1"
	set "_var_flags=%~2"
	set "_lib_path=%~3"
	set "_include_path=%~4"
	set "_libs_name=%~5"

	if "!_frontend!"=="gcc" (
		call :link_flags_gcc "!_var_flags!" "!_lib_path!" "!_include_path!" "!_libs_name!"
	)

	if "!_frontend!"=="cl" (
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
	set "STELLA_BUILD_TOOLSET="
	set "STELLA_BUILD_CONFIG_TOOL="
	set "STELLA_BUILD_BUILD_TOOL="
	set "STELLA_BUILD_COMPIL_FRONTEND="
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



	:: set flags -------------
	REM this env vars are setted if we use cmake or not
	if "!STELLA_BUILD_COMPIL_FRONTEND!"=="gcc" (
		set CC=gcc
		set CXX=gcc
		set CPP=gcc
	)

	REM this env vars are setted if we use cmake or not
	REM https://msdn.microsoft.com/en-us/library/d7ahf12s.aspx
	REM set AS=ml
	REM set BC=bc
	REM set RC=rc
	if "!STELLA_BUILD_COMPIL_FRONTEND!"=="cl" (
		call :vs_env_vars !STELLA_BUILD_ARCH!
		set CC=cl
		set CXX=cl
		set CPP=cl

	)


	if "!STELLA_BUILD_CONFIG_TOOL!"=="cmake" (
		call :set_env_vars_for_cmake
	) else (
		if "!STELLA_BUILD_COMPIL_FRONTEND!"=="gcc" (
			call :set_env_vars_for_gcc

		) else (

			if "!STELLA_BUILD_COMPIL_FRONTEND!"=="cl" (
				call :set_env_vars_for_cl
			) else (
				:: DEFAULT FLAGS
				call :set_env_vars_for_gcc
			)
		)
	)


	:: print build info ------------
	echo ** BUILD TOOLSET
	echo ====^> Configuration Tool : !STELLA_BUILD_CONFIG_TOOL!$
	echo ====^> Build management Tool : !STELLA_BUILD_BUILD_TOOL!
	echo ====^> Compiler Frontend : !STELLA_BUILD_COMPIL_FRONTEND!
	echo ** BUILD INFO
	echo ====^> Build arch directive : !STELLA_BUILD_ARCH!
	echo ====^> Parallelized (if supported) : !STELLA_BUILD_PARALLELIZE!
	echo ====^> Relocatable : !STELLA_BUILD_RELOCATE!
	echo ====^> Linked lib from stella features : !LINKED_LIBS_LIST!
	echo ** FOLDERS
	echo ====^> Install directory : !INSTALL_DIR!
	echo ====^> Source directory : !SOURCE_DIR!
	echo ====^> Build directory : !BUILD_DIR!
	echo ** SOME FLAGS
	echo ====^> STELLA_C_CXX_FLAGS : !STELLA_C_CXX_FLAGS!
	echo ====^> STELLA_CPP_FLAGS : !STELLA_CPP_FLAGS!
	echo ====^> STELLA_LINK_FLAGS : !STELLA_LINK_FLAGS!
	echo ====^> STELLA_DYNAMIC_LINK_FLAGS : !STELLA_DYNAMIC_LINK_FLAGS!
	echo ====^> STELLA_STATIC_LINK_FLAGS : !STELLA_STATIC_LINK_FLAGS!
	echo ====^> CMAKE_LIBRARY_PATH : !CMAKE_LIBRARY_PATH!
	echo ====^> CMAKE_INCLUDE_PATH : !CMAKE_INCLUDE_PATH!
	echo ====^> STELLA_CMAKE_EXTRA_FLAGS : !STELLA_CMAKE_EXTRA_FLAGS!
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
	call %STELLA_COMMON%\common.bat :trim "LINKED_LIBS_CMAKE_LIBRARY_PATH" "!LINKED_LIBS_CMAKE_LIBRARY_PATH!"
	call %STELLA_COMMON%\common.bat :trim "LINKED_LIBS_CMAKE_INCLUDE_PATH" "!LINKED_LIBS_CMAKE_INCLUDE_PATH!"
	set "CMAKE_LIBRARY_PATH=!LINKED_LIBS_CMAKE_LIBRARY_PATH!"
	set "CMAKE_INCLUDE_PATH=!LINKED_LIBS_CMAKE_INCLUDE_PATH!"
	:: -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH"

	:: TODO do we need this ?
	if not "!CMAKE_LIBRARY_PATH!"=="" set "CMAKE_LIBRARY_PATH=%CMAKE_LIBRARY_PATH:\=\\%"
	if not "!CMAKE_INCLUDE_PATH!"=="" set "CMAKE_INCLUDE_PATH=%CMAKE_INCLUDE_PATH:\=\\%"


	call %STELLA_COMMON%\common.bat :trim "STELLA_CMAKE_EXTRA_FLAGS" "!STELLA_CMAKE_EXTRA_FLAGS!"

goto :eof



:: set flags and env for standard build tools (GNU MAKE,...)
:set_env_vars_for_gcc

	:: ADD linked libraries flags
	call %STELLA_COMMON%\common.bat :trim "LINKED_LIBS_C_CXX_FLAGS" "!LINKED_LIBS_C_CXX_FLAGS!"
	call %STELLA_COMMON%\common.bat :trim "LINKED_LIBS_CPP_FLAGS" "!LINKED_LIBS_CPP_FLAGS!"
	call %STELLA_COMMON%\common.bat :trim "LINKED_LIBS_LINK_FLAGS" "!LINKED_LIBS_LINK_FLAGS!"

	set "STELLA_C_CXX_FLAGS=!STELLA_C_CXX_FLAGS! !LINKED_LIBS_C_CXX_FLAGS!"
	set "STELLA_CPP_FLAGS=!STELLA_CPP_FLAGS! !LINKED_LIBS_CPP_FLAGS!"
	set "STELLA_LINK_FLAGS=!LINKED_LIBS_LINK_FLAGS! !STELLA_LINK_FLAGS! !STELLA_DYNAMIC_LINK_FLAGS! !STELLA_STATIC_LINK_FLAGS!"


 	:: flags to pass to the C compiler.
	set "CFLAGS=!STELLA_C_CXX_FLAGS!"
	:: flags to pass to the C++ compiler.
	set "CXXFLAGS=!STELLA_C_CXX_FLAGS!"
	:: flags to pass to the C preprocessor. Used when compiling C and C++ (Used to pass include_folder)
	set "CPPFLAGS=!STELLA_CPP_FLAGS!"

	:: flags to pass to the linker
	set "LDFLAGS=!STELLA_LINK_FLAGS!"
	::if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		:: TODO experimental new flags
		:: https://sourceware.org/binutils/docs/ld/Options.html
		:: http://www.kaizou.org/2015/01/linux-libraries/
		::export LDFLAGS="-Wl,--copy-dt-needed-entries -Wl,--as-needed -Wl,--no-allow-shlib-undefined -Wl,--no-undefined $STELLA_LINK_FLAGS"

goto :eof


:: set flags and env for standard build tools (NMAKE,...)
:set_env_vars_for_cl


	:: ADD linked libraries flags
	call %STELLA_COMMON%\common.bat :trim "LINKED_LIBS_C_CXX_FLAGS" "!LINKED_LIBS_C_CXX_FLAGS!"
	call %STELLA_COMMON%\common.bat :trim "LINKED_LIBS_CPP_FLAGS" "!LINKED_LIBS_CPP_FLAGS!"
	call %STELLA_COMMON%\common.bat :trim "LINKED_LIBS_LINK_FLAGS" "!LINKED_LIBS_LINK_FLAGS!"

	set "STELLA_C_CXX_FLAGS=!STELLA_C_CXX_FLAGS! !LINKED_LIBS_C_CXX_FLAGS!"
	set "STELLA_CPP_FLAGS=!STELLA_CPP_FLAGS! !LINKED_LIBS_CPP_FLAGS!"
	set "STELLA_LINK_FLAGS=!LINKED_LIBS_LINK_FLAGS! !STELLA_LINK_FLAGS! !STELLA_DYNAMIC_LINK_FLAGS! !STELLA_STATIC_LINK_FLAGS!"

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

:: settings compiler flags -- depend on toolset (configure tool, build tool, compiler frontend)

:set_build_env
	:: CPU_INSTRUCTION_SCOPE -----------------------------------------------------------------
	:: http://sdf.org/~riley/blog/2014/10/30/march-mtune/
	if "%~1"=="CPU_INSTRUCTION_SCOPE" (
		if "!STELLA_BUILD_COMPIL_FRONTEND!"=="gcc" (
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
		if "!STELLA_BUILD_COMPIL_FRONTEND!"=="gcc" (
			if not "%~2"=="" (
				set "STELLA_C_CXX_FLAGS=!STELLA_C_CXX_FLAGS! -O%~2"
			)
		)
	)

	:: ARCH -----------------------------------------------------------------
	:: Setting flags for a specific arch
	if "%~1"=="ARCH" (
		if "!STELLA_BUILD_COMPIL_FRONTEND!"=="gcc" (
			if "%~2"=="x86" (
				set "STELLA_C_CXX_FLAGS=-m32 !STELLA_C_CXX_FLAGS!"
			)
			if "%~2"=="x64" (
				set "STELLA_C_CXX_FLAGS=-m64 !STELLA_C_CXX_FLAGS!"
			)
		)
		if "!STELLA_BUILD_COMPIL_FRONTEND!"=="cl" (
			echo TODO arch for cl ?
			REM set "CL=/arch:x86"
			REM set "LINK=/MACHINE:X86"
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
	REM Visual Studio 2005
	if not "%VS80COMNTOOLS%"=="" (
		set "vstudio=vs8"
		set "vcpath=%VS80COMNTOOLS%..\..\VC"
		echo ** Detected Visual Studio 2005 in %VS80COMNTOOLS%
		echo ** WARN Please update Visual Studio or it may not work
		if "!_target_arch!"=="arm" echo ** WARNING ARM target supported with Visual Studio 2012 / VC11 and after only
	)
	REM Visual Studio 2008
	if not "%VS90COMNTOOLS%"=="" (
		set "vstudio=vs9"
		set "vcpath=%VS90COMNTOOLS%..\..\VC"
		echo ** Detected Visual Studio 2008 in !VS90COMNTOOLS!
		echo ** WARN Please update Visual Studio or it may not work
		if "!_target_arch!"=="arm" echo ** WARNING ARM target supported with Visual Studio 2012 / VC11 and after only
	)
	REM Visual Studio 2010
	if not "%VS100COMNTOOLS%"=="" (
		set "vstudio=vs10"
		set "vcpath=%VS100COMNTOOLS%..\..\VC"
		echo ** Detected Visual Studio 2010 in !VS100COMNTOOLS!
		echo ** WARN You should update Visual Studio
		if "!_target_arch!"=="arm" echo ** WARNING ARM target supported with Visual Studio 2012 / VC11 and after only
	)
	REM Visual Studio 2012
	if not "%VS110COMNTOOLS%"=="" (
		set "vstudio=vs11"
		set "vcpath=%VS110COMNTOOLS%..\..\VC"
		echo ** Detected Visual Studio 2012 in !VS110COMNTOOLS!
	)
	REM Visual Studio 2013
	if not "%VS120COMNTOOLS%"=="" (
		set "vstudio=vs12"
		set "vcpath=%VS120COMNTOOLS%..\..\VC"
		echo ** Detected Visual Studio 2013 in !VS120COMNTOOLS!
	)
	REM Visual Studio 2014 OR VS13/VC13 does not exist
	REM Visual Studio 2015
	if not "%VS140COMNTOOLS%"=="" (
		set "vstudio=vs14"
		set "vcpath=%VS140COMNTOOLS%..\..\VC"
		echo ** Detected Visual Studio 2015 in !VS140COMNTOOLS!
	)


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



	REM ORIGINALPATH is a variable setted with some version of VS or WINSDK command line.
	REM ORIGINALPATH is setted with the value of %PATH% variable of the system
	REM so ORIGINALPATH miss our previously setted PATH setting. It is like a "reset" of PATH
	REM so we have to set again our own PATH after this

	REM Reinit PATH Values
	call %STELLA_COMMON%\common-feature.bat :feature_reinit_installed
goto :eof
