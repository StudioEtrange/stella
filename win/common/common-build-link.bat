
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


	if "!STELLA_BUILD_COMPIL_FRONTEND!"=="" (
		echo ** WARN : compil frontend empty - did you set a toolset ?
	)

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


	REM TODO dont need ?
	REM set "LINKED_LIBS_PATH=!LINKED_LIBS_PATH! !_opt_flavour! !_LIB!"

	:: set stella build system flags ----
	if "!_opt_set_flags!"=="ON" (
		call :set_link_flags "!_LIB!" "!_INCLUDE!" "!_libs_name!"
	)

	:: set <var> flags ----
	if not "!_var_flags!"=="" (
		call :link_flags "!STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY!" "!_var_flags!" "!_lib_path!" "!_include_path!" "!_libs_name!"
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

	if not "!STELLA_BUILD_CONFIG_TOOL_BIN_FAMILY!"=="cmake" (
		REM if "!STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY!"=="mingw32-gcc" (
		REM 	call :link_flags_gcc "_flags" "!_lib_path!" "!_include_path!" "!_libs_name!"
			REM set "LINKED_LIBS_C_CXX_FLAGS=!LINKED_LIBS_C_CXX_FLAGS! !_flags_C_CXX_FLAGS!"
			REM set "LINKED_LIBS_CPP_FLAGS=!LINKED_LIBS_CPP_FLAGS! !_flags_CPP_FLAGS!"
			REM set "LINKED_LIBS_LINK_FLAGS=!LINKED_LIBS_LINK_FLAGS !_flags_LINK_FLAGS!"
		)
		if "!STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY!"=="gcc" (
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